#!/bin/bash
set -e


#
# See https://github.com/coolaj86/install-caddy-script
#

# curl -fsSL bit.ly/caddy | bash
# wget -nv bit.ly/caddy -O - | bash

# curl -fsSL https://example.com/setup-min.bash | bash
# wget -nv https://example.com/setup-min.bash -O - | bash

BASE_URL="https://raw.githubusercontent.com/coolaj86/install-caddy-script/master"
OS="unsupported"
CADDY_ARCH=""
CADDY_VER="0.7.1"
FP=""

clear

#########################
# Which OS and version? #
#########################

# NOTE `uname -m` is more accurate than `arch`
if [ -n "$(uname -m | grep 64)" ]; then
  CADDY_ARCH="amd64"
elif [ -n "$(uname -m | grep 86)" ]; then
  CADDY_ARCH="386"
elif [ -n "$(uname -m | grep armv5)" ]; then
  CADDY_ARCH="arm5"
elif [ -n "$(uname -m | grep armv6l)" ]; then
  CADDY_ARCH="arm6l"
elif [ -n "$(uname -m | grep armv7l)" ]; then
  CADDY_ARCH="arm7l"
fi

if [ "$(uname | grep -i 'Darwin')" ]; then
  CADDY_OS='darwin'
  OSX_VER="$(sw_vers | grep ProductVersion | cut -d':' -f2 | cut -f2)"
  OSX_MAJOR="$(echo ${OSX_VER} | cut -d'.' -f1)"
  OSX_MINOR="$(echo ${OSX_VER} | cut -d'.' -f2)"
  OSX_PATCH="$(echo ${OSX_VER} | cut -d'.' -f3)"

  #
  # Major
  #
  if [ "$OSX_MAJOR" -lt 10 ]; then
    echo "unsupported OS X version (os 9-)"
    exit 1
  fi

  if [ "$OSX_MAJOR" -gt 10 ]; then
    echo "unsupported OS X version (os 11+)"
    exit 1
  fi

  #
  # Minor
  #
  if [ "$OSX_MINOR" -le 5 ]; then
    echo "unsupported OS X version (os 10.5-)"
    exit 1
  fi

  # could also use uname -m
  #if [ -n "$(sysctl hw | grep 64bit | grep ': 1')" ]; then
  #  ARCH="64"
  #  CADDY_ARCH="amd64"
  #else
  #  ARCH="32"
  #  CADDY_ARCH="386"
  #fi
elif [ "$(uname | grep -i 'Linux')" ]; then
  CADDY_OS='linux'
  if [ ! -f "/etc/issue" ]; then
    echo "unsupported linux os"
    exit 1
  fi

  if [ -e "/lib/arm-linux-gnueabihf" ]; then
    CADDY_ARCH="${CADDY_ARCH}-hf"
  #elif [ -e "/lib/arm-linux-gnueabi" ]; then
  #  CADDY_ARCH="${CADDY_ARCH}-sf"
  fi

  #if [ "$(cat /etc/issue | grep -i 'Raspbian')" ]; then
    #OS='raspbian'
  #fi
elif [ "$(uname | grep -i 'FreeBSD')" ]; then
  # uname FreeBSD
  # uname -m amd64
  CADDY_OS='freebsd'
elif [ "$(uname | grep -i 'OpenBSD')" ]; then
  # UNTESTED (I don't know what is actually reported)
  CADDY_OS='openbsd'
elif [ "$(uname | grep -i 'Win')" ]; then
  # Should catch cygwin, win32, win64
  # UNTESTED (I don't know what is actually reported)
  CADDY_OS='windows'
else
  echo "unsupported unknown os (non-mac, non-linux, non-freebsd)"
  exit 1
fi


#########################
# Which caddy VERSION ? #
#########################

if [ -f "/tmp/CADDY_VER" ]; then
  CADDY_VER=$(cat /tmp/CADDY_VER | grep v)
fi

#if [ -z "$CADDY_VER" ]; then
#  # TODO grep arch
#  if [ -n "$(which curl)" ]; then
#    CADDY_VER="$(curl -fsSL https://caddyserver.com/dist/index.tab | head -2 | tail -1 | cut -f 1)" \
#      || echo 'error automatically determining current caddy version'
#  elif [ -n "$(which wget)" ]; then
#    CADDY_VER="wget --quiet https://caddyserver.com/dist/index.tab -O - | head -2 | tail -1 | cut -f 1)" \
#      || echo 'error automatically determining current caddy version'
#  else
#    echo "Found neither 'curl' nor 'wget'. Can't Continue."
#    exit 1
#  fi
#fi

#
# caddy
#
CADDY_VER="0.7.1"
CADDY_CUR_VER="$(caddy --version 2>/dev/null | cut -d ' ' -f2)"
if [ -n "${CADDY_CUR_VER}" ]; then
# caddy of some version is already installed
  echo "Backing up $(which caddy) as $(which caddy).${CADDY_CUR_VER}"
  echo ""
  sleep 1
  CADDY_PATH=$(which caddy)
  echo sudo rsync -a "$CADDY_PATH" "$CADDY_PATH.$CADDY_CUR_VER"
  sudo rsync -a "$CADDY_PATH" "$CADDY_PATH.$CADDY_CUR_VER"
  echo ""
  echo "to restore backup: sudo rsync -a '"$CADDY_PATH.$CADDY_CUR_VER"' '$CADDY_PATH'"
  echo ""
fi

# 
# https://github.com/mholt/caddy/releases/download/v0.7.1/caddy_linux_amd64.zip
if [ -n "${CADDY_VER}" ]; then
  # $CADDY_FORMAT='zip'
  CADDY_FILE="caddy_${CADDY_OS}_${CADDY_ARCH}.zip"
  CADDY_URL="https://github.com/mholt/caddy/releases/download/v${CADDY_VER}/${CADDY_FILE}"
  echo "Downloading $CADDY_URL ..."
  rm -rf "/tmp/${CADDY_FILE}"
  if [ -n "$(which curl)" ]; then
    curl -fsSL "$CADDY_URL" \
      -o /tmp/${CADDY_FILE}
  elif [ -n "$(which wget)" ]; then
    wget --quiet "$CADDY_URL" \
      -O /tmp/${CADDY_FILE}
  else
    echo "Found neither 'curl' nor 'wget'. Can't Continue."
    exit 1
  fi

  #if [ 'zip' == "$CADDY_FORMAT" ]; then
    #unzip "/tmp/$CADDY_FILE.$CADDY_FORMAT" -d /tmp/
  #elif [ 'tar.gz' == "$CADDY_FORMAT" ]; then
    #tar xvf "/tmp/$CADDY_FILE.$CADDY_FORMAT" -C /tmp/
  #fi
  if [ -n $(echo "$CADDY_FILE" | grep '.zip') ]; then
    unzip -o "/tmp/$CADDY_FILE" -d /tmp/
  elif [ -n $(echo "$CADDY_FILE" | grep '.tar.gz') ]; then
    tar xvf "/tmp/$CADDY_FILE" -C /tmp/
  fi

  #sudo chown -R $(whoami) /usr/local/
  echo "sudo mv /tmp/caddy /usr/local/bin/caddy"
  sudo mv /tmp/caddy /usr/local/bin/caddy
  
  # caddy-browse helper
  sudo rm -rf /tmp/caddy-browse
  cat <<< '#!/bin/bash
echo "0.0.0.0
browse" | caddy' > /tmp/caddy-browse
  chmod a+x /tmp/caddy-browse
  sudo mv /tmp/caddy-browse /usr/local/bin/
  # end caddy-browse
fi

echo ""
caddy --version
echo ""
