module SyncFifo #(parameter FIFO_DEPTH, FIFO_WIDTH) (
  input logic clk,
  input logic rst,
  input logic readEn,
  input logic writeEn,
  input logic [FIFO_WIDTH-1:0] dataIn,

  output logic [FIFO_WIDTH-1:0] dataOut,
  output logic isEmpty,
  output logic isAlmostFull,
  output logic isFull
);

  logic [FIFO_DEPTH-1:0] readPtr = 'd0;
  logic [FIFO_DEPTH:0] writePtr = 'd0;
  logic [FIFO_DEPTH:0] nextWritePtr;
  
  logic [FIFO_WIDTH-1:0] dataOutReg;
  logic isFullReg, isAlmostFullReg;
  logic isEmptyReg;
  
  assign nextWritePtr = writePtr + 1'b1;
  assign isAlmostFullReg = ((readPtr == nextWritePtr[FIFO_DEPTH-1:0]) && (nextWritePtr[FIFO_DEPTH] == 1'b1)) ? 1'b1 : 1'b0;
  assign isFullReg = ((readPtr == writePtr[FIFO_DEPTH-1:0]) && (writePtr[FIFO_DEPTH] == 1'b1)) ? 1'b1 : 1'b0;
  assign isEmptyReg = (readPtr == writePtr[FIFO_DEPTH-1:0] && (writePtr[FIFO_DEPTH] == 1'b0)) ? 1'b1 : 1'b0;
  

  logic [FIFO_WIDTH-1:0] data [(1<<FIFO_DEPTH)-1:0];

  always_ff @(posedge clk) begin
    if (rst == 1'b1) begin
      readPtr <= 'd0;
      writePtr <= 'd0;
    end else begin
      if (writeEn && !isFullReg) begin
        data[writePtr[FIFO_DEPTH-1:0]] <= dataIn;
        writePtr <= writePtr + 1'b1;
      end
      if (readEn && !isEmptyReg) begin
        dataOutReg <= data[readPtr];
        readPtr <= readPtr + 1'b1;
        if (isFullReg == 1'b1) begin
          writePtr <= (writeEn == 1'b1) ? {1'b0, (readPtr + 1'b1)} : {1'b0, readPtr} ;
        end
      end
    end
  end

  assign isFull = isFullReg;
  assign isEmpty = isEmptyReg;
  assign isAlmostFull = isFullReg | isAlmostFullReg;
  assign dataOut = dataOutReg;
endmodule