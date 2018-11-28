// synopsys translate_off
`timescale 1 ns / 1 ps
// synopsys translate_on

module hdlctra_testbench(
    );
	reg         clk             ;
	reg         rst_n           ;
	reg         clkt           	;
	reg         trastart_flag  	;         	
	reg  [7:0]  ramd            ;     
	reg         datat           ;
	reg         inr             ;
	reg         flagt           ;
	integer i;   
	always #1 clk  = ~clk;

    initial begin
		clk       = 1;
		rst_n      = 0;
		trastart_flag = 0;		
		ramd = 8'h00;
		#128
		rst_n      = 1;	
		/************sdjkdsjksdjk****************/	
		#32
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
 		ramd = 8'hFF;#16;
		ramd = 8'hAA;#16;
		trastart_flag = 0;
		/************sdjkdsjksdjk****************/
		#6000
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
 		ramd = 8'hFF;#16;
		ramd = 8'hAA;#16;
		trastart_flag = 0;
		/************sdjkdsjksdjk****************/
		#6000
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
 		ramd = 8'hFF;#16;
		ramd = 8'hAA;#16;
		trastart_flag = 0;
		/************sdjkdsjksdjk****************/
		#6000
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
 		ramd = 8'hFF;#16;
		ramd = 8'hAA;#16;
		trastart_flag = 0;
		
	    #8000
		
		
		
		
		
		
		$finish;	
    end
	
	initial
    begin
        $dumpfile("hdlctra_testbench.vcd");
        $dumpvars(0,hdlctra_testbench);
        $display("hdlctra_testbench!");
    end

	hdlctra u_hdlctra(
		 .clk              ( clk             ),    //       
		 .rst_n            ( rst_n           ),    //       复位，低有效
		 .trastart_flag    ( trastart_flag   ),    //       发送出发脉冲，高脉冲，至少一个clkt宽度
		 .db               ( 10'd504           ),    // [7:0] 1帧发送字节数
		 .ramd             ( ramd            ),    // [7:0] 发送缓存区接口数据信号 		 
		 .datat            ( datat           ),    //       串口DATA
		 .inr              ( inr             )     //       发送完成中断输出
	);	 
	
	
endmodule  