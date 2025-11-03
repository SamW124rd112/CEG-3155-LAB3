LIBRARY ieee;
USE ieee.std_logic_1164.ALL;


ENTITY trafficLightController IS
    PORT(
        MSC, SSC              : IN  STD_LOGIC_VECTOR(3 downto 0);
        SSCS                  : IN  STD_LOGIC;
        G_Clock               : IN  STD_LOGIC;
        G_Reset               : IN  STD_LOGIC;  
        MSTL, SSTL            : OUT STD_LOGIC_VECTOR(2 downto 0));
END trafficLightController;

ARCHITECTURE structural OF trafficLightController IS
  SIGNAL int_SSCS, timerOut, int_Reset, int_Timer, int_Counter, int_s0, int_s1, int_Compare : STD_LOGIC;
  SIGNAL muxTimer, int_MST, int SST, int_MSC, int_SSC, muxCounter, max_MSC, max_SSC, muxOut : STD_LOGIC_VECTOR(3 downto 0);



  COMPONENT nBitComparator 
    GENERIC(n: INTEGER := 4);
    PORT(
      i_Ai, i_Bi			      : IN	STD_LOGIC_VECTOR(n-1 downto 0);
      o_GT, o_LT, o_EQ			: OUT	STD_LOGIC);
  END COMPONENT;

    COMPONENT nBitCounter 
      GENERIC(n : INTEGER := 4)
      PORT(
        i_resetBar, i_load	: IN	STD_LOGIC;
        i_clock			        : IN	STD_LOGIC;
        o_Value			        : OUT	STD_LOGIC_VECTOR(n-1 downto 0));
    END COMPONENT;

    COMPONENT debouncer
      PORT(
        i_raw			: IN	STD_LOGIC;
        i_clock			: IN	STD_LOGIC;
        o_clean			: OUT	STD_LOGIC);
    END COMPONENT;

    COMPONENT clk_div
      PORT(
        clock_25Mhz				: IN	STD_LOGIC;
        clock_1MHz				: OUT	STD_LOGIC;
        clock_100KHz				: OUT	STD_LOGIC;
        clock_10KHz				: OUT	STD_LOGIC;
        clock_1KHz				: OUT	STD_LOGIC;
        clock_100Hz				: OUT	STD_LOGIC;
        clock_10Hz				: OUT	STD_LOGIC;
        clock_1Hz				: OUT	STD_LOGIC);
    END COMPONENT;

    COMPONENT nBitMux2to1
      GENERIC(n: INTEGER := 4);
      PORT(
          i_sel       : IN  STD_LOGIC;
          i_d0, i_d1  : IN  STD_LOGIC_VECTOR(n-1 DOWNTO 0);
          o_q         : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0));
    END nBitMux2to1;

    COMPONENT fsmController 
      PORT(
        MSC, SSC, MST, SST, SSCS                : IN  STD_LOGIC;
        G_Clock                                 : IN  STD_LOGIC;
        G_Reset                                 : IN  STD_LOGIC;
        MSTL, SSTL                              : OUT STD_LOGIC_VECTOR(2 downto 0));
        resetCount, resetTimer, s0, s1          : OUT STD_LOGIC;
    END fsmController;

BEGIN

  timerMST: nBitCounter
    PORT MAP(
      i_resetBar  => int_Timer
      i_load      => '1'
      i_clock     => G_Clock
      o_Value     => int_MST
            );

  timerSST: nBitCounter
    PORT MAP(
      i_resetBar  => int_Timer
      i_load      => '1'
      i_clock     => G_Clock
      o_Value     => int_SST
            );

  counterMSC: nBitCounter
    PORT MAP(
      i_resetBar  => int_Counter
      i_load      => '1'
      i_clock     => G_Clock
      o_Value     => int_MSC
      o_q         => 
            );

  timerSSC: nBitCounter
    PORT MAP(
      i_resetBar  => int_Counter
      i_load      => '1'
      i_clock     => G_Clock
      o_Value     => int_SSC
      );       

  counterMux: nBitMux2to1
    GENERIC MAP(n => 4)
    PORT MAP(
     i_sel  => int_s0 
     i_d0   => int_MSC
     i_d1   => int_SSC
     q      => muxCounter
    );

  timerMux: nBitMux2to1
    GENERIC MAP(n => 4)
    PORT MAP(
     i_sel  => int_s0 
     i_d0   => int_MST
     i_d1   => int_SST
     q      => muxTimer
    );


  maxMux: nBitMux2to1
    GENERIC MAP(n => 4)
    PORT MAP(
      i_sel => int_s1
      i_d0  => MSC
      i_d1  => SSC
      q     => muxOut
    );

  comparator: nBitComparator
    GENERIC MAP(n => 4)
    PORT MAP(
     i_Ai => muxCounter 
     i_Bi => muxOut
     o_GT => open
     o_LT => open
     o_EQ => int_Compare
    );

  controller: fsmController
  PORT MAP(
    MSC         => int_Compare
    SSC         => int_Compare
    MST         => timerOut
    SST         => timerOut
    SSCS        => int_SSCS
    G_Clock     => G_Clock
    G_Reset     => G_Reset
    MSTL        => MSTL
    SSTL        => SSTL
    resetCount  => int_Counter 
    resetTimer  => int_Timer
    s0          => int_s0
    s1          => int_s1
   );


  sscsDebounce: debouncer
    PORT MAP(
      i_raw   => SSCS
      i_clock => G_Clock
      o_clean => int_SSCS
    );

  timerOut <= (timerMux(3) XOR '0')
              AND (timerMux(2) XOR '1')
              AND (timerMux(1) XOR '1')
              AND (timerMux(0) XOR '1');


end structural;




