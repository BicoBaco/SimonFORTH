\ Variabile utilizzata per l'uscita dal gioco in caso di perdita al livello 2
VARIABLE ?EXIT		0 ?EXIT !

DECIMAL

\ Incrementa il livello e produce il suono corrispondente alla vittoria
: +SCORE ( -- )
	BUZZER ON
	400 MS DELAY
	BUZZER OFF
	." Won" CR CR
	LEVEL @ 
	MAX_LVL @ < IF		\ incrementa livello se non è il livello massimo
		1 LEVEL +!
	ELSE			\ altrimenti finisce la partita
		1 ?EXIT !
		." Game won!" CR
	THEN
;

\ Decrementa il livello, produce il suono corrispondente alla sconfitta 
\ e, in caso di livello troppo basso, imposta il flag per l'uscita
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
	1 > IF			\ se il livello è maggiore di 2, decrementa
		-1 LEVEL +!
	ELSE			\ altrimenti la partita è persa
		1 ?EXIT !
		." Game lost" CR
	THEN
;

HEX

\ Confronta la sequenza premuta con la soluzione
\ 0 se l'i-esimo elemento della sequenza è diverso dall'i-esimo elemento della soluzione, -1 se uguali
\ comparisons = 0/-1, ..., 0/-1
: COMPARE ( -- comparisons )
	LEVEL @	
 	BEGIN									
		1- DUP 			\ [ i, i ]
 		DUP GET_SEQ @ 		\ [ i, i, seq_i ]
		SWAP GET_SOL @ =	\ [ i, seq_i, sol_i ] -> [ i, 0/-1 ]
		SWAP DUP		\ [ 0/-1, i, i ]	
	0= UNTIL	
	DROP
;

\ Somma i confronti, se la sequenza coincide con la soluzione allora la somma sarà uguale al livello corrente
: SUM ( comparisons -- sum )
	LEVEL @				
	BEGIN				
		1- 			\ [ 0/-1, ..., 0/-1, i]
		SWAP ROT +		\ [ 0/-1, ..., i, 0/-1, 0/-1 ]	-> [ 0/-1, ..., i, 0/-n ] 
		SWAP DUP
	1 = UNTIL
	DROP
;

\ Controlla che la sequenza sia corretta e cambia il livello corrente a seconda dell'esito
: CHECK ( -- )
	COMPARE
	LEVEL @
	1 > IF				\ Al livello 1 non è necessaria la somma dei confronti
		SUM			
	THEN
	NEGATE 				\ La somma è negativa
	LEVEL @
	= IF
		+SCORE
	ELSE
		-SCORE
	THEN
;

\ Cambia il livello massimo, minimo e di partenza a seconda dei valori inseriti nello stack
\ Imposta automaticamente il maggiore a MAX_LVL e il minore a MIN_LVL e controlla che MIN_LVL sia positivo
: SETTINGS ( {n1 n2} -- )
	DEPTH 2 
	= IF
		OVER OVER > 		\ se stack: [ max min ] 
		IF SWAP THEN		\ in questo modo il maggiore è TOS
		
		OVER 0 >				
		IF
			MAX_LVL !
			DUP MIN_LVL ! LEVEL !
		THEN		
	THEN
;

\ Cambia il numero di colori, e quindi coppie led/bottone, utilizzate durante la partita.
\ Il numero massimo è 4 poiché COLORS viene utilizzato per i loop e non è possibile
\ utilizzare un numero maggiore di quello installato. Si può facilmente cambiare nel caso
\ in cui si aggiungessero coppie led/bottone
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

