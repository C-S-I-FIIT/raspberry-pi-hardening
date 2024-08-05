#!/bin/bash

ssh_stat=$( sudo systemctl is-active ssh.service )
sshd_stat=$( sudo systemctl is-active sshd.service )
log_path="/var/log/ssh_restarter.log"

if [ ! -f "$log_path" ]; then
  touch "$log_path"
fi

if [ "$ssh_stat" != "active" ]; then
  sudo systemctl restart ssh.service
  echo "[INFO]" $(date -u) "SSH RESTARTED" >> $log_path
  echo "------------------------" >> $log_path
fi

if [ "$sshd_stat" != "active" ]; then
  sudo systemctl restart sshd.service
  echo "[INFO]" $(date -u) "SSHD RESTARTED" >> $log_path
  echo "------------------------" >> $log_path
fi
