module PaddlePhysics(
  input logic clk,
  input logoc rst,
  input logic [31:0] ballPosition,
  input logic [15:0] ballVelocity,     
  input logic [31:0] leftPaddlePosition,
  input logic [31:0] rightPaddlePosition,
  output logic eventDidHappen,
  output logic [1:0] playerDidScore     // RL
  output logic [31:0] ballPositionOut,
  output logic [31:0] ballVelocityOut
);
  localparam PADDLE_HEIGHT 
  logic [15:0] ball_vel_reg;

  always_ff @(posedge clk) begin
    eventDidHappen <= 1'b0;
    playerDidScore <= 2'b00;

    if ((ballPosition[31:16] >= rightPaddlePosition[31:16])) begin   // Right paddle logic
      eventDidHappen <= 1'b1;   
      if ((ballPosition[15:0] > rightPaddlePosition[15:0]) && (ballPosition[15:0] < rightPaddlePosition[15:0] + PADDLE_HEIGHT)) begin
        ball_vel_reg[7:0] = ~ball_vel_reg[7:0] + 8'h01;
      end else begin
        playerDidScore[0] <= 1'b1;
      end
    end

    if ((ballPosition[31:16] <= leftPaddlePosition[31:16])) begin     // Left paddle logic
      eventDidHappen <= 1'b1; 
      if ((ballPosition[15:0] > leftPaddlePosition[15:0]) && (ballPosition[15:0] < leftPaddlePosition[15:0] + PADDLE_HEIGHT)) begin
        ball_vel_reg[15:8] = ~ball_vel_reg[15:8] + 8'h01;
        eventDidHappen <= 1'b1;
      end else begin
        playerDidScore[1] <= 1'b1;
      end
    end 

    //TODO Function to do signed addition on ball velcoity/position
    ball_pos_reg[15:0] = ball_pos_reg[15:0] + ball_vel_reg[7:0];
    ball_pos_reg[31:16] = ball_pos_reg[31:16] + ball_vel_reg[15:8];
  end 

  always_ff @(negedge rst) begin
    eventDidHappen <= 1'b0;
    playerDidScore <= 2'b00;
  end

endmodule