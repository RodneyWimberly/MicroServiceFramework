#!/bin/bash
# exit logs with ctrl-c
stack=$1
if [ -z "${stack}" ]; then
    echo 'Usage:'
    echo "$0 <stack>"
    exit 1
fi

stackServices=$(docker stack services "$stack" --format "{{.ID}}")

trap 'jobs=$(jobs -p) && test -n "$jobs" && kill $jobs' EXIT

source ./Scripts/common.sh

current="$RED"
for item in ${stackServices//\\n/$'\n'}; do
    docker service logs -f -t --tail 10 $item | docker-logs-localtime &
    echo -e "${current}${logs}${NC}"
    case "$current" in
        "$RED")
        current="$GREEN"
        ;;
        "$GREEN")
        current="$ORANGE"
        ;;
        "$ORANGE")
        current="$BLUE"
        ;;
        "$BLUE")
        current="$PURPLE"
        ;;
        "$PURPLE")
        current="$CYAN"
        ;;
        "$CYAN")
        current="$LT_GRAY"
        ;;
        "$LT_GRAY")
        current="$DK_GRAY"
        ;;
        "$DK_GRAY")
        current="$LT_RED"
        ;;
        "$LT_RED")
        current="$LT_GREEN"
        ;;
        "$LT_GREEN")
        current="$YELLOW"
        ;;
        "$YELLOW")
        current="$LT_BLUE"
        ;;
        "$LT_BLUE")
        current="$LT_PURPLE"
        ;;
        "$LT_PURPLE")
        current="$LT_CYAN"
        ;;
        "$LT_CYAN")
        current="$WHITE"
        ;;
        "$WHITE")
        current="$RED"
         ;;      *)
        $current="$NC"
        ;;
    esac
done

sleep infinity
