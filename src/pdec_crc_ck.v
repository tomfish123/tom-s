//////////////////////////////////////////////////////////////////////////////////
// Description: early termination 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps

module pdec_crc_ck #(
  parameter                         WID_K         = 8  ,
  parameter                         WID_DEC       = 3  , //WID_K-5
  parameter                         NUM_K         = 164,
  parameter                         WID_PM        = 10
)(
  input   wire                      clk                , 
  input   wire                      rst_n              , 
  
  //----ICG
  output wire                       pdec_clk_en7        ,
  
  //----pdec_para_cfg interface
  input  wire[WID_K-1:0]            param_a            ,
  input  wire[WID_K-1:0]            param_k            ,
  input  wire                       crc_flag           ,//0:inital value is all 0 ,1:intial value is all 1
  input  wire[16*4-1:0]             rnti_val           ,//max is 4 RNTI
  input  wire[2-1:0]                rnti_num           ,//0:detect 1 rnti,1:detect 2 rnti,2:detect 3 rnti,3:detect 4 rnti
  input  wire[WID_K*NUM_K-1:0]      il_pattern         ,//interleave addrress
  output reg [32-1:0]               ck2cfg_head_data   ,//report rnti index
  
  //----broadcast control signals
  input  wire                       pdec_st            ,
  input  wire[4-1:0]                path_num           ,//value is 1 2 4 8
  input  wire[2*8-1:0]              path_valid         ,
  
  //----pdec_top_ctrl interface
  input  wire                       ctrl2ck_tb_st      ,//trace back start
  input  wire[8-1:0]                ctrl2ck_tb_ind     ,//trace back indication signal
  output reg                        ck2ctrl_ck_done    ,//crc check done

  //----pdec_pm_sort interface
  input  wire[WID_PM*8-1:0]         srt2ck_pm_val      ,//pm value of 8 pathes
  
  //----pdec_updt_path interface
  input  wire                       uph2ck_early_term  ,//pm value of 8 pathes

  //----pdec_sram_top interface
  output wire[8-1:0]                ck2sram_list_ren   ,
  output wire[WID_K-1:0]            ck2sram_list_raddr ,
  input  wire[4*8-1:0]              sram2ck_list_rdata ,
  
  output reg                        ck2sram_dec_wen    ,
  output reg [3:0]                  ck2sram_dec_wbyte  , 
  output reg [WID_DEC-1:0]          ck2sram_dec_waddr  ,
  output reg [31:0]                 ck2sram_dec_wdata   
);

//====================================================
//====          parameters
//====================================================
localparam WID_DEC16 = WID_DEC + 1'b1;

