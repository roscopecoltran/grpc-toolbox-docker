FROM alpine:3.6
MAINTAINER Rosco Pecoltran <https://github.com/roscopecoltran>

# build: docker build -t scraper:alpine -f scraper-alpine.dockerfile --no-cache .
# run: docker run --rm -ti -p 3000:3000 -v `pwd`:/app scraper:alpine

# build-args
ARG GOPATH=${GOPATH:-"/go"}
ARG APK_INTERACTIVE=${APK_INTERACTIVE:-"bash nano tree"}
ARG APK_RUNTIME=${APK_RUNTIME:-"go git openssl ca-certificates protobuf protobuf-c"}
ARG APK_BUILD=${APK_BUILD:-"openssl-dev protobuf-dev protobuf-c-dev"}

# env
ENV APP_BASENAME=${APP_BASENAME:-"letmegrpc"} \
    PATH="${GOPATH}/bin:/app:$PATH" \
    GOPATH=${GOPATH:-"/go"}

RUN \
    	echo "http://dl-4.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    	apk upgrade && \
      	apk add --no-cache ${APK_RUNTIME} && \
      	apk add --no-cache --virtual=.interactive-dependencies ${APK_INTERACTIVE} && \
      	apk add --no-cache --virtual=.build-dependencies ${APK_BUILD} \
    \
	# install GO utils
		\
			&& go get -v -u github.com/Masterminds/glide \
			&& go get -v -u github.com/mitchellh/gox \
	# install letmegrpc
		\
			&& cd $GOPATH \
		    && mkdir -p ./src/github.com/gogo/letmegrpc \
		    && git clone https://github.com/gogo/letmegrpc ./src/github.com/gogo/letmegrpc \
		    && git clone https://github.com/gogo/protobuf ./src/github.com/gogo/protobuf \
		    && go get google.golang.org/grpc \
		    && go get golang.org/x/net/context \
		    && (cd ./src/github.com/gogo/letmegrpc && make install) \
	# install protoc-gen-gogo 
		\
			&& go get github.com/gogo/protobuf/protoc-gen-gofast \
		    && go get github.com/gogo/protobuf/proto \
		    && go get github.com/gogo/protobuf/jsonpb \
		    && go get github.com/gogo/protobuf/protoc-gen-gogo \
		    && go get github.com/gogo/protobuf/gogoproto
	# clean APK build dependencies 
	    \
			apk del --no-cache --virtual=.build-dependencies

VOLUME ["/data"]

EXPOSE 8080 3003

CMD ["letmegrpc", "--addr=$SERVICE_ADDRESS", "--httpaddr=0.0.0.0:8080", "--proto_path=/data/letmegrpc/protos", "/var/letmegrpc/protos/$PROTO_FILE"]

# Snippets
# From CONTAINER:
#   - glide install --strip-vendor
#   - gox -verbose -os="linux" -arch="amd64" -output="/app/{{.Dir}}" $(glide novendor)

