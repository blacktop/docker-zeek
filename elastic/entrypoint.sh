#!/bin/sh

set -euo pipefail

geoipInfo(){
  ELASTICSEARCH_HOSTS=${ELASTICSEARCH_HOSTS:-elasticsearch:9200}
  echo "===> Adding geoip-info pipeline..."
  curl -s -X PUT "${ELASTICSEARCH_HOSTS}/_ingest/pipeline/geoip-info" -H 'Content-Type: application/json' -d'
  {
    "description": "Add geoip info",
    "processors": [
      {
        "geoip": {
          "field": "client.ip",
          "target_field": "client.geo",
          "ignore_missing": true
        }
      },
      {
        "geoip": {
          "field": "source.ip",
          "target_field": "source.geo",
          "ignore_missing": true
        }
      },
      {
        "geoip": {
          "field": "id.orig_h",
          "target_field": "source.geo",
          "ignore_missing": true
        }
      },
      {
        "geoip": {
          "field": "destination.ip",
          "target_field": "destination.geo",
          "ignore_missing": true
        }
      },
      {
        "geoip": {
          "field": "id.resp_h",
          "target_field": "destination.geo",
          "ignore_missing": true
        }
      },
      {
        "geoip": {
          "field": "server.ip",
          "target_field": "server.geo",
          "ignore_missing": true
        }
      },
      {
        "geoip": {
          "field": "host.ip",
          "target_field": "host.geo",
          "ignore_missing": true
        }
      }
    ]
  }
  '
  echo -e "\n * Done."
}
# Wait for elasticsearch to start. It requires that the status be either
# green or yellow.
waitForElasticsearch() {
  ELASTICSEARCH_HOSTS=${ELASTICSEARCH_HOSTS:-elasticsearch:9200}
  echo -n "===> Waiting on elasticsearch(${ELASTICSEARCH_HOSTS}) to start..."
  i=0;
  while [ $i -le 60 ]; do
    health=$(curl --silent "${ELASTICSEARCH_HOSTS}/_cat/health" | awk '{print $4}')
    if [[ "$health" == "green" ]] || [[ "$health" == "yellow" ]]
    then
      echo
      echo "Elasticsearch is ready!"
      return 0
    fi

    echo -n '.'
    sleep 1
    i=$((i+1));
  done

  echo
  echo >&2 'Elasticsearch is not running or is not healthy.'
  echo >&2 "Address: ${ELASTICSEARCH_HOSTS}"
  echo >&2 "$health"
  exit 1
}

# Wait for. Params: host, port, service
waitFor() {
    echo -n "===> Waiting for ${2}(${1}) to start..."
    i=1
    while [ $i -le 20 ]; do
        if nc -vz ${1} 2>/dev/null; then
            echo "${2} is ready!"
            return 0
        fi

        echo -n '.'
        sleep 1
        i=$((i+1))
    done

    echo
    echo >&2 "${2} is not available"
    echo >&2 "Address: ${1}"
}

startFilebeat() {
    cd /usr/share/filebeat
    echo "===> Setting up filebeat..."
    filebeat setup --modules zeek -e -E 'setup.dashboards.enabled=true'
    echo "===> Starting filebeat..."
    filebeat &
}

if [[ -z $1 ]] || [[ ${1:0:1} == '-' ]] ; then
  waitForElasticsearch
  # geoipInfo
  waitFor ${KIBANA_HOST:-kibana:5601} Kibana
  startFilebeat
  cd /pcap
  exec bro "$@"
fi

exec "$@"