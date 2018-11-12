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
	logic 		CLK_N		// negedge cpu clock
	logic		CKE_N;		// clock enable
	logic		CS_N;		// chip select** may not be used
	logic		RAS_N;		// row address strobe
	logic 		CAS_N;		// column address strobe
	logic		WE_N;		// write enable
	logic	[2:0]	BA;		// bank address
	logic	[14:0]	ADDR;		// row address bits
	wire	[7:0]	DQ;		// data bits
	wire		DM;		// data mask
	wire		DQS;		// data strobe
	
// ********** Controller -> Memory ********** //
	modport mem_cont_signals(
		output 	RESET_N, CLK_N, CKE_N, CS_N, RAS_N, CAS_N, WE_N, BA, ADDR,
		inout 	DQ, DM, DQS
	);

// ********** Memory -> Controller ********** //
	modport main_mem_signals(
		input 	RESET_N, CLK_N, CKE_N, CS_N, RAS_N, CAS_N, WE_N, BA, ADDR,
		inout 	DQ, DM, DQS
	);

endinterface


// Interface ( Controller <-> CPU ) ********** //
interface ddr3_cpu_intf(input logic CPU_CLK);

	logic		RESET;		// reset signal
	logic		CMD;		// read/write command
	logic		ADDR_VALID;	// valid address signal
	logic		CS;		// chip select** may not be used
	logic		RD_DATA_RDY;	// read data ready
	logic		RD_DATA_VALID;	// read data valid
	logic	[31:0]	ADDR;		// address bits
	logic	[63:0]	WR_DATA;	// write data
	logic	[7:0]	DM;		// data mask
	logic	[63:0]	RD_DATA;	// read data

// ********** Controller -> CPU ********** //
	modport mem_controller(
		input 	RESET, CMD, ADDR_VALID, CS, ADDR, WR_DATA, DM,
		output	RD_DATA_RDY, RD_DATA_VALID, RD_DATA
	);

// ********** CPU -> Controller ********** //
	modport cpu(
		output 	RESET, CMD, ADDR_VALID, CS, ADDR, WR_DATA, DM,
		input	RD_DATA_RDY, RD_DATA_VALID, RD_DATA
	);

endinterface
