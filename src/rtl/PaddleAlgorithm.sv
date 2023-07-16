module PaddleAlgorithm 
  parameter HALF_PADDLE_HEIGHT = 50;
(
  input logic clk,
  input logoc rst,
  input logic [31:0] ballPosition,
  input logic [15:0] ballVelocity,    
  input logic [31:0] paddlePositionIn, 
  output logic [31:0] paddlePositionOut
);

  always_ff @(posedge clk) begin 
    if ((paddlePositionIn[15:0] + HALF_PADDLE_HEIGHT) < ballPosition) begin
      paddlePositionOut[15:0] <= paddlePositionIn[15:0] + 16'h0005;
    end else begin
      paddlePositionOut[15:0] <= paddlePositionIn[15:0] + 16'hFFFB; 
    end
    paddlePositionOut[31:16] <= paddlePositionIn[31:16];
  end 

  always_ff @(negedge rst) begin
    playerDidScore <= 2'b00;
  end

endmodule