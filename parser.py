import sys
import re

# Replace single spaces (aces) with spade suit ♠️
# Decoded version is used ("\u2660") due to lack of support in K
def explicit_aces(s):
    matches = re.findall(r'[^ ] [^ ]', s)
    for m in matches:
        ace = m.replace(" ", "\\u2660")
        s = s.replace(m, ace, 1)
    return s

input_file = sys.argv[1]
with open(input_file) as f:
    content = f.read()
res = explicit_aces(content)
print(res)
