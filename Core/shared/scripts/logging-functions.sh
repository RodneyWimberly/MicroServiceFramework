#!/bin/sh

function log() {
  log_raw "${GREEN}[INF] $1"
}

function log_header() {
  echo " "
  log_raw "${PURPLE}[HDR] -----------------------------------------------------------"
  log_raw "${PURPLE_UNDERLINE}[HDR] - $1"
  log_raw "${PURPLE}[HDR] -----------------------------------------------------------"
}

function log_detail() {
  log_raw "${LT_GREEN}[DTL]  ====> $1"
}

function log_error() {
  log_raw "${RED}[ERR] $1"
}

function log_warning() {
  log_raw "${YELLOW}[WAR] $1"
}

function log_raw() {
  echo -e "${WHITE}$(date +"%T"): $1 ${NC}"
}
