module SRAMController (
  // SRAM interface for the controller user
  input logic clk,
  input logic rst,
  input logic read_en, wr_en, 
  input logic [17:0] address,
  input logic wr_data,
  output logic read_valid, wr_valid,
  output logic read_busy, wr_busy,
  output logic read_data,

  inout logic dq_sram,             // Signals intended for SRAM
  output logic [17:0] address_sram,
  output logic ce_n_sram, oe_n_sram, we_n_sram, lb_n_sram, ub_n_sram
);

  parameter MAX_DATA_ACCESS_AWAIT = 0; //12 ns wait period until data valid
  parameter MAX_DATA_INVALID_AWAIT = 0;

  parameter WR_MIN_SETUP_TIME = 1;
  parameter WR_OUTPUT_IMP = 5;
  parameter WR_DATA_DISABLE_AWAIT = 1;

  localparam logic HIGH = 1'b1;
  localparam logic LOW = 1'b0;

  localparam logic [4:0] CONTROL_IDLE  = 5'b11111;
  localparam logic [4:0] CONTROL_READ  = 5'b00100;
  localparam logic [4:0] CONTROL_WRITE = 5'b01000;
  localparam logic [15:0] HIGH_IMPEDENCE_DATA = 16'hzzzz;


  // Local registers
  logic [17:0] addr_reg; 

  logic [15:0] dq_wr_reg;
  logic [15:0] dq_rd_reg;

  logic [4:0] command_reg;
  logic read_busy_reg, wr_busy_reg, read_valid_reg, wr_valid_reg;

  logic [7:0] clock_await_cnt = 8'h00;       // Not assigned in comb block. 
  logic [7:0] wr_clock_await_cnt = 8'h00;

  typedef enum {
    IDLE,
    READ_AWAIT, 
    READ_BUSY_VALID, // The data is valid 
    READ_BUSY_INVALID, // The data is invalid in this state

    WRITE_SETUP, 
    WRITE_AWAIT,  
    WRITE_BUSY_VALID,
    WRITE_TEARDOWN
  } SRAM_STATE_t;

  SRAM_STATE_t current_state = IDLE;
  SRAM_STATE_t next_state; 
	
  //Address and data are latched on the rising edge of the clocks. 
  always_ff @(posedge clk) begin
    if ((read_en == HIGH) || (wr_en == HIGH)) begin
      addr_reg <= address;
    end
    if (wr_en == HIGH) dq_wr_reg <= wr_data;              
  end

  // Clock count logic in a seperate FF block.
  always_ff @(posedge clk) begin
    if (next_state == READ_AWAIT || next_state == READ_BUSY_INVALID) clock_await_cnt <= clock_await_cnt +1;
    else clock_await_cnt <= 0;
  end

  always_comb begin
    read_valid_reg <= ((read_en == HIGH) && (current_state == READ_BUSY_VALID) && (clk == LOW));
    command_reg <= (read_en == HIGH) ? CONTROL_READ : (wr_en == HIGH ? CONTROL_WRITE : CONTROL_IDLE);
    dq_rd_reg <= ( (current_state == READ_BUSY_VALID) && (clk == LOW)) ? dq : HIGH_IMPEDENCE_DATA;
  
    unique case (current_state)
      IDLE: begin
        next_state <= (read_en == HIGH) ? ((MAX_DATA_ACCESS_AWAIT == 0) ? READ_BUSY_VALID : READ_AWAIT) : IDLE;
        {read_valid_reg, wr_valid_reg, wr_busy_reg, read_busy_reg} <= {LOW, LOW, LOW, LOW};
      end
      READ_AWAIT: begin
        next_state <= (clock_await_cnt == MAX_DATA_ACCESS_AWAIT) ? READ_BUSY_VALID : READ_AWAIT;
        {read_valid_reg, wr_valid_reg, wr_busy_reg, read_busy_reg} <= {LOW, LOW, LOW, HIGH};
      end
      READ_BUSY_VALID: begin
        read_valid_reg <= (read_valid_reg == HIGH) ? HIGH : ((clk == LOW) ? HIGH : LOW);
        {wr_valid_reg, wr_busy_reg, read_busy_reg} <= {LOW, LOW, HIGH};
        next_state <= (read_en == HIGH) ? READ_BUSY_VALID: ((MAX_DATA_INVALID_AWAIT == 0) ? IDLE: READ_BUSY_INVALID);
      end
      READ_BUSY_INVALID: begin
        next_state <= (clock_await_cnt == MAX_DATA_INVALID_AWAIT) ? IDLE : READ_BUSY_INVALID;
        {read_valid_reg, wr_valid_reg, wr_busy_reg, read_busy_reg} <= {LOW, LOW, LOW, HIGH};
      end
    endcase
  end

  assign address_sram = ((read_busy_reg == HIGH) || (write_busy == HIGH)) ? addr_reg : HIGH_IMPEDENCE_DATA;
  assign {ce_n, oe_n, we_n, lb_n, ub_n} = command_reg;
  assign dq_sram = HIGH_IMPEDENCE_DATA;  // The dq bus is driven to only when the ready is ready. 

  assign read_data = (read_valid_reg == HIGH) ? dq_rd_reg : HIGH_IMPEDENCE_DATA;
  assign {read_busy, write_busy, read_valid, wr_valid} = {read_busy_reg, wr_busy_reg, read_valid_reg, wr_valid_reg};
  
endmodule
