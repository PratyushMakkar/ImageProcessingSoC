`include "counter.sv"
module Timer (
  input logic clk,
  input logic rst,
  input logic [31:0] address,
  input logic wr_en, rd_en,
  input logic [31:0] wr_data,
  output logic [31:0] rd_data,
  output logic [31:0] timer,
  output logic interrupt
);

  //-----------------------------------Start of timer commands----------------------//
  parameter  CONTROL_ADDRESS = 4'h0;       // 0x00     
  parameter  TIM_CNT_ADDRESS = 4'h4;       // 0x04
  parameter  COMPARE_ADDRESS = 4'h8;       // 0x08
  parameter  PRESCALER_ADDRESS = 4'hC;     // 0x0C

  parameter logic [7:0] CONTROL_DEFAULT = 8'h0F;
  parameter logic REINIT_COUNTER_INDEX = 3;
  
  logic [16:0] tim_control_reg;
  logic [31:0] tim_cnt_reg;
  logic [31:0] tim_cmp_reg;
  logic [31:0] tim_prescaler_reg;

  logic [31:0] read_data;
  //-------------------------------------------------------------------------------------------//
  logic prescaler_rst, prescaler_irq;
  logic [31:0] prescaler_reg, prescaler_cnt;

  logic timer_rst, timer_interrupt;
  logic [31:0] timer_cnt;
  
  //---------------------------------------------------------------------------------------------
  logic counter_en_cfg, interrupt_en_cfg, automatic_rst_cfg, 
  reinit_counter_cfg, clr_timer_cfg, timer_did_expire_cfg;

  logic synchronous_timer_reset;
  //---------------------------------------------------------------------------------------------

  assign synchronous_timer_reset = clr_timer_cfg | reinit_counter_cfg;
  assign {counter_en_cfg, interrupt_en_cfg, automatic_rst_cfg, reinit_counter_cfg, clr_timer_cfg}
    = tim_control_reg[0:4];
  assign tim_control_reg[5] = timer_did_expire_cfg;

  assign timer_did_expire_cfg = timer_interrupt;

  assign prescaler_rst = (synchronous_timer_reset |
                          (automatic_rst_cfg & prescaler_irq) | (~timer_interrupt & prescaler_irq));

  assign timer_rst = (automatic_rst_cfg & timer_interrupt) | synchronous_timer_reset;  

  Counter PRESCALER_COUNTER (
    .clk(clk),
    .en(counter_en_cfg),
    .rst(prescaler_rst),
    .count(prescaler_reg),
    .timer(prescaler_cnt)
    .irq(prescaler_irq)
  );

  Counter TIMER_COUNTR (
    .clk(clk),
    .en(prescaler_irq),
    .rst(timer_rst),
    .count(compare_reg),
    .timer(timer_cnt),
    .irq(timer_interrupt)
  );

  always_ff @(posedge clk) begin : WRITE_INTERFACE
    tim_control_reg[REINIT_COUNTER_INDEX] <= 1'b0;

    if (wr_en == 1'b1) begin
      case (address)
        CONTROL_ADDRESS: tim_control_reg <= wr_data;
        COMPARE_ADDRESS: tim_cmp_reg <= wr_data;
        PRESCALER_ADDRESS: tim_prescaler_reg <= wr_data;
        default: ;
      endcase
    end 

    if (clr_timer_cfg == 1'b1) begin
      tim_control_reg <= CONTROL_DEFAULT;
      tim_cmp_reg <= 32'd0;
      tim_prescaler_reg <= 32'd0;
    end
  end

  always_comb begin : READ_INTERFACE
    if (rd_en == 1'b1) begin
      unique case (address)
        CONTROL_ADDRESS: read_data <= tim_control_reg;
        TIM_CNT_ADDRESS: read_data <= tim_cnt_reg;
        COMPARE_ADDRESS: read_data <= tim_cmp_reg;
        PRESCALER_ADDRESS: read_data <= tim_prescaler_reg;
      endcase
    end else read_data <= 32'dz;
  end


  assign rd_data = read_data;
  assign timer = timer_cnt;
  assign interrupt = (interrupt_en_cfg == 1'b1) ? timer_interrupt : 1'b0;
endmodule