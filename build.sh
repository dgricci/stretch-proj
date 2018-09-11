#!/bin/bash

# Exit on any non-zero status.
trap 'exit' ERR
set -E

echo "Compiling PROJ-${PROJ_VERSION}..."
01-install.sh
#install proj and compile it over to prevent packages depending on to install it !
apt-get -qy --no-install-recommends install \
    libproj12 \
    libproj-dev \
    proj-bin \
    proj-data

NPROC=$(nproc)
cd /tmp
wget --no-verbose "$PROJ_DOWNLOAD_URL"
wget --no-verbose "$PROJ_DOWNLOAD_URL.md5"
md5sum --strict -c proj-$PROJ_VERSION.tar.gz.md5
wget --no-verbose "$PROJ_DATUM_DOWNLOAD_URL"
tar xzf proj-$PROJ_VERSION.tar.gz
rm -f proj-$PROJ_VERSION.tar.gz*
mkdir -p proj-$PROJ_VERSION/nad
tar xzf proj-datumgrid-$PROJ_DATUM_VERSION.tar.gz -C proj-$PROJ_VERSION/nad
rm -f proj-datumgrid-$PROJ_DATUM_VERSION.tar.gz
{ \
    cd proj-$PROJ_VERSION ; \
    ./configure --prefix=/usr && \
    make -j$NPROC  > ../../make.log 2>&1 && \
    make install ; \
    ldconfig ; \
    cd .. ; \
    rm -fr proj-$PROJ_VERSION ; \
}
# install libproj at the same place as libproj12 does :
mv /usr/lib/libproj.a /usr/lib/x86_64-linux-gnu/
mv /usr/lib/libproj.la /usr/lib/x86_64-linux-gnu/
mv /usr/lib/libproj.so.13.1.0 /usr/lib/x86_64-linux-gnu/
mv /usr/lib/libproj.so /usr/lib/x86_64-linux-gnu/
mv /usr/lib/libproj.so.13 /usr/lib/x86_64-linux-gnu/

# uninstall and clean
01-uninstall.sh y
# prevent libproj12, libproj-dev, proj-bin and proj-data to overwrite just compiled proj !
apt-mark hold libproj12 libproj-dev proj-bin proj-data

exit 0

