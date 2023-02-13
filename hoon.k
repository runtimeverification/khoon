module HOON-SYNTAX
    // Notes:
    //  - \ace represents an ace (a single space) and \gap represents a gap
    //  (two or more spaces or a newline). If neither an ace nor a gap is
    //  specified, it is zero spaces.
    //  - \dot represents "." and is used only for subject expressions, in
    //  other cases "." is left as is.

    syntax Hoon ::= TallExp
                  | WideExp

    syntax WideExp ::= Noun
                     | SubjectExp
                     | WideForm

    syntax TallExp ::= Noun
                     | SubjectExp
                     | TallForm

    syntax Noun ::= Atom
                  | Cell
                  | TasText "=" Noun

    syntax Atom ::= TAS
                  | UD
                  | UI
                  | Null

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

    syntax Cell ::= "[" Hoon "\\ace" Hoon "]" [strict]
                  | "[" Hoon "\\ace" Hoon "\\ace" CellImplicit "]" [strict]
    syntax CellImplicit ::= List{Hoon, "\\ace"}

    syntax SubjectExp ::= "\\dot"
                        | Lark
                        | Lark ":" Hoon [strict(2)]

    syntax Lark ::= r"([-+][<>]([-+][<>])*[-+]?)|[-+]" [token]

    syntax TallForm ::= ":-" "\\gap" Hoon "\\gap" Hoon [strict]
                      | ".=" "\\gap" Hoon "\\gap" Hoon [strict]
                      | "^-" "\\gap" Spec "\\gap" Hoon [strict(2)]
                      | "^+" "\\gap" Hoon "\\gap" Hoon [strict]
                      | "^*" "\\gap" Spec
                      | "^=" "\\gap" Skin "\\gap" Hoon [strict(2)]
                      | "=>" "\\gap" Hoon "\\gap" Hoon [strict(1)]
                      | "=+" "\\gap" Hoon "\\gap" Hoon [strict(1)]
                      | "?:" "\\gap" Hoon "\\gap" Hoon "\\gap" Hoon [strict]
                      | "?@" "\\gap" Hoon "\\gap" Hoon "\\gap" Hoon [strict]
                      | "?=" "\\gap" Spec "\\gap" Hoon [strict(2)]

    syntax WideForm ::= ":-" "(" WideExp "\\ace" WideExp ")" [strict]
                      | ".=" "(" WideExp "\\ace" WideExp ")" [strict]
                      | "^-" "(" Spec "\\ace" WideExp ")" [strict(2)]
                      | "^+" "(" WideExp "\\ace" WideExp ")" [strict]
                      | "^*" "(" Spec ")"
                      | "^=" "(" Skin "\\ace" WideExp ")" [strict(2)]
                      | "=>" "(" WideExp "\\ace" WideExp ")" [strict(1)]
                      | "=+" "(" WideExp "\\ace" WideExp ")" [strict(1)]
                      | "?:" "(" WideExp "\\ace" WideExp "\\ace" WideExp ")" [strict]
                      | "?@" "(" WideExp "\\ace" WideExp "\\ace" WideExp ")" [strict]
                      | "?=" "(" Spec "\\ace" WideExp ")" [strict(2)]

    syntax Spec ::= "[" Spec "\\ace" Spec "]"
                  | TAS
                  | "*"
                  | "@"
                  | "^"
                  | "?"
                  | "~"
                  | Aura

    syntax Aura ::= AText
                  | AInt

    syntax AText ::= "@tas"

    syntax AInt ::= "@u"
                  | "@ud"
                  | "@ui"

    syntax Skin ::= TasText
                  | TasText "=" Skin
                  | "[" Skin "\\ace" Skin "]"
                  | "[" Skin "\\ace" Skin "\\ace" SkinCellImplicit "]"
    syntax SkinCellImplicit ::= List{Skin, "\\ace"}
endmodule

module HOON-TYPED
    imports HOON-SYNTAX

    // Used to keep track of the type of a noun
    syntax TypedNoun ::= "(" Spec "," Noun ")"

    syntax TallExp ::= TypedNoun
    syntax WideExp ::= TypedNoun
endmodule

