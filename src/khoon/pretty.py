import re
import sys


def pretty(text: str) -> str:
    res = _pretty_spaces(text)
    res = _pretty_dots(res)
    res = _get_k_res(res)
    res = _strip_meta_info(res)
    return res


# Remove all spaces and replace aces with spaces
def _pretty_spaces(s: str) -> str:
    s = re.sub(r'\\gap| ', '', s)
    s = re.sub(r'\\ace', ' ', s)
    return s


# Replace all '\dot' with '.'
def _pretty_dots(s: str) -> str:
    s = re.sub(r'\\dot', '.', s)
    return s


# Get the value of the k cell
def _get_k_res(s: str) -> str:
    lines = s.splitlines()
    i = lines.index('<k>') + 1
    return lines[i][:-3]  # remove ending '~>.'


# Extract the noun from the meta noun
def _strip_meta_info(s: str) -> str:
    i = s.find(',')
    if i == -1:
        return s
    else:
        return s[i + 1 : -1]


if __name__ == '__main__':
    input_file = sys.argv[1]
    with open(input_file) as f:
        text = f.read()
    res = pretty(text)
    print(res)
