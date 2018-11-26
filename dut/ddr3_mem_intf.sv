///////////////////////////////////////////////////////////////////////////////////
//
// ddr3_mem_intf.sv (Group 8)
//
// Description: Wire interfaces for a DDR3 memory system
//
///////////////////////////////////////////////////////////////////////////////////


// ********** Interface ( Controller <-> Memory ) ********* //
interface ddr3_mem_intf(input logic CPU_CLK);

	logic 		RESET_N; 	// reset signal
	logic 		CK;		// high on posedge cpu clk
	logic		CK_N;		// high on negedge cpu clk
	logic		CKE_N;		// clock enable
	logic		CS_N;		// chip select.. used for command signal
	logic		RAS_N;		// row address strobe
	logic 		CAS_N;		// column address strobe
	logic		WE_N;		// write enable
	logic	[2:0]	BA;		// bank address
	logic	[14:0]	ADDR;		// row address bits
	wire	[7:0]	DQ;		// data bits
	wire	[7:0]	DM;		// data mask
	wire		DQS;		// data strobe
	
// ********** Controller -> Memory ********** //
	modport cont_to_mem(
		output 	RESET_N, CK, CK_N, CKE_N, CS_N, RAS_N, CAS_N, WE_N, BA, ADDR,
		inout 	DQ, DM, DQS
	);

// ********** Memory -> Controller ********** //
	modport mem_to_cont(
		input 	RESET_N, CK, CK_N, CKE_N, CS_N, RAS_N, CAS_N, WE_N, BA, ADDR,
		inout 	DQ, DM, DQS
	);

endinterface


// Interface ( Controller <-> CPU ) ********** //
interface ddr3_cpu_intf(input logic CPU_CLK);

	logic		RESET_N;	// reset signal
	logic		ADDR_VALID;	// valid address signal
	logic		CMD_RDY;	// controller ready for cpu cmd
	logic		CMD;		// command from cpu rd/wr#
	logic		WR_DATA_VALID;	// write data valid
	logic		RD_DATA_VALID;	// read data valid
	logic	[2:0]	BA;		// bank address
	logic	[14:0]	ADDR;		// address bits
	logic	[63:0]	WR_DATA;	// write data
	logic	[7:0]	DM;		// data mask
	logic	[63:0]	RD_DATA;	// read data

// ********** Controller -> CPU ********** //
	modport cont_to_cpu(
		input 	RESET_N, ADDR_VALID, CMD, BA, ADDR, WR_DATA, DM,
		output	CMD_RDY, WR_DATA_VALID, RD_DATA_VALID, RD_DATA
	);

// ********** CPU -> Controller ********** //
	modport cpu_to_cont(
		output 	RESET_N, ADDR_VALID, CMD, BA, ADDR, WR_DATA, DM,
		input	CMD_RDY, WR_DATA_VALID, RD_DATA_VALID, RD_DATA
	);
	
endinterface
