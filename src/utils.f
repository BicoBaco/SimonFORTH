\ --- Temporizzazione ---

HEX

\ Indirizzo del clock di sistema
\ Tiene conto dei cicli trascorsi dall'avvio del sistema
PERI_BASE 3004 + CONSTANT SYSCLK

DECIMAL

\ Restituisce il valore del clock di sistema
: NOW ( -- clk_value ) SYSCLK @ ;

\ Unità di misura per convertire i microsecondi in millisecondi e secondi
: US ( -- ) ;
: MS ( us -- ms ) 1000 * ;
: SEC ( us -- s ) 1000 MS * ;

\ Effettua un delay in base ai microsecondi in input utilizzando il clock di sistema
: DELAY ( us_delay -- )
	NOW + 
	BEGIN 
		DUP 
		NOW - 
	0 <= UNTIL 
	DROP 
;


\ --- Generazione casuale ---

\ Generatore di numeri pseudocasuali che inserisce nello stack un numero 32-bit
\ Il valore iniziale del seed è arbitrario e cambia a ogni generazione ma,
\ scegliendo il valore del clock di sistema al momento della generazione, si
\ assicura che sia sempre diverso
VARIABLE SEED	NOW SEED !
: XORSHIFT ( -- u ) 
    SEED @
    DUP 13 LSHIFT XOR
    DUP 17 RSHIFT XOR
    DUP 5  LSHIFT XOR
    DUP SEED !
;

\ Genera la sequenza soluzione utilizzando l'algoritmo XORSHIFT e la memorizza 
\ nell'array apposito. Utilizza il livello corrente come indice
: GEN_SOL ( -- )
	LEVEL @
	BEGIN
		1- DUP DUP		
		XORSHIFT 		\ Genera il numero casuale
		COLORS @ MOD 		\ Modulo del numero generato per ridurlo 
					\ al range dei bottoni presenti
		SWAP GET_SOL !	
	0= UNTIL
	DROP
;