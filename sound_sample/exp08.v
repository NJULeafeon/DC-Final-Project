module exp08(clk,ps2_clk,ps2_data,freq,volumn);
	input clk,ps2_clk,ps2_data;
	reg nextdata = 0;
	wire ready,overflow;
	output reg [15:0] freq; 
	reg flag = 0;
	output reg [4:0] volumn = 10;
	wire [7:0] code;
	reg [7:0] code_reg;
	
	ps2_keyboard p(.clk(clk),.clrn(1'b1),.ps2_clk(ps2_clk),.ps2_data(ps2_data),.data(code),.ready(ready),.nextdata_n(nextdata),.overflow(overflow));
	

	light l(.data(8'h78),.out_h(HEX1),.out_l(HEX0),.enable(1'b1));

	//clk_ls为原时钟周期的50倍
	reg [6:0] count_clk = 0;
	reg clk_ls = 0;
	always @ (posedge clk)
	begin
		if(count_clk == 50)
		begin
			count_clk <= 0;
			clk_ls <= ~clk_ls;
		end
		else
			count_clk <= count_clk + 1;
	end
	
	
	
	always @ (posedge clk_ls)
	begin
		if(ready) 
		begin
			nextdata <= 0;
			code_reg <= code;
			if(code == 8'hf0) flag <= 1;  //因为f0输出后还会增加一个通码，这会导致light_enable恢复到1
			else
			begin
				if(flag) 
				begin
					flag <= 0;
					code_reg <= 0;
					if(code == 8'h4c) volumn <= volumn - 1;
					if(code == 8'h52) volumn <= volumn + 1;
				end
			end
		end
		else nextdata <= 1;
	end
	
	always @ (code_reg)
	begin
	case(code_reg)
		8'h1c:freq = 16'd714;
		8'h1b:freq = 16'd801;
		8'h23:freq = 16'd900;
		8'h2b:freq = 16'd953;
		8'h34:freq = 16'd1070;
		8'h33:freq = 16'd1201;
		8'h3b:freq = 16'd1348;
		8'h42:freq = 16'd1428;
		default:freq = 16'd0;
	endcase
	end
	
endmodule