module hdlctra(clk, rst_n, trastart_flag, db, ramd, datat, inr);
	input                clk;               
	input                rst_n ;            
	input                trastart_flag;     
	input      [9:0]     db;                
	input      [7:0]     ramd;              
	output reg           datat;             
	output reg           inr;               
	
	parameter [2:0]  TRA_FLAG = 0,TRA_DATA = 1,TRA_CRC = 2,TRA_FLAGEND = 3,TRA_CLEAR = 4;
	integer i;
	
	wire [7:0] ram_outd;
 	insert0  u_insert0(
		.clk            (clk           ),
		.rst_n          (rst_n         ),
		.trastart_flag  (trastart_flag ),
		.db             (db            ),
		.ramd           (ramd          ),
		.inr            (inr           ),
	
		.ram_outd    	(ram_outd   )
	); 	
	
	reg [7:0 ] ram_outd_d[0:9];
	
	always @(posedge clk or negedge rst_n )
	begin
		if(rst_n == 0)
		begin
			for(i=0;i<10;i=i+1)
			begin
				ram_outd_d[i] <= 8'd0;
			end	
		end
		else if(inr == 1)
		begin
			for(i=0;i<10;i=i+1)
			begin
				ram_outd_d[i] <= 8'd0;
			end	
		end
		else
		begin
			ram_outd_d[0] <= ram_outd;
			for(i=0;i<9;i=i+1)
			begin
				ram_outd_d[i+1] <= ram_outd_d[i];
			end                         
		end	
	end
	
	wire [7:0]ram_outd_d9 = ram_outd_d[9];
	
	reg [7: 0] tra_flag_buf; reg [15:0] tra_crc_buf; reg [7: 0] tra_buf; reg [2: 0] current_state; reg [5: 0] flag_count; reg [8: 0] bytes;reg [4: 0] tra_buf_judge;reg [9: 0] tra_bytes_1;	

	always @(posedge clk or negedge rst_n )
	begin
		if (rst_n == 1'b0)
		begin
			tra_buf_judge <= 5'd0; tra_buf <= 8'd0; current_state <= TRA_FLAG; flag_count <= 6'd0; inr <= 1'b0;
			tra_flag_buf <= 8'b01111110; bytes <= 9'd1; datat <= 1'b1; tra_crc_buf <= 16'b0; tra_bytes_1 <= 1'b0;
		end
		else 
		begin
			case (current_state)
				TRA_FLAG :
				begin
					inr <= 0;
					if (trastart_flag == 1'b1)
					begin
						datat <= tra_flag_buf[7];
						tra_flag_buf <= {tra_flag_buf[6:0], tra_flag_buf[7]};
						tra_bytes_1 <= db;
						if (flag_count == 31)
						begin
							flag_count <= 6'b000000;
							tra_buf <= ram_outd_d9;
							if (bytes == db + 1'b1)
								current_state <= TRA_CRC;
							else
								current_state <= TRA_DATA;
							tra_crc_buf <= 16'b1111_1111_1111_1111; 
							bytes <= bytes; tra_buf_judge <= tra_buf_judge;
						end
						else
						begin
							flag_count <= flag_count + 1'b1;
							tra_buf_judge <= tra_buf_judge; tra_buf <= tra_buf; 
							current_state <= current_state; bytes <= bytes; tra_crc_buf <= tra_crc_buf;
						end	
					end
					else
					begin
						tra_buf_judge <= tra_buf_judge; tra_buf <= tra_buf; current_state <= current_state; flag_count <= flag_count;
						tra_flag_buf <= tra_flag_buf; bytes <= bytes; datat <= datat; tra_crc_buf <= tra_crc_buf; tra_bytes_1 <= tra_bytes_1;
					end
				end
				TRA_DATA :
				begin
					if (tra_buf_judge[4:0] == 5'b11111)
					begin
						datat <= 1'b0;
						tra_buf_judge[4:0] <= {tra_buf_judge[3:0], 1'b0};
						tra_buf <= tra_buf; current_state <= current_state; flag_count <= flag_count; inr <= inr;
						tra_flag_buf <= tra_flag_buf; bytes <= bytes; tra_crc_buf <= tra_crc_buf; tra_bytes_1 <= tra_bytes_1;
					end
					else
					begin
						datat <= tra_buf[0];
						tra_buf_judge[4:0] <= {tra_buf_judge[3:0], tra_buf[0]};
						tra_crc_buf <= {tra_crc_buf[14:12], (tra_crc_buf[11] ^ tra_crc_buf[15] ^ tra_buf[0]), tra_crc_buf[10:5], (tra_crc_buf[4] ^ tra_crc_buf[15] ^ tra_buf[0]), tra_crc_buf[14:12], (tra_crc_buf[15] ^ tra_buf[0])};
						if (flag_count == 6'b000110)
						begin
							flag_count <= flag_count + 1'b1;
							tra_buf <= {tra_buf[0], tra_buf[7:1]};
							bytes <= bytes; current_state <= current_state;
						end	
						else if (flag_count == 6'b000111)
						begin
							tra_buf <= ram_outd_d9;
							bytes <= bytes + 9'b1;
							flag_count <= 6'b000000;
							if (bytes == tra_bytes_1)
								current_state <= TRA_CRC;
							else
								current_state <= current_state;
						end
						else
						begin
							flag_count <= flag_count + 1'b1;
							tra_buf <= {tra_buf[0], tra_buf[7:1]};
							bytes <= bytes; current_state <= current_state;
						end
						tra_flag_buf <= tra_flag_buf;   tra_bytes_1 <= tra_bytes_1; inr <= inr;
					end
				end	
				TRA_CRC :
				begin
					if (tra_buf_judge[4:0] == 5'b11111)
					begin
						datat <= 0;
						tra_buf_judge <= {tra_buf_judge[3:0], 1'b0};		
						tra_buf <= tra_buf; current_state <= current_state; flag_count <= flag_count;
						tra_flag_buf <= tra_flag_buf; bytes <= bytes; tra_crc_buf <= tra_crc_buf; tra_bytes_1 <= tra_bytes_1; inr <= inr;				
					end
					else
					begin
						datat <= (~tra_crc_buf[15]);
						tra_buf_judge <= {tra_buf_judge[3:0], ((~tra_crc_buf[15]))};
						tra_crc_buf <= {tra_crc_buf[14:0], tra_crc_buf[15]};
						if (flag_count == 6'b001111)
						begin
							current_state <= TRA_FLAGEND;
							flag_count <= 6'b000000;
						end
						else
						begin
							flag_count <= flag_count + 1'b1;
							current_state <= current_state;
						end	
						tra_buf <= tra_buf; tra_flag_buf <= tra_flag_buf; bytes <= bytes;  tra_bytes_1 <= tra_bytes_1; inr <= inr;
					end
				end	
				
				TRA_FLAGEND :
				begin
					if (tra_buf_judge == 5'b11111)
					begin
						datat <= 1'b0;
						tra_buf_judge <= 5'b00000;
						tra_flag_buf <= tra_flag_buf; flag_count <= flag_count; current_state <= current_state; inr <= inr;	
					end
					else
					begin	
						tra_flag_buf <= {tra_flag_buf[6:0], tra_flag_buf[7]};
						tra_buf_judge <= tra_buf_judge;
						if (flag_count == 32)
						begin
							flag_count <= 6'b000000;
							current_state <= TRA_CLEAR;
							datat <= 1'b1;
							inr <= 1'b1;
						end
						else
						begin
							flag_count <= flag_count + 1'b1;
							datat <= tra_flag_buf[7];
							current_state <= current_state; inr <= inr;	
						end			
					end
					bytes <= bytes; tra_crc_buf <= tra_crc_buf; tra_bytes_1 <= tra_bytes_1; tra_buf <= tra_buf;	
				end	
				TRA_CLEAR :
				begin
					tra_buf_judge <= 5'd0; tra_buf <= 8'd0; current_state <= TRA_FLAG; flag_count <= 6'd0; inr <= 1'b0;	
                    tra_flag_buf <= 8'b01111110; bytes <= 9'd1; datat <= 1'b1; tra_crc_buf <= 16'b0; tra_bytes_1 <= 1'b0;
				end
				default:
				begin
					tra_buf_judge <= 5'd0; tra_buf <= 8'd0; current_state <= TRA_FLAG; flag_count <= 6'd0; inr <= 1'b0;
					tra_flag_buf <= 8'b01111110; bytes <= 9'd1; datat <= 1'b1; tra_crc_buf <= 16'b0; tra_bytes_1 <= 1'b0;
				end
			endcase
		end
	end
		
endmodule