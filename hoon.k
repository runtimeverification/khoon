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
                        | Lark
                        | Lark ":" Hoon [strict(2)]

    syntax Lark ::= r"([-+][<>]([-+][<>])*[-+]?)|[-+]" [token]

    // Runes
    syntax TallForm ::= ":-" "\\gap" Hoon "\\gap" Hoon [strict]
                      | ".=" "\\gap" Hoon "\\gap" Hoon [strict]
                      | "=>" "\\gap" Hoon "\\gap" Hoon [strict(1)]
                      | "=+" "\\gap" Hoon "\\gap" Hoon [strict(1)]
                      | "?:" "\\gap" Hoon "\\gap" Hoon "\\gap" Hoon [strict]
                      | "?=" "\\gap" Spec "\\gap" Hoon [strict(2)]

    syntax WideForm ::= ":-" "(" WideExp "\\ace" WideExp ")" [strict]
                      | ".=" "(" WideExp "\\ace" WideExp ")" [strict]
                      | "=>" "(" WideExp "\\ace" WideExp ")" [strict(1)]
                      | "=+" "(" WideExp "\\ace" WideExp ")" [strict(1)]
                      | "?:" "(" WideExp "\\ace" WideExp "\\ace" WideExp ")" [strict]
                      | "?=" "(" Spec "\\ace" WideExp ")" [strict(2)]

    syntax Spec ::= ElementaryMold
                  | TAS
                  | "[" Spec "\\ace" Spec "]"

    syntax ElementaryMold ::= "*"
                            | "@"
                            | "^"
                            | "?"
                            | "~"

    syntax Atom ::= TAS
                  | UD
                  | UI
                  | Null

    // Auras
    syntax TAS ::= "%" TasText | "%" TasBool | "%" TasNumber | "%" TasEmpty
        syntax TasText ::= r"[a-z]{1}[a-z0-9\\-]*" [token]
        syntax TasBool ::= ".y" [token]
                         | ".n" [token]
        syntax TasNumber ::= UD | UI
        syntax TasEmpty ::= "$"
    syntax UD ::= r"{UD}" [token]
    syntax UI ::= r"{UI}" [token]
    syntax Null ::= "~" [token]

    syntax lexical UD = r"(0{1})|([1-9]{1}[0-9]{0,2})(\\.(\\\\gap)?[0-9]{3})*"
    syntax lexical UI = r"(0i)(0{1}|[1-9]{1}[0-9]*)"
endmodule

module HOON
    imports HOON-SYNTAX
    imports HOON-HELPER

    configuration
        <k> $PGM:Hoon </k>
        <subject> ~:Noun </subject>

    // Current subject
    rule <k> \dot:Hoon => S ... </k>
         <subject> S </subject>

    // Addressing with lark notation
    rule <k> L:Lark => L : \dot ... </k>
    rule <k> L : C:Cell => LarkToString(L) : C ... </k>
    rule <k> LS : [P \ace _] => tail(LS) : P ... </k> requires (head(LS) ==K "-") orBool (head(LS) ==K "<")
    rule <k> LS : [_ \ace Q] => tail(LS) : Q ... </k> requires (head(LS) ==K "+") orBool (head(LS) ==K ">")
    rule <k> "-" : [P \ace _] => P ... </k>
    rule <k> "<" : [P \ace _] => P ... </k>
    rule <k> "+" : [_ \ace Q] => Q ... </k>
    rule <k> ">" : [_ \ace Q] => Q ... </k>

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

    // tislus
    rule <k> =+ \gap P \gap Q => => \gap [P \ace S] \gap Q ... </k>
         <subject> S </subject>
    rule <k> =+(P \ace Q) => =>([P \ace S] \ace Q) ... </k>
         <subject> S </subject>

    // wutcol
    rule <k> ?: \gap %.y \gap Q \gap _ => Q ... </k>
    rule <k> ?: \gap %.n \gap _ \gap R => R ... </k>
    rule <k> ?:(%.y \ace Q \ace _) => Q ... </k>
    rule <k> ?:(%.n \ace _ \ace R) => R ... </k>

    // wuttis
    rule <k> ?= \gap P \gap Q => %.y ... </k> requires nests(P, Q)
    rule <k> ?=(P \ace Q) => %.y ... </k> requires nests(P, Q)
    rule <k> ?= \gap _ \gap _ => %.n ... </k> [owise]
    rule <k> ?=(_ \ace _) => %.n ... </k> [owise]
endmodule

module HOON-HELPER
    imports HOON-SYNTAX
    imports INT
    imports STRING
    imports STRING-BUFFER
    imports K-EQUAL
    imports BOOL

    syntax Int ::= toUnsignedInt(Atom) [function]

    // Convert an atom to its underlying unsigned integer
    rule toUnsignedInt(%A:TasText) => String2Base(TextToHex(TasTextToString(A)), 16)
    rule toUnsignedInt(%.y) => 0
    rule toUnsignedInt(%.n) => 1
    rule toUnsignedInt(%A:UD) => String2Int(replaceAll(UDToString(A), ".", ""))
    rule toUnsignedInt(%A:UI) => String2Int(replaceFirst(UIToString(A), "0i", ""))
    rule toUnsignedInt(%$) => 0
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

    syntax Bool ::= nests(Spec, Noun) [function]

    // Check if noun Q nests in type P
    rule nests(*, _) => true
    rule nests(@, _:Atom) => true
    rule nests(^, _:Cell) => true
    rule nests(?, Q:Atom) => true requires (toUnsignedInt(Q) ==Int 0) orBool (toUnsignedInt(Q) ==Int 1)
    rule nests(~, Q:Atom) => true requires toUnsignedInt(Q) ==Int 0
    rule nests(P:TAS, Q:Atom) => true requires toUnsignedInt(P) ==Int toUnsignedInt(Q)
    rule nests([P1 \ace P2], [Q1 \ace Q2]) => nests(P1, Q1) andBool nests(P2, Q2)
    rule nests(_, _) => false [owise]

    syntax LarkString ::= String ":" Cell

    // Helper functions
    syntax String ::= TasTextToString(TasText) [function, total, hook(STRING.token2string)]
                    | UDToString(UD) [function, total, hook(STRING.token2string)]
                    | UIToString(UI) [function, total, hook(STRING.token2string)]
                    | LarkToString(Lark) [function, total, hook(STRING.token2string)]

    syntax String ::= HexOfLastChar(String) [function]
    rule HexOfLastChar(S) => Base2String(ordChar(substrString(S, lengthString(S) -Int 1, lengthString(S))), 16)

    syntax String ::= TextToHex(String) [function]
    rule TextToHex(S) => HexOfLastChar(S) +String TextToHex(CutLastChar(S)) requires lengthString(S) >Int 0
    rule TextToHex(_) => "" [owise]

    syntax String ::= CutLastChar(String) [function]
    rule CutLastChar(S) => substrString(S, 0, lengthString(S) -Int 1) requires lengthString(S) >Int 0

    syntax String ::= head(String) [function]
    rule head(S) => substrString(S, 0, 1)

    syntax String ::= tail(String) [function]
    rule tail(S) => substrString(S, 1, lengthString(S))
endmodule
