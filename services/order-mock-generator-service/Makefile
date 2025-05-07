proto:
	# rm -f pkg/**/pb/*.pb.go
	protoc --proto_path=pkg --go_out=pkg --go_opt=paths=source_relative \
    --go-grpc_out=pkg --go-grpc_opt=paths=source_relative \
    pkg/**/pb/*.proto

.PHONY: proto