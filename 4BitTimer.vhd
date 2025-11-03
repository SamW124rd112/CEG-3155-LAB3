LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY nBitTimer IS 
  PORT(
      GENERIC(n: INTEGER := 4);
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      MST, SST  :STD_LOGIC_VECTOR(n-1 downto 0);
      )
END nBitTimer;

ARCHITECTURE structural OF nBitTimer IS 

  COMPONENT nBitCounter




  COMPONENT nBitComparator
