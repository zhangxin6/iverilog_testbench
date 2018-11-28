// synopsys translate_off
`timescale 1 ns / 1 ns
// synopsys translate_on
module display_pal (      
						v_clk,
						rst,
						dram_datain, 
						dram_addr,
						dram_rclk,
						dram_ce0_n,
						dram_ren,
						pf_blank,pf_sync,pf_pixel        // pf_blank：消隐信号
				    );              
	
	input 			v_clk;  
	input 			rst;
	input  [15:0] 	dram_datain;	 
    output [18:0] 	dram_addr; 
	output 			dram_rclk;   
    output 			dram_ce0_n;
    output 			dram_ren;
    output 			pf_blank,pf_sync;	
	output [7:0 ] 	pf_pixel;
	
	parameter       us_273=368;		 //27.3us*7.375m=201337.5;
	parameter       us_320=432;		 //4.7us*7.375m=34662.5;
	parameter       us_23=31;          //2.3us
	parameter       ms_20=270000;      //20ms
	
	reg	    [18:0]  dram_addr;
	reg 	  		dram_rclk;
	wire 			dram_ce0_n;
	wire 			dram_ren;
	reg     		wrst;
	wire      		drst;	
	reg    			dac_hsync,dac_vsync;	
	reg    	[9:0 ]  clk_10m_cnt;
	reg   	[19:0] 	dac_vsync_cnt;
	reg   			h_blank,v_blank;
	reg   			pf_blank;
	reg   			field;
		
	reg  	[15:0] 	h_sync_counter;
	reg   	[23:0]	v_blank_cnt;
	reg     sync_temp1,sync_flag;

	assign pf_sync=(dac_hsync || sync_flag) && sync_temp1; 

	always @(negedge v_clk)    
		pf_blank <= (h_blank && v_blank);

	/*************************************/
	 
	//产生行同步
	always @(posedge v_clk or posedge rst) //v_clk = 13.5mhz
		begin
		if(rst)
		begin
			clk_10m_cnt<=10'd1;
			dac_hsync<=1;
		end 		  
		else if(clk_10m_cnt < 53)
		begin
			dac_hsync <=0;
			clk_10m_cnt <=clk_10m_cnt + 10'd1;			  
		end
		else 
		begin
			dac_hsync<=1;			 
			clk_10m_cnt <= (clk_10m_cnt<864) ? (clk_10m_cnt+1'b1) : 10'd1;			    
		end	    	
	end


	//产生场同步	  
	always @(posedge v_clk or posedge rst)
	begin
		if(rst)
		begin
			dac_vsync_cnt<=20'd1;
			dac_vsync<=0;
		end
		else
		begin
			if(dac_vsync_cnt<20'd2161)		//1601
			begin
				dac_vsync<=0;
				dac_vsync_cnt<=dac_vsync_cnt+1'd1;			 
			end
			else	
			begin
				dac_vsync<=1;
				dac_vsync_cnt<=dac_vsync_cnt<270000?(dac_vsync_cnt+1'b1):20'd1;			
			end
	
			case(dac_vsync_cnt)
				1:                 sync_temp1<=0;       //1
				us_273+1:          sync_temp1<=1;       //369   (1)
				us_320+1:          sync_temp1<=0;       //433
				us_320+us_273+1:   sync_temp1<=1;//801
				us_320*2+1:        sync_temp1<=0;       //865   (2)
				us_320*2+us_273+1: sync_temp1<=1;       //1233
				us_320*3+1:        sync_temp1<=0;       //1297   (3)
				us_320*3+us_273+1: sync_temp1<=1;       //1665
				us_320*4+1:        sync_temp1<=0;       //1729    (4)
				us_320*4+us_273+1: sync_temp1<=1;       //开槽脉冲；2097
														
				us_320*5+1:        sync_temp1<=0;       //2161    (5)
				us_320*5+us_23+1:  sync_temp1<=1;       //2192    (1)
				us_320*6+1:        sync_temp1<=0;       //2593      
				us_320*6+us_23+1:  sync_temp1<=1;       //2624    (2)
				us_320*7+1:        sync_temp1<=0;       //3025     
				us_320*7+us_23+1:  sync_temp1<=1;       //3056    (3)
				us_320*8+1:        sync_temp1<=0;       //3457      
				us_320*8+us_23+1:  sync_temp1<=1;       //3488    (4)
				us_320*9+1:        sync_temp1<=0;       //3889      
				us_320*9+us_23+1:  sync_temp1<=1;       //3920    (5)
				us_320*10+1:       sync_flag <=0 ;       //4321   							
				//后均衡脉冲；
				ms_20-us_320*5+1: //267841
				begin
					sync_temp1<=0;
					sync_flag<=1;
				end
				ms_20-us_320*5+us_23+1: sync_temp1<=1; //267872  (1)
				ms_20-us_320*4+1:       sync_temp1<=0; //268273
				ms_20-us_320*4+us_23+1: sync_temp1<=1; //268304  (2)
				ms_20-us_320*3+1:       sync_temp1<=0; //268705
				ms_20-us_320*3+us_23+1: sync_temp1<=1; //268736  (3)
				ms_20-us_320*2+1:       sync_temp1<=0; //269137 
				ms_20-us_320*2+us_23+1: sync_temp1<=1; //269168  (4)
				ms_20-us_320*1+1:       sync_temp1<=0; //269569
				ms_20-us_320*1+us_23+1: sync_temp1<=1; //前均衡脉冲；269600   (5)			
			endcase 
		end
	end  

	//产生奇偶场信号
	always @(negedge dac_vsync or posedge rst)	
	begin 
		if(rst) field<=0;
		else  field<=~field;
	 end

	//产生场消隐
	always @(posedge v_clk or posedge rst) 
	begin
		if(rst) 
			v_blank_cnt<=24'd1;
		else
		begin
			if(!field)  //if(!field)20070611
			begin       //奇数场
				if(v_blank_cnt>24'd267840 || v_blank_cnt<24'd19009)	 //198400  14401
				begin
					v_blank_cnt<=v_blank_cnt<270000?(v_blank_cnt+1'b1):24'd1;
					v_blank<=0;
				end
				else
				begin
					v_blank<=1;		  
					v_blank_cnt<=v_blank_cnt+1'b1;
				end
			end
			else 
			begin       //偶数场
				if(v_blank_cnt>24'd268272 || v_blank_cnt<24'd19441)	 //198400  14401
				begin
					v_blank_cnt<=v_blank_cnt<270000?(v_blank_cnt+1'b1):24'd1;
					v_blank<=0;
				end
				else
				begin
					v_blank<=1;		  
					v_blank_cnt<=v_blank_cnt+1'b1;
				end
			end
		end      
	end	  

	 //产生行消隐
	always@(posedge v_clk  or posedge rst)//hrst)
	begin
		if(rst)//if(hrst)
			h_sync_counter<=16'd0;
		else if(!dac_hsync)
			h_sync_counter<=16'd0;
		else
		begin
			h_sync_counter<=h_sync_counter+1'b1;
			case(h_sync_counter)
				70:	 h_blank<=1;//us_58:	h_blank<=1; //60:	h_blank<=1;
				790: h_blank<=0;//us_640-us_15-us_47:	h_blank<=0;//780:	h_blank<=0;
				default: ;  
			endcase
		end
	end 

    //operate dpram
	//	assign 			dram_ads_n = 0; //////////////////////////////////////////////////////
	//	assign          dram_cnten_n = 1;
	//	assign          dram_rpt_n = 1;
	//	assign          dram_pl = 1;
	//	assign          dram_be0_n = 0;//~(h_blank && v_blank);
	//	assign          dram_be1_n = 0;//~(h_blank && v_blank);
	//	assign          dram_be2_n = 1;
	//	assign          dram_be3_n = 1;
		assign 			dram_ce0_n = ~(h_blank && v_blank);
	//	assign    		dram_ce1 = 1;//(h_blank && v_blank);
		assign 			dram_ren = (h_blank && v_blank);
	//	assign 			dram_oe_n = 0; //~(h_blank && v_blank);

	always @(negedge dac_hsync or posedge v_clk)
	begin
		if (!dac_hsync)
			dram_rclk <= 1;
		else
			dram_rclk <= ~dram_rclk;    //6.75mhz
	end
	
	//dram_addr[18:0]
	always @(negedge field or posedge v_blank)  //vb_delay
	begin	
		if (v_blank) 
			wrst <= 0;
		else 
			wrst <= 1;
	end		
	
	assign drst = wrst || rst;
	
	always @(posedge drst or posedge dram_rclk)//or posedge dram_ce //negedge dram_rclk20070611
	begin
		if (drst) 
			dram_addr <= 19'd0;
		else
		begin
			if (!dram_ce0_n)
			begin
				if(dram_addr == 19'h329ff)
					dram_addr <= 19'd0;
				else
					dram_addr <= dram_addr + 1'b1;
			end		
			else
				dram_addr <= dram_addr;
		end		
    end		  
	
	//输出灰度值
	//always @(posedge dram_ce0_n or negedge v_clk)
	//always @(negedge v_clk)
	//if (dram_ce0_n) pf_pixel  <= pf_pixel;
	//else if (dram_rclk) pf_pixel[7:0] <= dram_datain[7:0];
	//	 else pf_pixel[7:0] <= dram_datain[15:8];

	assign	pf_pixel	=	clk_10m_cnt[7:0]	;

endmodule
