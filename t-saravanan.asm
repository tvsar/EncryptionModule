; Tharun Saravanan Project 4
.ORIG x3000
    AND R1, R1, #0 ; Zero out registers
    AND R2, R2, #0
    AND R3, R3, #0
    AND R4, R4, #0
    AND R5, R5, #0
    AND R6, R6, #0
    AND R7, R7, #0
    
    LEA R0, startmsg    ; Load start message
    PUTS    ; print  message
    
Loop    
    LEA R0, query    ; Load enter message
    PUTS    ; print  message
    GETC ;Loop
    ADD  R6, R0, #0 ;Store the input value into R6
    
    ; Checking for Encode routine
    LD R7, negCapE ;Load negative ASCII for 'E' into R7
    ADD R7, R6, R7  ;Add the input value with the ASCII value to see if match
    BRnp capD ;If non-zero, doesn't match. Branch to next check function
    LD R5, goKEY ;Invoke encrypt input routine to get input key
    JSRR R5
    LD R5, goIN ;Invoke encrypt input routine to get input key
    JSRR R5      
    LD R4, MESSAGE ; load message address into R4
    LD R5, encryptVI ;Invoke encrypt input routine to get input key ;;;;;
    JSRR R5 ;;;;;;
    LD R5, encryptCA ;Invoke encrypt input routine to get input key
    JSRR R5
    LD R5, encryptBIT ;Invoke encrypt input routine to get input key
    JSRR R5
    LD R5, clearKEY ;Invoke clearkey routine to clear keys
    JSRR R5
    ADD R5, R5, #0  ; case fulfilled, loop back to start
    BRnzp Loop    ; back to start of loop
    
    ; Checking for Decode routine
    capD    LD R7, negCapD ;Load negative ASCII for 'D' into R7
    ADD R7, R6, R7  ;Add the input value with the ASCII value to see if match
    BRnp capX ;If non-zero, doesn't match. Branch to next check function
    LD R5, goKEY ;Invoke encrypt input routine to get input key
    JSRR R5
    LD R5, decryptBIT ;Invoke encrypt input routine to get input key
    JSRR R5 
    LD R5, decryptCA ;Invoke encrypt input routine to get input key
    JSRR R5
    LD R4, DECRYPTM ; load message address into R4
    LD R5, encryptVI ;Invoke encrypt input routine to get input key
    JSRR R5
    LD R5, clearKEY ;Invoke clearkey routine to clear keys
    JSRR R5
    ADD R5, R5, #0  ; case fulfilled, loop back to start
    BRnzp Loop    ; back to start of loop
    
    ; Checking for exit routine
    capX LD R7, negCapX ;Load negative ASCII for 'X' into R7
    ADD R7, R6, R7  ;Add the input value with the ASCII value to see if match
    BRnp invalidCh ;If non-zero, doesn't match. Branch to next check function
    AND R2, R2, #0 ;Zero out R3
    AND R3, R3, #0 ;Zero out R3
    ADD R3, R3, #10 ;Counter of where data is
    LD R4, MESSAGE ; load message address into R4
    LD R5, DECRYPTM ;load decrypted message address into R5
EXITLOOP    STR R2, R4, #0  
	        STR R2, R5, #0
	        ADD R4, R4, #1 ; Increment message address pointer
	        ADD R5, R5, #1 ; Increment decrypted message address pointer
            ADD R3, R3, #-1 ; Increment loop check to loop 10 times
            BRp EXITLOOP ; exit once clearing 10 addresses of Encrypt and Decrypt message location
    HALT
    
    invalidCh LEA R0, invalid    ; Otherwise load error message
    PUTS    ; print  message
    ADD R5, R5, #0 
    BRnzp Loop    ; Return to top of loop

done HALT   ;end program

clearKEY   .FILL   ERASEKEY ; initialize variable clearKEY to the address/label of subroutine ERASEKEY
; subroutine ERASEKEY input
ERASEKEY AND R0, R0, #0 ;Zero out R0
        ST R0, Key1 ;Store 0 into all of the key storages
        ST R0, Key2 ;Store 0 into all of the key storages
        ST R0, Key3 ;Store 0 into all of the key storages
        ST R0, Key4 ;Store 0 into all of the key storages
        ST R0, Key5 ;Store 0 into all of the key storages
        AND R3, R3, #0  ;   Zero out the 3 digit number sum representing K
        STI R3, sum  ; Store value back into address
        RET ;Return to caller

