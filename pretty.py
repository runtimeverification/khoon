import sys
import re

# Remove all spaces and replace aces with spaces
def pretty_spaces(s):
    s = re.sub(r' ', "", s)
    s = re.sub(r'\\ace', " ", s)
    return s

# Replace all "\dot" with "."
def pretty_dots(s):
    s = re.sub(r'\\dot', "\.", s)
    return s

# Get the value of the k cell
def get_k_res(s):
    lines = s.splitlines()
    i = lines.index("<k>") + 1
    return lines[i][:-3] # remove ending "~>."

input_file = sys.argv[1]
with open(input_file) as f:
    content = f.read()
res = pretty_spaces(content)
res = pretty_dots(res)
res = get_k_res(res)
print(res)
