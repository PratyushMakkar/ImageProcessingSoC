module BallPhysics (
  input logic rst,
  input logic clk,
  input logic [31:0] dimensions,
  input logic [31:0] ballPosition,    // X- Y value
  input logic [31:0] ballVelocity,
  input logic [31:0] leftPaddlePosition,
  input logic [31:0] rightPaddlePosition,
  output logic [1:0] playerDidScore     // RL
  output logic [31:0] ballPositionOut,
  output logic [31:0] ballVelocityOut,
);

  localparam PADDLE_HEIGHT 
  localparam INITIAL_BALL_VELOCITY = 15;

  logic [15:0] ball_vel_reg;
  logic [31:0] ball_pos_reg;
  logic [2:0] player_score_reg;

  always_ff @(negedge rst) begin
    ball_vel_reg[31:16] <= INITIAL_BALL_VELOCITY;
    ball_vel_reg[15:0] <= INITIAL_BALL_VELOCITY;

    ball_pos_reg[31:16] <= {1'b0, dimensions[31:17]};
    ball_pos_reg[15:0] <= {1'b0, dimensions[16:1]};

    player_score_reg <= 2'b00;
  end

  always_ff @(posedge clk) begin
    if (ball_pos_reg[15:0] >= dimensions[15:0] ||  ball_pos_reg[15:0] <= 16'h001F) begin
      ball_vel_reg[15:0] <= ~ball_vel_reg[15:0] + 16'h01;
    end

    if ((ballPosition[31:16] >= rightPaddlePosition[31:16])) begin   // Right paddle logic
      if ((ballPosition[15:0] > rightPaddlePosition[15:0]) && (ballPosition[15:0] < rightPaddlePosition[15:0] + PADDLE_HEIGHT)) begin
        ball_vel_reg[31:16] <= ~ball_vel_reg[31:16] + 16'h01;
      end else begin
        player_score_reg[0] <= 1'b1;
      end
    end

    if ((ballPosition[31:16] <= leftPaddlePosition[31:16])) begin     // Left paddle logic
      if ((ballPosition[15:0] > leftPaddlePosition[15:0]) && (ballPosition[15:0] < leftPaddlePosition[15:0] + PADDLE_HEIGHT)) begin
        ball_vel_reg[31:16] <= ~ball_vel_reg[31:16] + 16'h01;
      end else begin
        player_score_reg[1] <= 1'b1;
      end
    end 

    ball_pos_reg[31:16] = ball_pos_reg[31:16] + ball_vel_reg[31:16];
    ball_pos_reg[15:0] = ball_pos_reg[15:0] + ball_vel_reg[15:0];
  end

  assign playerDidScore = player_score_reg;
  assign ballVelocityOut = ball_vel_reg;
  assign ballPositionOut = ball_pos_reg;
endmodule

