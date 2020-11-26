#!/bin/sh


# runCmd prints the given command and runs it.
runCmd() {
  (set -x; $@)
}


# Execution

set -e

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
