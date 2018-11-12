#####################################################
#
# Makefile for DDR3 SDRAM Controller
#
#####################################################

full:
	vlib work
	vlog ./dut/ddr3_mem_pkg.sv
	vlog ./dut/*.sv
	vlog ./tb/*.sv
	vsim -c work 
	vsim -c ddr3_mem_tb -do "run -all; quit"

compile:
	vlib work
	vlog ./dut/ddr3_mem_pkg.sv
	vlog ./dut/*.sv
	vlog ./tb/*.sv

run: 	
	vsim -c ddr3_mem_tb -do "run -all; quit"

clean:
	rm -rf work transcript vsim.wlf
