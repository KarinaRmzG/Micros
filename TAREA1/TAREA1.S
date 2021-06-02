;/**@brief RAMIREZ GALINDO KARINA
; * TAREA 1: Hacer un programa en el ensamblador del DSPIC para implementar una 
; * calculadora con las operaciones de suma, resta, multiplicación y división.
; * Las operaciones se deben seleccionar usando las terminales RD8 y RD9 
; * del puerto D de acuerdo a la tabla:
; *   ------------------------------------------------------------
; *  |  RD9  |  RD8 |	  OPERACIÓN	|        SIGNIFICADO	  |    
; *  |-------|------|-------------------|-------------------------|
; *  |   0   |   0  | RESTA             | PORTB = PORTF(5:2) - K  |
; *  |   0   |   1  | SUMA	        | PORTB = PORTF(5:2) + K  |
; *  |   1   |   0  | DIVISIÓN          | PORTB = PORTF(5:2) * K  |
; *  |   1   |   1  | MULTIPLICACIÓN    | PORTB = PORTF(5:2) / K  |
; *   ------------------------------------------------------------
; * Utilizar K = 5 y las instruccciones de BTSS ó BTSC para preguntar por RD8 y RD9.
     
;/**@brief ESTE PROGRAMA MUESTRA LOS BLOQUES QUE FORMAN UN PROGRAMA 
; * EN ENSAMBLADOR, LOS BLOQUES SON:
; * BLOQUE 1. OPCIONES DE CONFIGURACION DEL DSC: OSCILADOR, WATCHDOG,
; *	BROWN OUT RESET, POWER ON RESET Y CODIGO DE PROTECCION
; * BLOQUE 2. EQUIVALENCIAS Y DECLARACIONES GLOBALES
; * BLOQUE 3. ESPACIOS DE MEMORIA: PROGRAMA, DATOS X, DATOS Y, DATOS NEAR
; * BLOQUE 4. CÓDIGO DE APLICACIÓN
; * @device: DSPIC30F4013
; * @oscilLator: FRC, 7.3728MHz
; */
        .equ __30F3013, 1
        .include "p30F3013.inc"
;******************************************************************************
; BITS DE CONFIGURACIÓN
;******************************************************************************
;..............................................................................
;SE DESACTIVA EL CLOCK SWITCHING Y EL FAIL-SAFE CLOCK MONITOR (FSCM) Y SE 
;ACTIVA EL OSCILADOR INTERNO (FAST RC) PARA TRABAJAR
;FSCM: PERMITE AL DISPOSITIVO CONTINUAR OPERANDO AUN CUANDO OCURRA UNA FALLA 
;EN EL OSCILADOR. CUANDO OCURRE UNA FALLA EN EL OSCILADOR SE GENERA UNA TRAMPA
;Y SE CAMBIA EL RELOJ AL OSCILADOR FRC  
;..............................................................................
        config __FOSC, CSW_FSCM_OFF & FRC   
;..............................................................................
;SE DESACTIVA EL WATCHDOG
;..............................................................................
        config __FWDT, WDT_OFF 
;..............................................................................
;SE ACTIVA EL POWER ON RESET (POR), BROWN OUT RESET (BOR), POWER UP TIMER (PWRT)
;Y EL MASTER CLEAR (MCLR)
;POR: AL MOMENTO DE ALIMENTAR EL DSPIC OCURRE UN RESET CUANDO EL VOLTAJE DE 
;ALIMENTACIÓN ALCANZA UN VOLTAJE DE UMBRAL (VPOR), EL CUAL ES 1.85V
;BOR: ESTE MODULO GENERA UN RESET CUANDO EL VOLTAJE DE ALIMENTACIÓN DECAE
;POR DEBAJO DE UN CIERTO UMBRAL ESTABLECIDO (2.7V) 
;PWRT: MANTIENE AL DSPIC EN RESET POR UN CIERTO TIEMPO ESTABLECIDO, ESTO AYUDA
;A ASEGURAR QUE EL VOLTAJE DE ALIMENTACIÓN SE HA ESTABILIZADO (16ms) 
;..............................................................................
        config __FBORPOR, PBOR_ON & BORV27 & PWRT_16 & MCLR_EN
;..............................................................................
;SE DESACTIVA EL CÓDIGO DE PROTECCIÓN
;..............................................................................
   	config __FGS, CODE_PROT_OFF & GWRP_OFF      

;******************************************************************************
; SECCIÓN DE DECLARACIÓN DE CONSTANTES CON LA DIRECTIVA .EQU (= DEFINE EN C)
;******************************************************************************
        .equ MUESTRAS, 64         ;NÚMERO DE MUESTRAS

;******************************************************************************
; DECLARACIONES GLOBALES
;******************************************************************************
;..............................................................................
;PROPORCIONA ALCANCE GLOBAL A LA FUNCIÓN _wreg_init, ESTO PERMITE LLAMAR A LA 
;FUNCIÓN DESDE UN OTRO PROGRAMA EN ENSAMBLADOR O EN C COLOCANDO LA DECLARACIÓN
;"EXTERN"
;..............................................................................
        .global _wreg_init     
;..............................................................................
;ETIQUETA DE LA PRIMER LINEA DE CÓDIGO
;..............................................................................
        .global __reset          
;..............................................................................
;DECLARACIÓN DE LA ISR DEL TIMER 1 COMO GLOBAL
;..............................................................................
        .global __T1Interrupt    

;******************************************************************************
;CONSTANTES ALMACENADAS EN EL ESPACIO DE LA MEMORIA DE PROGRAMA
;******************************************************************************
        .section .myconstbuffer, code
