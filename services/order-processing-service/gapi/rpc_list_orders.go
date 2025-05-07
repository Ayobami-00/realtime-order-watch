package gapi

import (
	"context"
	"log" // Replace with your structured logger

	db "github.com/Ayobami-00/realtime-order-watch/order-processing-service/db/sqlc"
	orderspb "github.com/Ayobami-00/realtime-order-watch/order-processing-service/pb"
	grpcodes "google.golang.org/grpc/codes" // Alias to avoid conflict
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/timestamppb"

	"go.opentelemetry.io/otel/attribute"
	otelcodes "go.opentelemetry.io/otel/codes" // Import otelcodes
	"go.opentelemetry.io/otel/trace"
)

func (s *Server) ListOrders(ctx context.Context, req *orderspb.ListOrdersRequest) (*orderspb.ListOrdersResponse, error) {
	// OpenTelemetry Tracing
	ctx, span := s.tracer.Start(ctx, "gapi.ListOrders", trace.WithAttributes(
		attribute.Int64("limit", int64(req.GetLimit())),
		attribute.Int64("offset", int64(req.GetOffset())),
	))
	defer span.End()

	// --- Input Validation/Defaults ---
	limit := req.GetLimit()
	if limit <= 0 {
		limit = 10 // Default limit
	}
	if limit > 100 { // Max limit
		limit = 100
	}
	span.SetAttributes(attribute.Int64("effective_limit", int64(limit)))

	offset := req.GetOffset()
	if offset < 0 {
		offset = 0 // Default offset
	}
	span.SetAttributes(attribute.Int64("effective_offset", int64(offset)))

	arg := db.ListOrdersParams{
		Limit:  limit,
		Offset: offset,
	}

	// --- Database Interaction ---
	dbOrders, err := s.store.ListOrders(ctx, arg)
	if err != nil {
		span.SetStatus(otelcodes.Error, "failed to list orders")
		log.Printf("Failed to list orders from DB: %v", err) // Replace with structured logging
		span.RecordError(err)
		return nil, status.Errorf(grpcodes.Internal, "failed to list orders: %v", err)
	}

	// TODO: Implement a CountOrders method in SQLC for accurate total_count for pagination
	// For now, total_count might not be accurate if there are more items than the current list.
	// A separate s.store.CountOrders(ctx, filterParams) would be ideal.
	// As a placeholder, we can use the number of items returned if it's less than the limit,
	// or leave total_count as 0 or -1 to indicate it's not fully implemented.
	var totalCount int32 = 0
	if len(dbOrders) < int(limit) { // Simplistic way to estimate if we are on the last page
		totalCount = int32(offset) + int32(len(dbOrders))
	} else {
		// This isn't accurate, ideally a COUNT(*) query is needed.
		// We can set it to a value indicating more data might exist or leave it.
		// For a better UX, a separate count query is best.
		// totalCount, err = s.store.CountAllOrders(ctx) // Fictional method
		// For this example, we'll just set it to a placeholder.
		// A more robust solution would be to execute an additional COUNT(*) query.
		// totalCount, err = s.store.CountAllOrders(ctx) // Fictional method
	}

	pbOrders := make([]*orderspb.Order, 0, len(dbOrders))
	for _, dbOrder := range dbOrders {
		pbOrders = append(pbOrders, &orderspb.Order{
			OrderId:     dbOrder.ID.String(),
			CustomerId:  dbOrder.CustomerID,
			Amount:      dbOrder.Amount,
			Description: dbOrder.Description.String,
			Status:      dbOrder.Status.String,
			CreatedAt:   timestamppb.New(dbOrder.CreatedAt.Time),
			UpdatedAt:   timestamppb.New(dbOrder.UpdatedAt.Time),
		})
	}

	log.Printf("Listed %d orders successfully", len(pbOrders))

	// --- Response ---
	return &orderspb.ListOrdersResponse{
		Orders:     pbOrders,
		TotalCount: totalCount, // Placeholder, see TODO above
	}, nil
}
