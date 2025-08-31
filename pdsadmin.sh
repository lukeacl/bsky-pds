#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

if ! command -v jq &> /dev/null; then
    echo "Error: jq could not be found. Please install it." >&2
    exit 1
fi

BASEDIR=$(dirname "$0")

# Command to run.
COMMAND="${1:-help}"
shift || true

SCRIPT_FILE="${BASEDIR}/pdsadmin/${COMMAND}.sh"

"${SCRIPT_FILE}" "$@"
