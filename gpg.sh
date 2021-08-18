#!/bin/bash

set -eou pipefail

while true; do
  read -p "Enter Name: " name
  echo
  read -p "Enter Email: " email
  echo
  [[ ! -z "$name" ]] && break || echo "Name is empty string"
  echo
  [[ ! -z "$email" ]] && break || echo "Email is empty string"
  echo
done

echo 'User info confirmed'

mkdir ~/gpg

# Generate master key

gpg --quick-gen-key "$name <$email>" ed25519 sign 365d
export KEYID=$(gpg --list-keys --with-colons $email | grep "^pub:" | cut -d: -f5)
export FPR=$(gpg --list-keys --with-colons $email | grep "^fpr:" | cut -d: -f10)

# Generate subkeys

gpg --quick-add-key $FPR cv25519 encr 365d
gpg --quick-add-key $FPR ed25519 auth 365d
gpg --quick-add-key $FPR ed25519 sign 365d

# Generate revocation certificate

gpg --generate-revocation --output ~/gpg/$FPR.revoke.asc $FPR

# Configure GPG

echo "default-key $FPR" >~/gpg/gpg.conf

# Test

export GPG_TTY=$(tty)
echo 'test' | gpg --clearsign --default-key $email

# Backup

gpg --armor --export-secret-keys $FPR > ~/gpg/$FPR.master.asc
gpg --armor --export-secret-subkeys $FPR > ~/gpg/$FPR.subkeys.asc
gpg --armor --export $FPR > ~/gpg/$FPR.pub.asc
gpg --export-ssh-key $FPR > ~/gpg/$FPR.ssh
tar -czpf ~/gpg/gnupg.tgz ~/.gnupg/

# Test

rm -rf ~/.gnupg/
mkdir ~/.gnupg/
chmod 700 ~/.gnupg/
cp ~/gpg/gpg.conf ~/.gnupg/
gpg --import ~/gpg/$FPR.master.asc ~/gpg/$FPR.subkeys.asc

echo
echo '#############################################'
echo 'All keys have been successfully generated!'
echo 'Proceed with the following:'
echo
echo 'Copy ~/gpg to a secure offline storage device'
echo
echo 'Copy the following to a secondary storage device to'
echo 'be transfered to a workstation:'
echo "  - ~/gpg/gpg.conf"
echo "  - ~/gpg/$FPR.pub.asc"
echo "  - ~/gpg/$FPR.ssh"
echo '#############################################'
