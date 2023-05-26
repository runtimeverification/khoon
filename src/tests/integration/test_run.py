from __future__ import annotations

from typing import TYPE_CHECKING

import pytest

from .utils import TEST_DATA_DIR

if TYPE_CHECKING:
    from pathlib import Path

    from khoon import KHoon


GOOD_FILES = tuple((TEST_DATA_DIR / 'good').glob('*.hoon'))
GOOD_SKIPPED = set((TEST_DATA_DIR / 'good' / 'excluded').read_text().splitlines())

BAD_FILES = tuple((TEST_DATA_DIR / 'bad').glob('*.hoon'))
BAD_SKIPPED = set((TEST_DATA_DIR / 'bad' / 'excluded').read_text().splitlines())

GOOD_TEST_DATA = tuple(
    (program_file, program_file.parent / f'{program_file.name}.output') for program_file in GOOD_FILES
)


@pytest.mark.parametrize(
    'program_file,expected_file',
    GOOD_TEST_DATA,
    ids=[program_file.name for program_file, _ in GOOD_TEST_DATA],
)
def test_good(khoon: KHoon, program_file: Path, expected_file: Path) -> None:
    if program_file.name in GOOD_SKIPPED:
        pytest.skip()

    # Given
    expected = expected_file.read_text().rstrip()

    # When
    actual = khoon.run(program_file)

    # Then
    assert actual == expected


@pytest.mark.parametrize(
    'program_file',
    BAD_FILES,
    ids=[program_file.name for program_file in BAD_FILES],
)
def test_bad(khoon: KHoon, program_file: Path) -> None:
    if program_file.name in BAD_SKIPPED:
        pytest.skip()

    # Then
    with pytest.raises(RuntimeError):
        # When
        khoon.run(program_file)
