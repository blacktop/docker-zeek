FROM alpine:3.8

LABEL maintainer "https://github.com/blacktop"

ENV ZEEK_VERSION 2.6

COPY patches /tmp
RUN apk add --no-cache zlib openssl libstdc++ libpcap geoip libgcc tini
RUN apk add --no-cache -t .build-deps \
  linux-headers \
  openssl-dev \
  libpcap-dev \
  python-dev \
  geoip-dev \
  zlib-dev \
  binutils \
  fts-dev \
  cmake \
  clang \
  bison \
  perl \
  make \
  flex \
  git \
  g++ \
  fts \
  && cd /tmp \
  && git clone --recursive --branch v$ZEEK_VERSION https://github.com/zeek/zeek.git \
  && echo "===> Applying patches..." \
  && cd /tmp/zeek \
  && patch -p1 < /tmp/bro-musl.patch \
  && cp /tmp/FindFTS.cmake cmake \
  && cd /tmp/zeek/aux/binpac \
  && patch -p1 < /tmp/binpac-musl.patch \
  && echo "===> Compiling zeek..." \
  && cd /tmp/zeek \
  && CC=clang ./configure --prefix=/usr/local \
  --disable-broker-tests \
  --disable-broctl \
  --disable-auxtools \
  && make \
  && make install \
  && echo "===> Compiling af_packet plugin..." \
  && cd /tmp/zeek/aux/plugins \
  && git clone https://github.com/J-Gras/bro-af_packet-plugin \
  && cd /tmp/zeek/aux/plugins/bro-af_packet-plugin \
  && make distclean \
  && CC=clang ./configure --with-kernel=/usr \
  && make \
  && make install \
  && echo "===> Shrinking image..." \
  && strip -s /usr/local/bin/zeek \
  && rm -rf /tmp/* \
  && apk del --purge .build-deps

ENV BROPATH .:/data/config:/usr/local/share/bro:/usr/local/share/bro/policy:/usr/local/share/bro/site

WORKDIR /pcap

COPY local.bro /usr/local/share/bro/site/local.bro

ENTRYPOINT ["/sbin/tini","--","bro"]
CMD ["-h"]
