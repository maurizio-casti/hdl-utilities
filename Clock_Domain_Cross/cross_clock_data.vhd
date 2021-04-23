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

entity cross_clock_data is
	generic
	(
	CLK_DEST_PERIOD	: string   := "10 ns";
	DATA_WIDTH			: positive := 32
	);
	port											
	(
	RST						: in std_logic;
	CLK_SOURCE				: in std_logic;
	CLK_DEST				: in std_logic;
	DATA_SOURCE				: in std_logic_vector(DATA_WIDTH-1 downto 0);
	DATA_DEST				: out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end entity;

architecture cross_clock_data_arch of cross_clock_data is

signal toggle_clk_dest_ms			: std_logic:='0';
signal toggle_clk_dest_st			: std_logic:='0';
signal toggle_clk_dest_st_q1		: std_logic:='0';
signal toggle_clk_dest_st_q1_inv	: std_logic:='0';
signal edge_toggle_clk_dest   		: std_logic:='0';
signal cken_clk_dest   				: std_logic:='0';

signal toggle_clk_source_ms		: std_logic:='1';
signal toggle_clk_source_st		: std_logic:='1';
signal toggle_clk_source_st_q1	: std_logic:='1';
signal edge_toggle_clk_source   : std_logic:='0';
signal cken_clk_source   		: std_logic:='0';

signal d_temp					: std_logic_vector(DATA_WIDTH-1 downto 0);

signal rst_clk_source_q1		: std_logic:='1';
signal rst_clk_source_q2		: std_logic:='1';
signal rst_clk_source			: std_logic:='1';

signal rst_clk_dest_q1			: std_logic:='1';
signal rst_clk_dest_q2			: std_logic:='1';
signal rst_clk_dest				: std_logic:='1';

attribute maxdelay: string;
attribute maxdelay of d_temp: signal is CLK_DEST_PERIOD;

attribute shreg_extract : string;
attribute shreg_extract of rst_clk_source_q1: signal is "no";
attribute shreg_extract of rst_clk_source_q2: signal is "no";
attribute shreg_extract of rst_clk_source: signal is "no";
attribute shreg_extract of rst_clk_dest_q1: signal is "no";
attribute shreg_extract of rst_clk_dest_q2: signal is "no";
attribute shreg_extract of rst_clk_dest: signal is "no";
attribute shreg_extract of	toggle_clk_source_ms: signal is "no";
attribute shreg_extract of	toggle_clk_source_st: signal is "no";
attribute shreg_extract of	toggle_clk_source_st_q1: signal is "no";
attribute shreg_extract of	toggle_clk_dest_ms: signal is "no";
attribute shreg_extract of	toggle_clk_dest_st: signal is "no";
attribute shreg_extract of	toggle_clk_dest_st_q1: signal is "no";

begin
	
	-- Reset Synch
	synch_reset_clk_source:
	process(RST,CLK_SOURCE)
	begin
		if RST='1' then
			rst_clk_source_q1	<='1';
			rst_clk_source_q2	<='1';
			rst_clk_source		<='1';
		else
			if rising_edge(CLK_SOURCE) then
				rst_clk_source_q1	<= '0' ;
				rst_clk_source_q2	<=rst_clk_source_q1;
				rst_clk_source		<=rst_clk_source_q2;
			end if;	
		end if;
	end process;
	
	synch_reset_clk_dest:
	process(RST,CLK_DEST)
	begin
		if RST='1' then
			rst_clk_dest_q1	<='1';
			rst_clk_dest_q2	<='1';
			rst_clk_dest	<='1';
		else
			if rising_edge(CLK_DEST) then
				rst_clk_dest_q1	<= '0' ;
				rst_clk_dest_q2	<= rst_clk_dest_q1;
				rst_clk_dest	<= rst_clk_dest_q2;
			end if;	
		end if;
	end process;
	
	----------------------------------------------------------------------------
	----------------- Toggleling on 2 clock domains-----------------------------
	----------------------------------------------------------------------------
	
	process(rst_clk_dest,CLK_DEST)
	begin
		if rst_clk_dest='1' then
			toggle_clk_dest_ms			<= '0';
			toggle_clk_dest_st			<= '0';
			toggle_clk_dest_st_q1 		<= '0';
			toggle_clk_dest_st_q1_inv	<= '0';
		elsif rising_edge(CLK_DEST) then
			toggle_clk_dest_ms	        <= toggle_clk_source_st_q1;
			toggle_clk_dest_st	        <= toggle_clk_dest_ms;
			toggle_clk_dest_st_q1 		<= toggle_clk_dest_st;
			toggle_clk_dest_st_q1_inv	<= not toggle_clk_dest_st;
		end if;
	end process;
	edge_toggle_clk_dest	<= toggle_clk_dest_st xor toggle_clk_dest_st_q1;
	
	process(rst_clk_source,CLK_SOURCE)
	begin
		if rst_clk_source='1' then
			toggle_clk_source_ms	<= '0';
			toggle_clk_source_st	<= '0';
			toggle_clk_source_st_q1 <= '0';
		elsif rising_edge(CLK_SOURCE) then
			toggle_clk_source_ms	<= toggle_clk_dest_st_q1_inv;
			toggle_clk_source_st	<= toggle_clk_source_ms;
			toggle_clk_source_st_q1 <= toggle_clk_source_st;
		end if;
	end process;
	edge_toggle_clk_source	<= toggle_clk_source_st xor toggle_clk_source_st_q1;
	
	cken_clk_source 	<= edge_toggle_clk_source;
	cken_clk_dest   	<= edge_toggle_clk_dest;
	----------------------------------------------------------------------------			
	----------------------------------------------------------------------------			
	
	process(rst_clk_source,CLK_SOURCE)
	begin
		if rst_clk_source='1' then
			d_temp	<= (others => '0');
		elsif rising_edge(CLK_SOURCE) then
			if cken_clk_source='1' then
				d_temp <= DATA_SOURCE;
			end if;
		end if;	
	end process;

	process(rst_clk_dest,CLK_DEST)
	begin
		if rst_clk_dest='1' then
			DATA_DEST <= (others => '0');
		elsif rising_edge(CLK_DEST) then
			if cken_clk_dest='1' then
				DATA_DEST <= d_temp;
			end if;
		end if;	
	end process; 	

end architecture;
