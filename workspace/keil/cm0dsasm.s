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

;Write "TEST" to the text console

; R0 : SRAM Base addr
; R1 : SEG  Base addr : WRITE
; R2 : SEG  Base addr : PASS
; R3 : SEG  Base addr : FAIL


MAIN			LDR 	R0, =0x51000000
				LDR		R1, =0x52000000
				LDR		R2, =0x52000004
				LDR		R3, =0x52000008
				
				LDR		R4, =0x5200000C
				MOVS	R5, #'G'
				STR		R5, [R1]
				MOVS	R5, #'N'
				STR		R5, [R2]
				MOVS	R5, #'I'
				STR		R5, [R3]
				MOVS	R5, #' '
				STR		R5, [R4]
				
MEM_W			LDR		R4, =0x51000010
				LDR		R5, =0x0
MEM_W_LOOP	    SUBS	R4, R4, #4
				STR		R4, [R4]
				
				ADDS	R5, R5, #1
				STR		R5, [R1]
				
				CMP		R4, R0
				BNE		MEM_W_LOOP
				
MEM_R			LDR		R4, =0x51000010
				LDR		R5, =0x0
				LDR		R6, =0x0
MEM_R_LOOP	    SUBS	R4, R4, #4
				LDR		R7, [R4]
				CMP		R7, R4
				BNE		MEM_R_FAIL		
MEM_R_PASS		ADDS	R5, R5, #1
				STR		R5, [R2]
				B		MEM_R_RST
MEM_R_FAIL		ADDS	R6, R6, #1
				STR		R6, [R3]
				
MEM_R_RST		CMP		R4, R0
				BNE		MEM_R_LOOP
				
				
				LDR		R3, =0x5200000C
				LDR		R1, =0x0000000F
				STR		R1, [R3]

RESULT			LDR		R4, =0x5200000C
				MOVS	R5, #' '
				STR		R5, [R1]
				MOVS	R5, #'N'
				STR		R5, [R2]
				MOVS	R5, #'I'
				STR		R5, [R3]
				MOVS	R5, #' '
				STR		R5, [R4]
;Draw a triangle







				ENDP

				ALIGN 		4					 ; Align to a word boundary

		END                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
   