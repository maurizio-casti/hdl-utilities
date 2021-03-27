-- ==============================================================================
-- DESCRIPTION:
-- Clock domain cross for parallel data
-- ------------------------------------------
-- File        : cross_clock_data.vhd
-- Revision    : 1.0
-- Author      : M. Casti
-- Date        : 23/03/2021
-- ==============================================================================
-- HISTORY (main changes) :
-- 
-- Revision 1.0:  04/05/2020 - M. Casti
-- - Initial release
-- 
-- ==============================================================================
-- WRITING STYLE 
-- 
-- INPUTs:    UPPERCASE followed by "_i"
-- OUTPUTs:   UPPERCASE followed by "_o"
-- BUFFERs:   UPPERCASE followed by "_b"
-- CONSTANTs: UPPERCASE followed by "_c"
-- GENERICs:  UPPERCASE followed by "_g"
-- 
-- ==============================================================================

-- This module permits to transfer "slow variation" parallel data from a clock domain to another one.
-- With "slow variation" we intend a change rate that is quite slower than both clocks.
-- If not, some data can be lost


library IEEE;
  use IEEE.STD_LOGIC_1164.ALL;
  use ieee.std_logic_unsigned.all;
  use ieee.std_logic_arith.all;

entity parallel_data_cdc is
  generic(
    DATA_WIDTH_g			: positive := 32
    );
	port(
    CLEAR_N_i				  : in std_logic;
    CLK_SOURCE_i  		: in std_logic;
    CLK_DEST_i  			: in std_logic;
    DATA_SOURCE_i 		: in std_logic_vector(DATA_WIDTH_g-1 downto 0);
    DATA_DEST_o				: out std_logic_vector(DATA_WIDTH_g-1 downto 0)
    );
end entity;

architecture Behavioral of parallel_data_cdc is

signal toggle_clk_dest_ms         : std_logic := '0';
signal toggle_clk_dest_st         : std_logic := '0';
signal toggle_clk_dest_st_q1      : std_logic := '0';
signal toggle_clk_dest_st_q1_inv  : std_logic := '0';
signal edge_toggle_clk_dest       : std_logic := '0';
signal cken_clk_dest              : std_logic := '0';

signal toggle_clk_source_ms       : std_logic := '1';
signal toggle_clk_source_st       : std_logic := '1';
signal toggle_clk_source_st_q1    : std_logic := '1';
signal edge_toggle_clk_source     : std_logic := '0';
signal cken_clk_source            : std_logic := '0';

signal d_temp					            : std_logic_vector(DATA_WIDTH_g-1 downto 0);

signal rst_n_clk_source_q1		    : std_logic := '0';
signal rst_n_clk_source_q2		    : std_logic := '0';
signal rst_n_clk_source			      : std_logic := '0';

signal rst_n_clk_dest_q1          : std_logic := '0';
signal rst_n_clk_dest_q2          : std_logic := '0';
signal rst_n_clk_dest             : std_logic := '0';

attribute ASYNC_REG : string;   
attribute ASYNC_REG of rst_n_clk_source_q1          : signal is "true";
attribute ASYNC_REG of rst_n_clk_source_q2          : signal is "true";
attribute ASYNC_REG of rst_n_clk_source             : signal is "true";
attribute ASYNC_REG of rst_n_clk_dest_q1            : signal is "true";
attribute ASYNC_REG of rst_n_clk_dest_q2            : signal is "true";
attribute ASYNC_REG of rst_n_clk_dest               : signal is "true";
attribute ASYNC_REG of toggle_clk_source_ms         : signal is "true";
attribute ASYNC_REG of toggle_clk_source_st         : signal is "true";
attribute ASYNC_REG of toggle_clk_source_st_q1      : signal is "true";
attribute ASYNC_REG of toggle_clk_dest_ms           : signal is "true";
attribute ASYNC_REG of toggle_clk_dest_st           : signal is "true";
attribute ASYNC_REG of toggle_clk_dest_st_q1        : signal is "true";

