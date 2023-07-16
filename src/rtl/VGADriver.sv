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
  parameter HYSNC_SYNC_SIGN = 95;
  parameter HSYNC_BACK_PORCH = 47;
  
  //Vertical signal constants
  parameter VSYNC_ACTIVE  = 479;
  parameter VSYNC_FRONT_PORCH = 9;
  parameter VerticalYSNC_SYNC_SIGN = 1;
  parameter VSYNC_BACK_PORCH = 32;
  
  parameter HIGH = 1'b1;
  parameter LOW = 1'b0;
  
  typedef enum  {
    HSYNC_STATE_ACTIVE = 1,
    HYSNC_STATE_FRONT_PORCH = 2,
    HYSNC_STATE_SYNC_SIGN = 4,
    HYSNC_STATE_BACK_PORCH = 8
  } hysnc_state_t; 
  
  typedef enum {
    VSYNC_STATE_ACTIVE = 1,
    VYSNC_STATE_FRONT_PORCH = 2,
    VYSNC_STATE_SYNC_SIGN = 4,
    VYSNC_STATE_BACK_PORCH = 8
  } vsync_state_t;
  
  hysnc_state_t hsync_state = HSYNC_STATE_ACTIVE;
  hysnc_state_t hsync_nextState;
  
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
  logic       clkOut_reg

  logic [9:0] hsync_count_reg;
  logic [9:0] vsync_count_reg;
  
  always_ff @(posedge clk) begin
    if (rst == 1'b0) begin
      hsync_state <= HSYNC_STATE_ACTIVE;
      vsync_state <= VSYNC_STATE_ACTIVE;
    end else begin
      hsync_state <= hsync_nextState;
      vsync_state <= vsync_nextState;
    end
  end

  // HSYNC combinational logic block
  always_comb begin : HORIZONTEL_SYNC_LOGIC_BLOCK
    unique case (hsync_state) 
      HSYNC_STATE_ACTIVE: begin

      end

      HYSNC_STATE_FRONT_PORCH: begin

      end

      HSYNC_STATE_SYNC_SIGN: begin

      end

      HYSNC_STATE_BACK_PORCH: begin

      end
    endcase
  end

  always_comb begin : VERTICAL_SYNC_LOGIC_BLOCK
    
  end

  always_comb begin : RGB_REGISTER_ASSIGNMENT
    
  end

endmodule