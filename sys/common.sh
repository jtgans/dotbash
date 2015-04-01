# -*- sh -*-

umask 022

export HISTCONTROL="ignoredups:erasedups"
export FULL_NAME="June Tate-Gans"
export EMAIL="june@theonelab.com"

shopt -s checkhash
shopt -s checkwinsize
shopt -s cmdhist
shopt -s extglob
shopt -s hostcomplete
shopt -s histappend

export _PROMPT_HOOKS=""
export PROMPT_COMMAND="run-hooks _PROMPT_HOOKS"
