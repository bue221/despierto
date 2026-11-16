#!/bin/zsh
# Compila Despierto.app. Uso: ./build.sh
set -e
cd "$(dirname "$0")"

APP="build/Despierto.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"

cp Info.plist "$APP/Contents/Info.plist"
swiftc -O -swift-version 5 -target "$(uname -m)-apple-macos13" \
  main.swift -o "$APP/Contents/MacOS/Despierto"

codesign --force --sign - "$APP" >/dev/null 2>&1
echo "✅ Listo: $PWD/$APP"
