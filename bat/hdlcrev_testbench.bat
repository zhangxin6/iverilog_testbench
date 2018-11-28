@echo off
set testbench=hdlcrev_testbench

set iverilog_path=c:\iverilog\bin;
set gtkwave_path=c:\iverilog\gtkwave\bin;
set path=%iverilog_path%%gtkwave_path%%path%

set dir=C:\Users\zhang\iverilog_testbench
set ip_dir=C:\Users\zhang\manage_ip
set batdir=C:\Users\zhang\iverilog_testbench\bat

set s1=%dir%\hdlcrev_testbench.v
set s2=%dir%\hdlcrev.v

set vivado_dir=C:\Xilinx\Vivado\2015.1\data\verilog\src
set vivado_lib="-y%vivado_dir%" "-y%vivado_dir%\retarget" "-y%vivado_dir%\unifast" "-y%vivado_dir%\unimacro" "-y%vivado_dir%\unisims" "-y%vivado_dir%\xeclib"

iverilog -g2012 -o "%batdir%\%testbench%.vvp" %vivado_lib% %s1% %s2% %vivado_dir%/glbl.v

vvp "%batdir%\%testbench%.vvp"

set gtkw_file="%batdir%\%testbench%.gtkw"
if exist %gtkw_file% (gtkwave %gtkw_file%) else (gtkwave "%batdir%\%testbench%.vcd")

pause
