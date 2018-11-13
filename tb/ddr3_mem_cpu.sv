/////////////////////////////////////////////////////////////
//
// ddr3_mem_cpu.sv (Group 8)
//
// Description: Instantiation of CPU within Memory System
//
/////////////////////////////////////////////////////////////

// ********** CPU Module ********** //
module ddr3_mem_cpu(
	input logic 		cpu_clk,
	ddr3_cpu_intf.cpu	cpu_to_cont
);

initial
begin
	cpu_to_cont.RESET_N = 1;
	#100;
	cpu_to_cont.RESET_N = 0;
	#40;
	cpu_to_cont.RESET_N = 1;
	#100;
end

endmodule
