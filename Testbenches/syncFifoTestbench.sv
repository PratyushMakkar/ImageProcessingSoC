localparam FIFO_WIDTH = 4;
localparam FIFO_DEPTH = 3;

class RandomData;
  rand logic [FIFO_WIDTH-1:0] memoryValues [1<<FIFO_DEPTH];
endclass

module SyncFifoTestbench ();
  
  RandomData pkt;
  
  logic clk, rst;
  logic readEn, writeEn;
  logic [FIFO_WIDTH-1:0] dataIn, dataOut;
  logic isEmpty, isAlmostFull, isFull;
  
  SyncFifo #(.FIFO_WIDTH(FIFO_WIDTH), .FIFO_DEPTH(FIFO_DEPTH)) dut (
    .clk(clk),
    .rst(rst),
    .readEn(readEn),
    .writeEn(writeEn),
    .dataIn(dataIn),
    .dataOut(dataOut),
    .isEmpty(isEmpty),
    .isAlmostFull(isAlmostFull),
    .isFull(isFull)
  );
  
  initial begin
    clk = 1'b0;
    rst = 1'b0;
    readEn = 1'b0;
    writeEn = 1'b0;
    
    pkt = new();
    pkt.randomize();
    #2
    FillFifo();
    #5
    ReadFifo();
  end
  
  task ToggleClock();
    #5
    clk = ~clk;
    #5
    clk = ~clk;
  endtask
  
  task FillFifo();
    $display("The FIFO has status isFull = %B", isFull);
    for (int i = 0; i<(1<<FIFO_DEPTH); i = i+1) begin
      writeEn = 1'b1;
      dataIn = pkt.memoryValues[i];
      $display("The written value is %B", pkt.memoryValues[i]);
      ToggleClock;
    end
    
    $display("The FIFO has status isFull = %B", isFull);
    assert(isFull == 1'b1);
    
    dataIn = 'd0;
    $display("Inserting extraneous value %B", 'd0);
    ToggleClock;
    writeEn = 1'b0;
  endtask
  
  task ReadFifo();
    $display("The FIFO has status isEmpty = %B", isEmpty);
    for (int i = 0; i<(1<<FIFO_DEPTH); i = i+1) begin
      readEn = 1'b1;
 	  ToggleClock;
      $display("The read value is %B", dataOut);
      assert(dataOut == pkt.memoryValues[i]);
    end
    $display("The FIFO has status isEmpty = %B", isEmpty);
    assert(isEmpty == 1'b1);
  endtask
  
endmodule