module HOON-SYNTAX
    // Notes:
    //  - \ace represents an ace (a single space) and \gap represents a gap
    //  (two or more spaces or a newline). If neither an ace nor a gap is
    //  specified, it is zero spaces.
    //  - \dot represents "." and is used only for the current subject, in
    //  other cases "." is left as is.

    syntax Hoon ::= TallExp
                  | WideExp

    syntax WideExp ::= Noun
                     | SubjectExp
                     | LookupExp
                     | WideForm

    syntax TallExp ::= Noun
                     | SubjectExp
                     | LookupExp
                     | TallForm

    syntax Noun ::= Atom
                  | Cell
                  | TasText "=" Noun

    syntax Atom ::= TAS
                  | UD
                  | UI
                  | Null

    syntax TAS ::= "%" TasText | "%" TasBool | "%" TasNumber
    syntax TasText ::= r"([a-z][a-z0-9\\-]*)|\\$" [token]
    syntax TasBool ::= ".y" [token]
                     | ".n" [token]
    syntax TasNumber ::= UD | UI

    syntax UD ::= r"{UD}" [token]

    syntax UI ::= r"{UI}" [token]

    syntax Null ::= "~" [token]

    syntax lexical UD = r"(0{1})|([1-9]{1}[0-9]{0,2})(\\.(\\\\gap)?[0-9]{3})*"
    syntax lexical UI = r"(0i)(0{1}|[1-9]{1}[0-9]*)"

    syntax Cell ::= "[" Hoon "\\ace" Hoon "]" [strict]
                  | "[" Hoon "\\ace" Hoon "\\ace" CellImplicit "]" [strict]
    syntax CellImplicit ::= List{Hoon, "\\ace"}

    syntax SubjectExp ::= "\\dot"
                        | NumAddr
                        | Lark
                        | TasText
                        | SkipTasText
                        | SubjectExp "." SubjectExp

    syntax LookupExp ::= SubjectExp ":" Hoon [strict(2)]
                       | Noun ":" Hoon [strict(2)]

    syntax NumAddr ::= r"\\+[1-9][0-9]*" [token]
    syntax Lark ::= r"([-+][<>]([-+][<>])*[-+]?)|[-+]" [token]
    syntax SkipTasText ::= r"\\^+[a-z][a-z0-9\\-]*" [token]

    // TODO Add remaining arms (lus)
    syntax Arm ::= "++" "\\gap" TasText "\\gap" Hoon
    syntax ArmList ::= List{Arm, "\\gap"}

    // |_ |% syntax does not work with LR(1), but works with GLR
    syntax TallForm ::= "|_" "\\gap" Spec "\\gap" ArmList "\\gap" "--"
                      | "|%" "\\gap" ArmList "\\gap" "--"
                      | "|." "\\gap" Hoon
                      | "|-" "\\gap" Hoon
                      | "|=" "\\gap" Spec "\\gap" Hoon
                      | ":-" "\\gap" Hoon "\\gap" Hoon [strict]
                      | ".=" "\\gap" Hoon "\\gap" Hoon [strict]
                      | "^-" "\\gap" Spec "\\gap" Hoon
                      | "^+" "\\gap" Hoon "\\gap" Hoon [strict]
                      | "^~" "\\gap" Hoon [strict]
                      | "^*" "\\gap" Spec
                      | "^=" "\\gap" Skin "\\gap" Hoon [strict(2)]
                      | "=|" "\\gap" Spec "\\gap" Hoon
                      | "=<" "\\gap" Hoon "\\gap" Hoon
                      | "=>" "\\gap" Hoon "\\gap" Hoon [strict(1)]
                      | "=+" "\\gap" Hoon "\\gap" Hoon [strict(1)]
                      | "?:" "\\gap" Hoon "\\gap" Hoon "\\gap" Hoon [strict]
                      | "?@" "\\gap" Hoon "\\gap" Hoon "\\gap" Hoon
                      | "?=" "\\gap" Spec "\\gap" Hoon [strict(2)]

    syntax WideForm ::= "|." "(" Hoon ")"
                      | "|-" "(" Hoon ")"
                      | "|=" "(" Spec "\\ace" Hoon ")"
                      | ":-" "(" WideExp "\\ace" WideExp ")" [strict]
                      | ".=" "(" WideExp "\\ace" WideExp ")" [strict]
                      | "^-" "(" Spec "\\ace" WideExp ")"
                      | "^+" "(" WideExp "\\ace" WideExp ")" [strict]
                      | "^~" "(" Hoon ")" [strict]
                      | "^*" "(" Spec ")"
                      | "^=" "(" Skin "\\ace" WideExp ")" [strict(2)]
                      | "=|" "(" Spec "\\ace" WideExp ")"
                      | "=<" "(" WideExp "\\ace" WideExp ")"
                      | "=>" "(" WideExp "\\ace" WideExp ")" [strict(1)]
                      | "=+" "(" WideExp "\\ace" WideExp ")" [strict(1)]
                      | "?:" "(" WideExp "\\ace" WideExp "\\ace" WideExp ")" [strict]
                      | "?@" "(" WideExp "\\ace" WideExp "\\ace" WideExp ")"
                      | "?=" "(" Spec "\\ace" WideExp ")" [strict(2)]

    syntax Spec ::= "[" Spec "\\ace" Spec "]"
                  | "[" Spec "\\ace" Spec "\\ace" SpecCellImplicit "]"
                  | TAS
                  | "*"
                  | "@"
                  | "^"
                  | "?"
                  | "~"
                  | Aura
                  | TasText "=" Spec
    syntax SpecCellImplicit ::= List{Spec, "\\ace"}

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

