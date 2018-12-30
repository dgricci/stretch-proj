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
tar xzf proj-$PROJ_VERSION.tar.gz
rm -f proj-$PROJ_VERSION.tar.gz*
mkdir -p proj-$PROJ_VERSION/nad
wget --no-verbose "$PROJ_DATUM_DOWNLOAD_URL"
tar xzf proj-datumgrid-1.8.tar.gz -C proj-$PROJ_VERSION/nad
rm -f proj-datumgrid-1.8.tar.gz
wget --no-verbose "$PROJ_EUROPE_DATUM_DOWNLOAD_URL"
tar xzf proj-datumgrid-europe-1.1.tar.gz -C proj-$PROJ_VERSION/nad
rm -f proj-datumgrid-europe-1.1.tar.gz
wget --no-verbose "$PROJ_NORTHAMERICA_DATUM_DOWNLOAD_URL"
tar xzf proj-datumgrid-north-america-1.1.tar.gz -C proj-$PROJ_VERSION/nad
rm -f proj-datumgrid-north-america-1.1.tar.gz
{ \
    cd proj-$PROJ_VERSION ; \
    ./configure --prefix=${PROJ_HOME} && \
    make -j$NPROC && \
    make install ; \
    cd .. ; \
    rm -fr proj-$PROJ_VERSION ; \
}
# install libproj at the same place as libproj12 does :
case "${PROJ_HOME}" in
"/usr")
    mv ${PROJ_HOME}/lib/libproj.a /usr/lib/x86_64-linux-gnu/
    mv ${PROJ_HOME}/lib/libproj.la /usr/lib/x86_64-linux-gnu/
    mv ${PROJ_HOME}/lib/libproj.so.13.1.1 /usr/lib/x86_64-linux-gnu/
    mv ${PROJ_HOME}/lib/libproj.so /usr/lib/x86_64-linux-gnu/
    mv ${PROJ_HOME}/lib/libproj.so.13 /usr/lib/x86_64-linux-gnu/
    ;;
*)
    cp ${PROJ_HOME}/bin/ * /usr/bin/
    cp ${PROJ_HOME}/lib/libproj.a /usr/lib/x86_64-linux-gnu/
    cp ${PROJ_HOME}/lib/libproj.la /usr/lib/x86_64-linux-gnu/
    cp ${PROJ_HOME}/lib/libproj.so.13.1.1 /usr/lib/x86_64-linux-gnu/
    cp ${PROJ_HOME}/lib/libproj.so /usr/lib/x86_64-linux-gnu/
    cp ${PROJ_HOME}/lib/libproj.so.13 /usr/lib/x86_64-linux-gnu/
    cp ${PROJ_HOME}/include/* /usr/include/
    cp -a ${PROJ_HOME}/share/proj /usr/share/
    ;;
esac
sed -i -e "s:^\(libdir=\).*:\1'/usr/lib/x86_64-linux-gnu':" /usr/lib/x86_64-linux-gnu/libproj.la
ldconfig

# uninstall and clean
01-uninstall.sh y
# prevent libproj12, libproj-dev, proj-bin and proj-data to overwrite just compiled proj !
apt-mark hold libproj12 libproj-dev proj-bin proj-data

exit 0

