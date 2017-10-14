FROM mhart/alpine-node
MAINTAINER Rosco Pecoltran <https://github.com/roscopecoltran>

# notes: mainly focused on react/nodejs/ jsonschema
# build: docker build -t react-jsonschema-form-alpine:alpine -f react-jsonschema-form-alpine-alpine.dockerfile --no-cache .
# run: docker run --rm -ti -p 3000:3000 -v `pwd`:/app react-jsonschema-form-alpine:alpine

# build-args
ARG APK_INTERACTIVE=${APK_INTERACTIVE:-"bash nano tree"}
ARG APK_RUNTIME=${APK_RUNTIME:-"git openssl ca-certificates protobuf protobuf-c"}
ARG APK_BUILD=${APK_BUILD:-"openssl-dev gcc g++ musl-dev protobuf-dev protobuf-c-dev"}
ARG GOSU_VERSION=${GOSU_VERSION:-"1.10"}

# env
ENV APP_BASENAME=${APP_BASENAME:-"react-jsonschema-form"} \
	RJSF_DEV_SERVER=${RJSF_DEV_SERVER:-"localhost:3008"}

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
	      	&& apk add --no-cache --virtual=.build-dependencies ${APK_BUILD}

#	# clean APK build dependencies 
#	    \
#			apk del --no-cache --virtual=.build-dependencies

COPY ./src/github.com/mozilla-services/react-jsonschema-form /nodejs/src/github.com/mozilla-services/react-jsonschema-form
WORKDIR /nodejs/src/github.com/mozilla-services/react-jsonschema-form

COPY ./shared/docker/scripts/build-rjsf.sh /scripts/build-rjsf.sh

RUN chmod a+x /scripts/build-rjsf.sh \
	&& /scripts/build-rjsf.sh build-all

VOLUME ["/data"]

EXPOSE 3008

# CMD ["/bin/bash"]
CMD ["/scripts/build-rjsf.sh", "build-all-bash"]
