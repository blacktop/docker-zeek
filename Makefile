REPO=blacktop/docker-zeek
ORG=blacktop
NAME=zeek
BUILD ?=$(shell cat LATEST)
LATEST ?=$(shell cat LATEST)


all: build size test

build: ## Build docker image
	cd $(BUILD); docker build -t $(ORG)/$(NAME):$(BUILD) .

.PHONY: size
size: build ## Get built image size
ifeq "$(BUILD)" "$(LATEST)"
	sed -i.bu 's/docker%20image-.*-blue/docker%20image-$(shell docker images --format "{{.Size}}" $(ORG)/$(NAME):$(BUILD)| cut -d' ' -f1)-blue/' README.md
	sed -i.bu '/latest/ s/[0-9.]\{3,5\}MB/$(shell docker images --format "{{.Size}}" $(ORG)/$(NAME):$(BUILD))/' README.md
endif
	sed -i.bu '/$(BUILD)/ s/[0-9.]\{3,5\}MB/$(shell docker images --format "{{.Size}}" $(ORG)/$(NAME):$(BUILD))/' README.md

.PHONY: tags
tags:
	docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" $(ORG)/$(NAME)

test: clean_pcap ## Test docker image
ifeq ($(BUILD),elastic)
	@docker-compose -f docker-compose.elastic.yml up -d kibana
	@wait-for-es
	@docker-compose -f docker-compose.elastic.yml up bro
	@http localhost:9200/_cat/indices
	@open -a Safari http://localhost:5601
	@cat pcap/notice.log | jq .note
	# @cat pcap/json_streaming_notice.1.log | jq .note
else ifeq ($(BUILD),kafka)
	@kafka/tests/kafka.sh
else
	@docker run --rm $(ORG)/$(NAME):$(BUILD) --version
	@docker run --rm -v `pwd`/pcap:/pcap $(ORG)/$(NAME):$(BUILD) -r heartbleed.pcap local "Site::local_nets += { 192.168.11.0/24 }"
	@cat pcap/notice.log | awk '{ print $$11 }' | tail -n4
endif

.PHONY: tar
tar: ## Export tar of docker image
	docker save $(ORG)/$(NAME):$(BUILD) -o $(NAME).tar

.PHONY: push
push: build ## Push docker image to docker registry
	@echo "===> Pushing $(ORG)/$(NAME):$(BUILD) to docker hub..."
	@docker push $(ORG)/$(NAME):$(BUILD)

.PHONY: run
run: stop ## Run docker container
	@docker run --init -d --name $(NAME) -p 9200:9200 $(ORG)/$(NAME):$(BUILD)

.PHONY: ssh
ssh: clean_pcap ## SSH into docker image
ifeq ($(BUILD),elastic)
	@docker-compose -f docker-compose.elastic.yml up -d kibana
	@wait-for-es
	@docker run --init -it --rm --link docker-zeek_elasticsearch_1:elasticsearch --link docker-zeek_kibana_1:kibana -v `pwd`/pcap:/pcap -e ELASTICSEARCH_USERNAME=elastic -e ELASTICSEARCH_PASSWORD=password --entrypoint=sh $(ORG)/$(NAME):$(BUILD)
else
	@docker run --rm -v `pwd`/pcap:/pcap --entrypoint=sh $(ORG)/$(NAME):$(BUILD)
endif

.PHONY: stop
stop: ## Kill running docker containers
	@docker rm -f $(NAME) || true
	@docker rm -f elasticsearch || true
	@docker rm -f kibana || true

.PHONY: stop-all
stop-all: ## Kill ALL running docker containers
	@docker-clean stop

clean: ## Clean docker image and stop all running containers
	docker-clean stop
	docker rmi $(ORG)/$(NAME):$(BUILD) || true

.PHONY: clean_pcap
clean_pcap:
	@rm pcap/*.log || true
	@rm -rf pcap/.state || true
	@rm -rf pcap/extract_files || true

# Absolutely awesome: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
