#!/bin/bash

set -euo pipefail

start_filebeat() {
    filebeat
}

if [[ -z $1 ]] || [[ ${1:0:1} == '-' ]] ; then
  start_filebeat
  exec bro "$@"
fi

# If neither of those worked, then they have specified the binary they want, so
# just do exactly as they say.
exec "$@"