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
	signal clk					: std_logic;
	signal controller_clk_last 	: std_logic := '0';
	signal controller_clk_last_last 	: std_logic := '0';
	signal shiftreg				: std_logic_vector(7 downto 0) := "00000000";
	signal read_spi				: std_logic;
	signal bit_counter			: unsigned (3 downto 0);
	
	-- RAM signals
	signal r_addr                                   : std_logic_vector(3 downto 0);
	signal w_addr                                   : std_logic_vector(3 downto 0) := "0001";
	signal r_data, w_data                   		: std_logic_vector(7 downto 0);
	signal w_enable                                 : std_logic;
	-- RAM signals
	
    component HSOSC is
        generic (
            CLKHF_DIV : String := "0b00"
        ); -- Divide 48MHz clock by 2^N (0-3)
        port(
            CLKHFPU : in std_logic := 'X'; -- Set to 1 to power up
            CLKHFEN : in std_logic := 'X'; -- Set to 1 to enable output
            CLKHF   : out std_logic := 'X' -- Clock output
        ); 
    end component;
	
	component ramdp
		port (
			clk : in std_logic;
			r_addr : in std_logic_vector(3 downto 0);
			r_data : out std_logic_vector(7 downto 0);
			w_addr : in std_logic_vector(3 downto 0);
			w_data : in std_logic_vector(7 downto 0);
			w_enable : in std_logic
		);
	end component;
	
	type State is (READ, WRITE, IDLE);
	signal s : State := IDLE;

begin
	data_ready	<= '1';
	read_spi	<= controller_clk_last and (not controller_clk_last_last); -- clock crossing SPI edge detection
	led_array	<= shiftreg;
	
	-- RAM STUFF --
	w_enable                        <= '1' when (s = WRITE) else '0';
	w_data                          <= shiftreg;
	r_addr                          <= std_logic_vector(unsigned(w_addr) - 1);
	-- RAM STUFF -
		
	process (clk) begin
		if (reset = '1') then
			shiftreg	<= "00000000";
			bit_counter <= "0000";
			w_addr		<= "0000";
        elsif rising_edge(clk) then
			controller_clk_last <= controller_clk;
			controller_clk_last_last <= controller_clk_last;

			if (cs = '0') then
				if (read_spi = '1') then
					bit_counter				<= bit_counter + 1;
					shiftreg(6 downto 0)	<= shiftreg (7 downto 1);
					shiftreg(7) 			<= COPI;
					-- CIPO 					<= COPI;
					CIPO                    <= r_data(to_integer(bit_counter));
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
					w_addr	<= std_logic_vector(unsigned(w_addr) + 1);
					s		<= IDLE;
			end case;
	
        end if;
	end process;
	
	RAM : ramdp port map(
		clk             => clk,
		r_addr          => r_addr,
		r_data          => r_data,
		w_addr          => w_addr,
		w_data          => w_data,
		w_enable        => w_enable
	);

	H : HSOSC port map (CLKHFPU => '1', CLKHFEN => '1', CLKHF => clk);
end;