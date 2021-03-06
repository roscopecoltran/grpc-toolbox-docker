FROM golang
MAINTAINER Rudolf Pliva rpliva@seznam.cz

# notes: mainly focused on protobuf v3.x (features protoc generator, ...)
# build: docker build -t letmegrpc:ubuntu14 -f letmegrpc-ubuntu.dockerfile --no-cache .
# run: docker run --rm -ti -p 3000:3000 -v `pwd`:/app letmegrpc:ubuntu14

# install protobuf
RUN apt-get update && apt-get install curl unzip -y 
RUN curl -OL https://github.com/google/protobuf/releases/download/v3.0.0/protoc-3.0.0-linux-x86_64.zip \
    && unzip protoc-3.0.0-linux-x86_64.zip -d protoc3 \
    && mv protoc3/bin/protoc /usr/bin/protoc

# install letmegrpc
RUN cd $GOPATH \
    && mkdir -p ./src/github.com/gogo/letmegrpc \
    && git clone https://github.com/gogo/letmegrpc ./src/github.com/gogo/letmegrpc \
    && git clone https://github.com/gogo/protobuf ./src/github.com/gogo/protobuf \
    && go get google.golang.org/grpc \
    && go get golang.org/x/net/context \
    && (cd ./src/github.com/gogo/letmegrpc && make install)

# install protoc-gen-gogo
RUN go get github.com/gogo/protobuf/protoc-gen-gofast \
    && go get github.com/gogo/protobuf/proto \
    && go get github.com/gogo/protobuf/jsonpb \
    && go get github.com/gogo/protobuf/protoc-gen-gogo \
    && go get github.com/gogo/protobuf/gogoproto

# copy proto files used in service
ADD shared/testdata/protos /data/letmegrpc/protos

# share folder with protos
VOLUME ["/data/letmegrpc/protos"]

ENV PROTO_FILE "test.proto"
ENV SERVICE_ADDRESS "localhost:12345"

EXPOSE 8080 3003

# ENTRYPOINT ["letmegrpc"]
CMD ["letmegrpc", "--addr=${SERVICE_ADDRESS}", "--httpaddr=0.0.0.0:8080", "--proto_path=/data/letmegrpc/protos", "/data/letmegrpc/protos/${PROTO_FILE}"]

# Snippets
# From CONTAINER:
#   - letmegrpc --addr=$SERVICE_ADDRESS --httpaddr=0.0.0.0:8080 --proto_path=/data/letmegrpc/protos /data/letmegrpc/protos/$PROTO_FILE