module HOON
    imports HOON-SYNTAX
    imports HOON-TYPED
    imports HOON-HELPER

    configuration
        <k> $PGM:Hoon </k>
        <subject> ~:Noun </subject>

    syntax KResult ::= TypedNoun

    // Convert untyped nouns to typed nouns if not an end result
    rule <k> (P:Noun):TallExp ~> K:K => (typeOf(P), P) ~> K </k> requires K =/=K .
    rule <k> (P:Noun):WideExp ~> K:K => (typeOf(P), P) ~> K </k> requires K =/=K .

    // Convert cells of typed nouns to a typed noun
    rule <k> ([(T1, P) \ace (T2, Q)]):TallExp => ([T1 \ace T2], [P \ace Q]) ... </k>
    rule <k> ([(T1, P) \ace (T2, Q)]):WideExp => ([T1 \ace T2], [P \ace Q]) ... </k>

    // Current subject
    rule <k> \dot:Hoon => S ... </k>
         <subject> S </subject>

    // Addressing with lark notation
    rule <k> L:Lark => L : \dot ... </k>
    rule <k> L : (_, C:Cell) => LarkToString(L) : C ... </k>
    rule <k> LS : [P \ace _] => tail(LS) : P ... </k> requires (head(LS) ==K "-") orBool (head(LS) ==K "<")
    rule <k> LS : [_ \ace Q] => tail(LS) : Q ... </k> requires (head(LS) ==K "+") orBool (head(LS) ==K ">")
    rule <k> "-" : [P \ace _] => P ... </k>
    rule <k> "<" : [P \ace _] => P ... </k>
    rule <k> "+" : [_ \ace Q] => Q ... </k>
    rule <k> ">" : [_ \ace Q] => Q ... </k>

    // colhep
    rule <k> :- \gap (T1, P) \gap (T2, Q) => ([T1 \ace T2], [P \ace Q]) ... </k>
    rule <k> :-((T1, P) \ace (T2, Q)) => ([T1 \ace T2], [P \ace Q]) ... </k>

    // dottis TODO type union ?(%.y %.n)
    rule <k> .= \gap (_, P:Atom) \gap (_, Q:Atom) => (?, %.y) ... </k> requires (toUnsignedInt(P) ==K toUnsignedInt(Q))
    rule <k> .=((_, P:Atom) \ace (_, Q:Atom)) => (?, %.y) ... </k> requires (toUnsignedInt(P) ==K toUnsignedInt(Q))
    rule <k> .= \gap (_, P:Cell) \gap (_, Q:Cell) => (?, %.y) ... </k> requires (toUnsignedInts(P) ==K toUnsignedInts(Q))
    rule <k> .=((_, P:Cell) \ace (_, Q:Cell)) => (?, %.y) ... </k> requires (toUnsignedInts(P) ==K toUnsignedInts(Q))
    rule <k> .= \gap _ \gap _ => (?, %.n) ... </k> [owise]
    rule <k> .=(_ \ace _) => (?, %.n) ... </k> [owise]

    // kethep
    rule <k> ^- \gap T \gap Q => ^+ \gap ^* \gap T \gap Q ... </k>
    rule <k> ^-(T \ace Q) => ^+(^*(T) \ace Q) ... </k>

    // ketlus
    rule <k> ^+ \gap (T1, _) \gap (T2, Q) => (T1, toType(T1, Q)) ... </k> requires nests(T1, T2)
    rule <k> ^+((T1, _) \ace (T2, Q)) => (T1, toType(T1, Q)) ... </k> requires nests(T1, T2)

    // kettar
    rule <k> ^* \gap T => bunt(T) ... </k>
    rule <k> ^*(T) => bunt(T) ... </k>

    // kettis
    rule <k> ^= \gap N \gap (T, Q) => (T, name(N, Q)) ... </k>
    rule <k> ^=(N \ace (T, Q)) => (T, name(N, Q)) ... </k>

    // tisgar
    rule <k> => \gap (_, P) \gap Q => Q ... </k>
         <subject> _ => P </subject>
    rule <k> =>((_, P) \ace Q) => Q ... </k>
         <subject> _ => P </subject>

    // tislus
    rule <k> =+ \gap (_, P) \gap Q => => \gap [P \ace S] \gap Q ... </k>
         <subject> S </subject>
    rule <k> =+((_, P) \ace Q) => =>([P \ace S] \ace Q) ... </k>
         <subject> S </subject>

    // wutcol
    rule <k> ?: \gap (_, %.y) \gap Q \gap _ => Q ... </k>
    rule <k> ?: \gap (_, %.n) \gap _ \gap R => R ... </k>
    rule <k> ?:((_, %.y) \ace Q \ace _) => Q ... </k>
    rule <k> ?:((_, %.n) \ace _ \ace R) => R ... </k>

    // wutpat
    rule <k> ?@ \gap P \gap Q \gap R => ?: \gap ?= \gap @ \gap P \gap Q \gap R ... </k>
    rule <k> ?@(P \ace Q \ace R) => ?:(?=(@ \ace P) \ace Q \ace R) ... </k>

    // wuttis TODO type union ?(%.y %.n)
    rule <k> ?= \gap T \gap (_, Q) => (?, %.y) ... </k> requires weakNests(T, Q)
    rule <k> ?=(T \ace (_, Q)) => (?, %.y) ... </k> requires weakNests(T, Q)
    rule <k> ?= \gap _ \gap _ => (?, %.n) ... </k> [owise]
    rule <k> ?=(_ \ace _) => (?, %.n)... </k> [owise]
