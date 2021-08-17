#!/bin/bash

set -eou pipefail

while true; do
  read -s -p "PIN: " pin
  echo
  read -s -p "PIN Confirmation: " confirmation
  echo
  [ "$pin" = "$confirmation" ] && break || echo "PINs do not match, please try again"
done

echo 'PIN confirmed'

echo 'Configuring OpenPGP'

# N.B. Fixed means that the touch policy can not be changed without doing a
#      full openpgp reset (which will delete all keys from the device).
ykman openpgp touch sig fixed --force --admin-pin $pin
ykman openpgp touch aut fixed --force --admin-pin $pin
ykman openpgp touch enc fixed --force --admin-pin $pin
ykman openpgp info

echo 'Configuring PIV'

export CURRENT_MANAGEMENT_KEY=${CURRENT_MANAGEMENT_KEY:-'010203040506070801020304050607080102030405060708'}
export CURRENT_PUK=${CURRENT_PUK:-'12345678'}
export CURRENT_PIN=${CURRENT_PIN:-'123456'}

ykman piv change-puk --puk $CURRENT_PUK --new-puk $pin
ykman piv change-pin --pin $CURRENT_PIN --new-pin $pin
ykman piv change-management-key --force --management-key $CURRENT_MANAGEMENT_KEY --generate --protect --pin $pin --touch
ykman piv info

