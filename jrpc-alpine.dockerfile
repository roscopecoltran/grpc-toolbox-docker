FROM alpine:3.6
MAINTAINER Rosco Pecoltran <https://github.com/roscopecoltran>

# notes: mainly focused on protobuf v3.x (features protoc generator, ...)
# build: docker build -t jrpc:alpine -f jrpc-alpine.dockerfile --no-cache .
# run: docker run --rm -ti -p 8083:8083 -v `pwd`:/app jrpc:alpine

# build-args
ARG GOPATH=${GOPATH:-"/go"}
ARG APK_INTERACTIVE=${APK_INTERACTIVE:-"bash nano tree"}
ARG APK_RUNTIME=${APK_RUNTIME:-"go git openssl ca-certificates protobuf protobuf-c"}
ARG APK_BUILD=${APK_BUILD:-"openssl-dev gcc g++ musl-dev protobuf-dev protobuf-c-dev"}
ARG GOSU_VERSION=${GOSU_VERSION:-"1.10"}

# env
ENV APP_BASENAME=${APP_BASENAME:-"jrpc"} \
    PATH="${GOPATH}/bin:/app:$PATH" \
    GOPATH=${GOPATH:-"/go"}

# Install Gosu to /usr/local/bin/gosu
ADD https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64 /usr/local/sbin/gosu

# NSSwitch configuration file
COPY shared/docker/nsswitch.conf /etc/nsswitch.conf

RUN \
	chmod +x /usr/local/sbin/gosu \
	&& adduser -D app -h /data -s /bin/sh \
	\
	# install APK dependencies: build, runtime and interactive pkgs
		\
	    	&& echo "http://dl-4.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
	    	&& apk upgrade \
	      	&& apk add --no-cache ${APK_RUNTIME} \
	      	&& apk add --no-cache --virtual=.interactive-dependencies ${APK_INTERACTIVE} \
	      	&& apk add --no-cache --virtual=.build-dependencies ${APK_BUILD} \
    \
	# install GO utils
		\
			&& go get -v -u github.com/Masterminds/glide \
			&& go get -v -u github.com/mitchellh/gox

#	# clean APK build dependencies 
#	    \
#			apk del --no-cache --virtual=.build-dependencies

COPY ./src/github.com/kpango /go/src/github.com/kpango
WORKDIR /go/src/github.com/kpango/jrpc

RUN gox -verbose -os="linux" -arch="amd64" -output="/app/${APP_BASENAME}-{{.Dir}}" $(glide novendor)

VOLUME ["/data"]

EXPOSE 8083

CMD ["${APP_BASENAME}-web"]
# CMD ["/usr/local/sbin/gosu", "app", "${APP_BASENAME}-web"]

# CMD ["web", ""]
# Snippets
# From CONTAINER:
#   - glide install --strip-vendor
#   - gox -verbose -os="linux" -arch="amd64" -output="/app/{{.Dir}}" $(glide novendor)

