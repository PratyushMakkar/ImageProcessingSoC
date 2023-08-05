module Counter (
  input logic clk,
  input logic en,
  input logic rst,
  output logic [31:0] timer
);

  logic [31:0] timer_reg;

  always_ff @(posedge clk) begin
    if (rst == 1'b1) begin
      timer_reg <= 'd0;
    end else timer_reg <= timer_reg + 1;
  end

  assign timer = timer_reg;
endmodule