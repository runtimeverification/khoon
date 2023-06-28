from __future__ import annotations

from typing import TYPE_CHECKING

import pytest
from pyk.kast.inner import KApply
from pyk.testing import KProveTest

from khoon import K_SRC_DIR

from .utils import TEST_DATA_DIR

if TYPE_CHECKING:
    from pyk.ktool.kprove import KProve


class TestProve(KProveTest):
    SPEC_FILE = TEST_DATA_DIR / 'hoon-spec.k'
    INCLUDE_DIRS = (K_SRC_DIR,)

    KOMPILE_MAIN_FILE = SPEC_FILE
    KOMPILE_ARGS = {
        'main_module': 'VERIFICATION',
        'syntax_module': 'HOON-SPEC-SYNTAX',
        'include_dirs': INCLUDE_DIRS,
    }

    @pytest.mark.skip(reason='takes forever')
    def test_prove(self, kprove: KProve) -> None:
        # When
        result = kprove.prove(self.SPEC_FILE, include_dirs=self.INCLUDE_DIRS)

        # Then
        assert isinstance(result, KApply)
        assert result.label.name == '#Top'
