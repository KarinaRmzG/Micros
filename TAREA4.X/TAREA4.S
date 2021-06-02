;/**@brief ALUMNA: RAMIREZ GALINDO KARINA    BOLETA: 2015170921
; * TAREA 4: Hacer un programa en el ensamblador del DSPIC para mostrar los digitos del número de boleta del
; * estudiante de manera automática en intervalos de tiempo de 1 segundo. Los digitos se deben
; * mostrar en un display de cátodo común usando las terminales RB0, ..., RB6 del puerto B. Los
; * digitos del número de boleta se deben colocar de acuerdo a la tabla
; *   ---------------------------------------------
; *  | A | B | C | D | E | F | G | CODIGO | DIGITO |  
; *  |---|---|---|---|---|---|---|--------|--------|
; *  | 1 | 1 | 0 | 1 | 1 | 0 | 1 |  0X6D  |    2   |
; *  | 1 | 1 | 1 | 1 | 1 | 1 | 0 |  0x7E  |    0   |
; *  | 0 | 1 | 1 | 0 | 0 | 0 | 0 |  0x30  |    1   |
; *  | 1 | 0 | 1 | 1 | 0 | 1 | 1 |  0x5B  |    5   |
; *  | 0 | 1 | 1 | 0 | 0 | 0 | 0 |  0x30  |    1   |
; *  | 1 | 1 | 1 | 0 | 0 | 0 | 0 |  0x70  |    7   |
; *  | 1 | 1 | 1 | 1 | 1 | 1 | 0 |  0x7E  |    0   |
; *  | 1 | 1 | 1 | 1 | 0 | 1 | 1 |  0x7B  |    9   |
; *  | 1 | 1 | 0 | 1 | 1 | 0 | 1 |  0x6D  |    2   |
; *  | 0 | 1 | 1 | 0 | 0 | 0 | 0 |  0x30  |    1   |
; *   ---------------------------------------------
; * Colocar en la columna de ?Digito? los digitos de su número de boleta y completar las columnas A,
; * B, C, D, E, F, y G. Posteriormente obtener los códigos correspondientes en la columna de ?Código?.
; * Coloque los códigos en un arreglo ubicado en la memoria de programa.
; * Utilice la instrucción de TBLRD y un apuntador para leer cada elemento del arreglo.
; * Además utilice la terminal RD8 del puerto D para seleccionar si los elementos del arreglo deben
; * mostrarse de manera ascendente o descendente 
; *
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
boleta:
	.byte    0x00, 0x6D, 0x7E, 0x30, 0x5B, 0x30, 0x70, 0x7E, 0x7B, 0x6D, 0x30, 0x00

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
CICLO:
        MOV #tblpage(boleta),W0
	MOV W0,TBLPAG			;TBLPAG=msj(23:16)	
	MOV #tbloffset(boleta),W1	;W1=msj(15:0)
	NOP
	ADD #1,W1			;POSICION INCREMENTO
LEER_ARREGLO:
	BTSC PORTD,#RD8			;RD8=1 EJECUTA DESCENDENTE
	GOTO ARREGLO_DESCENDENTE
	BTSS PORTD,#RD8			;RD8=0 EJECUTA ASCENDENTE
	GOTO ARREGLO_ASCENDENTE
ARREGLO_ASCENDENTE:
	TBLRDL.B [W1++],W0		;W0=[W1++]
	CP0.B W0
	BRA Z,CICLO
	MOV W0,PORTB
	NOP
	CALL RETARDO_1S
	GOTO LEER_ARREGLO
LEER_ARREGLO_DECREMENTO:
	ADD #11,W1			;ENVIO A LA ULTIMA POSICION, POSICION DECREMENTO
ARREGLO_DESCENDENTE:
	TBLRDL.B [W1--],W0		;W0=[W1--]
	CP0.B W0
	BRA Z,LEER_ARREGLO_DECREMENTO
	MOV W0,PORTB
	NOP
	CALL RETARDO_1S
	GOTO LEER_ARREGLO
;/**@brief ESTA RUTINA GENERA UN RETARDO DE 1 SEGURO
; *
;* SIEMPRE QUE ESCRIBIMOS UNA FUNCION EN ENSAMBLADOR DEBEMOS GUARDAR AL INICIO
; LOS REGISTROS QUE SUSAMOS DENTRO DE LA FUNCION Y AL FINAL LOS REESTABLECEMOS
;*/
RETARDO_1S:
	PUSH W0
	PUSH W1
	MOV #10,W1
CICLO2_1S:
	CLR W0		    ;W0=0
	;MOV #3,W0
CICLO1_1S:
	DEC W0,W0	    ;W0=0-1=-1=0B11111111 11111111=65536
	BRA NZ,CICLO1_1S
	DEC W1,W1	    
	BRA NZ,CICLO2_1S
	
	POP W1
	POP W0
	RETURN
;/**@brief ESTA RUTINA INICIALIZA LOS PERIFERICOS DEL DSC
; */
INI_PERIFERICOS:

        CLR PORTD	    ;PORTD=0x0000
	NOP	    
	CLR LATD	    ;LATD=0x0000 
	NOP
	BSET TRISD,#TRISD8  ;TRISF, TRISD8 = 1
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






