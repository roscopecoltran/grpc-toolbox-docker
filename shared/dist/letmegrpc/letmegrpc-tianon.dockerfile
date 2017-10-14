FROM tianon/true
MAINTAINER Rosco Pecoltran <https://github.com/roscopecoltran>

EXPOSE 8080
COPY ./krakend-gin-linux /app/krakend

ENV PATH=/app:$PATH
VOLUME ["/app", "/conf.d/krakend"]

ENTRYPOINT ["/app/krakend"]
CMD ["-d", "-c", "/conf.d/krakend/default.yaml"]
