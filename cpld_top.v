`timescale 1ns/1ps

module cpld_top(
		//--- clock and reset ---
		hard_rst_n              ,  
		clk_25m_in              ,                                                                                                   
		//---- dsp reset -------
		rst_c6678_soft_n        ,
		rst_c6678_local_n       ,
		rst_c6678_por_n         ,
		rst_c6678_full_n        ,
		dsp0_rstn_state         ,
		dsp0_coresel0           ,
		dsp0_coresel1           ,
		dsp0_coresel2           ,
		dsp0_coresel3           ,
		dsp0_lresetnmien_n      ,
		dsp0_timi0              ,
		dsp0_timi1              ,
		endian_dsp0             ,
		boot_strap0_1           ,
		boot_strap0_2           ,
		boot_strap0_3           ,
		boot_strap0_4           ,
		boot_strap0_5           ,
		boot_strap0_6           ,
		boot_strap0_7           ,
		boot_strap0_8           ,
		boot_strap0_9           ,
		boot_strap0_10          ,
		boot_strap0_11          ,
		boot_strap0_12          ,
		boot_strap0_13          , 
		dsp_led_0               
	);
	//==============================================================================
	// parameters
	//==============================================================================
	parameter               SPI_BOOT_MODE               = 13'b101_1100000_110;      
	parameter               DSP_RST_DELAY               = 16'hC350           ;  //2ms   @ 25MHz
	parameter               DSP_POR_RST_DELAY1          = 20'h1_24F8         ;  //3ms   @ 25MHz
	parameter               DSP_POR_RST_DELAY2          = 20'h1_55CC         ;  //3.5ms @ 25MHz                  
	//==============================================================================
	// input & output ports                                                                     
	//==============================================================================
	input         hard_rst_n          ;
	output        dsp_led_0           ;
	input         clk_25m_in          ;
	//-------------- dsp reset ------------------------------
	//dsp reset
	output        rst_c6678_soft_n    ;
	output        rst_c6678_local_n   ;
	output        rst_c6678_por_n     ;
	output        rst_c6678_full_n    ;
	input         dsp0_rstn_state     ;
	output        dsp0_timi0          ;
	output        dsp0_timi1          ;
	//Reserved                                   
	output        dsp0_coresel0       ;
	output        dsp0_coresel1       ;
	output        dsp0_coresel2       ;
	output        dsp0_coresel3       ;
	output        dsp0_lresetnmien_n  ;				
	inout   tri   endian_dsp0         ;
	output        boot_strap0_1       ;
	output        boot_strap0_2       ;
	output        boot_strap0_3       ;
	output        boot_strap0_4       ;
	inout   tri   boot_strap0_5       ;
	output        boot_strap0_6       ;
	output        boot_strap0_7       ;
	output        boot_strap0_8       ;
	output        boot_strap0_9       ;
	output        boot_strap0_10      ;
	output        boot_strap0_11      ;
	output        boot_strap0_12      ;
	output        boot_strap0_13      ;

	assign dsp0_coresel0   =  0;  assign dsp0_coresel1 = 0;       assign dsp0_coresel2  = 0; assign dsp0_coresel3 = 0; 
	assign rst_c6678_local_n= 0;  assign  dsp0_lresetnmien_n = 1; assign  dsp0_timi0    = 0; assign dsp0_timi1    = 0;	
	
	wire sys_clk; BUFG u_clk_bufg (.O(sys_clk),.I(clk_25m_in));
									
	reg     [19:0]      dsp_por_rst_cnt;
	reg dsp_por_rst_n_buf; reg dsp_rstfull_n_buf; reg dsp_rst_n_buf;
	always @ (posedge sys_clk)
	begin
		if(hard_rst_n == 1'b0)
		begin
			dsp_rst_n_buf       <= 0;
			dsp_por_rst_n_buf   <= 0;
			dsp_rstfull_n_buf   <= 0;
		end
		else if( (dsp_por_rst_cnt < DSP_POR_RST_DELAY1) && (dsp_por_rst_cnt >=DSP_RST_DELAY) )
		begin
			dsp_rst_n_buf       <= 1;
			dsp_por_rst_n_buf   <= 0;
			dsp_rstfull_n_buf   <= 0;
		end
		else if(dsp_por_rst_cnt < DSP_POR_RST_DELAY2 &&dsp_por_rst_cnt >=DSP_POR_RST_DELAY1 )
		begin
			dsp_rst_n_buf       <= 1;
			dsp_por_rst_n_buf   <= 1;
			dsp_rstfull_n_buf   <= 0;
		end
		else if(dsp_por_rst_cnt >DSP_POR_RST_DELAY2  )
		begin
			dsp_rst_n_buf       <= 1;
			dsp_por_rst_n_buf   <= 1;
			dsp_rstfull_n_buf   <= 1;
		end
		else
		begin
			dsp_rst_n_buf       <= dsp_rst_n_buf;
			dsp_por_rst_n_buf   <= dsp_por_rst_n_buf;
			dsp_rstfull_n_buf   <= dsp_rstfull_n_buf;
		end
	end
	
	assign rst_c6678_soft_n = dsp_rst_n_buf;
	
	always @ (posedge sys_clk)
	begin
		if(hard_rst_n == 0)
			dsp_por_rst_cnt <= 20'd0;
		else if (dsp_por_rst_cnt > (DSP_POR_RST_DELAY2 + 20'd100))
			dsp_por_rst_cnt <= dsp_por_rst_cnt;
		 else
			dsp_por_rst_cnt <= dsp_por_rst_cnt + 1;
	end

	assign rst_c6678_full_n = dsp_rstfull_n_buf; assign rst_c6678_por_n  = dsp_por_rst_n_buf;

	gpio_intf #(
			.DSP0_BOOT_MODE   (SPI_BOOT_MODE)
		)
			u_gpio_intf(
			//system signals:clock and reset
			.clk_sys            (sys_clk        ),
			.rst_sys            ( 1             ),
			//dsp state signals from cpld
			.dsp0_rstn_state    (dsp0_rstn_state),
			//dsp gpio signals
			.endian_dsp0        (endian_dsp0    ),
			.boot_strap0_1      (boot_strap0_1  ),
			.boot_strap0_2      (boot_strap0_2  ),
			.boot_strap0_3      (boot_strap0_3  ),
			.boot_strap0_4      (boot_strap0_4  ),
			.boot_strap0_5      (boot_strap0_5  ),
			.boot_strap0_6      (boot_strap0_6  ),
			.boot_strap0_7      (boot_strap0_7  ),
			.boot_strap0_8      (boot_strap0_8  ),
			.boot_strap0_9      (boot_strap0_9  ),
			.boot_strap0_10     (boot_strap0_10 ),
			.boot_strap0_11     (boot_strap0_11 ),
			.boot_strap0_12     (boot_strap0_12 ),
			.boot_strap0_13     (boot_strap0_13 ),
			//led
			.dsp_led_0          (dsp_led_0      )
			);
   
endmodule
