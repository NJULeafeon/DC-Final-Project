module mykbd( clk, ps2_clk, ps2_data, state, ascii, ready);
	input clk, ps2_clk, ps2_data;
	reg clrn;

	output wire ready;
	
	parameter pressed = 2'b01, released = 2'b00, breakcode = 2'b10;
	wire [7:0] data;
	reg [7:0] rawcode;
	reg nextdata_n = 1;
	wire overflow;
	output reg [1:0] state = 0;
	
	reg [7:0] count = 0;
	reg en = 0;
	
	initial
	begin
		clrn = 1'b0; count = 1'b0; en = 1'b0;
		state = released;
	end
	
	ps2_keyboard kbd(.clrn(clrn),
						  .clk(clk),
						  .ps2_clk(ps2_clk),
						  .ps2_data(ps2_data),
						  .data(data),
						  .nextdata_n(nextdata_n),
						  .ready(ready),
						  .overflow(overflow));
						  
	always @ (posedge clk)
	begin
		if (overflow) clrn <= 1'b0;
		else clrn <= 1'b1;
		
		if (ready)
		begin
			case (state)
				released:
					begin
						rawcode <= data;
						state <= pressed;
						count <= count + 1;
					end
				pressed:
					begin
						if (data == 8'b11110000)
							begin
								state <= breakcode;
							end
					end
				breakcode:
					begin
						state <= released;
					end	
			endcase
			nextdata_n <= 1;
		end
		else
			nextdata_n <= 0;
	end
	
	output reg [7:0] ascii;
	
	always @ (state)
	begin
		case (state)
		released: en = 0;
		pressed: en = 1;
		breakcode: en = 0;
		endcase
		
		case (rawcode)
		/*
		8'h15: ascii = 8'h51;	//Q
		8'h1d: ascii = 8'h57;	//W
		8'h24: ascii = 8'h45;	//E
		8'h2d: ascii = 8'h52;	//R
		8'h2c: ascii = 8'h54;	//T
		8'h35: ascii = 8'h59;	//Y
		8'h3c: ascii = 8'h55;	//U
		8'h43: ascii = 8'h49;	//I
		8'h44: ascii = 8'h4f;	//O
		8'h4d: ascii = 8'h50;	//P				  	
		8'h1c: ascii = 8'h41;	//A
		8'h1b: ascii = 8'h53;	//S
		8'h23: ascii = 8'h44;	//D
		8'h2b: ascii = 8'h46;	//F
		8'h34: ascii = 8'h47;	//G
		8'h33: ascii = 8'h48;	//H
		8'h3b: ascii = 8'h4a;	//J
		8'h42: ascii = 8'h4b;	//K
		8'h4b: ascii = 8'h4c;	//L
		8'h1a: ascii = 8'h5a;	//Z
		8'h22: ascii = 8'h58;	//X
		8'h21: ascii = 8'h43;	//C
		8'h2a: ascii = 8'h56;	//V
		8'h32: ascii = 8'h42;	//B
		8'h31: ascii = 8'h4e;	//N
		8'h3a: ascii = 8'h4d;	//M
		8'h16: ascii = 8'h31;  //1
		8'h1e: ascii = 8'h32;  //2
		8'h26: ascii = 8'h33;  //3
		8'h25: ascii = 8'h34;  //4
		8'h2e: ascii = 8'h35;  //5
		8'h36: ascii = 8'h36;  //6
		8'h3d: ascii = 8'h37;  //7
		8'h3e: ascii = 8'h38;  //8
		8'h46: ascii = 8'h39;  //9
		8'h45: ascii = 8'h30;  //0
		8'h5a: ascii = 8'h20;  //<CR>*/
		
		8'h00: ascii = 8'h00;
8'h01: ascii = 8'h00;
8'h02: ascii = 8'h00;
8'h03: ascii = 8'h00;
8'h04: ascii = 8'h00;
8'h05: ascii = 8'h00;
8'h06: ascii = 8'h00;
8'h07: ascii = 8'h00;
8'h08: ascii = 8'h00;
8'h09: ascii = 8'h00;
8'h0A: ascii = 8'h00;
8'h0B: ascii = 8'h00;
8'h0C: ascii = 8'h00;
8'h0D: ascii = 8'h20;
8'h0E: ascii = 8'h60;
8'h0F: ascii = 8'h00;
8'h10: ascii = 8'h00;
8'h11: ascii = 8'h00;
8'h12: ascii = 8'h00;
8'h13: ascii = 8'h00;
8'h14: ascii = 8'h00;
8'h15: ascii = 8'h71;
8'h16: ascii = 8'h31;
8'h17: ascii = 8'h00;
8'h18: ascii = 8'h00;
8'h19: ascii = 8'h00;
8'h1A: ascii = 8'h7A;
8'h1B: ascii = 8'h73;
8'h1C: ascii = 8'h61;
8'h1D: ascii = 8'h77;
8'h1E: ascii = 8'h32;
8'h1F: ascii = 8'h00;
8'h20: ascii = 8'h00;
8'h21: ascii = 8'h63;
8'h22: ascii = 8'h78;
8'h23: ascii = 8'h64;
8'h24: ascii = 8'h65;
8'h25: ascii = 8'h34;
8'h26: ascii = 8'h33;
8'h27: ascii = 8'h00;
8'h28: ascii = 8'h00;
8'h29: ascii = 8'h20;
8'h2A: ascii = 8'h76;
8'h2B: ascii = 8'h66;
8'h2C: ascii = 8'h74;
8'h2D: ascii = 8'h72;
8'h2E: ascii = 8'h35;
8'h2F: ascii = 8'h00;
8'h30: ascii = 8'h00;
8'h31: ascii = 8'h6E;
8'h32: ascii = 8'h62;
8'h33: ascii = 8'h68;
8'h34: ascii = 8'h67;
8'h35: ascii = 8'h79;
8'h36: ascii = 8'h36;
8'h37: ascii = 8'h00;
8'h38: ascii = 8'h00;
8'h39: ascii = 8'h00;
8'h3A: ascii = 8'h6D;
8'h3B: ascii = 8'h6A;
8'h3C: ascii = 8'h75;
8'h3D: ascii = 8'h37;
8'h3E: ascii = 8'h38;
8'h3F: ascii = 8'h00;
8'h40: ascii = 8'h00;
8'h41: ascii = 8'h2C;
8'h42: ascii = 8'h6B;
8'h43: ascii = 8'h69;
8'h44: ascii = 8'h6F;
8'h45: ascii = 8'h30;
8'h46: ascii = 8'h39;
8'h47: ascii = 8'h00;
8'h48: ascii = 8'h00;
8'h49: ascii = 8'h2E;
8'h4A: ascii = 8'h2F;
8'h4B: ascii = 8'h6C;
8'h4C: ascii = 8'h3B;
8'h4D: ascii = 8'h70;
8'h4E: ascii = 8'h2D;
8'h4F: ascii = 8'h00;
8'h50: ascii = 8'h00;
8'h51: ascii = 8'h00;
8'h52: ascii = 8'h27;
8'h53: ascii = 8'h00;
8'h54: ascii = 8'h5B;
8'h55: ascii = 8'h3D;
8'h56: ascii = 8'h00;
8'h57: ascii = 8'h00;
8'h58: ascii = 8'h00;
8'h59: ascii = 8'h00;
8'h5A: ascii = 8'h20;
8'h5B: ascii = 8'h5D;
8'h5C: ascii = 8'h00;
8'h5D: ascii = 8'h5C;
8'h5E: ascii = 8'h00;
8'h5F: ascii = 8'h00;
8'h60: ascii = 8'h00;
8'h61: ascii = 8'h00;
8'h62: ascii = 8'h00;
8'h63: ascii = 8'h00;
8'h64: ascii = 8'h00;
8'h65: ascii = 8'h00;
8'h66: ascii = 8'h08;
8'h67: ascii = 8'h00;
8'h68: ascii = 8'h00;
8'h69: ascii = 8'h31;
8'h6A: ascii = 8'h00;
8'h6B: ascii = 8'h34;
8'h6C: ascii = 8'h37;
8'h6D: ascii = 8'h00;
8'h6E: ascii = 8'h00;
8'h6F: ascii = 8'h00;
8'h70: ascii = 8'h30;
8'h71: ascii = 8'h2E;
8'h72: ascii = 8'h32;
8'h73: ascii = 8'h35;
8'h74: ascii = 8'h36;
8'h75: ascii = 8'h38;
8'h76: ascii = 8'h00;
8'h77: ascii = 8'h00;
8'h78: ascii = 8'h00;
8'h79: ascii = 8'h2B;
8'h7A: ascii = 8'h33;
8'h7B: ascii = 8'h2D;
8'h7C: ascii = 8'h2A;
8'h7D: ascii = 8'h39;
8'h7E: ascii = 8'h00;
8'h7F: ascii = 8'h00;
8'h80: ascii = 8'h00;
8'h81: ascii = 8'h00;
8'h82: ascii = 8'h00;
8'h83: ascii = 8'h00;
8'h84: ascii = 8'h00;
8'h85: ascii = 8'h00;
8'h86: ascii = 8'h00;
8'h87: ascii = 8'h00;
8'h88: ascii = 8'h00;
8'h89: ascii = 8'h00;
8'h8A: ascii = 8'h00;
8'h8B: ascii = 8'h00;
8'h8C: ascii = 8'h00;
8'h8D: ascii = 8'h00;
8'h8E: ascii = 8'h00;
8'h8F: ascii = 8'h00;
8'h90: ascii = 8'h00;
8'h91: ascii = 8'h00;
8'h92: ascii = 8'h00;
8'h93: ascii = 8'h00;
8'h94: ascii = 8'h00;
8'h95: ascii = 8'h00;
8'h96: ascii = 8'h00;
8'h97: ascii = 8'h00;
8'h98: ascii = 8'h00;
8'h99: ascii = 8'h00;
8'h9A: ascii = 8'h00;
8'h9B: ascii = 8'h00;
8'h9C: ascii = 8'h00;
8'h9D: ascii = 8'h00;
8'h9E: ascii = 8'h00;
8'h9F: ascii = 8'h00;
8'hA0: ascii = 8'h00;
8'hA1: ascii = 8'h00;
8'hA2: ascii = 8'h00;
8'hA3: ascii = 8'h00;
8'hA4: ascii = 8'h00;
8'hA5: ascii = 8'h00;
8'hA6: ascii = 8'h00;
8'hA7: ascii = 8'h00;
8'hA8: ascii = 8'h00;
8'hA9: ascii = 8'h00;
8'hAA: ascii = 8'h00;
8'hAB: ascii = 8'h00;
8'hAC: ascii = 8'h00;
8'hAD: ascii = 8'h00;
8'hAE: ascii = 8'h00;
8'hAF: ascii = 8'h00;
8'hB0: ascii = 8'h00;
8'hB1: ascii = 8'h00;
8'hB2: ascii = 8'h00;
8'hB3: ascii = 8'h00;
8'hB4: ascii = 8'h00;
8'hB5: ascii = 8'h00;
8'hB6: ascii = 8'h00;
8'hB7: ascii = 8'h00;
8'hB8: ascii = 8'h00;
8'hB9: ascii = 8'h00;
8'hBA: ascii = 8'h00;
8'hBB: ascii = 8'h00;
8'hBC: ascii = 8'h00;
8'hBD: ascii = 8'h00;
8'hBE: ascii = 8'h00;
8'hBF: ascii = 8'h00;
8'hC0: ascii = 8'h00;
8'hC1: ascii = 8'h00;
8'hC2: ascii = 8'h00;
8'hC3: ascii = 8'h00;
8'hC4: ascii = 8'h00;
8'hC5: ascii = 8'h00;
8'hC6: ascii = 8'h00;
8'hC7: ascii = 8'h00;
8'hC8: ascii = 8'h00;
8'hC9: ascii = 8'h00;
8'hCA: ascii = 8'h00;
8'hCB: ascii = 8'h00;
8'hCC: ascii = 8'h00;
8'hCD: ascii = 8'h00;
8'hCE: ascii = 8'h00;
8'hCF: ascii = 8'h00;
8'hD0: ascii = 8'h00;
8'hD1: ascii = 8'h00;
8'hD2: ascii = 8'h00;
8'hD3: ascii = 8'h00;
8'hD4: ascii = 8'h00;
8'hD5: ascii = 8'h00;
8'hD6: ascii = 8'h00;
8'hD7: ascii = 8'h00;
8'hD8: ascii = 8'h00;
8'hD9: ascii = 8'h00;
8'hDA: ascii = 8'h00;
8'hDB: ascii = 8'h00;
8'hDC: ascii = 8'h00;
8'hDD: ascii = 8'h00;
8'hDE: ascii = 8'h00;
8'hDF: ascii = 8'h00;
8'hE0: ascii = 8'h00;
8'hE1: ascii = 8'h00;
8'hE2: ascii = 8'h00;
8'hE3: ascii = 8'h00;
8'hE4: ascii = 8'h00;
8'hE5: ascii = 8'h00;
8'hE6: ascii = 8'h00;
8'hE7: ascii = 8'h00;
8'hE8: ascii = 8'h00;
8'hE9: ascii = 8'h00;
8'hEA: ascii = 8'h00;
8'hEB: ascii = 8'h00;
8'hEC: ascii = 8'h00;
8'hED: ascii = 8'h00;
8'hEE: ascii = 8'h00;
8'hEF: ascii = 8'h00;
8'hF0: ascii = 8'h00;
8'hF1: ascii = 8'h00;
8'hF2: ascii = 8'h00;
8'hF3: ascii = 8'h00;
8'hF4: ascii = 8'h00;
8'hF5: ascii = 8'h00;
8'hF6: ascii = 8'h00;
8'hF7: ascii = 8'h00;
8'hF8: ascii = 8'h00;
8'hF9: ascii = 8'h00;
8'hFA: ascii = 8'h00;
8'hFB: ascii = 8'h00;
8'hFC: ascii = 8'h00;
8'hFD: ascii = 8'h00;
8'hFE: ascii = 8'h00;
8'hFF: ascii = 8'h00;

		default: ;
		endcase
	end
endmodule
