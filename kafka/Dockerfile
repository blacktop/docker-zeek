FROM alpine:3.8 as builder

LABEL maintainer "https://github.com/blacktop"

ENV ZEEK_VERSION 2.6.1

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

RUN echo "===> Cloning zeek..." \
  && cd /tmp \
  && git clone --recursive https://github.com/zeek/zeek.git
# && git clone --branch v$ZEEK_VERSION https://github.com/zeek/zeek.git

RUN echo "===> Compiling zeek..." \
  && cd /tmp/zeek \
  && CC=clang ./configure --prefix=/usr/local/bro \
  --disable-broker-tests \
  --disable-broctl \
  --disable-auxtools \
  && make -j `nproc` \
  && make install

RUN echo "===> Installing apache/metron-bro-plugin-kafka package..." \
  && cd /tmp/zeek/aux/ \
  && git clone https://github.com/apache/metron-bro-plugin-kafka.git \
  && apk add --no-cache librdkafka-dev \
  && cd /tmp/zeek/aux/metron-bro-plugin-kafka \
  && find . -name "*.bro" -exec sh -c 'mv "$1" "${1%.bro}.zeek"' _ {} \; \
  && CC=clang ./configure --bro-dist=/tmp/zeek \
  && make \
  && make install \
  && bro -N Apache::Kafka

RUN echo "===> Shrinking image..." \
  && strip -s /usr/local/bro/bin/bro

####################################################################################################
FROM alpine:3.8

LABEL maintainer "https://github.com/blacktop"

RUN apk --no-cache add ca-certificates zlib openssl libstdc++ libpcap geoip libgcc fts librdkafka

COPY --from=builder /usr/local/bro /usr/local/bro
COPY local.bro /usr/local/share/bro/site/local.bro

WORKDIR /pcap

ENV BROPATH .:/data/config:/usr/local/bro/share/bro:/usr/local/bro/share/bro/policy:/usr/local/bro/share/bro/site
ENV PATH $PATH:/usr/local/bro/bin

ENTRYPOINT ["bro"]
CMD ["-h"]