module HOON
    imports HOON-SYNTAX
    imports HOON-META
    imports HOON-CORES
    imports HOON-HELPER

    configuration
        <k> $PGM:Hoon </k>
        <subject> ({typeOf(~); .ArmNames}, ~):MetaNoun </subject>

    syntax KResult ::= MetaNoun

    // Convert nouns to meta nouns if not an end result
    rule <k> (P:Noun):TallExp ~> K:K => ({typeOf(P); emptyArmNames(P)}, P) ~> K </k> requires K =/=K .
    rule <k> (P:Noun):WideExp ~> K:K => ({typeOf(P); emptyArmNames(P)}, P) ~> K </k> requires K =/=K .

    // Convert cells of meta nouns to a meta noun
    rule <k> ([({T1; N1}, P) \ace ({T2; N2}, Q)]:Cell):TallExp => ({[T1 \ace T2]; [N1 \ace N2]}, cell(P, Q)) ... </k>
    rule <k> ([({T1; N1}, P) \ace ({T2; N2}, Q)]:Cell):WideExp => ({[T1 \ace T2]; [N1 \ace N2]}, cell(P, Q)) ... </k>

    // Current subject
    rule <k> \dot:Hoon => S ... </k>
         <subject> S </subject>

    // Lookup wings in the subject
    rule <k> (P:SubjectExp):TallExp => lookup(toWingStack(P, .WingStack), S, .MetaNounStack, 0) ... </k>
         <subject> S </subject>
    rule <k> (P:SubjectExp):WideExp => lookup(toWingStack(P, .WingStack), S, .MetaNounStack, 0) ... </k>
         <subject> S </subject>

    // Wing the specified noun
    rule <k> (P : Q):TallExp => lookup(toWingStack(P, .WingStack), Q, .MetaNounStack, 0) ... </k> [owise]
    rule <k> (P : Q):WideExp => lookup(toWingStack(P, .WingStack), Q, .MetaNounStack, 0) ... </k> [owise]
    rule <k> (P:Noun : _):TallExp => P ... </k>
    rule <k> (P:Noun : _):WideExp => P ... </k>

    // barcab
    rule <k> |_ \gap P \gap Q \gap -- => =| \gap P \gap |% \gap Q \gap -- ... </k>

    // barcen
    rule <k> |% \gap P \gap -- => core(P, S) ... </k>
         <subject> S </subject>

    // bardot
    rule <k> |. \gap P => |% \gap ++ \gap $ \gap P \gap -- ... </k>
    rule <k> |.(P) => |% \gap ++ \gap $ \gap P \gap -- ... </k>

    // barhep
    rule <k> |- \gap P => =< \gap $ \gap |. \gap P ... </k>
    rule <k> |-(P) => =<($ \ace |.(P)) ... </k>

    // bartis
    rule <k> |= \gap P \gap Q => =+ \gap ^~(^*(P)) \gap |% \gap ++ \gap $ \gap Q \gap -- ... </k>
    rule <k> |=(P \ace Q) => =+ \gap ^~(^*(P)) \gap |% \gap ++ \gap $ \gap Q \gap -- ... </k>

    // colhep
    rule <k> :- \gap ({T1; N1}, P) \gap ({T2; N2}, Q) => ({[T1 \ace T2]; [N1 \ace N2]}, cell(P, Q)) ... </k>
    rule <k> :-(({T1; N1}, P) \ace ({T2; N2}, Q)) => ({[T1 \ace T2]; [N1 \ace N2]}, cell(P, Q)) ... </k>

    // dottis TODO type union ?(%.y %.n)
    rule <k> .= \gap P \gap Q => ({?; .ArmNames}, %.y) ... </k> requires fundEq(P, Q)
    rule <k> .=(P \ace Q) => ({?; .ArmNames}, %.y) ... </k> requires fundEq(P, Q)
    rule <k> .= \gap _ \gap _ => ({?; .ArmNames}, %.n) ... </k> [owise]
    rule <k> .=(_ \ace _) => ({?; .ArmNames}, %.n) ... </k> [owise]

    // kethep
    rule <k> ^- \gap T \gap Q => ^+ \gap ^* \gap T \gap Q ... </k>
    rule <k> ^-(T \ace Q) => ^+(^*(T) \ace Q) ... </k>

    // ketlus
    rule <k> ^+ \gap ({T1; _}, _) \gap ({T2; _}, Q) => ({T1; .ArmNames}, toType(T1, Q)) ... </k> requires nests(T1, T2)
    rule <k> ^+(({T1; _}, _) \ace ({T2; _}, Q)) => ({T1; .ArmNames}, toType(T1, Q)) ... </k> requires nests(T1, T2)

    // ketsig TODO
    rule <k> ^~ \gap P => P ... </k>
    rule <k> ^~(P) => P ... </k>

    // kettar
    rule <k> ^* \gap T => bunt(T) ... </k>
    rule <k> ^*(T) => bunt(T) ... </k>

    // kettis
    rule <k> ^= \gap N \gap ({T; M}, Q) => ({N=T; M}, name(N, Q)) ... </k>
    rule <k> ^=(N \ace ({T; M}, Q)) => ({N=T; M}, name(N, Q)) ... </k>

    // tisbar
    rule <k> =| \gap P \gap Q => =+ \gap ^* \gap P \gap Q ... </k>
    rule <k> =| (P \ace Q) => =+(^*(P) \ace Q) ... </k>

    // tisgal
    rule <k> =< \gap P \gap Q => => \gap Q \gap P ... </k>
    rule <k> =<(P \ace Q) => =>(Q \ace P) ... </k>

    // tisgar
    rule <k> => \gap P \gap Q => Q ... </k>
         <subject> _ => P </subject>
    rule <k> => (P \ace Q) => Q ... </k>
         <subject> _ => P </subject>

    // tislus
    rule <k> =+ \gap P \gap Q => => \gap metaCell(P, S) \gap Q ... </k>
         <subject> S </subject>
    rule <k> =+(P \ace Q) => =>(metaCell(P, S) \ace Q) ... </k>
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
    rule <k> ?= \gap T \gap (_, Q) => ({?; .ArmNames}, %.y) ... </k> requires weakNests(T, Q)
    rule <k> ?=(T \ace (_, Q)) => ({?; .ArmNames}, %.y) ... </k> requires weakNests(T, Q)
    rule <k> ?= \gap _ \gap _ => ({?; .ArmNames}, %.n) ... </k> [owise]
    rule <k> ?=(_ \ace _) => ({?; .ArmNames}, %.n) ... </k> [owise]
