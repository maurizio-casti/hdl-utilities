----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:44:53 11/09/2012 
-- Design Name: 
-- Module Name:    enable_crossing - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity signal_crossing is
 port (
  RES              : in     std_logic;                      -- System Reset 
  CLK_ORIG         : in     std_logic;                      -- Origin Clock 
  CLK_DEST         : in     std_logic;                      -- Destination Clock
  SIG_ORIG         : in     std_logic;                      -- "Signal" in origin clock domain 
  SIG_DEST         : out    std_logic;                      -- "Signal" in destination clock domain 
  EN_DEST          : out    std_logic := '0'                -- Derivation of "SIG_DEST" in destination clock domain 
  );                                                        -- NOTE: Use EN_DEST if SIG_ORIGIN is an ENABLE to be transferred
end signal_crossing;

architecture Behavioral of signal_crossing is
 
signal req      : std_logic := '0';
signal ack1     : std_logic := '0';
signal ack2     : std_logic := '0';
signal req3      : std_logic := '0';
signal req1     : std_logic := '0';
signal req2     : std_logic := '0';

signal res_o_1     : std_logic := '0';
signal res_o_2     : std_logic := '0'; 
signal res_d_1     : std_logic := '0';
signal res_d_2     : std_logic := '0';

begin


-- EN_ORIG,  Resynchronisation with CLK_DEST 

--             ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---
--  CLK_ORIG ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---

--                               ------
--  EN_ORIG         -------------      -------------------------------------------------------------------------------

--                                     ------------------------------------
--  req              ---------------                                    -------------------------------------------

--                                                             ------------------------------------
--  ack1               -------------------------------------                                    -------------------

--                                                                   ------------------------------------
--  ack2               -------------------------------------------                                    -------------

   
--               ----    ----    ----    ----    ----    ----    ----    ----    ----    ----    ----    ----    ----
--  CLK_DEST ----    ----    ----    ----    ----    ----    ----    ----    ----    ----    ----    ----    ----    --

--                                       ----------------------------------------
--  req1               ---------------                                        ----------------------------------------
   
--                                               ----------------------------------------
--  req2               -----------------------                                        --------------------------------

--                                                       ----------------------------------------
--  req3               --------------------------------                                        ------------------------

--                                                                                               --------
--  EN_DEST              ------------------------------------------------------------------------        ------------------------ 


Resync_Control_Input_proc1 : process(CLK_ORIG)
begin
   if CLK_ORIG'event and CLK_ORIG = '1' then
      if res_o_2 = '1' then
         req <= '0';
         ack1 <= '0';
         ack2 <= '0';       
      else
	     if SIG_ORIG = '1' then
            req <= '1';
         elsif ack2 = '1' then
            req <= '0';
         end if;
         ack1 <= req2;
         ack2 <= ack1;
	  end if;
   end if;
end process Resync_Control_Input_proc1;   
  
Resync_Control_Input_proc2 : process(CLK_DEST)
begin
   if CLK_DEST'event and CLK_DEST = '1' then
      if res_d_2 = '1' then
         req1 <= '0';
         req2 <= '0';
         req3 <= '0';
		 EN_DEST <= '0';
      else
         req1 <= req;
         req2 <= req1;
         req3 <= req2;
	  end if;
   EN_DEST <= req2 and not(req3);
   end if;
end process Resync_Control_Input_proc2; 

SIG_DEST <= req3;



-- RESET

Reset_Origin : process(RES, CLK_ORIG)
begin
   if RES = '1' then
      res_o_1 <= '1';
      res_o_2 <= '1';
   elsif CLK_ORIG'event and CLK_ORIG = '1' then 
      res_o_1 <= '0';
	  res_o_2 <= res_o_1;
   end if;
end process Reset_Origin; 

Reset_Destination : process(RES, CLK_DEST)
begin
   if RES = '1' then
      res_d_1 <= '1';
      res_d_2 <= '1';
   elsif CLK_DEST'event and CLK_DEST = '1' then 
      res_d_1 <= '0';
	  res_d_2 <= res_d_1;
   end if;
end process Reset_Destination; 

end Behavioral;

