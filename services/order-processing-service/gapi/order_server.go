package gapi

import (
	"context"
	"database/sql" // Required for handling sql.NullString etc. if not handled by SQLC directly

	"github.com/Ayobami-00/realtime-order-watch/services/order-processing-service/db/sqlc"
	"github.com/Ayobami-00/realtime-order-watch/services/order-processing-service/pb"
	"github.com/Ayobami-00/realtime-order-watch/services/order-processing-service/repository"
	"github.com/google/uuid"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	// "google.golang.org/protobuf/types/known/emptypb" // If using for DeleteOrder
)

// OrderServer is the server for order gRPC services.
// It embeds UnimplementedOrderServiceServer for forward compatibility.
type OrderServer struct {
	pb.UnimplementedOrderServiceServer
	repo repository.OrderRepository
	// Add env or config if needed for specific logic within handlers
}

// NewOrderServer creates a new OrderServer.
// Note: This function might be integrated into the existing gapi/server.go's NewServer
// or kept separate if you prefer distinct server instances for different services.
// For now, let's assume it's part of a larger Server struct in gapi/server.go that will hold this repo.
func NewGRPCOrderServer(repo repository.OrderRepository) *OrderServer {
	return &OrderServer{repo: repo}
}

// CreateOrder handles the CreateOrder gRPC request.
func (s *OrderServer) CreateOrder(ctx context.Context, req *pb.CreateOrderRequest) (*pb.CreateOrderResponse, error) {
	// Basic input validation
	if req.GetCustomerId() == "" || req.GetAmount() <= 0 {
		return nil, status.Errorf(codes.InvalidArgument, "invalid order details: customer_id and amount are required")
	}

	orderID, err := uuid.NewRandom()
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to generate order ID: %s", err)
	}

	// Simulate order status logic (can be more complex)
	initialStatus := "PENDING" // Or "CREATED", "RECEIVED"

	arg := db.CreateOrderParams{
		ID:          orderID,
		CustomerID:  req.GetCustomerId(),
		Amount:      req.GetAmount(),
		Description: sql.NullString{String: req.GetDescription(), Valid: req.GetDescription() != ""},
		Status:      sql.NullString{String: initialStatus, Valid: true},
	}

	// TODO: Add OpenTelemetry tracing span here for the CreateOrder gRPC call
	// tracer := otel.Tracer("gapi")
	// gapiCtx, span := tracer.Start(ctx, "gapi.CreateOrder")
	// defer span.End()
	// span.SetAttributes(attribute.String("customer_id", req.GetCustomerId()))

	dbOrder, err := s.repo.CreateOrder(ctx, arg)
	if err != nil {
		// span.RecordError(err)
		// span.SetStatus(otelcodes.Error, "failed to create order in DB")
		// logger.GetLogger().Error("Failed to create order", zap.Error(err), zap.String("customer_id", req.GetCustomerId()))
		return nil, status.Errorf(codes.Internal, "failed to create order: %s", err)
	}

	// span.SetAttributes(attribute.String("order_id", dbOrder.ID.String()))
	// logger.GetLogger().Info("Order created successfully", zap.String("order_id", dbOrder.ID.String()))

	return &pb.CreateOrderResponse{Order: repository.ConvertDBOrderToPBOrder(dbOrder)}, nil
}

// GetOrder handles the GetOrder gRPC request.
func (s *OrderServer) GetOrder(ctx context.Context, req *pb.GetOrderRequest) (*pb.GetOrderResponse, error) {
	if req.GetOrderId() == "" {
		return nil, status.Errorf(codes.InvalidArgument, "order_id is required")
	}

	orderID, err := uuid.Parse(req.GetOrderId())
	if err != nil {
		return nil, status.Errorf(codes.InvalidArgument, "invalid order_id format: %s", err)
	}

	// TODO: Add OpenTelemetry tracing span
	dbOrder, err := s.repo.GetOrder(ctx, orderID)
	if err != nil {
		if err == sql.ErrNoRows { // Or pgx.ErrNoRows, check SQLC generated error type
			return nil, status.Errorf(codes.NotFound, "order not found with ID %s", req.GetOrderId())
		}
		return nil, status.Errorf(codes.Internal, "failed to get order: %s", err)
	}

	return &pb.GetOrderResponse{Order: repository.ConvertDBOrderToPBOrder(dbOrder)}, nil
}

// ListOrders handles the ListOrders gRPC request.
func (s *OrderServer) ListOrders(ctx context.Context, req *pb.ListOrdersRequest) (*pb.ListOrdersResponse, error) {
	// Validate limit and offset (e.g., ensure limit is not too high)
	limit := req.GetLimit()
	if limit <= 0 {
		limit = 10 // Default limit
	}
	if limit > 100 { // Max limit
		limit = 100
	}
	offset := req.GetOffset()
	if offset < 0 {
		offset = 0 // Default offset
	}

	arg := db.ListOrdersParams{
		Limit:  limit,
		Offset: offset,
	}
	// TODO: Add OpenTelemetry tracing span

	dbOrders, err := s.repo.ListOrders(ctx, arg)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to list orders: %s", err)
	}

	pbOrders := repository.ConvertDBOrdersToPBOrders(dbOrders)

	// For total_count, you might need a separate SQLC query like `CountOrders`
	// For simplicity, we are not implementing total_count accurately here.
	// In a real app, you'd call something like `total, _ := s.repo.CountOrders(ctx, filterParams)`
	totalCount := int32(len(pbOrders)) // Placeholder, this is not the total in DB

	return &pb.ListOrdersResponse{Orders: pbOrders, TotalCount: totalCount}, nil
}

// UpdateOrderStatus handles the UpdateOrderStatus gRPC request.
func (s *OrderServer) UpdateOrderStatus(ctx context.Context, req *pb.UpdateOrderStatusRequest) (*pb.UpdateOrderStatusResponse, error) {
	if req.GetOrderId() == "" || req.GetStatus() == "" {
		return nil, status.Errorf(codes.InvalidArgument, "order_id and status are required")
	}

	orderID, err := uuid.Parse(req.GetOrderId())
	if err != nil {
		return nil, status.Errorf(codes.InvalidArgument, "invalid order_id format: %s", err)
	}

	// You might want to validate the status string against a list of allowed statuses
	// e.g., "PROCESSING", "SHIPPED", "DELIVERED", "CANCELLED", "FAILED"

	arg := db.UpdateOrderStatusParams{
		ID:     orderID,
		Status: sql.NullString{String: req.GetStatus(), Valid: true},
	}

	// TODO: Add OpenTelemetry tracing span

	dbOrder, err := s.repo.UpdateOrderStatus(ctx, arg)
	if err != nil {
		if err == sql.ErrNoRows { // Or pgx.ErrNoRows
			return nil, status.Errorf(codes.NotFound, "order not found with ID %s for update", req.GetOrderId())
		}
		return nil, status.Errorf(codes.Internal, "failed to update order status: %s", err)
	}

	return &pb.UpdateOrderStatusResponse{Order: repository.ConvertDBOrderToPBOrder(dbOrder)}, nil
}

// Implement DeleteOrder if defined in proto and repository
// func (s *OrderServer) DeleteOrder(ctx context.Context, req *pb.DeleteOrderRequest) (*pb.DeleteOrderResponse, error) {
//     // ...
//     return &pb.DeleteOrderResponse{}, nil // or &emptypb.Empty{}
// }
