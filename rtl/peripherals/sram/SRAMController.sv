module SRAMController (
  // SRAM interface for the controller user
  input logic clk,
  input logic read_en, wr_en, 
  input logic [17:0] address,
  input logic [15:0] wr_data,
  input logic [1:0] byteEnable_n,
  output logic [15:0] read_data,

  inout logic [15:0] dq_sram,             // Signals intended for SRAM
  output logic [17:0] address_sram,
  output logic ce_n_sram, oe_n_sram, we_n_sram, lb_n_sram, ub_n_sram
);

  assign dq_sram = (read_en == 1'b1) ? 16'dz : wr_data;
  assign read_data = (read_en == 1'b1) ? dq_sram : 16'hz;

  assign address_sram = address;
  assign {ub_n_sram, lb_n_sram} = byteEnable_n;
  assign we_n_sram = (read_en == 1'b1) ? 1'b1 : 1'b0;
  assign {ce_n_sram, oe_n_sram} = ((read_en == 1'b1) || (wr_en ==1'b1)) ? 2'b00 : 2'b11;
  
endmodule