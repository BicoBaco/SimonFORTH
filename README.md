# SimonFORTH
Implementation of the electronic game “Simon” with bare-metal programming on Raspberry Pi 3B, using the FORTH language and basic electronic components.

The original Simon game consists of four buttons that light up, each of a different colour for visual feedback and paired with a musical note for sound feedback. 
The objective of the game is to memorise and repeat a sequence of buttons to which, with each level passed, a new random button to press is added.

Operating System used: PERIpijFORTHos, a versione of the pijFORTHos environment based on the FORTH JonesForth interpreter implementation, written in Assembly x86.

Interesting feature: 
Generation of different sounds by using an active buzzer (single-frequency) through amplitude modulation obtained by the use of delays between the repeated activations of the buzzer.
