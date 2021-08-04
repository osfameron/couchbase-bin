#!/bin/bash

CONF=$HOME/va.json

__va2() {
  if [[ $# < 2 ]]; then
    return 1
  fi

  VA_1=$1
  VA_2=$2

  if LOOKUP=`jq -e .$VA_1.$VA_2 $CONF`; then

    export VA_PROJECT=$VA_1
    export VA_TYPE=$VA_2
    echo $LOOKUP

    if DIR=`jq -e .$VA_1.$VA_2.dir $CONF -r`; then
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

  if LOOKUP=`jq -e .$VA_1 $CONF`; then

    export VA_PROJECT=$VA_1
    export VA_TYPE=
    echo $LOOKUP

    if DIR=`jq -e "first(.$VA_1 | .[]).dir" $CONF -r`; then
      DIR=${DIR/#\~/$HOME}
      cd "$DIR" && return 0
      echo "Couldn't cd to: $DIR"
      return 1
    else
      echo No .dir specified in config
      return 0
    fi
  fi

  echo .$VA_1 not found
  return 1
}

va() {
  local TRY=$1
  if [[ -z "$TRY" ]]; then
    __va2 $VA_PROJECT $VA_TYPE
  else
      __va2 $VA_PROJECT $TRY \
   || __va2 $TRY $VA_TYPE \
   || __va1 $TRY
  fi
}
