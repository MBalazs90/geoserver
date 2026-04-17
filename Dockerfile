# GeoServer on OCP
# Uses the official community image as base.
# The Tekton pipeline validates the source compiles (Maven),
# then builds this image with custom config + deploy via Helm.
FROM docker.io/kartoza/geoserver:2.28.2

LABEL maintainer="bm-infra.dev"
LABEL org.opencontainers.image.source="https://github.com/MBalazs90/geoserver"

# Make writable for OCP random UID
RUN chmod -R g=u /opt/geoserver /settings /scripts /usr/local/tomcat 2>/dev/null || true

ENV GEOSERVER_DATA_DIR=/opt/geoserver/data_dir

EXPOSE 8080
