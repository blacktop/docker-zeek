FROM alpine:3.10 as builder

LABEL maintainer "https://github.com/blacktop"

ENV ZEEK_VERSION 3.0.11

RUN apk add --no-cache zlib openssl libstdc++ libpcap libgcc
RUN apk add --no-cache -t .build-deps \
  bsd-compat-headers \
  libmaxminddb-dev \
  linux-headers \
  openssl-dev \
  libpcap-dev \
  python-dev \
  zlib-dev \
  binutils \
  fts-dev \
  cmake \
  clang \
  bison \
  bash \
  swig \
  perl \
  make \
  flex \
  git \
  g++ \
  fts

RUN echo "===> Cloning zeek..." \
  && cd /tmp \
  && git clone --recursive --branch v$ZEEK_VERSION https://github.com/zeek/zeek.git

RUN echo "===> Compiling zeek..." \
  && cd /tmp/zeek \
  && CC=clang ./configure --prefix=/usr/local/zeek \
  --build-type=MinSizeRel \
  --disable-broker-tests \
  --disable-zeekctl \
  --disable-auxtools \
  --disable-python \
  && make -j 2 \
  && make install

RUN echo "===> Compiling af_packet plugin..." \
  && cd /tmp/zeek/aux/ \
  && git clone https://github.com/J-Gras/zeek-af_packet-plugin.git \
  && cd /tmp/zeek/aux/zeek-af_packet-plugin \
  && CC=clang ./configure --with-kernel=/usr --zeek-dist=/tmp/zeek \
  && make -j 2 \
  && make install \
  && /usr/local/zeek/bin/zeek -NN Zeek::AF_Packet

RUN echo "===> Installing hosom/file-extraction package..." \
  && cd /tmp \
  && git clone https://github.com/hosom/file-extraction.git \
  && find file-extraction -name "*.bro" -exec sh -c 'mv "$1" "${1%.bro}.zeek"' _ {} \; \
  && mv file-extraction/scripts /usr/local/zeek/share/zeek/site/file-extraction

RUN echo "===> Installing Community-Id..." \
  && cd /tmp \
  && git clone https://github.com/corelight/zeek-community-id.git \
  && cd /tmp/zeek-community-id \
  && CC=clang ./configure --zeek-dist=/tmp/zeek \
  && cd /tmp/zeek-community-id/build \
  && make -j 2 \
  && make install \
  && /usr/local/zeek/bin/zeek -NN Corelight::CommunityID

RUN echo "===> Shrinking image..." \
  && strip -s /usr/local/zeek/bin/zeek

RUN echo "===> Size of the Zeek install..." \
  && du -sh /usr/local/zeek
####################################################################################################
FROM alpine:3.10

LABEL maintainer "https://github.com/blacktop"

RUN apk --no-cache add ca-certificates zlib openssl libstdc++ libpcap libmaxminddb libgcc fts

COPY --from=builder /usr/local/zeek /usr/local/zeek
COPY local.zeek /usr/local/zeek/share/zeek/site/local.zeek

# Add a few zeek scripts
ADD https://raw.githubusercontent.com/blacktop/docker-zeek/master/scripts/conn-add-geodata.zeek \
  /usr/local/zeek/share/zeek/site/geodata/conn-add-geodata.zeek
ADD https://raw.githubusercontent.com/blacktop/docker-zeek/master/scripts/log-passwords.zeek \
  /usr/local/zeek/share/zeek/site/passwords/log-passwords.zeek

WORKDIR /pcap

ENV ZEEKPATH .:/data/config:/usr/local/zeek/share/zeek:/usr/local/zeek/share/zeek/policy:/usr/local/zeek/share/zeek/site
ENV PATH $PATH:/usr/local/zeek/bin

ENTRYPOINT ["zeek"]
CMD ["-h"]
