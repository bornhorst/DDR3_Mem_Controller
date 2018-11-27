
module sdram_mem(
	input 	logic		en,
	input 	logic 		ck,
	input	logic		ck_n,
	input 	logic	[2:0]	ba,
	input 	logic	[14:0]	row_addr,
	input	logic	[9:0]	col_addr,
	input 	logic		we_n,
	input 	logic	[7:0]	i_data,
	output  logic	[7:0]	o_data
);

logic	[0:127][7:0]	bank0	[0:32767];
logic	[0:127][7:0]	bank1	[0:32767];
logic	[0:127][7:0]	bank2	[0:32767];
logic	[0:127][7:0]	bank3	[0:32767];
logic	[0:127][7:0]	bank4	[0:32767];
logic	[0:127][7:0]	bank5	[0:32767];
logic	[0:127][7:0]	bank6	[0:32767];
logic	[0:127][7:0]	bank7	[0:32767];

always_ff @(posedge ck, posedge ck_n)
begin
	case({we_n, ba})
		0 : if(en) bank0[row_addr][col_addr]	<= i_data;
		1 : if(en) bank1[row_addr][col_addr]	<= i_data;
		2 : if(en) bank2[row_addr][col_addr]	<= i_data;
		3 : if(en) bank3[row_addr][col_addr]	<= i_data;
		4 : if(en) bank4[row_addr][col_addr]	<= i_data;
		5 : if(en) bank5[row_addr][col_addr]	<= i_data;
		6 : if(en) bank6[row_addr][col_addr]	<= i_data;
		7 : if(en) bank7[row_addr][col_addr]	<= i_data;

		8 : if(en) o_data <= bank0[row_addr][col_addr];
		9 : if(en) o_data <= bank1[row_addr][col_addr];
		10: if(en) o_data <= bank2[row_addr][col_addr];
		11: if(en) o_data <= bank3[row_addr][col_addr];
		12: if(en) o_data <= bank4[row_addr][col_addr];
		13: if(en) o_data <= bank5[row_addr][col_addr];
		14: if(en) o_data <= bank6[row_addr][col_addr];
		15: if(en) o_data <= bank7[row_addr][col_addr];
	endcase
end

final
begin
	$display($time, "  BA0[%5d]: %p", row_addr, bank0);
end

endmodule
	
