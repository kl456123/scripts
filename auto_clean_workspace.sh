#!/bin/bash

# close tmux
tmux kill-server

# umout remote directory
LOCAL_TARGET_DIR=/home/breakpoint/Remote/detection
LOCAL_PASSWD=123456
echo ${LOCAL_PASSWD} | sudo -S umount -l ${LOCAL_TARGET_DIR}
