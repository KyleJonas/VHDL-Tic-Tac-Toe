LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY turncontrol IS
   PORT(
      clk        : IN  STD_LOGIC;                     --system clock input
      rst        : IN  STD_LOGIC;
      ps2_code_new : IN STD_LOGIC;                     --flag that new PS/2 code is available on ps2_code bus
      ps2_code     : IN STD_LOGIC_VECTOR(7 DOWNTO 0); --code received from PS/2
      
      player  : OUT STD_LOGIC;                     --output flag indicating new ASCII value
      P1, P2 : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
      win : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      LED : out std_logic_vector(11 downto 0)); --ASCII value
END turncontrol;

ARCHITECTURE behavior OF turncontrol IS

signal num : std_logic_vector(8 downto 0) := "000000000";
signal p   : std_logic := '1';
  
  TYPE machine IS(ready, new_code, translate, output);              
  --needed states
  SIGNAL state             : machine;                               --state machine

  SIGNAL prev_ps2_code_new : STD_LOGIC := '1';                      --value of ps2_code_new flag on previous clock
  SIGNAL break             : STD_LOGIC := '0';                      --'1' for break code, '0' for make code
  SIGNAL e0_code           : STD_LOGIC := '0';                      --'1' for multi-code commands, '0' for single code commands
  SIGNAL ascii             : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"FF"; --internal value of ASCII translation
  
  SIGNAL gb, player1, player2   : STD_LOGIC_VECTOR(8 DOWNTO 0) := "000000000";
  SIGNAL w : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
  SIGNAL r : std_logic;

