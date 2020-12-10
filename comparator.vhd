-- ==============================================================================
-- DESCRIPTION:
-- A large value comparator
-- ------------------------------------------
-- File        : comparator.vhd
-- Revision    : 1.0
-- Author      : M. Casti (IIT)
-- Date        : 15/04/2020
-- ==============================================================================
-- HISTORY (main changes) :
--
-- Revision 1.0:  10/09/2019 - M. Casti (IIT)
-- - Initial revision
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




--
--
-- **************************************
-- BETA VERSION
-- --------------------------------------
-- TO BE COMPLETED
--
--





library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;
  use ieee.math_real.all;
  
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity comparator is
  generic(
    A_WIDTH_g : natural := 8;
    A_TYPE_g  : string  := "SIGNED"; -- SIGNED or UNSIGNED
    B_WIDTH_g : natural := 8;
    B_TYPE_g  : string  := "SIGNED"; -- SIGNED or UNSIGNED
    LATENCY_g : natural := 1
    );
  port ( 
    CLK_i       : in  std_logic;                               
    CE_i        : in  std_logic;  
    RST_N_i     : in  std_logic;                             
    A_i         : in  std_logic_vector (A_WIDTH_g-1 downto 0);          
    B_i         : in  std_logic_vector (B_WIDTH_g-1 downto 0);
    VALID_IN_i  : in  std_logic;
    A_GREATER_o : out std_logic;                              
    B_GREATER_o : out std_logic;                              
    EQUALITY_o  : out std_logic;
    VALID_OUT_o : out std_logic                            
    );
end comparator;

architecture Behavioral of comparator is

function G_SELECT_f (A : natural; B : natural) return natural is
variable g_value : natural := 0;
begin
  if (A >= B) then
    g_value := A;
  else
    g_value := B;
  end if;
  return g_value;
end G_SELECT_f;

-- ***********************************************************************************
constant WIDTH_c      : natural := G_SELECT_f(A_WIDTH_g, B_WIDTH_g);
constant SLOT_NUM_c   : natural := LATENCY_g - 1; -- 2**(LATENCY_g - 1);
constant SLOT_WIDTH_c : natural := natural(ceil(real(WIDTH_c)/real(SLOT_NUM_c)));
constant EXT_WIDTH_c  : natural := SLOT_WIDTH_c * SLOT_NUM_c;
-- ***********************************************************************************



signal dummy_a_slv    : std_logic_vector(15 downto 0) := x"0110";
signal dummy_b_slv    : std_logic_vector(15 downto 0) := x"0101";
signal dummy_a_slv_GT_dummy_b_slv : std_logic;

signal dummy_a_unsign : unsigned(15 downto 0)         := x"8000";
signal dummy_b_unsign : unsigned(15 downto 0)         := x"7FFF";
signal dummy_a_unsign_GT_dummy_b_unsign : std_logic;

signal dummy_a_sign   : signed(15 downto 0)           := x"8000";
signal dummy_b_sign   : signed(15 downto 0)           := x"7FFF";
signal dummy_a_sign_GT_dummy_b_sign : std_logic;

signal dummy_a_GT_b   : std_logic;
signal dummy_a_LT_b   : std_logic;
signal dummy_a_EQ_b   : std_logic;

signal a_GT_b   : std_logic;
signal a_LT_b   : std_logic;
signal a_EQ_b   : std_logic;

signal a_GT_b_slice_mode    : std_logic;
signal a_LT_b_slice_mode    : std_logic;
signal a_EQ_b_slice_mode    : std_logic;
signal valid_out_slice_mode : std_logic;

type t_comp is array (LATENCY_g downto 0) of std_logic_vector(SLOT_NUM_c-1 downto 0);
signal comp : t_comp;

signal slot_a_GT_slot_b   : std_logic_vector(SLOT_NUM_c-1 downto 0);
signal slot_a_LT_slot_b   : std_logic_vector(SLOT_NUM_c-1 downto 0);
signal slot_a_EQ_slot_b   : std_logic_vector(SLOT_NUM_c-1 downto 0);

signal p_slice_a_GT_slice_b_flag  : std_logic;
signal p_slice_a_LT_slice_b_flag  : std_logic;
signal p_slice_a_EQ_slice_b_flag  : std_logic;
signal slice_a_GT_slice_b_flag : std_logic;
signal slice_a_LT_slice_b_flag : std_logic;
signal slice_a_EQ_slice_b_flag : std_logic;
signal slice_a_EQ_slice_b_d  : std_logic;
signal slice_a_EQ_slice_b_dw : std_logic;
signal comp_en               : std_logic;

