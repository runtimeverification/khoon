requires "hoon.k"
requires "domains.md"

module HOON-SPEC-SYNTAX
    imports HOON-SYNTAX

    syntax UD ::= "0" [token]
                | "1" [token]
                | "6" [token]
                | "15" [token]

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
endmodule

module HOON-SPEC
    imports VERIFICATION

    // :-(0 1) => [0 1]
    claim [cell]:
          <k>
            :-(0 \ace 1)
          =>
            ({[@ud \ace @ud]; ?_}, [0 \ace 1]:Cell)
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
            =/ \gap counter \gap 1 \gap
            =/ \gap sum \gap 0 \gap
            |- \gap
            ?: \gap .=(counter \ace 6) \gap
              sum \gap
            %= \gap $ \gap
              counter \gap %-(add \ace [counter \ace 1]:Cell) \gap
              sum \gap %-(add \ace [sum \ace counter]:Cell) \gap
            == \gap
            |% \gap
            ++ \gap add \gap
              |= \gap [a=@\aceb=@] \gap
              ^- \gap @ \gap
              ?: \gap .=(0 \ace a) \gap b \gap
              %=($ \ace a \ace %-(dec \ace a),\ace b \ace .+(b)) \gap
            ++ \gap dec \gap
              |= \gap a=@ \gap
              ?< \gap .=(0 \ace a) \gap
              =+ \gap b=0 \gap
              |- \gap ^- \gap @ \gap
              ?: \gap .=(a \ace .+(b)) \gap b \gap
              %=($ \ace b \ace .+(b)) \gap
            --
          =>
            ({@; ?_}, 15)
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
              ?< \gap .=(0 \ace a) \gap
              =+ \gap b=0 \gap
              |- \gap ^- \gap @ \gap
              ?: \gap .=(a \ace .+(b)) \gap b \gap
              %=($ \ace b \ace .+(b)) \gap
            --
          =>
            ({@; ?_}, ?B)
            ...
          </k>
          <subject> _->.Subject </subject>
          requires UDToInt(A) >Int UDToInt(0)
          ensures  UDToInt(?B) ==Int UDToInt(A) -Int UDToInt(1)

    // (add [A B]) => A + B
    claim [add]:
          <k>
            =< \gap
            %-(add \ace [A:UD \ace B:UD]:Cell) \gap
            |% \gap
            ++ \gap add \gap
              |= \gap [a=@\aceb=@] \gap
              ^- \gap @ \gap
              ?: \gap .=(0 \ace a) \gap b \gap
              %=($ \ace a \ace %-(dec \ace a),\ace b \ace .+(b)) \gap
            ++ \gap dec \gap
              |= \gap a=@ \gap
              ?< \gap .=(0 \ace a) \gap
              =+ \gap b=0 \gap
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
              ?: \gap .=(0 \ace b) \gap a \gap
              %=($ \ace a \ace %-(dec \ace a),\ace b \ace %-(dec \ace b)) \gap
            ++ \gap dec \gap
              |= \gap a=@ \gap
              ?< \gap .=(0 \ace a) \gap
              =+ \gap b=0 \gap
              |- \gap ^- \gap @ \gap
              ?: \gap .=(a \ace .+(b)) \gap b \gap
              %=($ \ace b \ace .+(b)) \gap
            --
          =>
            ({@; ?_}, ?C)
            ...
          </k>
          <subject> _->.Subject </subject>
          requires UDToInt(B) >Int UDToInt(0) andBool
                   UDToInt(A) >Int UDToInt(0) andBool
                   UDToInt(A) >=Int UDToInt(B)
          ensures  UDToInt(?C) ==Int UDToInt(A) -Int UDToInt(B)

    // (mul [A B] => A * B
    claim [mul]:
          <k>
            =< \gap
            %-(mul \ace [A:UD \ace B:UD]:Cell) \gap
            |% \gap
            ++ \gap mul \gap
              |: \gap [^=(a \ace ^-(@ \ace 1)) \ace ^=(b \ace ^-(@ \ace 1))]:Cell \gap
              ^- \gap @ \gap
              =+ \gap c=0 \gap
              |- \gap
              ?: \gap .=(0 \ace a) \gap c \gap
              %=($ \ace a \ace %-(dec \ace a),\ace c \ace %-(add \ace [b \ace c]:Cell)) \gap
            ++ \gap add \gap
              |= \gap [a=@\aceb=@] \gap
              ^- \gap @ \gap
              ?: \gap .=(0 \ace a) \gap b \gap
              %=($ \ace a \ace %-(dec \ace a),\ace b \ace .+(b)) \gap
            ++ \gap dec \gap
              |= \gap a=@ \gap
              ?< \gap .=(0 \ace a) \gap
              =+ \gap b=0 \gap
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
