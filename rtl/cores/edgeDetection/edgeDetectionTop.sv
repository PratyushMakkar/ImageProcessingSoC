module EdgeDetectionTop (
  input logic clk,
  input logic rst,
  input logic en,
  input logic waitrequest,
  input logic [7:0] pixel,

  output logic readValid,
  output logic sync,                  // Signals the end of column
  output logic [9:0] pixel_out_x,
  output logic [9:0] pixel_out_y,    // The pixel being calculated
  output logic [9:0] next_pixel_x,    // The pixel needed
  output logic [9:0] next_pixel_y,
  output logic [7:0] pixel_out
);

  parameter ROW_NUM = 480;
  parameter COL_NUM = 640;

  function [10:0] sobelDotProduct (input logic isPositive, input logic [7:0] vector [-1:1])
    logic [10:0] g;
    g = ({3'b000, vector[0]} << 1) + {3'b000, vector[1]} + {3'b000, vector[-1]};
    sobelDotProduct = (isPositive == 1'b1) ? g : ~g +'d1;
  endfunction
  
  typedef enum {
    IDLE,
    FIRST_ROW,
    SECOND_ROW,
    MIDDLE_ROW,
    TERMINATE_ROW
  } edge_detection_state_t;

  edge_detection_state_t currentState = NCOMPUTE_FIRST_ROW;
  edge_detection_state_t nextState;

  /*-------------------- Current and next col/row registers recieved by module --------*/
  logic [9:0] currentPixelx = 0;         
  logic [9:0] currentPixely = 0;
  logic [9:0] nextPixelx = 0;
  logic [9:0] nextPixely = 0;

  /*-------------------- Cache for rows ----------------------*/
  logic [7:0] topRowCache [COL_NUM-1:0];
  logic [7:0] middleRowCache [COL_NUM-1:0];
  logic [7:0] bottomRowCache [COL_NUM-1:0];

  /*------------------------ Registers for each pixel----------*/
  logic [7:0] sobelPixels [-1:1][-1:1];
  logic [7:0] nextSobelPixels [-1:1][-1:1];
  logic [10:0] gx, gy;        
  logic [10:0] finalPixel;    // Unsigned

  /*------------------------ End of row/col logic ---------------*/
  logic readValidReg;

  always_ff @(posedge clk) begin
    if (rst == 1'b1) begin
      currState <= IDLE;
    end else begin
      if (waitrequest == 1'b0) begin
        currState <= nextState;
      end
    end
  end

  always_ff @(posedge clk) begin : ROW_COL_LATCH
    if (rst == 1'b1) begin
      {currentPixelx, currentPixely} <= 'd0;
    end else begin
      if (waitrequest == 1'b0) begin
        {currentPixelx, currentPixely} <= {nextPixelx, nextPixely};
      end
    end
  end

  always_ff @(posedge clk) begin : ROW_CACHE_LATCH
    
  end

  always_ff @(posedge clk) begin : SOBEL_PIXEL_REGISTER_LATCH
    if (rst == 1'b0) begin
      for (i = -1; i<=1; i = i+1) begin
        for (j = -1; j <=1; j = j+1) begin
          sobelPixels[i][j] <= 8'd0;
        end
      end
    end else begin
      if (waitrequest == 1'b0) begin
        sobelPixels <= nextSobelPixels;
      end
    end
  end

  always_comb begin : NEXT_STATE_INTERFACE
    readValidReg = ((currentPixely >= 'd1) && (currentPixely <= ROW_NUM)) ? 1'b1 : 1'b0;
    unique case (currentState)
      IDLE: begin
        nextState = (en == 1'b1) ? FIRST_ROW : IDLE;
        {nextPixelx, nextPixely} = {'d0, 'd0};
      end
      FIRST_ROW: begin
        nextState = (currentPixelx == COL_NUM) ? SECOND_ROW : FIRST_ROW;
        {nextPixelx, nextPixely} = (currentPixelx == ROW_NUM) ? {'d0, currentPixely + 'd1}: {currentPixelx + 'd1, currentPixely} ;
      end
      SECOND_ROW: begin
        nextState = (currentPixelx == COL_NUM) ? MIDDLE_ROW : SECOND_ROW;
        {nextPixelx, nextPixely} = (currentPixelx == COL_NUM) ? {'d0, currentPixely + 'd1}: {currentPixelx + 'd1, currentPixely};
      end
      MIDDLE_ROW: begin
        nextState = (currentPixelx == COL_NUM) && (curr_pix_y == (ROW_NUM-1)) ? TERMINATE_ROW : MIDDLE_ROW;
        nextPixelx = (currentPixelx == COL_NUM) ? 'd0 : (currentPixelx + 'd1);
        nextPixely = (currentPixelx == COL_NUM) ? (currentPixely + 'd1) : currentPixely;
      end
      TERMINATE_ROW: begin
        nextState = (currentPixelx == COL_NUM) ? IDLE : TERMINATE_ROW;
        nextPixelx = (currentPixelx == COL_NUM) ? 'd0 : (currentPixelx + 'd1);
        nextPixely = (currentPixelx == COL_NUM) ? 'd0 : currentPixely;
      end
    endcase
  end

  always_comb begin : SOBEL_PIXEL_INTERFACE

  end

  always_comb begin : EDGE_COMPUTE_INTERFACE
    logic [10:0] gx_tmp, gy_tmp;
    gx_tmp = sobelDotProduct(1'b0, sobelPixels[-1][-1:1]) + sobelDotProduct(1'b1, sobelPixels[1][-1:1]);
    gy_tmp = sobelDotProduct(1'b0, sobelPixels[-1:1][-1]) + sobelDotProduct(1'b1, sobelPixels[-1:1][1]);
    gx = (gx_tmp[10] == 1'b1) : ~gx_tmp +'d1 : gx_tmp;
    gy = (gy_tmp[10] == 1'b1) : ~gy_tmp +'d1 : gy_tmp;
    finalPixel = gx + gy;
  end

  assign sync = ((currentPixelx == COL_NUM) || (currentPixely == ROW_NUM)) ? 1'b1 : 1'b0;
  assign readValid = readValidReg;
endmodule