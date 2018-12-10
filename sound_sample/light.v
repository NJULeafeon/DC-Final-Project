module light(data,out_h,out_l,enable);
	input [7:0] data;
	input enable;
	output reg [6:0] out_l,out_h;
	always @(*)
	begin
		if(enable)
		begin
			case(data[7:4])
					0: out_h=7'b1000000;
					1: out_h=7'b1111001;				
					2: out_h=7'b0100100;              
					3: out_h=7'b0110000;              
					4: out_h=7'b0011001;              
					5: out_h=7'b0010010;              
					6: out_h=7'b0000010;              
					7: out_h=7'b1111000;              
					8: out_h=7'b0000000;              
					9: out_h=7'b0010000;
					10: out_h=7'b0001000;
					11: out_h=7'b0000011;
					12: out_h=7'b1000110;
					13: out_h=7'b0100001;
					14: out_h=7'b0000110;
					15: out_h=7'b0001110;
					default: out_h=7'b1000000;
			endcase
			case(data[3:0])
					0: out_l=7'b1000000;
					1: out_l=7'b1111001;				
					2: out_l=7'b0100100;              
					3: out_l=7'b0110000;              
					4: out_l=7'b0011001;              
					5: out_l=7'b0010010;              
					6: out_l=7'b0000010;              
					7: out_l=7'b1111000;              
					8: out_l=7'b0000000;              
					9: out_l=7'b0010000;   
					10: out_l=7'b0001000;
					11: out_l=7'b0000011;
					12: out_l=7'b1000110;
					13: out_l=7'b0100001;
					14: out_l=7'b0000110;
					15: out_l=7'b0001110;
					default: out_l=7'b1000000;
			endcase		
		end
		else
		begin
			out_h = 7'b1111111;
			out_l = 7'b1111111;
		end
	end
endmodule