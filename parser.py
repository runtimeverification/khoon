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

# Replace '.' with '\dot' if it refers to the current subject
def replace_dots(s):
    dots_to_keep = re.findall(r'([0-9]\.)|(\.[0-9])|([%]\.[yn])|(\.[=])|([a-z]\.[a-z])', s)
    for tup in dots_to_keep:
        match = ''.join(tup)
        new = match.replace(".", "\\tmpdot")
        s = s.replace(match, new, 1)
    dot_sequences = re.findall(r'\.{2,}', s)
    for dot_sequence in dot_sequences:
        new = alt_subst(dot_sequence, "\\tmpdot")
        s = s.replace(dot_sequence, new, 1)
    s = s.replace(".", "\\dot")
    s = s.replace("\\tmpdot", ".")
    return s

# Substitute every other character in s1 with s2
def alt_subst(s1, s2):
    new = []
    for i in range(0, len(s1)):
        if i % 2:
            new.append(s2)
        else:
            new.append(s1[i])
    return ''.join(new)

input_file = sys.argv[1]
with open(input_file) as f:
    content = f.read()
res = explicit_gaps_and_aces(content)
res = replace_dots(res)
print(res)
