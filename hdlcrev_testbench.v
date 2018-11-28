// synopsys translate_off
`timescale 1 ns / 1 ps
// synopsys translate_on

module hdlcrev_testbench(
    );
	reg          clk              ;
	reg          rst_n            ;
    reg          datar            ;
    reg          flagr            ;
	reg  [7 :0]  ramd             ;
	reg  [8:0]  rama             ;
	reg          hwr              ;
	reg          interrupt              ;
	integer      i;

	
	always #8 clk  = ~clk;

    initial begin
		clk       = 1;
		rst_n      = 0;
		datar      = 1;
		flagr      = 0;
		
		#128
		rst_n = 1; 
		#16 flagr =1;
		
		#16 datar =0; #16 datar =1;#16 datar =1; #16 datar =1;#16 datar =1;#16 datar =1; #16 datar =1;#16 datar =0;		
		#16 datar =0; #16 datar =1;#16 datar =1; #16 datar =1;#16 datar =1;#16 datar =1; #16 datar =1;#16 datar =0;
		#16 datar =0; #16 datar =1;#16 datar =1; #16 datar =1;#16 datar =1;#16 datar =1; #16 datar =1;#16 datar =0;
		#16 datar =0; #16 datar =1;#16 datar =1; #16 datar =1;#16 datar =1;#16 datar =1; #16 datar =1;#16 datar =0;
		//flagr =0;
		
		#16 datar =0; #16 datar =1;#16 datar =0; #16 datar =1;#16 datar =0;#16 datar =1; #16 datar =0;#16 datar =0;
		#16 datar =1; #16 datar =1;#16 datar =0; #16 datar =1;#16 datar =1;#16 datar =1; #16 datar =0;#16 datar =1;
		#16 datar =1; #16 datar =1;#16 datar =0; #16 datar =0;#16 datar =1;#16 datar =1; #16 datar =0;#16 datar =0;
		#16 datar =1; #16 datar =1;#16 datar =0; #16 datar =1;#16 datar =1;#16 datar =1; #16 datar =0;#16 datar =1;
		#16 datar =1; #16 datar =1;#16 datar =0; #16 datar =0;#16 datar =1;#16 datar =1; #16 datar =0;#16 datar =0;
		#16 datar =0; #16 datar =1;#16 datar =0; #16 datar =1;#16 datar =0;#16 datar =1; #16 datar =0;#16 datar =0;
		#16 datar =1; #16 datar =1;#16 datar =0; #16 datar =1;#16 datar =1;#16 datar =1; #16 datar =0;#16 datar =1;
		#16 datar =1; #16 datar =1;#16 datar =0; #16 datar =0;#16 datar =1;#16 datar =1; #16 datar =0;#16 datar =0;
		#16 datar =1; #16 datar =1;#16 datar =0; #16 datar =1;#16 datar =1;#16 datar =1; #16 datar =0;#16 datar =1;
		#16 datar =1; #16 datar =1;#16 datar =0; #16 datar =0;#16 datar =1;#16 datar =1; #16 datar =0;#16 datar =0;
		
		#16 datar =0; #16 datar =1;#16 datar =1; #16 datar =1;#16 datar =1;#16 datar =1; #16 datar =1;#16 datar =0;		
		#16 datar =0; #16 datar =1;#16 datar =1; #16 datar =1;#16 datar =1;#16 datar =1; #16 datar =1;#16 datar =0;
		#16 datar =0; #16 datar =1;#16 datar =1; #16 datar =1;#16 datar =1;#16 datar =1; #16 datar =1;#16 datar =0;
		#16 datar =0; #16 datar =1;#16 datar =1; #16 datar =1;#16 datar =1;#16 datar =1; #16 datar =1;#16 datar =0;		
		
		/*******************************第二次接收*********************/
		#16000 flagr =1;
		
		#16 datar =0; #16 datar =1;#16 datar =1; #16 datar =1;#16 datar =1;#16 datar =1; #16 datar =1;#16 datar =0;		
		#16 datar =0; #16 datar =1;#16 datar =1; #16 datar =1;#16 datar =1;#16 datar =1; #16 datar =1;#16 datar =0;
		#16 datar =0; #16 datar =1;#16 datar =1; #16 datar =1;#16 datar =1;#16 datar =1; #16 datar =1;#16 datar =0;
		#16 datar =0; #16 datar =1;#16 datar =1; #16 datar =1;#16 datar =1;#16 datar =1; #16 datar =1;#16 datar =0;
		//flagr =0;
		for (i=0;i<100;i=i+1)
		begin
			#16 datar =0; #16 datar =1;#16 datar =0; #16 datar =1;#16 datar =0;#16 datar =1; #16 datar =0;#16 datar =0;
			#16 datar =1; #16 datar =1;#16 datar =0; #16 datar =1;#16 datar =1;#16 datar =1; #16 datar =0;#16 datar =1;
			#16 datar =1; #16 datar =1;#16 datar =0; #16 datar =0;#16 datar =1;#16 datar =1; #16 datar =0;#16 datar =0;
			#16 datar =1; #16 datar =1;#16 datar =0; #16 datar =1;#16 datar =1;#16 datar =1; #16 datar =0;#16 datar =1;
			#16 datar =1; #16 datar =1;#16 datar =0; #16 datar =0;#16 datar =1;#16 datar =1; #16 datar =0;#16 datar =0;
		end

		
		#16 datar =0; #16 datar =1;#16 datar =1; #16 datar =1;#16 datar =1;#16 datar =1; #16 datar =1;#16 datar =0;		
		#16 datar =0; #16 datar =1;#16 datar =1; #16 datar =1;#16 datar =1;#16 datar =1; #16 datar =1;#16 datar =0;
		#16 datar =0; #16 datar =1;#16 datar =1; #16 datar =1;#16 datar =1;#16 datar =1; #16 datar =1;#16 datar =0;
		#16 datar =0; #16 datar =1;#16 datar =1; #16 datar =1;#16 datar =1;#16 datar =1; #16 datar =1;#16 datar =0;		
		
		#128000
		$finish;
	end
	
	initial
    begin
        $dumpfile("hdlcrev_testbench.vcd");
        $dumpvars(0,hdlcrev_testbench);
        $display("hdlcrev_testbench!");
    end

	hdlcrev u_hdlcrev(
		 . rst_n             ( rst_n             ),      //         复位，低有效    
		 . ra                ( 8'd0              ),      //[7:0]    本站地址，本模块没有用                         
		 . clkr              ( clk               ),      //         串口时钟                       
		 . datar             ( datar             ),      //         数据                           
		 . flagr             ( flagr             ),      //         接收触发信号  
		           
		 . ramd              ( ramd              ),      // [7:0]   接收缓存数据信号       
		 . rama              ( rama              ),      // [8:0]  接收缓存地址信号       
	     . hwr               ( hwr               ),      //         接收缓存写信号                
		 . interrupt         ( interrupt               )       //         接收完成中断信号              
              
	);	 
	
endmodule