goKEY   .FILL   KEYIN ; initialize variable goKEY to the address/label of subroutine KEYIN
; subroutine key input
KEYIN   AND R3, R3, #0  ;   Zero out the 3 digit number sum representing K
        STI R3, sum  ; Store value back into address

        LEA R0, keymsg    ; Load enter message
        PUTS    ; print message
        LD R1, negNum ;Load -48 into R1 to convert input to numeric
        
        GETC ;take first digit in
        ADD R0, R0, R1
        ST  R0, Key1  ; save first digit of key
        GETC ;take second digit in
        ST  R0, Key2  ; save second of key
        GETC ;take third digit in
        ADD R0, R0, R1
        ST  R0, Key3  ; save third digit of key
        GETC ;take fourth digit in
        ADD R0, R0, R1
        ST  R0, Key4  ; save fourth digit of key
        GETC ;take fifth digit in
        ADD R0, R0, R1
        ST  R0, Key5  ; save fifth digit of key
        
checkFirst  LD R0, Key1 ;Load Key1 value back into R0
        ADD R0, R0, #0 ;Add 0 to the fist digit
        BRn invalidIn ;If negative, then the number must have been non-numeric, branch to error
        ADD R0, R0, #-7 ;Add -7 to the fist digit
        BRp invalidIn ;If positive, then the number must have been <= 8 or non-numeric, branch to error
        
checkSecond LD R1, negNum ;Load -48 into R1 to check if non-numeric with ascii < 48
        LD R0, Key2 ;Load Key2 value back into R0
        ADD R0, R0, R1 ;Add -48 to the second digit
        BRnz checkThird ;0 and ascii values under 48 are valid input, branch to third input check
        ADD R0, R0, #-10 ;Add another -10 to check if non-numeric with ascii > 58
        BRn invalidIn ;If negative, number is numeric

checkThird  LD R0, Key3 ;Load Key3 value back into R0
        ADD R0, R0, #0 ;Add 0 to the hundreds digit
        BRz checkFourth ; If 0, nothing to add 
        ADD R0, R0, #-1 ;Add -1 to the hundreds digit
        BRnp invalidIn ;If positive, number is greater than 1 (invalid)  ;;;;;;;RETURN TO
        
        ;Add 100 to the sum
        AND R3, R3, #0 
        AND R4, R4, #0
        ;ADD R4, R2, #10 ;Load R2 as a counter into R4
        ADD R4, R4, #10 ;Load R2 as a counter into R4
hundredsMul ADD R3, R3, R1 
            LD R0, sum ; Load the sum address into R0
            LDR R3, R0, #0 ; Load the sum value into R3
            ADD R3, R3, #10 ; Add 10 to the sum
            STI R3, sum  ; Store value back into address
            ADD R4, R4, #-1 
            BRp hundredsMul
        
checkFourth LD R4, Key4 ;Load Key4 value back into R4
            ADD R4, R4, #0 ;Add 0 to the tens digit
            BRz checkFifth ; If 0, nothing to add
            ADD R4, R4, #-9 ;Add -9 to the hundreds digit
            BRp invalidIn ;If positive, number is greater than 9 (invalid)
            
        ;Add tens multiplication to the sum
        LD R4, Key4 ;Load Key4 value back into R4
        AND R3, R3, #0 
tensMul ADD R3, R3, R1 
            LD R0, sum ; Load the sum address into R0
            LDR R3, R0, #0 ; Load the sum value into R3
            ADD R3, R3, #10 ; Add 10 to the sum
            STI R3, sum  ; Store value back into address
            ADD R4, R4, #-1 
            BRp tensMul    
        
checkFifth  LD R4, Key5 ;Load Key5 value back into R4
            ADD R4, R4, #0 ;Add 0 to the ones digit
            BRz endIn ; If 0, nothing to add
            ADD R4, R4, #-9 ;Add -1 to the hundreds digit
            BRp invalidIn ;If positive, number is greater than 9 (invalid)
            
            LD R4, Key5 ;Load Key4 value back into R4
            AND R3, R3, #0
            LD R0, sum ; Load the sum address into R0
            LDR R3, R0, #0 ; Load the sum value into R3
            ADD R3, R3, R4 ; Add R4 to the sum
            STI R3, sum  ; Store value back into address
            
            ;Finally check if full number is < 128
            LD R0, sum ; Load the sum address into R0
            LDR R3, R0, #0 ; Load the sum value into R3
            LD R4, NCheck ;Load -127 to check if full number valid
            ADD R3, R3, R4 ; Add -127 to the sum
            BRp invalidIn ;If positive, number is greater than 127 (invalid)
            
            LD  R0, Key2  ; save second of key
            
