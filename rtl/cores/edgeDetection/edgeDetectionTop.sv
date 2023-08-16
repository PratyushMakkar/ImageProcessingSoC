// Code your design here
module EdgeDetectionTop (
  input logic clk,
  input logic rst,
  input logic en,
  input logic waitrequest,
  input logic [7:0] pixel,

  output logic readValid,
  output logic sync,                  // Signals the end of column
  output logic [10:0] pixel_out_x,
  output logic [10:0] pixel_out_y,    // The pixel being calculated
  output logic [10:0] next_pixel_x,    // The pixel needed
  output logic [10:0] next_pixel_y,
  output logic [10:0] pixel_out
);
	
  parameter ROW_NUM = 480;
  parameter COL_NUM = 640;

  function [10:0] sobelDotProduct (input logic isPositive, input logic [20:0] vector);
    logic [10:0] g;
    g = ({3'b000, vector[20:14]} << 1) + {3'b000, vector[13:7]} + {3'b000, vector[6:0]};
    sobelDotProduct = (isPositive == 1'b1) ? g : ~g +'d1;
  endfunction
  
  typedef enum {
    IDLE,
    FIRST_ROW,
    SECOND_ROW,
    MIDDLE_ROW,
    TERMINATE_ROW
  } edge_detection_state_t;

  edge_detection_state_t currentState = IDLE;
  edge_detection_state_t nextState;

  /*-------------------- Current and next col/row registers recieved by module --------*/
  logic signed [10:0] currentPixelx = 0;         
  logic signed [10:0] currentPixely = 0;
  logic signed [10:0] nextPixelx = 0;
  logic signed [10:0] nextPixely = 0;

  /*-------------------- Cache for rows ----------------------*/
  logic [7:0] topRowCache [-1:COL_NUM];
  logic [7:0] middleRowCache [-1:COL_NUM];
  logic [7:0] bottomRowCache [-1:COL_NUM];

  /*------------------------ Registers for each pixel----------*/
  logic [7:0] sobelPixels [-1:1][-1:1];
  logic [10:0] gx, gy;        
  logic [10:0] finalPixel;    // Unsigned

  /*------------------------ End of row/col logic ---------------*/
  logic readValidReg;
  logic [7:0] resetCache [-1:COL_NUM];
  logic signed [10:0] operator [-1:1];
  logic [10:0] gx_tmp, gy_tmp;

  always_comb begin
    for (logic signed [10:0]  i =-1; i<= 1; i= i+1) begin
      operator[i] = currentPixelx + i;
    end
  end

  always_comb begin
    for (int i = -1; i<= COL_NUM; i= i+1) begin
      resetCache[i] = 0;
    end
  end

  always_ff @(posedge clk) begin
    if (rst == 1'b1) begin
      currentState <= IDLE;
    end else begin
      if (waitrequest == 1'b0) begin
        currentState <= nextState;
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
    if (waitrequest == 1'b0) begin
      if (nextState == IDLE) begin
        topRowCache <= resetCache;
        middleRowCache <= resetCache;
        bottomRowCache <= resetCache;
      end else begin
        if (nextPixelx == 0) begin
          topRowCache <= middleRowCache;
          middleRowCache <= bottomRowCache;
          bottomRowCache <= resetCache;
          bottomRowCache[0] <= pixel;
        end else if (nextPixelx < COL_NUM) begin
          bottomRowCache[nextPixelx] <= pixel;
        end
      end
    end
    if (rst == 1'b1) begin
      topRowCache <= resetCache;
      middleRowCache <= resetCache;
      bottomRowCache <= resetCache;
    end 
  end

  always_comb begin : NEXT_STATE_INTERFACE
    readValidReg = ((currentPixely >= 1) && (currentPixely <= ROW_NUM)) && ((currentPixelx >= 1) && (currentPixelx <= COL_NUM)) ? 1'b1 : 1'b0;
    unique case (currentState)
      IDLE: begin
        nextState = (en == 1'b1) ? FIRST_ROW : IDLE;
        {nextPixelx, nextPixely} = 0;
      end
      FIRST_ROW: begin
        nextState = (currentPixelx == COL_NUM) ? SECOND_ROW : FIRST_ROW;
        nextPixelx = (currentPixelx == ROW_NUM) ? 'd0: currentPixelx + 1;
        nextPixely = (currentPixelx == ROW_NUM) ? currentPixely + 1: currentPixely;
      end
      SECOND_ROW: begin
        nextState = (currentPixelx == COL_NUM) ? MIDDLE_ROW : SECOND_ROW;
        nextPixelx =  (currentPixelx == COL_NUM) ? 'd0: currentPixelx + 1;
        nextPixely = (currentPixelx == COL_NUM) ? currentPixely + 1: currentPixely;
      end
      MIDDLE_ROW: begin
        nextState = (currentPixelx == COL_NUM) && (currentPixely == (ROW_NUM-1)) ? TERMINATE_ROW : MIDDLE_ROW;
        nextPixelx = (currentPixelx == COL_NUM) ? 'd0: currentPixelx + 1;
        nextPixely = (currentPixelx == COL_NUM) ? currentPixely+1 : currentPixely;
      end
      TERMINATE_ROW: begin
        nextState = (currentPixelx == COL_NUM) ? IDLE : TERMINATE_ROW;
        nextPixelx = (currentPixelx == COL_NUM) ? 'd0 : currentPixelx + 1;
       nextPixely = (currentPixelx == COL_NUM) ?  'd0: currentPixely;
      end
    endcase
  end

  always_comb begin : SOBEL_PIXEL_INTERFACE
    for (logic signed [10:0] i = -1; i<=1; i++) begin
      sobelPixels[i][-1] = bottomRowCache[operator[i]];
      sobelPixels[i][0] = middleRowCache[operator[i]];
      sobelPixels[i][1] = topRowCache[operator[i]];
    end
  end

  always_comb begin : EDGE_COMPUTE_INTERFACE
    gx_tmp = sobelDotProduct(1'b0, {sobelPixels[-1][-1], sobelPixels[-1][0], sobelPixels[-1][1]}) + sobelDotProduct(1'b1, {sobelPixels[1][-1], sobelPixels[1][0], sobelPixels[1][1]});
    gy_tmp = sobelDotProduct(1'b0, {sobelPixels[-1][-1], sobelPixels[0][-1], sobelPixels[1][-1]}) + sobelDotProduct(1'b1, {sobelPixels[-1][1], sobelPixels[0][1], sobelPixels[1][1]});
    gx = (gx_tmp[10] == 1'b1) ? ~gx_tmp + 1 : gx_tmp;
    gy = (gy_tmp[10] == 1'b1) ? ~gy_tmp + 1 : gy_tmp;
    finalPixel = gx + gy;
  end

  assign sync = ((currentPixelx == COL_NUM) || (currentPixely == ROW_NUM)) ? 1'b1 : 1'b0;
  assign readValid = readValidReg;
  assign pixel_out = finalPixel;
  assign {next_pixel_x, next_pixel_y} = {nextPixelx, nextPixely};
  assign pixel_out_x = (currentPixelx-1);
  assign pixel_out_y = (currentPixely-1);
 
endmodule