view wave
dataset open ./veloce.wave/wave1.stw wave1
wave add -d wave1 ddr3_mem_tb.cpu_clk ddr3_mem_tb.en ddr3_mem_tb.cmd ddr3_mem_tb.reset_n {ddr3_mem_tb.cont_mem.WR_DATA[15:0]} {ddr3_mem_tb.cont_cpu.RD_DATA[15:0]}
echo "wave1.stw loaded and signals added. Open the Wave window to observe outputs."
