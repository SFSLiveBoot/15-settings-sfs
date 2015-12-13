#!/bin/sh

test ! -d "$HOME/.local/bin" || {
  case ":$PATH:" in
    *:"$HOME/.local/bin":*) ;;
    *) export PATH="$PATH:$HOME/.local/bin" ;;
  esac
}
