from __future__ import annotations

from typing import TYPE_CHECKING

import pytest
from pyk.kbuild import KBuild, Package

from khoon import K_SRC_DIR, KHoon

if TYPE_CHECKING:
    from pathlib import Path

    from pytest import TempPathFactory


@pytest.fixture(scope='session')
def kbuild(tmp_path_factory: TempPathFactory) -> KBuild:
    kbuild_dir = tmp_path_factory.mktemp('kbuild')
    return KBuild(kbuild_dir)


@pytest.fixture(scope='session')
def package() -> Package:
    return Package.create(K_SRC_DIR / 'kbuild.toml')


@pytest.fixture(scope='session')
def llvm_dir(kbuild: KBuild, package: Package) -> Path:
    return kbuild.kompile(package, 'llvm')


@pytest.fixture(scope='session')
def khoon(llvm_dir: Path) -> KHoon:
    return KHoon(llvm_dir=llvm_dir)
