module decoder_top (
    input  logic [2:0] a,
    input  logic [2:0] b,
    input  logic       c_in,
    input  logic [2:0] sel,
    output logic [6:0] seg,
    output logic [7:0] an
);

    logic [2:0] sum;
    logic       c_out;
    logic [3:0] result;

    ripple_carry u_ripple_carry (
        .a(a),
        .b(b),
        .c_in(c_in),
        .sum(sum),
        .c_out(c_out)
    );

    assign result = {c_out, sum};

    decoder_7seg u_decoder_7seg (
        .in(result),
        .seg(seg)
    );

    decoder_display_select u_display_select (
        .sel(sel),
        .an(an)
    );

endmodule