signal zeroes : std_logic_vector(EXT_WIDTH_c-1 downto 0) := (others => '0');

signal a            : std_logic_vector(EXT_WIDTH_c-1 downto 0);
signal a_msb_vector : std_logic_vector(EXT_WIDTH_c-1 downto 0);
signal b            : std_logic_vector(EXT_WIDTH_c-1 downto 0);
signal b_msb_vector : std_logic_vector(EXT_WIDTH_c-1 downto 0);

type t_sliced is array (SLOT_NUM_c-1 downto 0) of std_logic_vector(SLOT_WIDTH_c-1 downto 0);
signal a_trasp : t_sliced;
signal b_trasp : t_sliced;

signal valid_out_sr : std_logic_vector(SLOT_NUM_c-1 downto 0);

 
begin
-- *******************************************************************************
dummy_a_slv_GT_dummy_b_slv        <= '1' when (dummy_a_slv    > dummy_b_slv   ) else '0';
dummy_a_unsign_GT_dummy_b_unsign  <= '1' when (dummy_a_unsign > dummy_b_unsign) else '0';
dummy_a_sign_GT_dummy_b_sign      <= '1' when (dummy_a_sign   > dummy_b_sign  ) else '0';
-- *******************************************************************************


a_msb_vector <= (others => A_i(A_WIDTH_g-1));
b_msb_vector <= (others => B_i(B_WIDTH_g-1));


A_WIDTH_LT_EXT_WIDTH_gen : if (A_WIDTH_g < EXT_WIDTH_c) generate
begin
  A_UNSIGNED_gen   : if A_TYPE_g = "UNSIGNED"   generate 
  begin 
    a <= zeroes(EXT_WIDTH_c-1 downto A_WIDTH_g) & A_i(A_WIDTH_g-1 downto 0);
  end generate;
  
  A_SIGNED_gen : if A_TYPE_g = "SIGNED" generate 
  begin
    a <= not(a_msb_vector(EXT_WIDTH_c-1)) & a_msb_vector(EXT_WIDTH_c-2 downto A_WIDTH_g) & A_i(A_WIDTH_g-1 downto 0);
  end generate;
end generate;

A_WIDTH_EQ_EXT_WIDTH_gen : if (A_WIDTH_g = EXT_WIDTH_c) generate
begin
  A_UNSIGNED_gen   : if A_TYPE_g = "UNSIGNED"   generate 
  begin 
    a <= A_i(A_WIDTH_g-1 downto 0);
  end generate;
  
  A_SIGNED_gen : if A_TYPE_g = "SIGNED" generate 
  begin
    a <= not(a_msb_vector(A_WIDTH_g-1)) & A_i(A_WIDTH_g-2 downto 0);
  end generate;
end generate;

B_WIDTH_LT_EXT_WIDTH_gen : if (B_WIDTH_g < EXT_WIDTH_c) generate
begin
  B_UNSIGNED_gen   : if B_TYPE_g = "UNSIGNED"   generate 
  begin
    b <= zeroes(EXT_WIDTH_c-1 downto B_WIDTH_g) & B_i(B_WIDTH_g-1 downto 0);
  end generate;
  B_SIGNED_gen : if B_TYPE_g = "SIGNED" generate 
  begin
    b <= not(b_msb_vector(EXT_WIDTH_c-1)) & b_msb_vector(EXT_WIDTH_c-2 downto B_WIDTH_g) & B_i(B_WIDTH_g-1 downto 0);
  end generate;
end generate;

B_WIDTH_EQ_EXT_WIDTH_gen : if (B_WIDTH_g = EXT_WIDTH_c) generate
begin
  B_UNSIGNED_gen   : if B_TYPE_g = "UNSIGNED"   generate 
  begin 
    b <= B_i(B_WIDTH_g-1 downto 0);
  end generate;
  
  A_SIGNED_gen : if B_TYPE_g = "SIGNED" generate 
  begin
    b <= not(b_msb_vector(B_WIDTH_g-1)) & B_i(B_WIDTH_g-2 downto 0);
  end generate;
end generate;


dummy_a_GT_b <= '1' when (a > b ) else '0';
dummy_a_LT_b <= '1' when (a < b ) else '0';
dummy_a_EQ_b <= '1' when (a = b ) else '0';


