\ --- ./jonesForth.f ---

: '(' [ CHAR ( ] LITERAL ;
: ')' [ CHAR ) ] LITERAL ;
: '"' [ CHAR " ] LITERAL ;
: '.' [ CHAR . ] LITERAL ;

: ( IMMEDIATE 1 BEGIN KEY DUP '(' = IF DROP 1+ ELSE ')' = IF 1- THEN THEN DUP 0= UNTIL DROP ;
: ALIGNED ( c-addr -- a-addr ) 3 + 3 INVERT AND ;
: ALIGN HERE @ ALIGNED HERE ! ;
: C, HERE @ C! 1 HERE +! ;
: S" IMMEDIATE ( -- addr len )
	STATE @ IF
		' LITS , HERE @ 0 ,
		BEGIN KEY DUP '"'
                <> WHILE C, REPEAT
		DROP DUP HERE @ SWAP - 4- SWAP ! ALIGN
	ELSE
		HERE @
		BEGIN KEY DUP '"'
                <> WHILE OVER C! 1+ REPEAT
		DROP HERE @ - HERE @ SWAP
	THEN
;
: ." IMMEDIATE ( -- )
	STATE @ IF
		[COMPILE] S" ' TELL ,
	ELSE
		BEGIN KEY DUP '"' = IF DROP EXIT THEN EMIT AGAIN
	THEN
;

: JF-HERE   HERE ;
: HERE   JF-HERE @ ;
: ALLOT   HERE + JF-HERE ! ;


\ --- ./init.f ---

HEX

3F000000 CONSTANT PERI_BASE
PERI_BASE 200000 + CONSTANT GPIO_BASE
GPIO_BASE 4 + CONSTANT GPFSEL1
GPIO_BASE 8 + CONSTANT GPFSEL2
GPIO_BASE 1C + CONSTANT GPSET0
GPIO_BASE 28 + CONSTANT GPCLR0
GPIO_BASE 34 + CONSTANT GPLEV0

: CELLS ( n_blocks -- tot_size ) 
	5 LSHIFT 
;

: PIN_TO_WORD ( pin# -- pin_word )		
	1 SWAP LSHIFT 
;

VARIABLE COLORS		4 COLORS !
VARIABLE MAX_LVL	A MAX_LVL !
VARIABLE MIN_LVL	1 MIN_LVL !
VARIABLE LEVEL		MIN_LVL @ LEVEL !
VARIABLE ?PRESSED 	-1 ?PRESSED !

VARIABLE LEDS		COLORS @ 1- CELLS ALLOT
VARIABLE BUTTONS	COLORS @ 1- CELLS ALLOT
VARIABLE SOL		MAX_LVL 1- CELLS ALLOT
VARIABLE SEQ		MAX_LVL 1- CELLS ALLOT

: GET_LED ( led# -- led_pin )	CELLS LEDS + ;
: GET_BTN ( btn# -- btn_pin )	CELLS BUTTONS + ;
: GET_SOL ( input# -- led# )	CELLS SOL + ;
: GET_SEQ ( input# -- led# )	CELLS SEQ + ;

18 PIN_TO_WORD CONSTANT BUZZER		\ gpio 24

: SET_ARRAY ( -- )
	15 PIN_TO_WORD 0 GET_LED !	\ LED0		gpio 21
	14 PIN_TO_WORD 1 GET_LED !	\ LED1		gpio 20 
	10 PIN_TO_WORD 2 GET_LED !	\ LED2		gpio 16
	C PIN_TO_WORD 3 GET_LED !	\ LED3		gpio 12

	13 PIN_TO_WORD 0 GET_BTN !	\ BUTTON0	gpio 19
	D PIN_TO_WORD 1 GET_BTN !	\ BUTTON1	gpio 13
	6 PIN_TO_WORD 2 GET_BTN !	\ BUTTON2	gpio 6
	5 PIN_TO_WORD 3 GET_BTN !	\ BUTTON3	gpio 5
;

: INIT_GPIO ( -- )
	GPFSEL2 @ 00000008 00000001 00001000 OR OR OR GPFSEL2 !
	GPFSEL1 @ 00040000 00000040 OR OR GPFSEL1 !
;


\ --- ./utils.f ---

PERI_BASE 3004 + CONSTANT SYSCLK

DECIMAL

: NOW ( -- clk_value ) SYSCLK @ ;

: US ( -- ) ;
: MS ( us -- ms ) 1000 * ;
: SEC ( us -- s ) 1000 MS * ;

: DELAY ( us_delay -- )
	NOW + 
	BEGIN 
		DUP 
		NOW - 
	0 <= UNTIL 
	DROP 
;

VARIABLE SEED	NOW SEED !
: XORSHIFT ( -- u ) 
    SEED @
    DUP 13 LSHIFT XOR
    DUP 17 RSHIFT XOR
    DUP 5  LSHIFT XOR
    DUP SEED !
;

: GEN_SOL ( -- )
	LEVEL @
	BEGIN
		1- DUP DUP
		XORSHIFT
		COLORS @ MOD
		SWAP GET_SOL !	
	0= UNTIL
	DROP
;

HEX


\ --- ./components.f ---

: ON ( pin -- )		GPSET0 ! ;
: OFF ( pin -- ) 	GPCLR0 ! ;

DECIMAL 

: BUZZ ( us_delay -- )
	500 MS
	NOW +
	BEGIN
		BUZZER ON
		OVER DELAY
		BUZZER OFF
		OVER DELAY
		DUP
		NOW - 
	0 <= UNTIL
	DROP DROP
;

: BUZZ_DELAY ( led#/btn# -- us_delay )
	3 +
	2 SWAP LSHIFT
	100 +
	US
;


HEX

: ?ON ( led# -- led_state )		
	GPLEV0 @ SWAP
	GET_LED @ AND
;	

: SWITCH_LED ( led# -- )
	DUP
	?ON 0= 		
	IF
		GET_LED @ ON
	ELSE				
		GET_LED @ OFF
	THEN
;

DECIMAL

: BLINK ( led# -- )
	DUP SWITCH_LED
	DUP BUZZ_DELAY BUZZ
	SWITCH_LED
	200 MS DELAY
;

HEX

: LED_SEQ ( -- )
	LEVEL @
 	BEGIN
		1- DUP DUP	
		GET_SOL @ BLINK
	0= UNTIL
	DROP
;

: PRESS ( n -- )	?PRESSED ! ;
: RESET ( -- )		-1 ?PRESSED ! ;

: WAIT_BUTTON ( -- )
	COLORS @
	BEGIN
		DUP 0= IF
			DROP COLORS @
		THEN
		1- DUP
		GPLEV0 @ SWAP
		GET_BTN @ AND
		0 <> IF	
			PRESS
		THEN
	?PRESSED @ -1 > UNTIL		
;


\ --- ./gamelogic.f ---

VARIABLE ?EXIT		0 ?EXIT !

DECIMAL

: +SCORE ( -- )
	BUZZER ON
	400 MS DELAY
	BUZZER OFF
	." Won" CR CR
	LEVEL @ 
	MAX_LVL @ < IF
		1 LEVEL +!
	ELSE
		." Game won!" CR
		1 ?EXIT !
		MIN_LVL @ LEVEL !
	THEN
;

: -SCORE ( -- )
	BUZZER ON
	400 MS DELAY	
	BUZZER OFF
	400 MS DELAY
	BUZZER ON
	1 SEC DELAY
	BUZZER OFF
	." Lost" CR CR
	LEVEL @
	MIN_LVL @ > IF
		-1 LEVEL +!
	ELSE
		1 ?EXIT !
		." Game lost" CR
	THEN
;

HEX

: COMPARE ( -- comparisons )
	LEVEL @	
 	BEGIN									
		1- DUP
 		DUP GET_SEQ @
		SWAP GET_SOL @ =
		SWAP DUP	
	0= UNTIL	
	DROP
;

: SUM ( comparisons -- sum )
	LEVEL @				
	BEGIN				
		1- 
		SWAP ROT +
		SWAP DUP
	1 = UNTIL
	DROP
;

: CHECK ( -- )
	COMPARE
	LEVEL @
	1 > IF
		SUM
	THEN
	NEGATE
	LEVEL @
	= IF
		+SCORE
	ELSE
		-SCORE
	THEN
;

: SETTINGS ( {n1 n2} -- )
	DEPTH 2 
	= IF
		OVER OVER >
		IF SWAP THEN	
		
		OVER 0 >				
		IF
			MAX_LVL !
			DUP MIN_LVL ! LEVEL !
		ELSE
			DROP DROP
		THEN		
	THEN
;


: CHANGE_COLORS ( n -- )
	DUP 1 >
	OVER 4 <
	AND
	IF
		COLORS !
	ELSE
		DROP
	THEN
;

\ --- ./main.f --- 

SET_ARRAY
INIT_GPIO

: LOOP ( -- )
	LEVEL @ DUP 
	." Level " . CR
	BEGIN
		1- DUP
		WAIT_BUTTON
		?PRESSED @ DUP BLINK SWAP GET_SEQ !
		RESET
		DUP
	0= UNTIL
	DROP
;

: START ( {n1 n2} -- )
	SETTINGS
	BEGIN
		GEN_SOL
		LED_SEQ
		LOOP
		CHECK
		1 SEC DELAY
	?EXIT @ 1 = UNTIL
	0 ?EXIT !
;


