`include "SRAMController.sv"
`include "syncFifo.sv"
module AvalonSRAM (
  input logic rst,
  input logic clk,
  input logic read_n,       
  input logic write_n,
  input logic [31:0] address,
  output logic [15:0] readData,
  input logic [15:0] writeData,
  input logic [1:0] byteEnable_n,
  
  output logic waitrequest,          // Signals for burst support
  output logic readdatavalid,

  inout logic [15:0] dq_sram,             // Signals intended for SRAM
  output logic [17:0] address_sram,
  output logic ce_n_sram, oe_n_sram, we_n_sram, lb_n_sram, ub_n_sram
);

  typedef enum logic [1:0] {
    SRAM_IDLE,
    SRAM_BUSY
  } pipelined_state_t;

  pipelined_state_t currState = SRAM_IDLE;
  pipelined_state_t nextState;
  
  /*--------- RX FIFO signals------*/
  logic [17:0] addressDataIn, addressDataOut;
  logic [1:0] byteEnableIn, byteEnableOut;
  logic [15:0] writeDataIn, writeDataOut;
  logic readEn, writeEn;
  logic isEmptyAddressRX, isEmptyByteEnableRX, isEmptyDataRX;
  logic isFullAddressRX, isFullByteEnableRX,  isFullDataRX;
  logic isAlmostFullAddressRX, isAlmostFullByteEnableRX,  isAlmostFullDataRX;
  
  logic writeEnableRX;
  logic writeEnableDataRX;
  logic readEnableRX;
  logic readEnableDataRX;

  /*--------- TX FIFO signals------*/
  logic [17:0] dataInTX, dataOutTX;
  logic isEmptyDataTX, isFullDataTX;
  logic isAlmostFullDataTX;

  logic writeEnableTX;
  logic readEnableTX;

  assign dataInTX = readDataReg;

  /* ------------ SRAM Controller signals---------- */
  logic readEnableSRAM, writeEnableSRAM;
  logic [15:0] readDataReg;

  logic isReadLatch;

  SyncFifo #(.FIFO_DEPTH(3), .FIFO_WIDTH(18)) AddressFIFO (
    .clk(clk),
    .rst(rst),
    .dataIn(address[17:0]),
    .dataOut(addressDataOut),
    .isEmpty(isEmptyAddressRX),
    .isFull(isFullAddressRX),
    .isAlmostFull(isAlmostFullAddressRX),
    .writeEn(writeEnableRX),
    .readEn(readEnableRX)
  );

  SyncFifo #(.FIFO_DEPTH(3), .FIFO_WIDTH(2)) ByteEnableFIFO (
    .clk(clk),
    .rst(rst),
    .dataIn(byteEnable_n),
    .dataOut(byteEnableOut),
    .isEmpty(isEmptyByteEnableRX),
    .isFull(isFullByteEnableRX),
    .isAlmostFull(isAlmostFullByteEnableRX),
    .writeEn(writeEnableRX),
    .readEn(readEnableRX)
  );

  SyncFifo #(.FIFO_DEPTH(3), .FIFO_WIDTH(16)) WriteDataFIFO (
    .clk(clk),
    .rst(rst),
    .dataIn(writeData),
    .dataOut(writeDataOut),
    .isEmpty(isEmptyDataTX),
    .isFull(isFullDataRX),
    .isAlmostFull(isAlmostFullDataRX),
    .writeEn(writeEnableDataRX),
    .readEn(readEnableDataRX)
  );

  SRAMController Controller (
    .clk(clk),
    .read_en(readEnableSRAM),
    .wr_en(writeEnableSRAM),
    .address(addressDataOut),
    .wr_data(writeDataOut),
    .read_data(readDataReg),
    .byteEnable_n(byteEnableOut),
    .dq_sram(dq_sram),
    .address_sram(address_sram),
    .ce_n_sram(ce_n_sram),
    .oe_n_sram(oe_n_sram),
    .we_n_sram(we_n_sram),
    .lb_n_sram(lb_n_sram),
    .ub_n_sram(ub_n_sram)
  );

  SyncFifo #(.FIFO_DEPTH(3), .FIFO_WIDTH(16)) SRAMDataFIFO (
    .clk(clk),
    .rst(rst),
    .dataIn(dataInTX),
    .dataOut(dataOutTX),
    .isEmpty(isEmptyDataRX),
    .isFull(isFullDataTX),
    .isAlmostFull(isAlmostFullDataTX),
    .writeEn(writeEnableTX),
    .readEn(readEnableTX)
  );

  always_comb begin : RX_FIFO_INTERFACE
    if (!read_n || !write_n) begin 
      {addressDataIn, byteEnableIn} = {address, byteEnable_n};
      if (!isFullAddressRX) begin
        waitrequest = 1'b0;
        writeEnableRX = 1'b1;
        writeEnableDataRX = !write_n;
      end else begin
        waitrequest = 1'b1;
        writeEnableRX = 1'b0;
        writeEnableDataRX = 1'b0;
      end 
    end else begin
      waitrequest = 1'b0;
      writeEnableDataRX = 1'b0;
      writeEnableRX = 1'b0;
      {addressDataIn, byteEnableIn} = 'd0;
    end
  end

  always_comb begin : TX_FIFO_INTERFACE
    if (!isEmptyDataTX) begin
      readdatavalid = 1'b1;
      readEnableTX = 1'b1;
      readData = dataOutTX;
    end else begin
      readdatavalid = 1'b0;
      readEnableTX = 1'b0;
      readData = 'd0;
    end
  end

  always_comb begin : SRAM_INTERFACE
    unique case (currState)
      SRAM_IDLE: begin
        {readEnableSRAM, writeEnableSRAM} = {1'b0, 1'b0};
        writeEnableTX = 1'b0;
        if (!isEmptyAddressRX && !isFullAddressRX) begin
          nextState = SRAM_BUSY;
          readEnableRX = 1'b1;
          readEnableDataRX = !isEmptyDataRX;
        end else begin
          nextState = SRAM_IDLE;
          readEnableRX = 1'b0;
          readEnableDataRX = 1'b0;
        end
      end
      SRAM_BUSY: begin
        writeEnableTX = ~read_n;  // We only write to transmit buffer if we are reading.
        {readEnableSRAM, writeEnableSRAM} = {isReadLatch, ~isReadLatch};
        if (!isEmptyAddressRX && !isAlmostFullAddressRX) begin /* It should be almost full */
          nextState = SRAM_BUSY;
          readEnableRX = 1'b1;
          readEnableDataRX = !isEmptyDataRX;
        end else begin
          nextState = SRAM_IDLE;
          readEnableRX = 1'b0;
          readEnableDataRX = 1'b0;
        end
      end
    endcase
  end

  always_ff @(posedge clk) begin
    currState <= nextState;
  end

  always_ff @(posedge clk) begin : isReadLatch_Interface
    if (nextState == SRAM_IDLE) begin
      isReadLatch <= 1'b0;
    end else begin
      if (currState == SRAM_IDLE) begin
        if (~read_n) isReadLatch <= 1'b1;
        else isReadLatch <= 1'b0;
      end
    end
  end

endmodule