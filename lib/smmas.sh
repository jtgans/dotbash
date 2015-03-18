# -*- sh -*-
#
# sudo make me a sandwich!

smmas()
{
	history -w
	sudo $(cat $HISTFILE |grep -ve '^#' |tail -n 2 |head -n 1)
}

