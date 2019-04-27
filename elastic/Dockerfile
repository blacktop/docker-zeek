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

RUN echo "===> Installing hosom/file-extraction package..." \
  && cd /tmp \
  && git clone https://github.com/hosom/file-extraction.git \
  && find file-extraction -name "*.bro" -exec sh -c 'mv "$1" "${1%.bro}.zeek"' _ {} \; \
  && mv file-extraction/scripts /usr/local/bro/share/bro/site/file-extraction

RUN echo "===> Installing corelight/json-streaming-logs package..." \
  && cd /tmp \
  && git clone https://github.com/corelight/json-streaming-logs.git json-streaming-logs \
  && find json-streaming-logs -name "*.bro" -exec sh -c 'mv "$1" "${1%.bro}.zeek"' _ {} \; \
  && mv json-streaming-logs/scripts /usr/local/bro/share/bro/site/json-streaming-logs

# RUN echo "===> Installing corelight/bro-maxminddb package..." \
#   && cd /tmp/zeek/aux/ \
#   && git clone https://github.com/corelight/bro-maxminddb.git \
#   && apk add --no-cache libmaxminddb-dev \
#   && cd /tmp/zeek/aux/bro-maxminddb \
#   && find . -name "*.bro" -exec sh -c 'mv "$1" "${1%.bro}.zeek"' _ {} \; \
#   && CC=clang ./configure --bro-dist=/tmp/zeek \
#   && make -j `nproc` \
#   && make install

RUN echo "===> Shrinking image..." \
  && strip -s /usr/local/bro/bin/bro
####################################################################################################
FROM alpine:3.8 as filebeat

ENV BEAT_VERSION 7.0.0

RUN \
  cd /tmp \
  && wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${BEAT_VERSION}-linux-x86_64.tar.gz \
  && tar xzvf filebeat-${BEAT_VERSION}-linux-x86_64.tar.gz \
  && mv filebeat-${BEAT_VERSION}-linux-x86_64 /usr/share/filebeat \
  && mkdir /usr/share/filebeat/logs /usr/share/filebeat/data

COPY config /usr/share/filebeat
####################################################################################################
FROM alpine:3.8 as geoip

ENV MAXMIND_CITY https://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz
ENV MAXMIND_CNTRY https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz
ENV GITHUB_CITY https://github.com/blacktop/docker-zeek/raw/master/maxmind/GeoLite2-City.tar.gz
ENV GITHUB_CNTRY https://github.com/blacktop/docker-zeek/raw/master/maxmind/GeoLite2-Country.tar.gz
# Install the GeoIPLite Database
RUN cd /tmp \
  && mkdir -p /usr/share/GeoIP/ \
  && wget ${GITHUB_CITY} \
  && tar xzvf GeoLite2-City.tar.gz \
  && mv GeoLite2-City*/GeoLite2-City.mmdb /usr/share/GeoIP/ \
  && wget ${GITHUB_CNTRY} \
  && tar xzvf GeoLite2-Country.tar.gz \
  && mv GeoLite2-Country*/GeoLite2-Country.mmdb /usr/share/GeoIP/
####################################################################################################
FROM alpine:3.8

LABEL maintainer "https://github.com/blacktop"

RUN apk --no-cache add ca-certificates zlib openssl libstdc++ libpcap geoip libgcc fts libc6-compat libmaxminddb

COPY --from=builder /usr/local/bro /usr/local/bro
COPY local.bro /usr/local/bro/share/bro/site/local.zeek

WORKDIR /pcap

ENV BROPATH .:/data/config:/usr/local/bro/share/bro:/usr/local/bro/share/bro/policy:/usr/local/bro/share/bro/site
ENV PATH $PATH:/usr/local/bro/bin

COPY --from=filebeat /usr/share/filebeat /usr/share/filebeat
ENV PATH $PATH:/usr/share/filebeat

COPY --from=geoip /usr/share/GeoIP /usr/share/GeoIP

COPY entrypoint.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint

ENTRYPOINT ["entrypoint"]
CMD ["-h"]