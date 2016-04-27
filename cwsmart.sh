#!/bin/sh
set -eu

for x in /dev/sd?
  do
  echo "$x"
  sudo smartctl -A $x|grep "Temp\|Sector"
  done
