module exp09(clk,clk_ls,hsync,vsync,vga_sync_n,valid,vga_r,vga_g,vga_b,index);
input clk;
reg [7:0] ascii;
output clk_ls,hsync,vsync,vga_sync_n,valid;
output [7:0] vga_r,vga_g,vga_b;

assign vga_sync_n = 0;
output reg [11:0] index = 420;

reg [11:0] position;
reg [11:0] pos [3:0];
reg [7:0] falling_ascii [3:0];
reg [3:0] valid_fall;

reg [23:0] data = 0;
reg [11:0] block_addr = 0;
reg [11:0] addr;

reg [1:0] status = 0;
//reg wren = 0;
wire [9:0] h_addr,v_addr;
wire [7:0] vga_ret;
wire [8:0] font_ret;
wire [7:0] waste;

wire clk_rand2;
wire clk_rand3;
wire [7:0] rand1;
wire [7:0] rand2;
wire [7:0] rand3;
wire [7:0] rand_ascii = rand1 % 8'd26 + 8'h41;
wire [7:0] rand_pos = rand2 % 8'd71;
wire [7:0] rand_next = rand3 % 8'd20;    // if rand_next == 10 then generate the next char

clkgen #25000000 c(clk,1'b0,1'b1,clk_ls);
clkgen #1290784 c3(clk,1'b0,1'b1,clk_rand2);
clkgen #892742 c4(clk, 1'b0, 1'b1, clk_rand3);
clkgen #10 c2(clk,1'b0,1'b1,clk_10);
vga_ctrl v(.pclk(clk_ls),.reset(1'b0),.vga_data(data),.h_addr(h_addr),.v_addr(v_addr),.hsync(hsync),.vsync(vsync),.valid(valid),.vga_r(vga_r),.vga_g(vga_g),.vga_b(vga_b));
//ram_vga my_ram_vga(.address(block_addr),.clock(clk_ls),.data(ascii),.wren(wren),.q(vga_ret));
//ram2_vga my_ram2_vga(block_addr,index,clk_ls,1'b0,ascii,1'b0,1'b1,vga_ret,waste);
ram3 my_ram3(block_addr,position,clk_ls,clk_ls,1'b0,ascii,1'b0,1'b1,vga_ret,waste);
rom_font my_rom_font(.address(addr),.clock(clk_ls),.q(font_ret));
LFSR rand_gen(1, clk, rand1);
LFSR rand_gen2(1, clk_rand2, rand2);
LFSR rand_gen3(1, clk_rand3, rand3);

//light(addr,HEX2,HEX1,HEX0,1'b1);

initial begin
    /*pos[0] = 8'd20;
    pos[1] = 8'd40;
    falling_ascii[0] = 8'h41;
    falling_ascii[1] = 8'h42;*/
    valid_fall[0] = 0;
    valid_fall[1] = 0;
    falling_ascii[0] = 8'h0;
    falling_ascii[1] = 8'h0;
    valid_fall[2] = 0;
    valid_fall[3] = 0;
end


always @ (clk_ls)
begin
    block_addr <= (v_addr / 16) * 70 + ((h_addr-4) / 9);
    addr <= (vga_ret << 4) + (v_addr % 16);
    if(font_ret[h_addr%9] == 1'b1) data <= 24'hffffff;
    else data <= 24'h000000;
end

reg [4:0] counter = 0;
always @ (posedge clk_ls)
begin
    if(clk_10)
    begin
        if ( counter <= 4 && valid_fall[counter]) begin
            case(status)
                2'd0:
                begin
                    status <= 2'd1;
                    ascii <= 8'h0;
                    position <= pos[counter];
                end
                2'd1:
                begin
                    status <= 2'd2;
                    if ( pos[counter] + 70 <= 2100 ) begin
								ascii <= falling_ascii[counter];
                        pos[counter] = pos[counter] + 70;
                    end else begin
								ascii <= 0;
						     valid_fall[counter] <= 0;
						  end
                    position <= pos[counter];
                end	
                2'd2:
                begin
                    status <= 2'd0;
                    counter <= counter + 1;
                end
            endcase
        end else if ( counter <= 4 ) begin
            if ( rand_next == 8'd10 ) begin
                valid_fall[counter] <= 1;
                pos[counter] <= rand_pos;
                falling_ascii[counter] <= rand_ascii;
                counter <= counter + 1;
            end
        end
    end
    else counter <= 2'd0;
end

endmodule


