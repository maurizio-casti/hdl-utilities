--------------------------------------------------------------------------------
-- Company      : IIT 
-- Engineer     : Maurizio Casti
--------------------------------------------------------------------------------
-- Description  : Provides some RESET signal 
--==============================================================================
-- PRESENT REVISION
--==============================================================================
-- File         : reset_machine.vhd
-- Revision     : 1.0
-- Author       : M. Casti
-- Date         : 21/08/2019
 --==============================================================================
-- Revision history :
--
-- Rev 1.0      : 21/08/2019  
-- - Initial revision (M. Casti - IIT)
-------------------------------------------------------------------------------

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.std_logic_unsigned.all;

library unisim;
   use unisim.vcomponents.all;
----------------------------------------------------------------------------------

entity reset_machine is
generic (
  PON_RESET_g : boolean := true         -- If "true", generates a Power-On reset
  );
port ( 
  CLK_i         : in  std_logic;        -- Input Clock
  CE_i          : in  std_logic;        -- Clock enable
  CLK_LOCKED_i  : in  std_logic := 'H'; -- Clock locked flag
  ARST_i        : in  std_logic := 'L'; -- Active Hign Asyncronous reset input
  ARST_N_i      : in  std_logic := 'H'; -- Active Low Asyncronous reset input
  -- Reset output
  RST_o         : out std_logic;        -- Active high reset output: Async assertion, Sync deassertion
  RST_N_o       : out std_logic         -- Active low reset output: Async assertion, Sync deassertion
  );
end reset_machine;

architecture Behavioral of reset_machine is

signal pon_reset      :  std_logic;
signal pon_reset_sr   :  std_logic_vector(31 downto 0) := X"000000FF";
-- signal pon_reset_n    :  std_logic;
-- signal pon_reset_n_sr :  std_logic_vector(31 downto 0) := X"FFFFFF00";

signal areset    :  std_logic;
signal rst_sr    :  std_logic_vector(2 downto 0) := "000";
signal rst_n_sr  :  std_logic_vector(2 downto 0) := "111";

begin

-- *********************************************************************************************************
-- Power On Reset
PON_RESET_YES_gen : if (PON_RESET_g = true) generate

  Pon_Reset_Roll_proc: process(CLK_i)
  begin
    if rising_edge(CLK_i) then              -- NOTA: non si resetta, per sfruttare gli SR delle LUTs Xilinx
      if (CE_i = '1') then 
        pon_reset_sr   <= pon_reset_sr(30 downto 0) & '0';
  --    pon_reset_n_sr <= pon_reset_n_sr(30 downto 0) & '1';
      end if;
    end if;
  end process Pon_Reset_Roll_proc; 
    
  pon_reset   <= pon_reset_sr(31);
  --  pon_reset_n <= pon_reset_n_sr(31);
  
end generate;

PON_RESET_NO_gen : if (PON_RESET_g = false) generate

  pon_reset   <= '0';
--pon_reset_n <= '1';
  
end generate;

-- *********************************************************************************************************
-- Reset resync
areset <= ARST_i or           -- Reset asincrono (combinatorio, viene poi sincronizzato) 
          not ARST_N_i or
          not CLK_LOCKED_i;    


Reset_proc : process(CLK_i, areset)
begin
  if (areset = '1') then
    rst_sr   <= "111";                  -- Asserzione asincrona (attivo alto)
    rst_n_sr <= "000";
  elsif rising_edge(CLK_i) then
    rst_sr   <= rst_sr(1 downto 0) & pon_reset;            -- Deasserzione sincrona, con
	  rst_n_sr <= rst_n_sr(1 downto 0) & not pon_reset;      -- doppio flip-flop anti metastabilità
  end if;
end process Reset_proc;


RST_o   <= rst_sr(2);
RST_N_o <= rst_n_sr(2);


end Behavioral;

