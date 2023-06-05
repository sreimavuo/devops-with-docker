FROM openjdk:8-alpine3.9 as build-env
WORKDIR /usr/src/app
COPY spring-example-project/. .
RUN ./mvnw package

FROM openjdk:8-alpine3.9
WORKDIR /usr/src/app
EXPOSE 8080
COPY --from=build-env /usr/src/app/target /usr/src/app/target

RUN adduser --disabled-password --gecos "appuser" appuser && \
    chown appuser .

USER appuser
CMD ["java", "-jar", "./target/docker-example-1.1.3.jar"]

