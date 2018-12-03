///////////////////////////////////////////////////////////////////
//
// ddr3_mem_sdram.sv (Group 8)
//
// Descritpion: SDRAM memory module for the DDR3 SDRAM interface
//
//////////////////////////////////////////////////////////////////

module ddr3_mem_sdram(
	input 				cpu_clk,
	input				reset_n,
	ddr3_mem_intf.mem_to_cont	mem_to_cont	
);

// ********** Import Package ********** //
import ddr3_mem_pkg::*;

// ********** Local Variables ********** //
logic	[3:0]		command;
logic	[7:0]		wr_data;
logic	[0:127][7:0]	memory	[0:32767];
logic	[2:0]		wait_counter;

// ********** Reset Logic ********** //
always_ff @(posedge mem_to_cont.CK, negedge reset_n)
begin
	if(~reset_n)
		MEMState 	<= RESET;
	else
		MEMState 	<= nextMEMState;
end

// ********** Command Logic ********** //
assign command = {mem_to_cont.CS_N, mem_to_cont.RAS_N, mem_to_cont.CAS_N, mem_to_cont.WE_N};

// ********** State Transitions ********** //
always_comb
begin
		case(MEMState)
		RESET:
		begin
			memory = '{default:'b0};

			if(reset_n)
				nextMEMState = INIT;
			else
				nextMEMState = RESET;
		end
		INIT:
		begin
			if(command == Command.PRE)
				nextMEMState = PRE_C;
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
		ACTIVATE: 
		begin
			if(wait_counter == 5)
				nextMEMState = BANK_ACT;
			else
				nextMEMState = ACTIVATE;
		end
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
		PRE_C:
		begin
			if(wait_counter == 5)
				nextMEMState = IDLE;
			else
				nextMEMState = PRE_C;
		end
		default: nextMEMState 	= RESET;
	endcase
end

// ********** Wait State Counter ********** //
always_ff @(posedge cpu_clk)
begin
	if(((State == ACTIVATE)||(State == PRE_C)) && (wait_counter == 5))
		wait_counter <= 0;
	else if((State == ACTIVATE)||(State == PRE_C))
		wait_counter <= wait_counter + 1;
	else
		wait_counter <= 0;
end

// ********** Data Ready Signal ********** //
assign mem_to_cont.DQS_N   = 	((State == READ0)||(State == READ1)||(State == READ2)||(State == READ3)) ? 0 : 1;

// ********** Send Read Data to Controller ********** //
assign mem_to_cont.RD_DATA = 	((~mem_to_cont.DQS_N) && (State == READ0) && (mem_to_cont.CK_N)) 	? memory[mem_to_cont.ADDR][mem_to_cont.COL] :
				((~mem_to_cont.DQS_N) && (State == READ0) && (mem_to_cont.CK)) 		? memory[mem_to_cont.ADDR][mem_to_cont.COL] :
				((~mem_to_cont.DQS_N) && (State == READ1) && (mem_to_cont.CK_N)) 	? memory[mem_to_cont.ADDR][mem_to_cont.COL] :
				((~mem_to_cont.DQS_N) && (State == READ1) && (mem_to_cont.CK)) 		? memory[mem_to_cont.ADDR][mem_to_cont.COL] :
				((~mem_to_cont.DQS_N) && (State == READ2) && (mem_to_cont.CK_N)) 	? memory[mem_to_cont.ADDR][mem_to_cont.COL] :
				((~mem_to_cont.DQS_N) && (State == READ2) && (mem_to_cont.CK)) 		? memory[mem_to_cont.ADDR][mem_to_cont.COL] :
				((~mem_to_cont.DQS_N) && (State == READ3) && (mem_to_cont.CK_N)) 	? memory[mem_to_cont.ADDR][mem_to_cont.COL] :
				((~mem_to_cont.DQS_N) && (State == READ3) && (mem_to_cont.CK)) 		? memory[mem_to_cont.ADDR][mem_to_cont.COL] : 'bx;

final
begin
	$display("ADDR: %15b  MEMORY: %p", mem_to_cont.ADDR, memory[mem_to_cont.ADDR]);
end

endmodule
