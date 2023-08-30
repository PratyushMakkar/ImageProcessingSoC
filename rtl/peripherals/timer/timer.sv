`include "counter.sv"
module Timer (
  input logic clk,
  input logic rst,
  input logic [31:0] address,
  input logic wr_en, rd_en,
  input logic [31:0] wr_data,
  output logic [31:0] rd_data,
  output logic interrupt
);

  //-----------------------------------Start of timer commands----------------------//
  parameter  CONTROL_ADDRESS = 4'h0;       // 0x00     
  parameter  TIM_CNT_ADDRESS = 4'h4;       // 0x04    
  parameter  COMPARE_ADDRESS = 4'h8;       // 0x08
  parameter  PRESCALER_ADDRESS = 4'hC;     // 0x0C
  parameter  MAX_COUNTER_VAL = 32'hFFFFFFFF;

  parameter logic [7:0] CONTROL_DEFAULT = 8'h0F;
  parameter logic REINIT_COUNTER_INDEX = 3;
  parameter logic RESET = 2;
  parameter logic OVERFLOW = 3;
  
  logic [31:0] timControlReg            = 32'd0;        // [][][][][OverflowFlag][ResetTimer][GenerateInterrupt][EnableTimer]
  logic [31:0] timCompareReg            = 32'd0;
  logic [31:0] timFreeCountReg;
  logic [31:0] timPrescalerCountReg;
  logic [31:0] reserved                 = 32'd0;

  logic [31:0] readData;
  /*-------------------------------------------------------------------------------------------*/
  logic prescalerReset, prescalerInterrupt;
  logic timerReset, timerInterrupt;
  /*---------------------------------------------------------------------------------------------*/
  logic resetTimer, generateInterrupt, enableTimer, overflowFlag;
  /*---------------------------------------------------------------------------------------------*/

  assign {overflowFlag, resetTimer, generateInterrupt, enableTimer} = timControlReg[3:0];
  assign {prescalerReset, timerReset} = (resetTimer == 1'b1) ? 2'b11 : 2'b00;
  
  Counter PRESCALER_COUNTER (
    .clk(clk),
    .en(enableTimer),
    .rst(prescalerReset),
    .count(timCompareReg),
    .timer(timePrescalerCountReg),
    .irq(prescalerInterrupt)
  );

  Counter TIMER_COUNTR (
    .clk(clk),
    .en(prescalerInterrupt),
    .rst(timerReset),
    .count(MAX_COUNTER_VAL),
    .timer(timFreeCountReg),
    .irq(timerInterrupt)
  );

  always_ff @(posedge clk) begin : CONTROL_REG_INTERFACE
    if (timerInterrupt == 1'b1) timControlReg[OVERFLOW] <= 1'b1;
    timControlReg[RESET] <= 1'b0;
    if (wr_en == 1'b1 && address == CONTROL_ADDRESS) begin
      timControlReg <= wr_data;
    end
  end

  always_ff @(posedge clk) begin : WRITE_INTERFACE
    if (wr_en == 1'b1) begin
      case (address)
        TIM_CNT_ADDRESS: timFreeCountReg <= wr_data;
        COMPARE_ADDRESS: timCompareReg <= wr_data;
        PRESCALER_ADDRESS: timPrescalerCountReg <= wr_data;
      endcase
    end
  end

  always_comb begin : READ_INTERFACE
    if (rd_en == 1'b1) begin
      unique case (address)
        CONTROL_ADDRESS: readData = timControlReg;
        TIM_CNT_ADDRESS: readData = timFreeCountReg;
        COMPARE_ADDRESS: readData = timCompareReg;
        PRESCALER_ADDRESS: readData = timPrescalerCountReg;
        default: readData = reserved;
      endcase
    end else read_data <= 32'dz;
  end

  assign rd_data = readData;
  assign interrupt = generateInterrupt & overflowFlag;

endmodule