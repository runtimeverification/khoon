import re
import sys


def parse(text: str) -> str:
    res = _replace_dots(text)
    res = _explicit_gaps_and_aces(res)
    return res


# Replace '.' with '\dot' if it refers to the current subject
def _replace_dots(s: str) -> str:
    dots_to_keep = re.findall(
        r'([0-9]\.)|(\.[0-9])|([%]\.[yn])|(\.[=])|([a-z]\.)|(\.[a-z])|(\|\.)|(\.\+)|([\+\-><]\.)', s
    )
    for tup in dots_to_keep:
        match = ''.join(tup)
        new = match.replace('.', '\\tmpdot')
        s = s.replace(match, new, 1)
    dot_sequences = re.findall(r'\.{2,}', s)
    for dot_sequence in dot_sequences:
        new = _alt_subst(dot_sequence, '\\tmpdot')
        s = s.replace(dot_sequence, new, 1)
    s = s.replace('.', '\\dot')
    s = s.replace('\\tmpdot', '.')
    return s


# Substitute every other character in s1 with s2
def _alt_subst(s1: str, s2: str) -> str:
    new = []
    for i in range(0, len(s1)):
        if i % 2:
            new.append(s2)
        else:
            new.append(s1[i])
    return ''.join(new)


# Replace two or more spaces or newline (gaps) with \gap
def _explicit_gaps_and_aces(s: str) -> str:
    s = s.rstrip(' \n')
    s = re.sub(r'((  |\n)[ \n]*)', r'\\gap', s)
    return _explicit_aces(s)


# Replace single spaces (aces) with \ace
def _explicit_aces(s: str) -> str:
    return re.sub(r' ', r'\\ace', s)


if __name__ == '__main__':
    input_file = sys.argv[1]
    with open(input_file) as f:
        text = f.read()
    res = parse(text)
    print(res)
