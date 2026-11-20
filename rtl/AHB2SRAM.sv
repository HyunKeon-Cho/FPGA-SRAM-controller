module AHB2SRAM #(
    parameter   MEM_DEPTH       = 20,
    parameter   DATA_BITWIDTH   = 16,
    parameter   BASE_ADDR       = 32'h51000000
)(
  // --------------------------------
  // AHBLITE INTERFACE
  // --------------------------------
    // Global Signal
    input wire                      HCLK,
    input wire                      HRESETn,
    // Control
    input wire                      HWRITE,
    input wire [1:0]                HTRANS,
    input wire [2:0]                HSIZE,
    output wire                     HREADYOUT,
    input wire                      HREADY,
    // Address
    input wire [31:0]               HADDR,
    // Data
    input wire [31:0]               HWDATA,
    output reg  [31:0]              HRDATA,
    // select
    input wire                      HSEL,

  // --------------------------------
  // SRAM interface
  // --------------------------------
    output wire [MEM_DEPTH-1:0]     SRAM_ADDR,
    inout  wire [DATA_BITWIDTH-1:0] SRAM_DQ,
    output wire                     SRAM_UB_N,
    output wire                     SRAM_LB_N,
    output wire                     SRAM_CE_N,
    output wire                     SRAM_OE_N,
    output wire                     SRAM_WE_N
);

typedef enum reg [2:0] {
    IDLE  = 3'b001,
    READ  = 3'b010,
    WRITE = 3'b100
} state_t;

// --------------------------------
// wire & reg
// --------------------------------
// ---- SRAM ----
state_t cstate;
wire    is_IDLE;
wire    is_READ;
wire    is_WRITE;

// ---- AHB-Lite ----
// address phase
wire        aphase_hk;
reg  [31:0] aphase_addr; // address phase
reg         aphase_we;
reg  [2:0]  aphese_size;
// data phase
reg  [31:0] dphase_rdata;
reg  [31:0] dphase_wdata;
wire        dphase_len;
reg  [1:0]  dphase_cnt;
wire        dphase_done;
reg  [15:0] dphase_buf;


// --------------------------------
// assignment
// --------------------------------
// ---- SRAM ----
// port
assign SRAM_CE_N = cstate[0];
assign SRAM_OE_N = cstate[2];
assign SRAM_WE_N = !(cstate[2] & (dphase_cnt <= dphase_len));
assign SRAM_UB_N = cstate[0];
assign SRAM_LB_N = cstate[0];
assign SRAM_ADDR = aphase_addr + (dphase_len && (dphase_cnt != 0));
assign SRAM_DQ   = (is_WRITE && (dphase_cnt <= dphase_len)) ? ((dphase_cnt[0]) ?  HWDATA[31:16] : HWDATA[15:0]) : 16'bz;


// ---- AHB-Lite ---- 
// port
assign HREADYOUT = is_IDLE | dphase_done;
assign HRDATA = {SRAM_DQ, dphase_buf};

// address phase
assign aphase_hk = HSEL & HTRANS[1] & HREADY;

// data phase
assign is_IDLE           = cstate[0];
assign is_READ           = cstate[1];
assign is_WRITE          = cstate[2];
assign dphase_len    = aphese_size[1];
assign dphase_done = !is_IDLE & (dphase_cnt == dphase_len + 1);

// --------------------------------
// AHB-Lite : address phase
// --------------------------------
// Address phase
always @(posedge HCLK or negedge HRESETn) begin : ADDRESS_PHASE
    if (!HRESETn) begin
        aphase_addr <= '0;
        aphase_we   <= '0;
        aphese_size <= '0;
    end else if (aphase_hk & (is_IDLE | dphase_done)) begin
        aphase_addr <= HADDR >> 1;
        aphase_we   <= HWRITE;
        aphese_size <= HSIZE;
    end else begin
        aphase_addr <= aphase_addr;
        aphase_we   <= aphase_we;
        aphese_size <= aphese_size;
    end
end

// --------------------------------
// SRAM control : data phase
// --------------------------------
always @(posedge HCLK or negedge HRESETn) begin : DATA_PHASE
    if (!HRESETn) begin
        cstate <= IDLE;
    end else begin
        case(cstate) 
            IDLE : begin
                if (aphase_hk) begin
                    cstate <= (HWRITE) ? WRITE : READ; 
                end
            end
            READ : begin
                if (dphase_done & HREADY) begin 
                    if (aphase_hk) begin
                        cstate <= (HWRITE) ? WRITE : READ; 
                    end else begin
                        cstate <= IDLE;
                    end
                end else begin
                    cstate <= READ;
                end
            end 
            WRITE : begin
                if (dphase_done & HREADY) begin 
                    if (aphase_hk) begin
                        cstate <= (HWRITE) ? WRITE : READ; 
                    end else begin
                        cstate <= IDLE;
                    end
                end else begin
                    cstate <= WRITE;
                end
            end 
        endcase
    end
end

// --------------------------------
// counter
// --------------------------------
always @(posedge HCLK or negedge HRESETn) begin : DATA_PHASE_COUNTER
    if (!HRESETn) begin
        dphase_cnt <= '0;
    end else if (~cstate[0]) begin
        if (dphase_cnt == dphase_len + 1) begin
            dphase_cnt <= (HREADY) ? '0 : dphase_cnt;
        end else begin
            dphase_cnt <= dphase_cnt + 1;
        end 
    end else begin
        dphase_cnt <= '0;
    end
end

always @(posedge HCLK or negedge HRESETn) begin : DATA_PHASE_BUFFER
    if (!HRESETn) begin
        dphase_buf <= '0;
    end else if (dphase_cnt == 0) begin
        dphase_buf <= SRAM_DQ;
    end else begin
        dphase_buf <= dphase_buf;
    end
end


endmodule