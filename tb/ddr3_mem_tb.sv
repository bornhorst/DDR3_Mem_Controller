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

// ********** Configure Clock ********** //
always 
begin
	#5 cpu_clk = ~cpu_clk;
end

// ********** Interface Instantiations ********** //
ddr3_mem_intf 	cont_intf_mem(.CPU_CLK(cpu_clk));
ddr3_cpu_intf	cont_intf_cpu(.CPU_CLK(cpu_clk));

// ********** Module Instantiations ********** //
ddr3_mem_cont MEM_CONT(
	.cpu_clk(cpu_clk),
	.cont_to_cpu(cont_intf_cpu.cont_to_cpu),
	.cont_to_mem(cont_intf_mem.cont_to_mem)
);

ddr3_mem_cpu MEM_CPU(
	.cpu_clk(cpu_clk),
	.cpu_to_cont(cont_intf_cpu.cpu_to_cont)
);

// ********** Basic TB ********** //
initial 
begin

cpu_clk = 1;

#500 $finish;

end

endmodule
