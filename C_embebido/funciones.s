    .include "p30F3013.inc"
    .global _funcion1
    .global _funcion2
    .global _funcion3
    .global _funcion4
    .global _funcion5
    .global _funcion6
    .global _longitud	    ;variable compartida entre C y Ensamblador
    
  ;@brief: ESTA FUNCION REALIZA UN RETARDO 
  ;@param: NINGUNO
  ;@return: NINGUNO
  ;
  _funcion1:  
    PUSH W0
    MOV #6,W0
  CICLO_F1:
    DEC W0,W0
    BRA NZ,CICLO_F1
    POP W0
    RETURN
    
  ;@brief: ESTA FUNCION REALIZA UNA SUMA DE DOS NUMEROS
  ;@param: NINGUNO
  ;@return: W0, RESULTADO DE LA SUMA
  ;
    
  _funcion2:  
    MOV #12,W0
    MOV #23,W1
    
    ADD W0,W1,W0

    RETURN
    
  ;@brief: ESTA FUNCION REALIZA UNA SUMA DE DOS NUMEROS 
  ;@param1: W0, TIENE EL n1 A SUMAR
  ;@param2: W1, TIENE EL n2  A SUMAR 
  ;@return: W0, RESULTADO DE LA SUMA 
  ;
  _funcion3:  
    ADD W0,W1,W0

    RETURN

  ;@brief: ESTA FUNCION REALIZA UNA SUMA DE DOS NUMEROS 
  ;@param1: W0, TIENE EL n1 A SUMAR
  ;@param2: W1, TIENE EL n2  A SUMAR 
  ;@param3: W2, TIENE LA DIRECCION DEL RESULTADO
  ;@return: NINGUNO
  ;
  _funcion4:  
    ADD W0,W1,W0	    ;W0=W0+W1
    MOV W0,[W2]		    ;*W2=W0

    RETURN
    
  ;@brief: ESTA FUNCION REGRESA LA LONGITUD DE UNA CADENA
  ;@param1: W0, TIENE LA DIRECCION DEL PRIMER ELEMENTO DE LA CADENA
  ;@return: W0, LONGITUD DE LA CADENA
  ;
  _funcion5:  
    PUSH W1
    PUSH W2
    CLR W2		    ;CONTADOR
 CONTEO:
    MOV.B [W0++],W1	    ;W1=*CAD
    CP0.B W1
    BRA Z,FIN
    INC W2,W2		    ;CONTADOR++
    GOTO CONTEO
    
  FIN:
    MOV W2,W0		    ;W0=CONTADOR
    
    POP W2
    POP W1
    RETURN 
    
    ;@brief: ESTA FUNCION REGRESA LA LONGITUD DE UNA CADENA
  ;@param1: W0, TIENE LA DIRECCION DEL PRIMER ELEMENTO DE LA CADENA
  ;@return: NINGUNO
  ;
  _funcion6:  
    PUSH W1
    
    CLR _longitud		    ;CONTADOR
 CONTEO1:
    MOV.B [W0++],W1		    ;W1=*CAD
    CP0.B W1
    BRA Z,FIN1
    INC _longitud		    ;CONTADOR++
    GOTO CONTEO1
    
  FIN1:
    
    
    POP W1
    RETURN 
    
    

