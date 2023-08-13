`include "SRAMController.sv"
`include "syncFifo.sv"
module AvalonSRAM (
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

  typedef enum logic [2:0] {
    IDLE,
    BEGIN_ADDRESS,
    PIPELINED_TRANSFER,
    END_TRANSMIT
  } pipelined_state_t;

  pipelined_state_t currState = IDLE;
  pipelined_state_t nextState;
  
  /*--------- RX FIFO signals------*/
  logic [17:0] addressDataIn, addressDataOut;
  logic [1:0] byteEnableIn, byteEnableOut;
  logic readEn, writeEn;
  logic isEmptyAddressRX, isEmptyByteEnableRX;
  logic isFullAddressRX, isFullByteEnableRX;

  logic writeEnableRX:
  logic readEnableRX;

  /*--------- TX FIFO signals------*/
  logic [17:0] dataInTX, dataOutTX;
  logic isEmptyDataTX, isFullDataTX;

  logic writeEnableTX:
  logic readEnableTX;

  /* ------------ SRAM Controller signals---------- */
  logic readEnableSRAM, writeEnableSRAM;
  logic [15:0] readDataReg;


  SyncFifo #(.FIFO_DEPTH(3) .FIFO_WIDTH(18)) AddressFIFO (
    .clk(clk),
    .rst(rst),
    .dataIn(address[17:0]),
    .dataOut(addressDataOut),
    .isEmpty(isEmptyAddressRX),
    .isFull(isFullAddressRX),
    .writeEn(writeEnableRX),
    .readEn(readEnableRX)
  );

  SyncFifo #(.FIFO_DEPTH(3) .FIFO_WIDTH(2)) ByteEnableFIFO (
    .clk(clk),
    .rst(rst),
    .dataIn(byteEnable_n),
    .dataOut(addressDataOut),
    .isEmpty(isEmptyByteEnableRX),
    .isFull(isFullByteEnableRX),
    .writeEn(writeEnableRX),
    .readEn(readEnableRX)
  );

  SRAMController Controller (
    .clk(clk),
    .read_en(readEnableSRAM),
    .wr_en(writeEnableSRAM),
    .address(addressDataOut),
    .wr_data(writeData),
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

  SyncFifo #(.FIFO_DEPTH(3) .FIFO_WIDTH(16)) SRAMDataFIFO (
    .clk(clk),
    .rst(rst),
    .dataIn(dataInTX),
    .dataOut(dataOutTX),
    .isEmpty(isEmptyDataTX),
    .isFull(isFullDataTX),
    .writeEn(writeEnableTX),
    .readEn(readEnableTX)
  );

  always_comb begin : RX_FIFO_INTERFACE
    if (!read_n || !write_n) begin 
      {addressDataIn, byteEnableIn} = {address, byteEnable_n};
      if (!isFullAddressRX) begin
        waitrequest = 1'b0;
        writeEnableRX = 1'b1;
      end else begin
        waitrequest = 1'b1;
        writeEnableRX = 1'b0;
      end 
    end else begin
      writeEnableRX = 1'b0;
      {addressDataIn, byteEnableIn} = 'd0;
    end
  end

  // TODO handle case where TX buffer is full.
  always_comb begin : TX_FIFO_INTERFACE
    if (!isEmptyDataTX) begin
      readdatavalid = 1'b1;
      readEnableTX = 1'b1;
      readData = dataOutTX;
    end else begin
      readdatavalid = 1'b0;
      readEnableTX = 1'b0l
      readData = 'd0;
    end
  end

  always_comb begin : SRAM_INTERFACE

  end

endmodule