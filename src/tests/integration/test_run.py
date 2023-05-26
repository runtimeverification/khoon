from __future__ import annotations

from pathlib import Path
from typing import TYPE_CHECKING

import pytest

if TYPE_CHECKING:
    from khoon import KHoon


TEST_DATA_DIR = (Path(__file__).parent / 'test-data').resolve(strict=True)

GOOD_FILES = tuple((TEST_DATA_DIR / 'good').glob('*.hoon'))
BAD_FILES = tuple((TEST_DATA_DIR / 'bad').glob('*.hoon'))

GOOD_TEST_DATA = tuple(
    (program_file, program_file.parent / f'{program_file.name}.output') for program_file in GOOD_FILES
)


@pytest.mark.parametrize(
    'program_file,expected_file',
    GOOD_TEST_DATA,
    ids=[program_file.name for program_file, _ in GOOD_TEST_DATA],
)
def test_good(khoon: KHoon, program_file: Path, expected_file: Path) -> None:
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
    # Then
    with pytest.raises(RuntimeError):
        # When
        khoon.run(program_file)
