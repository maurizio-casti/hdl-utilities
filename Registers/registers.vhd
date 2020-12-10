-- ==============================================================================
-- DESCRIPTION:
-- Set of registers
-- ------------------------------------------
-- File        : registers.vhd
-- Revision    : 1.0
-- Author      : M. Casti
-- Date        : 30/10/2019
-- ==============================================================================
-- HISTORY (main changes) :
--
-- Revision 1.0:  30/10/2019 - M. Casti
-- - Initial revision
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

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	use ieee.std_logic_unsigned.all;


entity registers is
  generic (
    WHO_I_AM_g            : string;                           -- 0x00  - Read;  
    ADDRESS_WIDTH_g       : natural range 1 to 8
    );
  port (
    CLK_i                   : in  std_logic;
    RST_N_i                 : in  std_logic;

    -- I/F to the I2C slave
    Addr_i                  : in  std_logic_vector(ADDRESS_WIDTH_g-1 downto 0);
    nCs_i                   : in  std_logic;
    nWrRd_i                 : in  std_logic;
    WrData_i                : in  std_logic_vector(7 downto 0);
    RdData_o                : out std_logic_vector(7 downto 0);
    nBusy_o                 : out std_logic;

    ID_LSB_i                : in	std_logic_vector(7 downto 0);	-- 0x01	- Read
    ID_MSB_i			          : in	std_logic_vector(7 downto 0);	-- 0x02	- Read
    ID_CUSTOM_i			        : in	std_logic_vector(7 downto 0);	-- 0x03	- Read
    FPGA_BETA_REV_i			    : in	std_logic_vector(7 downto 0);	-- 0x04	- Read
    FPGA_REV_i			        : in	std_logic_vector(7 downto 0);	-- 0x05	- Read
    FPGA_MIN_VER_i			    : in	std_logic_vector(7 downto 0);	-- 0x06	- Read
    FPGA_MAJ_VER_i			    : in	std_logic_vector(7 downto 0);	-- 0x07	- Read
    HW_VER_i			          : in	std_logic_vector(7 downto 0);	-- 0x08	- Read
    HW_CUSTOM_i			        : in	std_logic_vector(7 downto 0);	-- 0x09	- Read
    HW_INFO_i			          : in	std_logic_vector(7 downto 0);	-- 0x0A	- Read
    HW_SET_o			          : out	std_logic_vector(7 downto 0);	-- 0x0B	- Read and Write


    I2C_M_SET_o             : out std_logic_vector(7 downto 0); -- 0x10 - Read and Write;
    I2C_M_CMD_o             : out std_logic_vector(7 downto 0); -- 0x11 - Write and Clear;
    I2C_M_SLAVE_ADDR_o      : out std_logic_vector(7 downto 0); -- 0x14 - Read and Write;
    I2C_M_REG_ADDR_o        : out std_logic_vector(7 downto 0); -- 0x15 - Read and Write;
    I2C_M_DATA_WR_o         : out std_logic_vector(7 downto 0); -- 0x16 - Read and Write;
    I2C_M_DATA_RD_i         : in  std_logic_vector(7 downto 0)  -- 0x17 - Read;

    );
end entity registers;

architecture beh of registers is

-- -----------------------------------------------------------------
-- CONSTANTS

constant WHO_I_AM_ADDR_c			       : natural range 0 to 255 :=	 0;	-- 0x00	- Read
constant ID_LSB_ADDR_c			         : natural range 0 to 255 :=	 1;	-- 0x01	- Read
constant ID_MSB_ADDR_c			         : natural range 0 to 255 :=	 2;	-- 0x02	- Read
constant ID_CUSTOM_ADDR_c			       : natural range 0 to 255 :=	 3;	-- 0x03	- Read
constant FPGA_BETA_REV_ADDR_c		     : natural range 0 to 255 :=	 4;	-- 0x04	- Read
constant FPGA_REV_ADDR_c			       : natural range 0 to 255 :=	 5;	-- 0x05	- Read
constant FPGA_MIN_VER_ADDR_c         : natural range 0 to 255 :=	 6;	-- 0x06	- Read
constant FPGA_MAJ_VER_ADDR_c         : natural range 0 to 255 :=	 7;	-- 0x07	- Read
constant HW_VER_ADDR_c			         : natural range 0 to 255 :=	 8;	-- 0x08	- Read
constant HW_CUSTOM_ADDR_c			       : natural range 0 to 255 :=	 9;	-- 0x09	- Read
constant HW_INFO_ADDR_c			         : natural range 0 to 255 :=	10;	-- 0x0A	- Read
constant HW_SET_ADDR_c			         : natural range 0 to 255 :=	11;	-- 0x0B	- Read and Write

constant I2C_M_SET_ADDR_c			       : natural range 0 to 255 :=	16;	-- 0x10	- Read and Write
constant I2C_M_CMD_ADDR_c			       : natural range 0 to 255 :=	17;	-- 0x11	- Write and Clear

