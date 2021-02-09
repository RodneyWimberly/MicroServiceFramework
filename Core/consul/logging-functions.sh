#!/bin/sh

# error - red
export COLOR_ERROR="${ESCAPE}[${RESET_ALL};${SET_BLINK};${FOREGROUND_RED}m"
# warning -yellow
export COLOR_WARNING="${ESCAPE}[${SET_BOLD};;${SET_BLINK};${FOREGROUND_YELLOW}m"
# information -green
export COLOR_INFORMATION="${ESCAPE}[${RESET_ALL};${FOREGROUND_GREEN}m"
# details - light green
export COLOR_DETAILS="${ESCAPE}[${SET_BOLD};${FOREGROUND_GREEN}m"
# header - purple
export COLOR_HEADER="${ESCAPE}[${RESET_ALL};${SET_UNDERLINE};${FOREGROUND_MAGENTA}m"
# time stamp/entry type - white
export COLOR_LOG_ENTRY="${ESCAPE}[${SET_BOLD};${FOREGROUND_LIGHT_GRAY}m"

function log() {
  log_raw "[INF]${COLOR_INFORMATION} $1"
}

function log_header() {
  echo " "
  #log_raw "${PURPLE}[HDR] -----------------------------------------------------------"
  log_raw "[HDR]${COLOR_HEADER} $1"
  #log_raw "${PURPLE}[HDR] -----------------------------------------------------------"
}

function log_detail() {
  log_raw "[DTL]${COLOR_DETAILS}  ====> $1"
}

function log_error() {
  log_raw "[ERR]${COLOR_ERROR} $1"
}

function log_warning() {
  log_raw "[WAR]${COLOR_WARNING} $1"
}

function log_raw() {
  echo -e "${COLOR_LOG_ENTRY}$(date +"%T"): $1 ${NC}"
}
