vlib work
vlib riviera

vlib riviera/blk_mem_gen_v8_4_2
vlib riviera/xil_defaultlib

vmap blk_mem_gen_v8_4_2 riviera/blk_mem_gen_v8_4_2
vmap xil_defaultlib riviera/xil_defaultlib

vlog -work blk_mem_gen_v8_4_2  -v2k5 \
"../../../ipstatic/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib  -v2k5 \
"../../../../project_2.srcs/sources_1/ip/blk_mem_gen_1/sim/blk_mem_gen_1.v" \


vlog -work xil_defaultlib \
"glbl.v"

