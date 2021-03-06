///////////////////////////////////////////////////////////////////////////////////
//
// ddr3_mem_intf.sv (Group 8)
//
// Description: Wire interfaces for a DDR3 memory system
//
///////////////////////////////////////////////////////////////////////////////////


// ********** Interface ( Controller <-> Memory ) ********* //
interface ddr3_mem_intf(input CPU_CLK, input RESET_N);

	logic 		CK;		// high on posedge cpu clk
	logic		CK_N;		// high on negedge cpu clk
	logic		CKE_N;		// clock enable
	logic		CS_N;		// chip select.. used for command signal
	logic		RAS_N;		// row address strobe
	logic 		CAS_N;		// column address strobe
	logic		WE_N;		// write enable
	logic	[2:0]	BA;		// bank address
	logic	[14:0]	ADDR;		// row address bits
	logic	[9:0]	COL;
	wire	[7:0]	WR_DATA;	// write data bits
	wire	[7:0]	RD_DATA;	// read data bits
	wire		DQS_N;		// data read/write finished
	
// ********** Controller -> Memory ********** //
	modport cont_to_mem(
		output 	CK, CK_N, CKE_N, CS_N, RAS_N, CAS_N, WE_N, BA, ADDR, COL, WR_DATA, 
		inout 	DQS_N,
		input 	RD_DATA
	);

// ********** Memory -> Controller ********** //
	modport mem_to_cont(
		input 	CK, CK_N, CKE_N, CS_N, RAS_N, CAS_N, WE_N, BA, ADDR, COL, WR_DATA, 
		inout	DQS_N,
		output 	RD_DATA
	);

endinterface


// Interface ( Controller <-> CPU ) ********** //
interface ddr3_cpu_intf(input CPU_CLK, input RESET_N, input EN);

	logic		CMD;
	logic		CMD_RDY;
	logic		ADDR_VALID;	// valid address signal
	logic	[2:0]	BA;		// bank address
	logic	[14:0]	ADDR;		// address bits
	logic	[9:0]	COL;
	logic	[63:0]	WR_DATA;	// write data
	logic	[63:0]	RD_DATA;	// read data

// ********** Controller -> CPU ********** //
	modport cont_to_cpu(
		input 	ADDR_VALID, BA, ADDR, WR_DATA, CMD, CMD_RDY, COL,
		output	RD_DATA
	);

// ********** CPU -> Controller ********** //
	modport cpu_to_cont(
		output 	ADDR_VALID, BA, ADDR, WR_DATA, CMD, CMD_RDY, COL,
		input	RD_DATA
	);

endinterface
