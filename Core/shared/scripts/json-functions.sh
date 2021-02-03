#!/bin/sh

# G.et J.SON V.alue
function gjv() {
  if [[ -f "$2" ]]; then
    cat $2 | jq -r -M '.$1'
  else
    echo $2 | jq -r -M '.$1'
  fi
}

# S.et J.SON V.alue
function sjv() {
  if [[ -f "$3" ]]; then
    cat $3 | jq ". + { \"$1\": \"$2\" }" > $3
  else
    echo $3 | jq ". + { \"$1\": \"$2\" }" > $3
  fi
}
