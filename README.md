## Setup GPG

### Airgap

```bash
gpg.sh
```

```bash
gpg --card-status
gpg --card-edit
admin
passwd
name
sex
lang
login
list
```

```bash
gpg --edit-key $FPR
toggle
key 1
keytocard
key 1
key 2
keytocard
key 2
key 3
keytocard
save
```

> Note: Running `keytocard` will move secret keys off of the local machine and onto the card.
> The subkeys will need to be imported again in order to use `keytocard` on another YubiKey.

## Setup YubiKey

### Airgap

```bash
yubikey.sh
```

## Setup Workstation

### YubiKey

1. In YubiKey Manager, click Applications > PIV
2. Click Setup for macOS
3. Click Setup for macOS. If you chose Protect with PIN when setting the Management Key, enter your PIN in the prompt. If you set a custom Management Key and did not protect with PIN, enter the Management Key in the prompt.
4. Click OK.
5. Remove your YubiKey and plug it into the USB port
6. In the SmartCard Pairing macOS prompt, click Pair. Note: If this prompt doesn't appear, see the Troubleshooting and Additional Topics section below.
7. In the password prompt, enter the password for the user account listed in the User Name field and click Pair
8. In the SmartCard Pairing prompt, enter the PIN for your YubiKey (refer to the Setting a new PIN section above) and click OK
9. In the "login" keychain prompt, enter your keychain password (typically the password for the logged in user account) and click OK
10. To test the configuration, lock your Mac (Ctrl+Command+Q), and make sure the password field reads PIN when your YubiKey is inserted. Try unlocking your session with your YubiKey by entering your PIN.

```bash
sudo defaults write /Library/Preferences/com.apple.security.smartcard enforceSmartCard -bool true
```

### GPG

```bash
brew install gnupg pinentry-mac
```

Disable storing OpenPGP passwords in macOS keychain:

```bash
defaults write org.gpgtools.common DisableKeychain -bool yes
```

This isn't required with the YubiKey, but we set it out of an abundance of caution.

```bash
gpg --import-key $FPR.pub.asc
gpg --edit-key $FPR
gpg> trust (ultimate)
gpg> quit
```

```bash
killall gpg-agent
echo "test" | gpg --clearsign
```

```bash
gpg --keyserver hkps://keys.openpgp.org --send-key YOUR_KEY_ID
gpg --keyserver hkps.pool.sks-keyservers.net  --send-key YOUR_KEY_ID
gpg --keyserver pgpkeys.urown.net --send-key YOUR_KEY_ID
gpg --keyserver keyserver.ubuntu.com --send-key YOUR_KEY_ID
```

```bash
cat >~/.gnupg/gpg.conf <<EOF
default-key $FPR
EOF
```

```bash
cat >~/.gnupg/gpg-agent.conf <<EOF
default-cache-ttl 43200
max-cache-ttl 86400

enable-ssh-support
default-cache-ttl-ssh 43200
max-cache-ttl-ssh 86400

pinentry-program /opt/homebrew/bin/pinentry-mac
EOF
```

```bash
cat >~/.zshrc <<EOF
export "SSH_AUTH_SOCK=\${HOME}/.gnupg/S.gpg-agent.ssh"
EOF
source ~/.zshrc
```

You should see your SSH key with `ssh-add -L`.

## References

- https://wiki.debian.org/InstallingDebianOn/HP/Chromebook%2014
- https://www.youtube.com/watch?time_continue=74&v=UWXO61_v_xo&feature=emb_logo
- https://www.straybits.org/post/2018/gpg-yubikey5#generating-gpg-keys
- https://support.yubico.com/hc/en-us/articles/360016614940-YubiKey-Manager-CLI-ykman-User-Manual
- https://support.yubico.com/hc/en-us/articles/360016649059-Using-Your-YubiKey-as-a-Smart-Card-in-macOS
- https://developers.yubico.com/PGP/Card_edit.html
- https://support.apple.com/en-us/HT208372
- https://support.apple.com/guide/deployment-reference-macos/configuring-macos-smart-cardonly-apdd3d1cd57d/1/web/1.0
- https://support.apple.com/guide/deployment-reference-macos/advanced-smart-card-options-apd2969ad2d7/1/web/1.0
- https://support.apple.com/guide/deployment-reference-macos/using-a-smart-card-in-macos-apd4ff986f6a/web
- https://www.stigviewer.com/stig/apple_macos_11_big_sur/2020-11-27/
