@echo off
set testbench=file_io_testbench

set iverilog_path=c:\iverilog\bin;
set gtkwave_path=c:\iverilog\gtkwave\bin;
set path=%iverilog_path%%gtkwave_path%%path%

set dir=C:\Users\zhang\iverilog_testbench
set ip_dir=C:\Users\zhang\manage_ip
set batdir=C:\Users\zhang\iverilog_testbench\bat

set s1=%dir%\file_io_testbench.v
set s2=%dir%\data_gen.v
set s3=%dir%\connect_domain_get.v

set ip1="%ip_dir%\delay_1hang\simulation\blk_mem_gen_v8_4.v"
set ip2="%ip_dir%\delay_1hang\sim\delay_1hang.v"

set vivado_dir=C:\Xilinx\Vivado\2018.2\data\verilog\src
set vivado_lib="-y%vivado_dir%" "-y%vivado_dir%\retarget" "-y%vivado_dir%\unifast" "-y%vivado_dir%\unimacro" "-y%vivado_dir%\unisims" "-y%vivado_dir%\xeclib"

iverilog -g2012 -o "%batdir%\%testbench%.vvp" %vivado_lib% %s1% %s2% %s3% %ip1% %ip2% %vivado_dir%/glbl.v

vvp "%batdir%\%testbench%.vvp"

set gtkw_file="%batdir%\%testbench%.gtkw"
if exist %gtkw_file% (gtkwave %gtkw_file%) else (gtkwave "%batdir%\%testbench%.vcd")

pause