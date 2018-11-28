/*  将insert0_flag进行插零延迟，连续5个1打一拍
	即1111100011111010111011111 变成
	  11111(0)00011111(0)010111011111(0)
	利用RAM实现，考虑到RAM的清零，采用乒乓操作，避免时序排不开
	具体功能请运行flag_i0_testbench.v
*/

module flag_i0(
	input                clk,              
	input                rst_n ,           
	input                insert0_flag,
	input                insert0_flag_valid,		
	input                inr,	           // clear
	output               insert0_flag_d5
); 

	reg  [12:0] cnt_0_number,cnt_0_valid;
	
	always @(posedge clk or negedge rst_n )
	begin
		if(rst_n == 0)
			cnt_0_valid <= 12'b0;
		else if(inr == 1)
			cnt_0_valid <= 12'b0;
		else if(insert0_flag_valid==1)
			cnt_0_valid <= cnt_0_valid + 12'd1;
		else
			cnt_0_valid <= cnt_0_valid;
	end
	
	always @(posedge clk or negedge rst_n )
	begin
		if(rst_n == 0)
			cnt_0_number <= 12'b0;
		else if(inr == 1)
			cnt_0_number <= 12'b0;
		else if(insert0_flag_valid==1 )
		begin
			if(insert0_flag==1)			
				cnt_0_number <= cnt_0_number + 12'd1;
			else
				cnt_0_number <= cnt_0_number;
		end		
		else
			cnt_0_number <= cnt_0_number;
	end
	
	wire[12:0] addra = cnt_0_number + cnt_0_valid;
	reg [12:0] addrb0; reg flag_used;
	
	always @(posedge clk or negedge rst_n )
	begin
		if(rst_n == 0)
		begin
			addrb0 <= 13'b0;
			flag_used <= 0;
		end	
		else if(inr == 1)
		begin
			addrb0 <= 13'b0;
			flag_used <= 0;
		end	
		else if((addrb0 < addra) && (flag_used==0) )
		begin
			addrb0 <= addrb0 + 13'd1;
			flag_used <= 0;
		end
		else if((addrb0 > 0) && (addrb0 == addra) )
		begin
			addrb0 <= 0;
			flag_used <= 1;
		end
		else
		begin
			addrb0 <= 0;
			flag_used <= flag_used;
		end	
	end
	
	reg [12:0] addrb,addrb1;reg enb0,enb1;
	
	always @(posedge clk or negedge rst_n )
	begin
		if(rst_n == 0)
		begin
			addrb1 <= 13'b0;
			addrb  <= 13'b0;
			enb1   <= 0;
		end	
		else
		begin
			addrb1 <= addrb0;
			addrb  <= addrb1;
			enb1   <= enb0;
		end	
	end
		
	always @(posedge clk or negedge rst_n )
	begin
		if(rst_n == 0)
			enb0 <= 0;
		else if((1 <= addrb0) && (addrb0< addra))
			enb0 <= 1;
		else
			enb0 <= 0;
	end
	
	wire enb = enb0 | enb1;	
	
	/********sdjksdfjkjkfskjfskjl**************************/
	reg [12:0] write_zero_cnt_ji,max_addr_ji; reg write_zero_valid_ji;
	
	always @(posedge clk or negedge rst_n )
	begin
		if(rst_n == 0)
		begin
			write_zero_valid_ji <= 0;
			max_addr_ji <= 13'd0;
			write_zero_cnt_ji <= 13'd0;
		end	
		else if((1 <= addrb0) && (addrb0 == addra)&&(cnt_ji_ou==1))
		begin
			write_zero_cnt_ji <= 1;
			max_addr_ji <= addra;
			write_zero_valid_ji <= 0;			
		end	
		else if((write_zero_cnt_ji>=1) && (write_zero_cnt_ji<=max_addr_ji) )
		begin
			write_zero_cnt_ji <= write_zero_cnt_ji + 1'd1;
			write_zero_valid_ji <= 1;
			max_addr_ji <= max_addr_ji;
		end
		else
		begin
			write_zero_cnt_ji <= 13'd0;
			write_zero_valid_ji <= 0;
			max_addr_ji <= 13'd0;
		end
	end	
	
	reg [12:0] write_zero_cnt_ou,max_addr_ou; reg write_zero_valid_ou;
	always @(posedge clk or negedge rst_n )
	begin
		if(rst_n == 0)
		begin
			write_zero_valid_ou <= 0;
			max_addr_ou <= 13'd0;
			write_zero_cnt_ou <= 13'd0;
		end	
		else if((1 <= addrb0) && (addrb0 == addra)&&(cnt_ji_ou==0))
		begin
			write_zero_cnt_ou <= 1;
			max_addr_ou <= addra;
			write_zero_valid_ou <= 0;			
		end	
		else if((write_zero_cnt_ou>=1) && (write_zero_cnt_ou<=max_addr_ou) )
		begin
			write_zero_cnt_ou <= write_zero_cnt_ou + 1'd1;
			write_zero_valid_ou <= 1;
			max_addr_ou <= max_addr_ou;
		end
		else
		begin
			write_zero_cnt_ou <= 13'd0;
			write_zero_valid_ou <= 0;
			max_addr_ou <= 13'd0;
		end
	end
	
	reg [12:0] write_zero_cnt_ji_d1,write_zero_cnt_ji_d2,write_zero_cnt_ou_d1,write_zero_cnt_ou_d2;
	always @(posedge clk or negedge rst_n )
	begin
		if(rst_n == 0)
		begin
			write_zero_cnt_ji_d1 <= 0;
			write_zero_cnt_ji_d2 <= 0;
			write_zero_cnt_ou_d1 <= 0;
			write_zero_cnt_ou_d2 <= 0;
		end	
		else
		begin
		   write_zero_cnt_ji_d1 <= write_zero_cnt_ji;
		   write_zero_cnt_ji_d2 <= write_zero_cnt_ji_d1;
		   write_zero_cnt_ou_d1 <= write_zero_cnt_ou;
		   write_zero_cnt_ou_d2 <= write_zero_cnt_ou_d1;
		end
	end
	
	reg insert0_flag_valid_d1,insert0_flag_d1; reg [12:0] addra_d1;
	always @(posedge clk or negedge rst_n )
	begin
		if(rst_n == 0)
		begin
			insert0_flag_valid_d1 <= 0;
			insert0_flag_d1       <= 0; 
			addra_d1              <= 13'd0; 
		end	
		else
		begin
			insert0_flag_valid_d1 <= insert0_flag_valid;
			insert0_flag_d1       <= insert0_flag; 
			addra_d1              <= addra;
		end	
	end
	
	reg cnt_ji_ou;
	always @(posedge clk or negedge rst_n )
	begin
		if(rst_n == 0)
			cnt_ji_ou <= 0;	
		else if((insert0_flag_valid==1) && (insert0_flag_valid_d1==0))
			cnt_ji_ou <= cnt_ji_ou + 1;
		else
			cnt_ji_ou <= cnt_ji_ou;
	end	
	

	wire ena_ou = (cnt_ji_ou==0)?insert0_flag_valid_d1:0;
	wire ena_ji = (cnt_ji_ou==1)?insert0_flag_valid_d1:0;
	wire mux_ena_ou   = write_zero_valid_ou | ena_ou;
	wire mux_ena_ji   = write_zero_valid_ji | ena_ji;	
	
	wire dina_ou = (cnt_ji_ou==0)?insert0_flag_d1:0;
	wire dina_ji = (cnt_ji_ou==1)?insert0_flag_d1:0;
	wire mux_dina_ou = (write_zero_valid_ou==1)?0: dina_ou;
	wire mux_dina_ji = (write_zero_valid_ji==1)?0: dina_ji;
	
	wire [12:0] addra_ou = (cnt_ji_ou==0)?addra_d1:0;
	wire [12:0] addra_ji = (cnt_ji_ou==1)?addra_d1:0;
	wire [12:0] mux_addra_ou = (write_zero_valid_ou==1)?write_zero_cnt_ou_d2: addra_ou;
	wire [12:0] mux_addra_ji = (write_zero_valid_ji==1)?write_zero_cnt_ji_d2: addra_ji;
		
	wire enb_ou = (cnt_ji_ou==0)?enb:0;
	wire enb_ji = (cnt_ji_ou==1)?enb:0;

	wire [12:0] addrb_ou = (cnt_ji_ou==0)?addrb:0;
	wire [12:0] addrb_ji = (cnt_ji_ou==1)?addrb:0;
	
	wire doutb_ou,doutb_ji ;

	flag_insert0_ram ou_flag_insert0_ram (
	  .clka  ( clk                  ),    
	  .ena   ( mux_ena_ou           ),    
	  .wea   ( 1'b1                 ),    
	  .addra ( mux_addra_ou         ),    
	  .dina  ( mux_dina_ou          ),    
			   
	  .clkb  ( clk                  ),    
	  .rstb  ( ~rst_n               ),
	  .enb   ( enb_ou               ), 
	  .addrb ( addrb_ou             ),    
	  .doutb ( doutb_ou             )     
	);
	
	flag_insert0_ram ji_flag_insert0_ram (
	  .clka  ( clk                 ),    
	  .ena   ( mux_ena_ji          ),    
	  .wea   ( 1'b1                ),    
	  .addra ( mux_addra_ji        ),    
	  .dina  ( mux_dina_ji         ),    
			   
	  .clkb  ( clk                 ),    
	  .rstb  ( ~rst_n              ),
	  .enb   ( enb_ji              ), 
	  .addrb ( addrb_ji            ),    
	  .doutb ( doutb_ji            )     
	);

	assign  insert0_flag_d5 = (cnt_ji_ou==0)?doutb_ou:doutb_ji;
	
endmodule