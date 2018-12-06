module exp08(clk,clrn,ps2_clk,ps2_data,ascii,code_reg, ready_out, state);
	parameter pressed = 2'b01, released = 2'b00, breakcode = 2'b10;
	input clk,clrn,ps2_clk,ps2_data;
	output [7:0] ascii;
	output reg [1:0] state;
	reg true = 1;
	reg [7:0] data_count = 0;
	reg nextdata = 0;
	reg flag = 1;
	reg CapsLock = 0;
	wire ready,overflow;
    output reg ready_out;
	wire [7:0] code;
	output reg [7:0] code_reg;
	reg light_enable = 0;
	
	ps2_keyboard p(.clk(clk),.clrn(clrn),.ps2_clk(ps2_clk),.ps2_data(ps2_data),.data(code),.ready(ready),.nextdata_n(nextdata),.overflow(overflow));
	
	rom_ascii r(.address(code_reg),.clock(clk),.q(ascii));

	//light l3(.data(data_count),.out_h(HEX5),.out_l(HEX4),.enable(true));
	//light l2(.data(ascii),.out_h(HEX3),.out_l(HEX2),.enable(light_enable));
	//light l(.data(code_reg),.out_h(HEX1),.out_l(HEX0),.enable(light_enable));

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
            ready_out <= ready;
			if(code == 8'hf0)
			begin
				data_count <= data_count + 1;
				flag <= 1;  //因为f0输出后还会增加一个通码，这会导致light_enable恢复到1
				state <= breakcode;
			end
			else
			begin
				if(flag) 
				begin
					light_enable <= 0;
					flag <= 0;
					code_reg <= 0;//清零用
					if(code == 8'h58) CapsLock = ~CapsLock;
					state <= released;
				end
				else
				begin
					light_enable <= 1;
					state <= pressed;
				end	
			end
			
		end
        else begin
            ready_out <= 0;
            nextdata <= 1;
        end
	end
	
	
endmodule
