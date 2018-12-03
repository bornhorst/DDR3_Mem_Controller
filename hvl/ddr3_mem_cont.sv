//////////////////////////////////////////////////////////////////
//
// ddr3_mem_cont.sv (Group 8)
//
// Description: Memory controller for a 256M x 8 DDR3 SDRAM
//		Utilizing 6-6-6 Timing 
//
//////////////////////////////////////////////////////////////////

// ********** Controller Module ********** //
module ddr3_mem_cont(
	input 				cpu_clk,
	input				reset_n,
	input				en,
	ddr3_cpu_intf.cont_to_cpu	cont_to_cpu,
	ddr3_mem_intf.cont_to_mem	cont_to_mem
);

// ********** Import Package ********** //
import ddr3_mem_pkg::*;

// ********** Local Variables ********** //
logic	[2:0]	ba;		// bank address
logic	[14:0]  ra;		// row address
logic	[63:0]	readdata;
logic	[3:0]	command;	// command signal from CPU for reading/writing
logic	[2:0]	wait_counter;

// ********** Timing Parameters ********** //
parameter	tCL	= 6;		// command to data out (clock cycles)   **
parameter	tRP	= 6;		// precharge to activate (clock cycles) **
parameter	tRCD	= 6;		// activate to rd/wr (clock cycles)

// ********** Assertion Properties ********** //
property act_to_cmd;
	@(posedge cpu_clk)
		(Command.ACT) |-> ##tRCD ((Command.RD) or (Command.WR));
endproperty

property pre_to_act;
	@(posedge cpu_clk)
		(Command.PRE) |-> ##tRP (Command.ACT);
endproperty

property cmd_to_data;
	@(posedge cpu_clk)
		(Command.PRE) |-> ##tCL ((Command.RD) or (Command.WR));
endproperty
	
assert property(act_to_cmd);
cover  property(act_to_cmd);
assert property(pre_to_act);
cover  property(pre_to_act);
assert property(cmd_to_data);
cover  property(cmd_to_data);

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
assign cont_to_mem.ADDR	= ra;
assign cont_to_mem.BA	= ba;
assign cont_to_mem.CKE_N= (State == RESET)    	? 0 : ((State > RESET) ? 1 : 'bz); 
assign cont_to_mem.CK	= (cont_to_mem.CKE_N) 	? ((cpu_clk)  ? 1 : 0) : 'bz; 
assign cont_to_mem.CK_N	= (cont_to_mem.CKE_N) 	? ((~cpu_clk) ? 1 : 0) : 'bz;
assign cont_to_mem.COL	= cont_to_cpu.COL >> 3;

// ********** Assign Command Signals ********** //
assign {cont_to_mem.CS_N, cont_to_mem.RAS_N, cont_to_mem.CAS_N, cont_to_mem.WE_N} = command;

// ********** State Transitions ********** //
always_comb
begin
	unique case(State)
		RESET: 
		begin	
			ba	= 0;
			ra	= 0;

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
				command		= Command.PRE;
				nextState 	= PRE_C;
			end
			else
				nextState 	= INIT;
		end
		IDLE: 
		begin			
			command		= Command.ACT;	
			nextState 	= ACTIVATE;
		end
		ACTIVATE: 
		begin
			command			= Command.NOP;
			if(wait_counter == tRCD-1) 
				nextState 	= BANK_ACT; 
			else 
				nextState 	= ACTIVATE;
		end
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
			else if(cont_to_cpu.CMD)
			begin
				command		= Command.RD;
				nextState 	= READ0;
			end
			else if(~cont_to_cpu.CMD)
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
			command			= Command.NOP;
			nextState 		= READ1;
		end
		READ1: 
		begin
			command			= Command.NOP;
			nextState 		= READ2;
		end

		READ2: 
		begin
			command			= Command.NOP;
			nextState 		= READ3;
		end
		READ3: 
		begin
			if(ra != cont_to_cpu.ADDR)
			begin
				command		= Command.PRE;
				nextState 	= PRE_C;
			end
			else if(cont_to_cpu.CMD)
			begin
				command		= Command.RD;
				nextState	= READ0;
			end
			else if(~cont_to_cpu.CMD)
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
			else if(cont_to_cpu.CMD)
			begin
				command		= Command.RD;
				nextState	= BANK_ACT;
			end
			else if(~cont_to_cpu.CMD)
			begin
				command		= Command.WR;
				nextState	= WRITE0;
			end
			else
				nextState	= BANK_ACT;
		end
		PRE_C:  
		begin
			command = Command.NOP;
			if(wait_counter == tRP-1)
			begin
				ba 		= cont_to_cpu.BA;
				ra 		= cont_to_cpu.ADDR;
				nextState 	= IDLE;
			end
			else
				nextState 	= PRE_C;
		end
		default:nextState 	= RESET;
	endcase
end

// ********** Wait Counter ********** //
always_ff @(posedge cpu_clk)
begin
	if(((State == ACTIVATE)||(State == PRE_C)) && (wait_counter == tRCD-1))
		wait_counter <= 0;
	else if((State == ACTIVATE)||(State == PRE_C))
		wait_counter <= wait_counter + 1;
	else
		wait_counter <= 0;
end

// ********** Data Ready Signal ********** //
assign cont_to_mem.DQS_N = ((State == WRITE0)||(State == WRITE1)||(State == WRITE2)||(State == WRITE3)) ? 0 : 1;

// ********** Read Data (negedge) ********** //
always_ff @(posedge cont_to_mem.CK_N)
begin
	case(State)
	READ0: 	readdata[7:0]	<= cont_to_mem.RD_DATA;	
	READ1: 	readdata[23:16]	<= cont_to_mem.RD_DATA;	
	READ2: 	readdata[39:32]	<= cont_to_mem.RD_DATA;	
	READ3:  readdata[55:48]	<= cont_to_mem.RD_DATA;	
	default:readdata	<= 'bz;
	endcase
end

// ********** Read Data (posedge) ********** //
always_ff @(posedge cont_to_mem.CK)
begin
	case(State)
	READ0: 	readdata[15:8]	<= cont_to_mem.RD_DATA;	
	READ1: 	readdata[31:24]	<= cont_to_mem.RD_DATA;	
	READ2: 	readdata[47:40]	<= cont_to_mem.RD_DATA;	
	READ3:  readdata[63:56]	<= cont_to_mem.RD_DATA;	
	default:readdata	<= 'bz;
	endcase
end

// *********** Send Data to CPU ********** //
assign cont_to_cpu.RD_DATA = ((~cont_to_mem.DQS_N)&&(cont_to_mem.CK)) ? readdata : 'bx;

// ********** Write to Memory ********** //
assign cont_to_mem.WR_DATA = 	((State == WRITE0) && (cont_to_mem.CK_N))	? cont_to_cpu.WR_DATA[7:0]  :
				((State == WRITE0) && (cont_to_mem.CK)) 	? cont_to_cpu.WR_DATA[15:8] :
				((State == WRITE1) && (cont_to_mem.CK_N))	? cont_to_cpu.WR_DATA[23:16]:
				((State == WRITE1) && (cont_to_mem.CK))		? cont_to_cpu.WR_DATA[31:24]: 
				((State == WRITE2) && (cont_to_mem.CK_N))	? cont_to_cpu.WR_DATA[39:32]: 
				((State == WRITE2) && (cont_to_mem.CK))		? cont_to_cpu.WR_DATA[47:40]: 
				((State == WRITE3) && (cont_to_mem.CK_N))	? cont_to_cpu.WR_DATA[55:48]: 
				((State == WRITE3) && (cont_to_mem.CK))		? cont_to_cpu.WR_DATA[63:56]: 'bz;

endmodule	
