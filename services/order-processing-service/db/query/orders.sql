-- name: CreateOrder :one
INSERT INTO orders (
  id,
  customer_id,
  amount,
  description,
  status
  -- created_at and updated_at have defaults
) VALUES (
  $1, $2, $3, $4, $5
) RETURNING *;

-- name: GetOrder :one
SELECT * FROM orders
WHERE id = $1 LIMIT 1;

-- name: ListOrders :many
SELECT * FROM orders
ORDER BY created_at DESC
LIMIT $1
OFFSET $2;

-- name: UpdateOrderStatus :one
UPDATE orders
SET status = $2, updated_at = NOW()
WHERE id = $1
RETURNING *;

-- Example for a more complex update if needed, e.g., updating multiple fields
-- name: UpdateOrderDetails :one
UPDATE orders
SET
  amount = COALESCE(sqlc.narg(amount), amount),
  description = COALESCE(sqlc.narg(description), description),
  status = COALESCE(sqlc.narg(status), status),
  updated_at = NOW()
WHERE id = sqlc.arg(id)
RETURNING *;

-- name: DeleteOrder :exec
DELETE FROM orders
WHERE id = $1;
