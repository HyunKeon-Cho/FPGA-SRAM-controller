
`timescale 10ms/1ms
	
module tb_AHB2SRAM();

	// Clock feeds to SoC 
	reg 		clk = 0;
	reg         nreset;             // Active low reset

	// LED
	wire	[7:0]	led;

	// SRAM
	wire [19:0]		SRAM_ADDR;
	wire [15:0]		SRAM_DQ;
	wire 			SRAM_UB_N;
	wire 			SRAM_LB_N;
	wire 			SRAM_CE_N;
	wire 			SRAM_OE_N;
	wire 			SRAM_WE_N;

	// Clock ratio for SoC. 
	// Changing the ratio and phase can produce unpredictable results. 
	always #1 clk = ~clk;

	// nreset input
	initial begin
		nreset   	<= 0;
		#(10)
		nreset   	<= 1;
	end

	

	// SoC instantiation
	AHBLITE_SYS	SoC (
		.CLK			(clk),
		.RESET			(nreset),
		
		//LED
		.LEDR			(led),
		
		// ETC
		.TCK_SWCLK		(),
		.TDI_NC			(),
		.TMS_SWDIO		(),
		.TDO_SWO		(),
		.SRAM_ADDR		(SRAM_ADDR),
		.SRAM_DQ		(SRAM_DQ),
		.SRAM_UB_N		(SRAM_UB_N),
		.SRAM_LB_N		(SRAM_LB_N),
		.SRAM_CE_N		(SRAM_CE_N),
		.SRAM_OE_N		(SRAM_OE_N),
		.SRAM_WE_N		(SRAM_WE_N)
	);
	
	SRAM_dummy uSRAM_dummy (
		.SRAM_ADDR		(SRAM_ADDR),
		.SRAM_DQ		(SRAM_DQ),
		.SRAM_UB_N		(SRAM_UB_N),
		.SRAM_LB_N		(SRAM_LB_N),
		.SRAM_CE_N		(SRAM_CE_N),
		.SRAM_OE_N		(SRAM_OE_N),
		.SRAM_WE_N		(SRAM_WE_N)
	);

	// Siganals dump for debugging
	initial
	begin
//		$shm_open("SoC.shm");
//		$shm_probe("AC");
		#(400)
		$finish;
	end

endmodule
