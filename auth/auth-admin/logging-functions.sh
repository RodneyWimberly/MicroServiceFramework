#!/bin/sh

set +u
if [ -z "$LOG_LEVEL" ]; then
  LOG_LEVEL="DEBUG"
fi
set -u

log_new_line() {
  echo " "
}

log_header() {
  if [ $LOG_LEVEL = "INFO" ] || [ $LOG_LEVEL = "DEBUG" ]; then
    log_new_line
    log_raw "${BLUE}" "SUMMARY" "$1"
  fi
}

log_detail() {
  if [ $LOG_LEVEL = "DEBUG" ]; then
    log_raw "${BLUE}" "DEBUG" "+ $1"
  fi
}

log() {  
  if [ $LOG_LEVEL = "INFO" ] || [ $LOG_LEVEL = "DEBUG" ]; then
    log_raw "${BOLD_CYAN}" "INFO" "=> $1"
  fi
}

log_info() {
  log "$1"
}

log_warning() {
  if [ $LOG_LEVEL = "DEBUG" ] || [ $LOG_LEVEL = "INFO" ] || [ $LOG_LEVEL = "WARNING" ]; then
   log_raw "${BOLD_YELLOW}" "WARNING" "$1"
  fi
}

log_error() {
  if  [ $LOG_LEVEL = "DEBUG" ] || [ $LOG_LEVEL = "INFO" ] || [ $LOG_LEVEL = "WARNING" ] || [ $LOG_LEVEL = "ERROR" ]; then
    log_raw "${BOLD_RED}" "ERROR" "$1"
  fi
}

log_failure() {
  if [ $LOG_LEVEL = "DEBUG" ] || [ $LOG_LEVEL = "INFO" ] || [ $LOG_LEVEL = "WARNING" ] || [ $LOG_LEVEL = "ERROR" ]; then
    log_raw "${RED}" "FAILURE" "$1"
  fi
}

log_success() {
  if [ $LOG_LEVEL = "DEBUG" ] || [ $LOG_LEVEL = "INFO" ]; then
    start_seconds=${2:-0}
    if [ "$start_seconds" -eq 0 ]; then
      log_raw "${GREEN}" "SUCCESS" "$1"
    else
      log_raw "${GREEN}" "SUCCESS" "$1 in $(get_elapsed_seconds "$start_seconds") seconds."
    fi
  fi
}

log_raw() {
  if [ "$2" = "SUMMARY" ]; then
     echo -e "${PURPLE}[$BOLD_GRAY$(date +"%T")${PURPLE}] $1${NO_COLOR}${BOLD_GRAY_UNDERLINE}$3${NO_COLOR}"
  else
     echo -e "${PURPLE}[$BOLD_GRAY$(date +"%T")${PURPLE}] $1$2:${NO_COLOR} $3"
  fi
}

get_seconds() {
  date +%s
}

get_elapsed_seconds() {
  start_seconds=${1:-$(get_seconds)}
  end_seconds=$(get_seconds)
  echo "$((end_seconds - start_seconds))"
}

#[12:45:34] SUMMARY: This is a sample log message

