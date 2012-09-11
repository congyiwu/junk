for x in /dev/sd?
  do
  echo "$x"
  sudo smartctl -A $x
  done
