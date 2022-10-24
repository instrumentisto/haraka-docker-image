#!/bin/sh


# runCmd prints the given command and runs it.
runCmd() {
  (set -x; $@)
}


# Execution

set -e

# Install APK (Alpine Package Keeper) packages if required.
if [ ! -z "$APK_INSTALL_PACKAGES" ]; then
  packages="$(echo $APK_INSTALL_PACKAGES | sed 's/,/ /g')"
  runCmd apk add --update $packages

  rm -rf /var/cache/apk/*
fi

# Specify actual hostname.
echo "$HOSTNAME" > /etc/haraka/config/me

# Install plugins from NPM if required.
if [ ! -z "$HARAKA_INSTALL_PLUGINS" ]; then
  currDir="$(pwd)"
  cd "$HARAKA_HOME"

  plugins="$(echo $HARAKA_INSTALL_PLUGINS | sed 's/,/ /g')"
  runCmd npm install $plugins

  cd "$currDir"
fi

case "$1" in
  -*) exec /usr/local/bin/haraka "$@" ;;
  *) exec "$@" ;;
esac
