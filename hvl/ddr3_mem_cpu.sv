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
	ddr3_cpu_intf.cpu_to_cont	cpu_to_cont
);

// ********** Import Package ********** //
import ddr3_mem_pkg::*;

// ********** Local Variables ********** //
logic	[9:0] 	addr_counter;
logic	[63:0]	temp_data;

parameter 	ADDR_CHANGE 	= 200;

// ********** LFSR ********** //
lfsr LFSR1(cpu_to_cont.WR_DATA, cpu_clk, reset_n, en);
lfsr LFSR2(temp_data, cpu_clk, reset_n, en);

// ********** State Transitions ********** //
always_ff @(posedge cpu_clk, negedge reset_n)
begin

		// initialize after reset
		if(~reset_n)
		begin
			cpu_to_cont.ADDR	<= 0;
			cpu_to_cont.COL		<= 0;
			cpu_to_cont.CMD		<= 0;
			addr_counter		<= 0;
		end
		else
		begin
			// ready to send/receive data w/ address
			if(cpu_to_cont.CMD_RDY)
				cpu_to_cont.ADDR_VALID <= 1;
			else
				cpu_to_cont.ADDR_VALID <= 0;

			// change ba/address/column/command randomly
			if(addr_counter == ADDR_CHANGE)
			begin	
				cpu_to_cont.ADDR	<= temp_data[14:0];
				cpu_to_cont.BA		<= temp_data[17:15];
				cpu_to_cont.CMD		<= temp_data[18];
				addr_counter 		<= 0;
			end
			else
			begin
				cpu_to_cont.COL	<= temp_data[28:19];
				addr_counter 	<= addr_counter + 1;
			end
		end
end

endmodule
