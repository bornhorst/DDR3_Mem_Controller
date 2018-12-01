//////////////////////////////////////////////////////////////////
//
// ddr3_mem_cont.sv (Group 8)
//
// Description: Memory controller for a 256M x 8 DDR3 SDRAM
//
//////////////////////////////////////////////////////////////////

// ********** Controller Module ********** //
module ddr3_mem_cont(
	input 				cpu_clk,
	input				reset_n,
	input				en,
	input				cmd,
	ddr3_cpu_intf.cont_to_cpu	cont_to_cpu,
	ddr3_mem_intf.cont_to_mem	cont_to_mem
);

// ********** Import Package ********** //
import ddr3_mem_pkg::*;

// ********** Local Variables ********** //
logic	[2:0]	ba;		// bank address
logic	[14:0]  ra;		// row address
logic	[7:0] 	wr1;
logic	[7:0] 	wr2;
logic	[3:0]	command;	// command signal from CPU for reading/writing

// ********** Reset Device ********* //
always_ff @(posedge cpu_clk, negedge reset_n)
begin
	if(~reset_n)				// Reset to default state
	begin
		Command.PRE	<= 4'b0010;	// Precharge Bank/Row
		Command.ACT	<= 4'b0011;	// Activate Bank/Row
		Command.WR	<= 4'b0100;	// Write
		Command.RD	<= 4'b0101;	// Read
		Command.NOP	<= 4'b0111;	// No Operation
		Command.ZQC	<= 4'b0110;	// ZQ Calibration

		State 		<= RESET;	
	end
	else
		State 		<= nextState;	// Progress state
end

// ********** Assign Controller -> Memory Signals ********** //
assign cont_to_mem.RESET_N 	= reset_n;
assign cont_to_mem.ADDR		= ra;
assign cont_to_mem.BA		= ba;
assign cont_to_mem.CKE_N	= (State == RESET)    		? 0 : ((State > RESET) ? 1 : 'bz); 
assign cont_to_mem.CK		= (cont_to_mem.CKE_N) 		? ((cpu_clk)  ? 1 : 0) : 'bz; 
assign cont_to_mem.CK_N		= (cont_to_mem.CKE_N) 		? ((~cpu_clk) ? 1 : 0) : 'bz;
assign cont_to_mem.COL		= cont_to_cpu.COL;

// ********** Assign Command Signals ********** //
assign {cont_to_mem.CS_N, cont_to_mem.RAS_N, cont_to_mem.CAS_N, cont_to_mem.WE_N} = command;

// ********** State Transitions ********** //
always_comb
begin
	unique case(State)
		RESET: 
		begin	
			ba	= 0;
			ra	= 9999;

			command = Command.NOP;

			if(reset_n)
				nextState = INIT;
			else
				nextState = RESET; 
		end
		INIT: 
		begin
			if(en)
			begin
				command		= Command.ZQC;
				nextState 	= IDLE;
			end
			else
				nextState 	= INIT;
		end
		IDLE: 
		begin			
			command		= Command.ACT;	
			nextState 	= ACTIVATE;
		end
		ACTIVATE: nextState 	= BANK_ACT;
		BANK_ACT: 
		begin
			cont_to_cpu.CMD_RDY = 1;		

		if(cont_to_cpu.ADDR_VALID)
		begin
			cont_to_cpu.CMD_RDY = 0;

			if(ra != cont_to_cpu.ADDR)
			begin
				command 	= Command.PRE;
				nextState	= PRE_C;
			end
			else if(cmd)
			begin
				command		= Command.RD;
				nextState 	= READ0;
			end
			else if(~cmd)
			begin
				command		= Command.WR;
				nextState	= WRITE0;
			end
			else
				nextState 	= BANK_ACT;
		end
		else
			nextState = BANK_ACT;
		end		
		READ0: 
		begin
			cont_to_cpu.RD_DATA[15:0] = cont_to_mem.RD_DATA;
			command			= Command.NOP;
			nextState 		= READ1;
		end
		READ1: 
		begin
			cont_to_cpu.RD_DATA[31:16] = cont_to_mem.RD_DATA;
			command			= Command.NOP;
			nextState 		= READ2;
		end

		READ2: 
		begin
			cont_to_cpu.RD_DATA[47:32] = cont_to_mem.RD_DATA;
			command			= Command.NOP;
			nextState 		= READ3;
		end
		READ3: 
		begin
			cont_to_cpu.RD_DATA[63:48] = cont_to_mem.RD_DATA;

			if(ra != cont_to_cpu.ADDR)
			begin
				command		= Command.PRE;
				nextState 	= PRE_C;
			end
			else if(cmd)
			begin
				command		= Command.RD;
				nextState	= READ0;
			end
			else if(~cmd)
			begin
				command		= Command.WR;
				nextState	= BANK_ACT;
			end
			else
				nextState	= BANK_ACT;

		end
		WRITE0: 
		begin
			command			= Command.NOP;
			nextState 		= WRITE1;
		end
		WRITE1: 
		begin
			command		= Command.NOP;
			nextState 	= WRITE2;
		end
		WRITE2: 
		begin
			command		= Command.NOP;
			nextState 	= WRITE3;
		end
		WRITE3:  
		begin
			if(ra != cont_to_cpu.ADDR)
			begin
				command		= Command.PRE;
				nextState 	= PRE_C;
			end
			else if(cmd)
			begin
				command		= Command.RD;
				nextState	= BANK_ACT;
			end
			else if(~cmd)
			begin
				command		= Command.WR;
				nextState	= WRITE0;
			end
			else
				nextState	= BANK_ACT;
		end
		PRE_C:  
		begin
			ba = cont_to_cpu.BA;
			ra = cont_to_cpu.ADDR;
			nextState = IDLE;
		end
		default:nextState = RESET;
	endcase
end

always_comb
	$display($time, "  WRITE_DATA: %b   READ_DATA: %b", cont_to_mem.WR_DATA, cont_to_cpu.RD_DATA);

assign cont_to_mem.WR_DATA = 	(State == WRITE0) ? cont_to_cpu.WR_DATA[15:0] :
				(State == WRITE1) ? cont_to_cpu.WR_DATA[31:16]:
				(State == WRITE2) ? cont_to_cpu.WR_DATA[47:32]:
				(State == WRITE3) ? cont_to_cpu.WR_DATA[63:48]: 'bz;

endmodule	
