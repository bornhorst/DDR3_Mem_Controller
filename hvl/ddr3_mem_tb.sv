`timescale 1ps/1ps
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
logic		reset_n;
logic		en;

parameter 	MAX_ADDR = 50;

// ********** Configure Clock ********** //
//tbx clkgen
initial 
begin
	cpu_clk = 1;
	forever	#5 cpu_clk = ~cpu_clk;
end

assign command = {cont_mem.CS_N, cont_mem.RAS_N, cont_mem.CAS_N, cont_mem.WE_N};

// ********** Interface Instantiations ********** //
ddr3_mem_intf 	cont_mem(.CPU_CLK(cpu_clk), .RESET_N(reset_n));
ddr3_cpu_intf	cont_cpu(.CPU_CLK(cpu_clk), .RESET_N(reset_n), .EN(en));

// ********** Module Instantiations ********** //
ddr3_mem_cont MEM_CONT(
	.cpu_clk(cpu_clk),
	.reset_n(reset_n),
	.en(en),
	.cont_to_cpu(cont_cpu.cont_to_cpu),
	.cont_to_mem(cont_mem.cont_to_mem)
);

ddr3_mem_sdram MEM_SDRAM(
	.cpu_clk(cpu_clk),
	.reset_n(reset_n),
	.mem_to_cont(cont_mem.mem_to_cont)
);

ddr3_mem_cpu MEM_CPU(
	.cpu_clk(cpu_clk),
	.reset_n(reset_n),
	.en(en),
	.cpu_to_cont(cont_cpu.cpu_to_cont)
);

// ********** Basic TB ********** //
//tbx clkgen
initial 
begin

reset_n = 1;
#20;
reset_n = 0;
#20;
reset_n = 1;
#20;
en = 1;

#10000000 $finish;

end

endmodule
