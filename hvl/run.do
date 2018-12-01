configure -emul velocesolo1
reg setvalue ddr3_mem_tb.reset_n 1
run 10
reg setvalue ddr3_mem_tb.reset_n 0
run 10
reg setvalue ddr3_mem_tb.reset_n 1
reg setvalue ddr3_mem_tb.en 1
run 5000
upload -tracedir ./veloce.wave/wave1

exit 
