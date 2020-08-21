;;;;;;; P5 for QwikFlash board ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Use this template for Experiment 5
;
;;;;;;; Assembler directives ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

         list  P=PIC18F4520, F=INHX32, C=160, N=0, ST=OFF, MM=OFF, R=DEC, X=ON
        #include <P18F4520.inc>
        __CONFIG  _CONFIG1H, _OSC_HS_1H  ;HS oscillator
        __CONFIG  _CONFIG2L, _PWRT_ON_2L & _BOREN_ON_2L & _BORV_2_2L  ;Reset
        __CONFIG  _CONFIG2H, _WDT_OFF_2H  ;Watchdog timer disabled
        __CONFIG  _CONFIG3H, _CCP2MX_PORTC_3H  ;CCP2 to RC1 (rather than to RB3)
        __CONFIG  _CONFIG4L, _LVP_OFF_4L & _XINST_OFF_4L  ;RB5 enabled for I/O
        errorlevel -314, -315          ;Ignore lfsr messages


;;;;;;; Variables ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        cblock  0x000           ;Beginning of Access RAM
		; --- BEGIN variables for TABLAT POINTER
		value
		counter
		; --- END variables for TABLAT POINTER

		; My variables
		v0 ;value for x[n]
		v1 ;value for x[n-1]
		v2 ;value for x[n-2]
		v3 ;value for x[n-2]
		v4 ;value for x[n-4]
		v5 ;value for x[n-5]
		f
		output

        endc

;;;;;;; Macro definitions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MOVLF   macro  literal,dest
        movlw  literal
        movwf  dest
        endm


;;;;;;; Vectors ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        org  0x0000             ;Reset vector
        nop
        goto  Mainline

        org  0x0008             ;High priority interrupt vector
        goto  $  ;Trap

        org  0x0018             ;Low priority interrupt vector
        goto  $                  ;Trap

;;;;;;; Mainline program ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Mainline
        rcall  Initial          ;Initialize everything
Loop
	
		MOVLF  10,counter
		MOVLF upper SimpleTable,TBLPTRU 
		MOVLF high  SimpleTable,TBLPTRH 
		MOVLF low   SimpleTable,TBLPTRL
	label_A
		TBLRD*+
		movf TABLAT, W
		movwf value ; value = x[n]

		;;;;;;; NOTE FOR STUDENTS:
		; 
		; Write the code for your moving average filter in 
		; the empty spaces below. Please create subroutines 
		; to make code your code transparent and easier to debug
		;
		; DO NOT MODIFY ANY OTHER PART OF THE THIS LOOP IN THE MAINLINE
		;
		; --------------------------------------------------------------
		; BEGIN WRTING CODE HERE 
		
			; ---------------------------------
			; (1) WRITE CODE FOR MEMORY BUFFER HERE
			;       you may write the full code 
			;		here or call a subroutine
		rcall Membuff ; writes data into buffer for [n to n-5]
		
			; ---------------------------------
			; (2) WRITE CODE FOR ADDER AND DIVIDER HERE 
			;       you may write the full code 
			;		here or call a subroutine
		rcall Mathboys ; adds current x[n] with x[n-k] (k depending on which output) and divides total sum by 2

  -------------------------------------------------------
		
		decf  counter,F     ; decrement counters value and store to F
	    	bz  label_B	    ; Once hit zero on counter we go to branch if not skip line
		bra label_A	    
	
	label_B

       		 bra	Loop



;;;;;;; Initial subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This subroutine performs all initializations of variables and registers.

Initial
        MOVLF  B'10001110',ADCON1  ;Enable PORTA & PORTE digital I/O pins
        MOVLF  B'11100001',TRISA  ;Set I/O for PORTA 0 = output, 1 = input
        MOVLF  B'11011100',TRISB  ;Set I/O for PORTB
        MOVLF  B'11010000',TRISC  ;Set I/0 for PORTC
        MOVLF  B'00001111',TRISD  ;Set I/O for PORTD
        MOVLF  B'00000000',TRISE  ;Set I/O for PORTE
        MOVLF  B'10001000',T0CON  ;Set up Timer0 for a looptime of 10 ms;  bit7=1 enables timer; bit3=1 bypass prescaler
        MOVLF  B'00010000',PORTA  ;Turn off all four LEDs driven from PORTA ; See pin diagrams of Page 5 in DataSheet
        MOVLF  B'00110010',v0  ;n-1 =50
		MOVLF  B'01100100',v1  ;n-2 =100
		MOVLF  B'10010110',v2  ;n-3 =150
		MOVLF  B'11001000',v3  ;n-4 =200
		MOVLF  B'11111010',v4  ;n-5 =250
	

		return


;;;;;;; My Memory Buffer Subroutine ;;;;;;;;;;;;;;;;;;;;;;;;
Membuff
	movff v4, v5
	movff v3, v4
	movff v2, v3
	movff v1, v2
	movff v0, v1
	movff value, v0

	return

Mathboys
	addwf v5, W
	movwf f
	rrcf f, W
	movwf output

	return
;;;;;;; TIME SERIES DATA
;
; 	The following bytes are stored in program memory.
;   Created by AC 
;	DO NOT MODIFY
;
SimpleTable 
db 0,50,100,150,200,250,200,150,100,50
; --------------------------------------------------------------

        end


