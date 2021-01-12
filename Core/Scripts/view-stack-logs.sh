#!/bin/bash
# USAGE: view-stack-logs.sh -t -f --since=1m --tail=50 mystackname
# 14-03-20:  multiple docker stacknames can be provided as stack1,stack2,stack3,...
ARGS=''
SEARCH='Jobserver'
LASTPONG=$(date +%s)

# getting positional (aka last) argument as STACK
[[ "x${@:$#}" != 'x' && "x$(echo ${@:$#}|grep ^\-)" = 'x' ]] && STACK="${@:$#}"

# all other cli arguments go 1:1 to docker service logs
# used as docker service logs $ARGS $STACK
ARGS=${*%${!#}}

# exit if no stackname
[[ -z ${STACK} || "x${STACK}" = 'x' ]] && echo "$0 stackname" && exit 1

# if just one stackname
if [[ ! "$STACK" =~ , ]] ; then
  ret=$(docker stack services $STACK --format "{{.Name}}" 2>&1)
  # add stack's services if found any
  [[ "x$ret" != 'x' && ! "$ret" =~ ^Nothing ]] && SERVICES="$ret"
else
  # multiple stacknames separated by ,
  OLDIFS=$IFS
  IFS=,
  for i in $STACK ; do
    [ "x${i}" = 'x' ] && continue
    ret=$(docker stack services $i --format "{{.Name}}" 2>&1)
    # add stack's services if found any
    [[ "x$ret" != 'x' && ! "$ret" =~ ^Nothing ]] && SERVICES="${SERVICES}${ret}"
  done
fi

# exit if no services found
[ "x$SERVICES" = 'x' ] && SEP=' ' &&  echo "ERROR: no services found in$(for i in $STACK ; do echo -n $SEP$i ; SEP=' or ' ; done)" && exit 1

# restore IFS
IFS=$OLDIFS

COMMAND="{ "
JOINER=""

for SERVICE in $SERVICES
do
  COMMAND="$COMMAND $JOINER docker service logs $ARGS $SERVICE"
  JOINER="&"
done

COMMAND="$COMMAND; }"

eval $COMMAND 2>&1 | grep --line-buffered '.*' | while read LOGLINE ; do
  [[ "${LOGLINE}" =~ $SEARCH ]] && LASTPONG=$(date +%s)
  [[ $(( $(date +%s) - $LASTPONG )) -gt 11 ]] && echo "$(TZ='UTC' date) ALERT"
done