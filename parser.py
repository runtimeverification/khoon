import sys
import re

# Replace two or more spaces or newline (gaps) with \gap
def explicit_gaps_and_aces(s):
    s = s.rstrip(" \n")
    s = re.sub(r'((  |\n)[ \n]*)', r'\\gap', s)
    return explicit_aces(s)

# Replace single spaces (aces) with \ace
def explicit_aces(s):
    return re.sub(r' ', r'\\ace', s)

# Replace dots "." with \dot
def replace_dots(s):
    return re.sub(r'\.', r'\\dot', s)

input_file = sys.argv[1]
with open(input_file) as f:
    content = f.read()
res = explicit_gaps_and_aces(content)
res = replace_dots(res)
print(res)
