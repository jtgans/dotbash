#!/bin/bash

[ -z $(which git) ] && echo "git not available." && exit 1

ln -s /media/private Private
mkdir Documents Downloads Code Projects SDKs chroots www

git clone git://git.theonelab.com/dotemacs.git .emacs.d
git clone git://git.theonelab.com/dotbash.git .bash.d
git clone git://git.theonelab.com/dotfiles.git .dotfiles

source .bash.d/setuplinks.sh
source .dotfiles/setuplinks.sh
