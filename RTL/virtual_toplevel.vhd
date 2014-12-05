library STD;
use STD.TEXTIO.ALL;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_TEXTIO.all;
use IEEE.NUMERIC_STD.ALL;


entity Virtual_Toplevel is
	generic
	(
		colAddrBits : integer := 8;
		rowAddrBits : integer := 12
	);
	port(
		reset : in std_logic;
		CLK : in std_logic;

		sw : in std_logic_vector(1 downto 0) := "00";
		
		DRAM_ADDR	: out std_logic_vector(rowAddrBits-1 downto 0);
		DRAM_BA_0	: out std_logic;
		DRAM_BA_1	: out std_logic;
		DRAM_CAS_N	: out std_logic;
		DRAM_CKE	: out std_logic;
		DRAM_CS_N	: out std_logic;
		DRAM_DQ		: inout std_logic_vector(15 downto 0);
		DRAM_LDQM	: out std_logic;
		DRAM_RAS_N	: out std_logic;
		DRAM_UDQM	: out std_logic;
		DRAM_WE_N	: out std_logic;
		
		DAC_LDATA : out std_logic_vector(15 downto 0);
		DAC_RDATA : out std_logic_vector(15 downto 0);
		
		VGA_R		: out std_logic_vector(7 downto 0);
		VGA_G		: out std_logic_vector(7 downto 0);
		VGA_B		: out std_logic_vector(7 downto 0);
		VGA_VS		: out std_logic;
		VGA_HS		: out std_logic;

		RS232_RXD : in std_logic;
		RS232_TXD : out std_logic;

		ps2k_clk_out : out std_logic;
		ps2k_dat_out : out std_logic;
		ps2k_clk_in : in std_logic;
		ps2k_dat_in : in std_logic;
		
		joya : in std_logic_vector(7 downto 0) := (others =>'1');
		joyb : in std_logic_vector(7 downto 0) := (others =>'1');
		joyc : in std_logic_vector(7 downto 0) := (others =>'1');
		joyd : in std_logic_vector(7 downto 0) := (others =>'1');
		joye : in std_logic_vector(7 downto 0) := (others =>'1');

		spi_miso		: in std_logic := '1';
		spi_mosi		: out std_logic;
		spi_clk		: out std_logic;
		spi_cs 		: out std_logic
	);
end entity;

architecture rtl of Virtual_Toplevel is

signal eopixel : std_logic;
signal eoline : std_logic;
signal eoframe : std_logic;
signal vga_X : unsigned(11 downto 0);
signal vga_Y : unsigned(11 downto 0);

signal testpattern : std_logic_vector(1 downto 0);

begin

vgamaster : entity work.video_vga_master
	port map (
-- System
		clk => clk,
		clkDiv => X"3", -- 100Mhz / (3+1) = 25 MHz dot clock

-- Sync outputs
		hSync => vga_HS,
		vSync => vga_VS,

-- Control outputs
		endOfPixel => eopixel,
		endOfLine => eoline,
		endOfFrame => eoframe,
		currentX => vga_X,
		currentY => vga_Y,

-- Configuration
		xSize => X"320",
		ySize => X"20D",
		xSyncFr => X"290",
		xSyncTo => X"2F0",
		ySyncFr => X"1F4",
		ySyncTo => X"1F6"
	);
	
testpattern<=sw;

process(clk,vga_X,vga_Y)
begin
	if rising_edge(clk) then
		if vga_Y<X"1E0" and vga_X<X"280" then
			case testpattern is
				when "00" =>
					VGA_R<=std_logic_vector(vga_X(7 downto 0));
					VGA_G<=std_logic_vector(vga_Y(7 downto 0));
					VGA_B<=vga_X(3)&vga_Y(3)&vga_X(2)&vga_Y(2)&vga_X(1)&vga_Y(1)&vga_X(0)&vga_Y(0);
				when "01" =>
					VGA_R<=std_logic_vector(not vga_X(7 downto 0));
					VGA_G<=std_logic_vector(vga_Y(7 downto 0));
					VGA_B<=not (vga_X(3)&vga_Y(3)&vga_X(2)&vga_Y(2)&vga_X(1)&vga_Y(1)&vga_X(0)&vga_Y(0));
				when "10" =>
					VGA_R<=std_logic_vector(vga_X(7 downto 0));
					VGA_G<=std_logic_vector(not vga_Y(7 downto 0));
					VGA_B<=vga_X(3)&vga_Y(3)&vga_X(2)&vga_Y(2)&vga_X(1)&vga_Y(1)&vga_X(0)&vga_Y(0);
				when "11" =>
					VGA_R<=std_logic_vector(not vga_X(7 downto 0));
					VGA_G<=std_logic_vector(not vga_Y(7 downto 0));
					VGA_B<=not (vga_X(3)&vga_Y(3)&vga_X(2)&vga_Y(2)&vga_X(1)&vga_Y(1)&vga_X(0)&vga_Y(0));
				when others =>
					null;
			end case;
		else
			VGA_R<=X"00";
			VGA_G<=X"00";
			VGA_B<=X"00";
		end if;
	end if;
end process;
	
end rtl;