module insert0(
	input                clk,              
	input                rst_n ,           
	input                trastart_flag,    
	input      [9:0]     db,               
	input      [7:0]     ramd,
	input                inr,	
	output     [7:0]     ram_outd		
); 		
	integer i;
	reg trans_start1, start;
    always @(posedge clk or negedge rst_n )
	begin
		if(rst_n == 0)
		begin
			trans_start1 <= 1'b0;
			start <= 1'b0;
		end
		else if(inr == 1)
		begin
			trans_start1 <= 1'b0;
			start <= 1'b0;
		end		
		else
		begin
			trans_start1 <= trastart_flag;
			start <= (trastart_flag & (~trans_start1));
		end
	end
	
 	reg [3:0] cnt_8;  reg [9:0] bytes;
	always @(posedge clk or negedge rst_n )
	begin
		if(rst_n == 0)
		begin
			cnt_8 <= 4'b0;
			bytes <= 4'd0;
		end
		else if(in_valid==1)
		begin
			if( cnt_8 < 4'd8  )
			begin
				cnt_8 <= cnt_8 + 1;
				bytes <= bytes;
			end	
			else
			begin
				cnt_8 <= 1;
				bytes <= bytes + 1; 
			end	
		end
		else
		begin
			cnt_8 <= 4'd0;
			bytes <= 4'd0;
		end
	end
		
	reg in_valid;
	always @(posedge clk or negedge rst_n )
	begin
		if(rst_n == 0)
			in_valid <= 1'b0;
		else if(start==1)
			in_valid <= 1'b1;
		else if((bytes < db) && (in_valid ==1))	
			in_valid <= 1'b1;
		else
			in_valid <= 1'b0;
	end
	
	reg [10:0] in_shift;
	always @(posedge clk or negedge rst_n ) 
	begin
		if(rst_n == 0)
			in_shift <= 11'd0;
		else if(inr == 1)
			in_shift <= 11'd0;
		else
			in_shift <= {in_shift[9:0],in_valid};
	end
	
	reg [7:0] ramd1,ramd2;
	wire insert0_flag_d5; reg insert0_flag_d6;
    always @(posedge clk or negedge rst_n )
	begin
		if(rst_n == 0)
		begin
			ramd1 <= 8'd0;
			ramd2 <= 8'd0;
			insert0_flag_d6 <= 0;
		end	
		else
		begin
			ramd1 <= ramd;
			ramd2 <= ramd1;
			insert0_flag_d6 <= insert0_flag_d5;
		end	
	end
	 
	reg [8:0] ram_insert0_waddr; reg [7:0] ram_insert0_wdata; reg ram_insert0_wren;
	
	always @(posedge clk or negedge rst_n )
	begin
		if(rst_n == 0)
		begin
			ram_insert0_waddr <= 9'b0;
			ram_insert0_wren <= 1'b0;
			ram_insert0_wdata <= 8'b0;
		end
		else if(cnt_8==4'd4 )  
		begin
			ram_insert0_waddr <= bytes; 	
			ram_insert0_wren  <= 1'b1;
			ram_insert0_wdata <= ramd2; 	
		end
		else
		begin
			ram_insert0_waddr <= ram_insert0_waddr;
		    ram_insert0_wren  <= 0; 
		    ram_insert0_wdata <= 0;
		end
	end	
	
	reg [7:0] buffer;
 	always @(posedge clk or negedge rst_n ) 
	begin
		if(rst_n==0)
			buffer <= 8'd0;
		else if(in_valid==1 || (in_shift[1]==1))
		begin
			if(cnt_8==4'd4)	
				buffer <= ramd2;
			else 
				buffer <= {buffer[0], buffer[7:1]};
		end	
		else
			buffer <= 8'd0;
	end	
	
	reg [2:0]  cnt_insert0;
	always @(posedge clk or negedge rst_n ) 
	begin
		if(rst_n == 0)
			cnt_insert0 <= 1'b0;
		else if(buffer[0]==0)
			cnt_insert0 <= 1'b0;
		else
		begin
			if(cnt_insert0==3'd5)
				cnt_insert0 <= 3'b1;
			else
				cnt_insert0 <= cnt_insert0 +1; 	
		end
	end
	
	wire insert0_flag = (cnt_insert0 == 3'd5); 
	
	wire insert0_flag_valid =  in_shift[3] & in_shift[5];
	
	flag_i0 u_flag_i0(
		.clk                    ( clk                 ),
		.rst_n                  ( rst_n               ),
		.insert0_flag           ( insert0_flag        ),
		.insert0_flag_valid     ( insert0_flag_valid  ),
		.inr 	                ( inr                 ),
													   
		.insert0_flag_d5        ( insert0_flag_d5     )
	);

	reg [8:0] ram_raddr[0:11];
	wire [8:0]ram_raddr11 = ram_raddr[11];
	wire [8:0] ram_raddr2 = ram_raddr[2];	
	wire [8:0] ram_raddr5 = ram_raddr[5]; 	
	reg [3:0] cnt_read; reg [8:0] read_bytes;
	
	always @(posedge clk or negedge rst_n ) 
	begin
		if(rst_n == 0)
			cnt_read <= 4'd8;
		else if( ((in_shift[10]==1) && (in_shift[8]==1)) || (0 < ram_raddr5) && (ram_raddr5 < db) ) 
		begin		
			if(insert0_flag_d5 == 1'b1)		
				cnt_read <= cnt_read;
			else if(cnt_read == 4'b1)
				cnt_read <= 4'd8;
			else 
				cnt_read <= cnt_read-1;
		end		
		else
			cnt_read <= 4'd8;	
	end
	
	reg [8:0] ram_insert0_raddr; reg ram_insert0_rden0;

	always @(posedge clk or negedge rst_n ) 
	begin
		if(rst_n == 0)
		begin
			ram_insert0_raddr <= 9'b0;	
            ram_insert0_rden0  <= 0;	
		end
		else if((in_shift[10] == 1) || ( (0 < ram_insert0_raddr) && (ram_raddr11 < db) ))
		begin
			if(cnt_read == 4'd8 && (insert0_flag_d6 != 1'b1) && (ram_insert0_raddr < db))
			begin	
				ram_insert0_raddr <= ram_insert0_raddr + 9'b1; 	
				ram_insert0_rden0  <= 1'b1;
			end
			else
			begin
				ram_insert0_raddr  <= ram_insert0_raddr;
				ram_insert0_rden0   <= 0;
			end
		end	
		else
		begin
			ram_insert0_raddr <= 9'b0;	
            ram_insert0_rden0  <= 0;	
		end	
	end
	
	always @(posedge clk)
	begin
		if(inr == 1)
		begin
			for(i=0;i<12;i=i+1)
			begin
				ram_raddr[i] <= 8'd0;
			end	
		end
		else
		begin
			ram_raddr[0] <= ram_insert0_raddr;
			for(i=0;i<11;i=i+1)
			begin
				ram_raddr[i+1] <= ram_raddr[i];
			end                         
		end	
	end
	
	reg ram_insert0_rden1,ram_insert0_rden;

	always @(posedge clk)
	begin
		ram_insert0_rden1  <= ram_insert0_rden0;
		ram_insert0_rden   <= ram_insert0_rden1 | ram_insert0_rden0;
	end
	
	wire [7:0] ram_insert0_rdata;
	reg ram_insert0_wren_d1; reg [8:0] ram_insert0_waddr_d1; reg [7:0] ram_insert0_wdata_d1;
	
	always @(posedge clk)
	begin
		ram_insert0_wren_d1    <= ram_insert0_wren  ;
		ram_insert0_waddr_d1   <= ram_insert0_waddr ;
		ram_insert0_wdata_d1   <= ram_insert0_wdata ;
	end
	
	insert0_ram u_insert0_ram (
	  .clka  ( clk                        ),      // input wire clka
	  .ena   ( ram_insert0_wren_d1        ),      // input wire [0 : 0] ena
	  .wea   ( 1'b1                       ),      // input wire [0 : 0] wea
	  .addra ( ram_insert0_waddr_d1       ),      // input wire [8 : 0] addra
	  .dina  ( ram_insert0_wdata_d1       ),      // input wire [7: 0] dina
			   
	  .clkb  ( clk                        ),      // input wire clkb
	  .enb   ( ram_insert0_rden           ), 
	  .addrb ( ram_raddr2                 ),      // input wire [7 : 0] addrb0
	  .doutb ( ram_insert0_rdata          )       // output wire [15 : 0] doutb
	);
	
	wire out_valid = (ram_raddr2 > 0 ) && (ram_raddr2 <=db);
	assign ram_outd = (out_valid==1) ? ram_insert0_rdata : 0;
	
endmodule	