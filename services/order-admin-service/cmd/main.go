package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"sync"
	"time"

	orderspb "github.com/Ayobami-00/realtime-order-watch/order-admin-service/pb"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

const (
	orderProcessingServiceAddress = "localhost:9090" // Address of the order-processing-service gRPC server
)

var (
	orderServiceClient orderspb.OrderServiceClient
	sseClients         = make(map[chan []byte]bool)
	sseClientsMutex    sync.Mutex
)

// broadcastToSSEClients sends data to all connected SSE clients.
func broadcastToSSEClients(data []byte) {
	sseClientsMutex.Lock()
	defer sseClientsMutex.Unlock()
	for clientChan := range sseClients {
		// Non-blocking send
		select {
		case clientChan <- data:
		default:
			log.Println("SSE client channel full, skipping")
		}
	}
}

// streamOrdersFromProcessingService connects to the gRPC stream and broadcasts orders.
func streamOrdersFromProcessingService(ctx context.Context) {
	log.Println("Attempting to connect to OrderProcessingService stream...")
	stream, err := orderServiceClient.StreamOrders(ctx, &orderspb.StreamOrdersRequest{})
	if err != nil {
		log.Printf("Failed to call StreamOrders: %v. Retrying in 5 seconds...", err)
		time.Sleep(5 * time.Second)
		go streamOrdersFromProcessingService(ctx) // Retry connection
		return
	}
	log.Println("Successfully connected to OrderProcessingService stream.")

	for {
		order, err := stream.Recv()
		if err == io.EOF {
			log.Println("Order stream ended (EOF).")
			time.Sleep(5 * time.Second) // Wait before attempting to reconnect
			go streamOrdersFromProcessingService(ctx) // Reconnect
			return
		}
		if err != nil {
			log.Printf("Error receiving order from stream: %v. Reconnecting...", err)
			time.Sleep(5 * time.Second) // Wait before attempting to reconnect
			go streamOrdersFromProcessingService(ctx) // Reconnect
			return
		}

		log.Printf("Received order: %+v", order)
		jsonData, err := json.Marshal(order)
		if err != nil {
			log.Printf("Failed to marshal order to JSON: %v", err)
			continue
		}
		broadcastToSSEClients(jsonData)
	}
}

func main() {
	fmt.Println("Starting Order Admin Service...")

	// --- Initialize gRPC client to order-processing-service ---
	conn, err := grpc.Dial(orderProcessingServiceAddress, grpc.WithTransportCredentials(insecure.NewCredentials()), grpc.WithBlock())
	if err != nil {
		log.Fatalf("Failed to connect to order-processing-service: %v", err)
	}
	defer conn.Close()
	orderServiceClient = orderspb.NewOrderServiceClient(conn)
	log.Printf("Connected to gRPC server at %s", orderProcessingServiceAddress)

	// Start the goroutine to stream orders from the processing service
	go streamOrdersFromProcessingService(context.Background())

	// --- Setup HTTP server and routes ---
	// Serve static files (HTML, CSS, JS)
	fs := http.FileServer(http.Dir("./static"))
	http.Handle("/static/", http.StripPrefix("/static/", fs))

	// Serve index.html for the root path
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/" {
            http.NotFound(w, r)
            return
        }
		http.ServeFile(w, r, "./static/index.html")
	})

	// SSE endpoint for streaming orders to the frontend
	http.HandleFunc("/sse/orders", func(w http.ResponseWriter, r *http.Request) {
		log.Println("Client connected to SSE orders stream")
		w.Header().Set("Content-Type", "text/event-stream")
		w.Header().Set("Cache-Control", "no-cache")
		w.Header().Set("Connection", "keep-alive")
		w.Header().Set("Access-Control-Allow-Origin", "*") // CORS for local dev

		clientChan := make(chan []byte, 10) // Buffered channel for this client

		sseClientsMutex.Lock()
		sseClients[clientChan] = true
		sseClientsMutex.Unlock()

		defer func() {
			sseClientsMutex.Lock()
			delete(sseClients, clientChan)
			sseClientsMutex.Unlock()
			close(clientChan)
			log.Println("Client disconnected from SSE orders stream, cleaned up channel.")
		}()

		// Send an initial connection confirmation message
		initMsg := map[string]string{"message": "Connected to order stream!"}
		initJSON, _ := json.Marshal(initMsg)
		fmt.Fprintf(w, "data: %s\n\n", initJSON)
		
		flusher, ok := w.(http.Flusher)
		if !ok {
			log.Println("Streaming unsupported by client!")
			http.Error(w, "Streaming unsupported!", http.StatusInternalServerError)
			return
		}
		flusher.Flush() // Send initial message

		ctx := r.Context()
		for {
			select {
			case data := <-clientChan:
				_, err := fmt.Fprintf(w, "data: %s\n\n", data)
				if err != nil {
					log.Printf("Error writing to SSE client: %v", err)
					return // Client probably disconnected
				}
				flusher.Flush()
			case <-ctx.Done():
				log.Println("SSE client context done (disconnected).")
				return
			}
		}
	})

	port := "8081"
	log.Printf("Order Admin Service listening on :%s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatalf("Failed to start HTTP server: %v", err)
	}
}
