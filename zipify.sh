#!/bin/sh

# the working directory
PWD=$(pwd)

# if error, exit 1
_die ()
{
  echo "Error: $1"
  exit 1
}

_skip ()
{
  echo "Skipping: $1"
}

# find the necessary binaries, unzip and 7z must be in $PATH
_getbin ()
{
  if ! UNZIP=$(which unzip); then
    _die "unzip binary not found in \$PATH"
  elif ! SZIP=$(which 7z); then
    _die "7z binary not found in \$PATH"
  fi
}

# extract zip contents and then add them to 7z archive
_zipify ()
{
  if $(file -i "$1" | grep -q 'application/zip'); then
    SZFILE=$(basename "$1" .zip).7z
    mkdir "$1.dir" && cd "$1.dir"
    $UNZIP ../"$1"
    $SZIP a "$SZFILE" ./*
    mv "$SZFILE" .. 
    cd .. && rm -rf "$1.dir"
    if [ -f ./"$SZFILE" ]; then
      rm "$1"
    fi
  else
    _skip "$1 is not a zip file"
  fi
}

# main loop
if [ $# -lt 1 ]; then
  _die "no argument given, must be file or directory"
fi

_getbin

while [ $# -ne 0 ]; do
  if [ -d "$1" ]; then
    cd "$1"
      for ZIPFILE in ./*; do
        _zipify "$ZIPFILE"
      done
    cd "$PWD"
  elif [ -f "$1" ]; then
    cd $(dirname "$1")
    ZIPFILE=$(basename "$1")
    _zipify "$ZIPFILE"
    cd "$PWD"
  else
    _die "$1 does not exist"
  fi
  shift
done

exit 0