//====================================================
//====          innner signals
//====================================================
genvar              ii                        ; 
genvar              jj                        ; 
genvar              pp                        ;
wire                tb_start                  ;
wire[WID_K-1:0]     param_a_sub1              ; 
wire[WID_K-1:0]     param_k_sub1              ; 
//----read list sram
wire[WID_K-1:0]     il_pattern_mem[NUM_K-1:0] ; 
reg                 list_ren                  ; 
reg                 list_ren_r                ; 
reg                 list_ren_rr               ; 
reg [WID_K-1:0]     list_raddr                ; 
reg [WID_K-1:0]     list_raddr_r              ; 
reg [WID_K-1:0]     list_raddr_rr             ; 
reg [7:0]           path_bitmap               ;
reg [WID_K-1:0]     itlv_addr                 ; 
//----trace back
wire[7:0]           valid_path_ind            ;
//wire[3:0]           valid_path_num            ;
wire[7:0]           tb_en                     ; 
wire[7:0]           hat_list                  ; 
wire[2:0]           pp_list[7:0]              ; 
reg [2:0]           pp_idx_r[7:0]             ; 
reg [2:0]           pp_idx[7:0]               ; 
reg [NUM_K-1:0]     dec_bit[7:0]              ; 
//----crc check proc
wire                ck_st_1st                 ;
wire                ck_st_valid               ;
wire                ck_st_invalid             ;
reg                 ck_st_invalid_r           ;
reg [2:0]           crc_ck_cnt_r              ;
reg                 dat_in_en                 ; 
reg [WID_DEC16-1:0] dat_in_cnt                ; 
reg [15:0]          dat_in                    ; 
wire                crc_in_en_head            ; 
wire                crc_in_en_inn             ; 
wire                crc_in_en_tail            ; 
wire                crc_in_en                 ; 
wire[4:0]           crc_out_idx               ; 
wire[15:0]          crc_dat_in                ; 
reg [23:0]          crc_in                    ; 
wire[23:0]          crc_in_24c[16:0]          ; 
//----rnti check proc
wire                dat_in_en_last3           ; 
wire                dat_in_en_last2           ; 
wire                dat_in_en_last1           ; 
reg [15:0]          dat_in_reg1               ; 
reg [6:0]           dat_in_reg0               ; 
wire[38:0]          dat_in_end                ; 
reg                 crc_ck_en                 ; 
reg [23:0]          crc_mask_in               ; 
wire[23:0]          crc_xor_rnti0             ; 
wire[23:0]          crc_xor_rnti1             ; 
wire[23:0]          crc_xor_rnti2             ; 
wire[23:0]          crc_xor_rnti3             ; 
reg                 crc_ck_rslt               ; 
//reg [15:0]          rnti_val_rslt             ; 
reg [1:0]           rnti_idx_rslt             ; 
reg [WID_PM-1:0]    pm_rslt                   ;
reg                 crc_ck_en_r               ; 
reg [2:0]           crc_ck_cnt                ; 
wire                ck_st_inn                 ; 
reg                 ck_proc                   ;
//====================================================
//====          top control
//====================================================
assign tb_start     = ctrl2ck_tb_st & (~uph2ck_early_term);
assign param_a_sub1 = param_a - 1'b1; 
assign param_k_sub1 = param_k - 1'b1; 

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    list_ren <= 1'b0;
  else if(tb_start)
    list_ren <= 1'b1;
  else if(list_ren && (list_raddr == {WID_K{1'b0}}))
    list_ren <= 1'b0;
end

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    list_raddr <= {WID_K{1'b0}};
  else if(tb_start)
    list_raddr <= param_k_sub1;
  else if(list_ren)
    list_raddr <= list_raddr - 1'b1;
end    

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin
    list_ren_r  <= 1'b0;
    list_ren_rr <= 1'b0;
  end  
  else begin
    list_ren_r  <= list_ren;
    list_ren_rr <= list_ren_r      ; //align with list_rdata
  end  
end

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    list_raddr_r <= {WID_K{1'b0}};
  else if(list_ren)  
    list_raddr_r <= list_raddr;
end    

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    list_raddr_rr <= {WID_K{1'b0}};
  else if(list_ren_r)  
    list_raddr_rr <= list_raddr_r;
end    

always @(*)begin
  if(path_num == 4'd1)
    path_bitmap = 8'h01;    
  else if(path_num == 4'd2)
    path_bitmap = 8'h03;    
  else if(path_num == 4'd4)
    path_bitmap = 8'h0F;    
  else if(path_num == 4'd8)
    path_bitmap = 8'hFF;
  else
    path_bitmap = 8'h00;
end
assign ck2sram_list_ren   = path_bitmap & {8{list_ren}};
assign ck2sram_list_raddr = list_raddr;

generate
  for(jj=0 ; jj<NUM_K ; jj=jj+1)begin  : il_pattern_arr
    assign il_pattern_mem[jj] = il_pattern[(jj+1)*WID_K-1:jj*WID_K] ;
  end
endgenerate

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    itlv_addr <= {WID_K{1'b0}};
  else if(list_ren_r)
    itlv_addr <= il_pattern_mem[list_raddr_r] ; //align with list_ren_rr
end

//====================================================
//====          trace back
//====================================================
assign valid_path_ind = ctrl2ck_tb_ind[7 :0] ; 
//assign valid_path_num = ctrl2ck_tb_ind[11:8] ; 

assign tb_en      = {8{list_ren_rr}} & valid_path_ind;

generate
  for(ii=0 ; ii<8 ; ii=ii+1)begin  : trace_back
    assign hat_list[ii] = sram2ck_list_rdata[4*ii+3];
    assign pp_list[ii]  = sram2ck_list_rdata[(ii+1)*4-2:ii*4];

    always @(*)begin
      if(tb_en[ii] && (list_raddr_rr == param_k_sub1))
        //pp_idx[ii] <= pp_list[ii];
        pp_idx[ii] <= ii[2:0];
      else if(tb_en[ii])
        pp_idx[ii] <= pp_idx_r[ii];
      else
        pp_idx[ii] <= 3'd0;
    end

    always @(posedge clk or negedge rst_n)begin
      if(!rst_n)
        pp_idx_r[ii] <= 3'd0;
      else if(tb_en[ii])
        pp_idx_r[ii] <= pp_list[pp_idx[ii]];
    end

    always @(posedge clk or negedge rst_n)begin
      if(!rst_n)
        dec_bit[ii] <= {NUM_K{1'b0}};
      else if(pdec_st)
        dec_bit[ii] <= {NUM_K{1'b0}};
      else if(tb_en[ii])
        dec_bit[ii][itlv_addr] <= hat_list[pp_idx[ii]];
    end    
  end
endgenerate
//=============================================
//====      calculate crc result 
//==== CRC24B(E88D4D) = D^24 + D^23 + D^21 + D^20 + D^17 + D^15 + D^13 + D^12 + D^8 + D^4 + D^2 + D^1 + 1
//=============================================
assign ck_st_1st     = (~list_ren_r) & list_ren_rr;
assign ck_st_valid   = (ck_st_1st || ck_st_inn) && (path_valid[crc_ck_cnt*2 +: 2] == 2'd1);
assign ck_st_invalid = (ck_st_1st || ck_st_inn) && (path_valid[crc_ck_cnt*2 +: 2] != 2'd1);

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    dat_in_en <= 1'b0;
  else if(ck_st_valid)
    dat_in_en <= 1'b1;
  else if(dat_in_en && dat_in_cnt == param_k_sub1[WID_K-1:4])
    dat_in_en <= 1'b0;
end

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    dat_in_cnt <= {WID_DEC16{1'b0}};
  else if(ck_st_valid && crc_flag == 1'b1) //for cchdec mode 
    dat_in_cnt <= {{WID_DEC16-1{1'b1}},1'b0}; //MAX-2 and MAX-1
  else if(ck_st_valid)
    dat_in_cnt <= {WID_DEC16{1'b0}}; //0
  else if(dat_in_en)  
    dat_in_cnt <= dat_in_cnt + 1'b1; 
end

assign crc_in_en_head = dat_in_en  & (dat_in_cnt >= {{WID_DEC16-1{1'b1}},1'b0}) & (crc_flag == 1'b1); //add 24 bit 1s for head
assign crc_in_en_inn  = dat_in_en  & (dat_in_cnt < param_a_sub1[WID_K-1:4]);
assign crc_in_en_tail = dat_in_en  & (dat_in_cnt == param_a_sub1[WID_K-1:4]);
assign crc_in_en = crc_in_en_head | crc_in_en_inn | crc_in_en_tail ; 

always @(*)begin
  if(crc_in_en_head)
    dat_in = 16'hffff;
  else if(dat_in_en)begin
    case(crc_ck_cnt_r)
      3'd0 : dat_in = dec_bit[0][dat_in_cnt*16 +: 16];
      3'd1 : dat_in = dec_bit[1][dat_in_cnt*16 +: 16];
      3'd2 : dat_in = dec_bit[2][dat_in_cnt*16 +: 16];
      3'd3 : dat_in = dec_bit[3][dat_in_cnt*16 +: 16];
      3'd4 : dat_in = dec_bit[4][dat_in_cnt*16 +: 16];
      3'd5 : dat_in = dec_bit[5][dat_in_cnt*16 +: 16];
      3'd6 : dat_in = dec_bit[6][dat_in_cnt*16 +: 16];
      3'd7 : dat_in = dec_bit[7][dat_in_cnt*16 +: 16];
    default: dat_in = dec_bit[0][dat_in_cnt*16 +: 16];
    endcase
  end
  else
    dat_in = 16'd0;
end

assign crc_dat_in = crc_in_en ? dat_in : 16'd0;


assign crc_out_idx = crc_in_en_tail ? param_a_sub1[3:0] + 1'b1 : 5'd0;

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    crc_in <= 24'd0;
  //----initial  
  else if (ck_st_1st || ck_st_inn)  
    crc_in <= 24'd0;
  //----head
  else if(crc_in_en_head && (dat_in_cnt == {{WID_DEC16-1{1'b1}},1'b0})) //MAX-2
    crc_in <= crc_in_24c[16];
  else if(crc_in_en_head && (dat_in_cnt == {WID_DEC16{1'b1}})) //MAX -1
    crc_in <= crc_in_24c[8];
  //----middle
  else if(crc_in_en_inn)
    crc_in <= crc_in_24c[16];
  //----last
  else if(crc_in_en_tail)
    crc_in <= crc_in_24c[crc_out_idx];
end

assign crc_in_24c[0] = crc_in;

generate
  for(pp=0 ; pp<16 ; pp=pp+1)begin  : crc_cal_16bit
    pdec_crc_24c
    U_pdec_crc_24c(
      .dat_in   (crc_dat_in[pp]     ) ,
      .crc_in   (crc_in_24c[pp]     ) ,
      .crc_out  (crc_in_24c[pp+1]   ) );
  end
endgenerate 

//=============================================
//====      mask rx crc bit
//====judge if masked rx crc euqal to calculated crc
//=============================================
assign dat_in_en_last3 = dat_in_en  && (dat_in_cnt == param_k_sub1[WID_K-1:4] - 2'd2);
assign dat_in_en_last2 = dat_in_en  && (dat_in_cnt == param_k_sub1[WID_K-1:4] - 1'b1);
assign dat_in_en_last1 = dat_in_en  && (dat_in_cnt == param_k_sub1[WID_K-1:4]       );

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    dat_in_reg0 <= 7'd0;
  else if(dat_in_en_last3)
    dat_in_reg0 <= dat_in[15:9]; 
end    

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    dat_in_reg1 <= 16'd0;
  else if(dat_in_en_last2)
    dat_in_reg1 <= dat_in;
end    

assign dat_in_end = dat_in_en_last1 ? {dat_in,dat_in_reg1,dat_in_reg0} : 39'd0; //16 + 16 + 7

//----extract rx crc bit
always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    crc_mask_in <= 24'd0;
  else if(dat_in_en_last1)begin
    case(param_k_sub1[3:0])
      4'd0  : crc_mask_in <= dat_in_end[23:0 ];
      4'd1  : crc_mask_in <= dat_in_end[24:1 ];
      4'd2  : crc_mask_in <= dat_in_end[25:2 ];
      4'd3  : crc_mask_in <= dat_in_end[26:3 ];
      4'd4  : crc_mask_in <= dat_in_end[27:4 ];
      4'd5  : crc_mask_in <= dat_in_end[28:5 ];
      4'd6  : crc_mask_in <= dat_in_end[29:6 ];
      4'd7  : crc_mask_in <= dat_in_end[30:7 ];
      4'd8  : crc_mask_in <= dat_in_end[31:8 ];
      4'd9  : crc_mask_in <= dat_in_end[32:9 ];
      4'd10 : crc_mask_in <= dat_in_end[33:10];
      4'd11 : crc_mask_in <= dat_in_end[34:11];
      4'd12 : crc_mask_in <= dat_in_end[35:12];
      4'd13 : crc_mask_in <= dat_in_end[36:13];
      4'd14 : crc_mask_in <= dat_in_end[37:14];
      4'd15 : crc_mask_in <= dat_in_end[38:15];
    default : crc_mask_in <= dat_in_end[38:15];
    endcase
  end
end    

//----crc check
always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    crc_ck_en <= 1'b0;
  else 
    crc_ck_en <= dat_in_en_last1;
end

assign crc_xor_rnti0 = crc_ck_en ? {(crc_in[23:8]^rnti_val[15: 0]),crc_in[7:0]} : 24'd0;
assign crc_xor_rnti1 = crc_ck_en ? {(crc_in[23:8]^rnti_val[31:16]),crc_in[7:0]} : 24'd0;
assign crc_xor_rnti2 = crc_ck_en ? {(crc_in[23:8]^rnti_val[47:32]),crc_in[7:0]} : 24'd0;
assign crc_xor_rnti3 = crc_ck_en ? {(crc_in[23:8]^rnti_val[63:48]),crc_in[7:0]} : 24'd0;

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin
    crc_ck_rslt   <= 1'b0;
    //rnti_val_rslt <= 16'd0;
    rnti_idx_rslt <= 2'd0;
  end
  else if(ck_st_1st)begin // clear to zeros
    crc_ck_rslt   <= 1'b0;
    //rnti_val_rslt <= 16'd0;
    rnti_idx_rslt <= 2'd0;
  end  
  else if(crc_ck_en)begin
    if((crc_mask_in == crc_xor_rnti0) && (rnti_num >= 2'd0))begin
      crc_ck_rslt   <= 1'b1;
      //rnti_val_rslt <= rnti_val[15: 0];
      rnti_idx_rslt <= 2'd0;
    end  
    else if((crc_mask_in == crc_xor_rnti1) && (rnti_num >= 2'd1))begin  
      crc_ck_rslt   <= 1'b1;
      //rnti_val_rslt <= rnti_val[31:16];
      rnti_idx_rslt <= 2'd1;
    end  
    else if((crc_mask_in == crc_xor_rnti2) && (rnti_num >= 2'd2))begin  
      crc_ck_rslt   <= 1'b1;
      //rnti_val_rslt <= rnti_val[47:32];
      rnti_idx_rslt <= 2'd2;
    end  
    else if((crc_mask_in == crc_xor_rnti3) && (rnti_num >= 2'd3))begin  
      crc_ck_rslt   <= 1'b1;
      //rnti_val_rslt <= rnti_val[63:48];
      rnti_idx_rslt <= 2'd3;
    end  
  end
end

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    crc_ck_en_r <= 1'b0;
  else 
    crc_ck_en_r <= crc_ck_en;
end

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    crc_ck_cnt <= 3'd0;
  else if(pdec_st)  
    crc_ck_cnt <= 3'd0;
  else if(ck_st_1st || ck_st_valid || ck_st_invalid)  
    crc_ck_cnt <= crc_ck_cnt + 1'b1;
end

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    crc_ck_cnt_r <= 3'd0;
  else if(ck_st_1st || ck_st_valid || ck_st_invalid)
    crc_ck_cnt_r <= crc_ck_cnt;
end

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    ck_st_invalid_r <= 1'b0;
  else 
    ck_st_invalid_r <= ck_st_invalid;
end

assign ck_st_inn = (crc_ck_en_r | ck_st_invalid_r) & (~crc_ck_rslt) & (crc_ck_cnt_r < 3'd7) ; //valid_path_num - 1

always @(*)begin
  if(crc_ck_en_r & crc_ck_rslt)begin //align with ck_done, only 1 cycle
    case(crc_ck_cnt_r)
      3'd0  : pm_rslt = srt2ck_pm_val[WID_PM*1-1:WID_PM*0];
      3'd1  : pm_rslt = srt2ck_pm_val[WID_PM*2-1:WID_PM*1];
      3'd2  : pm_rslt = srt2ck_pm_val[WID_PM*3-1:WID_PM*2];
      3'd3  : pm_rslt = srt2ck_pm_val[WID_PM*4-1:WID_PM*3];
      3'd4  : pm_rslt = srt2ck_pm_val[WID_PM*5-1:WID_PM*4];
      3'd5  : pm_rslt = srt2ck_pm_val[WID_PM*6-1:WID_PM*5];
      3'd6  : pm_rslt = srt2ck_pm_val[WID_PM*7-1:WID_PM*6];
      3'd7  : pm_rslt = srt2ck_pm_val[WID_PM*8-1:WID_PM*7];
    default : pm_rslt = srt2ck_pm_val[WID_PM*1-1:WID_PM*0];
    endcase
  end
  else 
    pm_rslt = {WID_PM{1'b1}} ;
end
//----------------------------------------
//[1 : 0] : crc_rslt : 0 :fail, 1: pass, 2:early
//[4 : 2] : path_index : 0~7
//[15: 5] : pm value
//[31:16] : rnti_val
//----------------------------------------

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    ck2cfg_head_data <= 32'd0;
  else if(pdec_st)
    ck2cfg_head_data <= {16'd0,{11{1'b1}},3'd0,2'b0};
  else if(ctrl2ck_tb_st && uph2ck_early_term) // early termination condition
    ck2cfg_head_data <= {16'd0,{11{1'b1}},3'd0,2'd2};
  else if((crc_ck_en_r || ck_st_invalid_r) && crc_ck_rslt) // crc check pass
    //ck2cfg_head_data <= {rnti_val_rslt,{{11-WID_PM{1'b0}},pm_rslt},crc_ck_cnt_r,{1'b0,crc_ck_rslt}}; //16+11+3+2
    ck2cfg_head_data <= {14'd0,rnti_idx_rslt,{{11-WID_PM{1'b0}},pm_rslt},crc_ck_cnt_r,{1'b0,crc_ck_rslt}}; //16+11+3+2
  else if((crc_ck_en_r || ck_st_invalid_r) && (crc_ck_cnt_r == 3'd7)) //crc check fail
    //ck2cfg_head_data <= {rnti_val_rslt,{11{1'b1}},3'd0,{1'b0,crc_ck_rslt}}; //16+11+3+2
    ck2cfg_head_data <= {14'd0,rnti_idx_rslt,{{11-WID_PM{1'b0}},pm_rslt},crc_ck_cnt_r,{1'b0,crc_ck_rslt}}; //16+11+3+2
end

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    ck2ctrl_ck_done <= 1'b0;
  else if(ctrl2ck_tb_st && uph2ck_early_term) // early termination condition
    ck2ctrl_ck_done <= 1'b1;
  else if(((crc_ck_en_r || ck_st_invalid_r) && (crc_ck_rslt || (crc_ck_cnt_r == 3'd7))) && (~uph2ck_early_term)) //not early termination condition
    ck2ctrl_ck_done <= 1'b1;
  else
    ck2ctrl_ck_done <= 1'b0;
end

//====================================================
//====          dec sram write control
//====================================================
wire   dec_wen_pre;
assign dec_wen_pre = dat_in_en  & (dat_in_cnt < {{WID_DEC16-1{1'b1}},1'b0});

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    ck2sram_dec_wen <= 1'b0;
  else
    ck2sram_dec_wen <= dec_wen_pre;
end

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    ck2sram_dec_waddr <= {WID_DEC{1'b0}};
  else if(dec_wen_pre)
    ck2sram_dec_waddr <= dat_in_cnt[WID_DEC16-1:1];
end

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    ck2sram_dec_wdata <= 32'd0;
  else if(dec_wen_pre && (!dat_in_cnt[0])) // == 0
    ck2sram_dec_wdata <= {16'd0,dat_in};
  else if(dec_wen_pre && dat_in_cnt[0])    // == 1
    ck2sram_dec_wdata <= {dat_in,16'd0};
end

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    ck2sram_dec_wbyte <= 4'b0000;
  else if(dec_wen_pre && (!dat_in_cnt[0])) // == 0
    ck2sram_dec_wbyte <= 4'b0011;
  else if(dec_wen_pre && dat_in_cnt[0])    // == 1
    ck2sram_dec_wbyte <= 4'b1100;
end

//====================================================
//====          ICG
//====================================================
always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    ck_proc <= 1'b0;
  else if(ctrl2ck_tb_st)  
    ck_proc <= 1'b1;
  else if(ck2ctrl_ck_done)  
    ck_proc <= 1'b0;
end    

assign pdec_clk_en7 = pdec_st       |
                      ctrl2ck_tb_st |
                      ck_proc       ;

endmodule
//Local Variables:
//verilog-library-flags:("-y ./ -y dir -y otherdir -y ./inc_dir/")
//verilog-auto-inst-param-value:t
//End:

