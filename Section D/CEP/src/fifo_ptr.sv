module fifo_ptr #(
    parameter int DEPTH = 32,
    parameter int POINTER_WIDTH = $clog2(DEPTH)
) (
    input  logic clk,
    input  logic rst,
    input  logic advance,
    output logic [POINTER_WIDTH-1:0] ptr
);

    always_ff @(posedge clk) begin
        if (rst) begin
            ptr <= '0;
        end
        else if (advance) begin
            if (ptr == DEPTH-1)
                ptr <= '0;
            else
                ptr <= ptr + 1'b1;
        end
    end

endmodule
