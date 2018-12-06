module exp09(clk,clk_ls,hsync,vsync,vga_sync_n,valid,vga_r,vga_g,vga_b,index, state, kbd_ascii, output_ascii,kbd_input,mode,sound);
input [1:0] state;
input mode;
input [7:0] kbd_ascii;
output reg kbd_input = 0;
reg [7:0] input_ascii;
reg [11:0] lowest_pos;
output reg [7:0] output_ascii;
input clk;
reg [7:0] ascii;
output clk_ls,hsync,vsync,vga_sync_n,valid;
output [7:0] vga_r,vga_g,vga_b;
output reg [15:0] sound;

assign vga_sync_n = 0;
output reg [11:0] index = 420;

reg [11:0] position;
reg [11:0] pos [4:0];
reg [7:0] falling_ascii [4:0];
reg [4:0] valid_fall;
reg [4:0] rev;

reg [23:0] data = 0;
reg [11:0] block_addr = 0;
reg [11:0] addr;

reg [1:0] status = 0;
reg [3:0] score_status = 0; 
reg [3:0] miss_status = 0;
reg [3:0] hit_status = 0;

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
wire [7:0] rand_ascii = rand1 % 8'd26 + 8'h61;
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

//----------rom for screen redraw-------------
wire [7:0] menu_value;
menu rom_menu(menu_screen,clk_ls,menu_value);
//--------------------------------------------

LFSR rand_gen(1, clk, rand1);
LFSR rand_gen2(1, clk_rand2, rand2);
LFSR rand_gen3(1, clk_rand3, rand3);


reg [10:0] score; //rightabove corner:score
reg [11:0] init_screen; //clear the screen
reg [11:0] menu_screen; //redraw the logo
reg [10:0] miss;
reg [10:0] hit;

initial begin
    /*pos[0] = 8'd20;
    pos[1] = 8'd40;
    falling_ascii[0] = 8'h41;
    falling_ascii[1] = 8'h42;*/
    valid_fall[0] = 0;
    valid_fall[1] = 0;
    falling_ascii[0] = 8'h0;
    falling_ascii[1] = 8'h0;
	 falling_ascii[2] = 8'h0;
    falling_ascii[3] = 8'h0;
	 falling_ascii[4] = 8'h0;
    valid_fall[2] = 0;
    valid_fall[3] = 0;
	 valid_fall[4] = 0;
    rev[0] = 0;
    rev[1] = 0;
    rev[2] = 0;
    rev[3] = 0;
	 init_screen = 0;
	 menu_screen = 0;
	 score = 0;
	 sound = 0;
	 miss = 0;
	 hit = 0;
end


