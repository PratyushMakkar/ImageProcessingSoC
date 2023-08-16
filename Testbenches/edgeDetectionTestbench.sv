module EdgeDetectionTestbench();
  logic clk;
  logic rst, en, waitrequest;
  logic [7:0] pixel;
  
  logic readValid, sync;
  logic [10:0] pixelOutx, pixelOuty;
  logic [10:0] nextPixelx, nextPixely;
  logic [10:0] pixelOut;
  
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
    
    ToggleClock;
    en = 1'b1;
    for (int i = 0; i<20; i = i+1) begin
      ToggleClock();
      $display("The pixel value is %b", nextPixelx);
    end
  end
  
  task ToggleClock();
    #2
    clk = ~clk;
    #2
    clk = ~clk;
  endtask
  

endmodule