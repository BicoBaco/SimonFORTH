HEX

\ Dichiarazione costanti con indirizzi utili del Raspberry Pi 3B
3F000000 CONSTANT PERI_BASE
PERI_BASE 200000 + CONSTANT GPIO_BASE
GPIO_BASE 4 + CONSTANT GPFSEL1
GPIO_BASE 8 + CONSTANT GPFSEL2
GPIO_BASE 1C + CONSTANT GPSET0
GPIO_BASE 28 + CONSTANT GPCLR0
GPIO_BASE 34 + CONSTANT GPLEV0

\ Blocchi da 32 bit per l'allocazione di celle
: CELLS ( n_blocks -- tot_size ) 
	5 LSHIFT 
;

\ Conversione del numero del pin da hex a 32-bit hex
: PIN_TO_WORD ( pin# -- pin_word )		
	1 SWAP LSHIFT 
;

\ Identifica il numero di colori
\ Si può modificare in caso di aggiunta o rimozione di tasti 
VARIABLE COLORS		4 COLORS !

\ Livello massimo e minimo
VARIABLE MAX_LVL	A MAX_LVL !
VARIABLE MIN_LVL	1 MIN_LVL !

\ Variabile utilizzata per tenere conto del livello corrente 
\ e come indice nei loop
VARIABLE LEVEL		MIN_LVL @ LEVEL !

\ Variabile utilizzata per tenere conto dell'indice dell'ultimo tasto premuto
VARIABLE ?PRESSED 	-1 ?PRESSED !

\ Array che contengono i pin delle componenti hw, 
\ la sequenza soluzione (SOL) e la sequenza premuta (SEQ)
VARIABLE LEDS		COLORS @ 1- CELLS ALLOT
VARIABLE BUTTONS	COLORS @ 1- CELLS ALLOT
VARIABLE SOL		MAX_LVL 1- CELLS ALLOT
VARIABLE SEQ		MAX_LVL 1- CELLS ALLOT

\ Word che permettono di recuperare velocemente gli elementi degli array dato l'indice
: GET_LED ( led# -- led_pin )	CELLS LEDS + ;
: GET_BTN ( btn# -- btn_pin )	CELLS BUTTONS + ;
: GET_SOL ( index -- led# )	CELLS SOL + ;
: GET_SEQ ( index -- led# )	CELLS SEQ + ;

\ Costante dedicata al pin del buzzer
18 PIN_TO_WORD CONSTANT BUZZER		\ gpio 24

\ Popolazione degli array
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

\ Inizializzazione funzioni GPIO
: INIT_GPIO ( -- )	
	GPFSEL2 @ 00000008 00000001 00001000 OR OR OR GPFSEL2 !
	GPFSEL1 @ 00040000 00000040 OR OR GPFSEL1 !
;