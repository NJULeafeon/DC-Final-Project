module display_ram #(
	parameter RAM_WIDTH = 8,
	parameter RAM_ADDR_WIDTH = 11
)(
	input valid,
	input [11:0] pos,
	input new,
	input new_ascii,
	output [RAM_WIDTH:0] ret);
	
reg [RAM_WIDTH:0] ram [(2**RAM_ADDR_WIDTH)-1:0];

initial begin
ram[20] = 8'h41;
end

always @ (pos) begin
	if ( valid ) begin
		if ( ram[pos] != 0 ) begin
			ram[pos + 70] = ram[pos];
			ram[pos] = 0;
		end
	end
end

assign ret = (pos < 2 ** RAM_ADDR_WIDTH) ? ram[pos] : 0;

endmodule
