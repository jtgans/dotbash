#!/bin/bash

[ -a $HOME/.bash_profile ] && rm $HOME/.bash_profile
[ -a $HOME/.profile ] && rm $HOME/.profile
[ -a $HOME/.bashrc ] && rm $HOME/.bashrc
[ -a $HOME/.bash_logout ] && rm $HOME/.bash_logout

ln -s $HOME/.bash.d/bash_profile $HOME/.bash_profile
ln -s $HOME/.bash.d/bashrc $HOME/.bashrc

