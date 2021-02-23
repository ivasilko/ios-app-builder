#!/bin/sh
set -eo pipefail

PROFILE=app.mobileprovision
CERTIFICATE=app.p12

gpg --quiet --batch --yes --decrypt --passphrase="$DECRYPTION_PASS" --output ./.github/certs/$PROFILE ./.github/certs/${PROFILE}.gpg
gpg --quiet --batch --yes --decrypt --passphrase="$DECRYPTION_PASS" --output ./.github/certs/$CERTIFICATE ./.github/certs/${CERTIFICATE}.gpg

KEYCHAIN_PATH=$RUNNER_TEMP/build.keychain

security create-keychain -p "" $KEYCHAIN_PATH
security set-keychain-settings -lut 21600 $KEYCHAIN_PATH
security unlock-keychain -p "" $KEYCHAIN_PATH
security import ./.github/certs/$CERTIFICATE -P "$KEYCHAIN_EXPORT" -A -t cert -f pkcs12 -k $KEYCHAIN_PATH -T /usr/bin/codesign
security list-keychain -d user -s $KEYCHAIN_PATH
security show-keychain-info $KEYCHAIN_PATH
security set-key-partition-list -S apple-tool:,apple: -s -k "" $KEYCHAIN_PATH

mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
cp ./.github/certs/$PROFILE ~/Library/MobileDevice/Provisioning\ Profiles/$PROFILE