endIn       RET ;return to caller

invalidIn   LEA R0, invalid    ; Load error message
        PUTS    ; print message
        BRnzp KEYIN
        
encryptCA .FILL   goENCRYPTCA
; subroutine encrypt message using Caeser's cipher
decryptCA .FILL   goDecryptCA
; subroutine dencrypt message using Caeser's cipher
encryptVI .FILL   goENCRYPTVI
; subroutine encrypt message using viginere
encryptBIT .FILL   goENCRYPTBIT
; subroutine encrypt message using bitshift
decryptBIT .FILL   goDECRYPTBIT
; subroutine encrypt message using bitshift

sum   .FILL   x3500
MESSAGE .FILL x4000
DECRYPTM    .FILL x5000
startmsg    .STRINGZ "\nSTARTING PRIVACY MODULE\n"
query       .STRINGZ "\nENTER E OR D OR X\n"
keymsg      .STRINGZ "\nENTER KEY\n"
promptmsg   .STRINGZ "\nENTER MESSAGE\n"
invalid     .STRINGZ "\nINVALID INPUT\n"
negTen  .FILL #-10
negNum    .FILL #-48
negCapE    .FILL #-69
negCapD    .FILL #-68
negCapX    .FILL #-88
NCheck  .FILL #-127
NegN   .FILL #-128
N      .FILL #128
ctr    .BLKW   1
Key1   .BLKW   1
Key2   .BLKW   1
Key3   .BLKW   1
Key4   .BLKW   1
Key5   .BLKW   1

goIN   .FILL   TAKEIN ; initialize variable goIN to the address/label of subroutine TAKEIN
; subroutine 10-character input
TAKEIN  LEA R0, promptmsg    ; load enter message
        PUTS    ; print  message
        LD R3, negTen ;Store -10 in R3
        LD R2, MESSAGE ; load message address into R2
INLOOP  GETC ;take character in
        STR R0, R2, #0  ; Store at address
        ADD R2, R2, #1 ; Increment message address pointer
        ADD R3, R3, #1 ; Increment loop check to loop 10 times
        BRn INLOOP
        RET ;return to caller after 10 input characters

goENCRYPTVI AND R3, R3, #0
        ADD R3, R3, #10
        ST R3, ctr ;LD R3, negTen ;Store -10 in R3
        ;LD R4, MESSAGE ; load message address into R4
        
VILOOP  LD R1, Key2
        LD R3, negNum
        ADD R3, R1, R3
        BRz endVI
        LDR R0, R4, #0
        ; Find XOR of R0 and R1
        AND R2 R2 #0 ; zero-out R2
        AND R3 R3 #0 ; zero-out R3
        NOT R2 R1 ;NOT R1, stored IN R2
        NOT R3 R0 ;NOT R0, stored in R3
        AND R3 R3 R2 ;AND of !R1 and !R0
        AND R0 R0 R1 ;AND of R1 and R0
        NOT R3 R3 ;invert R3
        NOT R0 R0 ;invert R0
        AND R2 R3 R0 ;AND of R3 and R0, the XOR result of R1 and R2
        ;;
        STR R2, R4, #0  ; Store at address
        ADD R4, R4, #1 ; Increment message address pointer
        LD R3, ctr
        ADD R3, R3, #-1 ; Increment loop check to loop 10 times
        ST R3, ctr
        BRp VILOOP
        
endVI   RET  ;return to caller
        
goENCRYPTCA AND R3, R3, #0
            ADD R3, R3, #10 ;Counter of where data is
            ST R3, ctr ;Store counter value in ctr
            LD R4, MESSAGE ; load message address into R4
