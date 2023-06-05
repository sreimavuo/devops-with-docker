FROM golang:1.20.4-alpine3.18 as build-stage
WORKDIR /usr/src/app
COPY example-backend/. .
RUN go build

# The run stage
FROM alpine:3.18
WORKDIR /usr/src/app
ENV PORT=8081 REQUEST_ORIGIN=*
EXPOSE 8081
COPY --from=build-stage /usr/src/app/server /usr/src/app/server

RUN adduser --disabled-password --gecos "appuser" appuser && \
    chown appuser .
USER appuser
CMD ./server

