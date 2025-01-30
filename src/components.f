\ Accensione e spegnimento di un componente (led/buzzer) prelevando dal TOS il valore pin
: ON ( pin -- )	GPSET0 ! ;
: OFF ( pin -- ) GPCLR0 ! ;

DECIMAL 

\ --- Buzzer ---

\ Genera note diverse col buzzer attivo sfruttando il principio di modulazione di ampiezza con 
\ l'introduzione di un delay, preso dallo stack, che modifica la durata degli impulsi del buzzer
\ e, di conseguenza, la frequenza
: BUZZ ( us_delay -- )
	500 MS 			\ durata del suono: 500ms, sommato al 
	NOW +			\ valore attuale del clock di sistema
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

\ In base al colore che è stato scelto, e quindi al numero del bottone premuto,
\ fornisce i microsecondi di delay utilizzati nella word BUZZ per produrre il suono associato.
\ verde: 116 us, giallo: 132 us, rosso: 164 us, blu: 228 us
: BUZZ_DELAY ( led#/btn# -- us_delay )
	3 +			\ in modo da rendere l'operazione 
	2 SWAP LSHIFT		\ 100 + 2^(led#+4)
	100 +
	US
;


HEX


\ --- LED ---

\ Controlla se il led corrispondente a led# è acceso. 
\ Inserisce nello stack il pin del led se è acceso, 0 altrimenti
: ?ON ( led# -- led_state )		
	GPLEV0 @ SWAP  			\ [gplev0@ led#]
	GET_LED @ AND			\ [gplev0@ led_pin] -> [0 = off / led_pin = on]
;	

\ Cambia lo stato del led dato il suo numero (indice nell'array LEDs)
: SWITCH_LED ( led# -- )
	DUP
	?ON 0= 		
	IF
		GET_LED @ ON		\ dato l'indice del led, GET_LED inserisce nello stack
					\ il suo pin, utilizzato da ON
	ELSE				
		GET_LED @ OFF		\ come sopra
	THEN
;

DECIMAL

\ Illumina il led corrispondente all'indice nello stack e riproduce il suo suono
: BLINK ( led# -- )
	DUP SWITCH_LED
	DUP BUZZ_DELAY BUZZ
	SWITCH_LED
	200 MS DELAY
;

HEX

\ Mostra la sequenza soluzione da riprodurre utilizzando led e buzzer
: LED_SEQ ( -- )
	LEVEL @
 	BEGIN
		1- DUP DUP	
		GET_SOL @ BLINK
	0= UNTIL
	DROP
;


\ --- Bottoni ---

\ Assegna e resetta la variabile che contiene l'indice dell'ultimo bottone premuto
: PRESS ( n -- )	?PRESSED ! ;
: RESET ( -- )		-1 ?PRESSED ! ;

\ Attesa e controllo del bottone premuto
: WAIT_BUTTON ( -- )
	COLORS @			\ # colori/tasti
	BEGIN
		DUP 0= IF 		\ se il check dei bottoni è terminato senza che
			DROP COLORS @	\ sia stato premuto un tasto, ricomincia
		THEN

		1- DUP 			\ stack: [ i, i ]
		GPLEV0 @ SWAP 		\ [ i, gplev0@, i ]
		GET_BTN @ AND  		\ [ i, gplev0@, btn_i ] -> [ i, on? ]
		0 <> IF	
			PRESS		\ [ i ] -> [ ] 
		THEN			\ else [ i ]	
	?PRESSED @ -1 > UNTIL		
;


