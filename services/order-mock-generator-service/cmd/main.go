package main

import (
	"context"
	"log"
	"math/rand"
	"os"
	"strconv"
	"time"

	"github.com/Ayobami-00/realtime-order-watch/order-mock-generator-service/bootstrap"
	"github.com/Ayobami-00/realtime-order-watch/order-mock-generator-service/pkg/order_processing_service"
	pb "github.com/Ayobami-00/realtime-order-watch/order-mock-generator-service/pkg/order_processing_service/pb"
	"github.com/google/uuid"
)

const (
	defaultRequestFrequencyPerSecond = 50
	invalidDataPercentage            = 15 // Percentage of requests to send with invalid data (0-100)
)

func main() {
	log.Println("Starting Order Mock Generator Service...")

	app := bootstrap.App()

	env := app.Env

	// Get request frequency from environment variable or use default
	reqFrequencyStr := os.Getenv("REQUEST_FREQUENCY_PER_SECOND")
	reqFrequency := defaultRequestFrequencyPerSecond
	if freq, err := strconv.Atoi(reqFrequencyStr); err == nil && freq > 0 {
		reqFrequency = freq
	} else if reqFrequencyStr != "" {
		log.Printf("Invalid REQUEST_FREQUENCY_PER_SECOND value '%s', using default %d", reqFrequencyStr, defaultRequestFrequencyPerSecond)
	}
	log.Printf("Request frequency set to %d per second", reqFrequency)

	// Initialize Order Processing Service Client
	// The client.go uses env.AuthServiceUrl, ensure this is set in your .env as ORDER_SERVICE_URL or similar
	orderServiceClient := order_processing_service.InitOrderProcessingServiceClient(env)
	if orderServiceClient == nil {
		log.Fatal("Failed to initialize Order Processing Service client")
	}

	log.Println("Order Processing Service client initialized.")

	// Seed random number generator
	rand.Seed(time.Now().UnixNano())

	ticker := time.NewTicker(time.Second / time.Duration(reqFrequency))
	defer ticker.Stop()

	ctx := context.Background()

	for range ticker.C {
		go func() {
			orderReq := generateMockOrderRequest()

			log.Printf("Sending order: CustomerID: %s, Amount: %.2f, Description: %s",
				orderReq.CustomerId, orderReq.Amount, orderReq.Description)

			resp, err := orderServiceClient.CreateOrder(ctx, orderReq)
			if err != nil {
				log.Printf("Error creating order: %v", err)
				// TODO: Add more specific error handling or metrics for failed requests
				return
			}
			log.Printf("Order created successfully: OrderID: %s", resp.GetOrder().GetOrderId())
		}()
	}
}

func generateMockOrderRequest() *pb.CreateOrderRequest {
	customerId := uuid.NewString()
	amount := rand.Float64() * 200 // Random amount between 0 and 200
	description := "Mock order item " + uuid.New().String()[:8]

	// Introduce invalid data randomly
	if rand.Intn(100) < invalidDataPercentage {
		switch rand.Intn(3) {
		case 0:
			log.Println("Introducing invalid data: Negative amount")
			amount = -50.0
		case 1:
			log.Println("Introducing invalid data: Empty description")
			description = ""
		case 2:
			log.Println("Introducing invalid data: Empty customer ID")
			customerId = ""
		}
	}

	return &pb.CreateOrderRequest{
		CustomerId:  customerId,
		Amount:      amount,
		Description: description,
	}
}
