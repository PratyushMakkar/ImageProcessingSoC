localparam ROW_NUM = 480;
localparam COL_NUM = 640;

class ImagePixelPacket;
  rand logic [7:0] pixels [-2:COL_NUM][-2:ROW_NUM];
  logic signed [10:0]  pixelEdges [-2:COL_NUM][-2:ROW_NUM];
  
  function logic [7:0] returnPixel(input logic [10:0] x, input logic [10:0] y);
    returnPixel = pixels[x][y];
    $display("The incoming pixel is %0d", returnPixel);
  endfunction
  
  function logic [10:0] returnIntendedPixel(input logic signed [10:0] x, input logic signed [10:0] y);
    returnIntendedPixel = pixelEdges[x][y];
  endfunction
  
  function setEdges();
    for (int i = -2; i<= ROW_NUM; i = i+1) begin
      for (int j = -2; j<= COL_NUM; j = j+1) begin
        if ((i<0) || (j<0) || (i== ROW_NUM) || (j== COL_NUM)) begin
          pixelEdges[i][j] = 0;
        end else begin
          pixelEdges[i][j] = {3'b000, pixels[i][j]};
        end
      end
    end
  endfunction
  
  function void computeEdges();
    for (int i = 0; i< ROW_NUM; i = i+1) begin
      for (int j = 0; j< COL_NUM; j = j+1) begin
        logic [10:0] gx_tmp, gy_tmp, gx, gy;
          gx_tmp = - $signed(pixelEdges[j-1][i-1]) 
        		        - ($signed(pixelEdges[j-1][i]) <<1) 
                    -  $signed(pixelEdges[j-1][i+1]) 
                    +  $signed(pixelEdges[j+1][i-1])
                    + ($signed(pixelEdges[j+1][i]) <<1) 	
                    + ($signed(pixelEdges[j+1][i+1]));

           gy_tmp = -  $signed(pixelEdges[j+1][i+1]) 
                    - ($signed(pixelEdges[j][i+1]) <<1) 
                    -  $signed(pixelEdges[j-1][i+1]) 
                    +  $signed(pixelEdges[j+1][i-1])
                    + ($signed(pixelEdges[j][i-1]) <<1) 	
                    + ($signed(pixelEdges[j-1][i-1]));

        gx = (gx_tmp[10] == 1'b1) ? ~gx_tmp +1 : gx_tmp;
        gy = (gy_tmp[10] == 1'b1) ? ~gy_tmp +1 : gy_tmp;
       pixelEdges[j][i] = gx + gy;
      end
    end
  endfunction

endclass	

module EdgeDetectionTestbench();
  
  ImagePixelPacket pkt;
  
  logic clk;
  logic rst, en, waitrequest;
  logic [7:0] pixel;
  
  logic readValid, sync;
  logic signed [10:0] pixelOutx, pixelOuty;
  logic signed [10:0] nextPixelx, nextPixely;
  logic signed [10:0] pixelOut;
  
  parameter ROW_NUM = 480;
  parameter COL_NUM = 640;
  
  EdgeDetectionTop top (
    .clk(clk),
    .rst(rst),
    .en(en),
    .waitrequest(waitrequest),
    .pixel(pixel),
    .readValid(readValid),
    .sync(sync),
    .pixel_out_x(pixelOutx),
    .pixel_out_y(pixelOuty),
    .next_pixel_x(nextPixelx),
    .next_pixel_y(nextPixely),
    .pixel_out(pixelOut)
  );
  
  
  initial begin 
    clk = 1'b1;
    rst = 1'b0;
    en = 1'b0;
    waitrequest = 1'b0;
    pixel = 0;
    
    pkt = new();
    pkt.randomize();
    pkt.setEdges();
    pkt.computeEdges();
    
    ToggleClock;
    en = 1'b1;
    for (int i = 0; i<10; i = i+1) begin
      if (!sync) begin
        pixel = pkt.returnPixel(nextPixelx, nextPixely);
        $display("The intended pixel is %0d", pkt.returnIntendedPixel(pixelOutx, pixelOuty));
        ToggleClock;
        $display("The out pixel is %0d", pixelOut);
      end
    end
  end
  
  task ToggleClock();
    #2
    clk = ~clk;
    #2
    clk = ~clk;
  endtask
  

endmodule