FROM node:16-alpine3.18 as build-stage
WORKDIR /usr/src/app
COPY example-frontend/. .

RUN npm install && \
    npm update && \
    npm run build

# The run stage
FROM node:16-alpine3.18
ENV REACT_APP_BACKEND_URL="http://localhost:8081"
EXPOSE 8080
WORKDIR /usr/src/app

COPY --from=build-stage /usr/src/app/build /usr/src/app/build

RUN npm install -g serve && \
    adduser --disabled-password --gecos "appuser" appuser && \
    chown appuser .

USER appuser
CMD ["serve", "-s", "-l", "8080", "build"]

