# Build stage
FROM golang:1.23-alpine AS builder
WORKDIR /app
COPY services/order-processing-service/ .  
RUN go build -o main services/order-processing-service/cmd/main.go

# Run stage
FROM alpine:3.19
WORKDIR /app
COPY --from=builder /app/main .

CMD [ "/app/main" ]
