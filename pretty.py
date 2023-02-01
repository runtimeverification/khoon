import sys
import re

# Remove all spaces and replace aces with spaces
def pretty_spaces(s):
    s = re.sub(r' ', "", s)
    s = re.sub(r'\\ace', " ", s)
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
res = get_k_res(res)
print(res)
