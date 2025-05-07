package gapi

import (
	"context"
	"database/sql"
	"log" // Replace with your structured logger

	db "github.com/Ayobami-00/realtime-order-watch/order-processing-service/db/sqlc"
	orderspb "github.com/Ayobami-00/realtime-order-watch/order-processing-service/pb"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"
	grpcodes "google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/timestamppb"

	"go.opentelemetry.io/otel/attribute"
	otelcodes "go.opentelemetry.io/otel/codes"
	"go.opentelemetry.io/otel/trace"
)

// IsValidOrderStatus checks if the provided status is a valid one.
// Consider moving this to a shared package or defining statuses more centrally
// if used in multiple places (e.g., from pb.OrderStatus enum if you define one).
func IsValidOrderStatus(orderStatus string) bool {
	switch orderStatus {
	case "PENDING", "PROCESSING", "SHIPPED", "DELIVERED", "CANCELLED", "FAILED", "CREATED": // "CREATED" from rpc_create_order.go
		return true
	default:
		return false
	}
}

func (s *Server) UpdateOrderStatus(ctx context.Context, req *orderspb.UpdateOrderStatusRequest) (*orderspb.UpdateOrderStatusResponse, error) {
	// OpenTelemetry Tracing
	ctx, span := s.tracer.Start(ctx, "gapi.UpdateOrderStatus", trace.WithAttributes(
		attribute.String("order_id", req.GetOrderId()),
		attribute.String("new_status", req.GetStatus()),
	))
	defer span.End()

	// --- Input Validation ---
	orderIDStr := req.GetOrderId()
	if orderIDStr == "" {
		span.SetStatus(otelcodes.Error, "order_id is required")
		return nil, status.Errorf(grpcodes.InvalidArgument, "order_id is required")
	}

	orderID, err := uuid.Parse(orderIDStr)
	if err != nil {
		span.SetStatus(otelcodes.Error, "invalid order_id format")
		return nil, status.Errorf(grpcodes.InvalidArgument, "invalid order_id format: %v", err)
	}

	newStatus := req.GetStatus()
	if newStatus == "" {
		span.SetStatus(otelcodes.Error, "status is required")
		return nil, status.Errorf(grpcodes.InvalidArgument, "status is required")
	}

	if !IsValidOrderStatus(newStatus) {
		span.SetStatus(otelcodes.Error, "invalid order status provided")
		return nil, status.Errorf(grpcodes.InvalidArgument, "invalid order status: %s", newStatus)
	}

	// --- Database Interaction ---
	// First, get the order to ensure it exists
	_, err = s.store.GetOrder(ctx, orderID) // Check existence
	if err != nil {
		if err == sql.ErrNoRows {
			span.SetStatus(otelcodes.Error, "order not found")
			return nil, status.Errorf(grpcodes.NotFound, "order not found with ID %s", orderIDStr)
		}
		span.SetStatus(otelcodes.Error, "failed to retrieve order before update")
		log.Printf("failed to get order %s before update: %v", orderID, err) 
		return nil, status.Errorf(grpcodes.Internal, "failed to retrieve order: %v", err)
	}

	updateArg := db.UpdateOrderStatusParams{
		ID:     orderID,
		Status: pgtype.Text{String: newStatus, Valid: true},
	}

	// Perform the update. We don't rely on its return value for the full order details.
	_, err = s.store.UpdateOrderStatus(ctx, updateArg)
	if err != nil {
		// If UpdateOrderStatus itself returns sql.ErrNoRows, it means the ID was not found for update,
		// which would be an inconsistency if the GetOrder above succeeded.
		if err == sql.ErrNoRows {
		    span.SetStatus(otelcodes.Error, "order not found during update attempt")
		    return nil, status.Errorf(grpcodes.NotFound, "order not found with ID %s for update", orderIDStr)
		}
		span.SetStatus(otelcodes.Error, "failed to update order status")
		log.Printf("failed to update order status for %s: %v", orderID, err) 
		return nil, status.Errorf(grpcodes.Internal, "failed to update order status: %v", err)
	}

	// After successful update, fetch the complete and current state of the order
	finalOrderState, err := s.store.GetOrder(ctx, orderID)
	if err != nil {
		span.SetStatus(otelcodes.Error, "failed to retrieve order after update")
		log.Printf("failed to get order %s after update: %v", orderID, err)
		return nil, status.Errorf(grpcodes.Internal, "failed to retrieve order state after update: %v", err)
	}

	log.Printf("Order status updated successfully for ID: %s to %s", finalOrderState.ID.String(), finalOrderState.Status.String)

	// --- Response Assembly ---
	return &orderspb.UpdateOrderStatusResponse{
		Order: &orderspb.Order{
			OrderId:     finalOrderState.ID.String(),
			CustomerId:  finalOrderState.CustomerID,
			Amount:      finalOrderState.Amount,
			Description: finalOrderState.Description.String,
			Status:      finalOrderState.Status.String,
			CreatedAt:   timestamppb.New(finalOrderState.CreatedAt.Time),
			UpdatedAt:   timestamppb.New(finalOrderState.UpdatedAt.Time),
		},
	}, nil
}
