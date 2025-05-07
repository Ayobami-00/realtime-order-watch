package gapi

import (
	"fmt"
	"time"

	"github.com/Ayobami-00/realtime-order-watch/services/order-processing-service/bootstrap"
	"github.com/Ayobami-00/realtime-order-watch/services/order-processing-service/db/sqlc"
	"github.com/Ayobami-00/realtime-order-watch/services/order-processing-service/pb"
	"github.com/Ayobami-00/realtime-order-watch/services/order-processing-service/repository"
)

type Server struct {
	pb.UnimplementedOrderServiceServer
	config    bootstrap.Env
	store     db.Store
	orderRepo repository.OrderRepository
	timeout   time.Duration
}

func NewServer(config bootstrap.Env, store db.Store, timeout time.Duration) (*Server, error) {
	orderRepo := repository.NewSQLCOrderRepository(store)
	if orderRepo == nil {
		return nil, fmt.Errorf("failed to create order repository")
	}

	server := &Server{
		config:    config,
		store:     store,
		orderRepo: orderRepo,
		timeout:   timeout,
	}

	return server, nil
}
