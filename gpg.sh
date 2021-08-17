#!/bin/bash

set -eou pipefail

mkdir ~/gpg

# Generate master key

gpg --quick-gen-key "Andrew Rynhard <andrew@rynhard.io>" ed25519 sign 365d
export KEYID=$(gpg --list-keys --with-colons | grep "^pub:" | cut -d: -f5)
export FPR=$(gpg --list-keys --with-colons | grep "^fpr:" | cut -d: -f10)

# Generate subkeys

gpg --quick-add-key $FPR cv25519 encr 365d
gpg --quick-add-key $FPR ed25519 auth 365d
gpg --quick-add-key $FPR ed25519 sign 365d

# Generate revocation certificate

#gpg --gen-revoke andrew@rynhard.io ~/gpg/$FPR.revoke.asc

# Configure GPG

echo "default-key $FPR" >~/gpg/gpg.conf

# Test

export GPG_TTY=$(tty)
echo 'test' | gpg --clearsign

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

echo 'All keys have been successfully generated'
echo 'Copy ~/gpg to a secure offline storage device'
echo "Copy ~/gpg/gpg.conf ~/gpg/$FPR.pub.asc and ~/gpg/$FPR.ssh to a storage device to be transfered to a workstation"

