/////////////////////////////////////////////////////////////////////
//
// ddr3_mem_tb.sv (Group 8)
//
// Description: Simulation Test Bench for a DDR3 SDRAM System
//
/////////////////////////////////////////////////////////////////////


// ********** DDR3 Memory TB ********** //
module ddr3_mem_tb;

// ********** Local Variables ********** //
logic 	cpu_clk;

// ********** Interface Instantiations ********** //
ddr3_mem_intf 	cont_intf_mem(.CPU_CLK(cpu_clk));
ddr3_cpu_intf	cont_intf_cpu(.CPU_CLK(cpu_clk));

// ********** Module Instantiations ********** //
ddr3_mem_cont MEM_CONT(
	.cpu_clk(cpu_clk),
	.cont_to_cpu(cont_intf_cpu.mem_controller),
	.cont_to_mem(cont_intf_mem.mem_cont_signals)
);

endmodule
