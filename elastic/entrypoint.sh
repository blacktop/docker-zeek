#!/bin/bash

set -euo pipefail

# Wait for elasticsearch to start. It requires that the status be either
# green or yellow.
waitForElasticsearch() {
  echo -n "===> Waiting on elasticsearch($(es_url)) to start..."
  i=0;
  while [ $i -le 60 ]; do
    health=$(curl --silent "$(es_url)/_cat/health" | awk '{print $4}')
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
  echo >&2 "Address: $(es_url)"
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
    echo >&2 "${3} is not available"
    echo >&2 "Address: ${1}"
}

startFilebeat() {
    filebeat setup
    filebeat
}

if [[ -z $1 ]] || [[ ${1:0:1} == '-' ]] ; then
  waitForElasticsearch
  waitFor ${KIBANA_HOST} Kibana
  startFilebeat
  exec bro "$@"
fi

exec "$@"