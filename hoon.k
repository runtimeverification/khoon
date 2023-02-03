module HOON-SYNTAX
    // Notes:
    //  - \ace represents an ace (a single space) and \gap represents a gap
    //  (two or more spaces or a newline). If neither an ace nor a gap is
    //  specified, it is zero spaces.
    //  - \dot represents "." and is used only for subject expressions, in
    //  other cases "." is left as is.

    syntax Hoon ::= TallExp
                  | WideExp

    syntax KResult ::= Noun

    syntax Noun ::= Atom
                  | Cell

    syntax Cell ::= "[" Hoon "\\ace" Hoon "]"

    syntax WideExp ::= Noun
                     | SubjectExp
                     | WideForm

    syntax TallExp ::= Noun
                     | SubjectExp
                     | TallForm

    syntax SubjectExp ::= "\\dot"

    // Runes
    syntax TallForm ::= ":-" "\\gap" Hoon "\\gap" Hoon [strict]
                      | ".=" "\\gap" Hoon "\\gap" Hoon [strict]
                      | "=>" "\\gap" Hoon "\\gap" Hoon [strict(1)]
                      | "?:" "\\gap" Hoon "\\gap" Hoon "\\gap" Hoon [strict]

    syntax WideForm ::= ":-" "(" WideExp "\\ace" WideExp ")" [strict]
                      | ".=" "(" WideExp "\\ace" WideExp ")" [strict]
                      | "=>" "(" WideExp "\\ace" WideExp ")" [strict(1)]
                      | "?:" "(" WideExp "\\ace" WideExp "\\ace" WideExp ")" [strict]

    syntax Atom ::= TAS
                  | UD
                  | UI
                  | Null

    syntax Null ::= "~" [token]

    // Auras
    syntax TAS ::= "%" TasText | "%" TasBool | "%" TasNumber
        syntax TasText ::= r"[a-z]{1}[a-z0-9\\-]*" [token]
        syntax TasBool ::= ".y" [token]
                         | ".n" [token]
        syntax TasNumber ::= UD | UI
    syntax UD ::= r"{UD}" [token]
    syntax UI ::= r"{UI}" [token]

    syntax lexical UD = r"(0{1})|([1-9]{1}[0-9]{0,2})(\\.(\\\\gap)?[0-9]{3})*"
    syntax lexical UI = r"(0i)(0{1}|[1-9]{1}[0-9]*)"
endmodule

module HOON
    imports HOON-SYNTAX
    imports HOON-HELPER
    imports K-EQUAL

    configuration
        <k> $PGM:Hoon </k>
        <subject> ~:Noun </subject>

    // Current subject
    rule <k> \dot:Hoon => S ... </k>
         <subject> S </subject>

    // colhep
    rule <k> :- \gap P \gap Q => [P \ace Q] ... </k>
    rule <k> :-(P \ace Q) => [P \ace Q] ... </k>

    // dottis
    rule <k> .= \gap P:Atom \gap Q:Atom => %.y ... </k> requires (toUnsignedInt(P) ==K toUnsignedInt(Q))
    rule <k> .=(P:Atom \ace Q:Atom) => %.y ... </k> requires (toUnsignedInt(P) ==K toUnsignedInt(Q))
    rule <k> .= \gap P:Cell \gap Q:Cell => %.y ... </k> requires (toUnsignedInts(P) ==K toUnsignedInts(Q))
    rule <k> .=(P:Cell \ace Q:Cell) => %.y ... </k> requires (toUnsignedInts(P) ==K toUnsignedInts(Q))
    rule <k> .= \gap _ \gap _ => %.n ... </k> [owise]
    rule <k> .=(_ \ace _) => %.n ... </k> [owise]

    // tisgar
    rule <k> => \gap P \gap Q => Q ... </k>
         <subject> _ => P </subject>
    rule <k> =>(P \ace Q) => Q ... </k>
         <subject> _ => P </subject>

    // wutcol
    rule <k> ?: \gap %.y \gap Q \gap _ => Q ... </k>
    rule <k> ?: \gap %.n \gap _ \gap R => R ... </k>
    rule <k> ?:(%.y \ace Q \ace _) => Q ... </k>
    rule <k> ?:(%.n \ace _ \ace R) => R ... </k>
endmodule

module HOON-HELPER
    imports HOON-SYNTAX
    imports INT
    imports STRING
    imports STRING-BUFFER
    imports K-EQUAL

    syntax Int ::= toUnsignedInt(Atom) [function]
    syntax String ::= TasTextToString(TasText) [function, total, hook(STRING.token2string)]
                    | UDToString(UD) [function, total, hook(STRING.token2string)]
                    | UIToString(UI) [function, total, hook(STRING.token2string)]

    // Convert an atom to its underlying unsigned integer
    rule toUnsignedInt(%A:TasText) => String2Base(TextToHex(TasTextToString(A)), 16)
    rule toUnsignedInt(%.y) => 0
    rule toUnsignedInt(%.n) => 1
    rule toUnsignedInt(%A:UD) => String2Int(replaceAll(UDToString(A), ".", ""))
    rule toUnsignedInt(%A:UI) => String2Int(replaceFirst(UIToString(A), "0i", ""))
    rule toUnsignedInt(A:UD) => String2Int(replaceAll(UDToString(A), ".", ""))
    rule toUnsignedInt(A:UI) => String2Int(replaceFirst(UIToString(A), "0i", ""))

    syntax IntNoun ::= Int | IntCell
    syntax IntCell ::= "[" IntNoun IntNoun "]"
                     | toUnsignedInts(Cell) [function]

    // Convert each atom in a cell to its underlying unsigned integer
    rule toUnsignedInts([P:Atom \ace Q:Atom]) => [toUnsignedInt(P) toUnsignedInt(Q)]
    rule toUnsignedInts([P:Atom \ace Q:Cell]) => [toUnsignedInt(P) toUnsignedInts(Q)]
    rule toUnsignedInts([P:Cell \ace Q:Atom]) => [toUnsignedInts(P) toUnsignedInt(Q)]
    rule toUnsignedInts([P:Cell \ace Q:Cell]) => [toUnsignedInts(P) toUnsignedInts(Q)]

    // Helper functions
    syntax String ::= HexOfLastChar(String) [function]
    rule HexOfLastChar(S) => Base2String(ordChar(substrString(S, lengthString(S) -Int 1, lengthString(S))), 16)

    syntax String ::= TextToHex(String) [function]
    rule TextToHex(S) => HexOfLastChar(S) +String TextToHex(CutLastChar(S)) requires lengthString(S) >Int 0
    rule TextToHex(_) => "" [owise]

    syntax String ::= CutLastChar(String) [function]
    rule CutLastChar(S) => substrString(S, 0, lengthString(S) -Int 1) requires lengthString(S) >Int 0
endmodule
