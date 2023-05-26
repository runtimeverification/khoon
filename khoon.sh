#!/bin/sh
#set -euxo pipefail

#kompile hoon.k

input="$1"
shift
python3 -m khoon.parser $input > $input.pre-parsed
krun $input.pre-parsed "$@" > $input.pre-pretty
if [ $? -ne 0 ]
then
    rm $input.pre-parsed $input.pre-pretty
    exit 1
else
output=$(python3 -m khoon.pretty $input.pre-pretty)
fi
rm $input.pre-parsed $input.pre-pretty
echo $output
