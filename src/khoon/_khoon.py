from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from tempfile import NamedTemporaryFile
from typing import TYPE_CHECKING, final

from pyk.cli_utils import check_dir_path, check_file_path
from pyk.ktool.krun import _krun

from .parser import parse
from .pretty import pretty

if TYPE_CHECKING:
    from typing import Final


K_SRC_DIR: Final = (Path(__file__).parent / 'hoon-semantics').resolve(strict=True)


@final
@dataclass(frozen=True)
class KHoon:
    llvm_dir: Path

    def __init__(self, llvm_dir: str | Path):
        llvm_dir = Path(llvm_dir)
        check_dir_path(llvm_dir)
        object.__setattr__(self, 'llvm_dir', llvm_dir)

    def run(self, program_file: str | Path, check: bool = True) -> str:
        program_file = Path(program_file)
        check_file_path(program_file)

        program_text = program_file.read_text()
        parsed_text = parse(program_text)

        with NamedTemporaryFile(mode='w') as f:
            temp_file = Path(f.name)
            temp_file.write_text(parsed_text)

            run_res = _krun(
                input_file=temp_file,
                definition_dir=self.llvm_dir,
                check=check,
                pipe_stderr=True,
            )

            return pretty(run_res.stdout)
