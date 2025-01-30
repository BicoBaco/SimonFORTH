\ Alcune definizioni provenienti dalla repository jonesforth di Richard W.M. Jones, 
\ l'autore dell'interprete FORTH JonesForth. 
\ Queste word permettono l'inserimento di commenti e la stampa su terminale, 
\ i quali non sono strettamente necessari per il funzionamento del progetto

: '(' [ CHAR ( ] LITERAL ;
: ')' [ CHAR ) ] LITERAL ;
: '"' [ CHAR " ] LITERAL ;
: '.' [ CHAR . ] LITERAL ;

\ Permette l'inserimento di commenti nel codice del tipo ( x -- y)
: ( IMMEDIATE 1 BEGIN KEY DUP '(' = IF DROP 1+ ELSE ')' = IF 1- THEN THEN DUP 0= UNTIL DROP ;

\ Arrotonda c-addr ai prossimi 4 byte
\ In pratica rende l'indirizzo word-aligned con ARM
: ALIGNED ( c-addr -- a-addr ) 3 + 3 INVERT AND ;

\ Allinea il puntatore HERE
: ALIGN HERE @ ALIGNED HERE ! ;

\ Preleva un byte dallo stack e lo inserisce in HERE
: C, HERE @ C! 1 HERE +! ;

\ Crea una stringa e inserisce il suo indirizzo e la sua lunghezza nello stack
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

\ Stampa una stringa sul terminale
: ." IMMEDIATE ( -- )
	STATE @ IF
		[COMPILE] S" ' TELL ,
	ELSE
		BEGIN KEY DUP '"' = IF DROP EXIT THEN EMIT AGAIN
	THEN
;

\ Ridefinizione di HERE e ALLOT
\ ALLOT alloca n byte consecutivi, con n TOS
\ HERE punta all'indirizzo del prossimo byte libero in memoria. 
\ Utilizzato per salvare le word durante la compilazione.
: JF-HERE   HERE ;
: HERE   JF-HERE @ ;
: ALLOT   HERE + JF-HERE ! ;
