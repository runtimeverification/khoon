#!/bin/sh
set -euxo pipefail

kompile hoon.k

input="$1"
shift
python3 parser.py $input > $input.pre-parsed
krun $input.pre-parsed "$@"
