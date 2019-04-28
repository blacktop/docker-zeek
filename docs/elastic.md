# Integrate with the Elasticsearch

Download or create `your.pcap` in current directory

```bash
$ docker run -d --name elasticsearch -p 9200:9200 blacktop/elasticsearch:7.0
$ docker run -d --name kibana --link elasticsearch -p 5601:5601 blacktop/kibana:7.0
$ docker run --init --rm -it -v `pwd`:/pcap \
                             --link kibana \
                             --link elasticsearch \
                             blacktop/filebeat -e
$ docker run -it --rm -v `pwd`:/pcap blacktop/zeek:elastic -r your.pcap local

# assuming you are using Docker For Mac.
$ open http://localhost:5601/app/kibana
```

> :warning: **NOTE:** I have noticed when running [elasticsearch](https://github.com/blacktop/docker-elasticsearch-alpine) on a **linux** host you need to increase the memory map areas with the following [command](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#docker-cli-run-prod-mode)

```bash
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
sudo sysctl -w vm.max_map_count=262144
```

=OR=

 You can use [docker-compose](https://docs.docker.com/compose/overview/)

```bash
$ git clone --depth 1 https://github.com/blacktop/docker-zeek.git
$ cd docker-zeek
$ docker-compose -f docker-compose.elastic.yml up -d kibana
# wait a little while for elasticsearch/kibana to start
$ docker-compose -f docker-compose.elastic.yml up -d filebeat
$ docker-compose -f docker-compose.elastic.yml up zeek
# wait a little while for filebeat to consume all the logs
$ open http://localhost:5601/app/kibana
```

## Open the Zeek [Dashboard](http://localhost:5601/app/kibana#/dashboard/7cbb5410-3700-11e9-aa6d-ff445a78330c?_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:'2011-01-25T18:50:05.529Z',to:'2011-01-25T18:58:53.008Z'))&_a=(description:'',filters:!(),fullScreenMode:!f,options:(hidePanelTitles:!f,useMargins:!t),panels:!((embeddableConfig:(mapCenter:!(43.32517767999296,-41.22070312500001),mapZoom:3),gridData:(h:14,i:'1',w:48,x:0,y:7),id:f469f230-370c-11e9-aa6d-ff445a78330c,panelIndex:'1',type:visualization,version:'7.0.0-beta1'),(embeddableConfig:(),gridData:(h:12,i:'2',w:16,x:0,y:33),id:'1df7ea80-370d-11e9-aa6d-ff445a78330c',panelIndex:'2',type:visualization,version:'7.0.0-beta1'),(embeddableConfig:(),gridData:(h:12,i:'3',w:16,x:16,y:33),id:'466e5850-370d-11e9-aa6d-ff445a78330c',panelIndex:'3',type:visualization,version:'7.0.0-beta1'),(embeddableConfig:(),gridData:(h:12,i:'4',w:16,x:32,y:33),id:'649acd40-370d-11e9-aa6d-ff445a78330c',panelIndex:'4',type:visualization,version:'7.0.0-beta1'),(embeddableConfig:(),gridData:(h:12,i:'5',w:16,x:0,y:21),id:'9436c270-370d-11e9-aa6d-ff445a78330c',panelIndex:'5',type:visualization,version:'7.0.0-beta1'),(embeddableConfig:(),gridData:(h:12,i:'6',w:16,x:16,y:21),id:bec2f0e0-370d-11e9-aa6d-ff445a78330c,panelIndex:'6',type:visualization,version:'7.0.0-beta1'),(embeddableConfig:(),gridData:(h:12,i:'7',w:16,x:32,y:21),id:e042fda0-370d-11e9-aa6d-ff445a78330c,panelIndex:'7',type:visualization,version:'7.0.0-beta1'),(embeddableConfig:(),gridData:(h:7,i:'8',w:47,x:0,y:0),id:f8c40810-370d-11e9-aa6d-ff445a78330c,panelIndex:'8',type:visualization,version:'7.0.0-beta1')),query:(language:kuery,query:''),timeRestore:!f,title:'Zeek%20Overview%20Dashboard',viewMode:view))

![dashboard](https://raw.githubusercontent.com/blacktop/docker-zeek/master/docs/imgs/dashboard.png)
