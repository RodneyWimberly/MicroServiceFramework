#!/bin/sh

function log() {
  log_raw "[INF]${LOG_COLOR_INFORMATION} $1"
}

function log_header() {
  echo " "
  #log_raw "${PURPLE}[HDR] -----------------------------------------------------------"
  log_raw "[HDR] ${LOG_COLOR_HEADER}$1"
  #log_raw "${PURPLE}[HDR] -----------------------------------------------------------"
}

function log_detail() {
  log_raw "[DTL] ${LOG_COLOR_DETAILS} ====> $1"
}

function log_error() {
  log_raw "[ERR] ${LOG_COLOR_ERROR}$1"
}

function log_warning() {
  log_raw "[WAR] ${LOG_COLOR_WARNING}$1"
}

function log_raw() {
  echo -e "${LOG_COLOR_TIMESTAMP}$(date +"%T"): ${LOG_COLOR_LOGTYPE}$1 ${NC}"
}
