module binary_to_BCD_tb;

  logic [4:0] A1;
  logic [7:0] Y1; 

  binary_to_BCD MEA(
    .A (A1),
    .Y (Y1)
  ); 

  initial begin

    A1 = 5'b00000;  #10;
    A1 = 5'b11111;  #10;
    A1 = 5'b11100;  #10;

    $stop;
  end

endmodule