BEGIN

  PROCESS(clk, rst)
  BEGIN
    IF(clk' EVENT AND clk = '1') THEN
    
 --      --check rst button to reset the board
         if (rst='0') then
           gb <= "000000000";
           player1 <= "000000000";
           player2 <= "000000000";
           num <= "000000000";
           p <= '1';
           w <= "00";
           r <= '1';
         else
           r <= '0';
--             end if;  
       
      prev_ps2_code_new <= ps2_code_new; --keep track of previous ps2_code_new values to determine low-to-high transitions
      CASE state IS
      
        --ready state: wait for a new PS2 code to be received
        WHEN ready =>
          IF(prev_ps2_code_new = '0' AND ps2_code_new = '1') THEN --new PS2 code received
            state <= new_code;                                      --proceed to new_code state
          ELSE                                                    --no new PS2 code received yet
            state <= ready;                                         --remain in ready state
          END IF;
          
        --new_code state: determine what to do with the new PS2 code  
        WHEN new_code =>
          IF(ps2_code = x"F0") THEN    --code indicates that next command is break
            break <= '1';                --set break flag
            state <= ready;              --return to ready state to await next PS2 code
          ELSIF(ps2_code = x"E0") THEN --code indicates multi-key command
            e0_code <= '1';              --set multi-code command flag
            state <= ready;              --return to ready state to await next PS2 code
          ELSE                         --code is the last PS2 code in the make/break code
            ascii(7) <= '1';             --set internal ascii value to unsupported code (for verification)
            state <= translate;          --proceed to translate state
          END IF;

        --translate state: translate PS2 code to ASCII value
        WHEN translate =>
               --reset break flag
            e0_code <= '0';  --reset multi-code command flag
                CASE ps2_code IS  
                  WHEN x"16" => 
                  num <= "000000001"; --1
                  WHEN x"1E" => 
                  num <= "000000010"; --2
                  WHEN x"26" => 
                  num <= "000000100"; --3
                  WHEN x"25" => 
                  num <= "000001000"; --4
                  WHEN x"2E" => 
                  num <= "000010000"; --5
                  WHEN x"36" => 
                  num <= "000100000"; --6
                  WHEN x"3D" => 
                  num <= "001000000"; --7
                  WHEN x"3E" => 
                  num <= "010000000"; --8
                  WHEN x"46" => 
                  num <= "100000000"; --9
                  WHEN OTHERS => NULL;
                END CASE;
                 break <= '0';
          
          IF(break = '0') THEN  --the code is a make
            state <= output;      --proceed to output state
          ELSE                  --code is a break
            state <= ready;       --return to ready state to await next PS2 code
          END IF;
        
        --output state: verify the code is valid and output the ASCII value
        WHEN output =>

          IF(ascii(7) = '1') then          --the PS2 code has an ASCII output
                         
            if(num = "000000001") then  --1
				if (gb(0)='0') then
				    gb(0)<='1';
				    p <= NOT p;
				    if (p='1') then
				        player1(0)<='1';
				    else
				        player2(0)<='1';
				    end if;
				end if;
			end if;
			
			if(num = "000000010") then  --2
                if (gb(1)='0') then
                    gb(1)<='1';
                    p <= NOT p;
                    if (p='1') then
                        player1(1)<='1';
                    else
                        player2(1)<='1';
                    end if;
                end if;
            end if;
			
			if(num = "000000100") then   --3
				if (gb(2)='0') then
                    gb(2)<='1';
                    p <= NOT p;
                    if (p='1') then
                        player1(2)<='1';
                    else
                        player2(2)<='1';
                    end if;
                end if;
			end if;
			
			if(num = "000001000") then --4
				if (gb(3)='0') then
                    gb(3)<='1';
                    p <= NOT p;
                    if (p='1') then
                        player1(3)<='1';
                    else
                        player2(3)<='1';
                    end if;
                end if;
            end if;
            
			if(num = "000010000") then --5
				if (gb(4)='0') then
                    gb(4)<='1';
                    p <= NOT p;
                    if (p='1') then
                        player1(4)<='1';
                    else
                        player2(4)<='1';
                    end if;
                end if;
            end if;
            
			if(num = "000100000") then --6
				if (gb(5)='0') then
                    gb(5)<='1';
                    p <= NOT p;
                    if (p='1') then
                        player1(5)<='1';
                    else
                        player2(5)<='1';
                    end if;
                end if;			
			end if;
			
			if(num = "001000000") then --7
				if (gb(6)='0') then
                    gb(6)<='1';
                    p <= NOT p;
                    if (p='1') then
                        player1(6)<='1';
                    else
                        player2(6)<='1';
                    end if;
                end if;				
			end if;
			
			if(num = "010000000") then --8
				if (gb(7)='0') then
                    gb(7)<='1';
                    p <= NOT p;
                    if (p='1') then
                        player1(7)<='1';
                    else
                        player2(7)<='1';
                    end if;
                end if;
			end if;
			
			if(num = "100000000") then --9
				if (gb(8)='0') then
                    gb(8)<='1';
                    p <= NOT p;
                    if (p='1') then
                        player1(8)<='1';
                    else
                        player2(8)<='1';
                    end if;
                end if;	
			end if;
			            
          END IF;
          ascii(7) <= '0';
          state <= ready;                    --return to ready state to await next PS2 code
      END CASE;
      
     --win detection
          -- P1 win
                --horizontal
          if ( (player1(0)='1' and player1(1)='1' and player1(2)='1') or (player1(3)='1' and player1(4)='1' and player1(5)='1') or
               (player1(6)='1' and player1(7)='1' and player1(8)='1') or
               --vertical
               (player1(0)='1' and player1(3)='1' and player1(6)='1') or (player1(1)='1' and player1(4)='1' and player1(7)='1') or
               (player1(2)='1' and player1(5)='1' and player1(8)='1') or
               --diagnol
               (player1(0)='1' and player1(4)='1' and player1(8)='1') or (player1(2)='1' and player1(4)='1' and player1(6)='1') ) then
              
              w(0)<='1';
              w(1)<='0';
              gb <= "111111111";
              
          -- p2 win
          elsif ((player2(0)='1' and player2(1)='1' and player2(2)='1') or (player2(3)='1' and player2(4)='1' and player2(5)='1') or
               (player2(6)='1' and player2(7)='1' and player2(8)='1') or
               --vertical
               (player2(0)='1' and player2(3)='1' and player2(6)='1') or (player2(1)='1' and player2(4)='1' and player2(7)='1') or
               (player2(2)='1' and player2(5)='1' and player2(8)='1') or
               --diagnol
               (player2(0)='1' and player2(4)='1' and player2(8)='1') or (player2(2)='1' and player2(4)='1' and player2(6)='1') ) then
              
              w(0)<='0';
              w(1)<='1';
              gb <= "111111111";
               
          -- no win
          else
              w(0)<='0';
              w(1)<='0';
          end if;         
      
      
     end if;
    END IF;    


--        --win detection
--        -- P1 win
--              --horizontal
--        if ( (player1(0)='1' and player1(1)='1' and player1(2)='1') or (player1(3)='1' and player1(4)='1' and player1(5)='1') or
--             (player1(6)='1' and player1(7)='1' and player1(8)='1') or
--             --vertical
--             (player1(0)='1' and player1(3)='1' and player1(6)='1') or (player1(1)='1' and player1(4)='1' and player1(7)='1') or
--             (player1(2)='1' and player1(5)='1' and player1(8)='1') or
--             --diagnol
--             (player1(0)='1' and player1(4)='1' and player1(8)='1') or (player1(2)='1' and player1(4)='1' and player1(6)='1') ) then
            
--            w(0)<='1';
--            w(1)<='0';
--            gb <= "111111111";
            
--        -- p2 win
--        elsif ((player2(0)='1' and player2(1)='1' and player2(2)='1') or (player2(3)='1' and player2(4)='1' and player2(5)='1') or
--             (player2(6)='1' and player2(7)='1' and player2(8)='1') or
--             --vertical
--             (player2(0)='1' and player2(3)='1' and player2(6)='1') or (player2(1)='1' and player2(4)='1' and player2(7)='1') or
--             (player2(2)='1' and player2(5)='1' and player2(8)='1') or
--             --diagnol
--             (player2(0)='1' and player2(4)='1' and player2(8)='1') or (player2(2)='1' and player2(4)='1' and player2(6)='1') ) then
            
--            w(0)<='0';
--            w(1)<='1';
--            gb <= "111111111";
             
--        -- no win
--        else
--            w(0)<='0';
--            w(1)<='0';
--        end if;        
        
  END PROCESS;   

  p1 <= player1;
  p2 <= player2;
  player <= p;
  led (8 downto 0) <= num;
  led (10 downto 9) <= w;
  led(11) <= r;
  win <= w;
  
END behavior;
