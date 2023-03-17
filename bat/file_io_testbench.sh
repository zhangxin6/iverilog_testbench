#!/bin/bash
testbench=file_io_testbench

IVERILOG=/opt/iverilog/bin/iverilog
VVP=/opt/iverilog/bin/vvp
GTKWAVE=/usr/bin/gtkwave

SRC_DIR=/mnt/sda1/connect_test/iverilog_testbench
IP_DIR=/mnt/sda1/connect_test/ip_manger/ip_manger.srcs/sources_1/ip/
SIM_OUT=/mnt/sda1/connect_test/sim

if [ ! -d "$SIM_OUT" ]; then
       mkdir $SIM_OUT
fi       
src="$SRC_DIR/file_io_testbench.v $SRC_DIR/data_gen.v $SRC_DIR/connect_domain_get.v"

ip1="$IP_DIR/delay_1hang/simulation/blk_mem_gen_v8_4.v"
ip2="$IP_DIR/delay_1hang/sim/delay_1hang.v"

VIVADO_DIR=/opt/Xilinx/Vivado/2018.3/data/verilog/src/
VIVADO_LIB="-y$VIVADO_DIR -y$VIVADO_DIR/retarget -y$VIVADO_DIR/unifast -y$VIVADO_DIR/unimacro -y$VIVADO_DIR/unisims -y$VIVADO_DIR/xeclib"
echo "Compile..."
$IVERILOG -g2012 -o $SIM_OUT/$testbench.vvp $VIVADO_LIB $src $ip1 $ip2 $VIVADO_DIR/glbl.v
status=$?
if [ $status -ne 0 ];then
	echo "Compile fail($status)."
	exit $status;
fi
echo "Generate wave file..."
cd $SIM_OUT
$VVP "$SIM_OUT/${testbench}.vvp"
status=$?
if [ $status -ne 0 ];then
	echo "Generate wave file fail($status)."
	exit $status;
fi
cd ..
echo "Open wavefile."
gtkw_file="$SIM_OUT/${testbench}.gtkw"
echo "$GTKWAVE"
if [ -f $gtkw_file ]; then
       	$GTKWAVE $gtkw_file
else
	$GTKWAVE "$SIM_OUT/${testbench}.vcd"
fi
