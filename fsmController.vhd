LIBRARY ieee;
use ieee.std_logic_1164.ALL;

ENTITY fsmController IS
    PORT(
        MSC, SSC, MST, SST, SSCS                : IN  STD_LOGIC;
        G_Clock                                 : IN  STD_LOGIC;
        G_Reset                                 : IN  STD_LOGIC;
        MSTL, SSTL                              : OUT STD_LOGIC_VECTOR(2 downto 0));
        resetCount, resetTimer, s0, s1          : OUT STD_LOGIC;
END fsmController;

ARCHITECTURE structural OF fsmController IS 
  SIGNAL w, y1, y0          : STD _LOGIC;
  SIGNAL n_w, n_y1, n_y0    : STD_LOGIC;
  SIGNAL sA,sB,sC,sD        : STD_LOGIC;
  SIGNAL i_d0, i_d1         : STD_LOGIC;
  SIGNAL green, yellow, red : STD_LOGIC_VECTOR(2 downto 0);
  SIGNAL mux_MSTL, mux_SSTL : STD_LOGIC_VECTOR(2 downto 0);
 

  COMPONENT enARdFF_2
    PORT(
      i_resetBar	: IN	STD_LOGIC;
      i_d		: IN	STD_LOGIC;
      i_enable	: IN	STD_LOGIC;
      i_clock		: IN	STD_LOGIC;
      o_q, o_qBar	: OUT	STD_LOGIC);
  END COMPONENT;

BEGIN

  dFF_y1: enARdFF_2
    PORT MAP(
      i_resetBar  => G_Reset,
      i_d         => i_d1,
      i_enable    => '1',
      i_clock     => G_Clock,
      o_q         => y1,
      o_qBar      => n_y1,
       );


  dFF_y0: enARdFF_2
    PORT MAP(
      i_resetBar  => G_Reset,
      i_d         => i_d0,
      i_enable    => '1',
      i_clock     => G_Clock,
      o_q         => y0,
      o_qBar      => n_y0,
            );
 
  dFF_resetTimer :enARdFF_2
    PORT MAP(
      i_resetBar  => G_Reset,
      i_d         => w,
      i_enable    => '1',
      i_clock     => G_Clock,
      o_q         => resetTimer,
      o_qBar      => open,
            );

  dFF_resetCount: enARdFF_2
    PORT MAP(
      i_resetBar  => G_Reset,
      i_d         => w,
      i_enable    => '1',
      i_clock     => G_Clock,
      o_q         => resetCount,
      o_qBar      => open,
            );


  A <= n_y1 and n_y0; 
  B <= n_y1 and y0; 
  C <= y1   and n_y0;
  D <= y1   and y0;

  w <= ((SSCS and MSC and A)
        or (MST and B)
        or (SSC and C)
        or (SST and D));

  n_w <= not(w);

  i_d1 <= (y1 and n_y0) or (y1 and n_w) or (n_y1 and y0 and w);
  i_d0 <= (y0 and n_w)  or (n_y0 and w);

  MSTL(2) <= n_y1 and n_y0
  MSTL(1) <= n_y1 and y0
  MSTL(0) <= y1

  SSTL(2) <= y1 and n_y0
  SSTL(1) <= y1 and y0
  SSTL(0) <= n_y1


  s1 <= y1   and n_y0; --D
  s0 <= n_y1 and y0;  --B

END rtl;


  

