# ~/.bashrc: executed by bash(1) for non-login shells.

# Change default prompt to different value from /etc/profile
PS1='${debian_chroot:+($debian_chroot)}\[\033]0;\u@\h:\w\007\]\[\033[01;31m\]\h\[\033[01;34m\] \w \$\[\033[00m\] '

test ! -e /etc/profile.d/zz-ps1-exit-status.sh || . /etc/profile.d/zz-ps1-exit-status.sh

umask 022

# You may comment the following lines if you do not want `ls' to be colorized:
export LS_OPTIONS='--color=auto'
eval "$(dircolors)"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'

# Some more alias to avoid making mistakes:
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
