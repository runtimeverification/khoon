module HOON-SYNTAX
    syntax Hoon ::= Exp

    syntax KResult ::= Noun

    syntax Exp ::= Noun
                 | Rune

    syntax WideExp ::= Noun
                     | WideForm

    syntax Rune ::= TallForm
                  | WideForm

    syntax TallForm ::= ":-" Exp Exp [strict]

    syntax WideForm ::= ":-(" WideExp WideExp ")" [strict]

    syntax Noun ::= Atom
                  | Cell

    syntax Cell ::= "[" Exp Exp "]"

    syntax Atom ::= UD
                  | UI

    syntax UD ::= r"(0{1})|([1-9]{1}[0-9]{0,2})(\\.[0-9]{3})*" [token]
    syntax UI ::= r"(0i)(0{1}|[1-9]{1}[0-9]*)" [token]
endmodule

module HOON
    imports HOON-SYNTAX

    configuration
        <k> $PGM:Hoon </k>
endmodule
