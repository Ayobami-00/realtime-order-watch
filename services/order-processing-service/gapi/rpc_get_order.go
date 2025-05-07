package gapi

import (
	"context"
	"database/sql"
	"log" // Replace with your structured logger

	db "github.com/Ayobami-00/realtime-order-watch/order-processing-service/db/sqlc"
	orderspb "github.com/Ayobami-00/realtime-order-watch/order-processing-service/pb"

	"github.com/google/uuid"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/timestamppb"

	otelcodes "go.opentelemetry.io/otel/codes"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/trace"
)

func (s *Server) GetOrder(ctx context.Context, req *orderspb.GetOrderRequest) (*orderspb.GetOrderResponse, error) {
	// OpenTelemetry Tracing
	ctx, span := s.tracer.Start(ctx, "gapi.GetOrder", trace.WithAttributes(
		attribute.String("order_id", req.GetOrderId()),
	))
	defer span.End()

	// --- Input Validation ---
	orderIDStr := req.GetOrderId()
	if orderIDStr == "" {
		span.SetStatus(otelcodes.Error, "order_id is required")
		return nil, status.Errorf(codes.InvalidArgument, "order_id is required")
	}

	orderID, err := uuid.Parse(orderIDStr)
	if err != nil {
		span.SetStatus(otelcodes.Error, "invalid order_id format")
		return nil, status.Errorf(codes.InvalidArgument, "invalid order_id format: %v", err)
	}

	// --- Database Interaction ---
	var dbOrder db.Order // Explicitly type dbOrder
	dbOrder, err = s.store.GetOrder(ctx, orderID) // Assign using =
	if err != nil {
		if err == sql.ErrNoRows {
			log.Printf("Order not found with ID: %s", orderIDStr)
			span.SetStatus(otelcodes.Error, "order not found")
			return nil, status.Errorf(codes.NotFound, "order not found with ID %s", orderIDStr)
		}
		log.Printf("Failed to get order from DB: %v", err) // Replace with structured logging
		span.RecordError(err)
		span.SetStatus(otelcodes.Error, "failed to get order")
		return nil, status.Errorf(codes.Internal, "failed to get order: %v", err)
	}

	log.Printf("Order retrieved successfully with ID: %s", dbOrder.ID.String())

	// --- Response Assembly ---
	resp := &orderspb.GetOrderResponse{
		Order: &orderspb.Order{
			OrderId:     dbOrder.ID.String(),
			CustomerId:  dbOrder.CustomerID, // customer_id is string in db.Order
			Amount:      dbOrder.Amount,      // Corrected: Use Amount
			Description: dbOrder.Description.String,
			Status:      dbOrder.Status.String,
			CreatedAt:   timestamppb.New(dbOrder.CreatedAt.Time),
			UpdatedAt:   timestamppb.New(dbOrder.UpdatedAt.Time),
		},
	}

	return resp, nil
}
