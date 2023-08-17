
`include "EdgeDetectionPackage.sv"
import EdgeDetectionPackage::*;
  
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
    for (int i = 0; i<5000; i = i+1) begin
      if (sync) begin
        ToggleClock;
        en = 1'b0;
      end else begin
        pixel = pkt.returnPixel(nextPixelx, nextPixely);
        ToggleClock;
      end
      
      if (readValid == 1'b1) begin
        if (pixelOut != pkt.returnIntendedPixel(pixelOutx, pixelOuty)) begin
          $display("Mismatch at index x - %0d, y - %0d", pixelOutx, pixelOuty); 
          $display("The intended pixel is %0d", pkt.returnIntendedPixel(pixelOutx, pixelOuty));
          $display("The displayed pixel was %0d", pixelOut);
          $finish;
        end
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