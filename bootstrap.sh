#!/usr/bin/env bash

set -euo pipefail

# configurable params
ANSIBLE_USER="ansible"
ANSIBLE_GROUP="ansible"
ANSIBLE_PUBKEY_URI="https://raw.githubusercontent.com/karolistamutis/meta/master/pubkeys/ansible.pub"
SSHD_CONFIG_URI="https://raw.githubusercontent.com/karolistamutis/meta/master/configs/sshd_config"


err_report() {
  echo "Exited with error on line $1"
}
trap 'err_report $LINENO' ERR

fatal () {
  echo "$*" >&2
  exit 1
}

USAGE="Usage: $0 hostname_to_bootstrap"

if [ "$#" == "0" ]; then
  echo "$USAGE"
  exit 1
fi

BOOTHOST=$1

echo -n "Checking passwordless ssh works ... "
cmd="ssh -n -o PasswordAuthentication=no $BOOTHOST hostname 2>&1"
out="`$cmd`"
if [ "$out" != "$BOOTHOST" ]; then
  echo
  fatal "$cmd returned [$out] not $BOOTHOST; aborting."
else
  echo "yep - good!"
fi

# Setup a multiplexed SSH socket
ssh_cmd="ssh -oControlMaster=yes -oLogLevel=QUIET -oControlPath=~/.ssh/ssh-%r-%h-%p $BOOTHOST"

ssh_file_exists() {
  $ssh_cmd -t "test -e $1"
}

ssh_exec () {
  $ssh_cmd -t "$@" 2>&1
}

#
# Setup Ansible user
#

# add goup
cmd="grep -c $ANSIBLE_GROUP /etc/group|tr -d '\n'"

# https://stackoverflow.com/questions/41078968/why-is-grep-c-with-0-count-exits-program-with-status-code-1
out=$(ssh_exec $cmd) || :

if [ "$out" == "0" ]; then
  $(ssh_exec "groupadd $ANSIBLE_GROUP")
  echo "group $ANSIBLE_GROUP added"
else
  echo "group $ANSIBLE_GROUP exists, skipping"
fi

# add user
cmd="grep -c $ANSIBLE_USER /etc/passwd|tr -d '\n'"
out=$(ssh_exec $cmd) || :

if [ "$out" == "0" ]; then
  out=$(ssh_exec "useradd -m -g $ANSIBLE_GROUP $ANSIBLE_USER")
  echo "user $ANSIBLE_USER added"

  # set password and unlock account
  out=$(ssh_exec "usermod -p `openssl rand -hex 8` $ANSIBLE_USER")
else
  echo "user $ANSIBLE_USER exists, skipping"
fi

# add to sudoers
if ! ssh_file_exists "/etc/sudoers.d/90-$ANSIBLE_USER-users"; then
  cmd="cat >/etc/sudoers.d/90-$ANSIBLE_USER-users <<< '%$ANSIBLE_GROUP   ALL=(ALL:ALL) ALL'; chmod 440 /etc/sudoers.d/90-$ANSIBLE_USER-users"
  out=$(ssh_exec $cmd)
  echo "added /etc/sudoers.d/90-$ANSIBLE_USER-users"
else
  echo "/etc/sudoers.d/90-$ANSIBLE_USER-users exists, skipping"
fi

# add ssh public key
if ! ssh_file_exists "/home/$ANSIBLE_USER/.ssh/authorized_keys"; then
  cmd="mkdir -p /home/$ANSIBLE_USER/.ssh && curl $ANSIBLE_PUBKEY_URI > /home/$ANSIBLE_USER/.ssh/authorized_keys"
  out=$(ssh_exec $cmd)
  echo "added $ANSIBLE_USER public key to ssh auth"
else
  echo "/home/$ANSIBLE_USER/.ssh/authorized_keys exists, skipping"
fi

#
# Harden sshd
# 

new_ssh_conf_md5=$(ssh_exec "curl -so- $SSHD_CONFIG_URI|sed 's/ALLOW_USERS/$ANSIBLE_USER/'|md5sum|cut -d' ' -f1")
old_ssh_conf_md5=$(ssh_exec "md5sum /etc/ssh/sshd_config|cut -d' ' -f1")

if [ "$new_ssh_conf_md5" != "$old_ssh_conf_md5" ]; then
  cmd="cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup && curl -so- $SSHD_CONFIG_URI|sed 's/ALLOW_USERS/$ANSIBLE_USER/'>/etc/ssh/sshd_config"
  out=$(ssh_exec $cmd)
  echo "updated /etc/ssh/sshd_config"

  # restart sshd
  cmd="systemctl restart ssh"
  out=$(ssh_exec $cmd)
  echo "restarted sshd"
else
  echo "/etc/ssh/sshd_config was already up to date, skipping"
fi