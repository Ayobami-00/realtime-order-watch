# Build stage
FROM golang:1.23-alpine AS builder
WORKDIR /app
COPY services/order-mock-generator-service/ . 
RUN go build -o main cmd/main.go

# Run stage
FROM alpine:3.19
WORKDIR /app
COPY --from=builder /app/main .
COPY .env .
COPY db/migration ./db/migration

CMD [ "/app/main" ]
