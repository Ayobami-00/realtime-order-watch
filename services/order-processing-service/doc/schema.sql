
-- Schema for the Order Processing Service

-- Drop table if it exists to ensure a clean state (optional, use with caution in dev)
DROP TABLE IF EXISTS orders;

CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY,
    customer_id TEXT NOT NULL,
    amount DOUBLE PRECISION NOT NULL,
    description TEXT,
    status TEXT, -- e.g., 'CREATED', 'PROCESSING', 'COMPLETED', 'FAILED_VALIDATION', 'FAILED_INTERNAL'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP -- Optional: to track updates
);

-- Optional: Add indexes for frequently queried columns
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);

-- A function to update 'updated_at' automatically on row update
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_timestamp
BEFORE UPDATE ON orders
FOR EACH ROW
EXECUTE PROCEDURE trigger_set_timestamp();