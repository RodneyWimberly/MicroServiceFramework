#!/bin/sh

function log() {
  log_raw "${ESCAPE}[${RESET_ALL};${FOREGROUND_GREEN}m [INF] $1 ${ESCAPE}[${RESET_ALL}m"
}

function log_header() {
  echo " "
  log_raw "${ESCAPE}[${RESET_ALL};${FOREGROUND_MAGENTA}m [HDR] ----------------------------------------------------------- ${ESCAPE}[${RESET_ALL}m"
  log_raw "${ESCAPE}[${RESET_ALL};${FOREGROUND_MAGENTA}m [HDR] - $1 ${ESCAPE}[${RESET_ALL}m"
  log_raw "${ESCAPE}[${RESET_ALL};${FOREGROUND_MAGENTA}m [HDR] ----------------------------------------------------------- ${ESCAPE}[${RESET_ALL}m"
}

function log_detail() {
  log_raw "${ESCAPE}[${SET_BOLD};${FOREGROUND_GREEN}m [DTL]  ====> $1 ${ESCAPE}[${RESET_ALL}m"
}

function log_error() {
  log_raw "${ESCAPE}[${RESET_ALL};${FOREGROUND_RED}m [ERR] $1 ${ESCAPE}[${RESET_ALL}m"
}

function log_warning() {
  log_raw "${ESCAPE}[${SET_BOLD};${FOREGROUND_YELLOW}m [WAR] $1 ${ESCAPE}[${RESET_ALL}m"
}

function log_raw() {
  echo -e "${ESCAPE}[${SET_BOLD};${FOREGROUND_LIGHT_GRAY}m $(date +"%T"): $1"
}