CALOOP  LDR R0, R4, #0 ;Load next message character into R0
            LDI R3, sum
            ADD R3, R3, #0
            BRz endCA
            LDR R2, R4, #0
            ADD R2, R2, R3 
            ;;;;;;;;; Perform Mod on data
            LD R1, NegN ;Store -128 in R3
            ModLoop ADD R2, R2, R1 ; Subtract R1 from dividend
                BRzp ModLoop    ; repeat loop if R2 > 0
            LD R1, N
            ADD R2, R2, R1 ; Repeat until max divisions reached
            ;;;;;;;;;;
            STR R2, R4, #0  ; Store at address
            ADD R4, R4, #1 ; Increment message address pointer
            LD R3, ctr
            ADD R3, R3, #-1 ; Increment loop check to loop 10 times
            ST R3, ctr
            BRp CALOOP
endCA       RET  ;return to caller

goDecryptCA AND R3, R3, #0
            ADD R3, R3, #10 ;Counter of where data is
            ST R3, ctr ;Store counter value in ctr
            
DCALOOP     LD R4, DECRYPTM ; load message address into R4
            LDR R0, R4, #0 ;Load next message character into R0
            LDI R3, sum
            NOT R3, R3
            ADD R3, R3, #1
            LDR R2, R4, #0
            ADD R2, R2, R3 
            ;;;;;;;;; Perform Mod on data
            LD R1, N ;Store 128 in R3
            ADD R2, R2, R1
            LD R1, NegN ;Store -128 in R3
            DModLoop ADD R2, R2, R1 ; Subtract R1 from dividend
                BRzp DModLoop    ; repeat loop if R2 > 0
            LD R1, N
            ADD R2, R2, R1 ; Repeat until max divisions reached
            ;;;;;;;;;;
            ADD R4, R4, #1
            LD R4, DECRYPTM ; load message address into R4
            STR R2, R4, #0  ; Store at address
            ADD R4, R4, #1
            ST R4, DECRYPTM
            ADD R4, R4, #1 ; Increment message address pointer
            LD R3, ctr
            ADD R3, R3, #-1 ; Increment loop check to loop 10 times
            ST R3, ctr
            BRp DCALOOP
            
            ;Reset the values of DECRYPTM AND MESSAGE
            LD R3, negTen
            LD R4, DECRYPTM ; load message address into R4
            ADD R4, R3, R4
            ST R4, DECRYPTM
            RET

goENCRYPTBIT AND R6, R6, #0
        ADD R6, R6, #10 ;Counter of where data is
        LD R3, Key1 ; load first bit of key into R3
	    ADD R3, R3, #0 ;Check value
	    BRz endEBIT ;If 0 no bit shift
        LD R4, MESSAGE ; load message address into R4
EBITLOOP    LD R3, Key1 ; load first bit of key into R3
            LDR R0, R4, #0 ;load number into R0
            ; Find bitshift of the number
BitLeft     ADD R0, R0, R0  ;Double the value to shift left by 1
            ADD R3, R3, #-1 ;Decrement counter
            BRp BitLeft ;Repeat until x bitshifts completed		
        STR R0, R4, #0  ; Store at address
        ADD R4, R4, #1 ; Increment message address pointer
        ADD R6, R6, #-1 ; Increment loop check to loop 10 times
        BRp EBITLOOP
        
endEBIT   RET  ;return to caller

goDECRYPTBIT AND R6, R6, #0
        ADD R6, R6, #10 ;Counter of where data is
        LD R3, Key1 ; load first bit of key into R3
        LD R4, MESSAGE ; load message address into R4
	    LD R2, DECRYPTM ; load decrypt message address into R1
DBITLOOP    LD R3, Key1 ; load first bit of key into R3
            LDR R0, R4, #0 ;load number into R0
	    ; Find bitshift of the number
	        ADD R3, R3, #0 ;Check value
	        BRz storeDBIT ;If 0 no bit shift
BitRight    AND R1, R1, #0
            DivTwo ADD R0, R0, #-2
                   ADD R1, R1, #1
                   ADD R0, R0, #0
                   BRp DivTwo
            ADD R0, R1, #0
            ADD R3, R3, #-1
            BRp BitRight	
storeDBIT   STR R0, R2, #0  ; Store at address
        ADD R4, R4, #1 ; Increment message address pointer
	    ADD R2, R2, #1 ; Increment message address pointer
        ADD R6, R6, #-1 ; Increment loop check to loop 10 times
        BRp DBITLOOP
endDBIT	RET
.END

.ORIG x3500
   .FILL #0
.END

.ORIG x4000
   .FILL #0
.END

.ORIG x5000
   .FILL #0
.END