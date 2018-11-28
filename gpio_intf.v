//-- Description  :  C6678_4DSP_DDR3_VPX SD FPGA Project
//-- 02/20/2014  huangxiaojie  1.0   Create new

`timescale 1ns/1ps

module gpio_intf(
                    clk_sys      ,
                    rst_sys      ,
                    //dsp state signals from cpld
                    dsp0_rstn_state,
                    //dsp gpio signals
                    endian_dsp0  ,
                    boot_strap0_1,
                    boot_strap0_2,
                    boot_strap0_3,
                    boot_strap0_4,
                    boot_strap0_5,
                    boot_strap0_6,
                    boot_strap0_7,
                    boot_strap0_8,
                    boot_strap0_9,
                    boot_strap0_10,
                    boot_strap0_11,
                    boot_strap0_12,
                    boot_strap0_13,
                    dsp_led_0
                    );

	parameter DSP0_BOOT_MODE = 13'b101_1100000_110;//dsp boot config
	parameter  PCIE_EP  = 2'b00, PCIE_LEP = 2'b01, PCIE_RC  = 2'b10 ;

	input                 clk_sys          ;
	input                 rst_sys          ;                              
	input                 dsp0_rstn_state  ;
	inout   tri           endian_dsp0      ;
	output                boot_strap0_1    ;
	output                boot_strap0_2    ;
	output                boot_strap0_3    ;
	output                boot_strap0_4    ;
	inout   tri           boot_strap0_5    ;
	output                boot_strap0_6    ;
	output                boot_strap0_7    ;
	output                boot_strap0_8    ;
	output                boot_strap0_9    ;
	output                boot_strap0_10   ;
	output                boot_strap0_11   ;
	output                boot_strap0_12   ;
	output                boot_strap0_13   ;  
	output                dsp_led_0        ;
	//########################internal signals####################//
	
	assign  endian_dsp0    =   1;
	assign  boot_strap0_1  =   0;     
	assign  boot_strap0_2  =   1;     
	assign  boot_strap0_3  =   1;     
	assign  boot_strap0_4  =   0;     
	assign  boot_strap0_5  =   1'bz;  
	assign  boot_strap0_6  =   0;     
	assign  boot_strap0_7  =   0;     
	assign  boot_strap0_8  =   0;     
	assign  boot_strap0_9  =   1;     
	assign  boot_strap0_10 =   1;     
	assign  boot_strap0_11 =   1;     
	assign  boot_strap0_12 =   0;     
	assign  boot_strap0_13 =   1;     

	reg dsp_gpio_0 ;
	always @ (posedge clk_sys or posedge rst_sys)
	begin
		if (rst_sys==1'b1)
			dsp_gpio_0 <= 1'b0 ;
		else
		begin
			if(dsp0_rstn_state==1'b1)
				dsp_gpio_0 <= endian_dsp0 ;
			else
				dsp_gpio_0 <= 1'b0 ;
		end
	end
	
	assign dsp_led_0 =  dsp_gpio_0 ;

endmodule
