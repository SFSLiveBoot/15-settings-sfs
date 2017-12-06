#!/bin/sh

test -z "$BASH" || shopt -s histappend

HISTTIMEFORMAT="%Y%m%d %T "
HISTSIZE=50000
HISTFILESIZE=100000

test -z "$SSH_CONNECTION" ||
  case "$HISTFILE" in
    */.bash_history) HISTFILE="${HISTFILE}-${SSH_CONNECTION%% *}" ;;
  esac
