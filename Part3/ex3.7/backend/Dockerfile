FROM golang:1.20.4-alpine3.18
ENV PORT=8081 REQUEST_ORIGIN=*
EXPOSE 8081
WORKDIR /usr/src/app
COPY example-backend/. .

RUN go build && \
    adduser --disabled-password --gecos "appuser" appuser && \
    chown appuser .

USER appuser
CMD ./server

