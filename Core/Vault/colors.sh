#!/bin/sh
##########################################################
# Normal
export BLACK="${ESCAPE}[${RESET_ALL};${FOREGROUND_BLACK}m"
export RED="${ESCAPE}[${RESET_ALL};${FOREGROUND_RED}m"
export GREEN="${ESCAPE}[${RESET_ALL};${FOREGROUND_GREEN}m"
export YELLOW="${ESCAPE}[${RESET_ALL};${FOREGROUND_YELLOW}m"
export BLUE="${ESCAPE}[${RESET_ALL};${FOREGROUND_BLUE}m"
export PURPLE="${ESCAPE}[${RESET_ALL};${FOREGROUND_MAGENTA}m"
export CYAN="${ESCAPE}[${RESET_ALL};${FOREGROUND_CYAN}m"
export GRAY="${ESCAPE}[${RESET_ALL};${FOREGROUND_LIGHT_GRAY}m"

##########################################################
# Bold
export BOLD_BLACK="${ESCAPE}[${SET_BOLD};${FOREGROUND_BLACK}m"
export BOLD_RED="${ESCAPE}[${SET_BOLD};${FOREGROUND_RED}m"
export BOLD_GREEN="${ESCAPE}[${SET_BOLD};${FOREGROUND_GREEN}m"
export BOLD_YELLOW="${ESCAPE}[${SET_BOLD};${FOREGROUND_YELLOW}m"
export BOLD_BLUE="${ESCAPE}[${SET_BOLD};${FOREGROUND_BLUE}m"
export BOLD_PURPLE="${ESCAPE}[${SET_BOLD};${FOREGROUND_MAGENTA}m"
export BOLD_CYAN="${ESCAPE}[${SET_BOLD};${FOREGROUND_CYAN}m"
export BOLD_GRAY="${ESCAPE}[${SET_BOLD};${FOREGROUND_LIGHT_GRAY}m"

##########################################################
# Dim
export DIM_BLACK="${ESCAPE}[${SET_DIM};${FOREGROUND_BLACK}m"
export DIM_RED="${ESCAPE}[${SET_DIM};${FOREGROUND_RED}m"
export DIM_GREEN="${ESCAPE}[${SET_DIM};${FOREGROUND_GREEN}m"
export DIM_YELLOW="${ESCAPE}[${SET_DIM};${FOREGROUND_YELLOW}m"
export DIM_BLUE="${ESCAPE}[${SET_DIM};${FOREGROUND_BLUE}m"
export DIM_PURPLE="${ESCAPE}[${SET_DIM};${FOREGROUND_MAGENTA}m"
export DIM_CYAN="${ESCAPE}[${SET_DIM};${FOREGROUND_CYAN}m"
export DIM_GRAY="${ESCAPE}[${SET_DIM};${FOREGROUND_LIGHT_GRAY}m"

##########################################################
# No Color
export NO_COLOR="${ESCAPE}[${RESET_ALL}m"

##########################################################
# Logging text colors

export BOLD_GRAY_UNDERLINE="${ESCAPE}[${SET_BOLD};${SET_UNDERLINE};${FOREGROUND_LIGHT_GRAY}m"
export BOLD_GREEN_UNDERLINE="${ESCAPE}[${SET_BOLD};${SET_UNDERLINE};${FOREGROUND_GREEN}m"
export PURPLE_UNDERLINE="${ESCAPE}[${RESET_ALL};${SET_UNDERLINE};${FOREGROUND_MAGENTA}m"
export NO_COLOR_UNDERLINE="${ESCAPE}[${RESET_ALL};${SET_UNDERLINE}m"
set_color() {
  COLOR=$1
  echo -e "${ESCAPE}[${COLOR}m"
}

no_color() {
  echo -e  "${NO_COLOR}"
}
