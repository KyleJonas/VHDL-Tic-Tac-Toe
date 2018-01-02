LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity TicTacToe Is
	port(
		-- Inputs
		clk : in std_logic;
		ps2_data : in std_logic;
		ps2_clk : in std_logic;
		rst : in std_logic;
		-- Outputs
		done : out std_logic;
		player : out std_logic;
		LED : out std_logic_vector(11 downto 0);
		R, G, B : out std_logic_vector(3 downto 0);
		H, V : out std_logic
	);
end TicTacToe;

architecture bhv of TicTacToe is
	
	component vgacontrol
		port (clk_i : in std_logic;
		    p1, p2 : in std_logic_vector(8 downto 0);
		    win : in std_logic_vector(1 downto 0);
			R, G, B: out std_logic_vector(3 downto 0);
			H, V : out std_logic
		);
	end component;

	component gamecontrol
		port (resetn, clock: in std_logic;
			ps2c, ps2d: in std_logic;
            done: out std_logic;
			player  : OUT STD_LOGIC;   
      		LED : out std_logic_vector(11 downto 0);
      		p1,p2 : out std_logic_vector(8 downto 0);
      		win: out std_logic_vector(1 downto 0)
      		);
	end component;

--	type state is (Start, Current, Draw);
--	signal st : state;
	
	signal player1, player2: std_logic_vector (8 downto 0);
	signal wn : std_logic_vector (1 downto 0);
	
	begin
	
	vc: vgacontrol port map (clk_i => clk,  p1 => player1, p2 => player2, win => wn, R => R, G => G, B => B, H => H, V => V );
	
	gc: gamecontrol port map (resetn => rst, clock => clk, ps2d => ps2_data, ps2c => ps2_clk, 
	                           done => done, player => player, LED => LED, p1 => player1, p2 => player2, win => wn);
	
--	stm: process(clk, rst)
--		begin
--			if rst = '0' then
--				st <= Start;	-- If reset go to initial state
--			elsif (clk' event and clk = '1') then
--				case st is
--					when Start =>
--					when Current =>
--					when 
				
	
end bhv;