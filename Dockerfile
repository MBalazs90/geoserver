# Stage 1: Build from source
FROM docker.io/maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /build
COPY src/ src/
RUN cd src && mvn -B package -DskipTests \
    -Dmaven.repo.local=/build/.m2

# Stage 2: Deploy into Red Hat UBI + Tomcat
FROM registry.access.redhat.com/ubi9/openjdk-17-runtime:latest

USER root
RUN microdnf install -y unzip gzip tar && microdnf clean all

# Install Tomcat
ENV CATALINA_HOME=/opt/tomcat
RUN curl -sL https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.34/bin/apache-tomcat-10.1.34.tar.gz \
    | tar xz -C /opt && mv /opt/apache-tomcat-* $CATALINA_HOME && \
    rm -rf $CATALINA_HOME/webapps/*

# Deploy GeoServer WAR from builder stage
COPY --from=builder /build/src/web/app/target/geoserver*.war /tmp/geoserver.war
RUN mkdir -p $CATALINA_HOME/webapps/geoserver && \
    cd $CATALINA_HOME/webapps/geoserver && \
    unzip -q /tmp/geoserver.war && \
    rm /tmp/geoserver.war

# GeoServer data directory
RUN mkdir -p /opt/geoserver/data_dir

# OCP: writable for random UID
RUN chmod -R g=u $CATALINA_HOME /opt/geoserver

ENV GEOSERVER_DATA_DIR=/opt/geoserver/data_dir
EXPOSE 8080

USER 1001
CMD ["sh", "-c", "$CATALINA_HOME/bin/catalina.sh run"]
