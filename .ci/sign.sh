#!/usr/bin/env bash
set -euo pipefail

BT="${ANDROID_HOME}/build-tools/37.0.0"
KS_P12="${RUNNER_TEMP}/release.p12"
PASS="android"
ALIAS="pixel9proims"

base64 -d .ci/keystore.b64 > "$KS_P12"

UNSIGNED=$(find app/build/outputs/apk/release -name '*.apk' | head -1)
echo "agp output: $UNSIGNED"
ls -l "$UNSIGNED"

cp "$UNSIGNED" app-unsigned.apk
"$BT/zipalign" -f -p 4 app-unsigned.apk app-aligned.apk
"$BT/apksigner" sign --ks "$KS_P12" --ks-type PKCS12 --ks-pass "pass:$PASS" --key-pass "pass:$PASS" --ks-key-alias "$ALIAS" --v1-signing-enabled true --v2-signing-enabled true --out app-release.apk app-aligned.apk

echo "--- signer ---"
"$BT/apksigner" verify --print-certs app-release.apk | head -6
ls -l app-release.apk
