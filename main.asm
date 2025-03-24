;*****************************************************************
;* ECE-3731 FINAL PROJECT: PIN-CODE LOCK
;* BY SHUBAN SRIKANTHA, DEVIN PEN, ANTHONY D'ALFONSO, & HENRY CHEN
;*****************************************************************

 ;export symbols
 XDEF Entry, _Startup ;export 'Entry' symbol
 ABSENTRY Entry ;for absolute assembly: mark this as application entry point

 ;Include derivative-specific definitions 
 INCLUDE 'derivative.inc' 
		
;----------------------------------------------------
; Equates Section  
;---------------------------------------------------- 
 
ROMStart EQU $2000  ; absolute address to place my code

 ;YOUR EQUATES HERE
TIM_PRESCALER EQU %110

;---------------------------------------------------- 
; Variable/Data Section
;---------------------------------------------------- 
 
 ORG RAMStart ;loc $1000 (RAMEnd = $3FFF)
 
 ;YOUR VARIABLES HERE

PIN0 DS 1
PIN1 DS 1
PIN2 DS 1
PIN3 DS 1

SET0 DS 1
SET1 DS 1
SET2 DS 1
SET3 DS 1

COUNT DC.B 0

NUM DS 1

COUNTER DS 2
SECONDS DS 1

FLG DC.B 0

ATTEMPT DC.B 3
 
STR1 DC.B "Enter a 4-number" , 0
STR2 DC.B "PIN: " , 0
STR3 DC.B "Working" , 0
STR4 DC.B "  NEW PIN SET!" , 0
STR5 DC.B "ENTER YOUR PIN: " , 0
STR6 DC.B "   TRY AGAIN!" , 0
STR7 DC.B " SYSTEM LOCKED!" , 0
STR8 DC.B "   LOGGED IN!" , 0

 INCLUDE 'utilities.inc'
 INCLUDE 'LCD.inc'

;---------------------------------------------------- 
; Code Section
;---------------------------------------------------- 

 ORG ROMStart ;loc $2000
Entry:
_Startup:

 ;remap the RAM &amp; EEPROM here. See EB386.pdf
 ifdef _HCS12_SERIALMON
 
   ;set registers at $0000
   CLR $11 ;INITRG= $0
   
   ;set ram to end at $3FFF
   LDAB #$39
   STAB $10 ;INITRM= $39

   ;set eeprom to end at $0FFF
   LDAA  #$9
   STAA  $12 ;INITEE= $9
   JSR   PLL_init ;initialize PLL 
    
 endif

;---------------------------------------------------- 
; YOUR CODE HERE
;---------------------------------------------------- 

;Remember that the following subroutines (functions) are available to you from here on out: 
  
