`timescale 1ns/1ps
`define DEBUG

module connect_domain_get(
        input                        clk          ,
        input                        rst_n        ,
        input                        fs           ,
        input                        hs           ,
        input      [DATA_WIDH-1:00]  data         ,
        input      [10:0]            hang_cnt_out ,
        input      [10:0]            lie_cnt_out  ,

        output reg [9:0]             e_label      ,
        output reg [8:0]             e_le         ,
        output reg [8:0]             e_ri         ,
        output reg [8:0]             e_upm        ,
        output reg [8:0]             e_dw         ,
        output reg [31:0]            e_sum_gray   ,
        output reg [19:0]            e_num_gray
);

    parameter   HANG_NUM      = 32;
    parameter   LIE_NUM       = 32;
    parameter   LIE_UNVALID   = 5;
    parameter   DATA_WIDH     = 8;
    parameter   THRES         = 135;

    reg [10:0] hang_cnt,lie_cnt; reg valid; integer i;
    wire data_valid = (hang_cnt_out > 1) & (hang_cnt_out < HANG_NUM) & (lie_cnt_out > 1) & (lie_cnt_out < LIE_NUM);

    always @(posedge clk or negedge rst_n)
    begin
        hang_cnt <= hang_cnt_out;
        lie_cnt  <= lie_cnt_out;
        valid <= data_valid;
    end

    wire [DATA_WIDH-1:00] middle    ;
    wire [DATA_WIDH-1:00] left      ;
    wire [DATA_WIDH-1:00] up_right1 ;
    wire [DATA_WIDH-1:00] up_middle1;
    wire [DATA_WIDH-1:00] up_left1  ; wire fs_neg,hs_neg;

    get_around u_get_around(
        .clk         ( clk          ),
        .rst_n       ( rst_n        ),
        .fs          ( fs           ),
        .hs          ( hs           ),
        .data        ( data         ),

        .middle      ( middle       ),
        .left        ( left         ),
        .up_right1   ( up_right1    ),
        .up_middle1  ( up_middle1   ),
        .up_left1    ( up_left1     ),
        .fs_neg      ( fs_neg       ),
        .hs_neg      ( hs_neg       )
    );

    reg [9:0]  max_label; reg start;
    reg [9:0]  label[1023:0];
    reg [8:0]  le [1023:0];
    reg [8:0]  ri [1023:0];
    reg [8:0]  upm[1023:0];
    reg [8:0]  dw [1023:0];
    reg [31:0] sum_gray[1023:0];
    reg [19:0] num_gray[1023:0];
    reg [9:0]  pixel_last_label[1023:0];
    reg [9:0]  pixel_last_temp [1023:0];
    reg [9:0]  pixel_left_label;

    always @(posedge clk or negedge rst_n)
    begin
        if(rst_n==1'b0)
            start <= 0;
        else if(valid ==1)
        begin
            if(middle >= THRES)
                start <= 1;
            else
                start <= start;
        end
        else if(fs_neg==1)
            start <= 0;
        else
            start <= start;
    end

    always @(posedge clk or negedge rst_n)
    begin
        if(rst_n==0)
        begin
            max_label <= 0;
            pixel_left_label <= 0;
            for(i=0;i<1024;i=i+1)
            begin
                label[i]    = 0;
                le[i]       = 0;
                ri[i]       = 0;
                upm[i]      = 0;
                dw[i]       = 0;
                sum_gray[i] = 0;
                num_gray[i] = 0;
                pixel_last_label[i]=0;
                pixel_last_temp[i]=0;
            end
        end
        else if(valid==1)
        begin
            if(start==0)
            begin
                if(middle >= THRES)
                begin
                    max_label <= 1;
                    label [max_label+1]  <= 1 ;

                    le  [max_label+1]  <= lie_cnt   ;
                    ri  [max_label+1]  <= lie_cnt   ;
                    upm [max_label+1]  <= hang_cnt   ;
                    dw  [max_label+1]  <= hang_cnt   ;

                    sum_gray [max_label+1]  <= middle   ;
                    num_gray [max_label+1]  <= 1   ;

                    pixel_left_label <= 1;
                    pixel_last_temp[lie_cnt] <= 1;
                end
            end
            else
            begin
                if(middle >= THRES)
                begin
                    if( (pixel_left_label!=pixel_last_label[lie_cnt+1]) &&(pixel_left_label!=0) && (pixel_last_label[lie_cnt+1]!=0) )
                    begin
                        le[combine1_l] <= (le[combine1_l] < le[combine1_b])?le[combine1_l]:le[combine1_b];
                        ri[combine1_l] <= (ri[combine1_l] > ri[combine1_b])?ri[combine1_l]:ri[combine1_b];
                        upm[combine1_l] <= (upm[combine1_l] < upm[combine1_b])?upm[combine1_l]:upm[combine1_b];
                        dw[combine1_l] <= hang_cnt;

                        sum_gray[combine1_l] <= sum_gray[combine1_l] + sum_gray[combine1_b] + middle;
                        num_gray[combine1_l] <= num_gray[combine1_l] + num_gray[combine1_b] + 1;
                        num_gray[combine1_b] <= 0;

                        for(i=0;i<LIE_NUM;i=i+1)
                        begin
                            if (pixel_last_label[i]==combine1_b)
                                pixel_last_label[i] <= combine1_l;
                            if (pixel_last_temp[i]==combine1_b)
                                pixel_last_temp[i] <= combine1_l;
                        end

                        pixel_left_label <= combine1_l;
                        pixel_last_temp[lie_cnt] <= combine1_l;
                    end
                    else if((pixel_last_label[lie_cnt-1]!=pixel_last_label[lie_cnt+1]) &&(pixel_last_label[lie_cnt-1]!=0) && (pixel_last_label[lie_cnt+1]!=0))
                    begin
                        le[combine2_l] <= (le[combine2_l] < le[combine2_b])?le[combine2_l]:le[combine2_b];
                        ri[combine2_l] <= (ri[combine2_l] > ri[combine2_b])?ri[combine2_l]:ri[combine2_b];
                        upm[combine2_l] <= (upm[combine2_l] < upm[combine2_b])?upm[combine2_l]:upm[combine2_b];
                        dw[combine2_l] <= hang_cnt;

                        sum_gray[combine2_l] <= sum_gray[combine2_l] + sum_gray[combine2_b] + middle;
                        num_gray[combine2_l] <= num_gray[combine2_l] + num_gray[combine2_b] + 1;
                        num_gray[combine2_b] <= 0;

                        for(i=0;i<LIE_NUM;i=i+1)
                        begin
                            if (pixel_last_label[i]==combine2_b)
                                pixel_last_label[i] <= combine2_l;
                            if (pixel_last_temp[i]==combine2_b)
                                pixel_last_temp[i] <= combine2_l;
                        end

                        pixel_left_label <= combine2_l;
                        pixel_last_temp[lie_cnt] <= combine2_l;
                    end


                    else if(pixel_left_label==0)
                    begin
                        if(pixel_last_label[lie_cnt-1]==0)
                        begin
                            if(pixel_last_label[lie_cnt]==0)
                            begin
                                if(pixel_last_label[lie_cnt+1]==0)
                                begin
                                    if(max_label < 1023)
                                        max_label <= max_label + 1;
                                    else
                                        max_label <= max_label;

                                    label [max_label+1]  <= max_label+1 ;

                                    le  [max_label+1]  <= lie_cnt   ;
                                    ri [max_label+1]  <= lie_cnt   ;
                                    upm    [max_label+1]  <= hang_cnt   ;
                                    dw  [max_label+1]  <= hang_cnt   ;

                                    sum_gray     [max_label+1]  <= middle   ;
                                    num_gray     [max_label+1]  <= 1   ;

                                    pixel_left_label <= max_label+1;
                                    pixel_last_temp[lie_cnt] <= max_label+1;
                                end
                                else
                                begin
                                    dw[pixel_last_label[lie_cnt+1]]  <= hang_cnt   ;
                                    le[pixel_last_label[lie_cnt+1]]  <= (lie_cnt < le[pixel_last_label[lie_cnt+1]])?lie_cnt:le[pixel_last_label[lie_cnt+1]];
                                    sum_gray[pixel_last_label[lie_cnt+1]]  <= sum_gray[pixel_last_label[lie_cnt+1]] + middle;
                                    num_gray[pixel_last_label[lie_cnt+1]]  <= num_gray[pixel_last_label[lie_cnt+1]] + 1;

                                    pixel_left_label <= pixel_last_label[lie_cnt+1];
                                    pixel_last_temp[lie_cnt] <= pixel_last_label[lie_cnt+1];
                                end
                            end
                            else
                            begin
                                dw[pixel_last_label[lie_cnt]]  <= hang_cnt   ;
                                sum_gray[pixel_last_label[lie_cnt]]  <= sum_gray[pixel_last_label[lie_cnt]] + middle;
                                num_gray[pixel_last_label[lie_cnt]]  <= num_gray[pixel_last_label[lie_cnt]] + 1;

                                pixel_left_label <= pixel_last_label[lie_cnt];
                                pixel_last_temp[lie_cnt] <= pixel_last_label[lie_cnt];
                            end
                        end
                        else
                        begin
                            dw[pixel_last_label[lie_cnt-1]]  <= hang_cnt   ;
                            ri[pixel_last_label[lie_cnt-1]]  <= (lie_cnt>ri[pixel_last_label[lie_cnt-1]])?lie_cnt:ri[pixel_last_label[lie_cnt-1]];
                            sum_gray[pixel_last_label[lie_cnt-1]]  <= sum_gray[pixel_last_label[lie_cnt-1]] + middle;
                            num_gray[pixel_last_label[lie_cnt-1]]  <= num_gray[pixel_last_label[lie_cnt-1]] + 1;

                            pixel_left_label <= pixel_last_label[lie_cnt-1];
                            pixel_last_temp[lie_cnt] <= pixel_last_label[lie_cnt-1];
                        end
                    end
                    else
                    begin
                        ri[pixel_left_label]  <= (lie_cnt>ri[pixel_left_label])?lie_cnt:ri[pixel_left_label];
                        sum_gray[pixel_left_label]  <= sum_gray[pixel_left_label] + middle;
                        num_gray[pixel_left_label]  <= num_gray[pixel_left_label] + 1;

                        pixel_left_label <= pixel_left_label;
                        pixel_last_temp[lie_cnt] <= pixel_left_label;
                    end
                end
                else
                begin
                    pixel_left_label <= 0;
                    pixel_last_temp[lie_cnt] <= 0;
                end
            end
        end
        else if(fs_neg==1)
        begin
            max_label <= 0;
        end
        else if(export_valid==1)
        begin
             label[cnt_write]     <= 0 ;
             le[cnt_write]        <= 0 ;
             ri[cnt_write]        <= 0 ;
             upm[cnt_write]       <= 0 ;
             dw[cnt_write]        <= 0 ;
             sum_gray[cnt_write]  <= 0 ;
             num_gray[cnt_write]  <= 0 ;
        end
        else
        begin
            max_label <= max_label;
        end
    end

    wire [9:0] combine1_l = (pixel_left_label < pixel_last_label[lie_cnt+1]) ? pixel_left_label : pixel_last_label[lie_cnt+1];
    wire [9:0] combine1_b = (pixel_left_label > pixel_last_label[lie_cnt+1]) ? pixel_left_label : pixel_last_label[lie_cnt+1];

    wire [9:0] combine2_l = (pixel_last_label[lie_cnt-1] < pixel_last_label[lie_cnt+1]) ? pixel_last_label[lie_cnt-1] : pixel_last_label[lie_cnt+1];
    wire [9:0] combine2_b = (pixel_last_label[lie_cnt-1] > pixel_last_label[lie_cnt+1]) ? pixel_last_label[lie_cnt-1] : pixel_last_label[lie_cnt+1];

    always @(posedge clk or negedge rst_n)
    begin
        if(rst_n==1'b0)
        begin
            for(i=0;i<LIE_NUM;i=i+1)
            begin
                pixel_last_label[i] <= 0;
            end
        end
        else if(hs_neg==1)
        begin
            for(i=0;i<LIE_NUM;i=i+1)
            begin
                pixel_last_label[i] <= pixel_last_temp[i];
            end
        end
    end

    reg [9:0] cnt_write;

    always @(posedge clk or negedge rst_n)
    begin
        if(rst_n==1'b0)
            cnt_write <= 0;
        else if(fs_neg==1)
            cnt_write <= 1;
        else if(cnt_write >= 1)
            cnt_write <= cnt_write + 1;
        else
            cnt_write <= cnt_write ;
    end

    wire export_valid = (cnt_write>=1) && (cnt_write<=1023);

    always @(posedge clk or negedge rst_n)
    begin
        if(rst_n==1'b0)
        begin
            e_label       <=   0;
            e_le          <=   0;
            e_ri          <=   0;
            e_upm         <=   0;
            e_dw          <=   0;
            e_sum_gray    <=   0;
            e_num_gray    <=   0;
        end
        else if(export_valid==1)
        begin
            e_label       <= label[cnt_write];
            e_le          <= le[cnt_write];
            e_ri          <= ri[cnt_write];
            e_upm         <= upm[cnt_write];
            e_dw          <= dw[cnt_write];
            e_sum_gray    <= sum_gray[cnt_write];
            e_num_gray    <= num_gray[cnt_write];
        end
        else
        begin
            e_label       <=   0;
            e_le          <=   0;
            e_ri          <=   0;
            e_upm         <=   0;
            e_dw          <=   0;
            e_sum_gray    <=   0;
            e_num_gray    <=   0;
        end
    end

    `ifdef DEBUG
        wire [8:0]  le1        =   le [1];
        wire [8:0]  ri1        =   ri [1];
        wire [8:0]  upm1       =   upm[1];
        wire [8:0]  dw1        =   dw [1];
        wire [31:0] sum_gray1  =   sum_gray[1];
        wire [19:0] num_gray1  =   num_gray[1];
        wire [9:0]  label1     =   label[1];

        wire [8:1]  le2        =   le [2];
        wire [8:1]  ri2        =   ri [2];
        wire [8:1]  upm2       =   upm[2];
        wire [8:1]  dw2        =   dw [2];
        wire [31:1] sum_gray2  =   sum_gray[2];
        wire [19:1] num_gray2  =   num_gray[2];
        wire [9:0]  label2     =   label[2];

        wire [8:1]  le3        =   le [3];
        wire [8:1]  ri3        =   ri [3];
        wire [8:1]  upm3       =   upm[3];
        wire [8:1]  dw3        =   dw [3];
        wire [31:1] sum_gray3  =   sum_gray[3];
        wire [19:1] num_gray3  =   num_gray[3];
        wire [9:0]  label3     =   label[3];

        wire [8:0]  le4        =   le [4];
        wire [8:0]  ri4        =   ri [4];
        wire [8:0]  upm4       =   upm[4];
        wire [8:0]  dw4        =   dw [4];
        wire [31:0] sum_gray4  =   sum_gray[4];
        wire [19:0] num_gray4  =   num_gray[4];
        wire [9:0]  label4     =   label[4];

        wire [8:0]  le5        =   le [5];
        wire [8:0]  ri5        =   ri [5];
        wire [8:0]  upm5       =   upm[5];
        wire [8:0]  dw5        =   dw [5];
        wire [31:0] sum_gray5  =   sum_gray[5];
        wire [19:0] num_gray5  =   num_gray[5];
        wire [9:0]  label5     =   label[5];

        wire [9:0]  temp1 = pixel_last_label[lie_cnt+1];
        wire [9:0]  temp2 = pixel_last_label[lie_cnt-1];
    `endif


endmodule


module get_around(
                    input                    clk          ,
                    input                    rst_n        ,
                    input                    fs           ,
                    input                    hs           ,
                    input  [DATA_WIDH-1:00]  data         ,


                    output [DATA_WIDH-1:00]  middle       ,
                    output [DATA_WIDH-1:00]  left         ,
                    output [DATA_WIDH-1:00]  up_right1    ,
                    output [DATA_WIDH-1:00]  up_middle1   ,
                    output [DATA_WIDH-1:00]  up_left1     ,
                    output                   fs_neg       ,
                    output                   hs_neg
    );

    parameter   HANG_NUM      = 32;
    parameter   LIE_NUM       = 32;
    parameter   LIE_UNVALID   = 5;
    parameter   DATA_WIDH     = 8;
    parameter   THRES         = 135;

    reg [4:0] address_w;
    always @(posedge clk or negedge rst_n)
    begin
        if(rst_n==1'b0)
            address_w <= 0;
        else if(address_w < (LIE_NUM-1) )
        begin
            if((fs==1) && (hs==1))
                address_w <= address_w + 1;
            else
                address_w <= address_w;
        end
        else
            address_w <= 0;
    end

    wire wren =fs && hs;

    reg fs_delay[0:(LIE_NUM+LIE_UNVALID-3)];
    reg hs_delay[0:(LIE_NUM+LIE_UNVALID-3)];

    integer i;

    always @(posedge clk)
    begin
        fs_delay[0] <= fs;
        hs_delay[0] <= hs;
        for(i=0;i<(LIE_NUM+LIE_UNVALID-3);i=i+1)
        begin
            fs_delay[i+1] <= fs_delay[i];
            hs_delay[i+1] <= hs_delay[i];
        end
    end

    wire fs_delay_1hang = fs_delay[LIE_NUM+LIE_UNVALID-3];
    wire hs_delay_1hang = hs_delay[LIE_NUM+LIE_UNVALID-3];

    reg [4:0] address_r;

    always @(posedge clk or negedge rst_n)
    begin
        if(rst_n==1'b0)
            address_r <= 0;
        else if(address_r < (LIE_NUM-1) )
        begin
            if((fs_delay_1hang==1) && (hs_delay_1hang==1))
                address_r <= address_r + 1;
            else
                address_r <= address_r;
        end
        else
            address_r <= 0;
    end

    wire rden0 =fs_delay_1hang && hs_delay_1hang;
    reg rden1,rden2;

    always @(posedge clk or negedge rst_n)
    begin
        rden1 <= rden0;
        rden2 <= rden1;
    end

    wire rden = rden0 | rden1;
    wire [DATA_WIDH-1:00] data_delay_1hang;

    delay_1hang u_delay_1hang (
      .clka  ( clk                ),
      .ena   ( wren               ),
      .wea   ( 1'b1               ),
      .addra ( address_w          ),
      .dina  ( data               ),

      .clkb  ( clk                ),
      .enb   ( rden               ),
      .addrb (address_r           ),
      .doutb ( data_delay_1hang   )
    );

    wire [DATA_WIDH-1:00] up_middle1_temp = (rden2==1)?data_delay_1hang:0;

    wire [DATA_WIDH-1:00] middle_temp = data;


    reg [DATA_WIDH-1:00] left_temp,left_temp1,up_left1_temp,up_left1_temp1;
    always @(posedge clk or negedge rst_n)
    begin
        left_temp  <= middle_temp;
        left_temp1 <= left_temp;
        up_left1_temp <= up_middle1_temp;
        up_left1_temp1<= up_left1_temp;
    end

    assign middle =left_temp;
    assign left   = left_temp1;
    assign up_right1 =up_middle1_temp;
    assign up_middle1 =up_left1_temp;
    assign up_left1 =up_left1_temp1;

    assign hs_neg = (hs_delay[0] & ~hs);
    assign fs_neg = (fs_delay[0] & ~fs);

endmodule
