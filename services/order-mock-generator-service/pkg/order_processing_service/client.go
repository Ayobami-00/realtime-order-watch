package order_processing_service

import (
	"fmt"
	"log"

	"github.com/Ayobami-00/realtime-order-watch/order-mock-generator-service/bootstrap"
	pb "github.com/Ayobami-00/realtime-order-watch/order-mock-generator-service/pkg/order_processing_service/pb"
	"github.com/Ayobami-00/realtime-order-watch/order-mock-generator-service/utils"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

func InitOrderProcessingServiceClient(env *bootstrap.Env) pb.OrderServiceClient {

	var transportOption grpc.DialOption

	if env.AppEnv == "PRODUCTION" {

		tlsCredentials, err := utils.LoadTLSCredentials()
		if err != nil {
			log.Fatal("cannot load TLS credentials: ", err)
		}

		transportOption = grpc.WithTransportCredentials(tlsCredentials)

	} else {

		transportOption = grpc.WithTransportCredentials(insecure.NewCredentials())
	}

	cc, err := grpc.Dial(env.AuthServiceUrl, transportOption)

	if err != nil {
		fmt.Println("Could not connect:", err)
	}

	return pb.NewOrderServiceClient(cc)
}
