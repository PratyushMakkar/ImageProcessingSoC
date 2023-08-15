module TimerTestbench ();
  parameter  CONTROL_ADDRESS = 4'h0;       // 0x00     
  parameter  TIM_CNT_ADDRESS = 4'h4;       // 0x04
  parameter  COMPARE_ADDRESS = 4'h8;       // 0x08
  parameter  PRESCALER_ADDRESS = 4'hC;     // 0x0C

  logic clk, rst;
  logic [31:0] address;
  logic writeEn, readEn;
  logic [31:0] wrData, readData;
  logic [31:0] timer;
  logic irq;
  
  task ToggleClock();
    #5
    clk = ~clk;
    #5
    clk = ~clk;
  endtask

endmodule