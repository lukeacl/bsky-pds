#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

BASEDIR=$(dirname "$0")

source "${BASEDIR}/../pds/pds.env"

curl \
  --fail \
  --silent \
  --show-error \
  --request POST \
  --user "admin:${PDS_ADMIN_PASSWORD}" \
  --header "Content-Type: application/json" \
  --data '{"useCount": 1}' \
  "https://${PDS_HOSTNAME}/xrpc/com.atproto.server.createInviteCode" | jq --raw-output '.code'
