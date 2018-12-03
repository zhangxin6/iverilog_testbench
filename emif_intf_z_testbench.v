// synopsys translate_off
`timescale 1 ns / 1 ns
// synopsys translate_on

module emif_intf_z_testbench(
    );
	reg         clk             ;
	reg         rst_n           ;
	
	wire [15:00]  emif_data_z    ;
	reg  [23:00]  emif_addr_i    ;
	reg  [01:00]  emif_byten_i   ;
	reg           emif_cen_i     ;
	reg           emif_wen_i     ;
	reg           emif_oen_i     ;
	
	reg           emif_dpram_wen   ;
	reg  [23:00]  emif_dpram_addr  ;
	reg  [15:00]  emif_dpram_wdata ;       	
	reg  [15:00]  emif_dpram_rdata ;   
	reg           emif_dpram_ren_2 ;   

	
	always #1 clk  = ~clk;

    initial begin
		clk        = 1;
		rst_n      = 0;
		
		#128
		rst_n       = 1;
		emif_addr_i = 0;
		emif_byten_i= 2'b11;
		emif_cen_i  = 1;
		emif_wen_i  = 1;
		emif_oen_i  = 1;
		
		/***************sednd*************/
		
		#100
		emif_addr_i  = 0;
		emif_byten_i = 2'b00;
		#3 
		emif_cen_i  = 0;
		emif_wen_i  = 0;
		#9 
		emif_cen_i  = 1;
		emif_wen_i  = 1;
		#1
		emif_byten_i = 3'b11;	
		#6
		
		emif_addr_i  = 24'h800000;
		emif_byten_i = 2'b00;
		#3 
		emif_cen_i  = 0;
		emif_wen_i  = 0;
		#9 
		emif_cen_i  = 1;
		emif_wen_i  = 1;
		#1
		emif_byten_i = 2'b11;	
		#6
		
		#1000
		$finish;
	end	
	
	initial
    begin
        $dumpfile("emif_intf_z_testbench.vcd");
        $dumpvars(0,emif_intf_z_testbench);
        $display("emif_intf_z_testbench!");
    end

	emif_intf_z u_emif_intf_z(
		 .clk_ref        ( clk             ),    //       
		 .rst_n          ( rst_n           ),    //       复位，低有效
		
 		 .emif_data_z    ( emif_data_z     ),    //       发送出发脉冲，高脉冲，至少一个clkt宽度
		 .emif_addr_i    ( emif_addr_i     ),    // [7:0] 1帧发送字节数
		 .emif_byten_i   ( emif_byten_i    ),    // [7:0] 发送缓存区接口数据信号 		 
		 .emif_cen_i     ( emif_cen_i      ),
		 .emif_wen_i     ( emif_wen_i      ),    // [7:0] 发送缓存区接口数据信号 	
		 .emif_oen_i     ( emif_oen_i      ),
		 
		 .emif_dpram_wen   (       ),
		 .emif_dpram_addr  (       ),
		 .emif_dpram_wdata (       ),
		 .emif_dpram_rdata ( 16'b0 ),
		 .emif_dpram_ren_2 (       )
		 
	);	 		
	
endmodule  