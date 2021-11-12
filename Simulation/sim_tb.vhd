library ieee;
  -- Logic libraries
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;              
  
  -- Math libraries
  use ieee.std_logic_arith.all;          
  -- use ieee.numeric_std.all;           
  use ieee.math_real.all;
  
  -- Text    
  use ieee.std_logic_textio.all;         

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
-- library unisim;
--   USE UNISIM.VCOMPONENTS.ALL;
 
entity sim_tb is
  generic (
    constant CLK_FREQ_g                    : real := 100.0 -- MHz                
  );
--  port ( 
--  );
end sim_tb;


architecture Behavioral of sim_tb is


-- ***************************************************************************************************
-- COMPONENT DECLARATION

component time_machine is
  generic ( 
    CLK_PERIOD_NS_g           : real                   := 10.0;   -- Main Clock period
    CLR_POLARITY_g            : string                 := "HIGH"; -- Active "HIGH" or "LOW"
    ARST_LONG_PERSISTANCE_g   : integer range 0 to 31  := 16;     -- Persistance of Power-On reset (clock pulses)
    ARST_ULONG_DURATION_MS_g  : integer range 0 to 255 := 10;     -- Duration of Ultrra-Long Reset (ms)
    HAS_POR_g                 : boolean                := TRUE;   -- If TRUE a Power On Reset is generated 
    SIM_TIME_COMPRESSION_g    : boolean                := FALSE   -- When "TRUE", simulation time is "compressed": frequencies of internal clock enables are speeded-up 
    );
  port (
    -- Clock in port
    CLK_i                     : in  std_logic;        -- Input Clock
    MCM_LOCKED_i              : in  std_logic := 'H'; -- Clock locked flag
    CLR_i                     : in  std_logic := 'L'; -- Polarity controlled Asyncronous Clear input
  
    -- Reset output
    ARST_o                    : out std_logic;        -- Active high asyncronous assertion, syncronous deassertion Reset output
    ARST_N_o                  : out std_logic;        -- Active low asyncronous assertion, syncronous deassertion Reset output 
    ARST_LONG_o               : out std_logic;	      -- Active high asyncronous assertion, syncronous deassertion Long Duration Reset output
    ARST_LONG_N_o             : out std_logic; 	      -- Active low asyncronous assertion, syncronous deassertion Long Duration Reset output 
    ARST_ULONG_o              : out std_logic;	      -- Active high asyncronous assertion, syncronous deassertion Ultra-Long Duration Reset output
    ARST_ULONG_N_o            : out std_logic;	      -- Active low asyncronous assertion, syncronous deassertion Ultra-Long Duration Reset output 
      
    -- Output ports for generated clock enables
    EN200NS_o                 : out std_logic;	      -- Clock enable every 200 ns
    EN1US_o                   : out std_logic;	      -- Clock enable every 1 us
    EN10US_o                  : out std_logic;	      -- Clock enable every 10 us
    EN100US_o                 : out std_logic;	      -- Clock enable every 100 us
    EN1MS_o                   : out std_logic;	      -- Clock enable every 1 ms
    EN10MS_o                  : out std_logic;	      -- Clock enable every 10 ms
    EN100MS_o                 : out std_logic;	      -- Clock enable every 100 ms
    EN1S_o                    : out std_logic 	      -- Clock enable every 1 s
    );
end component;

-- ***************************************************************************************************
-- SIGNAL AND CONSTANT DECLARATION

---------------------------------------
-- FOR TESTBENCH

constant CLK_PERIOD_NS_c      : time        := (1000.0 / CLK_FREQ_g) * 1 ns; 

signal clk, clk_n               : std_logic;
signal clear, clear_n           : std_logic;
signal pp_rst_n, p_rst_n, rst_n : std_logic := '0';
signal pp_rst, p_rst, rst       : std_logic := '1';


---------------------------------------
-- USER SIGNALS

signal mcm_locked : std_logic;




begin

---------------------------------------
-- STIMULI FOR TESTBENCH

