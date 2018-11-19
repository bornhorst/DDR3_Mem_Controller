/////////////////////////////////////////////////////////////
//
// ddr3_mem_cpu.sv (Group 8)
//
// Description: Instantiation of CPU within Memory System
//
/////////////////////////////////////////////////////////////

// ********** CPU Module ********** //
module ddr3_mem_cpu(
	input logic 			cpu_clk,
	ddr3_cpu_intf.cpu_to_cont	cpu_to_cont
);

// ********** Import Package ********** //
import ddr3_mem_pkg::*;

// ********** Local Variables ********** //
logic	[3:0]	command;

// ********** Assign Command Signals ********** //
assign {cpu_to_cont.CS_N, cpu_to_cont.RAS_N, cpu_to_cont.CAS_N, cpu_to_cont.WE_N} = command;

initial
begin
	cpu_to_cont.RESET_N = 1;
	#100;
	cpu_to_cont.RESET_N = 0;
	#40;
	cpu_to_cont.RESET_N = 1;
	#100;
	cpu_to_cont.ADDR = 5;
	command = Command.ACT;
	#20;
	command = Command.RD;
	#20;
	command = Command.WR;
	#20;
	cpu_to_cont.ADDR[10] = 1;
	command = Command.RD;
end

endmodule
