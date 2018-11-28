`timescale 1ns/1ps

module  emif_intf(
                    //system signals
                    clk_ref                     ,
                    rst_n                       ,
                    //emif interface signals    
                    emif_data_z                 ,
                    emif_addr_i                 ,
                    emif_byten_i                ,
                    emif_cen_i                  ,
                    emif_wen_i                  ,
                    emif_oen_i                  ,
                    emif_wait_o                 ,
                    emif_rnw_i                  ,
                    //user dpram interface      
                    emif_dpram_wen              ,
					emif_dpram_ren_2            ,
                    emif_dpram_addr             ,
                    emif_dpram_wdata            ,
                    emif_dpram_rdata            
    );
	parameter           DELAY_TIME = 9'd500;//5000ns time count work mode ; DELAY_TIME = 9'h60  test mode    
	                                                       
	//*****emif interface parameter*****************************************************/                    
	//write setup   16 CPU/6 periods
	//write strobe  64 CPU/6 periods
	//write hold    8  CPU/6 periods
	//read  setup   16 CPU/6 periods
	//read  strobe  64 CPU/6 periods
	//read  hold    8  CPU/6 periods
	//turn  around  4  CPU/6 periods
	//******************************************************************************/
	//system signals
	input                     clk_ref      ;    
	input                     rst_n        ;     
	//emif interface signals
	inout   tri   [15:00]     emif_data_z  ; 
	input         [23:00]     emif_addr_i  ; 
	input         [01:00]     emif_byten_i ; 
	input                     emif_cen_i   ; 
	input                     emif_wen_i   ; 
	input                     emif_oen_i   ; 
	output        [01:00]     emif_wait_o  ; 
	input                     emif_rnw_i   ; 
	//user dpram interface
	output  reg               emif_dpram_wen   ;
	output  reg   [23:00]     emif_dpram_addr  ;
	output  reg   [15:00]     emif_dpram_wdata ;
	input   wire  [15:00]     emif_dpram_rdata ;
	output                    emif_dpram_ren_2 ;
	//******************************************************************************//
	//synchronize  the asynchronous signals
	reg   [15:0]     emif_data_d0   ;
	reg   [23:0]     emif_addr_d0   ;
	reg   [ 1:0]     emif_byten_d0  ;
	reg   [ 1:0]     emif_cen_d0    ;
	reg              emif_wen_d0    ;
	reg              emif_oen_d0    ;
	reg   [15:0]     emif_data_d1   ;
	reg   [23:0]     emif_addr_d1   ;
	reg   [ 1:0]     emif_byten_d1  ;
	reg   [ 1:0]     emif_cen_d1    ;
	reg              emif_wen_d1    ;
	reg              emif_oen_d1    ;
	reg              emif_dpram_ren ;
	reg   [15:0]     emif_data_d2   ;
	reg   [23:0]     emif_addr_d2   ;
	reg              emif_wen_d2    ;
	reg              emif_oen_d2    ;
	reg   [15:0]     emif_data_d3   ;
	reg   [23:0]     emif_addr_d3   ;
	reg              emif_wen_d3    ;
	reg              emif_oen_d3    ;
	reg              emif_wen_d4    ;
	reg              emif_oen_d4    ;

	reg   [08:00]     delay_count;

	always @(posedge clk_ref or negedge rst_n)
	begin
		if(rst_n==1'b0)
		begin
			emif_data_d0  <= 16'b0;
			emif_addr_d0  <= 17'b0;
			emif_byten_d0 <= 2'b11;
			emif_cen_d0   <= 1;
			emif_wen_d0   <= 1;
			emif_oen_d0   <= 1;
			emif_data_d1  <= 16'b0;
			emif_addr_d1  <= 17'b0;
			emif_byten_d1 <= 2'b11;
			emif_cen_d1   <= 1;
			emif_wen_d1   <= 1;
			emif_oen_d1   <= 1;
			emif_data_d2  <= 16'b0;
			emif_addr_d2  <= 17'b0;
			emif_wen_d2   <= 1;
			emif_oen_d2   <= 1;
			emif_data_d3  <= 16'b0;
			emif_addr_d3  <= 17'b0;
			emif_wen_d3   <= 1;
			emif_oen_d3   <= 1;
			emif_wen_d4   <= 1;
			emif_oen_d4   <= 1;
		end
		else
		begin
			emif_data_d0  <=  emif_data_z   ; emif_addr_d0 <= {emif_addr_i[22:0],emif_addr_i[23]}  ;
			emif_byten_d0 <=  emif_byten_i  ;
			emif_cen_d0   <=  emif_cen_i    ;
			emif_wen_d0   <=  emif_wen_i    ;
			emif_oen_d0   <=  emif_oen_i    ;
			emif_data_d1  <=  emif_data_d0  ;
			emif_addr_d1  <=  emif_addr_d0  ;
			emif_byten_d1 <=  emif_byten_d0 ;
			emif_cen_d1   <=  emif_cen_d0   ;
			emif_wen_d1   <=  emif_wen_d0   ;
			emif_oen_d1   <=  emif_oen_d0   ;
			emif_data_d2  <=  emif_data_d1  ;
			emif_addr_d2  <=  emif_addr_d1  ;
			emif_wen_d2   <=  emif_wen_d1   ;
			emif_oen_d2   <=  emif_oen_d1   ;
			emif_data_d3  <=  emif_data_d2  ;
			emif_addr_d3  <=  emif_addr_d2  ;
			emif_wen_d3   <=  emif_wen_d2   ;
			emif_oen_d3   <=  emif_oen_d2   ;
			emif_wen_d4   <=  emif_wen_d3   ;
			emif_oen_d4   <=  emif_oen_d3   ;
		end
	end

	(*keep="true"*)reg [3:0] fsm_curr_st; (*keep="true"*)reg [3:0] fsm_next_st;
	
	parameter FSM_IDLE_STATE = 4'b0001,FSM_SS_SETUP_STATE = 4'b0010,FSM_SS_STROB_STATE = 4'b0100,FSM_SS_HOLD_STATE  = 4'b1000;   
	//1st segment
	always @(posedge clk_ref or negedge rst_n)
	begin
		if (rst_n==1'b0)
			fsm_curr_st  <=  FSM_IDLE_STATE;
		else
			fsm_curr_st  <=  fsm_next_st;
	end
	//2nd segment
	always @(*)
	begin
		case(fsm_curr_st)
			FSM_IDLE_STATE:
			begin
				if((emif_byten_d1!=2'b11) && (emif_cen_d1==1'b1))
					fsm_next_st = FSM_SS_SETUP_STATE ;
				else
					fsm_next_st = FSM_IDLE_STATE ;
			end
			FSM_SS_SETUP_STATE:
			begin
				if((emif_byten_d1!=2'b11) && (emif_cen_d1!=1'b1) && (emif_wen_d1==1'b0 || emif_oen_d1==1'b0))
					fsm_next_st = FSM_SS_STROB_STATE ;
				else if(delay_count==DELAY_TIME)
					fsm_next_st = FSM_IDLE_STATE ;
				else
					fsm_next_st = FSM_SS_SETUP_STATE ;
			end
			FSM_SS_STROB_STATE:
			begin
				if((emif_byten_d1!=2'b11) && (emif_cen_d1==1'b1) && (emif_wen_d1==1'b1) && (emif_oen_d1==1'b1))
					fsm_next_st = FSM_SS_HOLD_STATE ;
				else if(delay_count==DELAY_TIME)
					fsm_next_st = FSM_IDLE_STATE ;
				else
					fsm_next_st = FSM_SS_STROB_STATE ;
			end
			FSM_SS_HOLD_STATE:
			begin
				if((emif_byten_d1==2'b11) && (emif_cen_d1==1'b1))
					fsm_next_st = FSM_IDLE_STATE ;
				else if(delay_count==DELAY_TIME)
					fsm_next_st = FSM_IDLE_STATE ;
				else
					fsm_next_st = FSM_SS_HOLD_STATE;
			end
			default:
			begin
				fsm_next_st = FSM_IDLE_STATE ;
			end
		endcase
	end
	//3rd segment
	always @(posedge clk_ref or negedge rst_n)
	begin
		if(rst_n==1'b0)
		begin
			delay_count <= 9'b0;
		end
		else
		begin
			if(fsm_curr_st==FSM_IDLE_STATE)
			begin
				delay_count <= 9'b0;
			end
			else if(fsm_next_st!=fsm_curr_st)
			begin
				delay_count <= 9'b0;
			end
			else
			begin
				if(delay_count<DELAY_TIME)  
				begin
					delay_count <= delay_count + 1 ;
				end
				else
				begin
					delay_count <= delay_count ;
				end
			end
		end
	end

	always @(posedge clk_ref or negedge rst_n)
	begin
		if(rst_n==1'b0)
		begin
			emif_dpram_wdata <= 16'b0;
			emif_dpram_addr  <= 23'b0;
			emif_dpram_wen   <= 1'b0;
			emif_dpram_ren   <= 1'b0;
		end
		else
		begin
			if(fsm_curr_st==FSM_SS_STROB_STATE)
			begin
				if(emif_oen_d3==1'b0 && emif_oen_d4==1'b1)
				begin
					emif_dpram_wdata <= 16'b0;
					emif_dpram_addr  <= emif_addr_d3;
					emif_dpram_wen   <= 1'b0;
					emif_dpram_ren   <= 1'b1;
				end
				else
				begin
					emif_dpram_wdata <= emif_dpram_wdata;
					emif_dpram_addr  <= emif_dpram_addr;
					emif_dpram_wen   <= 1'b0;
					emif_dpram_ren   <= 1'b0;
				end
			end
			//Write Operation:42ns
			else if(fsm_curr_st==FSM_SS_HOLD_STATE)//SS Hold state:get write the dpram data
			begin
				if(emif_wen_d3==1'b1 && emif_wen_d4==1'b0)
				begin
					emif_dpram_wdata <= emif_data_d3;
					emif_dpram_addr  <= emif_addr_d3;
					emif_dpram_wen   <= 1'b1;
					emif_dpram_ren   <= 1'b0;
				end
				else
				begin
					emif_dpram_wdata <= emif_dpram_wdata;
					emif_dpram_addr  <= emif_dpram_addr;
					emif_dpram_wen   <= 1'b0;
					emif_dpram_ren   <= 1'b0;
				end
			end
			else
			begin
				emif_dpram_wdata <= 16'b0;
				emif_dpram_addr  <= 23'b0;
				emif_dpram_wen   <= 1'b0;
				emif_dpram_ren   <= 1'b0;
			end
		end
	end
	//get the read back response data: emif_dpram_rdata
	reg   emif_dpram_ren_d0,emif_dpram_ren_d1 ;
	reg   [15:00]     resp_data;
	reg   [00:00]     resp_rvld;
	always @(posedge clk_ref or negedge rst_n)
	begin
		if(rst_n==1'b0)
		begin
			emif_dpram_ren_d0  <= 1'b0;
			emif_dpram_ren_d1  <= 1'b0;
			resp_data   <= 16'b0;
			resp_rvld   <= 1'b0;
		end
		else
		begin
			emif_dpram_ren_d0 <= emif_dpram_ren;
			emif_dpram_ren_d1 <= emif_dpram_ren_d0;
			if(fsm_curr_st==FSM_SS_STROB_STATE)//at the Strobe state,get the response data
			begin
				if(emif_dpram_ren_d1==1'b1)//dpram_rdata is one period later than dpram_ren
				begin
					resp_data <= emif_dpram_rdata ;//latch the response data from the spi_dpram
					resp_rvld <= 1'b1 ;
				end
				else
				begin
					resp_data <= resp_data ;
					resp_rvld <= resp_rvld;
				end
			end
			else if(fsm_curr_st==FSM_SS_HOLD_STATE)//during the hold state,keep the response data on the emif data bus
			begin
				resp_data <= resp_data ;
				resp_rvld <= resp_rvld;
			end
			else
			begin
				resp_data <= 16'b0;
				resp_rvld <= 1'b0;
			end
		end
	end
	//insert the emif  wait state to the read operation
	assign          emif_wait_o = 2'b00 ;
	//when emif start read operation,put the read back response data on the emif data bus
	assign          emif_data_z = (resp_rvld==1'b1)? resp_data : 16'hzzzz ;
	//set dpram enable signa:no matter which operation it happens,enable the emif dpram
	assign          emif_dpram_ren_2 = emif_dpram_ren | emif_dpram_ren_d0; // make emif_dpram_ren_2 2 clock width  

endmodule
