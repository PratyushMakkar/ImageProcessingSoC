module PaddleAlgorithm 
  parameter [15:0] HALF_PADDLE_HEIGHT = 16'h0032;
  parameter [15:0] HALF_PADDLE_HEIGHT_COMPL = 16'hffCE;
(
  input logic clk,
  input logoc rst,
  input logic [31:0] dimensions,
  input logic [31:0] ballPosition,
  input logic [15:0] ballVelocity,    
  input logic [31:0] paddlePositionIn, 
  output logic [31:0] paddlePositionOut
);

  logic [15:0] half_dimension;
  logic [15:0] paddle_base;

  assign paddle_base = half_dimension + HALF_PADDLE_HEIGHT_COMPL;
  assign half_dimension = {1'b0, dimensions[15:1]};

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
    paddlePositionOut <= {paddlePositionIn[31:16], paddle_base};
  end

endmodule