library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity peripheral is
	port (
		led_array		: out std_logic_vector(7 downto 0);
		reset			: in std_logic;
		controller_clk	: in std_logic;
		COPI			: in std_logic;
		CS				: in std_logic;
		CIPO			: out std_logic;
		data_ready		: out std_logic
	);
end peripheral;

architecture synth of peripheral is
	signal clk						: std_logic;
	signal controller_clk_last 		: std_logic := '0';
	signal controller_clk_last_last	: std_logic := '0';
	signal shiftreg					: std_logic_vector(7 downto 0) := 8d"0";
	signal read_spi					: std_logic;
	
	signal bit_counter				: unsigned (3 downto 0) := 4d"0";
	-- signal counter					: unsigned (127 downto 0);
	signal byte_counter				: unsigned (4 downto 0) := 5d"0";
	
    component HSOSC is
        generic (
            CLKHF_DIV : String := "0b00"
        ); -- Divide 48MHz clock by 2^N (0-3)
        port(
            CLKHFPU : in std_logic	:= 'X'; -- Set to 1 to power up
            CLKHFEN : in std_logic	:= 'X'; -- Set to 1 to enable output
            CLKHF   : out std_logic := 'X' -- Clock output
        ); 
    end component;
	
	type State is (READ, WRITE, IDLE);
	signal s : State := IDLE;

begin
	read_spi	<= controller_clk_last and (not controller_clk_last_last); -- clock crossing SPI edge detection
	led_array	<= shiftreg;
	data_ready	<= byte_counter(4);

	process (clk) begin
		if (reset = '1') then
			shiftreg		<= 8d"0";
			bit_counter		<= 4d"0";
			byte_counter	<= 5d"0";
        elsif rising_edge(clk) then
			controller_clk_last <= controller_clk;
			controller_clk_last_last <= controller_clk_last;

			if (cs = '0') then
				if (read_spi = '1') then
					bit_counter				<= bit_counter + 1;
					shiftreg(6 downto 0)	<= shiftreg (7 downto 1);
					shiftreg(7) 			<= COPI;
					CIPO 					<= COPI;
					
					if (bit_counter = "0111") then
						byte_counter	<= byte_counter + 1;
					end if;
				end if;
			else
				bit_counter <= 4d"0";
				shiftreg	<= 8d"0";
			end if;
			
			case s is
				when IDLE =>
					if (cs = '0') then
						s <= READ;
					end if;
				when READ =>
					if (bit_counter = "111") then
						s <= WRITE;
					end if;
				when WRITE =>
					s	<= IDLE;
			end case;
        end if;
	end process;
	
	H : HSOSC port map (CLKHFPU => '1', CLKHFEN => '1', CLKHF => clk);
end;