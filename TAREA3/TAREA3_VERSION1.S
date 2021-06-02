;/**@brief ALUMNA: RAMIREZ GALINDO KARINA    BOLETA: 2015170921
; * TAREA 3: Hacer un programa en el ensamblador del DSPIC para implementar un convertidor de código que
; * permita mostrar los digitos del número de boleta del estudiante. Los digitos se deben mostrar en un
; * display de cátodo común usando las terminales RB0,..., RB6 del puerto B. Cada digito se
; * selecciona mediante las terminales RF2, RF3, RF4 y RF5 del puerto F de acuerdo a la tabla
; * VERSION 1 ---> CON INSTRUCCIONES DE COMPARACION 
; *   ---------------------------------------------------------------------
; *  | RF5 | RF4 | RF3 | RF2 | A | B | C | D | E | F | G | CODIGO | DIGITO |  
; *  |-----|-----|-----|-----|---|---|---|---|---|---|---|--------|--------|
; *  |  0  |  0  |  0  |  0  | 1 | 1 | 0 | 1 | 1 | 0 | 1 |  0X6D  |    2   |
; *  |  0  |  0  |  0  |  1  | 1 | 1 | 1 | 1 | 1 | 1 | 0 |  0x7E  |    0   |
; *  |  0  |  0	 |  1  |  0  | 0 | 1 | 1 | 0 | 0 | 0 | 0 |  0x30  |    1   |
; *  |  0  |  0  |  1  |  1  | 1 | 0 | 1 | 1 | 0 | 1 | 1 |  0x5B  |    5   |
; *  |  0  |  1  |  0  |  0  | 0 | 1 | 1 | 0 | 0 | 0 | 0 |  0x30  |    1   |
; *  |  0  |  1  |  0  |  1  | 1 | 1 | 1 | 0 | 0 | 0 | 0 |  0x70  |    7   |
; *  |  0  |  1  |  1  |  0  | 1 | 1 | 1 | 1 | 1 | 1 | 0 |  0x7E  |    0   |
; *  |  0  |  1  |  1  |  1  | 1 | 1 | 1 | 1 | 0 | 1 | 1 |  0x7B  |    9   |
; *  |  1  |  0  |  0  |  0  | 1 | 1 | 0 | 1 | 1 | 0 | 1 |  0x6D  |    2   |
; *  |  1  |  0  |  0  |  1  | 0 | 1 | 1 | 0 | 0 | 0 | 0 |  0x30  |    1   |
; *   ---------------------------------------------------------------------
     
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
	CLR W0
CICLO:
        MOV PORTF,W0	    ;W0=PORTF
	NOP
	AND #0X03C,W0	    ;W0= W0 & 0x03C
	LSR W0,#2,W0	    ;W0= W0>>2 
	
	CP W0,#0	    ;OPERACION: W0-0
	BRA Z,NUMERO_2
	CP W0,#1
	BRA Z,NUMERO_0
	CP W0,#2
	BRA Z,NUMERO_1
	CP W0,#3
	BRA Z,NUMERO_5
	CP W0,#4
	BRA Z,NUMERO_1
	CP W0,#5
	BRA Z,NUMERO_7
	CP W0,#6
	BRA Z,NUMERO_0
	CP W0,#7
	BRA Z,NUMERO_9
	CP W0,#8
	BRA Z,NUMERO_2
	CP W0,#9
	BRA Z,NUMERO_1
	
NUMERO_0:
	MOV #0X7E,W0	    ;W0=0X7E
	MOV W0,PORTB	    ;PORTB=W0
	NOP
	GOTO CICLO
NUMERO_1:
	MOV #0X30,W0	    ;W0=0X30
	MOV W0,PORTB	    ;PORTB=W0
	NOP
	GOTO CICLO
NUMERO_2:
	MOV #0X6D,W0	    ;W0=0X6D
	MOV W0,PORTB	    ;PORTB=W0
	NOP
	GOTO CICLO
NUMERO_5:
	MOV #0X5B,W0	    ;W0=0X5B
	MOV W0,PORTB	    ;PORTB=W0
	NOP
	GOTO CICLO
NUMERO_7:
	MOV #0X70,W0	    ;W0=0X70
	MOV W0,PORTB	    ;PORTB=W0
	NOP
	GOTO CICLO
NUMERO_9:
	MOV #0X7B,W0	    ;W0=0X7B
	MOV W0,PORTB	    ;PORTB=W0
	NOP
	GOTO CICLO
	
;/**@brief ESTA RUTINA INICIALIZA LOS PERIFERICOS DEL DSC
; */
INI_PERIFERICOS:
	CLR PORTF	    ;PORTF=0x0000
	NOP
	CLR LATF	    ;LATF=0x0000
	NOP
	SETM TRISF	    ;TRISF=0xFFFF
	NOP
	
        CLR PORTB	    ;PORTB=0x0000
	NOP
	CLR LATB	    ;LATB=0x0000
	NOP
	CLR TRISB	    ;TRISB=0x0000
	NOP
	SETM ADPCFG 
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






