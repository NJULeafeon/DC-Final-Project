module exp09(clk,clk_ls,hsync,vsync,vga_sync_n,valid,vga_r,vga_g,vga_b,ascii,index);
	input clk;
	input [7:0] ascii;
	output clk_ls,hsync,vsync,vga_sync_n,valid;
	output [7:0] vga_r,vga_g,vga_b;
	
	assign vga_sync_n = 0;
	output reg [11:0] index = 420;
	
	reg [11:0] pos = 20;
	
	reg [23:0] data = 0;
	reg [11:0] block_addr = 0;
	reg [11:0] addr;
	//reg wren = 0;
	wire [9:0] h_addr,v_addr;
	wire [7:0] vga_ret;
	wire [8:0] font_ret;
	wire [7:0] waste;
	clkgen #25000000 c(clk,1'b0,1'b1,clk_ls);
	clkgen #10 c2(clk,1'b0,1'b1,clk_10);
	vga_ctrl v(.pclk(clk_ls),.reset(1'b0),.vga_data(data),.h_addr(h_addr),.v_addr(v_addr),.hsync(hsync),.vsync(vsync),.valid(valid),.vga_r(vga_r),.vga_g(vga_g),.vga_b(vga_b));
	//ram_vga my_ram_vga(.address(block_addr),.clock(clk_ls),.data(ascii),.wren(wren),.q(vga_ret));
	//ram2_vga my_ram2_vga(block_addr,index,clk_ls,1'b0,ascii,1'b0,1'b1,vga_ret,waste);
	ram3 my_ram3(block_addr,pos,clk_ls,clk_10,1'b0,8'h61,1'b0,1'b1,vga_ret,waste);
	rom_font my_rom_font(.address(addr),.clock(clk_ls),.q(font_ret));

	//light(addr,HEX2,HEX1,HEX0,1'b1);
	
	
	
	always @ (clk_ls)
	begin
		//if(ascii == 0)
		//begin
			//wren <= 0;
			block_addr <= (v_addr / 16) * 70 + ((h_addr-4) / 9);
			addr <= (vga_ret << 4) + (v_addr % 16);
			if(font_ret[h_addr%9] == 1'b1) data <= 24'hffffff;
			else data <= 24'h000000;
			
			//if(ascii != 0) index <= index + 1;
		//end
		//else
		//begin
			//block_addr <= index;
			//wren <= 1;
			/*
			if(ascii == 8'h5a) index 
			*/
		//end
	end
	
	always @ (posedge clk_10)
	begin
		if(ascii != 0) 
		begin
			if(ascii == 8'h0d) index <= index + 70 - (index % 70);  //130 : 130 + 70 - (130 % 70) 
			else if (ascii == 8'h08) index <= index - 1;
			else index <= index + 1;
		end
		if(index == 2099) index <= 0;
		
		pos <= pos + 70;
	end
endmodule


