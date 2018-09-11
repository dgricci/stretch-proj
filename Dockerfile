## PROJ.4 - Cartographic Projections Library 
FROM dgricci/dev:1.0.0
MAINTAINER Didier Richard <didier.richard@ign.fr>
LABEL       version="1.0.0" \
            proj="v5.1.0" \
            os="Debian Stretch" \
            description="PROJ library and software with datum installed"

## arguments
ARG PROJ_VERSION
ENV PROJ_VERSION ${PROJ_VERSION:-5.1.0}
ARG PROJ_DOWNLOAD_URL
ENV PROJ_DOWNLOAD_URL ${PROJ_DOWNLOAD_URL:-http://download.osgeo.org/proj/proj-$PROJ_VERSION.tar.gz}
ARG PROJ_DATUM_VERSION
ENV PROJ_DATUM_VERSION ${PROJ_DATUM_VERSION:-1.7}
ARG PROJ_DATUM_DOWNLOAD_URL
ENV PROJ_DATUM_DOWNLOAD_URL ${PROJ_DATUM_DOWNLOAD_URL:-http://download.osgeo.org/proj/proj-datumgrid-$PROJ_DATUM_VERSION.tar.gz}

COPY build.sh /tmp/build.sh

RUN /tmp/build.sh && rm -f /tmp/build.sh

# Externally accessible data is by default put in /geodata
# use -v at run time !
WORKDIR /geodata

# Output capabilities by default.
CMD ["proj", "-l"]

