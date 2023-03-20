--------------------------------------------------------------------------------- 
-- Project Name        : Kit retrofit Radar DGA & PISQ
-- Design Name         : Telemesim - Telemetry Simulator
-- Starting date:      : 05/11/2013
-- Target Devices      : XC5VSX50T
-- Tool versions       : ISE 14.3 (start)
-- Project Description : HA Board
-- ------------------------------------------------------------------------------
-- Company             : Altran for ELDES
-- Engineer            : Maurizio Casti
-- ------------------------------------------------------------------------------ 
-- ==============================================================================
-- PRESENT REVISION
-- ==============================================================================
-- File        : radar_mode_man.vhd
-- Revision    : 1.00
-- Author      : M. Casti
-- Date        : 05/12/2013
-- ------------------------------------------------------------------------------
-- Description :
--    This module generates a pseudorandom sequence
-- ==============================================================================
-- Revision history :
-- ==============================================================================
--
-- Revision 1.00:  08/01/2014
-- - Initial revision
-- (ALTRAN Italia)
--
-- ==============================================================================
-- 
-- LEGENDA e Stile di scrittura
-- 
-- INPUT:  UPPER CASE con suffisso _i
-- OUTPUT: UPPER CASE con suffisso _o
-- BUFFER: UPPERCASE con suffisso _b (non usato)
-- COSTANTI: UPPERCASE con suffisso _k
--
-- ==============================================================================

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

-- library work;
--   use work.telemesim_pack.all;

entity rnd_gen is
generic (
  num_of_bits   : natural range 4 to 64 := 8;
--  feedback_term : std_logic_vector (natural range <>) := x"8E"
  feedback_term : std_logic_vector := x"8E"
  );
port (
  -- Outputs
  RND_VALUE_o       : out std_logic_vector(num_of_bits-1 downto 0);  -- Valore Pseudocasuale (estratto ogni "num_of_bits")
  LSFR_o            : out std_logic_vector(num_of_bits-1 downto 0);  -- Valore dell' LFSR
  -- Controls
  ENABLE_i          : in   std_logic;                       -- Clock Enable "grezzo"
  RST_n             : in   std_logic;                       -- Reset asincrono (logica negata)
  CLK_i             : in   std_logic                        -- Main Clock
  );
  
end rnd_gen;

architecture Behavioral of rnd_gen is

signal lfsr             : std_logic_vector(num_of_bits-1 downto 0) := (0 => '1', others => '0');
signal term             : std_logic_vector(num_of_bits-1 downto 0) ; 
signal lfsr_feedback    : std_logic := '0';

begin

-- GENERAZIONE DELLE CONNESSIONI DI FEEDBACK
-- NOTA: poichè "feedback_term" è definito come "std_logic_vector (natural range <>)", il range parte da 0;
--       questo significa che il valore è visto "ribaltato", con MSB e LSB invertiti.

-- term(num_of_bits-2) <= lfsr(num_of_bits-1) and  feedback_term(0);
term(num_of_bits-1) <= lfsr(num_of_bits-1) and  feedback_term(0);
LFSR_FEEDBACK_GENERATE : for i in 1 to (num_of_bits-1) generate
begin
-- term(num_of_bits-2 - i) <= term(num_of_bits-2 - i + 1) xor (lfsr(num_of_bits-1 - i) and  feedback_term(i));
term(num_of_bits-1 - i) <= term(num_of_bits-1 - i + 1) xor (lfsr(num_of_bits-1 - i) and  feedback_term(i));
end generate;
lfsr_feedback <= term(0);


-- LFSR ed USCITE
process (RST_n, CLK_i)
begin
  if (RST_n = '0') then
    lfsr <= (0 => '1', others => '0');

	LSFR_o <= (others => '0');
	RND_VALUE_o <= (others => '0');
  elsif rising_edge(CLK_i) then
    if (ENABLE_i = '1') then 
      lfsr <= lfsr(num_of_bits-2 downto 0) & lfsr_feedback;
	  LSFR_o <= lfsr;
      RND_VALUE_o <= lfsr xor feedback_term;
    end if;
  end if;
end process;



end Behavioral;

