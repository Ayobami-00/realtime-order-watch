DB_URL=postgresql://root:auxano3454@localhost/order_processing_service?sslmode=disable

network:
	docker network create order_processing_service_network

postgres:
	docker run --name postgres --network order_processing_service_network -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=auxano3454 -d postgres:14-alpine

createdb:
	docker exec -it postgres createdb --username=root --owner=root order_processing_service

dropdb:
	docker exec -it postgres dropdb order_processing_service

migrateup:
	migrate -path db/migration -database "$(DB_URL)" -verbose up

migrateup1:
	migrate -path db/migration -database "$(DB_URL)" -verbose up 1

migratedown:
	migrate -path db/migration -database "$(DB_URL)" -verbose down

migratedown1:
	migrate -path db/migration -database "$(DB_URL)" -verbose down 1

new_migration:
	migrate create -ext sql -dir db/migration -seq $(name)

db_docs:
	dbdocs build doc/db.dbml

db_schema:
	dbml2sql --postgres -o doc/schema.sql doc/db.dbml

redis:
	docker run --name redis --network order_processing_service_network -p 6379:6379 -e REDIS_PASSWORD=auxano3454 -d redis:7-alpine redis-server --requirepass auxano3454

sqlc:
	sqlc generate

test:
	go test -v -cover -short ./...

server:
	go run main.go

mock:
	mockgen -package mockdb -destination db/mock/store.go github.com/FusionLabInc/assignme-v3-backend/db/sqlc Store 

proto:
	rm -f pb/*.pb.go
	protoc --proto_path=pb --go_out=pb --go_opt=paths=source_relative \
    --go-grpc_out=pb --go-grpc_opt=paths=source_relative \
    pb/*.proto

.PHONY: network postgres createdb dropdb migrateup migratedown migrateup1 migratedown1 new_migration db_docs db_schema sqlc test server mock proto
