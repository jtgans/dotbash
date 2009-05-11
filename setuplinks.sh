#!/bin/bash

[ -f $HOME/.bash_profile ] && rm $HOME/.bash_profile
[ -f $HOME/.profile ] && rm $HOME/.profile
[ -f $HOME/.bashrc ] && rm $HOME/.bashrc
[ -f $HOME/.bash_logout ] && rm $HOME/.bash_logout

ln -s $HOME/.bash.d/bash_profile $HOME/.bash_profile
ln -s $HOME/.bash.d/bashrc $HOME/.bashrc

