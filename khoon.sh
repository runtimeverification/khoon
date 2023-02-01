#!/bin/sh
set -euxo pipefail

kompile hoon.k

input="$1"
shift
python3 parser.py $input > $input.pre-parsed
krun $input.pre-parsed "$@" > $input.pre-pretty
output=$(python3 pretty.py $input.pre-pretty)
rm $input.pre-parsed $input.pre-pretty
echo $output
