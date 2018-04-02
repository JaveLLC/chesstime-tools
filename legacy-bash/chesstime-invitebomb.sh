#!/bin/bash
# by taup1n and slobber
# usage: $0 <login id> <password> <target profile id>

set -e

if [ $# -lt 3 ]; then
  echo "$0 <login id> <password> <target profile id>"
  exit 1
fi

source vars.sh
source login.sh ${1} ${2}

_TARGET_UID=${3}

while true; do
  invite $_TOKEN $_TARGET_UID
done
