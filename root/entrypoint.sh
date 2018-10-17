#!/bin/bash

export LANG="en_US.UTF-8"  
export LANGUAGE="en_US:en" 
export LC_ALL="en_US.UTF-8"

if [ -z "$ANKI_USER" ]; then
  echo "Please set the environment variable ANKI_USER"
  exit 1
fi

if [ -z "$ANKI_PASSWORD" ]; then
  echo "Please set the environment variable ANKI_PASSWORD"
  exit 1
fi

echo -e "$ANKI_PASSWORD\n" | python3 /srv/ankisyncctl.py adduser "$ANKI_USER"

python3 -m ankisyncd
