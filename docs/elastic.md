# Integrate with the Elasticsearch

```bash
$ wget https://github.com/blacktop/docker-zeek/raw/master/pcap/heartbleed.pcap
$ docker run -d --name elasticsearch -p 9200:9200 blacktop/elasticsearch:7.0
$ docker run -d --name kibana --link elasticsearch -p 5601:5601 blacktop/kibana:7.0
$ docker run -it --rm -v `pwd`:/pcap --link elasticsearch --link kibana \
             blacktop/zeek:elastic -r heartbleed.pcap local "Site::local_nets += { 192.168.11.0/24 }"

# assuming you are using Docker For Mac.
$ open http://localhost:5601/app/kibana
```

> :warning: **NOTE:** I have noticed when running [elasticsearch](https://github.com/blacktop/docker-elasticsearch-alpine) on a **linux** host you need to increase the memory map areas with the following [command](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#docker-cli-run-prod-mode)

```bash
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
sudo sysctl -w vm.max_map_count=262144
```

Open the Zeek Dashboard

![dashboard](docs/imgs/dashboard.png)

=OR=

## You can use [docker-compose](https://docs.docker.com/compose/overview/)

```bash
$ git clone --depth 1 https://github.com/blacktop/docker-zeek.git
$ cd docker-zeek
$ docker-compose -f docker-compose.elastic.yml up -d kibana
# wait a little while for elasticsearch/kibana to start
$ docker-compose -f docker-compose.elastic.yml up zeek
$ open http://localhost:5601/app/kibana
```
