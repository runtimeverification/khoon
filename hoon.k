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

    syntax TallForm ::= ":-" Exp Exp [strict]

    syntax WideForm ::= ":-" "(" WideExp "\\u2660" WideExp ")" [strict]

    syntax Atom ::= UD
                  | UI

    syntax UD ::= r"(0{1})|([1-9]{1}[0-9]{0,2})(\\.\\n?[0-9]{3})*" [token]
    syntax UI ::= r"(0i)(0{1}|[1-9]{1}[0-9]*)" [token]
endmodule

module HOON
    imports HOON-SYNTAX

    configuration
        <k> $PGM:Hoon </k>

    rule <k> :- P Q => [P \u2660 Q] ... </k>
    rule <k> :-(P \u2660 Q) => [P \u2660 Q] ... </k>
endmodule
