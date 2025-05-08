package gapi

import (
	"fmt"
	"sync"
	"time"

	"github.com/Ayobami-00/realtime-order-watch/order-processing-service/bootstrap"
	db "github.com/Ayobami-00/realtime-order-watch/order-processing-service/db/sqlc"
	pb "github.com/Ayobami-00/realtime-order-watch/order-processing-service/pb"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/trace"
)

type Server struct {
	pb.UnimplementedOrderServiceServer
	config  bootstrap.Env
	store   db.Store
	timeout time.Duration
	tracer  trace.Tracer

	// For order streaming
	subscribersMutex sync.Mutex
	orderSubscribers map[string]chan *pb.Order
}

// NewServer creates a new gRPC server
func NewServer(config bootstrap.Env, store db.Store, timeout time.Duration) (*Server, error) {
	if store == nil {
		return nil, fmt.Errorf("database store cannot be nil")
	}

	server := &Server{
		config:           config,
		store:            store,
		timeout:          timeout,
		tracer:           otel.Tracer("gapi-server"),
		orderSubscribers: make(map[string]chan *pb.Order),
	}

	return server, nil
}

// broadcastOrder sends an order to all active subscribers.
func (s *Server) broadcastOrder(order *pb.Order) {
	s.subscribersMutex.Lock()
	defer s.subscribersMutex.Unlock()

	for id, ch := range s.orderSubscribers {
		// Non-blocking send
		select {
		case ch <- order:
		default:
			// Subscriber's channel is full or closed, consider logging or removing
			fmt.Printf("Failed to send order to subscriber %s, channel full or closed\n", id)
		}
	}
}
