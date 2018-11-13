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
		POWER_ON,
		RESET,
		INIT,
		IDLE,
		SELF_REFRESH,
		REFRESH,
		ACTIVATE,
		BANK_ACTIVATE,
		READ,
		READ_A,
		WRITE,
		WRITE_A,
		PRECHARGE
	} ddr3_states;

	ddr3_states State, nextState;

endpackage
