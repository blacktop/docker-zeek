<p align="center">
  <a href="https://github.com/blacktop/docker-zeek"><img alt="Zeek Logo" src="https://raw.githubusercontent.com/blacktop/docker-zeek/master/docs/logo.png" height="140" /></a>
  <a href="https://github.com/blacktop/docker-zeek"><h3 align="center">docker-zeek</h3></a>
  <p align="center"><a href="https://github.com/zeek/zeek">Zeek</a> Network Security Monitor Dockerfile</p>
    <p align="center">
    <a href="https://github.com/blacktop/docker-zeek/actions/workflows/docker-image.yml" alt="Publish Docker Image">
          <img src="https://github.com/blacktop/docker-zeek/actions/workflows/docker-image.yml/badge.svg" /></a>
    <a href="http://doge.mit-license.org" alt="License">
          <img src="http://img.shields.io/:license-mit-blue.svg" /></a>
    <a href="https://hub.docker.com/r/blacktop/zeek/" alt="Docker Stars">
          <img src="https://img.shields.io/docker/stars/blacktop/zeek.svg" /></a>
    <a href="https://hub.docker.com/r/blacktop/zeek/" alt="Docker Pulls">
          <img src="https://img.shields.io/docker/pulls/blacktop/zeek.svg" /></a>
    <a href="https://hub.docker.com/r/blacktop/zeek/" alt="Docker Image">
          <img src="https://img.shields.io/badge/docker%20image-65.6MB-blue.svg" /></a>
  </p>
</p>

**Table of Contents**

- [Dependencies](#dependencies)
- [Image Tags](#image-tags)
- [Installation](#installation)
- [Getting Started](#getting-started)
- [Documentation](#documentation)
- [Issues](#issues)
- [License](#license)

## Dependencies

- [alpine:3.14](https://hub.docker.com/_/alpine/)

## Image Tags

```bash
$ docker images

REPOSITORY           TAG          SIZE
blacktop/zeek        latest       65.6MB
blacktop/zeek        4.1          65.6MB
blacktop/zeek        4.0          41.6MB
blacktop/zeek        3.2          41.6MB
blacktop/zeek        3.1          39MB
blacktop/zeek        3.0          39MB
blacktop/zeek        elastic      102MB
blacktop/zeek        kafka        47.2MB
blacktop/zeek        zeekctl      84MB
```

## Installation

1. Install [Docker](https://docs.docker.com).
2. Download [trusted build](https://hub.docker.com/r/blacktop/zeek/) from public [Docker Registry](https://hub.docker.com): `docker pull blacktop/zeek`

## Getting Started

```bash
$ wget https://github.com/blacktop/docker-zeek/raw/master/pcap/heartbleed.pcap
$ wget https://github.com/blacktop/docker-zeek/raw/master/3.0/local.zeek
$ docker run --rm \
         -v `pwd`:/pcap \
         -v `pwd`/local.zeek:/usr/local/zeek/share/zeek/site/local.zeek \
         blacktop/zeek -r heartbleed.pcap local "Site::local_nets += { 192.168.11.0/24 }"
```

```bash
$ ls -l

-rw-r--r--  1 blacktop  staff   635B Jul 30 12:11 conn.log
-rw-r--r--  1 blacktop  staff   754B Jul 30 12:11 files.log
-rw-r--r--  1 blacktop  staff   384B Jul 30 12:11 known_certs.log
-rw-r--r--  1 blacktop  staff   239B Jul 30 12:11 known_hosts.log
-rw-r--r--  1 blacktop  staff   271B Jul 30 12:11 known_services.log
-rw-r--r--  1 blacktop  staff    17K Jul 30 12:11 loaded_scripts.log
-rw-r--r--  1 blacktop  staff   1.9K Jul 30 12:11 notice.log <====== NOTICE
-rw-r--r--  1 blacktop  staff   253B Jul 30 12:11 packet_filter.log
-rw-r--r--  1 blacktop  staff   1.2K Jul 30 12:11 ssl.log
-rw-r--r--  1 blacktop  staff   901B Jul 30 12:11 x509.log
```

```bash
$ cat notice.log | awk '{ print $11 }' | tail -n4

Heartbleed::SSL_Heartbeat_Attack
Heartbleed::SSL_Heartbeat_Odd_Length
Heartbleed::SSL_Heartbeat_Attack_Success
```

## Documentation

- [Usage](https://github.com/blacktop/docker-zeek/blob/master/docs/usage.md)
- [Integrate with the Elasticsearch](https://github.com/blacktop/docker-zeek/blob/master/docs/elastic.md)
- [Integrate with Kafka](https://github.com/blacktop/docker-zeek/blob/master/docs/kafka.md)
- [Tips and Tricks](https://github.com/blacktop/docker-zeek/blob/master/docs/tips-and-tricks.md)

## Issues

Find a bug? Want more features? Find something missing in the documentation? Let me know! Please don't hesitate to [file an issue](https://github.com/blacktop/docker-zeek/issues/new) and I'll get right on it.

## License

MIT Copyright (c) 2018-2020 **blacktop**
