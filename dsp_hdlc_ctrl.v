`timescale 1 ns / 1 ns

module dsp_hdlc_ctrl ( clk_100m, clk, rst_n, emif_dpram_wen, emif_dpram_addr, emif_data, trastart_flag, db, ramd);
	input                 clk_100m;          // 串口发送时钟
	input                 clk ;              // 复位，低有效
	input                 rst_n;             // 发送出发脉冲，高脉冲，至少一个clkt宽度
	input                 emif_dpram_wen;    // 1帧发送字节数
	input       [23:0]    emif_dpram_addr;
	input       [15:0]    emif_data;         // 发送缓存区接口数据信号
	
	output  reg           trastart_flag;
	output  reg  [9:0]    db;
	output       [7:0]    ramd;
	
	// CE0 空间07000_0000
	parameter  ADDR_TX_START = 24'd255;
	parameter  TR_FLAG_WIDTH = 10'd84;    //比4个7E的长度64多一些即可
	
	reg start; reg [9:0] cnt_start;
	always @(posedge clk_100m or negedge rst_n)
	begin
		if(rst_n==0)
		begin
			db <= 10'd0;
			start <= 0;
			cnt_start <= 10'd0; 
		end		
		else if((emif_dpram_wen == 1) && (emif_dpram_addr==ADDR_TX_START) )
		begin
			db <= emif_data[9:0];
		    start <= 1;
			cnt_start   <= 10'd1;			
		end
		else if((0 < cnt_start) && (cnt_start < 10'd500))  //500是让串口一定采集到
		begin	
			cnt_start <= cnt_start + 10'd1;
			start <= 1;
			db <= db;
		end		
		else
		begin
			db <= db;
			start <= 0;
			cnt_start <= 0;
		end			
	end

	//跨时钟域
	reg [9:0] db1,db2; reg start1,start2;
	always @(posedge clk or negedge rst_n)
	begin
		if(rst_n==0)
		begin		
			db1 <= 0; db2 <= 0;
			start1 <= 0; start2 <= 0;
		end	
		else
		begin	
			db1 <= db; db2 <= db1;
			start1 <= start; start2 <= start1;
		end
	end	
	
	//上升沿
	reg start3,start_pos;
	always @(posedge clk or negedge rst_n)
	begin
		if(rst_n==0)
		begin
			start3 <= 0;
			start_pos <= 0;
		end	
		else
		begin	
			start3 <= start2; 
			start_pos <= start2 & (~start3);
		end	
	end	
	
	// 产生一个计数器，开始按时序产生波形
	reg [3:0] cnt_8;
	always @(posedge clk or negedge rst_n)
	begin
		if(rst_n==0)
			cnt_8 <= 4'd0;
		else if(start_pos==1)
			cnt_8 <=1;	
		else if(bytes < db2)
		begin	
			if(cnt_8 == 4'd8)
				cnt_8 <= 4'd1;
			else if(cnt_8>=1)
				cnt_8 <= cnt_8 + 4'd1;
			else
				cnt_8 <= cnt_8;
		end
		else 
			cnt_8 <= cnt_8;
	end	
	
	reg [9:0] bytes;  reg rden;
	always @(posedge clk or negedge rst_n)
	begin
		if(rst_n==0)
		begin
			bytes <= 10'd0;
			rden  <= 0;
		end
		else if(start_pos==1)
		begin
			bytes <= 10'd0;
			rden  <= 0;
		end
		else if(cnt_8 == 4'd8)			
		begin
			bytes <= bytes + 10'd1;
			rden  <= 1;
		end
		else
		begin
		   bytes <= bytes;
		   rden  <= 0;
		end		
	end		
	
	reg [9:0] cnt_trans_start;
	always @(posedge clk or negedge rst_n)
	begin
		if (rst_n ==0)
			cnt_trans_start <= 0;
		else if(start_pos==1)
			cnt_trans_start<=10'd1;
		else if( (0 < cnt_trans_start) && (cnt_trans_start < TR_FLAG_WIDTH))
			cnt_trans_start <= cnt_trans_start + 10'd1;
		else
			cnt_trans_start <= cnt_trans_start;		
	end	

	always @(posedge clk or negedge rst_n)
	begin
		if (rst_n ==0)
			trastart_flag <= 0;
		else if((10'd9 <= cnt_trans_start) && (cnt_trans_start < TR_FLAG_WIDTH ))
			trastart_flag <= 1;
		else
			trastart_flag <= 0;		
	end	
		
	// 拓宽读使能宽度
	reg rden1, rden2_2; reg [9:0] bytes1, bytes2, bytes3;
	always @(posedge clk or negedge rst_n)
	begin
		if(rst_n==0)
		begin
			rden1   <= 0; 
			rden2_2 <= 0;
			bytes1  <= 0;
			bytes2  <= 0;
			bytes3  <= 0;
		end
		else
		begin
			rden1 <= rden; 
			rden2_2 <= rden | rden1;
			bytes1  <= bytes;
			bytes2  <= bytes1;
			bytes3  <= bytes2;
		end		
	end
	
	
	wire  [7:0] doutb;
	hdlc_tx_ram u_hdlc_tx_ram (
	  .clka  ( clk_100m                ),      // input wire clka
	  .ena   ( emif_dpram_wen          ),      // input wire [0 : 0] ena
	  .wea   ( 1'b1                    ),      // input wire [0 : 0] wea
	  .addra ( emif_dpram_addr[7:0]    ),      // input wire [7 : 0] addra
	  .dina  ( emif_data               ),      // input wire [15 : 0] dina
			   
	  .clkb  ( clk                     ),      // input wire clkb
	  .rstb  (  ~rst_n                 ),
	  .enb   ( rden2_2                 ), 
	  .addrb ( bytes3[8:0]             ),      // input wire [8 : 0] addrb
	  .doutb ( doutb                   )       // output wire [7 : 0] doutb
	);

	assign ramd = doutb; 
		
	
endmodule
	