;..............................................................................
;ALINEA LA SIGUIENTE PALABRA ALMACENADA EN LA MEMORIA 
;DE PROGRAMA A UNA DIRECCION MULTIPLO DE 2
;..............................................................................
        .palign 2                

ps_coeff:
        .hword   0x0002, 0x0003, 0x0005, 0x000A

;******************************************************************************
;VARIABLES NO INICIALIZADAS EN EL ESPACIO X DE LA MEMORIA DE DATOS
;******************************************************************************
         .section .xbss, bss, xmemory

x_input: .space 2*MUESTRAS        ;RESERVANDO ESPACIO (EN BYTES) A LA VARIABLE

;******************************************************************************
;VARIABLES NO INICIALIZADAS EN EL ESPACIO Y DE LA MEMORIA DE DATOS
;******************************************************************************

          .section .ybss, bss, ymemory

y_input:  .space 2*MUESTRAS       ;RESERVANDO ESPACIO (EN BYTES) A LA VARIABLE
;******************************************************************************
;VARIABLES NO INICIALIZADAS LA MEMORIA DE DATOS CERCANA (NEAR), LOCALIZADA
;EN LOS PRIMEROS 8KB DE RAM
;******************************************************************************
          .section .nbss, bss, near

var1:     .space 2               ;LA VARIABLE VAR1 RESERVA 1 WORD DE ESPACIO

;******************************************************************************
;SECCION DE CODIGO EN LA MEMORIA DE PROGRAMA
;******************************************************************************
.text					;INICIO DE LA SECCION DE CODIGO

__reset:
        MOV	#__SP_init, 	W15	;INICIALIZA EL STACK POINTER

        MOV 	#__SPLIM_init, 	W0     	;INICIALIZA EL REGISTRO STACK POINTER LIMIT 
        MOV 	W0, 		SPLIM

        NOP                       	;UN NOP DESPUES DE LA INICIALIZACION DE SPLIM

        CALL 	_WREG_INIT          	;SE LLAMA A LA RUTINA DE INICIALIZACION DE REGISTROS
                                  	;OPCIONALMENTE USAR RCALL EN LUGAR DE CALL
        CALL    INI_PERIFERICOS
	NOP
CICLO:
	NOP
	MOV PORTF,W0	    ;W0=PORTF
	NOP
	AND #0X03C,W0	    ;W0=W0 & 0X003C	;MOV #0X003C,W1
						;AND W0,W1,W0
	LSR W0,#2,W0	    ;W0=W0>>2
	
	BTSS PORTD,#RD9	    ;Si RD9=0 ejecuta SUM_RES, Si RD9=1 ejecuta DIV_MUL
	GOTO SUM_RES
	GOTO DIV_MUL
	
SUM_RES:
	BTSS PORTD,#RD8	    ;Si RD8=0 ejecuta RESTA, Si RD8=1 ejecuta SUMA
	GOTO RESTA
	GOTO SUMA
DIV_MUL:
	BTSS PORTD,#RD8	    ;Si RD8=0 ejecuta MULTIPLICACION, Si RD8=1 ejecuta DIVISION
	GOTO MULTIPLICACION
	GOTO DIVISION

SUMA:
	ADD W0,#5,W0
	NOP
	GOTO FIN

RESTA:
	SUB W0, #5,W0
	NOP
	GOTO FIN

MULTIPLICACION:
	MUL.UU	W0,#5,W0
	NOP
	GOTO FIN

DIVISION:
	MOV #5,W2
	NOP
	DISI #20
	CLR W1
	REPEAT #17
	DIV.U W0,W2
	NOP
	GOTO FIN

FIN:
	MOV W0,PORTB
	NOP
	GOTO CICLO
   

;/**@brief ESTA RUTINA INICIALIZA LOS PERIFERICOS DEL DSC
; */
INI_PERIFERICOS:
	CLR     PORTF	         ;PORTF=0x0000
	NOP	    
	CLR     LATF	         ;LATF=0x0000 
	NOP
	SETM    TRISF	         ;TRISF=0xFFFF
        NOP

        CLR     PORTD	         ;PORTD=0x0000
	NOP	    
	CLR     LATD	         ;LATD=0x0000 
	NOP
	BSET    TRISD,#TRISD8    ;TRISF, TRISD8 = 1
	NOP
	BSET    TRISD,#TRISD9    ;TRISF, TRISD9 = 1
	NOP

	CLR     PORTB	         ;PORTB=0x0000
	NOP
	CLR     LATB	         ;LATB=0x0000
	NOP
	CLR     TRISB	         ;TRISB=0x0000
	NOP
	SETM	ADPCFG		
	RETURN

;/**@brief ESTA RUTINA INICIALIZA LOS REGISTROS Wn A 0X0000
; */
_WREG_INIT:
        CLR 	W0
        MOV 	W0, 				W14
        REPEAT 	#12
        MOV 	W0, 				[++W14]
        CLR 	W14
        RETURN

;/**@brief ISR (INTERRUPT SERVICE ROUTINE) DEL TIMER 1
; * SE USA PUSH.S PARA GUARDAR LOS REGISTROS W0, W1, W2, W3, 
; * C, Z, N Y DC EN LOS REGISTROS SOMBRA
; */
__T1Interrupt:
        PUSH.S 


        BCLR IFS0, #T1IF           ;SE LIMPIA LA BANDERA DE INTERRUPCION DEL TIMER 1

        POP.S

        RETFIE                     ;REGRESO DE LA ISR


.END                               ;TERMINACION DEL CODIGO DE PROGRAMA EN ESTE ARCHIVO






