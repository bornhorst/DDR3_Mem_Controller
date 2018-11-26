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
logic	[3:0]	command;
logic	[9:0]	col_addr;
logic	[2:0]	burst_count;
logic	[7:0]	i_data, o_data;
logic		we_n;
logic		en_mem;

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
		POWER_ON:
		begin
			if(!mem_to_cont.RESET_N)
				nextMEMState = RESET;
			else
				nextMEMState = POWER_ON;
		end
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
				Command.RD: nextMEMState = READ;
				Command.WR: nextMEMState = WRITE;
				Command.PRE:nextMEMState = PRE_C;
				default:    nextMEMState = BANK_ACT;
			endcase
		end
		READ:   
		begin
			case(command)
				Command.RD: nextMEMState = READ;
				Command.WR: nextMEMState = WRITE;
				Command.PRE:nextMEMState = PRE_C;
				default:    nextMEMState = BANK_ACT;
			endcase
		end
		WRITE: 
		begin
			$display("BA: %1d ADDR: %b", mem_to_cont.BA, mem_to_cont.ADDR);
			case(command)
				Command.RD: nextMEMState = READ;
				Command.WR: nextMEMState = WRITE;
  				Command.NOP:nextMEMState = WRITE;
				Command.PRE:nextMEMState = PRE_C;
				default:    nextMEMState = BANK_ACT;
			endcase
		end
		PRE_C:   nextMEMState   = IDLE;
		default: nextMEMState 	= POWER_ON;
	endcase
end

always_ff @(posedge mem_to_cont.CK, posedge mem_to_cont.CK_N)
begin
	if(MEMState == BANK_ACT)
		col_addr 	<= 0;
	else if(((MEMState == READ) || (MEMState == WRITE)) && (burst_count != 3'b111))
	begin
		col_addr    	<= col_addr + 1;
		burst_count 	<= burst_count + 1;
	end
	else if(burst_count == 3'b111)
	begin
		burst_count	<= 0;
		col_addr 	<= col_addr + 1;
	end 
	else
		burst_count 	<= 0;

	$display("DIN: %b	DOUT: %b	BC: %1d", i_data, o_data, burst_count);
end

assign en_mem		= ((MEMState == READ) || (MEMState == WRITE)) ? 1 : 0;
assign we_n 		= (MEMState == WRITE) ? 0 : 1;
assign i_data 		= (MEMState == WRITE) ? mem_to_cont.DQ : 'bx;
assign mem_to_cont.DQ 	= (MEMState == READ)  ? o_data : 'bz;

sdram_mem MAIN_MEM(
	en_mem,
	mem_to_cont.CK,
	mem_to_cont.CK_N,
	mem_to_cont.BA,
	mem_to_cont.ADDR[14:0],
	col_addr,
	we_n,
	i_data,
	o_data
);
 
endmodule
