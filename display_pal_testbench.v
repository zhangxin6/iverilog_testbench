// synopsys translate_off
`timescale 1 ns / 1 ns
// synopsys translate_on

module display_pal_testbench(
    );

    reg             clk;
    reg             rst;
    reg [15:0]      data;
    reg [18:0]      dram_addr;
    reg             dram_rclk;
    reg             dram_ce0_n;
    reg             dram_ren;
    reg             pf_blank,pf_sync;
    reg [7:0 ]      pf_pixel;

    always #1 clk = ~clk;

    initial begin
        clk     = 0;
        rst     = 1;
        data    = 16'h3333;
        #100
        rst     = 0;
        #1500000
		data=16'h5555;
        $finish;
    end

    initial
    begin
        $dumpfile("display_pal_testbench.vcd");
        $dumpvars(0,display_pal_testbench);
        $display("display_pal_testbench!");
    end

    display_pal u_display_pal(
        .v_clk           ( clk           ),
        .rst             ( rst           ),
        .dram_datain     ( data          ),

        .dram_addr       ( dram_addr     ),
        .dram_rclk       ( dram_rclk     ),
        .dram_ce0_n      ( dram_ce0_n    ),
        .dram_ren        ( dram_ren      ),
        .pf_blank        ( pf_blank      ),
        .pf_sync         ( pf_sync       ),
        .pf_pixel        ( pf_pixel      )
    );

endmodule