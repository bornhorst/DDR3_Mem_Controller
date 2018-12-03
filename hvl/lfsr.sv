//////////////////////////////////////////////////////////////////
//
// lfsr.sv (Group 8)
//
// Description: linear feedback shift register
//
//////////////////////////////////////////////////////////////////

module lfsr(
	out,
	clk,
	reset_n,
	en
);

parameter max = (2^^64);

output	[63:0]	out;
input		clk, reset_n, en;
logic	[63:0] 	temp;

wire		feedback;
logic	[63:0]	out;

assign feedback = !(out[19] ^ out[6] ^ out[2] ^ out[1]);

always_ff @(posedge clk)
begin
	if(~reset_n)
		out <= 0;
	else if(en)
		out <= {out, feedback};
end

endmodule
