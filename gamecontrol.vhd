---------------------------------------------------------------------------
-- This VHDL file was developed by Daniel Llamocca (2015).  It may be
-- freely copied and/or distributed at no cost.  Any persons using this
-- file for any purpose do so at their own risk, and are responsible for
-- the results of such use.  Daniel Llamocca does not guarantee that
-- this file is complete, correct, or fit for any particular purpose.
-- NO WARRANTY OF ANY KIND IS EXPRESSED OR IMPLIED.  This notice must
-- accompany any copy of this file.
--------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.math_real.log2;
use ieee.math_real.ceil;


-- Output Data: 9 bits: DOUT(8): Stop bit (1). DOUT(7 downto 0): 8-bit data from keyboard
-- For each 9-bit output, the done is asserted for one clock cycle. Done is asserted when data is already available to capture.
-- Keyboard behavior: if a key is pressed and held, the scan code (8 bits, see Nexys4-DDR datashet) is sent every 100 ms
--                    Once the key is released, a keyup code is sent first (F0), followed by the 8-bit scan code.
--                    For all these instances (repeated scan code every 100 ms, keyup code, and scan code), the done signal is asserted
--                    for one clock cycle. Some keys send two keyup codes: E0 F0.
--                    If you want to only read one scan code, design an FSM that waits for the keyupcode (F0), and then retrieves the scan code once.
entity gamecontrol is
	port (resetn, clock: in std_logic;
			ps2c, ps2d: in std_logic;
--			DOUT: out std_logic_vector (8 downto 0);
			done: out std_logic;
			player  : OUT STD_LOGIC;
			LED : out std_logic_vector(11 downto 0);
			p1,p2 : out std_logic_vector(8 downto 0);
			win : out std_logic_vector(1 downto 0)
			);
end gamecontrol;

architecture Behavioral of gamecontrol is
	
    component turncontrol
           PORT(
              clk        : IN  STD_LOGIC;                     --system clock input
              rst        : IN  STD_LOGIC;
              ps2_code_new : IN STD_LOGIC;                     --flag that new PS/2 code is available on ps2_code bus
              ps2_code     : IN STD_LOGIC_VECTOR(7 DOWNTO 0); --code received from PS/2
              
              player  : OUT STD_LOGIC;                     --output flag indicating new ASCII value
              p1, p2 : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
              win : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
              LED : out std_logic_vector(11 downto 0)); --ASCII value
        END component;   
        

	component my_genpulse
		generic (COUNT: INTEGER:= (10**8)/2); -- (10**8)/2 cycles of T = 10 ns --> 0.5 s
		port (clock, resetn, E: in std_logic;
				Q: out std_logic_vector ( 31 downto 0);
				z: out std_logic);
	end component;
	
	component my_pashiftreg
		generic (N: INTEGER:= 4;
					DIR: STRING:= "LEFT");
		port ( clock, resetn: in std_logic;
				 din, E, s_l: in std_logic; -- din: shiftin input
				 D: in std_logic_vector (N-1 downto 0);
				 Q: out std_logic_vector (N-1 downto 0);
				 shiftout: out std_logic);
	end component;
	
	component dffe
        Port ( d : in  STD_LOGIC;
                clrn: in std_logic:= '1';
                  prn: in std_logic:= '1';
               clk : in  STD_LOGIC;
                  ena: in std_logic;
               q : out  STD_LOGIC);
    end component;
	
	type state is (S1, S2);
	signal y, yf: state;	
	
	signal doned, fall_edge, ps2cf, E, L, EQ, zQ: std_logic;
	signal Qfi: std_logic_vector (7 downto 0);
	
	signal DOUT: std_logic_vector (8 downto 0);
	signal XDDD :  std_logic_vector(7 downto 0);
	
	signal R, G, B : std_logic_vector (3 downto 0);
	signal H, V : std_logic;
	
begin

XDDD <= DOUT (7 downto 0);

--turn leds
tc: turncontrol port map ( clk => clock, rst => resetn, ps2_code_new => doned, ps2_code => XDDD, player => player, p1 => p1, p2 => p2, win => win, LED => LED);

-- Counter: Modulo-9
gb: my_genpulse generic map (COUNT => 9) 
	 port map (clock => clock, resetn => resetn, E => EQ, z => zQ);
	
-- Shift Register
sa: my_pashiftreg generic map (N => 9, DIR => "RIGHT")
    port map (clock => clock, resetn => resetn, din => ps2d, E => E, s_l => L, D => (others => '0'), Q => DOUT);

-----------------------------------------------------
-- Shift Register for ps2c: Filtering
fi: my_pashiftreg generic map (N => 8, DIR => "RIGHT")
    port map (clock => clock, resetn => resetn, din => ps2c, E => '1', s_l => '0', D => (others => '0'), Q => Qfi);
	 
-- Filtering: A FF is created here
	process (resetn, clock, Qfi)
	begin
		if resetn = '0' then -- asynchronous signal
			ps2cf <= '0';
		elsif (clock'event and clock = '1') then
			if Qfi = "00000000" then
				ps2cf <= '0';
			elsif Qfi = "11111111" then
				ps2cf <= '1';
			end if;
		end if;		
	end process;	 	 
-----------------------------------------------------

-- FSM: Falling Edge Detector
	Trans: process (resetn, clock, ps2cf)
	begin
		if resetn = '0' then -- asynchronous signal
			yf <= S1; -- if resetn asserted, go to initial state: S1			
		elsif (clock'event and clock = '1') then
			case yf is
				when S1 =>
					if ps2cf = '1' then yf <= S2; else yf <= S1; end if;
					
				when S2 =>
					if ps2cf = '1' then yf <= S2; else yf <= S1; end if;
			end case;			
		end if;		
	end process;
	
	Output: process (yf, ps2cf)
	begin
		-- Initialization of FSM outputs:
		fall_edge <= '0';
		case yf is
			when S1 =>
				
			when S2 =>
				if ps2cf = '0' then fall_edge <= '1'; end if;
		end case;
	end process;
	
-- Main FSM:
	Transitions: process (resetn, clock, fall_edge, ps2d, zQ)
	begin
		if resetn = '0' then -- asynchronous signal
			y <= S1; -- if resetn asserted, go to initial state: S1			
		elsif (clock'event and clock = '1') then
			case y is
				when S1 =>
					if fall_edge = '1' then
						if ps2d = '1' then y <= S1; else y <= S2; end if;
					else
						y <= S1;
					end if;
				
				when S2 =>
					if fall_edge = '1' then
						if zQ = '1' then y <= S1; else y <= S2; end if;
					else
						y <= S2;
					end if;
					
			end case;			
		end if;		
	end process;
	
	Outputs: process (y, zQ, fall_edge)
	begin
		-- Initialization of FSM outputs:
		E <= '0'; L <= '0'; doned <= '0'; EQ <= '0';
		case y is
			when S1 =>
				
			when S2 =>
				if fall_edge = '1' then
					E <= '1';
					EQ <= '1'; -- Q <= Q+1. If we reach the maximum count, then Q <= 0.
					if zQ = '1' then doned <= '1'; end if;
				end if;
		end case;
	end process;
	
-- This is so that 'done' appears (for one clock cycle) at the same time output data (9 bits is available).	
rd: dffe port map ( d => doned, clrn => resetn, prn => '1', clk => clock, ena => '1', q => done);
 
end Behavioral;

