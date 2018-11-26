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
logic	[2:0]	bank_addr;	// bank address
logic	[14:0]	row_addr;	// row address
logic	[2:0]	data_counter;	// process data in bursts of 8
logic		row_latch_en;	// enable row latch
logic	[14:0]	previous_row;	// store the previous row
logic	[2:0]	previous_bank;	// store the previous bank
logic		AP; 		// auto precharge
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
		Command.ZQC	<= 4'b0110;	// ZQ Calibration
		State 		<= RESET;	
	end
	else
		State <= nextState;		// Progress state
end

// ********** Assign Controller -> Memory Signals ********** //
assign cont_to_mem.RESET_N 	= cont_to_cpu.RESET_N;
assign cont_to_mem.ADDR		= row_addr;
assign cont_to_mem.BA		= cont_to_cpu.BA;
assign cont_to_mem.CKE_N	= (State == RESET)    ? 0 : ((State > RESET) ? 1 : 'bx); 
assign cont_to_mem.CK		= (cont_to_mem.CKE_N) ? ((cpu_clk)  ? 1 : 0) : 'bx; 
assign cont_to_mem.CK_N		= (cont_to_mem.CKE_N) ?	((~cpu_clk) ? 1 : 0) : 'bx;

// ********** Assign Command Signals ********** //
assign AP	= cont_to_cpu.ADDR[10];
assign {cont_to_mem.CS_N, cont_to_mem.RAS_N, cont_to_mem.CAS_N, cont_to_mem.WE_N} = command;

// ********** Latch Row Address ********** //
always_latch
begin
	if(row_latch_en)
	begin
		bank_addr 	<= cont_to_cpu.BA;
		row_addr	<= cont_to_cpu.ADDR;
	end
end

// ********** Read Signals ********** //


// ********** Write Signals ********** //


// ********** State Transitions ********** //
always_comb
begin
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
			command		= Command.ZQC;
			nextState 	= IDLE;
		end
		IDLE: 
		begin			
			command		= Command.ACT;	
			nextState 	= ACTIVATE;
		end
		ACTIVATE: nextState 	= BANK_ACT;
		BANK_ACT: 
		begin
			cont_to_cpu.CMD_RDY	= 1;

			if(row_addr != cont_to_cpu.ADDR)
			begin
				command		= Command.PRE;
				nextState 	= PRE_C;
			end
			else if(cont_to_cpu.CMD)
			begin
				command		= Command.RD;
				nextState 	= READ;
			end
			else if(~cont_to_cpu.CMD)
			begin
				command		= Command.WR;
				nextState	= WRITE;
			end
			else 
				nextState 	= BANK_ACT;
		end		
		READ:
		begin
			if(row_addr != cont_to_cpu.ADDR)
			begin
				command		= Command.PRE;
				nextState 	= PRE_C;
			end
			else if(cont_to_cpu.CMD)
			begin
				command		= Command.RD;
				nextState 	= READ;
			end
			else if(~cont_to_cpu.CMD)
			begin
				command		= Command.WR;
				nextState	= WRITE;
			end
			else 
				nextState 	= BANK_ACT;

		end
		WRITE: 
		begin
			if(row_addr != cont_to_cpu.ADDR)
			begin
				command		= Command.PRE;
				nextState 	= PRE_C;
			end
			else if(cont_to_cpu.CMD)
			begin
				command		= Command.RD;
				nextState 	= READ;
			end
			else if((~cont_to_cpu.CMD) && (cont_to_cpu.WR_DATA_VALID))
			begin
				command		= Command.WR;
				nextState	= WRITE;
			end
			else if((~cont_to_cpu.CMD) && (~cont_to_cpu.WR_DATA_VALID))
			begin
				command		= Command.NOP;
				nextState	= WRITE;
			end
			else 
				nextState 	= BANK_ACT;

		end
		PRE_C: nextState = IDLE;
		default: nextState = POWER_ON;
	endcase
end

assign row_latch_en = ((command == Command.ACT) || (command == Command.RD) || (command == Command.WR)) ? 1 : 0;

always_ff @(posedge cont_to_mem.CK, posedge cont_to_mem.CK_N)
begin
	if(data_counter == 3'b111)
		cont_to_cpu.WR_DATA_VALID	<= 1;
	else
		cont_to_cpu.WR_DATA_VALID	<= 0;

	if((State == WRITE) && (data_counter != 3'b111))
		data_counter <= data_counter + 1;
	else
		data_counter <= 0;
	$display("DC: %1d", data_counter);
end


assign cont_to_mem.DQ = ((State == WRITE) && (data_counter == 0)) ? cont_to_cpu.WR_DATA[7:0]  : 'bz;
assign cont_to_mem.DQ = ((State == WRITE) && (data_counter == 1)) ? cont_to_cpu.WR_DATA[15:8] : 'bz; 
assign cont_to_mem.DQ = ((State == WRITE) && (data_counter == 2)) ? cont_to_cpu.WR_DATA[23:16]: 'bz;
assign cont_to_mem.DQ = ((State == WRITE) && (data_counter == 3)) ? cont_to_cpu.WR_DATA[31:24]: 'bz; 
assign cont_to_mem.DQ = ((State == WRITE) && (data_counter == 4)) ? cont_to_cpu.WR_DATA[39:32]: 'bz;
assign cont_to_mem.DQ = ((State == WRITE) && (data_counter == 5)) ? cont_to_cpu.WR_DATA[47:40]: 'bz;
assign cont_to_mem.DQ = ((State == WRITE) && (data_counter == 6)) ? cont_to_cpu.WR_DATA[55:48]: 'bz; 
assign cont_to_mem.DQ = ((State == WRITE) && (data_counter == 7)) ? cont_to_cpu.WR_DATA[63:56]: 'bz; 
  	
endmodule	
