module mem_controller #(
  parameter FIFO_WIDTH = 8
) (
  input clk,
  input rst,
  input rx_fifo_empty,
  input tx_fifo_full,
  input [FIFO_WIDTH-1:0] din,

  output logic rx_fifo_rd_en,
  output logic tx_fifo_wr_en,
  output logic [FIFO_WIDTH-1:0] dout,
  output logic [5:0] state_leds
);

  localparam int MEM_WIDTH = 8;   // width of each memory entry
  localparam int MEM_DEPTH = 256; // number of entries
  localparam int NUM_BYTES_PER_WORD = MEM_WIDTH / 8;
  localparam int MEM_ADDR_WIDTH = $clog2(MEM_DEPTH);

  // Packet commands
  localparam logic [7:0] CMD_READ  = 8'd48;
  localparam logic [7:0] CMD_WRITE = 8'd49;

  // FSM states
  localparam logic [3:0] S_IDLE       = 4'd0;
  localparam logic [3:0] S_CMD_STORE  = 4'd1;
  localparam logic [3:0] S_WAIT_ADDR  = 4'd2;
  localparam logic [3:0] S_ADDR_STORE = 4'd3;
  localparam logic [3:0] S_WAIT_DATA  = 4'd4;
  localparam logic [3:0] S_DATA_STORE = 4'd5;
  localparam logic [3:0] S_PREP_WRITE  = 4'd6;
  localparam logic [3:0] S_PREP_READ   = 4'd7;
  localparam logic [3:0] S_WAIT_TX     = 4'd8;
  localparam logic [3:0] S_TX_WRITE    = 4'd9;

  logic [3:0] state_q, state_d;

  // Stored packet bytes
  logic [7:0] cmd_q,  cmd_d;
  logic [7:0] addr_q, addr_d;
  logic [7:0] data_q, data_d;

  logic cmd_ce, addr_ce, data_ce;

  // Memory interface
  logic [NUM_BYTES_PER_WORD-1:0] mem_we;
  logic [MEM_ADDR_WIDTH-1:0] mem_addr;
  logic [MEM_WIDTH-1:0] mem_din;
  logic [MEM_WIDTH-1:0] mem_dout;

  // Memory is read continuously from the stored address
  assign mem_addr = addr_q;
  assign mem_din   = data_q;
  assign dout      = mem_dout;
  assign mem_we    = (state_q == S_PREP_WRITE) ? 1'b1 : '0;

  SYNC_RAM_WBE #(
    .DWIDTH(MEM_WIDTH),
    .AWIDTH(MEM_ADDR_WIDTH)
  ) mem (
    .clk(clk),
    .en(1'b1),
    .wbe(mem_we),
    .addr(mem_addr),
    .d(mem_din),
    .q(mem_dout)
  );

  // State register
  REGISTER_R #(
    .N(4),
    .INIT(S_IDLE)
  ) state_reg (
    .q(state_q),
    .d(state_d),
    .rst(rst),
    .clk(clk)
  );

  // Byte registers
  REGISTER_R_CE #(
    .N(8),
    .INIT(8'd0)
  ) cmd_reg (
    .q(cmd_q),
    .d(din),
    .rst(rst),
    .ce(cmd_ce),
    .clk(clk)
  );

  REGISTER_R_CE #(
    .N(8),
    .INIT(8'd0)
  ) addr_reg (
    .q(addr_q),
    .d(din),
    .rst(rst),
    .ce(addr_ce),
    .clk(clk)
  );

  REGISTER_R_CE #(
    .N(8),
    .INIT(8'd0)
  ) data_reg (
    .q(data_q),
    .d(din),
    .rst(rst),
    .ce(data_ce),
    .clk(clk)
  );

  always_comb begin
    // defaults
    state_d       = state_q;
    rx_fifo_rd_en = 1'b0;
    tx_fifo_wr_en = 1'b0;

    cmd_ce  = 1'b0;
    addr_ce = 1'b0;
    data_ce = 1'b0;

    // debug LEDs
    state_leds = {2'b00, state_q};

    case (state_q)
      S_IDLE: begin
        // Wait for the first byte (command)
        if (!rx_fifo_empty) begin
          rx_fifo_rd_en = 1'b1;
          state_d = S_CMD_STORE;
        end
      end

      S_CMD_STORE: begin
        // Capture command byte from FIFO output
        cmd_ce = 1'b1;
        state_d = S_WAIT_ADDR;
      end

      S_WAIT_ADDR: begin
        // Wait for address byte to become available
        if (!rx_fifo_empty) begin
          rx_fifo_rd_en = 1'b1;
          state_d = S_ADDR_STORE;
        end
      end

      S_ADDR_STORE: begin
        // Capture address byte
        addr_ce = 1'b1;

        if (cmd_q == CMD_WRITE) begin
          state_d = S_WAIT_DATA;
        end
        else if (cmd_q == CMD_READ) begin
          state_d = S_PREP_READ;
        end
        else begin
          state_d = S_IDLE;
        end
      end

      S_WAIT_DATA: begin
        // Wait for data byte (write command only)
        if (!rx_fifo_empty) begin
          rx_fifo_rd_en = 1'b1;
          state_d = S_DATA_STORE;
        end
      end

      S_DATA_STORE: begin
        // Capture data byte
        data_ce = 1'b1;
        state_d = S_PREP_WRITE;
      end

      S_PREP_WRITE: begin
        // mem_we is asserted in this state
        // Synchronous write happens on the next rising edge
        state_d = S_IDLE;
      end

      S_PREP_READ: begin
        // Address is already stored in addr_q.
        // This state gives the synchronous RAM one cycle to produce mem_dout.
        state_d = S_WAIT_TX;
      end

      S_WAIT_TX: begin
        // Wait for space in TX FIFO
        if (!tx_fifo_full) begin
          tx_fifo_wr_en = 1'b1;
          state_d = S_TX_WRITE;
        end
      end

      S_TX_WRITE: begin
        // TX FIFO write occurs at the rising edge while wr_en is high
        state_d = S_IDLE;
      end

      default: begin
        state_d = S_IDLE;
      end
    endcase
  end

endmodule
