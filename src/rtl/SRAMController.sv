module SRAMController (
  // SRAM interface for the controller user
  input logic clk,
  input logic rst,
  input logic read_en, wr_en, 
  input logic [17:0] address_inputs,
  inout logic [15:0] dq,
  output logic read_valid,
  output logic read_busy,
  output logic wr_busy,
  output logic [17:0] address_out,
  output logic ce_n, oe_n, we_n, lb_n, ub_n
);

  parameter MAX_DATA_ACCESS_AWAIT = 11; //12 ns wait period until data valid
  parameter MAX_DATA_INVALID_AWAIT = 11;

  localparam logic HIGH = 1'b1;
  localparam logic LOW = 1'b0;

  localparam logic [4:0] CONTROL_HIGH = 5'b11111;
  localparam logic [4:0] CONTROL_LOW = 5'b00000;
  localparam logic [15:0] HIGH_IMPEDENCE_DATA = 16'hzzzz;

  logic [17:0] read_addr_reg; 
  logic [15:0] dq_bus_reg;
  logic ce_n_reg, oe_n_reg, we_n_reg, lb_n_reg, ub_n_reg;
  logic read_busy_reg, wr_busy_reg, read_valid_reg;

  logic [7:0] clock_await_cnt = 8'h00;

  typedef enum {
    IDLE,
    READ_AWAIT, 
    READ_BUSY_VALID, // The data is valid 
    READ_BUSY_INVALID  // The data is invalid in this state
  } SRAM_STATE_t;

  SRAM_STATE_t current_state = IDLE;
  SRAM_STATE_t next_state; 
	
  // Register the address to hold it out if next state is read_await
  always_ff @(posedge clk) begin
    if (rst == HIGH) begin
      current_state <= READ_BUSY_INVALID;
    end else begin 
      if (next_state == READ_BUSY_VALID) dq_bus_reg <= dq;
      current_state <= next_state;
    end
  end

  always_ff @(posedge clk) begin
    if (rst == HIGH) clock_await_cnt <= 0;
    else if ((current_state == READ_AWAIT) || (current_state == READ_BUSY_INVALID)) clock_await_cnt <= clock_await_cnt +1;
    else clock_await_cnt <= 0;
  end

  //TODO set the value on dq
  always_comb begin
    read_addr_reg <= ((current_state == READ_BUSY_VALID) || (current_state == READ_AWAIT)) ? address_inputs : HIGH_IMPEDENCE_DATA;
    unique case (current_state)
      IDLE: begin
        next_state <= (read_en == HIGH) ? READ_AWAIT : IDLE;
        {ce_n_reg, oe_n_reg, we_n_reg, lb_n_reg, ub_n_reg} <= CONTROL_HIGH;
        read_valid_reg <= LOW;
        {read_busy_reg, wr_busy_reg} <= 2'b00;
      end
      READ_AWAIT: begin
        next_state <= (clock_await_cnt == MAX_DATA_ACCESS_AWAIT) ? ((read_en == HIGH) ? READ_BUSY_VALID : IDLE) : READ_AWAIT;
        {ce_n_reg, oe_n_reg, we_n_reg, lb_n_reg, ub_n_reg} <= CONTROL_LOW;
        read_valid_reg <= LOW;
        {read_busy_reg, wr_busy_reg} <= 2'b10;
      end
      READ_BUSY_VALID: begin
        next_state <= (read_en == HIGH) ? READ_BUSY_VALID : READ_BUSY_INVALID;
        {ce_n_reg, oe_n_reg, we_n_reg, lb_n_reg, ub_n_reg} <= CONTROL_LOW;
        read_valid_reg <= HIGH;
        {read_busy_reg, wr_busy_reg} <= 2'b10;
      end
      READ_BUSY_INVALID: begin
        next_state <= (clock_await_cnt == MAX_DATA_INVALID_AWAIT) ? IDLE : READ_BUSY_INVALID;
        {ce_n_reg, oe_n_reg, we_n_reg, lb_n_reg, ub_n_reg} <= CONTROL_HIGH;
        read_valid_reg <= LOW;
        {read_busy_reg, wr_busy_reg} <= 2'b10;
      end
    endcase
  end
  
  
  assign dq = (current_state == READ_BUSY_VALID) ? dq_bus_reg : HIGH_IMPEDENCE_DATA;
  assign {ce_n, oe_n, we_n, lb_n, ub_n} = {ce_n_reg, oe_n_reg, we_n_reg, lb_n_reg, ub_n_reg};
  assign address_out = read_addr_reg;
  assign {read_busy, wr_busy, read_valid} = {read_busy_reg, wr_busy_reg, read_valid_reg};

endmodule