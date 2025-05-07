package gapi

import (
	"fmt"
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
}

// NewServer creates a new gRPC server
func NewServer(config bootstrap.Env, store db.Store, timeout time.Duration) (*Server, error) {
	if store == nil {
		return nil, fmt.Errorf("database store cannot be nil")
	}

	server := &Server{
		config:  config,
		store:   store,
		timeout: timeout,
		tracer:  otel.Tracer("gapi-server"),
	}

	return server, nil
}