endmodule

module HOON-META
    imports HOON-SYNTAX

    // Used to keep track of meta information of a noun
    syntax MetaNoun ::= "(" Meta "," Noun ")"

    // Type and list of arm names
    syntax Meta ::= "{" Spec ";" ArmNames "}"

    syntax ArmNames ::= List{TasText, ","}
                      | "[" ArmNames "\\ace" ArmNames "]"

    syntax TallExp ::= MetaNoun
    syntax WideExp ::= MetaNoun
endmodule

module HOON-CORES
    imports HOON-SYNTAX

    // Arms are encoded as a list of Hoon code instead of a Nock formula
    syntax Core ::= "[" Battery "\\ace" Hoon "]" [strict(2)]

    syntax Battery ::= List{Hoon, "\\sep"}

    syntax Noun ::= Core
endmodule

module HOON-HELPER
    imports HOON-SYNTAX
    imports HOON-META
    imports HOON-CORES
    imports INT
    imports STRING
    imports K-EQUAL
    imports BOOL

    // Make implicit brackets explicit
    syntax Cell ::= explicitBrackets(Cell) [function]

    rule [P \ace Q \ace R]:Cell => explicitBrackets([P \ace Q \ace R])
    rule explicitBrackets([P \ace Q \ace R \ace REST]:Cell) => [P \ace explicitBrackets([Q \ace R \ace REST])]
    rule explicitBrackets([P \ace Q \ace .CellImplicit]:Cell) => [P \ace Q]

    // Create a cell from the given nouns
    syntax Cell ::= cell(Noun, Noun) [function]

    rule cell(P, Q) => [P \ace Q]

    // Create a cell from the given meta nouns
    syntax Cell ::= metaCell(MetaNoun, MetaNoun) [function]

    rule metaCell(P, Q) => [P \ace Q]

    // Convert each atom in a noun to its underlying unsigned integer
    syntax IntNoun ::= Int | IntCell
                     | toUnsignedInts(Noun) [function]
    syntax IntCell ::= "[" IntNoun IntNoun "]"

    rule toUnsignedInts(P:Atom) => toUnsignedInt(P)
    rule toUnsignedInts(_=P) => toUnsignedInt(P)
    rule toUnsignedInts([P \ace Q]:Cell) => [toUnsignedInts(P) toUnsignedInts(Q)]

    // Convert an atom to its underlying unsigned integer
    syntax Int ::= toUnsignedInt(Atom) [function]

    rule toUnsignedInt(~) => 0
    rule toUnsignedInt(%A:TasText) => String2Base(TextToHex(TasTextToString(A)), 16)
    rule toUnsignedInt(%.y) => 0
    rule toUnsignedInt(%.n) => 1
    rule toUnsignedInt(%A:UD) => String2Int(replaceAll(UDToString(A), ".", ""))
    rule toUnsignedInt(%A:UI) => String2Int(replaceFirst(UIToString(A), "0i", ""))
    rule toUnsignedInt(%$) => 0
    rule toUnsignedInt(A:UD) => String2Int(replaceAll(UDToString(A), ".", ""))
    rule toUnsignedInt(A:UI) => String2Int(replaceFirst(UIToString(A), "0i", ""))

    // Check if the nouns are fundamentally equal
    syntax Bool ::= fundEq(MetaNoun, MetaNoun) [function]

    rule fundEq((_, P), (_, Q)) => toUnsignedInts(P) ==K toUnsignedInts(Q) [owise]
    // Special case for cores because arms are not encoded as Nock formulas
    rule fundEq(({[_ \ace T2]; [N1 \ace N2]}, [P1 \ace P2]:Core), ({[_ \ace U2]; [M1 \ace M2]}, [Q1 \ace Q2]:Core)) => batteryEq(P1, N1, Q1, M1) andBool fundEq(({T2; N2}, P2), ({U2; M2}, Q2))
    rule fundEq((_, _:Core), _) => false [priority(51)]
    rule fundEq(_, (_, _:Core)) => false [priority(51)]

    // Check if batteries are equal
    syntax Bool ::= batteryEq(Battery, ArmNames, Battery, ArmNames) [function]

    rule batteryEq(P, N1, Q, N2) => eqLength(N1, N2) andBool eqCode(P, Q) andBool sameArmsEq(P, N1, Q, N2)

    // Check if the length of the arm name lists are equal
    syntax Bool ::= eqLength(ArmNames, ArmNames) [function]

    rule eqLength(.ArmNames, .ArmNames) => true
    rule eqLength((_, P), (_, Q)) => eqLength(P, Q)
    rule eqLength(_, _) => false [owise]

    // Check if the batteries contain the same code (assumes equal length)
    syntax Bool ::= eqCode(Battery, Battery) [function]

    rule eqCode(P:Hoon, Q) => inBattery(P, Q)
    rule eqCode(P1 \sep P, Q) => inBattery(P1, Q) andBool eqCode(P, Q) [owise]

    // Check if Hoon code is in the battery
    syntax Bool ::= inBattery(Hoon, Battery) [function]

    rule inBattery(P, Q:Hoon) => P ==K Q
    rule inBattery(P, Q1 \sep _) => true requires P ==K Q1
    rule inBattery(P, Q1 \sep Q) => inBattery(P, Q) requires P =/=K Q1
    rule inBattery(_, _) => false [owise]

    // Check if the arms with the same name in the different batteries contain
    // the same code (assumes equal length)
    syntax Bool ::= sameArmsEq(Battery, ArmNames, Battery, ArmNames) [function]

    rule sameArmsEq(P:Hoon, N:TasText, Q, M) => P ==K getBatteryCode(N, Q, M) requires inArm(N, M)
    rule sameArmsEq(P1 \sep P, (N1, N), Q, M) => P1 ==K getBatteryCode(N1, Q, M) andBool sameArmsEq(P, N, Q, M) requires inArm(N1, M) [priority(51)]
    rule sameArmsEq(_, _, _, _) => true [owise]

    // Get battery code by arm name
    syntax Hoon ::= getBatteryCode(TasText, Battery, ArmNames) [function]

    rule getBatteryCode(N, P:Hoon, M:TasText) => P requires N ==K M
    rule getBatteryCode(N, P1 \sep _, (M1, _)) => P1 requires N ==K M1 [owise]
    rule getBatteryCode(N, _ \sep P, (M1, M)) => getBatteryCode(N, P, M) requires N =/=K M1 [owise]

    // Check if name is in arm names
    syntax Bool ::= inArm(TasText, ArmNames) [function]

    rule inArm(N, M:TasText) => N ==K M
    rule inArm(N, (M1, _)) => true requires N ==K M1 [owise]
    rule inArm(N, (M1, M)) => inArm(N, M) requires N =/=K M1 [owise]

    // Check if the second Spec nests in the first
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
    rule nests(@tas, @) => true
    rule nests(@u, _:AInt) => true
    rule nests(@u, @) => true
    rule nests(@ud, @ud) => true
    rule nests(@ud, @) => true
    rule nests(@ui, @ui) => true
    rule nests(@ui, @) => true
    rule nests(P:TAS, Q:TAS) => true requires P ==K Q
    rule nests([P1 \ace P2], [Q1 \ace Q2]) => nests(P1, Q1) andBool nests(P2, Q2)
    rule nests(_=P, Q) => nests(P, Q)
    rule nests(P, _=Q) => nests(P, Q)
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
    rule weakNests([P1 \ace P2], [Q1 \ace Q2]:Cell) => weakNests(P1, Q1) andBool weakNests(P2, Q2)
    rule weakNests([P1 \ace P2], [Q1 \ace Q2]:Core) => weakNests(P1, Q1) andBool weakNests(P2, Q2)
    rule weakNests([P1 \ace P2 \ace Ps], Q) => weakNests([P1 \ace P2], Q) requires Ps ==K .SpecCellImplicit
    rule weakNests([P1 \ace P2 \ace Ps], [Q1 \ace Q2]:Cell) => weakNests(P1, Q1) andBool weakNests([P2 \ace Ps], Q2)
    rule weakNests(_, _) => false [owise]

    // Infer type of noun
    // TODO type union ?(%.y %.n)
    //      input can be any Hoon, not just nouns (e.g. zapgar a rune exp)
    syntax Spec ::= typeOf(Noun) [function]

    rule typeOf(%.y) => ?
    rule typeOf(%.n) => ?
    rule typeOf(P:TAS) => P [owise]
    rule typeOf(_:UD) => @ud
    rule typeOf(_:UI) => @ui
    rule typeOf(_:Null) => @ // TODO type of null? %~
    rule typeOf([P \ace Q]:Cell) => [typeOf(P) \ace typeOf(Q)]
    rule typeOf([_ \ace Q]:Core) => [* \ace typeOf(Q)]
    rule typeOf(P=Q) => P=typeOf(Q)

    // Bunt value of spec
    syntax MetaNoun ::= bunt(Spec) [function]

    rule bunt([P \ace Q]) => ({[getSpec(bunt(P)) \ace getSpec(bunt(Q))]; [emptyArmNames(getNoun(bunt(P))) \ace emptyArmNames(getNoun(bunt(Q)))]}, cell(getNoun(bunt(P)), getNoun(bunt(Q))))
    rule bunt([P \ace Q \ace REST]) => bunt([P \ace Q]) requires REST ==K .SpecCellImplicit
    rule bunt([P \ace Q \ace REST]) => ({[getSpec(bunt(P)) \ace getSpec(bunt([Q \ace REST]))]; [emptyArmNames(getNoun(bunt(P))) \ace emptyArmNames(getNoun(bunt(Q)))]}, cell(getNoun(bunt(P)), getNoun(bunt([Q \ace REST]))))
    rule bunt(P=Q) => ({P=getSpec(bunt(Q)); emptyArmNames(getNoun(bunt(Q)))}, P=getNoun(bunt(Q)))
    rule bunt(P:TAS) => ({P; .ArmNames}, P)
    rule bunt(*) => ({*; .ArmNames}, StringToUD("0"))
    rule bunt(@) => ({@; .ArmNames}, StringToUD("0"))
    rule bunt(^) => ({[* \ace *]; [.ArmNames \ace .ArmNames]}, cell(StringToUD("0"), StringToUD("0")))
    rule bunt(?) => ({?; .ArmNames}, %.y) // TODO type should be type union ?(%.y %.n)
    rule bunt(~) => ({~; .ArmNames}, ~) // TODO zapgar gives: %~
    rule bunt(@tas) => ({@tas; .ArmNames}, %$)
    rule bunt(@u) => ({@u; .ArmNames}, StringToUD("0"))
    rule bunt(@ud) => ({@ud; .ArmNames}, StringToUD("0"))
    rule bunt(@ui) => ({@ui; .ArmNames}, 0i0)

    // Get noun from meta noun
    syntax Noun ::= getNoun(MetaNoun) [function]

    rule getNoun((_, N)) => N

    // Get spec (type) from meta noun
    syntax Spec ::= getSpec(MetaNoun) [function]

    rule getSpec(({T; _}, _)) => T

    // Get arm names from meta noun
    syntax ArmNames ::= getArmNames(MetaNoun) [function]

    rule getArmNames(({_; N}, _)) => N

    // Bind a name to a value
    syntax Noun ::= name(Skin, Noun) [function]

    rule name(N:TasText, P) => N=P
    rule name(N1=N2, P) => N1=name(N2, P)
    rule name([N1 \ace N2], [P1 \ace P2]:Cell) => cell(name(N1, P1), name(N2, P2))
    rule name([N1 \ace N2 \ace Ns], P) => name([N1 \ace N2], P) requires Ns ==K .SkinCellImplicit
    rule name([N1 \ace N2 \ace Ns], [P1 \ace P2]:Cell) => cell(name(N1, P1), name([N2 \ace Ns], P2))

    // Convert the underlying integer in the given Noun to the corresponding
    // type in Spec
    // TODO Make exhaustive
    syntax Noun ::= toType(Spec, Noun) [function]

    rule toType(@tas, Q:UD) => % StringToTasText(UDToText(Q))
    rule toType([T1 \ace T2], [P \ace Q]:Cell) => cell(toType(T1, P), toType(T2, Q))
    rule toType(_, Q) => Q [owise]

    // Lark the given meta noun
    syntax MetaNoun ::= lark(String, MetaNoun) [function]

    rule lark(L, ({[T \ace _]; [N \ace _]}, [P \ace _]:Cell)) => lark(tail(L), ({T; N}, P)) requires (head(L) ==K "-") orBool (head(L) ==K "<")
    rule lark(L, ({[_ \ace T]; [_ \ace N]}, [_ \ace Q]:Cell)) => lark(tail(L), ({T; N}, Q)) requires (head(L) ==K "+") orBool (head(L) ==K ">")
    rule lark(L, ({[_ \ace T]; [_ \ace N]}, [_ \ace Q]:Core)) => lark(tail(L), ({T; N}, Q)) requires (head(L) ==K "+") orBool (head(L) ==K ">")
    rule lark("", P) => P

    // Convert a positive integer to a lark string
    syntax String ::= toLarkString(Int) [function]

    rule toLarkString(1) => ""
    rule toLarkString(I) => toLarkString(I /Int 2) +String "-" requires (I >Int 1) andBool (I %Int 2 ==Int 0) andBool (log2Int(I) %Int 2 =/=Int 0)
    rule toLarkString(I) => toLarkString(I /Int 2) +String "<" requires (I >Int 1) andBool (I %Int 2 ==Int 0) andBool (log2Int(I) %Int 2 ==Int 0)
    rule toLarkString(I) => toLarkString((I -Int 1) /Int 2) +String "+" requires (I >Int 1) andBool (I %Int 2 =/=Int 0) andBool (log2Int(I) %Int 2 =/=Int 0)
    rule toLarkString(I) => toLarkString((I -Int 1) /Int 2) +String ">" requires (I >Int 1) andBool (I %Int 2 =/=Int 0) andBool (log2Int(I) %Int 2 ==Int 0)

    // Lookup wing in the given meta noun (Hoon)
    syntax Hoon ::= lookup(WingStack, Hoon, MetaNounStack, Int) [function]
    syntax WingStack ::= List{SubjectExp, "->"}
    syntax MetaNounStack ::= List{MetaNoun, "->"}

    rule lookup(P:NumAddr, Q, _, _) => lark(toLarkString(NumAddrToInt(P)), Q)
    rule lookup(P:Lark, Q, _, _) => lark(LarkToString(P), Q)
    rule lookup(P:TasText, ({_ = T; N}, Q1 = Q2), _, 0) => ({T; N}, Q2) requires P ==K Q1
    rule lookup(P:TasText, ({_; [N \ace _]}, Q:Core), _, 0) => coreCode(P, N, Q) requires nameInList(P, N)
    rule lookup(P:TasText, (_, Q = _), R1->R, I) => lookup(P, R1, R, I -Int 1)  requires P ==K Q andBool I >Int 0
    rule lookup(P:TasText, ({_; [N \ace _]}, _:Core), R1->R, I) => lookup(P, R1, R, I -Int 1)  requires nameInList(P, N) andBool I >Int 0
    rule lookup(P:TasText, ({[T1 \ace T2]; [N1 \ace N2]}, [Q1 \ace Q2]:Cell), R, I) => lookup(P, ({T1; N1}, Q1), ({T2; N2}, Q2)->R, I)
    rule lookup(P:TasText, ({[_ \ace T2]; [_ \ace N2]}, [_ \ace Q2]:Core), R, I) => lookup(P, ({T2; N2}, Q2), R, I) [owise]
    rule lookup(P:TasText, _, R1->R, I) => lookup(P, R1, R, I) [owise]
    rule lookup(P:SkipTasText, Q, R, _) => lookup(getTasText(P), Q, R, numberOfSkips(P))
    rule lookup(P->PS, Q, R, I) => lookup(PS, lookup(P, Q, R, I), R, I) requires PS =/=K .WingStack

    // Get the code in the battery that the wing refers to
    syntax Hoon ::= coreCode(TasText, ArmNames, Core) [function]

    rule coreCode(P, (N, _), [Q \sep _ \ace _]) => Q requires P ==K N
    rule coreCode(P, (_, N), [_ \sep Q \ace R]) => coreCode(P, N, [Q \ace R]) [owise]

    // Check if wing is in arm names
    syntax Bool ::= nameInList(TasText, ArmNames) [function]

    rule nameInList(_, .ArmNames) => false
    rule nameInList(P, (N, _)) => true requires P ==K N
    rule nameInList(P, (_, N)) => nameInList(P, N) [owise]

    // Convert wing into a stack of names/larks
    syntax WingStack ::= toWingStack(SubjectExp, WingStack) [function]

    rule toWingStack(P.Q, R) => toWingStack(Q, P->R)
    rule toWingStack(P, R) => P->R [owise]

    // Construct empty ArmNames matching the noun structure
    syntax ArmNames ::= emptyArmNames(Noun) [function]

    rule emptyArmNames(_:Atom) => .ArmNames
    rule emptyArmNames(_:Cell) => [.ArmNames \ace .ArmNames]
    rule emptyArmNames(_=Q) => emptyArmNames(Q)

    // Get arm names from arms
    syntax ArmNames ::= armNames(ArmList) [function]

    rule armNames(.ArmList) => .ArmNames
    rule armNames(++ \gap P \gap _) => P
    rule armNames(++ \gap P \gap _ \gap REST) => P, armNames(REST)

    // Construct battery from arms
    syntax Battery ::= battery(ArmList) [function]

    rule battery(.ArmList) => .Battery
    rule battery(++ \gap _ \gap Q) => Q
    rule battery(++ \gap _ \gap Q \gap REST) => Q \sep battery(REST)

    // Produce a core from the given arms and payload
    syntax MetaNoun ::= core(ArmList, MetaNoun) [function]

    rule core(P, R) => ({[* \ace getSpec(R)]; [armNames(P) \ace getArmNames(R)]}, [battery(P) \ace getNoun(R)])

    // Helper functions
    syntax TasText ::= StringToTasText(String) [function, total, hook(STRING.string2token)]
    syntax UD ::= StringToUD(String) [function, total, hook(STRING.string2token)]

    syntax String ::= TasTextToString(TasText) [function, total, hook(STRING.token2string)]
                    | UDToString(UD) [function, total, hook(STRING.token2string)]
                    | UIToString(UI) [function, total, hook(STRING.token2string)]
                    | LarkToString(Lark) [function, total, hook(STRING.token2string)]
                    | SkipTasTextToString(SkipTasText) [function, total, hook(STRING.token2string)]
                    | NumAddrToString(NumAddr) [function, total, hook(STRING.token2string)]

    syntax Int ::= NumAddrToInt(NumAddr) [function]
    rule NumAddrToInt(P) => String2Int(tail(NumAddrToString(P)))

    syntax TasText ::= getTasText(SkipTasText) [function]
    rule getTasText(P) => StringToTasText(cutSkips(SkipTasTextToString(P)))

    syntax String ::= cutSkips(String) [function]
    rule cutSkips(P) => cutSkips(tail(P)) requires head(P) ==String "^"
    rule cutSkips(P) => P [owise]

    syntax Int ::= numberOfSkips(SkipTasText) [function]
    rule numberOfSkips(P) => ketPrefixLength(SkipTasTextToString(P))

    syntax Int ::= ketPrefixLength(String) [function]
    rule ketPrefixLength(P) => ketPrefixLength(tail(P)) +Int 1 requires head(P) ==String "^"
    rule ketPrefixLength(_) => 0 [owise]

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
