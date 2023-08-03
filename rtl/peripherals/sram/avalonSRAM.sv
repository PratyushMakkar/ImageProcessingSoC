`include "SRAMController.sv"
module AvalonSRAM (
  input logic clk,
  input logic read_n,       
  input logic write_n,
  input logic chipselect,
  input logic beginTransfer,
  input logic [31:0] address,
  output logic [15:0] readData,
  input logic [15:0] writeData,
  input logic [3:0] byteEnable_n,
  output logic waitrequest,
  output logic readyfordata,
  output logic irq,

  inout logic [15:0] dq_sram,             // Signals intended for SRAM
  output logic [17:0] address_sram,
  output logic ce_n_sram, oe_n_sram, we_n_sram, lb_n_sram, ub_n_sram
);

  logic [31:0] address_reg;
  logic [3:0] byteEnable_reg_n;
  logic read_n_reg, chipselect_reg;

  logic rst, read_en, wr_en;
  logic [17:0] address_in;
  logic [15:0] wr_data;
  logic read_valid, wr_valid;
  logic read_busy, wr_busy;
  logic [15:0] read_data;

  typedef enum {
    IDLE,
    READ,
    WRITE
  } avalon_state_t;
  avalon_state_t current_state, next_state;

  always_ff @(posedge clk) begin
    if (current_state == IDLE) begin
      address_reg <= address;
      byteEnable_reg_n <= byteEnable_n;
      read_n_reg <= read_n;
      chipselect_reg <= chipselect;
    end
  end

  always_comb begin
    unique case (current_state)
      IDLE: begin
        next_state <= (chipselect && ~read_n) ? READ : IDLE;
      end
      READ: begin
        next_state <= (chipselect && ~read_n) ? READ: IDLE;
      end
    endcase
  end

  SRAMController sramController (
    .clk(clk),
    .rst(rst),
    .read_en(~read_n),
    .wr_en(~write_n), 
    .address(address_in),
    .wr_data(wr_data),
    .read_valid(read_valid), 
    .wr_valid(wr_valid),
    .read_busy(read_busy)
    .wr_busy(wr_busy),
    .read_data(read_data),
  
    .dq_sram(dq_sram),             // Signals intended for SRAM
    .address_sram(address_sram),
    .ce_n_sram(ce_n_sram), 
    .oe_n_sram(oe_n_sram), 
    .we_n_sram(we_n_sram), 
    .lb_n_sram(lb_n_sram), 
    .ub_n_sram(ub_n_sram)
  );

  assign waitrequest = (read_en && ~read_valid);

endmodule