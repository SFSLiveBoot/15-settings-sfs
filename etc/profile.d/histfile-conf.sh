#!/bin/sh

test -z "$BASH" || shopt -s histappend

test -z "$SSH_CONNECTION" ||
  case "$HISTFILE" in
    */.bash_history) HISTFILE="${HISTFILE}-${SSH_CONNECTION%% *}" ;;
  esac
