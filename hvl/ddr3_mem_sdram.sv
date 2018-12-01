///////////////////////////////////////////////////////////////////
//
// ddr3_mem_sdram.sv (Group 8)
//
// Descritpion: SDRAM memory module for the DDR3 SDRAM interface
//
//////////////////////////////////////////////////////////////////

module ddr3_mem_sdram(
	input logic			cpu_clk,
	ddr3_mem_intf.mem_to_cont	mem_to_cont	
);

// ********** Import Package ********** //
import ddr3_mem_pkg::*;

// ********** Local Variables ********** //
logic	[3:0]		command;
logic	[15:0]		wr_data;
logic	[0:63][15:0]	memory	[0:32767];

// ********** Reset Logic ********** //
always_ff @(posedge mem_to_cont.CK, negedge mem_to_cont.RESET_N)
begin
	if(~mem_to_cont.RESET_N)
		MEMState <= RESET;
	else
		MEMState <= nextMEMState;
end

// ********** Command Logic ********** //
assign command = {mem_to_cont.CS_N, mem_to_cont.RAS_N, mem_to_cont.CAS_N, mem_to_cont.WE_N};

// ********** State Transitions ********** //
always_comb
begin
		case(MEMState)
		RESET:
		begin
			if(mem_to_cont.RESET_N)
				nextMEMState = INIT;
			else
				nextMEMState = RESET;
		end
		INIT:
		begin
			if(command == Command.ZQC)
				nextMEMState = IDLE;
			else
				nextMEMState = INIT;
		end
		IDLE: 
		begin
			if(command == Command.ACT)
				nextMEMState = ACTIVATE;
			else
				nextMEMState = IDLE;
		end
		ACTIVATE: nextMEMState = BANK_ACT;
		BANK_ACT:
		begin
			case(command)
				Command.RD: nextMEMState = READ0;
				Command.WR: nextMEMState = WRITE0;
				Command.PRE:nextMEMState = PRE_C;
				default:    nextMEMState = BANK_ACT;
			endcase
		end
		READ0: nextMEMState = READ1;
		READ1: nextMEMState = READ2;
		READ2: nextMEMState = READ3;
		READ3:   
		begin
			case(command)
				Command.RD: nextMEMState = READ0;
				Command.WR: nextMEMState = BANK_ACT;
				Command.PRE:nextMEMState = PRE_C;
				default:    nextMEMState = BANK_ACT;
			endcase
		end
		WRITE0: 
		begin
			memory[mem_to_cont.ADDR][mem_to_cont.COL]	= mem_to_cont.WR_DATA;
			nextMEMState 					= WRITE1;
		end
		WRITE1: 
		begin
			memory[mem_to_cont.ADDR][mem_to_cont.COL]	= mem_to_cont.WR_DATA;
			nextMEMState 					= WRITE2;
		end
		WRITE2: 
		begin
			memory[mem_to_cont.ADDR][mem_to_cont.COL]	= mem_to_cont.WR_DATA;
			nextMEMState 					= WRITE3;
		end
		WRITE3: 
		begin
			memory[mem_to_cont.ADDR][mem_to_cont.COL]	= mem_to_cont.WR_DATA;
			case(command)
				Command.RD: nextMEMState = BANK_ACT;
				Command.WR: nextMEMState = WRITE0;
				Command.PRE:nextMEMState = PRE_C;
				default:    nextMEMState = BANK_ACT;
			endcase
		end
		PRE_C:   nextMEMState   = IDLE;
		default: nextMEMState 	= RESET;
	endcase
end

assign mem_to_cont.RD_DATA = 	(State == READ0) ? memory[mem_to_cont.ADDR][mem_to_cont.COL] :
				(State == READ1) ? memory[mem_to_cont.ADDR][mem_to_cont.COL] :
				(State == READ2) ? memory[mem_to_cont.ADDR][mem_to_cont.COL] :
				(State == READ3) ? memory[mem_to_cont.ADDR][mem_to_cont.COL] : 'bz;

endmodule
