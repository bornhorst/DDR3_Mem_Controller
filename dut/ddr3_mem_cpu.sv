/////////////////////////////////////////////////////////////
//
// ddr3_mem_cpu.sv (Group 8)
//
// Description: Instantiation of CPU within Memory System
//
/////////////////////////////////////////////////////////////

// ********** CPU Module ********** //
module ddr3_mem_cpu(
	input logic 			cpu_clk,
	ddr3_cpu_intf.cpu_to_cont	cpu_to_cont
);

// ********** Import Package ********** //
import ddr3_mem_pkg::*;

// ********** Parameters ********** //
parameter MAX_ROW = 32768;
parameter MAX_COL = 128;

parameter START_ROW = 32765;

// ********** Local Variables ********** //
logic	[14:0]	total_counter		= 0;
logic	[4:0]	word_counter		= 0;
logic	[14:0]	row_counter		= 0;
logic	[6:0]	column_counter 		= 0;
logic	[1:0]	reset_wait_counter 	= 0;
logic	[63:0]	wr_data;

// ********** Reset Logic ********** //
assign cpu_to_cont.RESET_N = (CPUState == RESET) ? 0 : 1;

// ********** State Transitions ********** //
always_ff @(posedge cpu_clk)
	CPUState <= CPUnextState;

always_ff @(posedge cpu_clk)
begin
	case(CPUState)
		RESET: 
		begin
			if(reset_wait_counter != 2'b11)
				reset_wait_counter <= reset_wait_counter + 1;
			else
				reset_wait_counter <= 0;
		end
		WRITE:cpu_to_cont.ADDR = row_counter + total_counter;
		READ: cpu_to_cont.ADDR = START_ROW;
		INIT: cpu_to_cont.ADDR = START_ROW;
	endcase
end

always_comb
begin
	case(CPUState)
		POWER_ON: CPUnextState 	= RESET;
		RESET: 
		begin
			if(reset_wait_counter == 2'b11)
				CPUnextState = INIT; 
			else
				CPUnextState = RESET;
		end
		INIT: 
		begin
			row_counter 		= START_ROW;
			column_counter		= 0;

			if(cpu_to_cont.CMD_RDY)
				CPUnextState 	= IDLE;
			else
				CPUnextState 	= INIT;
		end
		IDLE:
		begin
			cpu_to_cont.ADDR_VALID 	= 0;
			cpu_to_cont.BA		= 0;
			cpu_to_cont.CMD		= 0;		

			cpu_to_cont.WR_DATA	= 64'b00000111_00000110_00000101_00000100_00000011_00000010_00000001_00000000;
		
			if((total_counter + START_ROW) < MAX_ROW)
				CPUnextState 	= WRITE;
			else
				CPUnextState	= READ;
		end
		WRITE:
		begin
			cpu_to_cont.ADDR_VALID		= 1;

			if(cpu_to_cont.WR_DATA_VALID == 1)
				word_counter 		= word_counter + 1;

			if(word_counter == 5'b10000)
			begin
				word_counter		= 0;
				column_counter		= column_counter + 1;
				total_counter		= total_counter + 1;
			end

			if((total_counter + START_ROW) < MAX_ROW)
				CPUnextState 		= WRITE;
			else
			begin
				//rc
				cpu_to_cont.ADDR_VALID 	= 0;
				CPUnextState 		= IDLE;
			end
			$display("WC: %2d	 CC: %2d	TR: %d", word_counter, column_counter, total_counter);
		end
		READ: CPUnextState = READ;
		default: CPUnextState 	= POWER_ON;
	endcase
end
 
endmodule