proc_clear : process  
begin
  clear_n <= '1';
  clear   <= '0';
  wait for 1002 ns;
  wait for 12 ms;
  clear_n <= '0';
  clear   <= '1'; 
  wait for 104 ns;
  clear_n <= '1';
  clear   <= '0';
  wait;
end process proc_clear;  

proc_clk : process 
begin
  clk   <= '0';
  clk_n <= '0';
  wait for 10 ns;
  clk_loop : loop
    clk   <= not clk;
    clk_n <= not clk_n;
    wait for (CLK_PERIOD_NS_c / 2.0);
  end loop;
end process proc_clk;

-- ***************************************************************************************************
-- RESET DEASSERTION SYNCRONIZATION

-- RST_N
process(clk, clear)
begin
  if (clear = '1') then
    pp_rst_n  <= '0';
    p_rst_n   <= '0';
    rst_n     <= '0';
  elsif rising_edge(clk) then
    pp_rst_n  <= '1';
    p_rst_n   <= pp_rst_n;
    rst_n     <= p_rst_n;
  end if;
end process;  

-- RST
process(clk, clear_n)
begin
  if (clear_n = '0') then
    pp_rst    <= '1';
    p_rst     <= '1';
    rst       <= '1';
  elsif rising_edge(clk) then
    pp_rst    <= '0';
    p_rst     <= pp_rst;
    rst       <= p_rst;
  end if;
end process;  


-- ***************************************************************************************************
-- Component instantiation

TIME_MACHINE_m : time_machine 
  generic map( 
    CLK_PERIOD_NS_g           => 10.0,   -- Main Clock period
    CLR_POLARITY_g            => "HIGH", -- Active "HIGH" or "LOW"
    ARST_LONG_PERSISTANCE_g   => 16,     -- Persistance of Power-On reset (clock pulses)
    ARST_ULONG_DURATION_MS_g  => 10,     -- Duration of Ultrra-Long Reset (ms)
    HAS_POR_g                 => FALSE,   -- If TRUE a Power On Reset is generated 
    SIM_TIME_COMPRESSION_g    => FALSE   -- When "TRUE", simulation time is "compressed": frequencies of internal clock enables are speeded-up 
    ) 
  port map (
    -- Clock in port
    CLK_i                     => clk,         -- Input Clock
    MCM_LOCKED_i              => mcm_locked,  -- Clock locked flag
    CLR_i                     => clear,       -- Polarity controlled Asyncronous Clear input
  
    -- Reset output
    ARST_o                    => open,        -- Active high asyncronous assertion, syncronous deassertion Reset output
    ARST_N_o                  => open,        -- Active low asyncronous assertion, syncronous deassertion Reset output 
    ARST_LONG_o               => open,	      -- Active high asyncronous assertion, syncronous deassertion Long Duration Reset output
    ARST_LONG_N_o             => open, 	      -- Active low asyncronous assertion, syncronous deassertion Long Duration Reset output 
    ARST_ULONG_o              => open,	      -- Active high asyncronous assertion, syncronous deassertion Ultra-Long Duration Reset output
    ARST_ULONG_N_o            => open,	      -- Active low asyncronous assertion, syncronous deassertion Ultra-Long Duration Reset output 
      
    -- Output ports for generated clock enables
    EN200NS_o                 => open,        -- Clock enable every 200 ns
    EN1US_o                   => open,        -- Clock enable every 1 us
    EN10US_o                  => open,        -- Clock enable every 10 us
    EN100US_o                 => open,        -- Clock enable every 100 us
    EN1MS_o                   => open,        -- Clock enable every 1 ms
    EN10MS_o                  => open,        -- Clock enable every 10 ms
    EN100MS_o                 => open,        -- Clock enable every 100 ms
    EN1S_o                    => open         -- Clock enable every 1 s
    );




-- ***************************************************************************************************
-- USER'S STIMULI

proc_locked : process  
begin
  mcm_locked   <= '1';
  wait for 5004 ns;
  mcm_locked   <= '1'; 

  wait;
end process proc_locked;  

end Behavioral;
