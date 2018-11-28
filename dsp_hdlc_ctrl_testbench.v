// synopsys translate_off
`timescale 1 ns / 1 ps
// synopsys translate_on

module dsp_hdlc_ctrl_testbench(
    );
	reg             clk_100m;         
	reg             clk ;             
	reg             rst_n;            
	reg             emif_dpram_wen;   
	reg   [23:0]    emif_dpram_addr;
	reg   [15:0]    emif_data;        
	
	reg             trastart_flag;
	reg   [9:0]     db;
	reg   [7:0]     ramd;
	reg             datat;
	reg             inr;
	
	integer i;
	
	always #1  clk_100m = ~clk_100m;
	always #50 clk = ~clk;  

    initial begin
		clk   = 1;
		clk_100m = 1;		
		rst_n = 0;
		emif_dpram_addr = 32'd0;
		emif_dpram_wen  = 0;
		emif_data       = 16'h0;
				
		#128
		rst_n = 1; 
		/****************连续读数测试**********************/
		/***************skldj;fsgkdfslkfldaslk******************************/	
		for(i=0;i<250;i=i+1)
		begin
			#8
			emif_dpram_addr = i;
			emif_dpram_wen  = 1;
			emif_data       = 16'hFFFF;
			#2
			emif_dpram_wen  = 0;	
		end

		#8
			emif_dpram_addr = 250;
			emif_dpram_wen  = 1;
			emif_data       = 16'hFF55;
		#2
			emif_dpram_wen  = 0;
			
		#8
			emif_dpram_addr = 251;
			emif_dpram_wen  = 1;
			emif_data       = 16'hFFAA;
		#2	
			emif_dpram_wen  = 0;
			
		/***********发送个数**********************/	
		#8
			emif_dpram_addr = 24'd255;
			emif_dpram_wen  = 1;
			emif_data       = 16'd504;
		#2
			emif_dpram_wen  = 0;	
			
		#500000
		/***************skldj;fsgkdfslkfldaslk******************************/	
		for(i=0;i<250;i=i+1)
		begin
			#8
			emif_dpram_addr = i;
			emif_dpram_wen  = 1;
			emif_data       = 16'hFFFF;
			#2
			emif_dpram_wen  = 0;	
		end

		#8
			emif_dpram_addr = 250;
			emif_dpram_wen  = 1;
			emif_data       = 16'hFF55;
		#2
			emif_dpram_wen  = 0;
			
		#8
			emif_dpram_addr = 251;
			emif_dpram_wen  = 1;
			emif_data       = 16'hFFAA;
		#2	
			emif_dpram_wen  = 0;
			
		/***********发送个数**********************/	
		#8
			emif_dpram_addr = 24'd255;
			emif_dpram_wen  = 1;
			emif_data       = 16'd504;
		#2
			emif_dpram_wen  = 0;	
			
		#500000
		/***************skldj;fsgkdfslkfldaslk******************************/	
		for(i=0;i<250;i=i+1)
		begin
			#8
			emif_dpram_addr = i;
			emif_dpram_wen  = 1;
			emif_data       = 16'hFFFF;
			#2
			emif_dpram_wen  = 0;	
		end

		#8
			emif_dpram_addr = 250;
			emif_dpram_wen  = 1;
			emif_data       = 16'hFF55;
		#2
			emif_dpram_wen  = 0;
			
		#8
			emif_dpram_addr = 251;
			emif_dpram_wen  = 1;
			emif_data       = 16'hFFAA;
		#2	
			emif_dpram_wen  = 0;
			
		/***********发送个数**********************/	
		#8
			emif_dpram_addr = 24'd255;
			emif_dpram_wen  = 1;
			emif_data       = 16'd504;
		#2
			emif_dpram_wen  = 0;	
			
		#500000
		/***************skldj;fsgkdfslkfldaslk******************************/	
		for(i=0;i<250;i=i+1)
		begin
			#8
			emif_dpram_addr = i;
			emif_dpram_wen  = 1;
			emif_data       = 16'hFFFF;
			#2
			emif_dpram_wen  = 0;	
		end

		#8
			emif_dpram_addr = 250;
			emif_dpram_wen  = 1;
			emif_data       = 16'hFF55;
		#2
			emif_dpram_wen  = 0;
			
		#8
			emif_dpram_addr = 251;
			emif_dpram_wen  = 1;
			emif_data       = 16'hFFAA;
		#2	
			emif_dpram_wen  = 0;
			
		/***********发送个数**********************/	
		#8
			emif_dpram_addr = 24'd255;
			emif_dpram_wen  = 1;
			emif_data       = 16'd504;
		#2
			emif_dpram_wen  = 0;	
			
		#500000
		
		
		
		
		$finish;	
    end

	initial
    begin
        $dumpfile("dsp_hdlc_ctrl_testbench.vcd");
        $dumpvars(0,dsp_hdlc_ctrl_testbench);
        $display("dsp_hdlc_ctrl_testbench!");
    end

	dsp_hdlc_ctrl u_dsp_hdlc_ctrl(
		.clk_100m         ( clk_100m       ),
		.clk              ( clk            ),
		.rst_n            ( rst_n          ),
		.emif_dpram_wen   ( emif_dpram_wen ),
		.emif_dpram_addr  ( emif_dpram_addr),
		.emif_data        ( emif_data      ),
		                                    
		.trastart_flag    ( trastart_flag  ),
		.db               ( db             ),
		.ramd             ( ramd           )
	);
	
	hdlctra u_hdlctra(
	 .clk           ( clk           ),
	 .rst_n         ( rst_n         ),
	 .trastart_flag ( trastart_flag ),
	 .db            ( db            ),
	 .ramd          ( ramd          ),
	 
	 .datat         ( datat         ),
	 .inr           ( inr           )
	);
	 
	
	
	

endmodule