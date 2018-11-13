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
always_ff @(posedge cpu_clk, negedge cont_to_cpu.RESET_N)
begin
	if(~cont_to_cpu.RESET_N)
		State <= RESET;
	else
		State <= nextState;
end

// ********** Assign Controller -> Memory Signals ********** //
assign cont_to_mem.RESET_N 	= cont_to_cpu.RESET_N;
assign cont_to_mem.BA		= cont_to_cpu.ADDR[2:0];
assign cont_to_mem.ADDR		= cont_to_cpu.ADDR[14:0];
assign cont_to_mem.CKE_N	= (State == RESET) ? 0 : ((State > RESET) ? 1 : 'bz); 
assign cont_to_mem.CK		= (cont_to_mem.CKE_N) ? cpu_clk : 'bz; 

// ********** State Transitions ********** //
always_comb
begin
$display($time, "  Clk: %b	State: %d	Reset: %b	MemReset: %b	ClockEn: %b	MemCK/CK#: %b\n",
		cpu_clk, State, cont_to_cpu.RESET_N, cont_to_mem.RESET_N, cont_to_mem.CKE_N, cont_to_mem.CK);
	unique case(State)
		POWER_ON: 
		begin
			if(~cont_to_cpu.RESET_N)
				nextState = RESET;
			else 
				nextState = POWER_ON;
		end
		RESET: 
		begin
			if(cont_to_cpu.RESET_N)
				nextState = INIT;
			else
				nextState = RESET; 
		end
		INIT: 
		begin
			nextState = IDLE;
		end
		IDLE:
		begin
			nextState = IDLE;
		end
		default: nextState = POWER_ON;
	endcase
end

endmodule	
