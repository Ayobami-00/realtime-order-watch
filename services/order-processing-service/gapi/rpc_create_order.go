package gapi

import (
	"context"
	"log" // Replace with your structured logger

	db "github.com/Ayobami-00/realtime-order-watch/order-processing-service/db/sqlc"
	orderspb "github.com/Ayobami-00/realtime-order-watch/order-processing-service/pb"
	"github.com/google/uuid"
	grpcodes "google.golang.org/grpc/codes" // Alias to avoid conflict
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/timestamppb"

	"go.opentelemetry.io/otel/attribute"
	otelcodes "go.opentelemetry.io/otel/codes" // Import otelcodes
	"go.opentelemetry.io/otel/trace"
	pgtype "github.com/jackc/pgx/v5/pgtype" // Added pgtype import
)

const (
	OrderStatusCreated = "CREATED"
	// Define other statuses as needed
	OrderStatusFailedValidation = "FAILED_VALIDATION"
	OrderStatusFailedInternal   = "FAILED_INTERNAL"
)

func (s *Server) CreateOrder(ctx context.Context, req *orderspb.CreateOrderRequest) (*orderspb.CreateOrderResponse, error) {
	// OpenTelemetry Tracing
	ctx, span := s.tracer.Start(ctx, "gapi.CreateOrder", trace.WithAttributes(
		attribute.String("customer_id", req.GetCustomerId()),
		attribute.Float64("amount", req.GetAmount()),
	))
	defer span.End()

	// --- Input Validation ---
	if req.GetCustomerId() == "" {
		span.SetStatus(otelcodes.Error, "customer_id is required")
		return nil, status.Errorf(grpcodes.InvalidArgument, "customer_id is required")
	}
	if req.GetAmount() <= 0 {
		span.SetStatus(otelcodes.Error, "amount must be positive")
		return nil, status.Errorf(grpcodes.InvalidArgument, "amount must be positive")
	}
	// Add more validation as needed (e.g., description length)

	orderID := uuid.New()
	span.SetAttributes(attribute.String("generated_order_id", orderID.String()))

	arg := db.CreateOrderParams{
		ID:          orderID,
		CustomerID:  req.GetCustomerId(),
		Amount:      req.GetAmount(),
		Description: pgtype.Text{String: req.GetDescription(), Valid: req.GetDescription() != ""},
		Status:      pgtype.Text{String: OrderStatusCreated, Valid: true}, // Initial status
	}

	// --- Database Interaction ---
	dbOrder, err := s.store.CreateOrder(ctx, arg)
	if err != nil {
		log.Printf("Failed to create order in DB: %v", err) // Replace with structured logging
		span.RecordError(err)
		span.SetStatus(otelcodes.Error, "failed to create order")
		return nil, status.Errorf(grpcodes.Internal, "failed to create order: %v", err)
	}

	span.SetAttributes(attribute.String("db.order_id", dbOrder.ID.String()))
	log.Printf("Order created successfully with ID: %s", dbOrder.ID.String())

	// --- Response ---
	return &orderspb.CreateOrderResponse{
		Order: &orderspb.Order{
			OrderId:     dbOrder.ID.String(),
			CustomerId:  dbOrder.CustomerID,
			Amount:      dbOrder.Amount,
			Description: dbOrder.Description.String,
			Status:      dbOrder.Status.String,
			CreatedAt:   timestamppb.New(dbOrder.CreatedAt.Time),
			UpdatedAt:   timestamppb.New(dbOrder.UpdatedAt.Time),
		},
	}, nil
}
