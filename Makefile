.PHONY: dep grpc-protobuf

all: go-lib
go-lib: dep grpc-protobuf
	protoc -I. --proto_path=$(GOPATH)/src --proto_path=$(GOPATH)/src/github.com/gogo/protobuf/protobuf --proto_path=. --go_out=plugins=grpc:./ protocol/*.proto
dep: Gopkg.toml
	dep ensure
grpc-protobuf:
	go get -u github.com/gogo/protobuf/proto
	go get -u github.com/gogo/protobuf/protoc-gen-gogo
	go get -u github.com/gogo/protobuf/gogoproto
clean:
	rm -rf vendor
	rm protocol/*.go
