#!/bin/sh

log_new_line() {
  echo " "
}

log_header() {
  log_new_line
  log_raw "${BOLD_PURPLE}" "SUMMARY" "$1"
}

log_detail() {
  log_raw "${CYAN}" "DETAILS" "====> $1"
}

log() {
  log_raw "${PURPLE}" "VERBOSE" "$1"
}

log_warning() {
  log_raw "${BOLD_YELLOW}" "WARNING" "$1"
}

log_error() {
  log_raw "${BOLD_RED}" "FAILURE" "$1"
}

log_raw() {
  if [ "$2" = "SUMMARY" ]; then
     echo -e "${GREEN}[$BOLD_GRAY$(date +"%T")${GREEN}] $1$2:${NO_COLOR} ${BOLD_GRAY_UNDERLINE}$3${NO_COLOR}"
  else
     echo -e "${GREEN}[$BOLD_GRAY$(date +"%T")${GREEN}] $1$2:${NO_COLOR} $3"
  fi
  
  
}

#[12:45:34] SUMMARY: This is a sample log message

