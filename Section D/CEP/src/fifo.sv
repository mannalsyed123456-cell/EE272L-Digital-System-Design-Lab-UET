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
    output [WIDTH-1:0] dout,
    output empty
);

    localparam int COUNT_WIDTH = $clog2(DEPTH + 1);

    logic [POINTER_WIDTH-1:0] wr_ptr;
    logic [POINTER_WIDTH-1:0] rd_ptr;

    logic [COUNT_WIDTH-1:0] count;

    logic write_fire;
    logic read_fire;

    logic [WIDTH-1:0] mem_dout;

    assign empty = (count == 0);
    assign full  = (count == DEPTH);
    assign dout  = mem_dout;

    fifo_ctrl u_ctrl (
        .wr_en(wr_en),
        .rd_en(rd_en),
        .full(full),
        .empty(empty),
        .write_fire(write_fire),
        .read_fire(read_fire)
    );

    fifo_ptr #(
        .DEPTH(DEPTH),
        .POINTER_WIDTH(POINTER_WIDTH)
    ) u_wr_ptr (
        .clk(clk),
        .rst(rst),
        .advance(write_fire),
        .ptr(wr_ptr)
    );

    fifo_ptr #(
        .DEPTH(DEPTH),
        .POINTER_WIDTH(POINTER_WIDTH)
    ) u_rd_ptr (
        .clk(clk),
        .rst(rst),
        .advance(read_fire),
        .ptr(rd_ptr)
    );

    fifo_mem #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH),
        .POINTER_WIDTH(POINTER_WIDTH)
    ) u_mem (
        .clk(clk),
        .rst(rst),
        .wr_en(write_fire),
        .wr_ptr(wr_ptr),
        .din(din),
        .rd_en(read_fire),
        .rd_ptr(rd_ptr),
        .dout(mem_dout)
    );

    always_ff @(posedge clk) begin
        if (rst) begin
            count <= '0;
        end
        else begin
            if (write_fire && !read_fire)
                count <= count + 1'b1;
            else if (read_fire && !write_fire)
                count <= count - 1'b1;
            else
                count <= count;
        end
    end

endmodule
