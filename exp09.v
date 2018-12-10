module exp09(clk,clk_ls,hsync,vsync,vga_sync_n,valid,vga_r,vga_g,vga_b, state, kbd_ascii, output_ascii,kbd_input,mode,sound,difficulty);
parameter waste_pos = 12'hfff;
input [1:0] state;
input difficulty;
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

reg [11:0] position;
reg [11:0] pos [70:0];
reg [7:0] falling_ascii [70:0];
reg [70:0] valid_fall;
reg [70:0] rev;
reg [5:0] ascii_num = 10;  //num of char on screen, intended for difficulty control and modification
reg [4:0] speed [70:0];
reg [4:0] speed_counter [70:0];

reg [23:0] data = 0;
reg [11:0] block_addr = 0;
reg [11:0] addr;

reg [1:0] status = 0;
reg [3:0] score_status = 0; 
reg [3:0] miss_status = 0;
reg [3:0] hit_status = 0;
reg [2:0] difficulty_status = 0;
reg [2:0] game_over_status = 0;
reg [3:0] time_status = 0;

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
wire [4:0] rand_speed = ( rand2 % 2'd3 ) * 2 + 6;

clkgen #25000000 c(clk,1'b0,1'b1,clk_ls);
clkgen #100 c6(clk,1'b0,1'b1,clk_100);
clkgen #1290791 c3(clk,1'b0,1'b1,clk_rand2);
clkgen #892747 c4(clk, 1'b0, 1'b1, clk_rand3);
clkgen #10 c2(clk,1'b0,1'b1,clk_10);
clkgen #1 c5(clk,1'b0,1'b1,clk_1);
vga_ctrl v(.pclk(clk_ls),.reset(1'b0),.vga_data(data),.h_addr(h_addr),.v_addr(v_addr),.hsync(hsync),.vsync(vsync),.valid(valid),.vga_r(vga_r),.vga_g(vga_g),.vga_b(vga_b));
//ram_vga my_ram_vga(.address(block_addr),.clock(clk_ls),.data(ascii),.wren(wren),.q(vga_ret));
//ram2_vga my_ram2_vga(block_addr,index,clk_ls,1'b0,ascii,1'b0,1'b1,vga_ret,waste);
ram3 my_ram3(block_addr,position,clk_ls,clk_ls,1'b0,ascii,1'b0,1'b1,vga_ret,waste);
rom_font my_rom_font(.address(addr),.clock(clk_ls),.q(font_ret));

//----------rom for screen redraw-------------
wire [7:0] menu_value;
menu rom_menu(menu_screen,clk_ls,menu_value);
//--------------------------------------------

//----------rom for game_over -------------
wire [7:0] game_over_value;
rom_game_over my_rom_game_over(game_over_screen,clk_ls,game_over_value);
//--------------------------------------------

LFSR rand_gen(1, clk, rand1);
LFSR rand_gen2(1, clk_rand2, rand2);
LFSR rand_gen3(1, clk_rand3, rand3);


reg [10:0] score; //rightabove corner:score
reg [11:0] init_screen; //clear the screen
reg [11:0] menu_screen; //redraw the logo
reg [11:0] game_over_screen; //draw game_over_screen
reg [6:0] timee; //time left
reg [10:0] miss;
reg [10:0] hit;
reg prev_difficulty;//difficulty at previous clock period. If difficulty changes, reset init_screen to 0 to clear the screen.

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
	 game_over_screen = 0;
	 score = 0;
	 miss = 0;
	 hit = 0;
	 timee = 20;
	 prev_difficulty = difficulty;
end

always @ (posedge clk_1)
begin
	if(mode) begin
		if(timee > 0) timee <= timee - 1;
		else if(timee == 0 && game_over_status == 0) game_over_status <= 3;
		else if(game_over_status > 1) game_over_status <= game_over_status -1;
		else if(game_over_status == 1) begin
			game_over_status <= 0;
			timee <= 20;	
		end
	end
end

always @ (posedge clk_ls)
begin
    block_addr <= (v_addr / 16) * 70 + ((h_addr-4) / 9);
    addr <= (vga_ret << 4) + (v_addr % 16);
    if(font_ret[h_addr%9] == 1'b1)
	 begin
		if(block_addr >= 61 && block_addr <= 70)data <= 24'h00ff00;
		else if(block_addr >= 133 && block_addr <= 140 && timee <= 5) data <= 24'hff0000;
		else if((block_addr >= 2023 && block_addr <= 2030) || (block_addr >= 2092 && block_addr <= 2100)) data <= 24'h0000ff;
		else data <= 24'hffffff;
	 end
    else data <= 24'h000000;
end

reg [4:0] counter = 0;
reg [4:0] triggered = 5;
reg [32:0] kbd_counter = 0;
reg kbd_ready = 1;
always @ (posedge clk_ls)
begin
    if (state == 2'b01 && kbd_ready) begin
        kbd_input <= 1;
        input_ascii <= kbd_ascii;
        output_ascii <= kbd_ascii;
        kbd_ready <= 0;
        kbd_counter <= 0;
    end else if ( kbd_ready == 0 ) begin
        if ( kbd_counter >= 1420000) begin
            kbd_ready <= 1;
				kbd_counter <= 0;
        end else begin
            kbd_counter <= kbd_counter + 1;
        end
    end
	 
	 
	 
    if(clk_100)
    begin
	 
		  if(mode) begin //game mode
			  
			   if(game_over_status == 0) begin
					if(timee == 20) score <= 0;
					menu_screen <= 0;
					game_over_screen <= 0;
					sound <= 0;
					
					if(difficulty != prev_difficulty) init_screen <= 0;
					prev_difficulty <= difficulty;
					if(difficulty == 1) ascii_num <= 10;
					else ascii_num <= 5;
				  //---------------------screen erase----------------------
					if (init_screen != 2100) begin
						position <= init_screen;
						ascii <= 0;
						init_screen <= init_screen + 1;
					end
				  
				  //-------------------------------------------------------
		 
		 
		 
			
				  //---------------------char fall-------------------------
					else if ( counter <= ascii_num - 1 && valid_fall[counter]) begin
						case(status)
							 2'd0:
							 begin
								  status <= 2'd1;
											ascii <= 8'h0;
                              if ( speed_counter[counter] < speed[counter] ) begin
                                  position <= waste_pos;
                              end else begin
                                  position <= pos[counter];
                              end
							 end
							 2'd1:
							 begin
								  if ( rev[counter] ) status <= 2'd3;
								  else status <= 2'd2;
							 end	
							 2'd2:
							 begin
                              if ( speed_counter[counter] < speed[counter] ) begin
                                  position = waste_pos;
                                  speed_counter[counter] <= speed_counter[counter] + 1;
                              end else if ( pos[counter] + 70 <= 2100 ) begin
                                  pos[counter] = pos[counter] + 70;
                                  ascii <= falling_ascii[counter];
                                  position <= pos[counter];
                                  speed_counter[counter] <= 0;
                              end else begin
									valid_fall[counter] <= 0;
									ascii <= 0;
									rev[counter] <= 0;
                                    position <= pos[counter];
                                    miss <= miss + 1;
							  end
							  status <= 2'd0;
							  counter <= counter + 1;
							 end
							 2'd3:
							 begin
                              if ( speed_counter[counter] < speed[counter] ) begin
                                  position = waste_pos;
                                  speed_counter[counter] <= speed_counter[counter] + 1;
                              end else if ( pos[counter] >= 70 ) begin
									pos[counter] = pos[counter] - 70;
									ascii <= falling_ascii[counter];
                                    position <= pos[counter];
                                    speed_counter[counter] <= 0;
							  end
							  else begin
									valid_fall[counter] <= 0;
									ascii <= 0;
									rev[counter] <= 0;
                                    position <= pos[counter];
							  end
							  status <= 2'd0;
							  counter <= counter + 1;
							 end
						endcase
				  end else if ( counter <= ascii_num - 1 ) begin
						if ( rand_next == 8'd11 && rand_pos != pos[counter - 1] ) begin
							 valid_fall[counter] <= 1;
							 pos[counter] <= rand_pos;
							 falling_ascii[counter] <= rand_ascii;
							 counter <= counter + 1;
									 speed[counter] <= rand_speed;
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
					
					//------------difficulty display--------
					else if(difficulty_status != 4) begin
						position <= 2031 + difficulty_status;
						if(difficulty == 1) begin
						case(difficulty_status)
							0:ascii<=72;  
							1:ascii<=65;
							2:ascii<=82;
							3:ascii<=68;
						endcase
						end
						else begin
						case(difficulty_status)
							0:ascii<=69;  
							1:ascii<=65;
							2:ascii<=83;
							3:ascii<=89;
						endcase
						end
						difficulty_status <= difficulty_status + 1;
					end
					
					//----------time display------------
					  else if (time_status != 7) begin
						position <= 133 + time_status;
						case(time_status)
							4'd0:ascii <= 84;
							4'd1:ascii <= 73;
							4'd2:ascii <= 77;
							4'd3:ascii <= 69;
							4'd4:ascii <= 58;
							4'd5:ascii <= (timee / 10) % 10 + 48;
							4'd6:ascii <= timee % 10 + 48;
						endcase
						time_status <= time_status + 1;
					end
					
					//---------end of time display--------
				
				end
				
				else //game_over_status > 0
				begin
					
					miss <= 0;
					hit <= 0;
					init_screen <= 0;
					if (game_over_screen != 2100) begin
						position <= game_over_screen;
						if(game_over_screen == 1439) ascii <= (score / 100) % 10 + 48;
						else if(game_over_screen == 1440) ascii <= (score / 10) % 10 + 48;	
						else if(game_over_screen == 1441) ascii <= score  % 10 + 48;
						else ascii <= game_over_value;
						game_over_screen <= game_over_screen + 1;
					end
				end
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
		  time_status <= 0;
		  difficulty_status <= 0;
        if ( kbd_input ) begin
            if ( counter <= ascii_num - 1 && falling_ascii[counter] == input_ascii && valid_fall[counter] && rev[counter] == 0 &&
				     pos[counter] >= lowest_pos) begin
                lowest_pos <= pos[counter];
                triggered <= counter;
                counter <= counter + 1;
            end else if (counter > ascii_num - 1 ) begin
                if ( triggered <= ascii_num - 1 ) 
					 begin
					 score <= score + 1;
						hit <= hit + 1;
						sound <= 1070;
					 end
                rev[triggered] <= 1;
                triggered <= ascii_num;
                kbd_input <= 0;
					 lowest_pos <= 0;
            end else begin
					counter <= counter + 1;
				end
        end else begin
	        counter <= 2'd0;
        end
    end
end

endmodule


