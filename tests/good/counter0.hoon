=<
=/  counter  1
=/  sum  0
|-
?:  .=(counter 6)
  sum
%=  $
  counter  %-(add [counter 1])
  sum      %-(add [sum counter])
==
|%
++  add
  |=  [a=@ b=@]
  ^-  @
  ?:  .=(0 a)  b
  %=($ a %-(dec a), b .+(b))
++  dec
  |=  a=@
  ?<  .=(0 a)
  =+  b=0
  |-  ^-  @
  ?:  .=(a .+(b))  b
  %=($ b .+(b))
--
