module VGADriver (
  input logic clk,
  input logic rst,
  input logic [23:0] colour_in,
  output logic [9:0] x_pixel,
  output logic [9:0] y_pixel,
  output logic hsync,
  output logic vscync,
  output logic [7:0] red,
  output logic [7:0] green,
  output logic [7:0] blue,
  output logic sync,
  output logic blank,
  output logic clkOut
);
  
  // Horizontel signal constants
  parameter HSYNC_ACTIVE  = 639;
  parameter HSYNC_FRONT_PORCH = 15;
  parameter HSYNC_SYNC_SIGN = 95;
  parameter HSYNC_BACK_PORCH = 47;
  
  //Vertical signal constants
  parameter VSYNC_ACTIVE  = 479;
  parameter VSYNC_FRONT_PORCH = 9;
  parameter VSYNC_SYNC_SIGN = 1;
  parameter VSYNC_BACK_PORCH = 32;
  
  parameter HIGH = 1'b1;
  parameter LOW = 1'b0;
  localparam [9:0] RESET_COUNTER = 0;
  
  typedef enum  {
    HSYNC_STATE_ACTIVE = 1,
    HSYNC_STATE_FRONT_PORCH = 2,
    HSYNC_STATE_SYNC_SIGN = 4,
    HSYNC_STATE_BACK_PORCH = 8
  } hsync_state_t; 
  
  typedef enum {
    VSYNC_STATE_ACTIVE = 1,
    VSYNC_STATE_FRONT_PORCH = 2,
    VSYNC_STATE_SYNC_SIGN = 4,
    VSYNC_STATE_BACK_PORCH = 8
  } vsync_state_t;
  
  hsync_state_t hsync_state = HSYNC_STATE_ACTIVE;
  hsync_state_t hsync_nextState;
  
  vsync_state_t vsync_state = VSYNC_STATE_ACTIVE;
  vsync_state_t vsync_nextState;
  
  logic [9:0] x_pixel_reg,
  logic [9:0] y_pixel_reg,
  logic       hsync_reg,
  logic       vscync_reg,
  logic [7:0] red_reg,
  logic [7:0] green_reg,
  logic [7:0] blue_reg,
  logic       sync_reg,
  logic       blank_reg,

  logic [9:0] hsync_count_reg = 0;
  logic [9:0] vsync_count_reg = 0;

  logic line_done = 1'b0;
  logic is_active;

  assign is_active = (hsync_state == HSYNC_STATE_ACTIVE) && (vsync_state == VSYNC_STATE_ACTIVE);
  
  always_ff @(posedge clk) begin
    if (rst == 1'b0) begin
      hsync_state <= HSYNC_STATE_ACTIVE;
      vsync_state <= VSYNC_STATE_ACTIVE;
    end else begin
      hsync_state <= hsync_nextState;
      vsync_state <= vsync_nextState;
    end
  end

  always_ff @(posedge clk) begin : HSYNC_VSYNC_COUNTER_LOGIC
    unique case (hsync_state) 
      HSYNC_STATE_ACTIVE: begin
        if (hsync_count_reg == HSYNC_ACTIVE) hsync_count_reg <= RESET_COUNTER;
        else hsync_count_reg <= hsync_count_reg + 1;
      end
      HSYNC_STATE_FRONT_PORCH: begin
        if (hsync_count_reg == HSYNC_FRONT_PORCH) hsync_count_reg <= RESET_COUNTER;
        else hsync_count_reg <= hsync_count_reg + 1;
      end
      HSYNC_STATE_SYNC_SIGN: begin
        if (hsync_count_reg == HSYNC_SYNC_SIGN) hsync_count_reg <= RESET_COUNTER;
        else hsync_count_reg <= hsync_count_reg + 1;
      end
      HSYNC_STATE_BACK_PORCH: begin
        if (hsync_count_reg == HSYNC_BACK_PORCH) hsync_count_reg <= RESET_COUNTER;
        else hsync_count_reg <= hsync_count_reg + 1;
      end
    endcase

    unique case (vsync_state) 
      VSYNC_STATE_ACTIVE: begin
        if (line_done == HIGH) begin
          vsync_count_reg <= (vsync_count_reg == VSYNC_ACTIVE) ? RESET_COUNTER : vsync_count_reg + 10'd1;
        end 
      end
      VSYNC_STATE_FRONT_PORCH: begin
        if (line_done == HIGH) begin
          vsync_count_reg <= (vsync_count_reg == VSYNC_FRONT_PORCH) ? RESET_COUNTER : vsync_count_reg + 10'd1;
        end
      end
      VSYNC_STATE_SYNC_SIGN: begin
        if (line_done == HIGH) begin
          vsync_count_reg <= (vsync_count_reg == VSYNC_SYNC_SIGN) ? RESET_COUNTER : vsync_count_reg + 10'd1;
        end
      end
      VSYNC_STATE_BACK_PORCH: begin
        if (line_done == HIGH) begin
          vsync_count_reg <= (vsync_count_reg == VSYNC_BACK_PORCH) ? RESET_COUNTER : vsync_count_reg + 10'd1;
        end 
      end
    endcase
  end

  // HSYNC combinational logic block
  always_comb begin : HORIZONTEL_SYNC_LOGIC_BLOCK
    unique case (hsync_state) 
      HSYNC_STATE_ACTIVE: begin
        line_done = LOW:
        hsync_nextState = (hsync_count_reg == HSYNC_ACTIVE) ? HSYNC_STATE_FRONT_PORCH : HSYNC_STATE_ACTIVE;
        hsync_reg = HIGH;
      end

      HSYNC_STATE_FRONT_PORCH: begin
        line_done = LOW:
        hsync_nextState = (hsync_count_reg == HSYNC_FRONT_PORCH) ? HSYNC_STATE_SYNC_SIGN : HSYNC_STATE_FRONT_PORCH;
        hsync_reg = HIGH;
      end

      HSYNC_STATE_SYNC_SIGN: begin
        line_done = LOW:
        hsync_nextState = (hsync_count_reg == HSYNC_STATE_SYNC_SIGN) ? HSYNC_STATE_BACK_PORCH : HSYNC_STATE_SYNC_SIGN;
        hsync_reg = LOW;
      end

      HSYNC_STATE_BACK_PORCH: begin
        line_done = (hsync_count_reg == HSYNC_BACK_PORCH) ? HIGH : LOW;
        hsync_nextState = (hsync_count_reg == HSYNC_BACK_PORCH) ? HSYNC_STATE_ACTIVE : HSYNC_STATE_BACK_PORCH;
        hsync_reg = HIGH;
      end
    endcase
  end

  always_comb begin : VERTICAL_SYNC_LOGIC_BLOCK
    unique case (vsync_state) 
      VSYNC_STATE_ACTIVE: begin
        vsync_reg = HIGH;
        if (line_done == HIGH) begin
          vsync_nextState = (vsync_count_reg == VSYNC_ACTIVE) ? VSYNC_STATE_FRONT_PORCH : VYSNC_STATE_ACTIVE;
        end else 
          vsync_nextState = VSYNC_STATE_ACTIVE
      end

      VSYNC_STATE_FRONT_PORCH: begin
        vsync_reg = HIGH;
        if (line_done == HIGH) begin
          vsync_nextState = (vsync_count_reg == VSYNC_FRONT_PORCH) ? VSYNC_STATE_SYNC_SIGN : VSYNC_STATE_FRONT_PORCH;
        end else 
          vsync_nextState = VSYNC_STATE_FRONT_PORCH;
      end

      VSYNC_STATE_SYNC_SIGN: begin
        vscync_reg = LOW;
        if (line_done == HIGH) begin
          vsync_nextState = (vsync_count_reg == VSYNC_STATE_SYNC_SIGN) ? VSYNC_STATE_BACK_PORCH : VSYNC_STATE_SYNC_SIGN;
        end else
          vsync_nextState = VSYNC_STATE_SYNC_SIGN;
      end

      VSYNC_STATE_BACK_PORCH: begin
        vsync_reg = HIGH;
        if (line_done == HIGH) begin
          vsync_nextState = (vsync_count_reg == VSYNC_STATE_SYNC_SIGN) ? VSYNC_STATE_ACTIVE : VSYNC_STATE_BACK_PORCH;
        end else 
          vsync_nextState = VSYNC_STATE_BACK_PORCH;
      end
    endcase
  end

  always_comb begin : RGB_REGISTER_ASSIGNMENT
    if (hsync_state == HSYNC_STATE_ACTIVE) begin
      x_pixel_reg = (hsync_count_reg == HSYNC_ACTIVE) ? RESET_COUNTER : (hsync_count_reg +1);
    end else x_pixel_reg = RESET_COUNTER;

    if (vsync_state == VSYNC_STATE_ACTIVE) begin
      x_pixel_reg = (vsync_count_reg == VSYNC_ACTIVE) ? RESET_COUNTER : (vsync_count_reg +1);
    end else y_pixel_reg = RESET_COUNTER;
      
    red_reg = is_active ? colour_in[23:16] : 8'h00;
    blue_reg = is_active ? colour_in[15:8] : 8'h00;
    green_reg = is_active ? colour_in[7:0] : 8'h00;
    blank_reg = hsync_reg & vsync_reg;
    sync_reg = 1'b1;
  end

  assign clkOut = clk;
  assign x_pixel = x_pixel_reg;
  assign y_pixel = y_pixel_reg;
  assign red = red_reg;
  assign green = green_reg;
  assign blue = blue_reg;
  assign blank = blank_reg;
  assign sync = sync_reg;

  assign hsync = hsync_reg;
  assign vscync = vscync_reg;
endmodule