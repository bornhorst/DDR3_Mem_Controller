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
logic		cmd;

parameter MAX_ADDR = 50;

// ********** Configure Clock ********** //
always 
begin
	cpu_clk = 1;
	forever	#5 cpu_clk = ~cpu_clk;
end

assign command = {cont_mem.CS_N, cont_mem.RAS_N, cont_mem.CAS_N, cont_mem.WE_N};

// ********** Interface Instantiations ********** //
ddr3_mem_intf 	cont_mem(.CPU_CLK(cpu_clk));
ddr3_cpu_intf	cont_cpu(.CPU_CLK(cpu_clk), .RESET_N(reset_n), .EN(en), .CMD(cmd));

// ********** Module Instantiations ********** //
ddr3_mem_cont MEM_CONT(
	.cpu_clk(cpu_clk),
	.reset_n(reset_n),
	.en(en),
	.cmd(cmd),
	.cont_to_cpu(cont_cpu.cont_to_cpu),
	.cont_to_mem(cont_mem.cont_to_mem)
);

ddr3_mem_sdram MEM_SDRAM(
	.cpu_clk(cpu_clk),
	.mem_to_cont(cont_mem.mem_to_cont)
);

always @(posedge cpu_clk)
begin

	if(cont_cpu.ADDR > MAX_ADDR)
	begin
		cmd 		<= ~cmd;
		cont_cpu.ADDR 	<= 0;
	end

if(cmd == 0)
begin

	if(cont_cpu.CMD_RDY)
	begin
		cont_cpu.WR_DATA	<= 0;
		cont_cpu.ADDR 		<= cont_cpu.ADDR;
		cont_cpu.COL		<= 0;
		cont_cpu.BA		<= 0;
		cont_cpu.ADDR_VALID 	<= 1;
	end	

	if((cont_cpu.COL == 6'b111111) && (State == WRITE3))
	begin
		cont_cpu.ADDR		<= cont_cpu.ADDR + 1;
	end
	else if((State == WRITE0) || (State == WRITE1) || (State == WRITE2) || (State == WRITE3)) 
	begin
		cont_cpu.ADDR_VALID	<= 0;
		cont_cpu.WR_DATA 	<= cont_cpu.WR_DATA + 1;
		cont_cpu.COL		<= cont_cpu.COL + 1;
	end

	$display($time, " COL: %d 	WR_DATA: %b", cont_cpu.COL, cont_mem.WR_DATA);
end
else if(cmd == 1)
begin

	if(cont_cpu.CMD_RDY)
	begin
		cont_cpu.WR_DATA	<= 0;
		cont_cpu.ADDR 		<= cont_cpu.ADDR;
		cont_cpu.COL		<= 0;
		cont_cpu.BA		<= 0;
		cont_cpu.ADDR_VALID 	<= 1;
	end	

	if((cont_cpu.COL == 6'b111111) && (State == READ3))
	begin
		cont_cpu.ADDR		<= cont_cpu.ADDR + 1;
	end
	else if((State == READ0) || (State == READ1) || (State == READ2) || (State == READ3)) 
	begin
		cont_cpu.ADDR_VALID	<= 0;
		cont_cpu.COL		<= cont_cpu.COL + 1;
	end
	
	$display($time, " COL: %d 	RD_DATA: %b", cont_cpu.COL, cont_mem.RD_DATA);
end

end



// ********** Basic TB ********** //
initial 
begin

cont_cpu.ADDR = 0;
reset_n = 1;
#20;
reset_n = 0;
#20;
reset_n = 1;
#20;
en = 1;
cmd = 0;

$monitor($time, "  clk: %b ck/ck#: %b%b	State: %s			MEMState: %s    		addr: %16h	valid: %b rd/wr: %b",
		cpu_clk, cont_mem.CK, cont_mem.CK_N, State, MEMState, cont_cpu.ADDR, cont_cpu.ADDR_VALID, cmd);	

#500000 $finish;

end

endmodule
