#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

BASEDIR=$(dirname "$0")

source "${BASEDIR}/../pds/pds.env"

RELAY_HOSTS="${1:-}"
if [[ "${RELAY_HOSTS}" == "" ]]; then
  RELAY_HOSTS="${PDS_CRAWLERS}"
fi

if [[ "${RELAY_HOSTS}" == "" ]]; then
  echo "ERROR: missing RELAY HOST parameter." >/dev/stderr
  echo "Usage: $0 <RELAY HOST>[,<RELAY HOST>,...]" >/dev/stderr
  exit 1
fi

for host in ${RELAY_HOSTS//,/ }; do
  echo "Requesting crawl from ${host}"
  if [[ $host != https:* && $host != http:* ]]; then
    host="https://${host}"
  fi
  curl \
    --fail \
    --silent \
    --show-error \
    --request POST \
    --header "Content-Type: application/json" \
    --data "{\"hostname\": \"${PDS_HOSTNAME}\"}" \
    "${host}/xrpc/com.atproto.sync.requestCrawl" >/dev/null
done

echo "done"
