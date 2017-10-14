FROM alpine:3.6
MAINTAINER Rosco Pecoltran <https://github.com/roscopecoltran>

# notes: mainly focused on protobuf v3.x (features protoc generator, ...)
# build: docker build -t letmegrpc:alpine -f letmegrpc-alpine.dockerfile --no-cache .
# run: docker run --rm -ti -p 3000:3000 -v `pwd`:/app letmegrpc:alpine

# build-args
ARG GOPATH=${GOPATH:-"/go"}
ARG APK_INTERACTIVE=${APK_INTERACTIVE:-"bash nano tree"}
ARG APK_RUNTIME=${APK_RUNTIME:-"go git openssl ca-certificates protobuf protobuf-c"}
ARG APK_BUILD=${APK_BUILD:-"openssl-dev gcc g++ musl-dev protobuf-dev protobuf-c-dev make"}

# env
ENV APP_BASENAME=${APP_BASENAME:-"letmegrpc"} \
    PATH="${GOPATH}/bin:/app:$PATH" \
    GOPATH=${GOPATH:-"/go"}

RUN \
	# install APK dependencies: build, runtime and interactive pkgs
		\
	    	echo "http://dl-4.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
	    	&& apk upgrade \
	      	&& apk add --no-cache ${APK_RUNTIME} \
	      	&& apk add --no-cache --virtual=.interactive-dependencies ${APK_INTERACTIVE} \
	      	&& apk add --no-cache --virtual=.build-dependencies ${APK_BUILD} \
    \
	# install GO utils
		\
			&& go get -v -u github.com/Masterminds/glide \
			&& go get -v -u github.com/mitchellh/gox \
	\
	# install letmegrpc
		\
			&& cd $GOPATH \
		    && mkdir -p ./src/github.com/gogo/letmegrpc \
		    && git clone --recursive --depth=1 https://github.com/gogo/letmegrpc ./src/github.com/gogo/letmegrpc \
		    && git clone --recursive --depth=1 https://github.com/gogo/protobuf ./src/github.com/gogo/protobuf \
		    && go get -v google.golang.org/grpc \
		    && go get -v golang.org/x/net/context \
		    && (cd ./src/github.com/gogo/letmegrpc && make install) \
	\
	# install protoc-gen-gogo
		\
			&& go get -v github.com/gogo/protobuf/protoc-gen-gofast \
		    && go get -v github.com/gogo/protobuf/proto \
		    && go get -v github.com/gogo/protobuf/jsonpb \
		    && go get -v github.com/gogo/protobuf/protoc-gen-gogo \
		    && go get -v github.com/gogo/protobuf/gogoproto \
	\
	# clean APK build dependencies
	    \
			&& apk del --no-cache --virtual=.build-dependencies	\
	&& echo " --> Build process is finished"

# COPY ./src/github.com/gogo /go/src/github.com/gogo
# WORKDIR /go/src/github.com/gogo/letmegrpc
# RUN gox -verbose -os="linux" -arch="amd64" -output="/app/${APP_BASENAME}-{{.Dir}}" $(glide novendor)

# copy proto files used in service
ADD shared/testdata/protos /data/letmegrpc/protos

VOLUME ["/data"]
EXPOSE 8080 3003

# ENTRYPOINT ["letmegrpc"]
CMD ["letmegrpc", "--addr=$SERVICE_ADDRESS", "--httpaddr=0.0.0.0:8080", "--proto_path=/data/letmegrpc/protos", "/data/letmegrpc/protos/$PROTO_FILE"]
# letmegrpc --addr=$SERVICE_ADDRESS --httpaddr=0.0.0.0:8080 --proto_path=/data/letmegrpc/protos /data/letmegrpc/protos/$PROTO_FILE

# Snippets
# From CONTAINER:
#   - glide install --strip-vendor
#   - gox -verbose -os="linux" -arch="amd64" -output="/app/{{.Dir}}" $(glide novendor)
#   - letmegrpc --addr=$SERVICE_ADDRESS --httpaddr=0.0.0.0:8080 --proto_path=/data/letmegrpc/protos /data/letmegrpc/protos/$PROTO_FILE
