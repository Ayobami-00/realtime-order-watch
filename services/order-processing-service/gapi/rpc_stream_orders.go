package gapi

import (
	"fmt"

	pb "github.com/Ayobami-00/realtime-order-watch/order-processing-service/pb"
	"github.com/google/uuid"
)

// StreamOrders streams newly created or updated orders to the client.
func (s *Server) StreamOrders(_ *pb.StreamOrdersRequest, stream pb.OrderService_StreamOrdersServer) error {
	// Generate a unique ID for this subscriber
	subscriberID := uuid.New().String()
	orderChan := make(chan *pb.Order, 10) // Buffered channel

	s.subscribersMutex.Lock()
	s.orderSubscribers[subscriberID] = orderChan
	s.subscribersMutex.Unlock()

	fmt.Printf("Client %s connected for order streaming\n", subscriberID)

	// Ensure subscriber is cleaned up when the stream is closed
	defer func() {
		s.subscribersMutex.Lock()
		delete(s.orderSubscribers, subscriberID)
		s.subscribersMutex.Unlock()
		close(orderChan)
		fmt.Printf("Client %s disconnected, cleaning up resources\n", subscriberID)
	}()

	ctx := stream.Context()
	for {
		select {
		case <-ctx.Done(): // Client disconnected
			fmt.Printf("Client %s context done: %v\n", subscriberID, ctx.Err())
			return ctx.Err()
		case order := <-orderChan:
			if err := stream.Send(order); err != nil {
				fmt.Printf("Error sending order to client %s: %v\n", subscriberID, err)
				return err
			}
			fmt.Printf("Sent order %s to client %s\n", order.OrderId, subscriberID)
		}
	}
}
