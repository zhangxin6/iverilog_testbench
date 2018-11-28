module gpio_intr_gen#
(
    parameter   PLUSE_WIDTH        =   100,   
    parameter   PERIOD             =   25_000_000                                                           			
)
(
	input     hard_rst_n,
	input     clk_25m_in,
	
	output   interrupt
);

	reg [31: 0] cnt;
	always @(posedge clk_25m_in or negedge hard_rst_n)
	begin
		if(!hard_rst_n)
			cnt <= 32'd0;
		else if (cnt < (PERIOD-1) )	
			cnt <= cnt + 32'd1;
		else
			cnt <= 0;
	end			
		
	reg interrupt_d;	
	always @(posedge clk_25m_in or negedge hard_rst_n)
	begin
		if(!hard_rst_n)
			interrupt_d <= 1'd0;
		else if ( (1 <= cnt) &&  (cnt <= PLUSE_WIDTH) )	
			interrupt_d <= 1'd1;
		else
			interrupt_d <= 1'd0;
	end

	assign interrupt = interrupt_d;
endmodule