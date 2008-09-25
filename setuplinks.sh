#!/bin/bash

[ -f $HOME/.bash_profile ] && rm $HOME/.bash_profile
[ -f $HOME/.profile ] && rm $HOME/.profile
[ -f $HOME/.bashrc ] && rm $HOME/.bashrc
[ -f $HOME/.bash_logout ] && rm $HOME/.bash_logout

ln -s bash_profile ../.bash_profile
ln -s bashrc ../.bashrc

