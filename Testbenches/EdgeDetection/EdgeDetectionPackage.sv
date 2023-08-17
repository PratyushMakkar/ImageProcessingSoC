package EdgeDetectionPackage;

   localparam ROW_NUM = 480;
   localparam COL_NUM = 640;

  class ImagePixelPacket;
    rand logic [7:0] pixels [-2:COL_NUM][-2:ROW_NUM];
    logic signed [10:0]  pixelEdges [-2:COL_NUM][-2:ROW_NUM];

    function logic [7:0] returnPixel(input logic [10:0] x, input logic [10:0] y);
      returnPixel = pixels[x][y];
      //$display("The incoming pixel is %0d at x -  %0d and y -  %0d", returnPixel, x, y);
    endfunction

    function logic [10:0] returnIntendedPixel(input logic signed [10:0] x, input logic signed [10:0] y);
      returnIntendedPixel = pixelEdges[x][y];
    endfunction

    function setEdges();
      for (int i = -2; i<= ROW_NUM; i = i+1) begin
        for (int j = -2; j<= COL_NUM; j = j+1) begin
          if ((i<0) || (j<0) || (i== ROW_NUM) || (j== COL_NUM)) begin
            pixels[j][i] = 0;
          end 
        end
      end
    endfunction

    function void computeEdges();
      for (int i = -1; i< ROW_NUM; i = i+1) begin
        for (int j = -1; j< COL_NUM; j = j+1) begin
          logic [10:0] gx_tmp, gy_tmp, gx, gy;
          gx_tmp = - $signed({3'b000, pixels[j-1][i-1]}) 
          - ($signed({3'b000, pixels[j-1][i]}) <<1) 
          -  $signed({3'b000, pixels[j-1][i+1]}) 
          +  $signed({3'b000, pixels[j+1][i-1]})
          + ($signed({3'b000, pixels[j+1][i]}) <<1) 	
          + ($signed({3'b000, pixels[j+1][i+1]}));
          gy_tmp = -  $signed({3'b000, pixels[j+1][i+1]}) 
          - ($signed({3'b000, pixels[j][i+1]}) <<1) 
          -  $signed({3'b000, pixels[j-1][i+1]}) 
          +  $signed({3'b000, pixels[j+1][i-1]})
          + ($signed({3'b000, pixels[j][i-1]}) <<1) 	
          + ($signed({3'b000, pixels[j-1][i-1]}));
          gx = (gx_tmp[10] == 1'b1) ? ~gx_tmp +1 : gx_tmp;
          gy = (gy_tmp[10] == 1'b1) ? ~gy_tmp +1 : gy_tmp;
         pixelEdges[j][i] = gx + gy;
          if (j == 1 && i ==1) begin
            $display(gx);
            $display(gy);
          end
        end
      end
    endfunction

  endclass
endpackage