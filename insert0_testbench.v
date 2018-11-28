// synopsys translate_off
`timescale 1 ns / 1 ns
// synopsys translate_on

module insert0_testbench(
    );
	reg         clk             ;
	reg         rst_n           ;
	reg         trastart_flag  	;         	
	reg  [7:0]  ramd            ;     
	reg         datat           ;
	reg         inr             ;
	reg         flagt           ;
	integer i;
	
	always #1 clk  = ~clk;

    initial begin
		inr        = 0;
		clk        = 1;
		rst_n      = 0;
		trastart_flag = 0;		
		ramd = 8'h00;
		#128
		rst_n      = 1;		
		/***************sednd*************/
		#204
		trastart_flag = 1;   
		
		#4
 	 	for (i=0;i<125;i=i+1)
		begin
			ramd = 8'hFF;#16;
			ramd = 8'hFF;#16;
			ramd = 8'hFF;#16;
			ramd = 8'hFF;#16;
		end	  
		ramd = 8'hFF;#16;
		ramd = 8'h55;#16;
 		ramd = 8'h33;#16;
		ramd = 8'hFF;#16;
 		ramd = 8'hFF;#16;
		ramd = 8'h7E;#16;
 		ramd = 8'hFF;#16;		
		trastart_flag = 0;
		#36000
		inr =1;
		#2 inr = 0;
		/***************sednd*************/
		#204
		trastart_flag = 1;   
		
		#4
 	 	for (i=0;i<125;i=i+1)
		begin
			ramd = 8'hFF;#16;
			ramd = 8'hFF;#16;
			ramd = 8'hFF;#16;
			ramd = 8'hFF;#16;
		end	  
		ramd = 8'hFF;#16;
		ramd = 8'h55;#16;
 		ramd = 8'h33;#16;
		ramd = 8'hFF;#16;
 		ramd = 8'hFF;#16;
		ramd = 8'h7E;#16;
 		ramd = 8'hFF;#16;		
		trastart_flag = 0;
		#36000
		inr =1;
		#2 inr = 0;
		/***************sednd*************/
		#204
		trastart_flag = 1;   
		
		#4
 	 	for (i=0;i<125;i=i+1)
		begin
			ramd = 8'hFF;#16;
			ramd = 8'hFF;#16;
			ramd = 8'hFF;#16;
			ramd = 8'hFF;#16;
		end	  
		ramd = 8'hFF;#16;
		ramd = 8'h55;#16;
 		ramd = 8'h33;#16;
		ramd = 8'hFF;#16;
 		ramd = 8'hFF;#16;
		ramd = 8'h7E;#16;
 		ramd = 8'hFF;#16;		
		trastart_flag = 0;
		#36000
		inr =1;
		#2 inr = 0;
		/***************sednd*************/
		#204
		trastart_flag = 1;   
		
		#4
 	 	for (i=0;i<125;i=i+1)
		begin
			ramd = 8'hFF;#16;
			ramd = 8'hFF;#16;
			ramd = 8'hFF;#16;
			ramd = 8'hFF;#16;
		end	  
		ramd = 8'hFF;#16;
		ramd = 8'h55;#16;
 		ramd = 8'h33;#16;
		ramd = 8'hFF;#16;
 		ramd = 8'hFF;#16;
		ramd = 8'h7E;#16;
 		ramd = 8'hFF;#16;		
		trastart_flag = 0;
		#36000
		inr =1;
		#2 inr = 0;
		
		$finish;	
    end
	
	initial
    begin
        $dumpfile("insert0_testbench.vcd");
        $dumpvars(0,insert0_testbench);
        $display("insert0_testbench!");
    end

	insert0 u_insert0(
		 .clk              ( clk             ),    //       
		 .rst_n            ( rst_n           ),    //       复位，低有效
		 .trastart_flag    ( trastart_flag   ),    //       发送出发脉冲，高脉冲，至少一个clkt宽度
		 .db               ( 10'd507         ),    // [7:0] 1帧发送字节数
		 .ramd             ( ramd            ),    // [7:0] 发送缓存区接口数据信号 		 
		 .inr              ( inr             )
	);	 		
	

endmodule  