;ms_delay       -> delays for a number of milliseconds. Load the number of milliseconds to delay into accumulator D
;clear_lcd      -> clears the lcd
;set_lcd_cursor -> sets the cursor position on the LCD. Load the cursor position (0-31) into accumulator B
;hex2lcd        -> prints the value of accumulator B to the LCD in hex
;dec2lcd        -> prints the value of accumulator B to the LCD in dec
;lcd_printf     -> prints a zero-terminated string to the LCD. Load a pointer to the string in accumulator D (LDD #STR)
;lcd_putchar    -> prints an ASCII character to the LCD. Load the character into accumulator B.
     
     
       
  LDS #ROMStart ;initialize the stack pointer
  JSR LED_INIT ;initialize LEDs
  JSR lcd_init ;initialize the LCD
  
  
;Keypad setup
  MOVB #$0F, DDRA
  BSET PUCR, $01

;Prompt user to create a 4-digit PIN
  JSR clear_lcd
  
  LDAB #0
  JSR set_lcd_cursor
  
  LDD #STR1
  JSR lcd_printf
  
  LDAB #16
  JSR set_lcd_cursor
  
  LDD #STR2
  JSR lcd_printf
  
  
LOOP
 
  LDAA #01
  CMPA FLG
  BEQ EXIT_L
  
  JSR CHECK_KEYPAD
  LDD #250
  JSR ms_delay
  
  JMP LOOP
  
EXIT_L

  JSR SET_PIN
  
  JSR PROMPT0_TO_LCD
  
NEW_ATTEMPT

  JSR ENABLE_KEYPAD
  
  JSR PROMPT4_TO_LCD
  
LOOP2
 
  LDAA #01
  CMPA FLG
  BEQ EXIT_L2
  
  JSR CHECK_KEYPAD
  LDD #250
  JSR ms_delay
  
  JMP LOOP2
  
EXIT_L2
  
  LDAB PIN0
  CMPB SET0
  BNE CHECK
  
  LDAB PIN1
  CMPB SET1
  BNE CHECK
  
  LDAB PIN2
  CMPB SET2
  BNE CHECK
  
  LDAB PIN3
  CMPB SET3
  BNE CHECK
  
  JMP LOGGED_IN
  
CHECK
  LDAA ATTEMPT
  DECA
  STAA ATTEMPT
  
  LDAB ATTEMPT
  CMPB #0
  BEQ FAILED
  
  
  JSR PROMPT1_TO_LCD
  JSR PROMPT4_TO_LCD
  
  JMP NEW_ATTEMPT
  
  
FAILED
  JSR PROMPT2_TO_LCD
  
  BSET PTP,%00010000
  
  JSR INIT_TIM5_OC
  
  BSET TC5, 62
  
  JSR TIM_ENABLE
  
  
  JMP QUIT
  
  
LOGGED_IN

  JSR PROMPT3_TO_LCD
  BSET PTP,%01000000  
 
 
QUIT BRA *


           
;---------------------------------------------------- 
; Subroutines
;---------------------------------------------------- 

  ;initialize channel 5 of timer for output compare
INIT_TIM5_OC
  SEI
  
  BSET TIOS, $20 ;set channel 5 to output compare mode
  MOVB #$04, TCTL1 ;set PT5 to toggle on output compare event
  MOVB #$20, TIE ;enable interrupt when output compare occurs on timer channel 5 
  BSET TSCR2, TIM_PRESCALER ;set timer prescaler  
  
  CLI
  RTS
  
  
  
  ;enable timer
TIM_ENABLE  
  BSET TSCR1, $80
  RTS
  
TIM5_ISR

  ;YOUR ISR CODE HERE
  LDD #62
  ADDD TC5
  STD TC5
  
  LDD #6000
  CPD COUNTER
  BEQ INCREMENT
  
  JMP HERE   
  
  
INCREMENT
  INC SECONDS 
  LDD #0
  STD COUNTER
  
HERE
  LDD #1
  ADDD COUNTER
  STD COUNTER
  
    
  BSET TFLG1, $20
  RTI


CHECK_KEYPAD

;COL_2, KEY 2, 6, 10
  BSET PORTA,%00001111
  BCLR PORTA,%00000100
  
;Check if 3 is pressed
  MOVB #03,NUM
  LDAA #%11101011
  CMPA PORTA
  BEQ KEY_PRESSED
  
;Check if 6 is pressed
  MOVB #06,NUM
  LDAA #%11011011
  CMPA PORTA
  BEQ KEY_PRESSED
  
;Check if 9 is pressed
  MOVB #09,NUM
  LDAA #%10111011
  CMPA PORTA
  BEQ KEY_PRESSED
  
  
  
;COL_1, KEY 1, 5, 9, 13
  BSET PORTA,%00001111
  BCLR PORTA,%00000010
  
;Check if 2 is pressed
  MOVB #02,NUM
  LDAA #%11101101
  CMPA PORTA
  BEQ KEY_PRESSED
  
;Check if 5 is pressed
  MOVB #05,NUM
  LDAA #%11011101
  CMPA PORTA
  BEQ KEY_PRESSED
  
;Check if 8 is pressed
  MOVB #08,NUM
  LDAA #%10111101
  CMPA PORTA
  BEQ KEY_PRESSED
  
;Check if 0 is pressed
  MOVB #00,NUM
  LDAA #%01111101
  CMPA PORTA
  BEQ KEY_PRESSED
  
  
 
;COL_0, KEY 0, 4, 8
  BSET PORTA,%00001111
  BCLR PORTA,%00000001
  
;Check if 1 is pressed
  MOVB #01,NUM
  LDAA #%11101110
  CMPA PORTA
  BEQ KEY_PRESSED
  
;Check if 4 is pressed
  MOVB #04,NUM
  LDAA #%11011110
  CMPA PORTA
  BEQ KEY_PRESSED
  
;Check if 7 is pressed
  MOVB #07,NUM
  LDAA #%10111110
  CMPA PORTA
  BEQ KEY_PRESSED
  
  JMP OUT
  
;Check which PIN index we are on
KEY_PRESSED

  ;LDD #STR3
  ;JSR lcd_printf
  
  LDAB COUNT
  CMPB #0
  BEQ SET_PIN0
  
  LDAB COUNT
  CMPB #1
  BEQ SET_PIN1
  
  LDAB COUNT
  CMPB #2
  BEQ SET_PIN2
  
  LDAB COUNT
  CMPB #3
  BEQ SET_PIN3
  
;Set value of PIN at correct index
SET_PIN0
  MOVB NUM,PIN0
  MOVB #01,COUNT
  
  LDAB PIN0
  JSR dec2lcd
  
  JMP OUT
  
SET_PIN1
  MOVB NUM,PIN1
  MOVB #02,COUNT
  
  LDAB PIN1
  JSR dec2lcd
  
  JMP OUT
  
SET_PIN2
  MOVB NUM,PIN2
  MOVB #03,COUNT
  
  LDAB PIN2
  JSR dec2lcd
  
  JMP OUT
  
SET_PIN3
  MOVB NUM,PIN3
  MOVB #01,FLG
  
  LDAB PIN3
  JSR dec2lcd
  
  JMP OUT
  
  
OUT RTS

SET_PIN
  MOVB PIN0, SET0
  MOVB PIN1, SET1
  MOVB PIN2, SET2
  MOVB PIN3, SET3
  
  
  RTS
  
ENABLE_KEYPAD
  MOVB #00,FLG
  MOVB #00,COUNT
  
  RTS



PROMPT0_TO_LCD
  LDD #1500
  JSR ms_delay
  
  JSR clear_lcd
  
  LDAB #0
  JSR set_lcd_cursor
  
  LDD #STR4
  JSR lcd_printf
   
  
  RTS
  
PROMPT1_TO_LCD
  LDD #1500
  JSR ms_delay
  
  JSR clear_lcd
  
  LDAB #0
  JSR set_lcd_cursor
  
  LDD #STR6
  JSR lcd_printf

  
  RTS
  

PROMPT2_TO_LCD
  LDD #1500
  JSR ms_delay
  
  JSR clear_lcd
  
  LDAB #0
  JSR set_lcd_cursor
  
  LDD #STR7
  JSR lcd_printf
   
  
  RTS
  
PROMPT3_TO_LCD
  LDD #1500
  JSR ms_delay
  
  JSR clear_lcd
  
  LDAB #0
  JSR set_lcd_cursor
  
  LDD #STR8
  JSR lcd_printf
   
  
  RTS
  
PROMPT4_TO_LCD
  LDD #1000
  JSR ms_delay
  
  JSR clear_lcd
  
  LDAB #0
  JSR set_lcd_cursor
   
  LDD #STR5
  JSR lcd_printf
  
  LDAB #16
  JSR set_lcd_cursor
  
  RTS

  ;initialize peripherals
LED_INIT

  LDAA #$FF
  STAA DDRB ;set all pins on port b to output
  STAA DDRJ ;set all pins on port j to output
  STAA DDRP ;set all pins on port p to output
  BSET DDRM, $04 ;set PM2 to output
  
  BSET PTP, $0F ;set PP0-PP3 (disable 7-segment displays)
  BCLR PTP, $70 ;clear RGB LED
  BCLR PTJ, $02 ;clear PJ1 (enable LEDs)
  BCLR PTM, $04 ;clear PM2 (enable RGB)
  CLR PORTB ;turn off LEDs
  
  RTS

  




;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
 ORG Vreset
 DC.W Entry ;Reset Vector
 
 ORG Vtimch5
 DC.W TIM5_ISR
 