#!/bin/sh

PWD=$(pwd)

_die ()
{
  echo "Error: $1"
  exit 1
}

_getbin ()
{
  if ! UNZIP=$(which unzip); then
    _die "unzip binary not found in \$PATH"
  elif ! SZIP=$(which 7z); then
    _die "7z binary not found in \$PATH"
  fi
}

if [ $# -lt 1 ]; then
  _die "no argument given, must be file or directory"
fi

_getbin

while [ $# -ne 0 ]
do
  cd $1
    for zipfile in *.zip; do
      echo ======== $zipfile ========
      SZFILE=$(basename $zipfile .zip)
      mkdir $SZFILE
      cd $SZFILE
      unzip ../$zipfile
      7z a $SZFILE.7z ./*
      cd ..
      mv $SZFILE/$SZFILE.7z .
      rm -rf $SZFILE
      if [ -f ./$SZFILE.7z ]; then
        rm $zipfile
      fi
    done
  cd $PWD
  shift
done

exit 0
