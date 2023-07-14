module PingPong (
  input logic rst,
  input logic clk,
  input logic [31:0] dimensions,
  input logic [31:0] ballPosition,
  input logic [15:0] ballVelocity,
  input logic [31:0] leftPaddlePosition,
  input logic [31:0] rightPaddlePosition,

  output logic [1:0] scoreOut,
  output logic [31:0] leftPaddlePositionOut,
  output logic [31:0] rightPaddlePositionOut,
  output logic [31:0] ballPositionOut,
  output logic [15:0] ballVelocityOut
);

  logic [1:0] score_reg = 2'b0;
  logic [31:0] ball_vel_reg;

  assign ballVelocityOut = ball_vel_reg;
  assign scoreOut = score_reg;
  
endmodule