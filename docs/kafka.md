# Integrate with Kafka

## Start a Kafka Broker

```bash
$ docker run -d \
           --name kafka \
           -p 9092:9092 \
           -e KAFKA_ADVERTISED_HOST_NAME=localhost \
           -e KAFKA_CREATE_TOPICS="zeek:1:1" \
           blacktop/kafka:0.11
```

## In a new terminal start a Kafka consumer

### Required

- [Golang](https://golang.org/doc/install)
- [jq](https://stedolan.github.io/jq/)

```bash
$ go get github.com/Shopify/sarama/tools/kafka-console-consumer
$ kafka-console-consumer --bootstrap-server localhost:9092 --topic zeek | jq .
```

## Run Bro with the Kafka plugin and watch the consumer... consume.

```bash
$ wget https://github.com/blacktop/docker-zeek/raw/master/pcap/heartbleed.pcap
$ docker run --rm \
         -v `pwd`:/pcap \
         --link kafka:localhost \
         blacktop/zeek:kafka -P -r heartbleed.pcap local "Site::local_nets += { 192.168.11.0/24 }"
```
