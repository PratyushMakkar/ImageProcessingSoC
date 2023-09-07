`include "../syncFifo.sv"

module pixelBuffer (
  input logic clk,
  input logic rst,
  input logic writeEn,
  input logic [23:0] pixelRGB,
  output logic readEn,
  output logic [9:0] pixelAddressRegister,
  output logic writeValid,
  output logic [23:0] pixel,
  output logic emptyInterrupt
);  

  parameter logic [12:0] PIXEL_BUFFER_DEPTH = 1280;
  
  logic [9:0] currentPixelAddress = 0;
  logic [10:0] currentFifoLevel = 0;

  logic writeValid, readValid;

  /* ---------------------- FIFO Signals ------------------- */
  logic isEmpty, isFull, isAlmostFull; 

  always @(posedge clk) begin
    if (writeValid) currentFifoLevel <= currentFifoLevel - 1'b1;
    if (readValid) currentFifoLevel <= currentFifoLevel + 1'b1;
  end

  SyncFifo #(.FIFO_DEPTH(PIXEL_BUFFER_DEPTH), .FIFO_WIDTH(23)) PixelFIFO (
    .clk(clk),
    .rst(rst),
    .dataIn(pixelRGB),
    .dataOut(pixel),
    .isEmpty(isEmpty),
    .isFull(isFull),
    .isAlmostFull(isAlmostFull),
    .writeEn(writeEn),
    .readEn(readEn)
  );

  assign writeValid = !isFull & writeEn;
  assign readValid = !isEmpty & readEn;
  assign emptyInterrupt = (currentFifoLevel == PIXEL_BUFFER_DEPTH >> 2);
  assign pixelAddressRegister = currentPixelAddress;
endmodule