constant I2C_M_SLAVE_ADDR_ADDR_c     : natural range 0 to 255 :=	20;	-- 0x14	- Read and Write
constant I2C_M_REG_ADDR_ADDR_c	     : natural range 0 to 255 :=	21;	-- 0x15	- Read and Write
constant I2C_M_DATA_WR_ADDR_c		     : natural range 0 to 255 :=	22;	-- 0x16	- Read and Write
constant I2C_M_DATA_RD_ADDR_c		     : natural range 0 to 255 :=	23;	-- 0x17	- Read

-- constant SPI_M_ADDR_c             : natural range 0 to 255 := 32;  -- 0x20 - Read and Write;

constant FILTER_BETA_REV_ADDR_c			 : natural range 0 to 255 :=	48;	-- 0x30	- Read"
constant FILTER_REV_ADDR_c			     : natural range 0 to 255 :=	49;	-- 0x31	- Read"
constant FILTER_MIN_VER_ADDR_c			 : natural range 0 to 255 :=	50;	-- 0x32	- Read"
constant FILTER_MAJ_VER_ADDR_c			 : natural range 0 to 255 :=	51;	-- 0x33	- Read"
constant FILTER_CTRL_ADDR_c			     : natural range 0 to 255 :=	52;	-- 0x34	- Read and Write"
constant FILTER_STATUS_ADDR_c			   : natural range 0 to 255 :=	53;	-- 0x35	- Read"
constant ARP_TIMER_TIMEOUT_UP_ADDR_c : natural range 0 to 255 :=	54;	-- 0x36	- Read and Write"
constant ARP_TIMER_TIMEOUT_DW_ADDR_c : natural range 0 to 255 :=	55;	-- 0x37	- Read and Write"
constant STN_TIMER_TIMEOUT_ADDR_c		 : natural range 0 to 255 :=	56;	-- 0x38	- Read and Write"

component rolling_string is
  generic (
    ROLLING_STRING_g    : string                 := "DEFAULT STRING";
    BUS_ADDR_WIDTH_g    : natural range 0 to 8   :=  8;    
    STRING_REG_ADDR_g   : natural range 0 to 255 :=  0
    );
  port ( 
    CLK_i           : in std_logic;
    RST_N_i         : in std_logic;
    BUS_ADDR_i      : in std_logic_vector (BUS_ADDR_WIDTH_g-1 downto 0);
    CHAR_OUT_o      : out std_logic_vector (7 downto 0);
    RD_i            : in std_logic
    );
end component;

-- **************************************************************************************
-- SIGNALS
signal who_i_am                   : std_logic_vector(7 downto 0);

signal i_write, i_write_d, reg_wr : std_logic;
signal i_read, i_read_d, reg_rd   : std_logic;
signal i_AddrU                    : unsigned(ADDRESS_WIDTH_g-1 downto 0);
	


-- --------------------------------------------------------------------------------------
-- Output Registers
signal hw_set                 : std_logic_vector(7 downto 0);  -- 0x0B - Read and Write;
signal i2c_m_set              : std_logic_vector(7 downto 0);  -- 0x10 - Read and Write;
signal i2c_m_cmd              : std_logic_vector(7 downto 0);  -- 0x11 - Write and Clear;
signal i2c_m_slave_addr       : std_logic_vector(7 downto 0);  -- 0x14 - Read and Write;
signal i2c_m_reg_addr         : std_logic_vector(7 downto 0);  -- 0x15 - Read and Write;
signal i2c_m_data_wr          : std_logic_vector(7 downto 0);  -- 0x16 - Read and Write;

signal 	filter_ctrl			      : std_logic_vector(7 downto 0);
signal 	arp_timer_timeout_up	: std_logic_vector(7 downto 0);
signal 	arp_timer_timeout_dw	: std_logic_vector(7 downto 0);
signal 	stn_timer_timeout			: std_logic_vector(7 downto 0);



begin


nBusy_o <= '1';

i_AddrU <= unsigned(Addr_i);

i_write <= '1' when (nCs_i = '0' and nWrRd_i = '0') else '0';
i_read  <= '1' when (nCs_i = '0' and nWrRd_i = '1') else '0';


ROLLING_STRING_i : rolling_string
  generic map(
    ROLLING_STRING_g   => WHO_I_AM_g,      -- : string 
    BUS_ADDR_WIDTH_g   => ADDRESS_WIDTH_g, -- : natural range 0 to 8   :=  8;    
    STRING_REG_ADDR_g  => 0                -- : natural range 0 to 255 :=  0
    )
  port map( 
    CLK_i              => CLK_i, -- : in std_logic;
    RST_N_i            => RST_N_i, -- : in std_logic;
    BUS_ADDR_i         => Addr_i, -- : in std_logic_vector (BUS_ADDR_WIDTH_g-1 downto 0);
    CHAR_OUT_o         => who_i_am, -- : out std_logic_vector (7 downto 0);
    RD_i               => reg_rd  -- : in std_logic
    );





