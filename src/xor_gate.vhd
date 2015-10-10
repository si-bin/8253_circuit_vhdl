library ieee;
use ieee.std_logic_1164.all;
----------------------------
-- XOR gate
----------------------------
ENTITY xor_gate IS
  GENERIC(delay: TIME:=3 ns);
  port(
    x:IN BIT;
    y:IN BIT;
    F:out BIT
    );
    

END xor_gate;
ARCHITECTURE behaviour OF xor_gate IS
-- behaviour of xor_gate
BEGIN
  F<=x XOR y AFTER delay;     
END behaviour;  
