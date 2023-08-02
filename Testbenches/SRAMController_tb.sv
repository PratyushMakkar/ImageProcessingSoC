module SRAMTestbench();
  
logic clk;
logic rst;
logic read_en, wr_en;
logic [17:0] addr_in;
wire [15:0] data_bus;
logic [15:0] data_bus_reg = 0;

// Output signals from the DUT
logic read_valid, wr_valid;
logic read_busy, wr_busy;
logic ce_n, oe_n, we_n, lb_n, ub_n;
logic [17:0] addr_out;

localparam MAX_DATA_ACCESS_AWAIT = 11; 
localparam MAX_DATA_INVALID_AWAIT = 11;
localparam logic [17:0] ADDR_IN = 18'h3ffff;
  
localparam  WR_MIN_SETUP_TIME = 1;
localparam  WR_OUTPUT_IMP = 5;
localparam  WR_DATA_DISABLE_AWAIT = 1;

assign data_bus = read_valid ? 16'hzzz : data_bus_reg;

SRAMController sramController  (
  .clk(clk),
  .rst(rst),
  .read_en(read_en),
  .wr_en(wr_en),
  .address_inputs(addr_in),
  .dq(data_bus),
  .read_valid(read_valid),
  .wr_valid(wr_valid),
  .read_busy(read_busy),
  .wr_busy(wr_busy),
  .address_out(addr_out),
  .ce_n(ce_n),
  .oe_n(oe_n),
  .we_n(we_n),
  .lb_n(lb_n),
  .ub_n(ub_n)
);                           

initial begin
  read_en = 1'b0;
  wr_en = 1'b0;
  addr_in = 0;
  
  $dumpfile("dumb.vcd");
  $dumpvars(1);
  
  VerifyWrite;
end

task VerifyRead(); 
  begin
    wr_en = 1'b0;
    rst = 1'b0;
    clk = 1'b0;
    clk_toggle;
    assert({ce_n, oe_n, we_n, lb_n, ub_n} == 5'b11111);
    read_en = 1'b1;
    
    // We await the states until it gets to READ_VALID
    data_bus_reg = 16'hab04;
    addr_in = ADDR_IN;
    clk_toggle;
    assert(read_busy == 1'b1);
    assert(read_valid == 1'b0);
    assert({ce_n, oe_n, we_n, lb_n, ub_n} == 5'b00000);
    
    for (int i = 0; i< MAX_DATA_ACCESS_AWAIT+2; i = i+1) begin
      clk_toggle;
    end
    data_bus_reg = 16'hffff;
    assert(addr_out == ADDR_IN);
    assert(read_valid == 1'b1);
    assert(read_busy == 1'b1);
    clk_toggle;
    clk_toggle;
  end
endtask
  
task VerifyWrite(); 
  begin
    assert({read_busy, wr_busy} == 2'b00);
    rst = 1'b0;
    clk = 1'b0;
    clk_toggle;
    assert({ce_n, oe_n, we_n, lb_n, ub_n} == 5'b11111);
    
    wr_en = 1'b1;
    addr_in = ADDR_IN;
    data_bus_reg = 16'h2004;    // Begin to assert the data write away 
   
    clk_toggle;
    assert(wr_busy == 1'b1);
    assert(wr_valid == 1'b0);
    assert({ce_n, oe_n, we_n, lb_n, ub_n} == 5'b11111);
    for (int i = 0; i< +2; i = i+1) begin
      clk_toggle;
    end
    
    // We await the states until it gets to READ_VALID
    for (int i = 0; i<= WR_MIN_SETUP_TIME; i = i+1) begin
      clk_toggle;
    end
   
    assert(wr_busy == 1'b1);
    assert(wr_valid == 1'b0);
    assert({ce_n, oe_n, we_n, lb_n, ub_n} == 5'b01000);
    for (int i = 0; i<= WR_OUTPUT_IMP; i = i+1) begin
      clk_toggle;
    end
 	  assert(wr_busy == 1'b1);
    assert(wr_valid == 1'b1);
    
    wr_en = 1'b0;
    clk_toggle;
    for (int i = 0; i<= WR_DATA_DISABLE_AWAIT; i = i+1) begin
      clk_toggle;
    end
  end
endtask


// A full clock cycle
task clk_toggle();
  begin
    #0.5
    clk = 1'b1;
    #0.5
    clk = 1'b0;
  end
endtask

endmodule