#!/usr/bin/env bash

set -euo pipefail

VAGRANT_USER="vagrant"
VAGRANT_GROUP="vagrant"

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
# Setup Vagrant user
#

# add goup
cmd="grep -c $VAGRANT_GROUP /etc/group"

# https://stackoverflow.com/questions/41078968/why-is-grep-c-with-0-count-exits-program-with-status-code-1
out=$(ssh_exec $cmd) || :

if [ "$out" == "0" ]; then
  $(ssh_exec "groupadd $VAGRANT_GROUP")
  echo "group $VAGRANT_GROUP added"
else
  echo "group $VAGRANT_GROUP exists, skipping"
fi

# add user
cmd="grep -c $VAGRANT_USER /etc/passwd"
out=$(ssh_exec $cmd) || :

if [ "$out" == "0" ]; then
  out=$(ssh_exec "useradd -m -g $VAGRANT_GROUP $VAGRANT_USER")
  echo "user $VAGRANT_USER added"
else
  echo "user $VAGRANT_USER exists, skipping"
fi

# add to sudoers
cmd="cat >/etc/sudoers.d/90-vagrant-users <<< '%$VAGRANT_GROUP   ALL=(ALL:ALL) ALL'; chmod 440 /etc/sudoers.d/90-vagrant-users"
out=$(ssh_exec $cmd)
echo "added /etc/sudoers.d/90-vagrant-users"

# add ssh public key
#cmd="curl -o- "

#
# Harden sshd
# 
