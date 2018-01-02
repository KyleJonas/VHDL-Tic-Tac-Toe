-- RGB VGA test pattern  Rob Chapman  Mar 9, 1998

 -- This file uses the VGA driver and creates 3 squares on the screen which
 -- show all the available colors from mixing red, green and blue

Library IEEE;
use IEEE.STD_Logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity vgacontrol is
  port(clk_i        : in std_logic;
       p1, p2       : in std_logic_vector (8 downto 0);
       win          : in std_logic_vector (1 downto 0);
       R, G, B      : out std_logic_vector (3 downto 0); 
       H, V         : out std_logic);
end entity;


architecture test of vgacontrol is

 signal pxl_clk : std_logic;

  --For getting the pixel clock of a 640*480 display
  COMPONENT PxlClkGen is
       PORT
        (-- Clock in ports
         CLK_IN1           : in std_logic; --100 MHz
         -- Clock out ports
         CLK_OUT1          : out std_logic; --27.15 MHz
         -- Status and control signals
         LOCKED            : out std_logic
        );
   END COMPONENT;

  component vgadrive is
    port( clock          : in std_logic;  -- 25.175 Mhz clock
        red, green, blue : in std_logic;  -- input values for RGB signals
        row, column      : out std_logic_vector(9 downto 0); -- for current pixel
        Rout, Gout, Bout : out std_logic_vector(3 downto 0);
        H, V             : out std_logic); -- VGA drive signals
  end component;
  
  signal row, column : std_logic_vector(9 downto 0);
  signal red, green, blue : std_logic;
  
--  signal t1 : std_logic_vector(8 downto 0) :="101010101";
--  signal t2 : std_logic_vector(8 downto 0) :="010101010";

begin

  -- takes the chip clock to ge the picel clock speed of 25.175 MHz
  PxlClk: PxlClkGen port map( CLK_IN1 => clk_i, CLK_OUT1 => pxl_clk, LOCKED => open);

  -- for debugging: to view the bit order
  VGA :  vgadrive
    port map ( clock => pxl_clk, red => red, green => green, blue => blue,
               row => row, column => column,
               Rout => R, Gout => G, Bout => B, H => H, V => V);
  
  RGB : process(row, column)
  begin
    -- wait until clock = '1';
    
    -- Draws the gameboard and game pieces
    
    --Grid Lines
    if ( (column > 225 and column < 245) or (column > 395 and column < 415) or (row > 145 and row < 165) or (row >315 and row < 335) ) then
        --p1 win
        if (win(0)='1') then
            red   <= '1';
            green <= '0';
            blue  <= '0';    
        --p2 win    
        elsif (win(1)='1') then
            red   <= '0';
            green <= '1';
            blue  <= '0';
        --game ongoing
        else
            red   <= '1';
            green <= '1';
            blue  <= '1';
        end if;
        
    --cell 1
    elsif ( (row > 45 and row < 95) and (column > 125 and column < 175) ) then
        if ( p1(0)='1') then
            red   <= '1';
            green <= '0';
            blue  <= '0';
        elsif ( p2(0)='1') then
            red   <= '0';
            green <= '1';
            blue  <= '0';
        end if;
    --cell 2
    elsif ( (row > 45 and row < 95) and (column > 295 and column < 345) ) then
        if ( p1(1)='1') then
            red   <= '1';
            green <= '0';
            blue  <= '0';
        elsif ( p2(1)='1') then
            red   <= '0';
            green <= '1';
            blue  <= '0';
        end if;
     --cell 3
    elsif ( (row > 45 and row < 95) and (column > 465 and column < 515) ) then
        if ( p1(2)='1') then
            red   <= '1';
            green <= '0';
            blue  <= '0';
        elsif ( p2(2)='1') then
            red   <= '0';
            green <= '1';
            blue  <= '0';
        end if;
    --cell 4
    elsif ( (row > 215 and row < 265) and (column > 125 and column < 175) ) then
        if ( p1(3)='1') then
            red   <= '1';
            green <= '0';
            blue  <= '0';
        elsif ( p2(3)='1') then
            red   <= '0';
            green <= '1';
            blue  <= '0';
        end if;    
    --cell 5
    elsif ( (row > 215 and row < 265) and (column > 295 and column < 345) ) then
        if ( p1(4)='1') then
            red   <= '1';
            green <= '0';
            blue  <= '0';
        elsif ( p2(4)='1') then
            red   <= '0';
            green <= '1';
            blue  <= '0';
        end if; 
    --cell 6
    elsif ( (row > 215 and row < 265) and (column > 465 and column < 515) ) then
        if ( p1(5)='1') then
            red   <= '1';
            green <= '0';
            blue  <= '0';
        elsif ( p2(5)='1') then
            red   <= '0';
            green <= '1';
            blue  <= '0';
        end if;
    --cell 7
    elsif ( (row > 385 and row < 435) and (column > 125 and column < 175) ) then
        if ( p1(6)='1') then
            red   <= '1';
            green <= '0';
            blue  <= '0';
        elsif ( p2(6)='1') then
            red   <= '0';
            green <= '1';
            blue  <= '0';
        end if;            
    --cell 8
    elsif ( (row > 385 and row < 435) and (column > 295 and column < 345) ) then
        if ( p1(7)='1') then
            red   <= '1';
            green <= '0';
            blue  <= '0';
        elsif ( p2(7)='1') then
            red   <= '0';
            green <= '1';
            blue  <= '0';
        end if; 
    --cell 9
    elsif ( (row > 385 and row < 435) and (column > 465 and column < 515) ) then
        if ( p1(8)='1') then
            red   <= '1';
            green <= '0';
            blue  <= '0';
        elsif ( p2(8)='1') then
            red   <= '0';
            green <= '1';
            blue  <= '0';
        end if; 
        
    --blank spaces        
    else
        red   <= '0';
        green <= '0';
        blue  <= '0';
    end if;

  end process;

end architecture;