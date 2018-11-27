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
parameter MAX_ROW = 32768;	// total rows in memory
parameter MAX_COL = 1024;	// total columns in memory

parameter START_ROW = 32765;	// row to start simulation
parameter STOP_ROW  = 32767;	// row to stop simulation

// ********** Local Variables ********** //
logic	[4:0]	word_counter		= 0;	// count 64 bit words written
logic	[14:0]	row_counter		= 0;	// count all rows written to
logic	[1:0]	reset_wait_counter 	= 0;	// give reset time

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
		IDLE: cpu_to_cont.ADDR 	<= START_ROW;
		WRITE:cpu_to_cont.ADDR 	<= START_ROW + row_counter;
		READ: cpu_to_cont.ADDR 	<= START_ROW;
		INIT: cpu_to_cont.ADDR 	<= START_ROW;
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
			if(cpu_to_cont.CMD_RDY)
				CPUnextState 	= IDLE;
			else
				CPUnextState 	= INIT;
		end
		IDLE:
		begin
			cpu_to_cont.WR_READY		= 0;
			cpu_to_cont.ADDR_VALID 		= 0;
			cpu_to_cont.BA			= 0;
			cpu_to_cont.CMD			= 0;		

			cpu_to_cont.WR_DATA		= 64'b00000111_00000110_00000101_00000100_00000011_00000010_00000001_00000000;
		
			if((row_counter + START_ROW) > STOP_ROW)
				CPUnextState 		= IDLE;
			else
			begin
				cpu_to_cont.WR_READY	= 1;
				cpu_to_cont.ADDR_VALID	= 1;
				CPUnextState		= WRITE;
			end
		end
		WRITE:
		begin
			if(cpu_to_cont.WR_DATA_VALID == 1)
				word_counter 		= word_counter + 1;

			if(word_counter == 5'b10000)
			begin	
				word_counter		= 0;
				row_counter		= row_counter + 1;
			end

			if(((row_counter + START_ROW) > STOP_ROW) && (row_counter == (STOP_ROW - START_ROW) + 1))
			begin
				cpu_to_cont.ADDR_VALID	= 0;
				cpu_to_cont.WR_READY	= 0;
				CPUnextState 		= IDLE;
			end
			else
				CPUnextState		= WRITE;

			$display($time,"  WC: %2d	 RC: %d		ROW: %5d", word_counter, row_counter, (START_ROW + row_counter));
		end
		READ: CPUnextState = READ;
		default: CPUnextState 	= POWER_ON;
	endcase
end
 
endmodule
