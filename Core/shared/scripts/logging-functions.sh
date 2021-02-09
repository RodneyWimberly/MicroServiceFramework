#!/bin/sh

function log() {
  log_raw "${GREEN} [INF] $1 ${NC}"
}

function log_header() {
  echo " "
  log_raw "${PURPLE} [HDR] ----------------------------------------------------------- ${NC}"
  log_raw "${PURPLE} [HDR] - $1 ${NC}"
  log_raw "${PURPLE} [HDR] ----------------------------------------------------------- ${NC}"
}

function log_detail() {
  log_raw "${LT_GREEN} [DTL]  ====> $1 ${NC}"
}

function log_error() {
  log_raw "${RED} [ERR] $1 ${NC}"
}

function log_warning() {
  log_raw "${YELLOW} [WAR] $1 ${NC}"
}

function log_raw() {
  echo -e "${WHITE} $(date +"%T"): $1"
}