endmodule

module HOON-HELPER
    imports HOON-SYNTAX
    imports HOON-TYPED
    imports INT
    imports STRING
    imports K-EQUAL
    imports BOOL

    // Make implicit brackets explicit
    syntax Cell ::= explicitBrackets(Cell) [function]

    rule [P \ace Q \ace R]:Cell => explicitBrackets([P \ace Q \ace R])
    rule explicitBrackets([P \ace Q \ace R \ace REST]:Cell) => [P \ace explicitBrackets([Q \ace R \ace REST])]
    rule explicitBrackets([P \ace Q \ace .CellImplicit]:Cell) => [P \ace Q]

    // Convert an atom to its underlying unsigned integer
    syntax Int ::= toUnsignedInt(Atom) [function]

    rule toUnsignedInt(%A:TasText) => String2Base(TextToHex(TasTextToString(A)), 16)
    rule toUnsignedInt(%.y) => 0
    rule toUnsignedInt(%.n) => 1
    rule toUnsignedInt(%A:UD) => String2Int(replaceAll(UDToString(A), ".", ""))
    rule toUnsignedInt(%A:UI) => String2Int(replaceFirst(UIToString(A), "0i", ""))
    rule toUnsignedInt(%$) => 0
    rule toUnsignedInt(A:UD) => String2Int(replaceAll(UDToString(A), ".", ""))
    rule toUnsignedInt(A:UI) => String2Int(replaceFirst(UIToString(A), "0i", ""))

    // Convert each atom in a cell to its underlying unsigned integer
    syntax IntNoun ::= Int | IntCell
    syntax IntCell ::= "[" IntNoun IntNoun "]"
                     | toUnsignedInts(Cell) [function]

    rule toUnsignedInts([P:Atom \ace Q:Atom]) => [toUnsignedInt(P) toUnsignedInt(Q)]
    rule toUnsignedInts([P:Atom \ace Q:Cell]) => [toUnsignedInt(P) toUnsignedInts(Q)]
    rule toUnsignedInts([P:Cell \ace Q:Atom]) => [toUnsignedInts(P) toUnsignedInt(Q)]
    rule toUnsignedInts([P:Cell \ace Q:Cell]) => [toUnsignedInts(P) toUnsignedInts(Q)]

    // Check if noun Q nests in type P
    syntax Bool ::= nests(Spec, Spec) [function]

    rule nests(*, _) => true
    rule nests(@, @) => true
    rule nests(@, _:Aura) => true
    rule nests(^, ^) => true
    rule nests(^, [_ \ace _]) => true
    rule nests(?, %.y) => true
    rule nests(?, %.n) => true
    rule nests(~, ~) => true
    rule nests(@tas, %_:TasText) => true
    rule nests(@tas, %_:TasNumber) => true
    rule nests(@tas, %_:TasEmpty) => true
    rule nests(@tas, @) => true
    rule nests(@u, _:AInt) => true
    rule nests(@u, @) => true
    rule nests(@ud, @ud) => true
    rule nests(@ud, @) => true
    rule nests(@ui, @ui) => true
    rule nests(@ui, @) => true
    rule nests(P:TAS, Q:TAS) => true requires P ==K Q
    rule nests([P1 \ace P2], [Q1 \ace Q2]) => nests(P1, Q1) andBool nests(P2, Q2)
    rule nests(_, _) => false [owise]

    // Check if noun underlying int nests in type P
    syntax Bool ::= weakNests(Spec, Noun) [function]

    rule weakNests(*, _) => true
    rule weakNests(@, _:Atom) => true
    rule weakNests(^, _:Cell) => true
    rule weakNests(?, Q:Atom) => true requires (toUnsignedInt(Q) ==Int 0) orBool (toUnsignedInt(Q) ==Int 1)
    rule weakNests(~, Q:Atom) => true requires toUnsignedInt(Q) ==Int 0
    rule weakNests(@tas, _:Atom) => true
    rule weakNests(@u, _:Atom) => true
    rule weakNests(@u, _:Atom) => true
    rule weakNests(@ud, _:Atom) => true
    rule weakNests(@ui, _:Atom) => true
    rule weakNests(P:TAS, Q:Atom) => true requires toUnsignedInt(P) ==Int toUnsignedInt(Q)
    rule weakNests([P1 \ace P2], [Q1 \ace Q2]) => weakNests(P1, Q1) andBool weakNests(P2, Q2)
    rule weakNests(_, _) => false [owise]

    // Infer type of noun TODO type union ?(%.y %.n)
    syntax Spec ::= typeOf(Noun) [function]

    rule typeOf(%.y) => ?
    rule typeOf(%.n) => ?
    rule typeOf(P:TAS) => P [owise]
    rule typeOf(_:UD) => @ud
    rule typeOf(_:UI) => @ui
    rule typeOf(_:Null) => @ // TODO type of null? %~
    rule typeOf([P \ace Q]) => [typeOf(P) \ace typeOf(Q)]

    // Bunt value of spec
    syntax TypedNoun ::= bunt(Spec) [function]

    rule bunt([P \ace Q]) => ([getSpec(bunt(P)) \ace getSpec(bunt(Q))], [getNoun(bunt(P)) \ace getNoun(bunt(Q))])
    rule bunt(P:TAS) => (P, P)
    rule bunt(*) => (*, StringToUD("0"))
    rule bunt(@) => (@, StringToUD("0"))
    rule bunt(^) => ([* \ace *], [StringToUD("0") \ace StringToUD("0")])
    rule bunt(?) => (?, %.y) // TODO type should be type union ?(%.y %.n)
    rule bunt(~) => (~, ~) // TODO zapgar gives: %~
    rule bunt(@tas) => (@tas, %$)
    rule bunt(@u) => (@u, StringToUD("0"))
    rule bunt(@ud) => (@ud, StringToUD("0"))
    rule bunt(@ui) => (@ui, 0i0)

    // Get noun from typed noun
    syntax Noun ::= getNoun(TypedNoun) [function]

    rule getNoun((_, N)) => N

    // Get spec (type) from typed noun
    syntax Spec ::= getSpec(TypedNoun) [function]

    rule getSpec((T, _)) => T

    // Bind a name to a value
    syntax Noun ::= name(Skin, Noun) [function]

    rule name(N:TasText, P) => N=P
    rule name(N1=N2, P) => N1=name(N2, P)
    rule name([N1 \ace N2], [P1 \ace P2]) => [name(N1, P1) \ace name(N2, P2)]
    rule name([N1 \ace N2 \ace Ns], P) => name([N1 \ace N2], P) requires Ns ==K .SkinCellImplicit
    rule name([N1 \ace N2 \ace Ns], [P1 \ace P2]) => [name(N1, P1) \ace name([N2 \ace Ns], P2)]

    // TODO Make exhaustive
    rule toType(@tas, Q:UD) => % StringToTasText(UDToText(Q))
    rule toType([T1 \ace T2], [P \ace Q]) => [toType(T1, P) \ace toType(T2, Q)]
    rule toType(_, Q) => Q [owise]

    syntax Noun ::= toType(Spec, Noun) [function]

    // Lark syntax used in lark rules
    syntax LarkString ::= String ":" Cell

    // Helper functions
    syntax TasText ::= StringToTasText(String) [function, total, hook(STRING.string2token)]
    syntax UD ::= StringToUD(String) [function, total, hook(STRING.string2token)]

    syntax String ::= TasTextToString(TasText) [function, total, hook(STRING.token2string)]
                    | UDToString(UD) [function, total, hook(STRING.token2string)]
                    | UIToString(UI) [function, total, hook(STRING.token2string)]
                    | LarkToString(Lark) [function, total, hook(STRING.token2string)]

    syntax String ::= TextToHex(String) [function]
    rule TextToHex(S) => HexOfLastChar(S) +String TextToHex(CutLastChar(S)) requires lengthString(S) >Int 0
    rule TextToHex(_) => "" [owise]

    syntax String ::= HexOfLastChar(String) [function]
    rule HexOfLastChar(S) => Base2String(ordChar(substrString(S, lengthString(S) -Int 1, lengthString(S))), 16)

    syntax String ::= UDToText(UD) [function]
    rule UDToText(P) => HexToText(Base2String(toUnsignedInt(P), 16))

    syntax String ::= HexToText(String) [function]
    rule HexToText(S) => LastCharOfHex(S) +String HexToText(CutLast2Char(S)) requires lengthString(S) >Int 1
    rule HexToText(_) => "" [owise]

    syntax String ::= LastCharOfHex(String) [function]
    rule LastCharOfHex(S) => chrChar(String2Base(substrString(S, lengthString(S) -Int 2, lengthString(S)), 16))

    syntax String ::= CutLastChar(String) [function]
    rule CutLastChar(S) => substrString(S, 0, lengthString(S) -Int 1) requires lengthString(S) >Int 0

    syntax String ::= CutLast2Char(String) [function]
    rule CutLast2Char(S) => substrString(S, 0, lengthString(S) -Int 2) requires lengthString(S) >Int 1

    syntax String ::= head(String) [function]
    rule head(S) => substrString(S, 0, 1)

    syntax String ::= tail(String) [function]
    rule tail(S) => substrString(S, 1, lengthString(S))
endmodule
