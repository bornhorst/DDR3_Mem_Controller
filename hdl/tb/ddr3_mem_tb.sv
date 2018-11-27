/////////////////////////////////////////////////////////////////////
//
// ddr3_mem_tb.sv (Group 8)
//
// Description: Simulation Test Bench for a DDR3 SDRAM System
//
/////////////////////////////////////////////////////////////////////


// ********** DDR3 Memory TB ********** //
module ddr3_mem_tb;

// ********** Import Package ********** //
import ddr3_mem_pkg::*;

// ********** Local Variables ********** //
logic 		cpu_clk;
logic	[3:0]	command;

// ********** Assign Command ********** //
assign command = {cont_mem.CS_N, cont_mem.RAS_N, cont_mem.CAS_N, cont_mem.WE_N};

// ********** Configure Clock ********** //
always 
begin
	#5 cpu_clk = ~cpu_clk;
end

// ********** Interface Instantiations ********** //
ddr3_mem_intf 	cont_mem(.CPU_CLK(cpu_clk));
ddr3_cpu_intf	cont_cpu(.CPU_CLK(cpu_clk));

// ********** Module Instantiations ********** //
ddr3_mem_cont MEM_CONT(
	.cpu_clk(cpu_clk),
	.cont_to_cpu(cont_cpu.cont_to_cpu),
	.cont_to_mem(cont_mem.cont_to_mem)
);

ddr3_mem_cpu MEM_CPU(
	.cpu_clk(cpu_clk),
	.cpu_to_cont(cont_cpu.cpu_to_cont)
);

ddr3_mem_sdram MEM_SDRAM(
	.cpu_clk(cpu_clk),
	.mem_to_cont(cont_mem.mem_to_cont)
);

// ********** Basic TB ********** //
initial 
begin

$monitor($time, " CPU_CLK: %b	CK/CK#: %b%b	State: %s		CPUState: %s		MEMState: %s    	Valid: %b	RD/WR: %b	Command: %4b",
		cpu_clk, cont_mem.CK, cont_mem.CK_N, State, CPUState, MEMState, cont_cpu.ADDR_VALID, cont_cpu.CMD, command);	

cpu_clk = 1;

#(10*250) $finish;

end

endmodule
