#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

BASEDIR=$(dirname "$0")

# Command to run.
COMMAND="${1:-help}"
shift || true

SCRIPT_FILE="${BASEDIR}/pdsadmin/${COMMAND}.sh"

"${SCRIPT_FILE}" "$@"