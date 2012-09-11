#!/bin/sh
export theirs
export usebase

sudo updatedb
allPacnew=$(locate "*.pacnew")

for theirs in $allPacnew; do
  yours=${theirs%.pacnew}
  base=${yours}.cworig

  if [ ! -f $yours ] || [ ! -f $theirs ]; then
    echo $yours or $theirs is missing
  else
    [ -f $base ] && usebase=$base || usebase=
      if VISUAL=/home/congyiwu/bin/cwpacmerge_kdiff3.sh sudoedit $yours; then
      sudo mv -i $theirs $base
    fi
  fi
done
