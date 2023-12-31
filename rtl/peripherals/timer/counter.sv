module Counter (
  input logic clk,
  input logic en,
  input logic rst,
  input logic count, 
  output logic [31:0] timer,
  output logic irq
);

  enum logic {INITIAL, OPERATING} timerState = INITAL;
  logic [31:0] timer_reg;
  
  always_ff @(posedge clk) begin
    if (timerState == INITAL) begin
      timerState <= OPERATING;
      timer_reg = 32'd0;
    end
  end

  always_ff @(posedge clk) begin
    if (rst == 1'b1) begin
      timer_reg <= 'd0;
    end else timer_reg <= timer_reg + 'd1;
  end

  assign timer = timer_reg;
  assign irq = ((en==1'b1) && (timer_reg == count)) ? 1'b1 : 1'b0;
endmodule