;------------------------------------------------------------------------------------------------------
; Design and Implementation of an AHB VGA Peripheral
; 1) Display text string: "TEST" on VGA. 
; 2) Change the color of the four corners of the image region.
;------------------------------------------------------------------------------------------------------

; Vector Table Mapped to Address 0 at Reset

						PRESERVE8
                		THUMB

        				AREA	RESET, DATA, READONLY	  			; First 32 WORDS is VECTOR TABLE
        				EXPORT 	__Vectors
					
__Vectors		    	DCD		0x000001FC							; 16K Internal Memory
        				DCD		Reset_Handler
        				DCD		0  			
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD 	0
        				DCD		0
        				DCD		0
        				DCD 	0
        				DCD		0
        				
        				; External Interrupts
						        				
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
              
                AREA |.text|, CODE, READONLY
;Reset Handler
Reset_Handler   PROC
                GLOBAL Reset_Handler
                ENTRY
				
				B		MAIN
				
Delay           LDR     R6, =0x00010000
DelayLoop       SUBS    R6, R6, #1
                BNE     DelayLoop
                BX      LR
				
COLOR_UPDATE	SUBS 	R2, R2, #1
				BNE		COLOR_RTN
				LDR		R2, =0x000000FF
COLOR_RTN		BX		LR				

MOVE_BL			ADDS	R1, R1, R4
				CMP		R1, R3
				BLS		MOVE_RTN
				SUBS	R1, R1, R5
				
MOVE_RTN		BL		COLOR_UPDATE
				BL		DISPLAY
				BL		Delay
				B 		MOVE_BL

DISPLAY			STR		R2, [R1]
				BX		LR

MAIN			LDR		R1, =0x50000000
				LDR		R2, =0x20436F53
				STR		R2, [R1] 
    	     	LDR		R1, =0x50000008
				LDR		R2, =0x000000FF
				LDR		R3, =0x0000018C
				LDR		R4, =0x0000EF8C
				B		MOVE_BL
				
                B 		MAIN      
				ENDP


				ALIGN 		4					 ; Align to a word boundary

		END                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
   