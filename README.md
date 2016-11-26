## Milestones
<<<<<<< 93eb226a495af9b142eeacdf5a6a502710d51099
* core
* pipeline
* cache

## currently under construction
* core:datamemory
=======
-core
-pipeline
-cache

## currently under construction
-core:datamemory

## instructionset
| state | bincode | mnem |
| ----- | ----------------- | ----- |
|       | 100101001SSS1000 | bclr |
|       | 100101000SSS1000 | bset |
|       | 1001010100001001 | icall|
|       | 1001010000001001 | ijmp |
|   x   | 0000000000000000 | nop  |
|       | 1001010100001000 | ret  |
|       | 1001010100011000 | reti |
|       | 1001010110001000 | sleep|
|       | 1001010110011000 | break|
|       | 000111rdddddrrrr | adc  |
|   x   | 000011rdddddrrrr | add  |
|   x   | 001000rdddddrrrr | and  |
|   x   | 000101rdddddrrrr | cp	  | 
|       | 000001rdddddrrrr | cpc  |
|   x   | 001001rdddddrrrr | eor  |
|   x   | 001011rdddddrrrr | mov  | 
|   x   | 001010rdddddrrrr | or   | 
|       | 000010rdddddrrrr | sbc  |
|   x   | 000110rdddddrrrr | sub  | 
|       | 001001rdddddrrrr | clr  |
|   x   | 000011rdddddrrrr | lsl  |
|       | 000111rdddddrrrr | rol  |
|       | 001000rdddddrrrr | tst  |
|   x   | 0111KKKKddddKKKK | andi |  
|       | 0111KKKKddddKKKK | cbr  |   
|   x   | 1110KKKKddddKKKK | ldi  |
|       | 11101111dddd1111 | ser  |   
|   x   | 0110KKKKddddKKKK | ori  |
|       | 0110KKKKddddKKKK | sbr  |
|   x   | 0011KKKKddddKKKK | cpi  |
|       | 0100KKKKddddKKKK | sbci |
|   x   | 0101KKKKddddKKKK | subi |
|       | 1111110rrrrr0sss | sbrc |
|       | 1111111rrrrr0sss | sbrs |
|       | 1111100ddddd0sss | bld  |
|       | 1111101ddddd0sss | bst  |
|       | 10110PPdddddPPPP | in   |
|       | 10111PPrrrrrPPPP | out  |
|       | 10010110KKddKKKK | adiw |
|       | 10010111KKddKKKK | sbiw |
|       | 10011000pppppsss | cbi  |
|       | 10011010pppppsss | sbi  |
|       | 10011001pppppsss | sbic |
|       | 10011011pppppsss | sbis |
|       | 111101lllllll000 | brcc |
|       | 111100lllllll000 | brcs |
|   x   | 111100lllllll001 | breq | 
|       | 111101lllllll100 | brge | 
|       | 111101lllllll101 | brhc |
|       | 111100lllllll101 | brhs |
|       | 111101lllllll111 | brid |
|       | 111100lllllll111 | brie | 
|       | 111100lllllll000 | brlo |
|       | 111100lllllll100 | brlt | 
|       | 111100lllllll010 | brmi | 
|   x   | 111101lllllll001 | brne | 
|       | 111101lllllll010 | brpl |
|       | 111101lllllll000 | brsh |
|       | 111101lllllll110 | brtc |
|       | 111100lllllll110 | brts |
|       | 111101lllllll011 | brvc |
|       | 111100lllllll011 | brvs |
|       | 111101lllllllsss | brbc |
|       | 111100lllllllsss | brbs |
|       | 1101LLLLLLLLLLLL | rcall|
|       | 1100LLLLLLLLLLLL | rjmp |
|       | 1001010hhhhh111h | call |
|       | 1001010hhhhh110h | jmp  |
|       | 1001010rrrrr0101 | asr  |
|       | 1001010rrrrr0000 | com  | 
|   x   | 1001010rrrrr1010 | dec  |
|   x   | 1001010rrrrr0011 | inc  |
|   x   | 1001010rrrrr0110 | lsr  |
|       | 1001010rrrrr0001 | neg  |
|       | 1001000rrrrr1111 | pop  |
|       | 1001001rrrrr1111 | push |
|       | 1001010rrrrr0111 | ror  |
|       | 1001010rrrrr0010 | swap | 
|       | 1001001ddddd0000 | sts  |
|       | 1001000ddddd0000 | lds  |
|       | 10o0oo0dddddbooo | ldd  |
|   x   | 100!000dddddee-+ | ld   |
|       | 10o0oo1rrrrrbooo | std  |
|   x   | 100!001rrrrree-+ | st   |
|       | 1001010100011001 | eicall|
|       | 1001010000011001 | eijmp|
>>>>>>> f0a7d01e49c706d3c50c991a0af675d9b33424ef
