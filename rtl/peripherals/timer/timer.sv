module Timer (
  input logic clk,
  input logic rst,
  input logic timer_rst,
  input logic [3:0] commmand,
  input logic wr_en, rd_en,
  input logic [31:0] wr_data,
  output logic [31:0] rd_data,
  output logic [31:0] timer
);

  //-----------------------------------Start of timer commands----------------------//
  localparam CONTROL = 4'h0;
  localparam COMPARE= 4'h1;
  localparam CAPTURE = 4'h2;
  localparam PRESCALER = 4'h3;

  localparam logic [7:0] CONTROL_DEFAULT = ;

  logic synchronous_timer_reset = 1'b0;
  logic [31:0] timer_reg, read_data;

  logic [7:0] control_reg;
  logic [31:0] capture_reg, comapre_reg, prescaler_reg;

  logic [7:0] control_sync;
  logic [31:0] capture_sync, compare_sync, prescaler_sync;

  always_comb begin : REGISTER_INTERFACE
    synchronous_timer_reset <= rd_en;

    if (rd_en == 1'b1) begin
      {control_sync, compare_sync, capture_sync, prescaler_sync} <= 128'd0;
      unique case (command)
        CONTROL: read_data <= control_reg;
        COMPARE: read_data <= comapre_reg;
        CAPTURE: read_data <= capture_reg;
        PRESCALER: read_data <= prescaler_reg;
      endcase
    end else if (wr_en == 1'b1) begin
      read_data <= 32'hzzzzzzz;
      unique case (command) 
        CONTROL: control_sync <= wr_data;
        COMPARE: compare_sync <= wr_data;
        CAPTURE: capture_sync <= wr_data;
        PRESCALER: prescaler_sync <= wr_data;
      endcase
    end else begin
      {control_sync, compare_sync, capture_sync, prescaler_sync} <= 128'd0;
      read_data <= 32'hzzzzzzz;
    end
  end

  always_ff @(posedge clk) begin : REGISTER_LATCH
    if (rst == 1'b1) begin
      control_sync <= CONTROL_DEFAULT;
      {comapre_reg, prescaler_sync, capture_sync} <= {32'd0, 32'd0, 32'd0};
    end else if (synchronous_timer_reset == 1'b1 || timer_rst == 1'b1) begin
      timer_reg <= 32'd0;
      case (command)
        CONTROL: control_reg <= control_sync;
        COMPARE: comapre_reg <= compare_sync;
        CAPTURE: capture_reg <= capture_sync;
        PRESCALER: prescaler_reg <= prescaler_sync;
        default: timer_reg <= 32'd0;
      endcase
    end 
  end
  
  assign rd_data = read_data;
  assign timer = timer_reg;
endmodule