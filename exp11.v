
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module exp11(

	//////////// CLOCK //////////
	input 		          		CLOCK2_50,
	input 		          		CLOCK3_50,
	input 		          		CLOCK4_50,
	input 		          		CLOCK_50,

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

	//////////// VGA //////////
	output		          		VGA_BLANK_N,
	output		     [7:0]		VGA_B,
	output		          		VGA_CLK,
	output		     [7:0]		VGA_G,
	output		          		VGA_HS,
	output		     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS,

	//////////// PS2 //////////
	inout 		          		PS2_CLK,
	inout 		          		PS2_CLK2,
	inout 		          		PS2_DAT,
	inout 		          		PS2_DAT2
);



//=======================================================
//  REG/WIRE declarations
//=======================================================

wire [7:0] ascii;
wire [7:0] code_reg;
wire [11:0] index;


//=======================================================
//  Structural coding
//=======================================================
exp09(CLOCK_50,VGA_CLK,VGA_HS,VGA_VS,VGA_SYNC_N,VGA_BLANK_N,VGA_R,VGA_G,VGA_B,ascii,index);
exp08(CLOCK_50,1'b1,PS2_CLK,PS2_DAT,ascii,code_reg);
light l(.data(index[7:0]),.out_h(HEX1),.out_l(HEX0),.enable(1'b1));
light l2(.data(code_reg),.out_h(HEX3),.out_l(HEX2),.enable(1'b1));
endmodule