always @ (posedge clk_ls)
begin
    block_addr <= (v_addr / 16) * 70 + ((h_addr-4) / 9);
    addr <= (vga_ret << 4) + (v_addr % 16);
    if(font_ret[h_addr%9] == 1'b1) 
	 begin
		if(block_addr >= 61 && block_addr <= 70)data <= 24'h00ff00;
		else data <= 24'hffffff;
	 end
    else data <= 24'h000000;
end

reg [4:0] counter = 0;
reg [4:0] triggered = 5;
reg [32:0] kbd_counter = 0;
always @ (posedge clk_ls)
begin
    if ( kbd_counter >= 2000000 ) begin
        if (state == 2'b01) begin
            kbd_input <= 1;
            input_ascii <= kbd_ascii;
            output_ascii <= kbd_ascii;
        end
        kbd_counter <= 0;
    end else kbd_counter <= kbd_counter + 1;
    if(clk_10)
    begin
	 
		  if(mode) begin //game mode
			  
				menu_screen <= 0;
				sound <= 0;
			  //---------------------screen erase----------------------
				if (init_screen != 2100) begin
					position <= init_screen;
					ascii <= 0;
					init_screen <= init_screen + 1;
				end
			  
			  //-------------------------------------------------------
	 
	 
	 
		
			  //---------------------char fall-------------------------
			   else if ( counter <= 4 && valid_fall[counter]) begin
					case(status)
						 2'd0:
						 begin
							  status <= 2'd1;
							  ascii <= 8'h0;
							  position <= pos[counter];
						 end
						 2'd1:
						 begin
							  if ( rev[counter] ) status <= 2'd3;
							  else status <= 2'd2;
						 end	
						 2'd2:
						 begin
							  if ( pos[counter] + 70 <= 2100 ) begin
							pos[counter] = pos[counter] + 70;
									ascii <= falling_ascii[counter];
							  end
							  else begin
									miss <= miss + 1;
									valid_fall[counter] <= 0;
									ascii <= 0;
									rev[counter] <= 0;
							  end
							  position <= pos[counter];
							  status <= 2'd0;
							  counter <= counter + 1;
						 end
						 2'd3:
						 begin
							  if ( pos[counter] >= 70 ) begin
									pos[counter] = pos[counter] - 70;
									ascii <= falling_ascii[counter];
							  end
							  else begin
									valid_fall[counter] <= 0;
									ascii <= 0;
									rev[counter] <= 0;
							  end
							  position <= pos[counter];
							  status <= 2'd0;
							  counter <= counter + 1;
						 end
					endcase
			  end else if ( counter <= 4 ) begin
					if ( rand_next == 8'd11 ) begin
						 valid_fall[counter] <= 1;
						 pos[counter] <= rand_pos;
						 falling_ascii[counter] <= rand_ascii;
						 counter <= counter + 1;
					end
			  end
			  //------------------end of char fall---------------
			  
			  
			  //----------score handler-----------
			  else if (score_status != 9) begin
					position <= 61 + score_status;
					case(score_status)
						4'd0:ascii <= 83;
						4'd1:ascii <= 67;
						4'd2:ascii <= 79;
						4'd3:ascii <= 82;
						4'd4:ascii <= 69;
						4'd5:ascii <= 58;
						4'd6:ascii <= (score / 100) % 10 + 48;
						4'd7:ascii <= (score / 10) % 10 + 48;
						4'd8:ascii <= score % 10 + 48;
					endcase
					score_status <= score_status + 1;
				end
				//------end of score handler----------
				
				//----------hit count----------------
				else if (hit_status != 7) begin
					position <= 2023 + hit_status;
					case(hit_status)
						4'd0:ascii <= 72;
						4'd1:ascii <= 73;
						4'd2:ascii <= 84;
						4'd3:ascii <= 58;
						4'd4:ascii <= (hit / 100) % 10 + 48;
						4'd5:ascii <= (hit / 10) % 10 + 48;
						4'd6:ascii <= hit % 10 + 48;
					endcase
					hit_status <= hit_status + 1;
				end
				//----------end of hit count----------
				
				//---------miss count ---------------
				else if (miss_status != 8) begin
					position <= 2092 + miss_status;
					case(miss_status)
						4'd0:ascii <= 77;
						4'd1:ascii <= 73;
						4'd2:ascii <= 83;
						4'd3:ascii <= 83;
						4'd4:ascii <= 58;
						4'd5:ascii <= (miss / 100) % 10 + 48;
						4'd6:ascii <= (miss / 10) % 10 + 48;
						4'd7:ascii <= miss % 10 + 48;
					endcase
					miss_status <= miss_status + 1;
				end
				//----------end of miss count----------
				
				
				
		  end //end of if(mode) begin
		  
		  if(!mode) //menu screen mode
		  begin
		     init_screen <= 0;
			  
			  //---------------------menu_screen redraw---------------
				if (menu_screen != 2100) begin
					position <= menu_screen;
					ascii <= menu_value;
					menu_screen <= menu_screen + 1;
				end
			  
			  //-------------------------------------------------------
			  
		  end
    end
    else begin
		  score_status <= 0;
		  miss_status <= 0;
		  hit_status <= 0;
        if ( kbd_input ) begin
            if ( counter <= 4 && falling_ascii[counter] == input_ascii && valid_fall[counter] && rev[counter] == 0) begin
                lowest_pos <= pos[counter];
                triggered <= counter;
                counter <= counter + 1;
            end else if (counter > 4 ) begin
                if ( triggered <= 4 ) 
					 begin
						score <= score + 1;
						hit <= hit + 1;
						sound <= 1070;
					 end
                rev[triggered] <= 1;
                triggered <= 5;
                kbd_input <= 0;
            end else begin
					counter <= counter + 1;
				end
        end else begin
	        counter <= 2'd0;
        end
    end
end

endmodule


