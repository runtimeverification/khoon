# khoon

K Framework implementation of Hoon.


## Installation

Prerequsites: `python >= 3.10`, `pip >= 20.0.2`, `poetry >= 1.3.2`.

```bash
make build
pip install dist/*.whl
```


## For Developers

Use `make` to run common tasks (see the [Makefile](Makefile) for a complete list of available targets).

* `make build`: Build wheel
* `make check`: Check code style
* `make format`: Format code
* `make test-unit`: Run unit tests

For interactive use, spawn a shell with `poetry shell` (after `poetry install`), then run an interpreter.


## Issues

ISSUES:
* [ ] Pretty-printer does not remove explicit brackets in cells.
* [ ] Errors are never thrown.
* [ ] Arms are encoded as a list of Hoon code instead of a Nock formula, therefore looking inside a battery gives the wrong result.

TODO:
* [ ] Remaining runes.
* [ ] Remaining auras.
* [ ] Irregular forms.
