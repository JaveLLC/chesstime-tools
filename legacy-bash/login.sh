#!/bin/bash

set -e

source vars.sh

_SELF_UID=${1}
_PASSWORD=${2}
_TOKEN=$(curl -H 'Accept: */*' -H 'User-Agent: haptic_chess/7.8.8.2 CFNetwork/894 Darwin/17.4.0' -H 'Accept-Language: en-us' --data "{ \"user\" : \"${_SELF_UID}\" }" --compressed https://${_AUTH_HOST}/jlogin/init2 | jq -r .rmessage)

curl -H 'Accept: */*' -H 'User-Agent: haptic_chess/7.8.8.2 CFNetwork/894 Darwin/17.4.0' -H 'Accept-Language: en-us' --data "{
  \"code\" : \"${_TOKEN}\",
  \"password\" : \"${_PASSWORD}\",
  \"device\" : \"ios\",
  \"isPro\" : \"N\",
  \"sysversion\" : \"11.2.5\",
  \"version\" : \"7.8.8\"
}" --compressed https://${_AUTH_HOST}/jlogin/enter
