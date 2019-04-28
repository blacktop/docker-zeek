# Usage

## Capture Live Traffic

```bash
docker run --rm --cap-add=NET_RAW --net=host -v `pwd`:/pcap:rw blacktop/zeek -i eth0
```

## Use your own pcap

```bash
$ docker run --rm -v /path/to/pcap:/pcap:rw blacktop/zeek -r my.pcap local
```

## To use your own `local.zeek`

```bash
$ docker run --rm \
  -v `pwd`:/pcap \
  -v `pwd`/local.zeek:/usr/local/share/zeek/site/local.zeek \
  blacktop/zeek -r my_pcap.pcap local
```
