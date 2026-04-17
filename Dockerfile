# GeoServer built from source — deployed into Tomcat
FROM docker.io/tomcat:10.1-jre17

# Pre-explode WAR so Tomcat doesn't need write access at runtime
RUN apt-get update -qq && apt-get install -y -qq unzip > /dev/null && rm -rf /var/lib/apt/lists/*
COPY geoserver.war /tmp/geoserver.war
RUN mkdir -p /usr/local/tomcat/webapps/geoserver && \
    cd /usr/local/tomcat/webapps/geoserver && \
    unzip -q /tmp/geoserver.war && \
    rm /tmp/geoserver.war

# Make everything readable + writable by any UID (OCP runs as random UID)
RUN chmod -R g=u /usr/local/tomcat && \
    mkdir -p /opt/geoserver/data_dir && \
    chmod -R 777 /opt/geoserver

ENV GEOSERVER_DATA_DIR=/opt/geoserver/data_dir

EXPOSE 8080

CMD ["catalina.sh", "run"]
