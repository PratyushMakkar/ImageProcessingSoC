module SyncFifo (
  input logic clk,
  input logic rst,
  input logic [FIFO_WIDTH-1:0] dataIn,
  input logic readEn,
  input logic writeEn,
  output logic isFull,
  output logic [FIFO_WIDTH-1:0] dataOut,
);

  parameter FIFO_DEPTH = 3;
  parameter FIFO_WIDTH = 17;

  logic dataOutReg;
  
  logic isFullReg; 
  logic isEmptyReg; 
  
  assign isFullReg = ((readPtr == writePtr[MAX_DEPTH-1:0]) && (writePtr[MAX_DEPTH] == 1'b1)) ? 1'b1 : 1'b0;
  assign isEmptyReg = (readPtr == writePtr[MAX_DEPTH-1:0] && (writePtr[MAX_DEPTH] == 1'b0)) ? 1'b1 : 1'b0;
  
  logic [FIFO_DEPTH-1:0] readPtr = 'd0;
  logic [FIFO_DEPTH:0] writePtr = 'd0;

  logic [FIFO_WIDTH-1:0] data [(1<<FIFO_DEPTH)-1:0];

  always_ff @(posedge clk) begin
    if (rst == 1'b1) begin
      readPtr <= 'd0;
      writePtr <= 'd0;
    end else begin
      if (writeEn && !isFullReg) begin
        data[writePtr] <= dataIn;
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
  assign dataOut = dataOutReg;
endmodule