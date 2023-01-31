module HOON-SYNTAX
    // Notes:
    //  - \u2660 represents an ace (a single space). A gap (two or more spaces
    //  or a newline) is assumed if an ace is not specified (unless it is zero
    //  spaces).

    syntax Hoon ::= Exp

    syntax KResult ::= Noun

    syntax Noun ::= Atom
                  | Cell

    syntax Cell ::= "[" Exp "\\u2660" Exp "]"

    syntax Exp ::= TallExp
                 | WideExp

    syntax WideExp ::= Noun
                     | WideForm

    syntax TallExp ::= Noun
                     | TallForm

    syntax TallForm ::= Rune2 Exp Exp [strict]
                      | Rune3 Exp Exp Exp [strict]

    syntax WideForm ::= Rune2 "(" WideExp "\\u2660" WideExp ")" [strict]
                      | Rune3 "(" WideExp "\\u2660" WideExp "\\u2660" WideExp ")" [strict]

    // 2 arg runes
    syntax Rune2 ::= ":-"
                   | ".="

    // 3 arg runes
    syntax Rune3 ::= "?:"

    syntax Atom ::= TAS
                  | UD
                  | UI

    // Auras
    syntax TAS ::= r"%(([a-z]{1}[a-z0-9\\-]*)|(.[yn])|{Number})" [token]
    syntax UD ::= r"{UD}" [token]
    syntax UI ::= r"{UI}" [token]

    syntax lexical Number = r"{UD}|{UI}"
    syntax lexical UD = r"(0{1})|([1-9]{1}[0-9]{0,2})(\\.\\n?[0-9]{3})*"
    syntax lexical UI = r"(0i)(0{1}|[1-9]{1}[0-9]*)"
endmodule

module HOON
    imports HOON-SYNTAX

    configuration
        <k> $PGM:Hoon </k>

    // colhep
    rule <k> :- P Q => [P \u2660 Q] ... </k>
    rule <k> :-(P \u2660 Q) => [P \u2660 Q] ... </k>

    // dottis
    // TODO rule

    // wutcol
    // TODO rule
endmodule
