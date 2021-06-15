    .include "p30F3013.inc"
    .EQU    RS_LCD,	RF4
    .EQU    RW_LCD,	RF5
    .EQU    E_LCD,	RD8

    .GLOBAL _COMANDO_LCD
    .GLOBAL _DATO_LCD
    .GLOBAL _BF_LCD
    .GLOBAL _INI_LCD_8BITS
    .GLOBAL _printLCD
; @BRIEF: ESTA RUTINA IMPRIME UNA CADENA EN EL LCD
; @PARAM: W0, CADENA A IMPRIMIR
; @RETURN: NINGUNO
_printLCD:
    PUSH W0
    PUSH W1
    MOV W0,W1
    CLR W0 ;PRUEBA
IMPRIMIR:
    MOV.B [W1++],W0		    ;W0=[W1]
    CP0.B W0
    BRA Z, FIN_printLCD
    ;CONTINUARA....
    ;COLOCAR EL CODIGO DE ENVIO AL LCD
    CALL _BF_LCD
    CALL _DATO_LCD 
    
    GOTO IMPRIMIR
FIN_printLCD:
    POP W1
    POP W0
    RETURN
; @BRIEF: ESTA RUTINA MANDA COMANDOS AL LCD
; @PARAM: W0, COMANDO A ENVIAR
; @RETURN: NINGUNO   
_COMANDO_LCD:
    BCLR    PORTF,	#RS_LCD	    ;RS = 0 -----> (RF4=0)
    NOP
    BCLR    PORTF,	#RW_LCD	    ;RW = 0 -----> (RF5=0)
    NOP
    BSET    PORTD,	#E_LCD	    ;E = 1 -----> (RD8=1)
    NOP
    MOV.B   WREG,	PORTB	    ;PORTB(7:0) = W0(7:0)
    NOP
    BCLR    PORTD,	#E_LCD	    ;E = 0 -----> (RD8=0)
    NOP
    
    RETURN
; @BRIEF: ESTA RUTINA MANDA DATOS AL LCD
; @PARAM: W0, DATO A ENVIAR
; @RETURN: NINGUNO
_DATO_LCD:
    BSET    PORTF,	#RS_LCD	    ;RS = 1 -----> (RF4=1)
    NOP
    BCLR    PORTF,	#RW_LCD	    ;RW = 0 -----> (RF5=0)
    NOP
    BSET    PORTD,	#E_LCD	    ;E = 1 -----> (RD8=1)
    NOP
    MOV.B   WREG,	PORTB	    ;PORTB(7:0) = W0(7:0)
    NOP
    BCLR    PORTD,	#E_LCD	    ;E = 0 -----> (RD8=0)
    NOP
    
    RETURN
; @BRIEF: ESTA RUTINA VERIFICA LA BANDERA BUSY FLAG DEL LCD
;    
_BF_LCD:
    PUSH TRISB			    ;STACK(SP++) = TRISB
    PUSH W0
    MOV	    #0x00FF,	W0	    ;W0=0X00F
    IOR	    TRISB
    NOP
    BCLR    PORTF,	#RS_LCD	    ;RS = 0 ----> (RF4=0)
    NOP
    BSET    PORTF,	#RW_LCD	    ;RW = 1 ----> (RF5=1)
    NOP
    BSET    PORTD,	#E_LCD	    ;E = 1 -----> (RD8=1)
    NOP
ESPERA_LCD:
    BTSC    PORTB,	#RB7	    ;POLLING
    GOTO    ESPERA_LCD
    
    ;CONTINUARA...
    BCLR PORTD,#E_LCD		    ;E=0 -------> (RD8=0)
    NOP
    BCLR PORTF,#RW_LCD		    ;RW=0 ------> (RF5=0)
    NOP
    POP W0
    POP	    TRISB
    RETURN
; @BRIEF: ESTA RUTINA INICIALIZA EL LCD EN MODO DE 8 BITS
;    
_INI_LCD_8BITS:
    
    DO #2, INI_CICLO    
	CALL    _RETARDO_100ms
	MOV	    #0X30,	W0
	CALL    _COMANDO_LCD
INI_CICLO:	
    NOP
    PUSH W1
    NOP
    
    CLR W1
    
    DO #4, CICLO2
	CALL _BF_LCD
	CALL VALORES
	ADD #1,W1
	CALL _COMANDO_LCD
    CICLO2:
    NOP
    
    POP W1
    NOP
    
    RETURN
    
VALORES:
    BRA W1			;PC=PC+W1=BRINCO RELATIVO
    RETLW #0X38,W0	
    RETLW #0X08,W0	
    RETLW #0X01,W0	
    RETLW #0X06,W0	
    RETLW #0X0C,W0
    
    
    