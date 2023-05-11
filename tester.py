import os
from enum import Enum
from subprocess import run

class TestKind(Enum):
    GOOD = 0
    BAD = 1

def test(path, kind):
    f = None
    match kind:
        case TestKind.GOOD:
            f = test_good
        case TestKind.BAD:
            f = test_bad
    total = 0
    passed = 0
    files = os.listdir(path)
    for file in files:
        if file.endswith(".hoon"):
            total += 1
            location = path + file
            ok, actual, expected, err = f(location)
            if ok:
                passed += 1
            else:
                error = err.decode().partition('\n')[0]
                print("[BAD] " + location + (" : " + error if error else ""))
                print("Actual:   " + actual)
                print("Expected: " + expected + "\n")
    return passed, total

def test_good(location):
    p = run(["./khoon.sh", location], capture_output=True)
    actual = p.stdout.decode()
    expected = open(location + ".output").read()
    return actual == expected, actual.rstrip('\n'), expected.rstrip('\n'), p.stderr

def test_bad(location):
    p = run(["./khoon.sh", location], capture_output=True)
    return p.returncode != 0, p.stdout.decode().rstrip('\n'), "ERROR", p.stderr

good_passed, good_total = test("tests/good/", TestKind.GOOD)
bad_rejected, bad_total = test("tests/bad/", TestKind.BAD)
print("GOOD PASSED:  [" + str(good_passed) + "/" + str(good_total) + "]")
print("BAD REJECTED: [" + str(bad_rejected) + "/" + str(bad_total) + "]")
