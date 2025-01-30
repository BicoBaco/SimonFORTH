\ Inizializza gli array utilizzati per accedere ai led e ai bottoni
SET_ARRAY

\ Inizializza i pin GPIO
INIT_GPIO

\ Main loop che aspetta che venga premuto un bottone e mostra ciò che è stato premuto
\ visivamente e uditivamente tante volte quanto il valore del livello corrente
: LOOP ( -- )
	LEVEL @ DUP 
	." Level " . CR
	BEGIN
		1- DUP
		WAIT_BUTTON				\ Busy wait bottone
		?PRESSED @ DUP BLINK SWAP GET_SEQ !	\ Blink, suono e salvataggio del bottone premuto
		RESET					\ Reset variabile che segna l'ultimo bottone premuto
		DUP
	0= UNTIL
	DROP
;

\ Avvia la partita
\ È possibile inserire nello stack 2 numeri, n1 e n2, che modificano il livello massimo e minimo
: START ( {n1 n2} -- )
	SETTINGS			\ Se forniti, cambia i livelli max e min
	BEGIN
		GEN_SOL			\ Genera la soluzione
		LED_SEQ			\ Mostra la soluzione
		LOOP			\ Main Loop
		CHECK			\ Controllo della sequenza premuta
		1 SEC DELAY
	?EXIT @ 1 = UNTIL		\ Controllo uscita in caso di perdita al livello 2
	0 ?EXIT !
;