FROM docker:latest
WORKDIR /usr/src/app
COPY ./builder.sh .
RUN apk add git

ENTRYPOINT ["./builder.sh"]

