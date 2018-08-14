#!/usr/bin/env bash

detect_os() {
  echo -n "Detecting OS type... "
  case "$OSTYPE" in
    solaris*) echo "SOLARIS - Unsupported!"; return 1 ;;
    darwin*)  echo "OSX - Unsupported!"; return 1 ;; 
    linux*)   echo "LINUX" ;;
    bsd*)     echo "BSD - Unsupported!"; return 1 ;;
    msys*)    echo "WINDOWS - Unsupported!"; return 1 ;;
    *)        echo "unknown - Unsupported: $OSTYPE" ;;
  esac
}

detect_distro() {
  # Based on https://unix.stackexchange.com/a/6348
  echo -n "Attempting to detect the distro and version "
  if [ -f /etc/os-release ]; then # freedesktop.org and systemd
    echo -n "using /etc/os-release... "
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
  elif type lsb_release >/dev/null 2>&1; then # linuxbase.org
    echo -n "using lsb_release... "
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
  elif [ -f /etc/lsb-release ]; then # some versions of Debian/Ubuntu without lsb_release command
    echo -n "using /etc/lsb-release... "
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
  elif [ -f /etc/debian_version ]; then # Older Debian/Ubuntu/etc.
    echo -n "using /etc/debian_version... "
    OS=Debian
    VER=$(cat /etc/debian_version)
  elif [ -f /etc/SuSe-release ]; then # Older SuSE/etc.
    echo -n "using /etc/SuSe-release... "
    echo -n "Unsupported!"
    return 1
  elif [ -f /etc/redhat-release ]; then # Older Red Hat, CentOS, etc.
    echo -n "using /etc/redhat-release... "
    echo -n "Unsupported!"
    return 1
  else # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    echo -n "using uname... "
    OS=$(uname -s)
    VER=$(uname -r)
  fi
  echo "$OS $VER"
}

check_min_distro_version() {
  # Based on https://stackoverflow.com/a/19912649
  echo "Checking minimum distro version... "
  case "$OS" in
    Debian*) local minver="7.7" ;;
    Ubuntu*) local minver="14.04" ;;
    CentOS*) local minver="7" ;;
    *)        
      echo "unknown: $OS is not supported. Stopping."
      return 1 
      ;;
  esac
  echo -n "Requires at least $OS $minver... "
  if awk 'BEGIN{exit ARGV[1]>ARGV[2]}' "$VER" "$minver"; then
    echo "Stopping."
    return 1
  else 
    echo "OK!"
  fi
}

main() {
  detect_os
  detect_distro
  check_min_distro_version
}

main
