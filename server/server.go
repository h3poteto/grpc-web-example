package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"sync"

	pb "github.com/h3poteto/grpc-web-example/protocol"
	"github.com/improbable-eng/grpc-web/go/grpcweb"
	"golang.org/x/net/context"
	"google.golang.org/grpc"
)

type customerService struct {
	customers []*pb.Person
	m         sync.Mutex
}

func (cs *customerService) ListPerson(p *pb.RequestType, stream pb.CustomerService_ListPersonServer) error {
	cs.m.Lock()
	defer cs.m.Unlock()
	for _, p := range cs.customers {
		if err := stream.Send(p); err != nil {
			return err
		}
	}
	return nil

}

func (cs *customerService) AddPerson(c context.Context, p *pb.Person) (*pb.ResponseType, error) {
	cs.m.Lock()
	defer cs.m.Unlock()
	cs.customers = append(cs.customers, p)
	return new(pb.ResponseType), nil
}

func main() {
	port := os.Getenv("SERVER_PORT")

	grpcServer := grpc.NewServer()
	pb.RegisterCustomerServiceServer(grpcServer, new(customerService))

	wrappedServer := grpcweb.WrapServer(grpcServer)
	handler := func(resp http.ResponseWriter, req *http.Request) {
		wrappedServer.ServeHttp(resp, req)
	}

	httpServer := http.Server{
		Addr:    fmt.Sprintf(":%s", port),
		Handler: http.HandlerFunc(handler),
	}
	log.Printf("starting grpc server port: %s", port)

	if err := httpServer.ListenAndServe(); err != nil {
		log.Fatalf("failed to start http server:%v", err)
	}
}
