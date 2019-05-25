#!/bin/bash

REMOTE_IP=10.10.99.113
PASSWD="abcd1234!" # remote password
REMOTE_USER=liang
REMOTE_TARGET_DIR=/data/liangxiong/detection
LOCAL_TARGET_DIR=/home/breakpoint/Remote/detection
ENV_ACT=/data/liangxiong/environments/pytorch1.0_cu10/bin/activate


#################################
# mount all remote directories
#################################
SSH_COMMAND="sshpass -p ${PASSWD} ssh"
sshfs -o ssh_command="${SSH_COMMAND}" ${REMOTE_USER}@${REMOTE_IP}:${REMOTE_TARGET_DIR} ${LOCAL_TARGET_DIR}


#################################
# setup tmux
#################################

session="detection"
tmux start-server

# local
tmux new-session -d -s ${session}_local -n scripts "cd ${LOCAL_TARGET_DIR};vim scripts/run.sh"
tmux new-window -a -t ${session}_local -n config "cd ${LOCAL_TARGET_DIR};vim utils/generate_config.py"
tmux new-window -a -t ${session}_local -n model "cd ${LOCAL_TARGET_DIR};vim models/detectors/fpn_corners_model.py"

# remote
# TODO(convert to loop format)
tmux new-session -d -s ${session}_remote -n run "sshpass -p ${PASSWD} ssh -t ${REMOTE_USER}@${REMOTE_IP} 'bash -l'"
tmux selectp -t 1
tmux send-keys "cd ${REMOTE_TARGET_DIR}; source ${ENV_ACT}" C-m
tmux new-window -a -t ${session}_remote -n test "sshpass -p ${PASSWD} ssh -t ${REMOTE_USER}@${REMOTE_IP} 'bash -l'"
tmux selectp -t 2
tmux send-keys "cd ${REMOTE_TARGET_DIR}; source ${ENV_ACT}" C-m
tmux new-window -a -t ${session}_remote -n visualization "sshpass -p ${PASSWD} ssh -t ${REMOTE_USER}@${REMOTE_IP} 'bash -l'"
tmux selectp -t 3
tmux send-keys "cd ${REMOTE_TARGET_DIR}; source ${ENV_ACT}" C-m

# detach
tmux attach-session -t ${session}_remote
