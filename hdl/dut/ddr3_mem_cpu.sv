/////////////////////////////////////////////////////////////
//
// ddr3_mem_cpu.sv (Group 8)
//
// Description: Instantiation of CPU within Memory System
//
/////////////////////////////////////////////////////////////

// ********** CPU Module ********** //
module ddr3_mem_cpu(
	input 	 			cpu_clk,
	input				reset_n,
	input				en,
	input				cmd,	
	ddr3_cpu_intf.cpu_to_cont	cpu_to_cont
);

// ********** Import Package ********** //
import ddr3_mem_pkg::*;

// ********** Local Variables ********** //
logic	[14:0]  row_addr	= 1;
logic	[14:0]	addr_inc	= 0;
logic	[63:0]	data		= 0;

// ********** State Transitions ********** //
always_ff @(posedge cpu_clk, negedge reset_n)
begin
	if(~reset_n)
		CPUState 		<= RESET;
	else
		CPUState 		<= nextCPUState;
end

always_ff @(posedge cpu_clk)
begin
	cpu_to_cont.BA			<= 0;

	if(~reset_n)
		cpu_to_cont.ADDR	<= 0;
	else if(cmd == 1)
	begin
		cpu_to_cont.ADDR	<= 0;
		addr_inc		<= 0;
	end
	else if(addr_inc == 20)
	begin
		addr_inc		<= 0;
		cpu_to_cont.ADDR	<= cpu_to_cont.ADDR + 1;
	end
	else if(CPUState > ACTIVATE)
		addr_inc		<= addr_inc + 1;
	else
	begin
		addr_inc		<= addr_inc;
		cpu_to_cont.ADDR	<= cpu_to_cont.ADDR;
	end
end

always_comb
begin
	case(CPUState)
		RESET: if(reset_n) nextCPUState = INIT;
		INIT: 
		begin
	 		if(en)
				nextCPUState = IDLE;
			else
				nextCPUState = INIT;
		end
		IDLE:    nextCPUState = ACTIVATE;
		ACTIVATE:
		begin
			cpu_to_cont.ADDR_VALID 	= 1;
			cpu_to_cont.WR_DATA	= 64'h77_66_55_44_33_22_11_00;

			nextCPUState = BANK_ACT;
		end
		BANK_ACT:
		begin
			if(row_addr != cpu_to_cont.ADDR)
				nextCPUState = PRE_C;
			else if(cmd)
				nextCPUState = READ0;
			else if(~cmd)
				nextCPUState = WRITE0;
			else
				nextCPUState = BANK_ACT;
		end	
		READ0:  
		begin
			cpu_to_cont.ADDR_VALID 	= 0;
			nextCPUState 		= READ1;
		end
		READ1: nextCPUState = READ2;
		READ2: nextCPUState = READ3;
		READ3: 
		begin
			if(row_addr != cpu_to_cont.ADDR)
				nextCPUState = PRE_C;
			else if(cmd)	
				nextCPUState = READ0;
			else if(~cmd)
				nextCPUState = BANK_ACT;
		end
		WRITE0:  
		begin
			cpu_to_cont.ADDR_VALID 	= 0;
			nextCPUState 		= WRITE1;
		end
		WRITE1: nextCPUState = WRITE2;
		WRITE2: nextCPUState = WRITE3;
		WRITE3: 
		begin
			if(row_addr != cpu_to_cont.ADDR)
				nextCPUState = PRE_C;
			else if(cmd)	
				nextCPUState = BANK_ACT;
			else if(~cmd)
				nextCPUState = WRITE0;
		end
		PRE_C: 
		begin
			row_addr = cpu_to_cont.ADDR;
			nextCPUState = IDLE;
		end
		default: nextCPUState = RESET;
	endcase
end

endmodule
