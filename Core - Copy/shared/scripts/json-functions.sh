  #!/bin/sh

# G.et J.SON V.alue
function gjv() {
  FIELD_PATH=$1
  JSON_SRC=$2 # Can be a JSON string or a JSON file path
  if [[ -f "$JSON_SRC" ]]; then
    cat $JSON_SRC | jq -r '.'$FIELD_PATH
  else
    echo $JSON_SRC | jq -r '.'$FIELD_PATH
  fi
}

# S.et J.SON V.alue
function sjv() {
  FIELD_NAME=$1 # Limitation - Only supports top level fields
  FIELD_VALUE=$2
  JSON_SRC=$3  # Can be a JSON string or a JSON file path
  mj '{ "'$FIELD_NAME'": "'$FIELD_VALUE'" }' "$JSON_SRC"
  # if [[ -f "$JSON_SRC" ]]; then
  #   echo $(cat $JSON_SRC)' { "'$FIELD_NAME'": "'$FIELD_VALUE'" }' | jq -s add
  # else
  #   echo $JSON_SRC' { "'$FIELD_NAME'": "'$FIELD_VALUE'" }' | jq -s add
  # fi
}

# M.erge J.SON
# Second JSON parameter will overwrite values
#   in the first JSON parameter if they both
#   have the same field name at the same level
function mj() {
  # Can be a JSON string or a JSON file path
  if [[ -f "$1" ]]; then
    JSON1=$(cat $1)
  else
    JSON1=$1
  fi
  # Can be a JSON string or a JSON file path
  if [[ -f "$2" ]]; then
    JSON2=$(cat $2)
  else
    JSON2=$2
  fi
  echo $JSON1' '$JSON2  | jq -s add
  # jq --slurp 'reduce .[] as $item ({}; . * $item)'
}
