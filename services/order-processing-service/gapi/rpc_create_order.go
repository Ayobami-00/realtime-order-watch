package gapi

import (
	"context"
	"database/sql"

	"github.com/Ayobami-00/realtime-order-watch/services/order-processing-service/db/sqlc"
	"github.com/Ayobami-00/realtime-order-watch/services/order-processing-service/pb"
	"github.com/Ayobami-00/realtime-order-watch/services/order-processing-service/repository"
	"github.com/google/uuid"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	// Consider adding your logger and OpenTelemetry imports here later
)

func (s *Server) CreateOrder(ctx context.Context, req *pb.CreateOrderRequest) (*pb.CreateOrderResponse, error) {
	// Access timeout from server config if needed:
	// ctx, cancel := context.WithTimeout(ctx, s.timeout)
	// defer cancel()

	// Basic input validation
	if req.GetCustomerId() == "" || req.GetAmount() <= 0 {
		return nil, status.Errorf(codes.InvalidArgument, "invalid order details: customer_id and amount are required")
	}

	orderID, err := uuid.NewRandom()
	if err != nil {
		// s.logger.Error("failed to generate order ID", zap.Error(err)) // Example logging
		return nil, status.Errorf(codes.Internal, "failed to generate order ID: %s", err)
	}

	initialStatus := "PENDING" // Or a status from your config/constants

	arg := db.CreateOrderParams{
		ID:          orderID,
		CustomerID:  req.GetCustomerId(),
		Amount:      req.GetAmount(),
		Description: sql.NullString{String: req.GetDescription(), Valid: req.GetDescription() != ""},
		Status:      sql.NullString{String: initialStatus, Valid: true},
	}

	// TODO: Add OpenTelemetry tracing span here for the CreateOrder gRPC call
	// tracer := otel.Tracer("gapi") // Use a tracer instance from your server or a global one
	// spanCtx, span := tracer.Start(ctx, "gapi.Server.CreateOrder")
	// defer span.End()
	// span.SetAttributes(attribute.String("customer_id", req.GetCustomerId()))

	dbOrder, err := s.orderRepo.CreateOrder(ctx, arg) // Use s.orderRepo
	if err != nil {
		// span.RecordError(err)
		// span.SetStatus(otelcodes.Error, "failed to create order in DB")
		// s.logger.Error("failed to create order", zap.Error(err), zap.String("customer_id", req.GetCustomerId()))
		return nil, status.Errorf(codes.Internal, "failed to create order: %s", err)
	}

	// span.SetAttributes(attribute.String("order_id", dbOrder.ID.String()))
	// s.logger.Info("Order created successfully", zap.String("order_id", dbOrder.ID.String()))

	return &pb.CreateOrderResponse{Order: repository.ConvertDBOrderToPBOrder(dbOrder)}, nil
}
