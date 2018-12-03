module Lab06_Register(en, clk, Selector, in, set, out);
  input en;
  input in;
  input clk;
  input [7:0] set;
  input [2:0] Selector;
  output reg [7:0] out;
  
  always @ (posedge clk)
  begin
  if (en)
    case (Selector)
	   0: begin out <= 0; end
		1: begin out <= set; end
		2: begin out <= {1'b0, out[7:1]}; end
		3: begin out <= {out[6:0], 1'b0}; end
		4: begin out <= {out[7], out[7:1]}; end
		5: begin out <= {in, out[7:1]}; end
		6: begin out <= {out[0], out[7:1]}; end
		7: begin out <= {out[6:0], out[7]}; end
	 endcase 
  else
    out <= out;
  end
  
endmodule
