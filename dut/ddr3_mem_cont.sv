//////////////////////////////////////////////////////////////////
//
// ddr3_mem_cont.sv (Group 8)
//
// Description: Memory controller for a 256M x 8 DDR3 SDRAM
//
//////////////////////////////////////////////////////////////////

// ********** Controller Module ********** //
module ddr3_mem_cont(
	input logic			cpu_clk,
	ddr3_cpu_intf.cont_to_cpu	cont_to_cpu,
	ddr3_mem_intf.cont_to_mem	cont_to_mem
);

// ********** Import Package ********** //
import ddr3_mem_pkg::*;

// ********** Local Variables ********** //
logic		auto_precharge;	// signal to auto-precharge row 
logic	[3:0]	command;	// command signal from CPU for reading/writing

// ********** Reset Device ********* //
always_ff @(posedge cpu_clk, negedge cont_to_cpu.RESET_N)
begin
	if(~cont_to_cpu.RESET_N)		// Reset to default state
	begin
		Command.MRS	<= 4'b0000;	// Mode Register
		Command.REF	<= 4'b0001;	// Refresh
		Command.SRE	<= 4'b0111;	// Self Refresh
		Command.SRX	<= 4'b0111;	// Self Refresh Exit
		Command.PRE	<= 4'b0010;	// Precharge Bank/Row
		Command.ACT	<= 4'b0011;	// Activate Bank/Row
		Command.WR	<= 4'b0100;	// Write
		Command.RD	<= 4'b0101;	// Read
		Command.NOP	<= 4'b0111;	// No Operation
		State 		<= RESET;	
	end
	else
		State <= nextState;		// Progress state
end

// ********** Assign Controller -> Memory Signals ********** //
assign cont_to_mem.RESET_N 	= cont_to_cpu.RESET_N;
assign cont_to_mem.BA		= cont_to_cpu.ADDR[2:0];
assign cont_to_mem.ADDR		= cont_to_cpu.ADDR[14:0];
assign cont_to_mem.CKE_N	= (State == RESET)    ? 0 : ((State > RESET) ? 1 : 'bx); 
assign cont_to_mem.CK		= (cont_to_mem.CKE_N) ? ((cpu_clk)  ? 1 : 0) : 'bx; 
assign cont_to_mem.CK_N		= (cont_to_mem.CKE_N) ?	((~cpu_clk) ? 1 : 0) : 'bx;

// ********** Assign Command Signals ********** //
assign auto_precharge	= cont_to_cpu.ADDR[10];
assign command 		= {cont_to_cpu.CS_N, cont_to_cpu.RAS_N, cont_to_cpu.CAS_N, cont_to_cpu.WE_N};

// ********** State Transitions ********** //
always_comb
begin
$display($time, "  Clk: %b	State: %s	Reset: %b	MemReset: %b	ClockEn: %b	MemCK/CK#: %b %b\n",
		cpu_clk, State, cont_to_cpu.RESET_N, cont_to_mem.RESET_N, cont_to_mem.CKE_N, cont_to_mem.CK, cont_to_mem.CK_N);
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
			if(command == Command.ACT)
				nextState = ACTIVATE;
			else
				nextState = IDLE;
		end
		ACTIVATE: nextState = BANK_ACTIVATE;
		BANK_ACTIVATE:
		begin
			case(command)
				Command.RD:
				begin
					if(~auto_precharge)
						nextState = READ;
					else
						nextState = READ_A;
				end
				Command.WR:		
				begin
					if(~auto_precharge)
						nextState = WRITE;
					else
						nextState = WRITE_A;
				end
				Command.PRE: nextState = PRECHARGE;
				default: nextState = BANK_ACTIVATE;
			endcase
		end
		READ:
		begin
			case(command)
				Command.RD:
				begin
					if(~auto_precharge)
						nextState = READ;
					else
						nextState = READ_A;
				end
				Command.WR:
				begin
					if(~auto_precharge)
						nextState = WRITE;
					else
						nextState = WRITE_A;
				end
				Command.PRE: nextState = PRECHARGE;
				default: nextState = BANK_ACTIVATE;
			endcase
		end
		WRITE:
		begin
			case(command)
				Command.RD:
				begin
					if(~auto_precharge)
						nextState = READ;
					else
						nextState = READ_A;
				end
				Command.WR:
				begin
					if(~auto_precharge)
						nextState = WRITE;
					else
						nextState = WRITE_A;
				end
				Command.PRE: nextState = PRECHARGE;
				default: nextState = BANK_ACTIVATE;
			endcase
		end
		READ_A:    nextState = PRECHARGE;
		WRITE_A:   nextState = PRECHARGE;
		PRECHARGE: nextState = IDLE;
		default:   nextState = POWER_ON;
	endcase
end

endmodule	
