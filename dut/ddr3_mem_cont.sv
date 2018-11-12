//////////////////////////////////////////////////////////////////
//
// ddr3_mem_cont.sv (Group 8)
//
// Description: Memory controller for a 256M x 8 DDR3 SDRAM
//
//////////////////////////////////////////////////////////////////

// ********** Memory Package ********** //
import ddr3_mem_pkg::*;

// ********** Controller Module ********** //
module ddr3_mem_cont(
	input logic			cpu_clk,
	ddr3_cpu_intf.mem_controller	cont_to_cpu,
	ddr3_mem_intf.mem_cont_signals	cont_to_mem
);

// ********** Local Variables ********** //



// ********** Reset Device ********* //
always_ff @(posedge cpu_clk, negedge cont_to_cpu.RESET)
begin
	if(~cont_to_cpu.RESET)
		State <= RESET;
	else
		State <= nextState;
end

endmodule	
