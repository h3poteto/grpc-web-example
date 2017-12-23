.PHONY: dep grpc-protobuf

all: go-lib node-lib
go-lib: dep grpc-protobuf
	protoc -I. --proto_path=$(GOPATH)/src --proto_path=$(GOPATH)/src/github.com/gogo/protobuf/protobuf --proto_path=. --go_out=plugins=grpc:./ protocol/*.proto
dep: Gopkg.toml
	dep ensure
grpc-protobuf:
	go get -u github.com/gogo/protobuf/proto
	go get -u github.com/gogo/protobuf/protoc-gen-gogo
	go get -u github.com/gogo/protobuf/gogoproto
node-lib: npm
	protoc --plugin=protoc-gen-js_service=./node_modules/.bin/protoc-gen-js_service --js_out=import_style=commonjs,binary:. --js_service_out=. protocol/*.proto
	npm run build
npm: package.json
	npm install
clean:
	rm -rf node_modules
	rm -rf client/ruby/vendor/bundle
	rm -rf vendor
	rm protocol/*.go
	rm protocol/*.js
	rm client/ruby/lib/*.rb
