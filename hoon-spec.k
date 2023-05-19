requires "hoon.k"
requires "domains.md"

module HOON-SPEC-SYNTAX
    imports HOON-SYNTAX

    syntax Name ::= "a" [token]
                  | "b" [token]
                  | "c" [token]
                  | "foo" [token]
                  | "dec" [token]
                  | "add" [token]
                  | "counter" [token]
                  | "sum" [token]
                  | "sub" [token]
                  | "mul" [token]
endmodule

module VERIFICATION
    imports HOON-SPEC-SYNTAX
    imports HOON

    rule StringToUD(IntStringToUDString(Int2String(String2Int(replace(UDToString(A), ".", "", countAllOccurrences(UDToString(A), ".")))))) => A [simplification]
    rule String2Int(replace(UDToString(StringToUD(IntStringToUDString(Int2String(String2Int(replace(UDToString(A), ".", "", countAllOccurrences(UDToString(A), "."))) +Int I)))), ".", "", countAllOccurrences(UDToString(StringToUD(IntStringToUDString(Int2String(String2Int(replace(UDToString(A), ".", "", countAllOccurrences(UDToString(A), "."))) +Int I)))), "."))) => String2Int(replace(UDToString(A), ".", "", countAllOccurrences(UDToString(A), "."))) +Int I [simplification]
    rule String2Int ( replace ( UDToString ( A:UD ) , "." , "" , countAllOccurrences ( UDToString ( A:UD ) , "." ) ) ) >Int 1 => true
         requires String2Int ( replace ( UDToString ( A:UD ) , "." , "" , countAllOccurrences ( UDToString ( A:UD ) , "." ) ) ) >Int 0 andBool
                  #Not ( { 1 #Equals String2Int ( replace ( UDToString ( A:UD ) , "." , "" , countAllOccurrences ( UDToString ( A:UD ) , "." ) ) ) } ) [simplification]
    rule {
           String2Int ( replace ( UDToString ( B ) , "." , "" , countAllOccurrences ( UDToString ( B ) , "." ) ) ) +Int 2
         #Equals
           String2Int ( replace ( UDToString ( A ) , "." , "" , countAllOccurrences ( UDToString ( A ) , "." ) ) )
         }
        =>
         {
           StringToUD ( IntStringToUDString ( Int2String ( String2Int ( replace ( UDToString ( A ) , "." , "" , countAllOccurrences ( UDToString ( A ) , "." ) ) ) +Int -1 ) ) )
         #Equals
           StringToUD ( IntStringToUDString ( Int2String ( String2Int ( replace ( UDToString ( B ) , "." , "" , countAllOccurrences ( UDToString ( B ) , "." ) ) ) +Int 1 ) ) )
         } [simplification]
    rule {
           String2Int ( replace ( UDToString ( A ) , "." , "" , countAllOccurrences ( UDToString ( A ) , "." ) ) ) -Int I1
         #Equals
           String2Int ( replace ( UDToString ( B ) , "." , "" , countAllOccurrences ( UDToString ( B ) , "." ) ) ) +Int I2
         }
        =>
         {
           String2Int ( replace ( UDToString ( B ) , "." , "" , countAllOccurrences ( UDToString ( B ) , "." ) ) ) +Int (I1 +Int I2)
         #Equals
           String2Int ( replace ( UDToString ( A ) , "." , "" , countAllOccurrences ( UDToString ( A ) , "." ) ) )
         } [simplification]
    rule String2Int ( replace ( UDToString ( A:UD ) , "." , "" , countAllOccurrences ( UDToString ( A:UD ) , "." ) ) ) >Int String2Int ( replace ( UDToString ( B:UD ) , "." , "" , countAllOccurrences ( UDToString ( B:UD ) , "." ) ) ) +Int 2 => true
         requires String2Int ( replace ( UDToString ( A:UD ) , "." , "" , countAllOccurrences ( UDToString ( A:UD ) , "." ) ) ) >Int String2Int ( replace ( UDToString ( B:UD ) , "." , "" , countAllOccurrences ( UDToString ( B:UD ) , "." ) ) ) +Int 1 andBool
                  #Not ( { String2Int ( replace ( UDToString ( B:UD ) , "." , "" , countAllOccurrences ( UDToString ( B:UD ) , "." ) ) ) +Int 2 #Equals String2Int ( replace ( UDToString ( A:UD ) , "." , "" , countAllOccurrences ( UDToString ( A:UD ) , "." ) ) ) } ) [simplification]
    rule I >=Int String2Int ( replace ( UDToString ( B:UD ) , "." , "" , countAllOccurrences ( UDToString ( B:UD ) , "." ) ) ) => I -Int 1 >=Int String2Int ( replace ( UDToString ( B:UD ) , "." , "" , countAllOccurrences ( UDToString ( B:UD ) , "." ) ) )
        requires #Not ( {
                     I
                   #Equals
                     String2Int ( replace ( UDToString ( B:UD ) , "." , "" , countAllOccurrences ( UDToString ( B:UD ) , "." ) ) )
                   } ) [simplification]
    rule I >=Int String2Int(replace(UDToString(A), ".", "", countAllOccurrences(UDToString(A), "."))) => false requires I <Int 0 [simplification]
    rule 0 *Int String2Int ( replace ( UDToString ( B ) , "." , "" , countAllOccurrences ( UDToString ( B ) , "." ) ) ) => 0 [simplification]
