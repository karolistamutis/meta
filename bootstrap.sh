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

boothost=$1

echo -n "Checking passwordless ssh works ... "
cmd="ssh -n -o PasswordAuthentication=no $boothost hostname 2>&1"
out="`$cmd`"
if [ "$out" != "$boothost" ]; then
  echo
  fatal "$cmd returned [$out] not $boothost; aborting."
else
  echo "yep - good!"
fi

# Setup a multiplexed SSH socket
ssh_cmd="ssh -oControlMaster=yes -oControlPath=~/.ssh/ssh-%r-%h-%p $boothost"

ssh_exec () {
  $ssh_cmd -t "$@" 2>&1
}

#
# Setup Ansible user
#

# add goup
cmd="grep -c $ANSIBLE_GROUP /etc/group"

# https://stackoverflow.com/questions/41078968/why-is-grep-c-with-0-count-exits-program-with-status-code-1
out=$(ssh_exec $cmd) || :

if [ "$out" == "0" ]; then
  $(ssh_exec "groupadd $ANSIBLE_GROUP")
  echo "group $ANSIBLE_GROUP added"
else
  echo "group $ANSIBLE_GROUP exists, skipping"
fi

# add user
cmd="grep -c $ANSIBLE_USER /etc/passwd"
out=$(ssh_exec $cmd) || :

if [ "$out" == "0" ]; then
  out=$(ssh_exec "useradd -m -g $ANSIBLE_GROUP $ANSIBLE_USER")
  echo "user $VAGRANT_USER added"
else
  echo "user $VAGRANT_USER exists, skipping"
fi

# add to sudoers
cmd="cat >/etc/sudoers.d/90-ansible-users <<< '%$ANSIBLE_GROUP   ALL=(ALL:ALL) ALL'; chmod 440 /etc/sudoers.d/90-ansible-users"
out=$(ssh_exec $cmd)
echo "added /etc/sudoers.d/90-ansible-users"

# add ssh public key
cmd="mkdir -p /home/$ANSIBLE_USER/.ssh && curl $ANSIBLE_PUBKEY_URI > /home/$ANSIBLE_USER/.ssh/authorized_keys"
out=$(ssh_exec $cmd)
echo "added $ANSIBLE_USER public key to ssh auth"

#
# Harden sshd
# 

cmd="cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup && curl -so- $SSHD_CONFIG_URI|sed 's/ALLOW_USERS/$ANSIBLE_USER/'>/etc/ssh/sshd_config"
out=$(ssh_exec $cmd)
echo "updated /etc/ssh/sshd_config"

# restart sshd
cmd="systemctl restart ssh"
out=$(ssh_exec $cmd)
echo "restarted sshd"