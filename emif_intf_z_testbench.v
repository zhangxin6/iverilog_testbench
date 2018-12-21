// synopsys translate_off
`timescale 1 ns / 1 ns
// synopsys translate_on

module emif_intf_z_testbench(
    );
	reg         clk             ;
	reg         rst_n           ;
	
	reg  [15:00]  emif_data_i    ;
	reg  [23:00]  emif_addr_i    ;
	reg  [01:00]  emif_byten_i   ;

	reg           emif_cen_i     ;
	reg           emif_wen_i     ;
	reg           emif_oen_i     ;
	
	reg           emif_dpram_wen   ;
	reg  [23:00]  emif_dpram_addr  ;
	reg  [15:00]  emif_dpram_wdata ;       	
	reg  [15:00]  emif_dpram_rdata ;   
	reg           emif_dpram_ren   ;   

	
	always #1 clk  = ~clk;

    initial begin
		clk        = 1;
		rst_n      = 0;
		emif_wen_i = 1;		
		emif_cen_i  = 1;
		emif_byten_i = 2'b11;
		emif_data_i = 0;
		emif_addr_i = 0;
		emif_oen_i  = 1;
 		
		#128
		rst_n       = 1;
		/********************write one data begin***************/
		emif_addr_i = 24'h000000;
		emif_byten_i = 0;
		
		
		#3
		emif_wen_i  = 0;
		emif_cen_i = 0;
		
		#9
		emif_wen_i  = 1;
		emif_cen_i = 1;		
		
		#2
		emif_byten_i = 2'b11;
		#6	
		/********************write one data end***************/
		/********************write one data begin***************/
		emif_addr_i = 24'h800000;
		emif_byten_i = 0;
		
		
		#3
		emif_wen_i  = 0;
		emif_cen_i = 0;
		
		#9
		emif_wen_i  = 1;
		emif_cen_i = 1;		
		
		#2
		emif_byten_i = 2'b11;
		#6	
		/********************write one data end***************/			
		#1000
		/********************read one data begin***************/
		emif_addr_i = 24'h000000;
		emif_byten_i = 0;
		
		
		#3
		emif_oen_i  = 0;
		emif_cen_i = 0;
		
		#9
		emif_oen_i  = 1;
		emif_cen_i = 1;		
		
		#2
		emif_byten_i = 2'b11;
		#6	
		/********************read one data end***************/
		
		/********************read one data begin***************/
		emif_addr_i = 24'h800000;
		emif_byten_i = 0;
		
		
		#3
		emif_oen_i  = 0;
		emif_cen_i = 0;
		
		#9
		emif_oen_i  = 1;
		emif_cen_i = 1;		
		
		#2
		emif_byten_i = 2'b11;
		#6	
		/********************read one data end***************/
		
		
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
		 .clk_100m         ( clk              ),    
		 .rst_n            ( rst_n            ),    
		                                      
 		 .emif_data_i      ( emif_data_i      ),    
		 .emif_addr_i      ( emif_addr_i      ),    
		 .emif_byten_i     ( emif_byten_i     ),    
		 .emif_cen_i       ( emif_cen_i       ),
		 .emif_wen_i       ( emif_wen_i       ),    
		 .emif_oen_i       ( emif_oen_i       ),
		 
		 .emif_dpram_wen   ( emif_dpram_wen   ),
		 .emif_dpram_addr  ( emif_dpram_addr  ),
		 .emif_dpram_wdata ( emif_dpram_wdata ),
		 .emif_dpram_ren   ( emif_dpram_ren   )	 
	);	 		
	
endmodule  