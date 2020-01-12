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
  if ! UNZIP=$(command -v unzip); then
    _die "unzip binary not found in \$PATH"
  elif ! SZIP=$(command -v 7z); then
    _die "7z binary not found in \$PATH"
  elif ! ZIP=$(command -v zip); then
    _die "zip binary not found in \$PATH"
  fi
}

# extract zip contents and then add them to 7z archive
_zipify ()
{
  echo ======== "$1" ========
  if $(file -i "$1" | grep -q 'application/zip'); then
    NEWFILE=$(basename "$1" .zip).7z
    mkdir "$1.dir" && cd "$1.dir"
    $UNZIP -q ../"$1"
    $SZIP a -sdel "$NEWFILE" ./*
    mv "$NEWFILE" ..
    cd .. && rmdir "$1.dir"
    if [ -f ./"$NEWFILE" ]; then
      rm "$1"
    fi
  elif $(file -i "$1" | grep -q 'application/x-7z-compressed'); then
    NEWFILE=$(basename "$1" .7z).zip
    mkdir "$1.dir" && cd "$1.dir"
    $SZIP x ../"$1"
    $ZIP -r "$NEWFILE" ./*
    mv "$NEWFILE" ..
    cd .. && rmdir "$1.dir"
    if [ -f ./"$NEWFILE" ]; then
      rm "$1"
    fi
  else
    _skip "$1 is not a zip nor a 7z file"
  fi
}

# main loop
if [ $# -lt 1 ]; then
  _die "no argument given, must be file or directory"
else
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
fi
exit 0
