module fifo_ctrl (
    input  logic wr_en,
    input  logic rd_en,
    input  logic full,
    input  logic empty,
    output logic write_fire,
    output logic read_fire
);

    always_comb begin
        read_fire  = rd_en && !empty;
        write_fire = wr_en && (!full || read_fire);
    end

endmodule
