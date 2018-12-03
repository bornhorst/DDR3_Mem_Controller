#Makefile for Legacy ICE Mode (Standalone) for VeloceOS3 flow 
#standalone_tutorial_1 
#Author-Sameer Ghewari, April 2015

all: map compile sim

MODE ?= veloce
#MODE ?= puresim

map: 
	vlib work
	vmap work ./work

compile:
	vlog ddr3_mem_pkg.sv
	vlog ddr3_mem_intf.sv
	vlog ddr3_mem_tb.sv
	vlog ddr3_mem_cpu.sv
	vlog ddr3_mem_cont.sv
	vlog ddr3_mem_sdram.sv
	vlog lfsr.sv
	velanalyze ddr3_mem_pkg.sv 
	velanalyze ddr3_mem_intf.sv 
	velanalyze ddr3_mem_tb.sv 
	velanalyze ddr3_mem_cpu.sv
	velanalyze ddr3_mem_cont.sv 
	velanalyze ddr3_mem_sdram.sv
	velanalyze lfsr.sv
	velcomp -top ddr3_mem_tb
	velhvl -sim $(MODE) 

sim:
	vsim -c ddr3_mem_tb -do "run -all; quit"

clean:
	rm -rf work transcript vsim.wlf dpi.so modelsim.ini output.log result.TBX tbxsvlink.log
	rm -rf waves.wlf vsim_stacktrace.vstf sc_dpiheader.h hdl.* debussy.cfg  dmTclClient.log  partition.info 
	rm -rf tbxbindings.h  tbx.dir  tbx.map   veloce_c_transcript dmslogdir    ECTrace.log      Report.out      tbx.log  tbxsim.v  vlesim.log
	rm -rf multiplicand.txt multiplier.txt product.txt veloce.map velrunopts.ini edsenv veloce.log veloce.med veloce.wave work puresimwork 
