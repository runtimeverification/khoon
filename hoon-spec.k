requires "hoon.k"
requires "domains.md"

module HOON-SPEC-SYNTAX
    imports HOON-SYNTAX

    syntax UD ::= "0" [token]
                | "1" [token]
                | "2" [token]
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
endmodule

module VERIFICATION
    imports HOON-SPEC-SYNTAX
    imports HOON

endmodule

module HOON-SPEC
    imports VERIFICATION

    // :-(0 1) => [0 1]
    claim <k>
            :-(0 \ace 1)
          =>
            ({[@ud \ace @ud]; ?_}, [0 \ace 1]:Cell)
            ...
          </k>

    // c is a or b
    claim <k>
            =/ \gap a \gap A:UD \gap
            =/ \gap b \gap B:UD \gap
            =/ \gap c \gap
              ?:(.=(a \ace .+(b)) \ace a \ace b) \gap
            c
          =>
            ({@ud; ?_}, ?C)
            ...
          </k>
          <subject> _:MetaNoun </subject>
          ensures (?C ==K A) orBool (?C ==K B)

    // c is a or b (gate version)
    claim <k>
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
          <subject> _:MetaNoun </subject>
          ensures (?C ==K A) orBool (?C ==K B)

    // (dec 1) => 0
    claim <k>
            =< \gap
            %-(dec \ace 1) \gap
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
            (?_, 0)
            ...
          </k>
          <subject> _:MetaNoun </subject>

    // (add [0 1]) => 1
    claim <k>
            =< \gap
            %-(add \ace [0 \ace 1]:Cell) \gap
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
            (?_, 1)
            ...
          </k>
          <subject> _:MetaNoun </subject>

    // Sum one through five
    claim <k>
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
            (?_, 15)
            ...
          </k>
          <subject> _:MetaNoun </subject>
endmodule
