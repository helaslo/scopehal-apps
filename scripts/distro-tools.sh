#!/usr/bin/env bash

#Error handling is done according to https://dougrichardson.us/notes/fail-fast-bash-scripting

set -euo pipefail
shopt -s inherit_errexit

#Used to auto-escalate to superuser if sudo binary is present
COMMAND_EXECUTOR=""

if command -v sudo >/dev/null 2>&1
then
  export COMMAND_EXECUTOR="sudo"
fi

usage() {
  echo ""
  echo "Script usage:"
  echo ""
  echo "$0 install-build-deps"
  printf "\t install dependencies absolutely required to build the project\n"
  echo "$0 install-test-dependencies"
  printf "\t install dependencies required for some unit test, which may include some GPL code\n"
  echo "$0 install-documentation-dependencies"
  printf "\t install dependencies required for building the included documentation\n"
}

if [[ -v DISTRO_LSB_ID ]]; then
  CURRENT_DISTRO="$DISTRO_LSB_ID"
  else
  if command -v lsb_release >/dev/null 2>&1; then
    CURRENT_DISTRO=$(lsb_release -si)
  else
      echo "lsb_release can't be found, and \$DISTRO_LSB_ID isn't set, can't autodetect distribution"
      echo "Please either install lsb_release, or set \$DISTRO_LSB_ID"
      exit 1
  fi
fi



echo "Detected distribution is $CURRENT_DISTRO"

#Taken from https://stackoverflow.com/a/246128
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

HELPER_FILE_NAME="$SCRIPT_DIR/helpers/setup-system/helper-$CURRENT_DISTRO.sh"

if [ ! -f "$HELPER_FILE_NAME" ]; then
    echo "There is no distro helper yet for your distribution ($CURRENT_DISTRO)"
    exit 1
fi

source "$HELPER_FILE_NAME"

if [ $# -lt 1 ]; then
  echo "Script ran without arguments, please specify one"
  usage
  exit 1
fi

case "$1" in

  "install-build-deps")
    install_build_deps
    ;;

  "install-test-dependencies")
    install_test_dependencies
    ;;

  *)
    echo "Unknown command"
    usage
    ;;
esac


