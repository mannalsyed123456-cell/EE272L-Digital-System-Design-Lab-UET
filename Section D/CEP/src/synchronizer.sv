module synchronizer(
    input logic async_sig,
    input logic clk, 
    output logic sync_sig
 );
    logic mid_sig;
 always_ff @( posedge clk )
 begin
    mid_sig <= async_sig;
 end


 always_ff @(posedge clk)
 begin
    sync_sig <= mid_sig;
 end

endmodule
