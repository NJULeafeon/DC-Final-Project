module LFSR(en, clk, out);
  input en;
  input clk;
  
  reg in = 1;
  output wire [7:0] out;
  
  Lab06_Register lfsr(.en(en),
                      .clk(clk),
							 .out(out),
							 .Selector(3'b101),
							 .in(in));
  
  always @ (posedge clk)
  begin
    if (out == 0)
	 in <= 1;
	 else
	 in <= out[4] ^ out[3] ^ out[2] ^ out[0];
  end

endmodule
