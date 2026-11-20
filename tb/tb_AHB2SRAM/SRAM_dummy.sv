module SRAM_dummy #(
    parameter   MEM_DEPTH       = 20,
    parameter   DATA_BITWIDTH   = 16
)(
    input      wire [19:0]      SRAM_ADDR,
    inout      wire [15:0]      SRAM_DQ,
    input      wire             SRAM_UB_N,
    input      wire             SRAM_LB_N,
    input      wire             SRAM_CE_N,
    input      wire             SRAM_OE_N,
    input      wire             SRAM_WE_N
);

reg [DATA_BITWIDTH-1:0] sram[(1<<MEM_DEPTH)-1:0];
wire we;

assign we = ~SRAM_CE_N & ~SRAM_WE_N & ~SRAM_UB_N & ~SRAM_LB_N;
assign SRAM_DQ = (we) ? {DATA_BITWIDTH{1'bz}} : sram[SRAM_ADDR];

always_latch begin
    if (we) begin
        sram[SRAM_ADDR] <= SRAM_DQ;
    end 
end

endmodule