process(CLK_i, RST_n_i)
begin
  if (RST_N_i = '0') then 
    a_trasp <= (others => (others => '0'));
    b_trasp <= (others => (others => '0'));
    valid_out_sr <= (others => '0');
  elsif rising_edge(CLK_i) then
    valid_out_sr <= valid_out_sr(SLOT_NUM_c-2 downto 0) & VALID_IN_i;
    if (VALID_IN_i = '1') then 
      for i in 0 to SLOT_NUM_c-1 loop
        a_trasp(i) <= a(((i+1)*SLOT_WIDTH_c-1) downto i*SLOT_WIDTH_c);
        b_trasp(i) <= b(((i+1)*SLOT_WIDTH_c-1) downto i*SLOT_WIDTH_c);
      end loop;
    else 
      a_trasp(0) <= (others => '0');
      b_trasp(0) <= (others => '0');
      for i in 1 to SLOT_NUM_c-1 loop
        a_trasp(i) <= a_trasp(i-1);
        b_trasp(i) <= b_trasp(i-1);
      end loop;
    end if;
  end if;
end process;

p_slice_a_GT_slice_b_flag <= '1' when (a_trasp(SLOT_NUM_c-1) > b_trasp(SLOT_NUM_c-1)) else '0';
p_slice_a_LT_slice_b_flag <= '1' when (a_trasp(SLOT_NUM_c-1) < b_trasp(SLOT_NUM_c-1)) else '0';
p_slice_a_EQ_slice_b_flag <= '1' when (a_trasp(SLOT_NUM_c-1) = b_trasp(SLOT_NUM_c-1)) else '0';

process(CLK_i, RST_n_i)
begin
  if (RST_N_i = '0') then 
    slice_a_GT_slice_b_flag   <= '0';
    slice_a_LT_slice_b_flag   <= '0';
    slice_a_EQ_slice_b_flag   <= '0';
    comp_en              <= '0';   
    a_GT_b_slice_mode    <= '0';
    a_LT_b_slice_mode    <= '0';
    a_EQ_b_slice_mode    <= '0';
    valid_out_slice_mode <= '0';

  elsif rising_edge(CLK_i) then 
    if (p_slice_a_EQ_slice_b_flag = '0') then
      comp_en <= '0';
    elsif (VALID_IN_i = '1') then
      comp_en <= '1';
    end if;
      
    if (comp_en = '1') then
      slice_a_GT_slice_b_flag <= p_slice_a_GT_slice_b_flag;
      slice_a_LT_slice_b_flag <= p_slice_a_LT_slice_b_flag;
    end if;
 
    valid_out_slice_mode <= valid_out_sr(SLOT_NUM_c-1);
    if (valid_out_sr(SLOT_NUM_c-1) = '1') then
      if (comp_en = '1') then
        a_GT_b_slice_mode <= p_slice_a_GT_slice_b_flag;
        a_LT_b_slice_mode <= p_slice_a_LT_slice_b_flag;
        a_EQ_b_slice_mode <= p_slice_a_EQ_slice_b_flag;
      else
        a_GT_b_slice_mode <= slice_a_GT_slice_b_flag;
        a_LT_b_slice_mode <= slice_a_LT_slice_b_flag;
        a_EQ_b_slice_mode <= slice_a_EQ_slice_b_flag;      
      end if;
    end if; 
      
  end if;
end process;

-- process(CLK_i, RST_n_i)
-- begin
--   if (RST_N_i = '0') then 
--     slot_a_GT_slot_b <= (others => '0');
--     slot_a_LT_slot_b <= (others => '0');
--     slot_a_EQ_slot_b <= (others => '0');
--   elsif rising_edge(CLK_i) then 
--     for i in 0 to SLOT_NUM_c-1 loop
--       if (a_trasp(i) > b_trasp(i)) then
--         slot_a_GT_slot_b(i) <= '1';
--       else
--         slot_a_GT_slot_b(i) <= '0';
--       end if;
--       if (a_trasp(i) < b_trasp(i)) then
--         slot_a_LT_slot_b(i) <= '1';
--       else
--         slot_a_LT_slot_b(i) <= '0';
--       end if;
--       if (a_trasp(i) = b_trasp(i)) then
--         slot_a_EQ_slot_b(i) <= '1';
--       else
--         slot_a_EQ_slot_b(i) <= '0';
--       end if;
--     end loop;
--   end if;
-- end process;

-- **********************************************************************
-- OUTPUT
A_GREATER_o <= a_GT_b_slice_mode;                             
B_GREATER_o <= a_LT_b_slice_mode;                             
EQUALITY_o  <= a_EQ_b_slice_mode;
VALID_OUT_o <= valid_out_slice_mode; 

end Behavioral;
