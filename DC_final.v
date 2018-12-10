
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module DC_final(

	//////////// CLOCK //////////
	input 		          		CLOCK2_50,
	input 		          		CLOCK3_50,
	input 		          		CLOCK4_50,
	input 		          		CLOCK_50,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// SW //////////
	input 		     [9:0]		SW,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// Seg7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,

	//////////// SDRAM //////////
	output		    [12:0]		DRAM_ADDR,
	output		     [1:0]		DRAM_BA,
	output		          		DRAM_CAS_N,
	output		          		DRAM_CKE,
	output		          		DRAM_CLK,
	output		          		DRAM_CS_N,
	inout 		    [15:0]		DRAM_DQ,
	output		          		DRAM_LDQM,
	output		          		DRAM_RAS_N,
	output		          		DRAM_UDQM,
	output		          		DRAM_WE_N,

	//////////// Video-In //////////
	input 		          		TD_CLK27,
	input 		     [7:0]		TD_DATA,
	input 		          		TD_HS,
	output		          		TD_RESET_N,
	input 		          		TD_VS,

	//////////// VGA //////////
	output		          		VGA_BLANK_N,
	output		     [7:0]		VGA_B,
	output		          		VGA_CLK,
	output		     [7:0]		VGA_G,
	output		          		VGA_HS,
	output		     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS,

	//////////// Audio //////////
	input 		          		AUD_ADCDAT,
	inout 		          		AUD_ADCLRCK,
	inout 		          		AUD_BCLK,
	output		          		AUD_DACDAT,
	inout 		          		AUD_DACLRCK,
	output		          		AUD_XCK,

	//////////// PS2 //////////
	inout 		          		PS2_CLK,
	inout 		          		PS2_CLK2,
	inout 		          		PS2_DAT,
	inout 		          		PS2_DAT2,

	//////////// ADC //////////
	output		          		ADC_CONVST,
	output		          		ADC_DIN,
	input 		          		ADC_DOUT,
	output		          		ADC_SCLK,

	//////////// I2C for Audio and Video-In //////////
	output		          		FPGA_I2C_SCLK,
	inout 		          		FPGA_I2C_SDAT,

	//////////// IR //////////
	input 		          		IRDA_RXD,
	output		          		IRDA_TXD
);



//=======================================================
//  REG/WIRE declarations
//=======================================================

wire [7:0] ascii;
wire [7:0] code_reg;
wire [7:0] output_ascii;
wire mode;
assign mode = SW[0];
assign difficulty = SW[1];

wire clk_i2c;
wire reset;
wire [15:0] audiodata;
wire [15:0] freq;
wire [15:0] sound;

wire clk_i2c;
wire reset;
wire [15:0] audiodata;
wire [15:0] freq;
//wire [4:0] volumn;
reg [4:0] volumn = 10;
wire [8:0] test;
wire [15:0] sound;

//=======================================================
//  Structural coding
//=======================================================
wire ready;
wire kbd_input;
wire [1:0] state;
<<<<<<< HEAD
exp09 vga(CLOCK_50,VGA_CLK,VGA_HS,VGA_VS,VGA_SYNC_N,VGA_BLANK_N,VGA_R,VGA_G,VGA_B,index, state, ascii, output_ascii,KEY[0],mode,sound);
=======
exp09 vga(CLOCK_50,VGA_CLK,VGA_HS,VGA_VS,VGA_SYNC_N,VGA_BLANK_N,VGA_R,VGA_G,VGA_B,state, ascii, output_ascii,KEY[0],mode,sound,difficulty);
>>>>>>> leafeon
//mykbd my_keyboard(CLOCK_50,PS2_CLK,PS2_DAT,state,ascii,ready);
exp08 kbd(CLOCK_50, 1'b1, PS2_CLK,PS2_DAT,ascii,code_reg, ready, state);
light l(.data(output_ascii),.out_h(HEX1),.out_l(HEX0),.enable(1'b1));
light l2(.data(ascii),.out_h(HEX3),.out_l(HEX2),.enable(1'b1));
light l3(sound[7:0],HEX5,HEX4,1'b1);
assign LEDR[0] = state[0];
assign LEDR[1] = state[1];

<<<<<<< HEAD
assign reset = ~KEY[1];
audio_clk u1(CLOCK_50, reset,AUD_XCK, LEDR[9]);

clkgen #(10000) my_i2c_clk(CLOCK_50,reset,1'b1,clk_i2c);  //10k I2C clock  

assign test [8:0] = 9'h42+5*volumn;

I2C_Audio_Config myconfig(clk_i2c, KEY[1],FPGA_I2C_SCLK,FPGA_I2C_SDAT,LEDR[8:6],test);
=======
//-----------------sound-----------------

assign reset = ~KEY[1];
audio_clk u1(CLOCK_50, reset,AUD_XCK, LEDR[9]);
clkgen #(10000) my_i2c_clk(CLOCK_50,reset,1'b1,clk_i2c);  //10k I2C clock  

I2C_Audio_Config myconfig(clk_i2c, KEY[1],FPGA_I2C_SCLK,FPGA_I2C_SDAT,LEDR[8:6]);
>>>>>>> leafeon

I2S_Audio myaudio(AUD_XCK, KEY[1], AUD_BCLK, AUD_DACDAT, AUD_DACLRCK, audiodata);

Sin_Generator sin_wave(AUD_DACLRCK, KEY[1], sound, audiodata);
<<<<<<< HEAD
=======
//----------------end of sound------------

>>>>>>> leafeon
endmodule
