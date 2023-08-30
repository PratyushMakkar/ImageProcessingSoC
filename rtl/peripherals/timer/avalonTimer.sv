`include "timer.sv"

module AvalonTimer (
  input logic clk,
  input logic rst,
  input logic read_n,       
  input logic write_n,
  input logic [31:0] address,
  output logic [31:0] readData,
  input logic [31:0] writeData,
  output logic irq
);

  parameter logic [1:0] TIM1_OFFSET = 2b'00;
  parameter logic [1:0] TIM2_OFFSET = 2b'01;
  parameter logic [1:0] TIM3_OFFSET = 2b'10;
  parameter logic [1:0] TIM4_OFFSET = 2b'11;

  logic [3:0] rst_reg = 4'd0;
  logic [3:0] rd_en_reg, wr_en_reg; 

  logic [31:0] read_data_reg [3:0];
  logic [31:0] tim_timers [3:0];
  logic [31:0] tim_address;
  logic [3:0] tim_interrupts; 

  logic [1:0] address_offset;

  assign address_offset = address[5:4];
  assign tim_address = {28'd0, address[3:0]};

  assign {rd_en_reg[3], rd_en_reg[2], rd_en_reg[1], rd_en_reg[0]}
    = {(((address_offset == TIM1_OFFSET) && (read_n == 1'b0)) ? 1'b1 : 1'b0),
      (((address_offset == TIM2_OFFSET) && (read_n == 1'b0)) ? 1'b1 : 1'b0),
      (((address_offset == TIM3_OFFSET) && (read_n == 1'b0)) ? 1'b1 : 1'b0),
      (((address_offset == TIM4_OFFSET) && (read_n == 1'b0)) ? 1'b1 : 1'b0)}

  assign {wr_en_reg[3], wr_en_reg[2], wr_en_reg[1], wr_en_reg[0]}
      = {(((address_offset == TIM1_OFFSET) && (write_n == 1'b0)) ? 1'b1 : 1'b0),
        (((address_offset == TIM2_OFFSET) && (write_n == 1'b0)) ? 1'b1 : 1'b0),
        (((address_offset == TIM3_OFFSET) && (write_n == 1'b0)) ? 1'b1 : 1'b0),
        (((address_offset == TIM4_OFFSET) && (write_n == 1'b0)) ? 1'b1 : 1'b0)}

  Timer TIM1 (
    .clk(clk),
    .rst(rst),
    .timer_rst(timer_rst_reg[0]),
    .command(tim_address),
    .wr_en(wr_en_reg[0]),
    .rd_en(rd_en_reg[0]),
    .wr_data(writeData),
    .rd_data(readData),
    .interrupt(interrupts[0])
  );

  Timer TIM2 (
    .clk(clk),
    .rst(rst),
    .timer_rst(timer_rst_reg[1]),
    .command(tim_address),
    .wr_en(wr_en_reg[1]),
    .rd_en(rd_en_reg[1]),
    .wr_data(writeData),
    .rd_data(readData),
    .interrupt(interrupts[1])
  );

  Timer TIM3 (
    .clk(clk),
    .rst(rst),
    .timer_rst(timer_rst_reg[2]),
    .command(tim_address),
    .wr_en(wr_en_reg[2]),
    .rd_en(rd_en_reg[2]),
    .wr_data(writeData),
    .rd_data(readData),
    .interrupt(interrupts[2])
  );

  Timer TIM4 (
    .clk(clk),
    .rst(rst),
    .timer_rst(timer_rst_reg[3]),
    .command(tim_address),
    .wr_en(wr_en_reg[3]),
    .rd_en(rd_en_reg[3]),
    .wr_data(writeData),
    .rd_data(readData),
    .interrupt(interrupts[3])
  );

  assign read_data = ((rd_en_reg[0] == 1'b1) ? read_data_reg[0]
                    : (rd_en_reg[1] == 1'b1) ? read_data_reg[1]
                    : (rd_en_reg[2] == 1'b1) ? read_data_reg[2]
                    : (rd_en_reg[3] == 1'b1) ? read_data_reg[3]
                    : 32'hzzzzzzz);

    assign irq = interrupts[3] | interrupts[2] | interrupts[1] | interrupts[0];
endmodule