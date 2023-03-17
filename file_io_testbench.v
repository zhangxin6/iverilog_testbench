`timescale 1ns / 1ps
`define W 32                     //Image Width  这两个定义需要根据输入测试图像的大小来修改. These two definitions need to be modified according to the size of the input test image.
`define H 32                     //Image Height 忘了改结果就会不正确                        If you forgot, the result will be wrong
`define S `W * `H            //图像数据的总字节数,由于是RGB数据,所以*3.                 Total bytes of the image
module file_io_testbench(
    );
    reg clk   ;
    reg rst_n ;
    reg [10:0] k;
    reg [7:0] PicMem[0:`S-1];    //用来存储RGB图像数据 Used to store RGB image data
    reg fs,hs;
    reg [7:0] data;
    reg [10:0] hang_cnt_out,lie_cnt_out;

    reg [9:0]         e_label        ;
    reg [8:0]         e_le           ;
    reg [8:0]         e_ri           ;
    reg [8:0]         e_upm          ;
    reg [8:0]         e_dw           ;
    reg [31:0]        e_sum_gray     ;
    reg [19:0]        e_num_gray     ;

    always #5 clk = ~clk;

    initial
    begin
        $dumpfile("file_io_testbench.vcd");
        $dumpvars(0,file_io_testbench);
        $display("file_io_testbench!");
    end

    initial begin
        clk   = 0;
        rst_n = 0;
        $readmemh("/mnt/sda1/connect_test/iverilog_testbench/file_io/5.txt",PicMem);         //把tb1.txt中的图像数据读取到PicMem中来

        #100 rst_n=1;
        #100000;
        $finish;

    end

    data_gen u_data_gen(
        .clk          (clk         ),
        .rst_n        (rst_n       ),
        .data_in      (PicMem      ),

        .fs           (fs          ),
        .hs           (hs          ),
        .data         (data        ),
        .hang_cnt_out (hang_cnt_out),
        .lie_cnt_out  (lie_cnt_out )
    );

    connect_domain_get u_connect_domain_get(
        .clk          (clk         ),
        .rst_n        (rst_n       ),
        .fs           (fs          ),
        .hs           (hs          ),
        .data         (data        ),
        .hang_cnt_out (hang_cnt_out),
        .lie_cnt_out  (lie_cnt_out ),

        .e_label      (e_label     ),
        .e_le         (e_le        ),
        .e_ri         (e_ri        ),
        .e_upm        (e_upm       ),
        .e_dw         (e_dw        ),
        .e_sum_gray   (e_sum_gray  ),
        .e_num_gray   (e_num_gray  )
    );

endmodule
