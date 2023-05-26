import re
import sys


# Remove all spaces and replace aces with spaces
def pretty_spaces(s: str) -> str:
    s = re.sub(r'\\gap| ', '', s)
    s = re.sub(r'\\ace', ' ', s)
    return s


# Replace all '\dot' with '.'
def pretty_dots(s: str) -> str:
    s = re.sub(r'\\dot', '.', s)
    return s


# Get the value of the k cell
def get_k_res(s: str) -> str:
    lines = s.splitlines()
    i = lines.index('<k>') + 1
    return lines[i][:-3]  # remove ending '~>.'


# Extract the noun from the meta noun
def strip_meta_info(s: str) -> str:
    i = s.find(',')
    if i == -1:
        return s
    else:
        return s[i + 1 : -1]


input_file = sys.argv[1]
with open(input_file) as f:
    content = f.read()
res = pretty_spaces(content)
res = pretty_dots(res)
res = get_k_res(res)
res = strip_meta_info(res)
print(res)
