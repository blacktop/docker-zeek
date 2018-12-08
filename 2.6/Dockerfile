FROM alpine:3.8 as builder

LABEL maintainer "https://github.com/blacktop"

ENV ZEEK_VERSION 2.6

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
  fts

COPY patches /tmp
RUN echo "===> Cloning zeek..." \
  && cd /tmp \
  && git clone --recursive --branch v$ZEEK_VERSION https://github.com/zeek/zeek.git \
  && echo "===> Applying patches..." \
  && cd /tmp/zeek \
  && git fetch origin pull/221/head:alpine \
  && git checkout alpine
# && patch -p1 < /tmp/bro-musl.patch \
# && cp /tmp/FindFTS.cmake cmake \
# && cd /tmp/zeek/aux/binpac \
# && patch -p1 < /tmp/binpac-musl.patch

RUN echo "===> Compiling zeek..." \
  && cd /tmp/zeek \
  && CC=clang ./configure --prefix=/usr/local/bro \
  --disable-broker-tests \
  --disable-broctl \
  --disable-auxtools \
  && make \
  && make install

# RUN echo "===> Compiling af_packet plugin..." \
#   && cd /tmp/zeek/aux/plugins \
#   && git clone https://github.com/J-Gras/bro-af_packet-plugin \
#   && cd /tmp/zeek/aux/plugins/bro-af_packet-plugin \
#   && make distclean \
#   && CC=clang ./configure --with-kernel=/usr \
#   && make \
#   && make install

RUN echo "===> Shrinking image..." \
  && strip -s /usr/local/bro/bin/bro

####################################################################################################
FROM alpine:latest

LABEL maintainer "https://github.com/blacktop"

RUN apk --no-cache add ca-certificates geoip openssl libpcap

COPY --from=builder /usr/local/bro /bro
COPY local.bro /usr/local/share/bro/site/local.bro

WORKDIR /pcap

ENV BROPATH .:/data/config:/usr/local/share/bro:/usr/local/share/bro/policy:/usr/local/share/bro/site
ENV PATH $PATH:/bro/bin

ENTRYPOINT ["bro"]
CMD ["-h"]
