`timescale 1ns/1ps
`define DEBUG


module  data_gen(
    input                   clk                ,
    input                   rst_n              ,
    input  [DATA_WIDH-1:00] data_in [0:1024-1] ,

    output                  fs                 ,
    output                  hs                 ,
    output [DATA_WIDH-1:00] data               ,
    output [10:0]           hang_cnt_out       ,
    output [10:0]           lie_cnt_out
);
	parameter   DATA_WIDH     = 8;
	parameter   FRONT         = 10;
	parameter   HANG_NUM      = 32;
	parameter   LIE_NUM       = 32;
	parameter   LIE_UNVALID   = 5;
	parameter  	FRAME_UNVALID = 100;
	parameter   BACK          = 5;

	parameter   NUM = FRONT + HANG_NUM*(LIE_NUM+LIE_UNVALID)+BACK+FRAME_UNVALID;

  reg [20:0] cnt;
	always @(posedge clk or negedge rst_n)
	begin
		if(rst_n==1'b0)
			cnt <= 0;
		else if(cnt < NUM-1)
			cnt <= cnt + 1;
		else
			cnt<=0;
	end

	reg fs_temp;
	always @(posedge clk or negedge rst_n)
	begin
		if(rst_n==1'b0)
			fs_temp <= 0;
		else if( (0<cnt) && (cnt <= NUM-FRAME_UNVALID) )
			fs_temp <= 1;
		else
			fs_temp <=0;
	end

	reg [10:0] lie_cnt;
	always @(posedge clk or negedge rst_n)
	begin
		if(rst_n==1'b0)
			lie_cnt <= 0;
		else if( (cnt > FRONT-1) && (fs_temp==1) )
		begin
			if(lie_cnt < LIE_NUM+LIE_UNVALID-1 )
				lie_cnt <= lie_cnt + 1;
			else
				lie_cnt <= 0;
		end
		else
			lie_cnt<=0;
	end

	reg [10:0] hang_cnt;
	always @(posedge clk or negedge rst_n)
	begin
		if(rst_n==1'b0)
			hang_cnt <= 0;
		else if( lie_cnt==1 )
		begin
			if(hang_cnt < HANG_NUM )
				hang_cnt <= hang_cnt + 1;
			else
				hang_cnt <= 0;
		end
		else
			hang_cnt<=hang_cnt;
	end

	reg hs_temp;
	always @(posedge clk or negedge rst_n)
	begin
		if(rst_n==1'b0)
			hs_temp <= 0;
		else if( (0<lie_cnt) && (lie_cnt <= LIE_NUM) )
			hs_temp <= 1;
		else
			hs_temp <=0;
	end

	reg [10:0] lie_cnt_d1;
	always @(posedge clk or negedge rst_n)
	begin
		lie_cnt_d1<=lie_cnt;
	end

	assign hs = hs_temp & (hang_cnt > 0);
	assign fs = fs_temp;
	assign hang_cnt_out =hang_cnt;
	assign lie_cnt_out = lie_cnt_d1;
	assign data = (fs & hs)?data_in[(hang_cnt_out-1)*LIE_NUM+(lie_cnt_out-1)]:0;

endmodule
