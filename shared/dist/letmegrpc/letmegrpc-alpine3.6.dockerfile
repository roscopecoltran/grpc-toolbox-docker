FROM alpine:3.6
MAINTAINER Rosco Pecoltran <https://github.com/roscopecoltran>

EXPOSE 8080
COPY ./krakend-gin-linux /app/krakend

RUN apk --update --no-cache --no-progress add ca-certificates

ENV PATH=/app:$PATH
VOLUME ["/app", "/conf.d/krakend"]

ENTRYPOINT ["/app/krakend"]
CMD ["-d", "-c", "/conf.d/krakend/default.yaml"]
