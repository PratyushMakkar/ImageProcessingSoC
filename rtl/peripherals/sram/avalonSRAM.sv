module AvalonSRAM (
  input logic clk,
  input logic read_n,       
  input logic write_n,
  input logic chipselect,
  input logic beginTransfer,
  input logic [31:0] address,
  output logic [7:0] readData,
  input logic [7:0] writeData,
  input logic [3:0] byteEnable_n,
  output logic readdatavalid,
  output logic waitrequest,
  output logic readyfordata,
  output logic resetrequest,
  output logic irq
);

endmodule