begin

----------------------------------------------------------------------------
-----------------             Reset             ----------------------------
----------------------------------------------------------------------------

-- Reset Synch
synch_reset_clk_source:
process(CLEAR_N_i, CLK_SOURCE_i)
begin
	if (CLEAR_N_i = '0') then
		rst_n_clk_source_q1	<= '0';
		rst_n_clk_source_q2	<= '0';
		rst_n_clk_source    <= '0';
	elsif rising_edge(CLK_SOURCE_i) then
		rst_n_clk_source_q1	<= '1';
		rst_n_clk_source_q2	<= rst_n_clk_source_q1;
		rst_n_clk_source    <= rst_n_clk_source_q2;
	end if;
end process;

synch_reset_clk_dest:
process(CLEAR_N_i, CLK_SOURCE_i)
begin
	if (CLEAR_N_i = '0') then
		rst_n_clk_dest_q1 <= '0';
		rst_n_clk_dest_q2 <= '0';
		rst_n_clk_dest    <= '0';
	elsif rising_edge(CLK_DEST_i) then
		rst_n_clk_dest_q1 <= '1';
		rst_n_clk_dest_q2 <= rst_n_clk_dest_q1;
		rst_n_clk_dest    <= rst_n_clk_dest_q2;
	end if;
end process;

----------------------------------------------------------------------------
----------------- Toggleling between 2 clock domains -----------------------
----------------------------------------------------------------------------
	
process(rst_n_clk_dest, CLK_DEST_i)
begin
	if (rst_n_clk_dest = '0') then
		toggle_clk_dest_ms			  <= '0';
		toggle_clk_dest_st			  <= '0';
		toggle_clk_dest_st_q1 		<= '0';
		toggle_clk_dest_st_q1_inv	<= '0';
	elsif rising_edge(CLK_DEST_i) then
		toggle_clk_dest_ms	      <= toggle_clk_source_st_q1;
		toggle_clk_dest_st	      <= toggle_clk_dest_ms;
		toggle_clk_dest_st_q1 		<= toggle_clk_dest_st;
		toggle_clk_dest_st_q1_inv	<= not toggle_clk_dest_st;
	end if;
end process;
edge_toggle_clk_dest	<= toggle_clk_dest_st xor toggle_clk_dest_st_q1;

process(rst_n_clk_source, CLK_SOURCE_i)
begin
	if (rst_n_clk_source = '0') then
		toggle_clk_source_ms	    <= '0';
		toggle_clk_source_st	    <= '0';
		toggle_clk_source_st_q1   <= '0';
	elsif rising_edge(CLK_SOURCE_i) then
		toggle_clk_source_ms	    <= toggle_clk_dest_st_q1_inv;
		toggle_clk_source_st	    <= toggle_clk_source_ms;
		toggle_clk_source_st_q1   <= toggle_clk_source_st;
	end if;
end process;
edge_toggle_clk_source	<= toggle_clk_source_st xor toggle_clk_source_st_q1;

cken_clk_source 	<= edge_toggle_clk_source;
cken_clk_dest   	<= edge_toggle_clk_dest;
	----------------------------------------------------------------------------			
	----------------------------------------------------------------------------			
	
process(rst_n_clk_source, CLK_SOURCE_i)
begin
	if (rst_n_clk_source = '0') then
		d_temp	<= (others => '0');
	elsif rising_edge(CLK_SOURCE_i) then
		if (cken_clk_source = '1') then
			d_temp <= DATA_SOURCE_i;
		end if;
	end if;	
end process;

process(rst_n_clk_dest, CLK_DEST_i)
begin
	if (rst_n_clk_dest = '0') then
		DATA_DEST_o <= (others => '0');
	elsif rising_edge(CLK_DEST_i) then
		if (cken_clk_dest = '1') then
			DATA_DEST_o <= d_temp;
		end if;
	end if;	
end process; 	

end architecture;
