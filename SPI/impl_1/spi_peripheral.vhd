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
		CIPO			: out std_logic
	);
end peripheral;

architecture synth of peripheral is
	signal clk					: std_logic;
	signal controller_clk_last 	: std_logic := '0';
	signal controller_clk_last_last 	: std_logic := '0';
	signal shiftreg				: std_logic_vector(7 downto 0) := "00000000";
	signal read_spi				: std_logic;
	signal bit_counter			: unsigned (3 downto 0);
	
	-- RAM signals
	signal addr					: std_logic_vector(6 downto 0) := "0000000";
	signal ram_data_in_a		: std_logic_vector(7 downto 0);
	signal ram_data_in_b		: std_logic_vector(7 downto 0);
	signal ram_data_out_a		: std_logic_vector(7 downto 0);
	signal ram_data_out_b		: std_logic_vector(7 downto 0);
	signal ram_rw				: std_logic;
	-- RAM signals
	
    component HSOSC is
        generic (
            CLKHF_DIV : String := "0b11"
        ); -- Divide 48MHz clock by 2^N (0-3)
        port(
            CLKHFPU : in std_logic := 'X'; -- Set to 1 to power up
            CLKHFEN : in std_logic := 'X'; -- Set to 1 to enable output
            CLKHF   : out std_logic := 'X' -- Clock output
        ); 
    end component;
	
	--https://github.com/pmassolino/vhdl-examples/blob/master/dpram.vhd
	component dpram
		Port (
			data_in_a : in STD_LOGIC_VECTOR(7 downto 0);
			data_in_b : in STD_LOGIC_VECTOR(7 downto 0);
			rw_a : in STD_LOGIC;
			rw_b : in STD_LOGIC;
			clk : in STD_LOGIC;
			address_a : in STD_LOGIC_VECTOR(6 downto 0);
			address_b : in STD_LOGIC_VECTOR(6 downto 0);
			data_out_a : out STD_LOGIC_VECTOR(7 downto 0);
			data_out_b : out STD_LOGIC_VECTOR(7 downto 0)
		);
	end component;
	
	
	type State is (READ, WRITE, IDLE);
	signal s : State := IDLE;

begin
	read_spi <= controller_clk_last and (not controller_clk_last_last);
	led_array <= shiftreg;
	
	-- RAM STUFF --
	ram_rw			<= '1' when (s = WRITE) else '0';
	ram_data_in_a 	<= shiftreg;
	-- RAM STUFF --

	-- for testing of synchronous clocks
	--read_data <= '1';
	--clk <= controller_clk;

	process (clk) begin
		if (reset = '1') then
			shiftreg	<= "00000000";
			bit_counter <= "0000";
			addr		<= "0000000";
        elsif rising_edge(clk) then
			controller_clk_last <= controller_clk;
			controller_clk_last_last <= controller_clk_last;

			if (cs = '0') then
				if (read_spi = '1') then
					bit_counter				<= bit_counter + 1;
					shiftreg(6 downto 0)	<= shiftreg (7 downto 1);
					shiftreg(7) 			<= COPI;
					CIPO					<= not ram_data_out_a(to_integer(bit_counter));
					--CIPO 					<= COPI;
				end if;
			else
				bit_counter <= "0000";
				shiftreg	<=  "00000000";
			end if;
			
			case s is
				when IDLE =>
					if (cs = '0') then
						s <= READ;
					end if;
				when READ =>
					if (bit_counter = "1000") then
						s <= WRITE;
					end if;
				when WRITE =>
					addr	<= std_logic_vector(unsigned(addr) + 1);
					s		<= IDLE;
			end case;
	
        end if;
	end process;

	RAM : dpram port map(
		data_in_a => ram_data_in_a,
		data_in_b => ram_data_in_b,
		rw_a => ram_rw,
		rw_b => ram_rw,
		clk => clk,
		address_a => addr,
		address_b => addr,
		data_out_a => ram_data_out_a,
		data_out_b => ram_data_out_b 
	);
	H : HSOSC port map (CLKHFPU => '1', CLKHFEN => '1', CLKHF => clk);
end;