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

  function [10:0] sobelDotProduct (input logic isPositive, input logic [7:0] vector [-1:1]);
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
        for (int i =-1; i<= COL_NUM; i++) begin
          topRowCache[i] <= 0;
          middleRowCache[i] <= 0;
          bottomRowCache[i] <= 0;
      	end
      end else begin
        if (nextPixelx == 0) begin
          topRowCache <= middleRowCache;
          middleRowCache <= bottomRowCache;
          for (int i = -1; i<= COL_NUM; i++) begin
            bottomRowCache[i] <= 0;
          end
          bottomRowCache[0] <= pixel;
        end else if (nextPixelx < COL_NUM) begin
          bottomRowCache[nextPixelx] <= pixel;
        end
      end
    end
    if (rst == 1'b1) begin
      for (int i =-1; i<= COL_NUM; i++) begin
        topRowCache[i] <= 0;
        middleRowCache[i] <= 0;
        bottomRowCache[i] <= 0;
      end
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
        {nextPixelx, nextPixely} = (currentPixelx == ROW_NUM) ? {11'd0, currentPixely + 1}: {currentPixelx + 1, currentPixely} ;
      end
      SECOND_ROW: begin
        nextState = (currentPixelx == COL_NUM) ? MIDDLE_ROW : SECOND_ROW;
        {nextPixelx, nextPixely} = (currentPixelx == COL_NUM) ? {11'd0, currentPixely + 1}: {currentPixelx + 1, currentPixely};
      end
      MIDDLE_ROW: begin
        nextState = (currentPixelx == COL_NUM) && (currentPixely == (ROW_NUM-1)) ? TERMINATE_ROW : MIDDLE_ROW;
        {nextPixelx, nextPixely} = (currentPixelx == COL_NUM) ? {11'd0, currentPixely+1} : {currentPixelx + 1, currentPixely};
      end
      TERMINATE_ROW: begin
        nextState = (currentPixelx == COL_NUM) ? IDLE : TERMINATE_ROW;
        {nextPixelx, nextPixely} = (currentPixelx == COL_NUM) ? {11'd0, 11'd0}: {currentPixelx + 1, currentPixely};
      end
    endcase
  end

  always_comb begin : SOBEL_PIXEL_INTERFACE
    for (int i = -1; i<=1; i++) begin
      sobelPixels[i][-1] = bottomRowCache[currentPixelx+i];
      sobelPixels[i][0] = middleRowCache[currentPixelx+i];
      sobelPixels[i][1] = topRowCache[currentPixelx+i];
    end
  end

  always_comb begin : EDGE_COMPUTE_INTERFACE
    logic [10:0] gx_tmp, gy_tmp;
    gx_tmp = sobelDotProduct(1'b0, {sobelPixels[-1][-1], sobelPixels[-1][0], sobelPixels[-1][1]}) + sobelDotProduct(1'b1, {sobelPixels[1][-1], sobelPixels[1][0], sobelPixels[1][1]});
    gy_tmp = sobelDotProduct(1'b0, {sobelPixels[-1][-1], sobelPixels[0][-1], sobelPixels[1][-1]}) + sobelDotProduct(1'b1, {sobelPixels[-1][1], sobelPixels[0][1], sobelPixels[1][1]});
    gx = (gx_tmp[10] == 1'b1) ? ~gx_tmp +'d1 : gx_tmp;
    gy = (gy_tmp[10] == 1'b1) ? ~gy_tmp +'d1 : gy_tmp;
    finalPixel = gx + gy;
  end

  assign sync = ((currentPixelx == COL_NUM) || (currentPixely == ROW_NUM)) ? 1'b1 : 1'b0;
  assign readValid = readValidReg;
  assign pixel_out = finalPixel;
  assign {next_pixel_x, next_pixel_y} = {nextPixelx, nextPixely};
  assign {pixel_out_x, pixel_out_y} =  {currentPixelx-1, currentPixely-1};
endmodule