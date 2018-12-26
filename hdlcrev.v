`timescale 1 ns / 1 ns
`define DEBUG

module hdlcrev(rst_n , clk_100m, clkr, datar, flagr, ramd, rama, hwr, interrupt);
	input              rst_n;                // 复位，低有效
	input              clk_100m;
	input              clkr;                 // 接收数据时钟
	input              datar;                // 数据
	input              flagr;                // 接收开始信号
	output reg [7:0]   ramd ;                 // 接收缓存数据信号
	output reg [8:0]  rama;                 // 接收缓存地址信号
	output reg         hwr;                  // 接收缓存写信号
	output reg         interrupt;                  // 接收完成中断信号

	parameter  [2:0]   HDLC_TYPE_REC_FLAG = 0,HDLC_TYPE_REC_WAIT = 1,HDLC_TYPE_REC_DATA = 2,HDLC_TYPE_REC_OVER = 3,HDLC_TYPE_REC_CLEAR = 4;
	parameter  ADDR_LENGH_REC1 = 9'd510; parameter ADDR_LENGH_REC2 = 9'd511;
	 

	reg syncflag3,flag1,clear; reg [15:0] wait_buf; reg [6: 0] rec_flag_buf;

	always @(negedge rst_n or posedge clkr )
	begin
		if ( (rst_n == 1'b0))
		begin
			rec_flag_buf <= 7'b0000000; syncflag3 <= 1'b0; wait_buf <= 16'b0000000000000000;
		end
		else
		begin
			if(clear == 1'b1)
			begin
				rec_flag_buf <= 7'b0000000; syncflag3 <= 1'b0; wait_buf <= 16'b0000000000000000;
			end
			else
			begin	
				rec_flag_buf <= {rec_flag_buf[5:0], datar};
				wait_buf <= {wait_buf[14:0], rec_flag_buf[6]};
				if (({rec_flag_buf,datar}== 8'b01111110) && (flag1 == 1'b1))
					syncflag3 <= 1'b1;
				else
					syncflag3 <= 1'b0;
			end		
		end
	end

	reg  [2:0 ]  current_state; reg  [7:0 ]   rec_buf; reg  [2:0 ] count;  reg newbyte_buf,bytes_flag,crcwr_flag;
	reg  [4:0 ]  waitnum; reg  [15:0]  rec_crc_buf; reg  [4:0 ]  wait_count; reg  [4: 0]  rec_buf_judge; reg  [7 :0]  ramd0;

	always @(negedge rst_n or posedge clkr)
	begin
		if ( rst_n == 1'b0 )
		begin
			current_state <= HDLC_TYPE_REC_FLAG; rec_buf <= 8'b00000000; count <= 3'b000; newbyte_buf <= 1'b0; bytes_flag <= 1'b0;   crcwr_flag <= 1'b0;
			flag1 <= 1'b1; waitnum <= 5'b10101; wait_count <= 5'b00000; rec_buf_judge <= 5'b00000 ;ramd0 <= 8'b0000_0000; rec_crc_buf <= 16'b0000_0000_0000_0000;
		end
		else
		begin
			case (current_state)
				HDLC_TYPE_REC_FLAG :
				begin
					if (flagr == 1'b1)
					begin
						bytes_flag <= 1'b0;
						newbyte_buf <= 1'b0;
						if (syncflag3 == 1'b1)
						begin
							flag1 <= 1'b0;
							current_state <= HDLC_TYPE_REC_WAIT;
							wait_count <= 5'b00000;
							waitnum <= 5'b10101;
						end
						else
						begin
							current_state <= current_state; flag1 <= flag1;  waitnum <= waitnum; wait_count <= wait_count;
						end
						rec_buf <= rec_buf; count <= count; crcwr_flag <= crcwr_flag;  rec_buf_judge <= rec_buf_judge; ramd0 <= ramd0; rec_crc_buf <= rec_crc_buf;
					end
					else
					begin
						current_state <= current_state; rec_buf <= rec_buf; count <= count; newbyte_buf <= newbyte_buf; bytes_flag <= bytes_flag; crcwr_flag <= crcwr_flag;
                        flag1 <= flag1;  waitnum <= waitnum; wait_count <= wait_count; rec_buf_judge <= rec_buf_judge; ramd0 <= ramd0; rec_crc_buf <= rec_crc_buf;
					end
				end
				HDLC_TYPE_REC_WAIT :
				begin
					crcwr_flag <= 1'b0;
					if (({rec_flag_buf, datar}) == 8'b01111110)
					begin
						wait_count <= 5'b00000;
						waitnum <= 5'b10110;
						current_state <= current_state;  bytes_flag <= bytes_flag; count <= count; rec_buf_judge <= rec_buf_judge; rec_crc_buf <= rec_crc_buf;
					end
					else if (wait_count == waitnum)
					begin
						wait_count <= 5'b00000;
						current_state <= HDLC_TYPE_REC_DATA;
						count <= 3'b000;
						bytes_flag <= 1'b1;
						rec_buf_judge <= 5'b00000;
						rec_crc_buf <= 16'b1111111111111111;
						waitnum <= waitnum;
					end
					else
					begin
						wait_count <= wait_count + 1'b1;
						current_state <= current_state;  bytes_flag <= bytes_flag; count <= count; rec_buf_judge <= rec_buf_judge; rec_crc_buf <= rec_crc_buf; waitnum <= waitnum;
					end
					rec_buf <= rec_buf; newbyte_buf <= newbyte_buf; flag1 <= flag1; ramd0 <= ramd0;
				end
				HDLC_TYPE_REC_DATA :
				begin
					if (rec_buf_judge[4:0] == 5'b11111)
					begin
						rec_buf_judge <= {rec_buf_judge[3:0], 1'b0};
						newbyte_buf <= 1'b0;
						rec_buf <= rec_buf; count <= count; bytes_flag <= bytes_flag;
                        flag1 <= flag1;  waitnum <= waitnum; wait_count <= wait_count; ramd0 <= ramd0; rec_crc_buf <= rec_crc_buf;
					end
					else
					begin
						rec_buf_judge <= {rec_buf_judge[3:0], wait_buf[15]};
						rec_buf <= {wait_buf[15], rec_buf[7:1]};
						rec_crc_buf <= {rec_crc_buf[14:12], (wait_buf[15] ^ rec_crc_buf[11] ^ rec_crc_buf[15]), rec_crc_buf[10:5], (rec_crc_buf[4] ^ rec_crc_buf[15] ^ wait_buf[15]), rec_crc_buf[3:0], (rec_crc_buf[15] ^ wait_buf[15])};
						count <= count + 1'b1;
						if (count == 3'b111)
						begin
							newbyte_buf <= 1'b1;
							ramd0 <= {wait_buf[15], rec_buf[7:1]};
						end
						else
						begin
							newbyte_buf <= 1'b0; ramd0 <= ramd0;
						end
							bytes_flag <= bytes_flag; flag1 <= flag1;  waitnum <= waitnum; wait_count <= wait_count;
					end
					if (({rec_flag_buf, datar}) == 8'b01111110)
					begin
                        current_state <= HDLC_TYPE_REC_OVER;
                        crcwr_flag <= 1'b1;
					end
					else
					begin
						current_state <= current_state; crcwr_flag <= crcwr_flag;
					end
				end
				HDLC_TYPE_REC_OVER :
				begin
					newbyte_buf <= 1'b0;
					flag1 <= 1'b1;
					crcwr_flag <= 0;
					current_state <= HDLC_TYPE_REC_CLEAR; rec_buf <= rec_buf; count <= count; bytes_flag <= bytes_flag;
                    waitnum <= waitnum; wait_count <= wait_count; rec_buf_judge <= rec_buf_judge; ramd0 <= ramd0; rec_crc_buf <= rec_crc_buf;
                end
			    HDLC_TYPE_REC_CLEAR :
			    begin
					if(clear==1)
					begin
						current_state <= HDLC_TYPE_REC_FLAG;
						bytes_flag <= 1'b0;
					end	
					else
					begin					
						current_state <= current_state; 
						bytes_flag <= bytes_flag; 
					end
					rec_buf <= 8'b00000000; count <= 3'b000; newbyte_buf <= 1'b0; crcwr_flag <= 1'b0;
					flag1 <= 1'b1; waitnum <= 5'b10101; wait_count <= 5'b00000; rec_buf_judge <= 5'b00000 ;ramd0 <= 8'b0000_0000; rec_crc_buf <= 16'b0000_0000_0000_0000;   
                end
				default:
				begin
					current_state <= HDLC_TYPE_REC_FLAG; rec_buf <= 8'b00000000; count <= 3'b000; newbyte_buf <= 1'b0; bytes_flag <= 1'b0;   crcwr_flag <= 1'b0;
					flag1 <= 1'b1; waitnum <= 5'b10101; wait_count <= 5'b00000; rec_buf_judge <= 5'b00000 ;ramd0 <= 8'b0000_0000; rec_crc_buf <= 16'b0000_0000_0000_0000;
				end
			endcase
		end
	end

	reg newbytes_flag1;

	always @(negedge rst_n or posedge clkr)
	begin
		if ( rst_n == 1'b0 )
			newbytes_flag1 <= 1'b0;
		else if(clear == 1'b1)
			newbytes_flag1 <= 1'b0;
		else
			newbytes_flag1 <= newbyte_buf;
	end

	reg   [8:0] bytes;

	always @(negedge rst_n or posedge clkr)
	begin
		if (rst_n == 1'b0)
			bytes <= 12'b000000000000;
		else if(clear == 1'b1)
			bytes <= 12'b000000000000;
		else
		begin
			if(bytes_flag == 1'b0)
				bytes <= 12'b000000000000;
			else if(newbytes_flag1 == 1'b1)
				bytes <= bytes + 1'b1;
			else
				bytes <= bytes;
		end
	end

	reg [7: 0] rec_crc_buf1,rec_crc_buf2;

	always @(negedge rst_n or posedge clkr)
	begin: crc_pd_gen
		if ( rst_n == 1'b0 )
		begin
			rec_crc_buf1 <= 8'b00000000; rec_crc_buf2 <= 8'b00000000;
		end
		else if(clear == 1'b1)
		begin
			rec_crc_buf1 <= 8'b00000000; rec_crc_buf2 <= 8'b00000000;
		end		
		else
		begin
			if (newbyte_buf == 1'b1)
			begin
				rec_crc_buf1 <= rec_crc_buf[15:8];
				rec_crc_buf2 <= rec_crc_buf[7:0];
			end
			else
			begin
			    rec_crc_buf1 <= rec_crc_buf1 ;
			    rec_crc_buf2 <= rec_crc_buf2 ;
			end
		end
	end
	/***********数据接收完后，写入一个数据个数******************/
	reg inr1,inr_neg;
	always @(negedge rst_n or posedge clkr)
	begin
		if (rst_n == 1'b0)
		begin
			inr1 <= 1'b0; inr_neg <= 1'b0;
		end
		else
		begin
			inr1 <= inr; inr_neg <= (~inr) & (inr1);
		end
	end

	reg [5:0] cnt_last_write;
	always @(negedge rst_n or posedge clkr)
	begin
		if (rst_n == 1'b0)
			cnt_last_write <= 6'd0;
		else if(inr_neg==1)
			cnt_last_write <= 6'd1;
		else if( (1 <= cnt_last_write )&& (cnt_last_write <= 6'd50) )
			cnt_last_write <= cnt_last_write +6'd1;
		else
			cnt_last_write <= 6'd0;
	end

	always @(negedge rst_n or posedge clkr)
	begin
		if (rst_n == 1'b0)
			clear <= 0;
		else if( (cnt_last_write == 6'd48) || (cnt_last_write == 6'd49) )
			clear <= 1;
		else
			clear <= 0;
	end

	reg last_wren_first;
	always @(negedge rst_n or posedge clkr)
	begin
		if (rst_n == 1'b0)
			last_wren_first <= 0;
		else if(cnt_last_write == 6'd6)
			last_wren_first <= 1;
		else
			last_wren_first <= 0;
	end
	
	reg last_wren_second;
	always @(negedge rst_n or posedge clkr)
	begin
		if (rst_n == 1'b0)
			last_wren_second <= 0;
		else if(cnt_last_write == 6'd14)
			last_wren_second <= 1;
		else
			last_wren_second <= 0;
	end	

	
	`ifdef DEBUG1
		ila_8_16384_1120  h_ila_8_16384_1120 (
			.clk    ( clk_100m                      ), 
			.probe0 ( {datar,clkr}                  ),      
			.probe1 ( {syncflag3,flagr}             ),      
			.probe2 ( current_state                 ),       
			.probe3 ( 4'b0                          ),       
			.probe4 ( wait_count                    ),       
			.probe5 ( rec_flag_buf                  ),        
			.probe6 ( {inr_neg,cnt_last_write,crcwr_flag,interrupt} ),        
			.probe7 ( 32'b0                         )
		);
	`endif
	
	
	/********************ila2********************/
/* 		ila_4  u_ila_4 (
		.clk    ( clkr                   ), // input wire clk
		.probe0 ( datar                  ), // input wire  probe0
		.probe1 ( syncflag3              ), // input wire  probe1
		.probe2 ( flag1                  ), // input wire   probe2
		.probe3 ( current_state          ), // input wire [02:0]  probe3
		.probe4 ( bytes                  ),  // input wire [8:0]  probe4
		.probe5 ( newbytes_flag1         ),  // input wire [00:0]  probe4
		.probe6 ( rama                   ),  // input wire [8 :0]  probe4
		.probe7 ( ramd                   ),  // input wire [07:0]  probe4
		.probe8 ( count                  ),  // input wire [02:0]  probe4
		.probe9 ( wait_buf               ),  // input wire [15:0]  probe4
		.probe10( hwr                    )   // input wire [00:0]  probe4
	);  */
	reg [7:0] ramd1,ramd2;          
	reg [8:0] rama1,rama2;            
	reg hwr1,hwr2,interrupt1,interrupt2; 
	
	
	always @(negedge rst_n or posedge clkr)
	begin
		if (rst_n == 1'b0)
			interrupt1 <= 1'd0;
		else
			interrupt1 <= last_wren_second;
	end
	
	always @(negedge rst_n or posedge clkr)
	begin
		if (rst_n == 1'b0)
		begin
			rama1 <= 9'd0;
			ramd1 <= 8'd0;
			hwr1  <= 1'b0;
		end
		else if(last_wren_first==1)
		begin
			rama1 <= ADDR_LENGH_REC1;
			ramd1 <= bytes[7:0];  
			hwr1  <= 1'b1;
		end
		else if(last_wren_second==1)
		begin
			rama1 <= ADDR_LENGH_REC2;
			ramd1 <= bytes[8];  
			hwr1  <= 1'b1;
		end		
		else
		begin
			rama1 <= bytes;
			ramd1 <= ramd0;
			hwr1 <=  newbytes_flag1;
		end	
	end
	
	//跨时钟域	
	always @(posedge clkr)
	begin
		interrupt2  <= interrupt1;  interrupt  <= interrupt2;
		rama2       <= rama1     ;  rama       <= rama2     ;
		ramd2       <= ramd1     ;  ramd       <= ramd2     ;
		hwr2        <= hwr1      ;  hwr        <= hwr2      ;
	end
	
	assign inr = crcwr_flag;	
endmodule
