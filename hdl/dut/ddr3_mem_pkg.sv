////////////////////////////////////////////////////////////
//
// ddr3_mem_pkg.sv (Group 8)
//
// Description: Package for DDR3 Memory System
//
////////////////////////////////////////////////////////////

// ********** DDR3 Memory Package ********** //
package ddr3_mem_pkg;

// ********** Memory Control States ********** //
	typedef enum{
		RESET,		// Reset Device
		INIT,		// Program Mode Registers
		IDLE,		// Wait State
		ACTIVATE,	// Activate
		BANK_ACT,	// Activate bank
		READ0,	
		READ1,
		READ2,
		READ3,
		WRITE0,
		WRITE1,
		WRITE2,
		WRITE3,	
		PRE_C		// Precharge row
	} ddr3_states;

	ddr3_states State, nextState;
	ddr3_states CPUState, nextCPUState;
	ddr3_states MEMState, nextMEMState;

// ********** Memory Command Signals ********** //
	typedef	struct packed{
		logic	[3:0]	PRE,	// Precharge row
				ACT,	// Activate bank
				WR,	// Write
				RD,	// Read
				NOP,	// Do nothing
				ZQC;	// ZQ calibration
	} ddr3_commands;

	ddr3_commands Command;

// ********** Mode Registers ********** //
struct{
	logic	[2:0]	BA	= 3'b000; // bank address
	logic	[2:0]	RES	= 3'b000; // reserved
	logic		PPD 	= 0;	  // precharge prop delay
	logic	[2:0]	WR	= 3'b001; // write recovery
	logic		DLL	= 0;	  // DLL control
	logic		TM	= 0;	  // test mode
	logic	[2:0]	CL2	= 3'b010; // cas latency upper
	logic		RBT	= 0;	  // read burst type
	logic		CL1	= 0;	  // cas latency lower
	logic	[1:0]	BL	= 2'b00;  // burst length
} MR0;

struct{
	logic	[2:0]	BA	= 3'b001; // bank address
	logic	[2:0]	RES3	= 3'b000; // reserved
	logic		Q_OFF	= 0;	  // output buffer enable
	logic		TDQS	= 0;	  // TDQS enable
	logic		RES2	= 0;	  // reserved
	logic		RTT3	= 0;	  // Rtt_Nom upper
	logic		RES1	= 0;	  // reserverd
	logic		WL	= 0;	  // write leveling enable
	logic		RTT2	= 0;	  // Rtt_Nom mid
	logic		DIC2	= 0;      // driver impedence control
	logic	[1:0]	AL	= 2'b00;  // additive latency
	logic		RTT1	= 0;	  // Rtt_Nom low
	logic		DIC1	= 0;	  // driver impedence control
	logic		DLL	= 0;	  // DLL enable
} MR1;

struct{
	logic	[2:0]	BA	= 3'b010; // bank address
	logic	[4:0]	RES2	= 3'b000; // reserved
	logic	[1:0]	RTTW	= 2'b00;  // Rtt_WR impedence
	logic		RES1	= 0;	  // reserved
	logic		SRT	= 0;	  // self refresh temp range
	logic		ASR	= 0;	  // auto self refresh enable
	logic	[2:0]	CWL	= 3'b001; // cas write latency
	logic	[2:0]   PASR	= 3'b000; // partial array self refresh
} MR2;

struct{
	logic	[2:0]	BA	= 3'b011; // bank address
	logic	[12:0]	RES	= 0;	  // reserved
	logic		MPR	= 0;	  // multi purpose register
	logic	[1:0]	MPR_L	= 2'b00;  // MPR location
} MR3;

endpackage
