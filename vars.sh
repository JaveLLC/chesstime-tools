#!/bin/bash

_AUTH_HOST=auth.chesstimelive.com
_SERV_HOST=server.chesstimelive.com

function invite() {
  if [ $# -lt 2 ]; then
    echo "invite <token> <uid> #invite func"
    return 1
  fi

  local _TOKEN=$1
  local _TARGET_UID=$2

  curl -H 'Accept: */*' -H 'User-Agent: haptic_chess/7.8.8.2 CFNetwork/894 Darwin/17.4.0' -H 'Accept-Language: en-us' --data "{
    \"username\" : \"${_TARGET_UID}\",
    \"secPerMove\" : 172800
  }" --compressed http://${_SERV_HOST}/juser/invite/user?tkn=${_TOKEN}

  gid=$(curl  -H 'Accept: */*' -H 'User-Agent: haptic_chess/7.8.8.2 CFNetwork/894 Darwin/17.4.0' -H 'Accept-Language: en-us' --compressed http://${_SERV_HOST}/jgame/active?tkn=${_TOKEN} | jq .result.myInvites[].id)

  for i in $gid; do
    curl -H 'Accept: */*' -H 'User-Agent: haptic_chess/7.8.8.2 CFNetwork/894 Darwin/17.4.0' -H 'Accept-Language: en-us' --data "{ }" --compressed "http://${_SERV_HOST}/juser/invite/delete/$i?tkn=${_TOKEN}"
  done
}

function bestmove() {
  if [ $# -lt 1 ]; then
    echo "bestmove <fen position> #bestmove func"
    return 1
  fi

  bestmove=$(cat << EOF | stockfish
setoption name Threads value 4
setoption name Hash value 1024
position fen ${1}
go movetime 60000 # analyze for 60s
EOF)

  echo ${bestmove} | grep bestmove | sed -e 's/^.*bestmove //'
}
