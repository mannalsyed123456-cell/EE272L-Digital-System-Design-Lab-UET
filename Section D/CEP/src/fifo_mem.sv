module fifo_mem #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 32,
    parameter int POINTER_WIDTH = $clog2(DEPTH)
) (
    input  logic clk,
    input  logic rst,

    input  logic wr_en,
    input  logic [POINTER_WIDTH-1:0] wr_ptr,
    input  logic [WIDTH-1:0] din,

    input  logic rd_en,
    input  logic [POINTER_WIDTH-1:0] rd_ptr,

    output logic [WIDTH-1:0] dout
);

    logic [WIDTH-1:0] mem [0:DEPTH-1];

    always_ff @(posedge clk) begin
        if (rst) begin
            dout <= '0;
        end
        else begin
            if (wr_en)
                mem[wr_ptr] <= din;

            if (rd_en)
                dout <= mem[rd_ptr];
        end
    end

endmodule
