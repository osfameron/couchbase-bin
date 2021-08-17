#!/bin/bash

CONF=$HOME/va.json

vaq() {
  local QUERY=${1:-.}
  shift 2>/dev/null
  local OPTIONS=$*
  jq -e "$QUERY" $CONF $OPTIONS
}

__va2() {
  if [[ $# < 2 ]]; then
    return 1
  fi

  VA_1=$1
  VA_2=$2

  if LOOKUP=`vaq ".$VA_1.$VA_2"`; then

    export VA_PROJECT=$VA_1
    export VA_TYPE=$VA_2
    echo $LOOKUP

    if DIR=`vaq ".$VA_1.$VA_2.dir" -r`; then
      DIR=${DIR/#\~/$HOME}
      cd "$DIR" && return 0
      echo "Couldn't cd to: $DIR"
      return 1
    else
      echo No .dir specified in config
      return 0
    fi
  fi

  return 1
}

__va1() {
  if [[ $# < 1 ]]; then
    return 1
  fi

  local VA_1=$1

  if LOOKUP=`vaq .$VA_1`; then

    echo $LOOKUP
    VA_TYPE=`vaq ".$VA_1 | keys_unsorted | first" -r`
    __va2 $VA_1 $VA_TYPE > /dev/null
    return 0
  fi

  return 1
}

va() {
  local TRY=$1
  if [[ -z "$TRY" ]]; then
    __va2 $VA_PROJECT $VA_TYPE
  else
      __va2 $VA_PROJECT $TRY \
   || __va2 $TRY $VA_TYPE \
   || __va1 $TRY \
   || echo "$TRY not found" && return 1
  fi
}

alias vap="vaq 'keys |.[]' -r"
