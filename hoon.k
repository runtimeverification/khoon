module HOON-SYNTAX
    syntax Hoon ::= Noun

    syntax Noun ::= Atom

    syntax Atom ::= UD
                  | UI

    syntax UD ::= r"(0{1})|([1-9]{1}[0-9]{0,2})(\\.[0-9]{3})*" [token]
    syntax UI ::= r"(0i)(0{1}|[1-9]{1}[0-9]*)" [token]
endmodule

module HOON
    imports HOON-SYNTAX

endmodule
