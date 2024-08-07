#!/bin/sh

set -x

# Add testing repository
echo "@testing https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
apk update

# Install dependencies
apk add --no-cache \
    curl geoip libgcc libstdc++ libffi libjpeg-turbo libtorrent-rasterbar@testing openssl python3 py3-pip py3-libtorrent-rasterbar@testing tzdata zlib p7zip
apk add --no-cache --virtual=build-dependencies \
    build-base cargo geoip-dev git libffi-dev libjpeg-turbo-dev openssl-dev python3-dev zlib-dev

# Build deluge
cd /tmp
#git clone git://deluge-torrent.org/deluge.git && cd deluge
#echo ${DELUGE_VERSION} > RELEASE-VERSION
git clone --branch deluge-${DELUGE_VERSION} --depth 1 git://deluge-torrent.org/deluge.git && cd deluge
pip3 install --no-cache-dir -U wheel setuptools pip --break-system-packages
pip3 install --no-cache-dir -U -r requirements.txt pygeoip --break-system-packages
python3 setup.py build
python3 setup.py install

# Build deluge-ltconfig
cd /tmp
git clone --branch 2.x --depth 1 https://github.com/ratanakvlun/deluge-ltconfig.git && cd deluge-ltconfig
python3 setup.py bdist_egg
mkdir -p /usr/share/deluge/plugins
cp dist/ltConfig-*.egg /usr/share/deluge/plugins

# Fix missing geoip legacy database
curl -s "https://dl.miyuru.lk/geoip/maxmind/country/maxmind4.dat.gz" | gunzip > /usr/share/GeoIP/GeoIP.dat
cat << EOF > /etc/periodic/monthly/geoip
#!/bin/sh
curl -s "https://dl.miyuru.lk/geoip/maxmind/country/maxmind4.dat.gz" | gunzip > /usr/share/GeoIP/GeoIP.dat
EOF

# Cleanup
apk del --purge build-dependencies
rm -rf /tmp/* /var/cache/apk/* /root/.cache /root/.cargo
rm -- "$0"
