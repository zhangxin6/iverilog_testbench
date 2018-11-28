@echo off
set testbench=dsp_hdlc_ctrl_testbench

set iverilog_path=c:\iverilog\bin;
set gtkwave_path=c:\iverilog\gtkwave\bin;
set path=%iverilog_path%%gtkwave_path%%path%

set dir=C:\Users\zhang\iverilog_testbench
set ip_dir=C:\Users\zhang\manage_ip
set batdir=C:\Users\zhang\iverilog_testbench\bat

set s1=%dir%\dsp_hdlc_ctrl_testbench.v 
set s2=%dir%\dsp_hdlc_ctrl.v 
set s3=%dir%\insert0.v
set s4=%dir%\flag_i0.v
set s5=%dir%\hdlctra.v

set ip1="%ip_dir%\flag_insert0_ram\sim\flag_insert0_ram.v"
set ip2="%ip_dir%\flag_insert0_ram\simulation\blk_mem_gen_v8_4.v"
set ip3="%ip_dir%\insert0_ram\sim\insert0_ram.v"
set ip4="%ip_dir%\hdlc_tx_ram\sim\hdlc_tx_ram.v"


set vivado_dir=C:\Xilinx\Vivado\2015.1\data\verilog\src
set vivado_lib="-y%vivado_dir%" "-y%vivado_dir%\retarget" "-y%vivado_dir%\unifast" "-y%vivado_dir%\unimacro" "-y%vivado_dir%\unisims" "-y%vivado_dir%\xeclib"

iverilog -g2012 -o "%batdir%\%testbench%.vvp" %vivado_lib% %s1% %s2% %s3% %s4% %s5% %ip1% %ip2% %ip3% %ip4% %vivado_dir%/glbl.v


vvp "%batdir%\%testbench%.vvp"

set gtkw_file="%batdir%\%testbench%.gtkw"
if exist %gtkw_file% (gtkwave %gtkw_file%) else (gtkwave "%batdir%\%testbench%.vcd")

pause