CMD_proc : process (CLK_i, RST_N_i)
begin
  if (RST_N_i = '0') then
    i_write_d <= '0';
    i_read_d  <= '0'; 
  elsif rising_edge(CLK_i) then
    i_write_d <= i_write;
    i_read_d  <= i_read; 
  end if;
end process CMD_proc;

reg_wr <= i_write and not i_write_d;
reg_rd <= i_read and not i_read_d;

WRITE_proc : process (CLK_i, RST_N_i)
begin
  if (RST_N_i = '0') then
    hw_set               <= (others => '0');
    i2c_m_set            <= (others => '0');
    i2c_m_cmd            <= (others => '0');
    i2c_m_slave_addr     <= (others => '0');
    i2c_m_reg_addr       <= (others => '0');
    i2c_m_data_wr        <= (others => '0');

  elsif rising_edge(CLK_i) then
    if (reg_wr = '1') then
      case (to_integer(i_AddrU)) is
        when HW_SET_ADDR_c                => hw_set                 <= WrData_i;
        when I2C_M_SET_ADDR_c             => i2c_m_set              <= WrData_i;
        when I2C_M_CMD_ADDR_c             => i2c_m_cmd              <= WrData_i;
        when I2C_M_SLAVE_ADDR_ADDR_c      => i2c_m_slave_addr       <= WrData_i;
        when I2C_M_REG_ADDR_ADDR_c        => i2c_m_reg_addr         <= WrData_i;
        when I2C_M_DATA_WR_ADDR_c         => i2c_m_data_wr          <= WrData_i;

        when others =>  null;
      end case;
    else
      i2c_m_cmd     <= (others => '0');
    end if;
  end if;
end process WRITE_proc;


READ_proc : process (i_AddrU, 
                     who_i_am, ID_LSB_i, ID_MSB_i, ID_CUSTOM_i, FPGA_BETA_REV_i, FPGA_REV_i, FPGA_MIN_VER_i, FPGA_MAJ_VER_i, HW_VER_i, HW_CUSTOM_i, HW_INFO_i, hw_set,
                     i2c_m_set, i2c_m_cmd, i2c_m_slave_addr, i2c_m_reg_addr, i2c_m_data_wr, I2C_M_DATA_RD_i)
begin
  case (to_integer(i_AddrU)) is

    when WHO_I_AM_ADDR_c             => RdData_o <= who_i_am;
    when ID_LSB_ADDR_c               => RdData_o <= ID_LSB_i;
    when ID_MSB_ADDR_c               => RdData_o <= ID_MSB_i;
    when ID_CUSTOM_ADDR_c            => RdData_o <= ID_CUSTOM_i;
    when FPGA_BETA_REV_ADDR_c        => RdData_o <= FPGA_BETA_REV_i;
    when FPGA_REV_ADDR_c             => RdData_o <= FPGA_REV_i;
    when FPGA_MIN_VER_ADDR_c         => RdData_o <= FPGA_MIN_VER_i;
    when FPGA_MAJ_VER_ADDR_c         => RdData_o <= FPGA_MAJ_VER_i;
    when HW_VER_ADDR_c               => RdData_o <= HW_VER_i;
    when HW_CUSTOM_ADDR_c            => RdData_o <= HW_CUSTOM_i;
    when HW_INFO_ADDR_c              => RdData_o <= HW_INFO_i;
    when HW_SET_ADDR_c               => RdData_o <= hw_set;

    when I2C_M_SET_ADDR_c            => RdData_o <= i2c_m_set;
    when I2C_M_CMD_ADDR_c            => RdData_o <= i2c_m_cmd;
    when I2C_M_SLAVE_ADDR_ADDR_c     => RdData_o <= i2c_m_slave_addr;
    when I2C_M_REG_ADDR_ADDR_c       => RdData_o <= i2c_m_reg_addr;
    when I2C_M_DATA_WR_ADDR_c        => RdData_o <= i2c_m_data_wr;
    when I2C_M_DATA_RD_ADDR_c        => RdData_o <= I2C_M_DATA_RD_i;

    when others                      => RdData_o <= x"BA";

  end case;
end process READ_proc;

-- Output Registers
    HW_SET_o                <= hw_set;           
    I2C_M_SET_o             <= i2c_m_set;        
    I2C_M_CMD_o             <= i2c_m_cmd;        
    I2C_M_SLAVE_ADDR_o      <= i2c_m_slave_addr; 
    I2C_M_REG_ADDR_o        <= i2c_m_reg_addr;   
    I2C_M_DATA_WR_o         <= i2c_m_data_wr;    


end architecture beh;


