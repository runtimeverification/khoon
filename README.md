K framework implementation of Hoon.

ISSUES:
 - Pretty-printer does not remove explicit brackets in cells.
 - Errors are never thrown.
 - Arms are encoded as a list of Hoon code instead of a Nock formula, therefore looking inside a battery gives the wrong result.
 - Ahead-of-time parser ignores avoid attribute.

TODO:
 - Remaining runes.
 - Remaining auras.
 - Irregular forms.
