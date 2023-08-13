`include "SRAMController.sv"
module AvalonSRAM (
  input logic clk,
  input logic read_n,       
  input logic write_n,
  input logic chipselect,
  input logic [31:0] address,
  output logic [31:0] readData,
  input logic [31:0] writeData,
  input logic [3:0] byteEnable_n,
  output logic waitrequest,
 
  inout logic [15:0] dq_sram,             // Signals intended for SRAM
  output logic [17:0] address_sram,
  output logic ce_n_sram, oe_n_sram, we_n_sram, lb_n_sram, ub_n_sram
);

  //-----------------------------------Start of Avalon MM bus signals-----------------------//
  logic read_n_avalon_reg, write_n_avalon_reg;
  logic [31:0] address_n_avalon_reg;
  logic [31:0] readData_avalon_reg;
  logic [31:0] writeData_avalon_reg;
  logic [3:0] byteEnable_n_avalon_reg;
  // --------------------------------- End of Avalon MM bus signals ----------------------//

  //-----------------------------------Start of external SRAM interface signals-----------------------//
  logic read_n_avalon_reg, write_n_avalon_reg;
  logic [31:0] address_n_avalon_reg;
  logic [31:0] readData_avalon_reg;
  logic [31:0] writeData_avalon_reg;
  logic [3:0] byteEnable_n_avalon_reg;
  // --------------------------------- End of external SRAM interface signals ----------------------//

  //-----------------------------------Start of SRAM controller signals-----------------------//
  logic read_sram_reg, write_sram_reg;
  logic [17:0] address_sram_reg;
  logic rdValid_sram_reg, wrValid_sram_reg;
  logic [15:0] wrData_sram_reg, rdData_sram_reg;
  // --------------------------------- End of SRAM controller signals ----------------------//

  //-----------------------------------Start of internal signals-----------------------//
  logic read_n_avalon_reg, write_n_avalon_reg;
  logic [31:0] address_n_avalon_reg;
  logic [31:0] readData_avalon_reg;
  logic [31:0] writeData_avalon_reg;
  logic [3:0] byteEnable_n_avalon_reg;
  // --------------------------------- End of internal signals ----------------------//

  typedef enum {
    IDLE,
    READ_ZERO,
    READ_ONE,
    WRITE
  } avalon_state_t;
  avalon_state_t current_state, next_state;

  always_ff @(posedge clk) begin
    if (current_state == IDLE) begin
      address_reg <= address;
      byteEnable_reg_n <= byteEnable_n;
      read_n_reg <= read_n;
      chipselect_reg <= chipselect;
    end
  end

  always_comb begin
    unique case (current_state)
      IDLE: begin
        next_state = (chipselect && ~read_n) ? READ : IDLE;
      end
      READ: begin
        next_state = (chipselect && ~read_n) ? READ: IDLE;
      end
    endcase
  end

  SRAMController sramController (
    .clk(clk),
    .rst(rst),
    .read_en(~read_n),
    .wr_en(~write_n), 
    .address(address_in),
    .wr_data(wr_data),
    .read_valid(read_valid), 
    .wr_valid(wr_valid),
    .read_busy(read_busy)
    .wr_busy(wr_busy),
    .read_data(read_data),
  
    .dq_sram(dq_sram),             // Signals intended for SRAM
    .address_sram(address_sram),
    .ce_n_sram(ce_n_sram), 
    .oe_n_sram(oe_n_sram), 
    .we_n_sram(we_n_sram), 
    .lb_n_sram(lb_n_sram), 
    .ub_n_sram(ub_n_sram)
  );

  assign waitrequest = waitrequest_reg;
  assign readData = {read_data_avalon_reg_MSB, read_data_avalon_reg_LSB};

endmodule