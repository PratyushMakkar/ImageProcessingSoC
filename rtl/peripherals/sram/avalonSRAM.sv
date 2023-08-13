`include "SRAMController.sv"
module AvalonSRAM (
  input logic clk,
  input logic read_n,       
  input logic write_n,
  input logic [31:0] address,
  output logic [31:0] readData,
  input logic [31:0] writeData,
  input logic [1:0] byteEnable_n,
 
  inout logic [15:0] dq_sram,             // Signals intended for SRAM
  output logic [17:0] address_sram,
  output logic ce_n_sram, oe_n_sram, we_n_sram, lb_n_sram, ub_n_sram
);

  SRAMController controller (
    .clk(clk),
    .read_en(~read_n),
    .wr_en(~write_n),
    .address(address[17:0]),
    .wr_data(writeData),
    .read_data(readData),
    .byteEnable_n(byteEnable_n),
    .dq_sram(dq_sram),
    .address_sram(address_sram),
    .ce_n_sram(ce_n_sram),
    .oe_n_sram(oe_n_sram),
    .we_n_sram(we_n_sram),
    .lb_n_sram(lb_n_sram),
    .ub_n_sram(ub_n_sram)
  );

endmodule