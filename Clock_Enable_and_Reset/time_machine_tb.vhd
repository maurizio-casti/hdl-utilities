-- ------------------------------------------------------------------------------ 
--  Project Name        : 
--  Design Name         : 
--  Starting date:      : 
--  Target Devices      : 
--  Tool versions       : 
--  Project Description : 
-- ------------------------------------------------------------------------------
--  Company             : IIT - Italian Institute of Technology  
--  Engineer            : Maurizio Casti
-- ------------------------------------------------------------------------------ 
-- ==============================================================================
--  PRESENT REVISION
-- ==============================================================================
--  File        : HPUcore_tb.vhd
--  Revision    : 1.0
--  Author      : M. Casti
--  Date        : 
-- ------------------------------------------------------------------------------
--  Description : Test Bench for "HPUcore" (SpiNNlink-AER)
--     
-- ==============================================================================
--  Revision history :
-- ==============================================================================
-- 
--  Revision 1.0:  07/19/2018
--  - Initial revision, based on tbench.vhd (F. Diotalevi)
--  (M. Casti - IIT)
-- 
-- ------------------------------------------------------------------------------

    
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.std_logic_arith.all;
-- use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use IEEE.STD_LOGIC_TEXTIO.ALL;

 
entity time_machine_tb is
    generic (
        CLK_PERIOD_g                 : integer := 10   -- CLK period [ns]
        );
end time_machine_tb;
 
architecture behavior of time_machine_tb is 
 
 
component time_machine 
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
    EN100NS_o                 : out std_logic;	      -- Clock enable every 200 ns
    EN1US_o                   : out std_logic;	      -- Clock enable every 1 us
    EN10US_o                  : out std_logic;	      -- Clock enable every 10 us
    EN100US_o                 : out std_logic;	      -- Clock enable every 100 us
    EN1MS_o                   : out std_logic;	      -- Clock enable every 1 ms
    EN10MS_o                  : out std_logic;	      -- Clock enable every 10 ms
    EN100MS_o                 : out std_logic;	      -- Clock enable every 100 ms
    EN1S_o                    : out std_logic 	      -- Clock enable every 1 s
    );
end component;	

signal clk_100          : std_logic;
signal clk_locked       : std_logic;
signal clear_n          : std_logic;
signal arst             : std_logic;  
signal arst_n           : std_logic; 
signal arst_long        : std_logic; 
signal arst_long_n      : std_logic; 
signal arst_ulong       : std_logic; 
signal arst_ulong_n     : std_logic; 
signal en100ns          : std_logic;	
signal en1us            : std_logic;	
signal en10us           : std_logic;	
signal en100us          : std_logic;	
signal en1ms            : std_logic;
signal en10ms           : std_logic;	
signal en100ms          : std_logic;	
signal en1s             : std_logic;		


begin 


TIME_MACHINE_m : time_machine 
generic map( 
  CLK_PERIOD_NS_g           => 10.0,          -- Main Clock period
  CLR_POLARITY_g            => "LOW",         -- Active "HIGH" or "LOW"
  ARST_LONG_PERSISTANCE_g   => 16,            -- Persistance of Power-On reset (clock pulses)
  ARST_ULONG_DURATION_MS_g  => 10,            -- Duration of Ultrra-Long Reset (ms)
  HAS_POR_g                 => TRUE,          -- If TRUE a Power On Reset is generated 
  SIM_TIME_COMPRESSION_g    => FALSE          -- When "TRUE", simulation time is "compressed": frequencies of internal clock enables are speeded-up 
  )
port map(
 -- Clock in port
  CLK_i                     => clk_100,       -- Input Clock
  MCM_LOCKED_i              => clk_locked,    -- Clock locked flag
  CLR_i                     => clear_n,       -- Polarity controlled Asyncronous Clear input
  
  -- Reset output
  ARST_o                    => arst,          -- Active high asyncronous assertion, syncronous deassertion Reset output
  ARST_N_o                  => arst_n,        -- Active low asyncronous assertion, syncronous deassertion Reset output 
  ARST_LONG_o               => arst_long,     -- Active high asyncronous assertion, syncronous deassertion Long Duration Reset output
  ARST_LONG_N_o             => arst_long_n,   -- Active low asyncronous assertion, syncronous deassertion Long Duration Reset output 
  ARST_ULONG_o              => arst_ulong,    -- Active high asyncronous assertion, syncronous deassertion Ultra-Long Duration Reset output
  ARST_ULONG_N_o            => arst_ulong_n,  -- Active low asyncronous assertion, syncronous deassertion Ultra-Long Duration Reset output 
    
  -- Output ports for generated clock enables
  EN100NS_o                 => en100ns,       -- Clock enable every 200 ns
  EN1US_o                   => en1us,         -- Clock enable every 1 us
  EN10US_o                  => en10us,        -- Clock enable every 10 us
  EN100US_o                 => en100us,       -- Clock enable every 100 us
  EN1MS_o                   => en1ms,         -- Clock enable every 1 ms
  EN10MS_o                  => en10ms,        -- Clock enable every 10 ms
  EN100MS_o                 => en100ms,       -- Clock enable every 100 ms
  EN1S_o                    => en1s           -- Clock enable every 1 s
  );

 

-- Stimulus process 

Clock_Proc : process
    begin
        clk_100 <= '0';
        loop
            wait for (CLK_PERIOD_g/2 * 1 ns); 
            clk_100 <= not clk_100;
        end loop;
end process Clock_Proc;

Reset_Proc : process
	begin
		clear_n <= '1';
		wait for 1235 ns;
		clear_n <= '0';
		wait for 256 ns;
		clear_n <= '1';
		wait;
end process Reset_Proc;


end;
