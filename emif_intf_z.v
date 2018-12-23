`timescale 1ns/1ps

(* DONT_TOUCH = "yes" *)
module  emif_intf_z(
                    input                     clk_100m          , 
                    input                     rst_n            ,  

                    input         [15:00]     emif_data_i      ,
                    input         [23:00]     emif_addr_i      ,
                    input         [01:00]     emif_byten_i     ,
                    input                     emif_cen_i       ,
                    input                     emif_wen_i       ,
                    input                     emif_oen_i       ,

                    output  reg               emif_dpram_wen   ,
                    output  reg   [23:00]     emif_dpram_addr  ,
					output  reg   [15:00]     emif_dpram_wdata ,			
                    output reg                emif_dpram_ren 				
    );   
	                                                       												   
    reg [15:0]  emif_data_d0; reg [23:0]  emif_addr_d0; reg [ 1:0]  emif_byten_d0; reg emif_cen_d0;    reg emif_wen_d0 ; reg emif_oen_d0 ;
	reg [15:0]  emif_data_d1; reg [23:0]  emif_addr_d1; reg [23:0]  emif_addr_d2; 
	 (* dont_touch = "yes" *) reg [ 1:0]  emif_byten_d1;
	 (* dont_touch = "yes" *) reg         emif_cen_d1; 
	 (* dont_touch = "yes" *) reg         emif_wen_d1;  
	 (* dont_touch = "yes" *) reg         emif_oen_d1;   
	 (* dont_touch = "yes" *) reg         emif_wen_d2;  
     (* dont_touch = "yes" *) reg         emif_oen_d2;
	 (* dont_touch = "yes" *) reg [ 1:0]  emif_byten_d2;
										    
	always @(posedge clk_100m or negedge rst_n)
	begin
		if(rst_n==1'b0)
		begin
			emif_data_d0  <= 0;     emif_data_d1  <= 0;       
			emif_addr_d0  <= 0;     emif_addr_d1  <= 0;       emif_addr_d2  <= 0;
			emif_byten_d0 <= 2'b11; emif_byten_d1  <= 2'b11;  emif_byten_d2 <= 2'b11; 
			emif_cen_d0   <= 1;     emif_cen_d1    <= 1;     
			emif_wen_d0   <= 1;     emif_wen_d1    <= 1;      emif_wen_d2   <= 1;    
			emif_oen_d0   <= 1;     emif_oen_d1    <= 1;      emif_oen_d2   <= 1;    
		end
		else
		begin
			emif_data_d0 <= emif_data_i ; emif_addr_d0<={emif_addr_i[22:0],emif_addr_i[23]}; emif_byten_d0<=emif_byten_i;  emif_cen_d0<=emif_cen_i;  emif_wen_d0<=emif_wen_i;  emif_oen_d0 <=emif_oen_i ;
			emif_data_d1 <=emif_data_d0 ; emif_addr_d1  <=  emif_addr_d0  ;                  emif_byten_d1<=emif_byten_d0; emif_cen_d1<=emif_cen_d0; emif_wen_d1<=emif_wen_d0; emif_oen_d1 <=emif_oen_d0;
			emif_wen_d2  <=emif_wen_d1  ;
			emif_oen_d2  <=emif_oen_d1  ;
			emif_byten_d2<=emif_byten_d1; 
			emif_addr_d2 <= emif_addr_d1;			
 		end
	end

	reg emif_dpram_wen0,emif_dpram_ren0 ; reg   [23:00] emif_dpram_addr0 ; reg   [15:00] emif_dpram_wdata0;	
	
	
	always @(posedge clk_100m or negedge rst_n)
	begin
		if(rst_n==0)
		begin
			emif_dpram_ren0 <= 0;	
			emif_dpram_wen0 <= 0;
		    emif_dpram_addr0  <= 0 ;
		    emif_dpram_wdata0 <=	0;
		end
		else if( (emif_oen_d1==0) && (emif_oen_d2==1) && (emif_byten_d1==2'b00) && (emif_cen_d1==0) )
		begin
			emif_dpram_ren0 <= 1;
			emif_dpram_addr0   <= emif_addr_d2;
			emif_dpram_wen0 <= 0;
			emif_dpram_wdata0 <=	emif_dpram_wdata0;
		end
		else if(emif_cen_d1==1)
		begin
			emif_dpram_ren0 <= 0;
			emif_dpram_addr0   <= emif_dpram_addr0;
			emif_dpram_wen0 <= 0;
			emif_dpram_wdata0 <=	emif_dpram_wdata0;
		end
		else if( (emif_wen_d1==0) && (emif_wen_d2==1) && (emif_byten_d1==2'b00) && (emif_cen_d1==0) )
		begin
			emif_dpram_ren0 <= emif_dpram_ren0;	
			emif_dpram_wen0 <= 1;
			emif_dpram_addr0 <= emif_addr_d2;
			emif_dpram_wdata0 <= emif_data_d1;
		end	
		else
		begin		
			emif_dpram_ren0 <= emif_dpram_ren0;	
			emif_dpram_wen0 <= 0;
			emif_dpram_addr0  <= emif_dpram_addr0 ;
			emif_dpram_wdata0 <=	0;
		end	
	end		
	
	always @(posedge clk_100m)
	begin
		emif_dpram_ren   <= emif_dpram_ren0   ;
		emif_dpram_addr  <= emif_dpram_addr0  ;
		emif_dpram_wen   <= emif_dpram_wen0   ;
		emif_dpram_wdata <= emif_dpram_wdata0 ;
	end		

	`ifdef DEBUG1
		ila_8_16384_1120  emif_ila_8_16384_1120 (
			.clk    ( clk_100m         ), 
			.probe0 (emif_byten_i             ),
			.probe1 (  0          ),
			.probe2 ( {emif_cen_i,emif_wen_i,emif_oen_i}   ),
			.probe3 ( {emif_dpram_wen,emif_dpram_ren}    ),
			.probe4 ( {emif_oen_d1,emif_oen_d2,emif_byten_d2}          ),
			.probe5 ( emif_dpram_addr[7:0]         ),
			.probe6 ( emif_data_i ),
			.probe7 (emif_addr_i   )
		);
	`endif	

endmodule
