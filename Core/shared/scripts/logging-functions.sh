#!/bin/sh

function log() {
  log_raw "[INF] $1"
}

function log_detail() {
  log_raw "[DTL]  ====> $1"
}

function log_error() {
  log_raw "[ERR] $1"
}

function log_warning() {
  log_raw "[WAR] $1"
}

function log_raw() {
  echo "$(date +"%T"): $1"
}
