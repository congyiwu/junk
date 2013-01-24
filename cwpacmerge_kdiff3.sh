#!/bin/sh
set -eu

echo kdiff3 $usebase $theirs $1 -o $1
kdiff3 $usebase $theirs $1 -o $1
