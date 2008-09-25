#!/bin/bash

[ -f $HOME/.bash_profile ] && rm $HOME/.bash_profile
[ -f $HOME/.profile ] && rm $HOME/.profile
[ -f $HOME/.bashrc ] && rm $HOME/.bashrc

ln -s bash_profile ../.bash_profile
ln -s bashrc ../.bashrc

