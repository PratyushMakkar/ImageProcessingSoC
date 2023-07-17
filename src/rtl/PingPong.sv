`include "BallPhysics.sv"
`include "PaddleAlgorithm.sv"
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
  output logic [31:0] ballVelocityOut
);

  logic [1:0] player_score_update_reg;
  logic [15:0] player_score_reg;

  automatedPaddle PaddleAlgorithm (
    .clk(clk),
    .rst(rst),
    .ballPosition(ballPosition),
    .dimensions(dimensions),
    .ballVelocity(ballVelocity),
    .paddlePositionIn(leftPaddlePosition),
    .paddlePositionOut(leftPaddlePosition),
  );

  ballPixel BallPhysics (
    .rst(rst),
    .clk(clk),
    .dimensions(dimensions),
    .ballPosition(ballPosition),       // X- Y value
    .ballVelocity(ballVelocity),
    .leftPaddlePosition(leftPaddlePosition),
    .rightPaddlePosition(rightPaddlePosition),
    .playerDidScore(player_score_update_reg)                    // RL
    .ballPositionOut(ballPosition),
    .ballVelocityOut(ballVelocity),
  );

  always_ff @(posedge clk) begin
    if (player_score_reg != 2'b00) begin
      if (player_score_update_reg[1]) begin
        player_score_reg[15:8] <= player_score_reg[15:8] + 8'h01;
      end else begin
        player_score_reg[7:0] <= player_score_reg[7:0] + 8'h01;
      end
    end
  end
  
  assign scoreOut = player_score_reg;

endmodule