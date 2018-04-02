#!/bin/bash

set -ex

if [ $# -lt 2 ]; then
  echo "$0 <login id> <password>"
  exit 1
fi

source vars.sh
source login.sh ${1} ${2}

leaders=$(curl -H 'Accept: */*' -H 'User-Agent: haptic_chess/7.8.8.2 CFNetwork/894 Darwin/17.4.0' -H 'Accept-Language: en-us' --compressed "http://${_SERV_HOST}/juser/leaders2?scope=Global&tkn=${_TOKEN}" | jq .result[].name)

for i in $leaders; do
  echo $i;
  while true; do
    invite $_TOKEN $i
  done &
done
