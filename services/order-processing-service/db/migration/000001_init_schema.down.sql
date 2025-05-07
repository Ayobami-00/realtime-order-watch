
-- Migration to revert the initial orders schema

-- Drop the trigger if it exists
DROP TRIGGER IF EXISTS set_timestamp ON orders;

-- Drop the function if it exists
DROP FUNCTION IF EXISTS trigger_set_timestamp();

-- Drop indexes (optional, as they are typically dropped with the table)
-- DROP INDEX IF EXISTS idx_orders_created_at;
-- DROP INDEX IF EXISTS idx_orders_status;
-- DROP INDEX IF EXISTS idx_orders_customer_id;

-- Drop the orders table
DROP TABLE IF EXISTS orders;