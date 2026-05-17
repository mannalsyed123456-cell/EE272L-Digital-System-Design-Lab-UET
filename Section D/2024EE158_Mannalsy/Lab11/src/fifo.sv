module fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 32,
    parameter POINTER_WIDTH = $clog2(DEPTH)
) (
    input clk, rst,

    // Write side
    input wr_en,
    input [WIDTH-1:0] din,
    output full,

    // Read side
    input rd_en,
    output logic [WIDTH-1:0] dout, // Changed to logic for clocked sequential assignment
    output empty
);

    reg [WIDTH-1:0] memory [DEPTH-1:0];
    reg [POINTER_WIDTH-1:0] wr_ptr = 0;
    reg [POINTER_WIDTH-1:0] rd_ptr = 0;
    reg [POINTER_WIDTH:0] count = 0; 

    // Status Flags
    assign empty = (count == 0);
    assign full  = (count == DEPTH);

    // Strictly synchronous control and data read logic
    always @(posedge clk) begin
        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0; count  <= 0;
            dout   <= 0;
        end else begin
            // Update output data register on a valid read edge safely
            if (rd_en && !empty) begin
                dout <= memory[rd_ptr];
            end

            case ({wr_en && !full, rd_en && !empty})
                2'b10: begin // Write Only
                    memory[wr_ptr] <= din;
                    wr_ptr <= wr_ptr + 1;
                    count  <= count + 1;
                end
                2'b01: begin // Read Only
                    rd_ptr <= rd_ptr + 1;
                    count  <= count - 1;
                end
                2'b11: begin // Simultaneous Write and Read
                    memory[wr_ptr] <= din;
                    wr_ptr <= wr_ptr + 1;
                    rd_ptr <= rd_ptr + 1;
                end
                default: ; // Safeguard configuration
            endcase
        end
    end

endmodule