endmodule

module HOON-SPEC
    imports VERIFICATION

    // :-(0 1) => [0 1]
    claim [cell]:
          <k>
            :-(StringToUD("0") \ace StringToUD("1"))
          =>
            ({[@ud \ace @ud]; ?_}, [StringToUD("0") \ace StringToUD("1")]:Cell)
            ...
          </k>

    // c is a or b
    claim [AorB0]:
          <k>
            =/ \gap a \gap A:UD \gap
            =/ \gap b \gap B:UD \gap
            =/ \gap c \gap
              ?:(.=(a \ace .+(b)) \ace a \ace b) \gap
            c
          =>
            ({@ud; ?_}, ?C)
            ...
          </k>
          <subject> _->.Subject </subject>
          ensures ?C ==K A orBool ?C ==K B

    // c is a or b (gate version)
    claim [AorB1]:
          <k>
            =< \gap
            %-(foo \ace [A:UD \ace B:UD]:Cell) \gap
            ^= \gap foo \gap
            |= \gap [a=@ud \ace b=@ud] \gap
            ^- \gap @ \gap
            =/ \gap c \gap
              ?:(.=(a \ace .+(b)) \ace a \ace b) \gap
            c
          =>
            ({@; ?_}, ?C)
            ...
          </k>
          <subject> _->.Subject </subject>
          ensures ?C ==K A orBool ?C ==K B

    // Sum one through five
    claim [sum]:
          <k>
            =< \gap
            =/ \gap counter \gap StringToUD("1") \gap
            =/ \gap sum \gap StringToUD("0") \gap
            |- \gap
            ?: \gap .=(counter \ace StringToUD("6")) \gap
              sum \gap
            %= \gap $ \gap
              counter \gap %-(add \ace [counter \ace StringToUD("1")]:Cell) \gap
              sum \gap %-(add \ace [sum \ace counter]:Cell) \gap
            == \gap
            |% \gap
            ++ \gap add \gap
              |= \gap [a=@\aceb=@] \gap
              ^- \gap @ \gap
              ?: \gap .=(StringToUD("0") \ace a) \gap b \gap
              %=($ \ace a \ace %-(dec \ace a),\ace b \ace .+(b)) \gap
            ++ \gap dec \gap
              |= \gap a=@ \gap
              ?< \gap .=(StringToUD("0") \ace a) \gap
              =+ \gap b=StringToUD("0") \gap
              |- \gap ^- \gap @ \gap
              ?: \gap .=(a \ace .+(b)) \gap b \gap
              %=($ \ace b \ace .+(b)) \gap
            --
          =>
            ({@; ?_}, StringToUD("15"))
            ...
          </k>
          <subject> _->.Subject </subject>

    // (dec A) => A - 1
    claim [dec]:
          <k>
            =< \gap
            %-(dec \ace A:UD) \gap
            |% \gap
            ++ \gap dec \gap
              |= \gap a=@ \gap
              ?< \gap .=(StringToUD("0") \ace a) \gap
              =+ \gap b=StringToUD("0") \gap
              |- \gap ^- \gap @ \gap
              ?: \gap .=(a \ace .+(b)) \gap b \gap
              %=($ \ace b \ace .+(b)) \gap
            --
          =>
            ({@; ?_}, ?B)
            ...
          </k>
          <subject> _->.Subject </subject>
          requires UDToInt(A) >Int 0
          ensures  UDToInt(?B) ==Int UDToInt(A) -Int 1

    claim [dec-loop-inv0]:
          <k>
            %= ( $ \ace b \ace .+ ( b ) )
          =>
            ({@; ?_}, IntToUD(UDToInt(A) -Int 1))
            ...
          </k>
          <subject>
            ( { [ * \ace [ b = T:Spec \ace [ * \ace [ a = @ud \ace [ * \ace _:Spec ] ] ] ] ] ; [ $ , .ArmNames \ace [ .ArmNames \ace [ $ , .ArmNames \ace [ .ArmNames \ace [ dec , .ArmNames \ace _:ArmNames ] ] ] ] ] } , [ ^- \gap @ \gap ?: \gap .= ( a \ace .+ ( b ) ) \gap b \gap %= ( $ \ace b \ace .+ ( b ) ,\ace .WingHoonWideList ) \sep .Battery \ace [ b = B:UD \ace [ ?< \gap .= ( StringToUD("0") \ace a ) \gap =+ \gap b = StringToUD("0") \gap |- \gap ^- \gap @ \gap ?: \gap .= ( a \ace .+ ( b ) ) \gap b \gap %= ( $ \ace b \ace .+ ( b ) ,\ace .WingHoonWideList ) \sep .Battery \ace [ a = A \ace [ |= \gap a = @ \gap ?< \gap .= ( StringToUD("0") \ace a ) \gap =+ \gap b = StringToUD("0") \gap |- \gap ^- \gap @ \gap ?: \gap .= ( a \ace .+ ( b ) ) \gap b \gap %= ( $ \ace b \ace .+ ( b ) ,\ace .WingHoonWideList ) \sep .Battery \ace _:Noun ] ] ] ] ] ) ->
            _:Subject
          </subject>
          requires (T ==K @ud orBool T ==K @) andBool
                   UDToInt(A) >Int UDToInt(B) +Int 1 [trusted]

    claim [dec-loop-inv1]:
          <k>
            %= ( $ \ace b \ace .+ ( b ) )
          =>
            ({@; ?_}, ?C)
            ...
          </k>
          <subject>
            ( { [ * \ace [ b = T:Spec \ace [ * \ace [ a = @ud \ace [ * \ace _:Spec ] ] ] ] ] ; [ $ , .ArmNames \ace [ .ArmNames \ace [ $ , .ArmNames \ace [ .ArmNames \ace [ dec , .ArmNames \ace _:ArmNames ] ] ] ] ] } , [ ^- \gap @ \gap ?: \gap .= ( a \ace .+ ( b ) ) \gap b \gap %= ( $ \ace b \ace .+ ( b ) ,\ace .WingHoonWideList ) \sep .Battery \ace [ b = B:UD \ace [ ?< \gap .= ( StringToUD("0") \ace a ) \gap =+ \gap b = StringToUD("0") \gap |- \gap ^- \gap @ \gap ?: \gap .= ( a \ace .+ ( b ) ) \gap b \gap %= ( $ \ace b \ace .+ ( b ) ,\ace .WingHoonWideList ) \sep .Battery \ace [ a = A \ace [ |= \gap a = @ \gap ?< \gap .= ( StringToUD("0") \ace a ) \gap =+ \gap b = StringToUD("0") \gap |- \gap ^- \gap @ \gap ?: \gap .= ( a \ace .+ ( b ) ) \gap b \gap %= ( $ \ace b \ace .+ ( b ) ,\ace .WingHoonWideList ) \sep .Battery \ace _:Noun ] ] ] ] ] ) ->
            _:Subject
          </subject>
          requires (T ==K @ud orBool T ==K @) andBool
                   UDToInt(A) >Int UDToInt(B) +Int 1
          ensures  UDToInt(?C) ==Int UDToInt(A) -Int 1

    // (add [A B]) => A + B
    claim [add]:
          <k>
            =< \gap
            %-(add \ace [A:UD \ace B:UD]:Cell) \gap
            |% \gap
            ++ \gap add \gap
              |= \gap [a=@\aceb=@] \gap
              ^- \gap @ \gap
              ?: \gap .=(StringToUD("0") \ace a) \gap b \gap
              %=($ \ace a \ace %-(dec \ace a),\ace b \ace .+(b)) \gap
            ++ \gap dec \gap
              |= \gap a=@ \gap
              ?< \gap .=(StringToUD("0") \ace a) \gap
              =+ \gap b=StringToUD("0") \gap
              |- \gap ^- \gap @ \gap
              ?: \gap .=(a \ace .+(b)) \gap b \gap
              %=($ \ace b \ace .+(b)) \gap
            --
          =>
            ({@; ?_}, ?C)
            ...
          </k>
          <subject> _->.Subject </subject>
          ensures UDToInt(?C) ==Int UDToInt(A) +Int UDToInt(B)

    // (sub [A B] => A - B
    claim [sub]:
          <k>
            =< \gap
            %-(sub \ace [A:UD \ace B:UD]:Cell) \gap
            |% \gap
            ++ \gap sub \gap
              |= \gap [a=@ \ace b=@] \gap
              ^- \gap @ \gap
              ?: \gap .=(StringToUD("0") \ace b) \gap a \gap
              %=($ \ace a \ace %-(dec \ace a),\ace b \ace %-(dec \ace b)) \gap
            ++ \gap dec \gap
              |= \gap a=@ \gap
              ?< \gap .=(StringToUD("0") \ace a) \gap
              =+ \gap b=StringToUD("0") \gap
              |- \gap ^- \gap @ \gap
              ?: \gap .=(a \ace .+(b)) \gap b \gap
              %=($ \ace b \ace .+(b)) \gap
            --
          =>
            ({@; ?_}, ?C)
            ...
          </k>
          <subject> _->.Subject </subject>
          requires UDToInt(A) >=Int UDToInt(B)
          ensures  UDToInt(?C) ==Int UDToInt(A) -Int UDToInt(B)

    // (mul [A B] => A * B
    claim [mul]:
          <k>
            =< \gap
            %-(mul \ace [A:UD \ace B:UD]:Cell) \gap
            |% \gap
            ++ \gap mul \gap
              |: \gap [^=(a \ace ^-(@ \ace StringToUD("1"))) \ace ^=(b \ace ^-(@ \ace StringToUD("1")))]:Cell \gap
              ^- \gap @ \gap
              =+ \gap c=StringToUD("0") \gap
              |- \gap
              ?: \gap .=(StringToUD("0") \ace a) \gap c \gap
              %=($ \ace a \ace %-(dec \ace a),\ace c \ace %-(add \ace [b \ace c]:Cell)) \gap
            ++ \gap add \gap
              |= \gap [a=@\aceb=@] \gap
              ^- \gap @ \gap
              ?: \gap .=(StringToUD("0") \ace a) \gap b \gap
              %=($ \ace a \ace %-(dec \ace a),\ace b \ace .+(b)) \gap
            ++ \gap dec \gap
              |= \gap a=@ \gap
              ?< \gap .=(StringToUD("0") \ace a) \gap
              =+ \gap b=StringToUD("0") \gap
              |- \gap ^- \gap @ \gap
              ?: \gap .=(a \ace .+(b)) \gap b \gap
              %=($ \ace b \ace .+(b)) \gap
            --
          =>
            ({@; ?_}, ?C)
            ...
          </k>
          <subject> _->.Subject </subject>
          ensures UDToInt(?C) ==Int UDToInt(A) *Int UDToInt(B)
endmodule
