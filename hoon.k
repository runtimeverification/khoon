module HOON-SYNTAX
    // Notes:
    //  - \ace represents an ace (a single space) and \gap represents a gap
    //  (two or more spaces or a newline). If neither an ace nor a gap is
    //  specified, it is zero spaces.

    syntax Hoon ::= Exp

    syntax KResult ::= Noun

    syntax Noun ::= Atom
                  | Cell

    syntax Cell ::= "[" Exp "\\ace" Exp "]"

    syntax Exp ::= TallExp
                 | WideExp

    syntax WideExp ::= Noun
                     | WideForm

    syntax TallExp ::= Noun
                     | TallForm

    // Runes
    syntax TallForm ::= ":-" "\\gap" Exp "\\gap" Exp [strict]
                      | ".=" "\\gap" Exp "\\gap" Exp [strict]
                      | "?:" "\\gap" Exp "\\gap" Exp "\\gap" Exp [strict]

    syntax WideForm ::= ":-" "(" WideExp "\\ace" WideExp ")" [strict]
                      | ".=" "(" WideExp "\\ace" WideExp ")" [strict]
                      | "?:" "(" WideExp "\\ace" WideExp "\\ace" WideExp ")" [strict]

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
    rule <k> :- \gap P \gap Q => [P \ace Q] ... </k>
    rule <k> :-(P \ace Q) => [P \ace Q] ... </k>

    // dottis
    // TODO rule

    // wutcol
    // TODO rule
endmodule
