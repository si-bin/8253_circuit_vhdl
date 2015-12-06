library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
----------------------------
-- COUNTER
----------------------------
ENTITY counter IS
-- a counter module from 8253 circuit have the next ports:
-- CLK:         clock           ->in
-- GATE:        gate            ->in
-- OUTPUT:      output          ->out
-- DATA:        8bit data       ->inout
-- CTRL:        2 bit control   ->in
  -- 00 means read counter
  -- 01 means load mode
  -- 10 means read lower byte of data
  -- 11 means read higher byte of data
  -- ZZ means start counting
-- COUNT:       16 bit counter  ->varible/register
	PORT
	(
		CLK:        IN      STD_LOGIC;
		GATE:       IN      STD_LOGIC;
		OUTPUT:     OUT     STD_LOGIC;
		DATA:       INOUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
		CTRL:       IN      STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
END counter;
ARCHITECTURE behaviour OF counter IS
-- behaviour of counter

--MODE 0;
--after programming OUT->0 until counter will be 0. 
 
	SIGNAL MODE:STD_LOGIC_VECTOR(2 DOWNTO 0):="ZZZ";              --used for
  	                                                              --saving mode
	SIGNAL BUFFER_MODE:STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL BUFFER_DATA_LN:STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL BUFFER_DATA_HN:STD_LOGIC_VECTOR(7 DOWNTO 0);


	PROCEDURE mode0_count                                         --procedure for
         	                                                      --count mode 0
	(
		COUNTER:  IN      STD_LOGIC_VECTOR(15 DOWNTO 0);          --input variable
		RET_COUNT:OUT     STD_LOGIC_VECTOR(15 DOWNTO 0);          --out variable
		OUTPUT:   OUT     STD_LOGIC                               --value of
                                                                --output line
	)IS
	BEGIN
		IF (COUNTER="0000000000000000") THEN                        --if count is 0
			OUTPUT:='1';                                        --output will
                                     			                    --be 1
		ELSE
			RET_COUNT:=std_logic_vector(unsigned(COUNTER)- 1);
 
		END IF;
	END mode0_count;

	PROCEDURE mode4_count
	(
		COUNTER:	IN	STD_LOGIC_VECTOR(15 DOWNTO 0);
		RET_COUNT:	OUT	STD_LOGIC_VECTOR(15 DOWNTO 0);
		OUTPUT:		OUT	STD_LOGIC
     	)IS
	BEGIN
		IF(COUNTER="0000000000000000") THEN
			OUTPUT:='0';
		ELSE
			RET_COUNT:=std_logic_vector(unsigned(COUNTER)- 1);
		END IF;
	END mode4_count;
	
	PROCEDURE mode5_count
	(
		COUNTER:	IN	STD_LOGIC_VECTOR(15 DOWNTO 0);
		RET_COUNT:	OUT	STD_LOGIC_VECTOR(15 DOWNTO 0);
		OUTPUT:		OUT	STD_LOGIC
     	)IS
	BEGIN
		IF(COUNTER="0000000000000000") THEN
			OUTPUT:='0';
		ELSE
			RET_COUNT:=std_logic_vector(unsigned(COUNTER)- 1);
		END IF;
	END mode5_count;

  
BEGIN

	BUFFER_MODE<=DATA WHEN CTRL="01" else "ZZZZZZZZ";
	BUFFER_DATA_LN<=DATA WHEN CTRL="10" else "ZZZZZZZZ";
	BUFFER_DATA_HN<=DATA WHEN CTRL="11" else "ZZZZZZZZ";
	DATA<=BUFFER_DATA_LN WHEN CTRL="00" else "ZZZZZZZZ";
	PROCESS(CLK,CTRL) IS
		VARIABLE COUNT:STD_LOGIC_VECTOR(15 DOWNTO 0):="ZZZZZZZZZZZZZZZZ"; 	--used
	                                                                  		--for counting
		VARIABLE BUFFER_COUNT:STD_LOGIC_VECTOR(15 DOWNTO 0):="ZZZZZZZZZZZZZZZZ";
		VARIABLE S_OUT:STD_LOGIC:='1';               --used for assigning value to out line

	BEGIN
		IF (CTRL/="ZZ") THEN
			OUTPUT<=S_OUT;
		END IF;
    
		IF (CTRL="01") THEN                     --programming mode: load mode
			MODE(0)<=BUFFER_MODE(0);
			MODE(1)<=BUFFER_MODE(1);
			MODE(2)<=BUFFER_MODE(2);
		ELSIF (CTRL="10") THEN                  --programming mode: load lowest
      			                                --nibble of counter
			FOR index IN 0 TO 7 LOOP
				COUNT(index):=BUFFER_DATA_LN(index);
			END LOOP;
		ELSIF (CTRL="11") THEN                  --programming mode:load highest
		                                        --nibble of counter
			FOR index IN 0 TO 7 LOOP
				COUNT(index+8):=BUFFER_DATA_HN(index);
			END LOOP;
		ELSIF (CTRL="00") THEN                  --reading mode
      							--data=count;
			FOR index in 0 TO 7 LOOP
				BUFFER_DATA_LN(index)<=COUNT(index);
			END LOOP;
			FOR index in 0 TO 7 LOOP
				BUFFER_DATA_LN(index)<=COUNT(index+8);
			END LOOP;
		END IF;         
  	
	IF (CLK'EVENT AND CLK='1' AND CTRL="ZZ") THEN --only on clk
    	                                                           --transitions,
    	                                                  
    	                                                           --and ctrl in
    	                                                           --count mode
      		BUFFER_COUNT:=COUNT;
		CASE MODE IS
			WHEN "000"=>
				IF(GATE='1') THEN	--counting is stopped when GATE is 0;
					S_OUT:='0';
					mode0_count(COUNT,COUNT,S_OUT);
				END IF;
          		WHEN "100"=>
				S_OUT:='1';
				mode4_count(COUNT,COUNT,S_OUT);
			WHEN "101"=>
				IF(GATE='1') THEN
					S_OUT:='1';
					mode5_count(COUNT,COUNT,S_OUT);
				END IF;
			WHEN OTHERS => null;        
		END CASE ; 
	END IF;
	IF(GATE='1') THEN
		COUNT:=BUFFER_COUNT;
	END IF;
--    OUTPUT<=S_OUT;
  END PROCESS;


  
END behaviour;  


