//////////////////////////////////////////////////////////////////////////////////
// Description: 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps

module pdec_updt_path #(
  parameter                         WID_N         = 9  , //512->9 4096->12
  parameter                         WID_K         = 8  , //log2(164) = 8
  parameter                         NUM_K         = 164, //140+24
  parameter                         NUM_PTR       = 9  , //512->9 4096->12
  parameter                         NUM_DCRC_INFO = 143  //NUM_K-24+3
  )(

  input  wire                       clk                 , 
  input  wire                       rst_n               , 
  
  //----ICG
  output wire                       pdec_clk_en5        ,
  
  //----pdec_para_cfg interface
  input  wire[WID_K-1:0]            param_k             , //1:stage2 , 0:stage0
  input  wire                       leaf_mode           , //0:stage0 is leaf node, 1:stage2 is leaf node
  input  wire[WID_K*NUM_K-1:0]      il_pattern          , //interleave addrress
  input  wire[1:0]                  dcrc_num            , //0:close,1:1bit,2:2bit,3:3bit
  input  wire                       dcrc_mode           , //0:CD,1:CK
  input  wire[WID_K*3-1:0]          dcrc_idx            , //indicate which is dcrc check bit
  input  wire[3-1:0]                dcrc_reg_ini        , //DCRC register initial value
  input  wire[NUM_DCRC_INFO*3-1:0]  dcrc_info_bit       , //indicate which is dcrc info bit
  
  //----broadcast control signals
  input  wire[3:0]                  cur_stage           ,
  input  wire[2:0]                  cur_jump_type       , //0:frozen,1:repetion,2:bit2_type0,3:bit2_type1,4:bit3,5:bit4,7:normal
  input  wire                       pdec_st             , //used for clear status and set info_cnt to zero
  output wire[8*2-1:0]              path_valid          , //3:invalid path,0:CK path,1:valid_path,
  
  //----pdec_top_ctrl interface
  input  wire                       ctrl2uph_uph_st     , //update path start signal
  output wire                       uph2ctrl_uph_done   , //update path done signal
  output wire                       uph2ctrl_early_term , //early termination flag 
  input  wire                       ctrl2uph_llr_updt_en, //llr update done, then update llr pointer 
  input  wire                       ctrl2uph_us_updt_en , //us update done, then update llr pointer 
  input  wire[NUM_PTR-1:0]          ctrl2uph_llr_cp_ind , //indicate llr_ptr of stage be copy, 0: dont copy,1:copy
  input  wire[NUM_PTR-1:0]          ctrl2uph_us_cp_ind  , //indicate us_ptr of stage be copy, 0: dont copy,1:copy
  input  wire[7:0]                  ctrl2uph_srvl_bmp   , //updated path valid signal after pm sort
  
  //----pdec_pm_sort interface
  input  wire[5*8-1:0]              srt2uph_pm_idx      , //0~31 for stage2 ,0~15 for stage0 

  //---pdec_updt_pm interface
  input  wire[4*4*8-1:0]            upm2uph_bit_val     , //stage2 : {bit3,bit2,bit1,bit0} ,inclue frozen bit

  //----pdec_rd_ctrl interface
  output wire[NUM_PTR*3*8-1:0]      uph2rdc_llr_ptr     , 
  output wire[NUM_PTR*3*8-1:0]      uph2rdc_us_ptr      , 

  //----pdec_updt_us interface
  output wire[4*8-1:0]              uph2uus_hard_bit    , //repetion node : {3'd0,bit0}, stage2 node exclue repetion: {bit3,bit2,bit1,bit0} ,inclue frozen bit
  output wire[NUM_PTR*3*8-1:0]      uph2uus_us_ptr      , //the same with uph2rdc_us_ptr
  
  //----pdec_sram_top interface
  output wire[8-1:0]                uph2sram_list_wen   ,
  output wire[WID_K-1:0]            uph2sram_list_waddr ,
  output wire[4*8-1:0]              uph2sram_list_wdata  //{uhat,pp_list}
  
);

//====================================================
//====         inner signals
//====================================================
genvar          ii                                   ; 
genvar          jj                                   ; 
genvar          kk                                   ; 
reg [1:0]       bit_num                              ; 
wire            info_cnt_en                          ; 
reg [WID_K-1:0] info_cnt                             ; 
reg             bit_en_pre                           ; 
reg [1:0]       bit_en_cnt                           ; 
wire[WID_K-1:0] il_pattern_mem[NUM_K-1:0]            ; 
wire[2:0]       dcrc_info_bit_mem[NUM_DCRC_INFO-1:0] ; 
wire[7:0]       bit_st                               ; 
wire[7:0]       bit_en                               ; 
reg [2:0]       dcrc_ck_ind                          ; 
wire[WID_K-1:0] dcrc_itlv_addr                       ; 
wire[2:0]       dcrc_info_ind_pre                    ; 
wire[2:0]       dcrc_info_ind                        ; 
wire[8-1:0]     llr_updt_en                          ; 
wire[8-1:0]     us_updt_en                           ; 
wire[3*8-1:0]   dcrc_reg                             ; 
wire[3-1:0]     dcrc_reg_mem[7:0]                    ; 
wire[5-1:0]     pm_idx_mem[7:0]                      ; 
wire[2:0]       old_idx_mem[7:0]                     ; 
wire[3*8-1:0]   old_idx                              ; 
wire[4-1:0]     bit_val[31:0]                        ; 
reg[3:0]        hard_bit2us[7:0]                     ;
reg [3:0]       stage2_bit[7:0]                      ; 
reg [7:0]       dec_bit                              ; 
reg [7:0]       hat_list                             ; 
reg [3-1:0]     pp_list[7:0]                         ; 
reg [7:0]       pp_list_en                           ; 
reg [WID_K-1:0] pp_list_waddr                        ; 
reg [7:0]       bit_st_r                             ; 
reg [7:0]       bit_en_r                             ; 
reg [1:0]       path_valid_mem[7:0]                  ; 
wire            early_term0                          ;
wire            early_term1                          ;
reg             path_proc                            ;

//====================================================
//====         top control
//====================================================
//----bit en 
always @(*)begin
  if(leaf_mode && ((cur_jump_type == 3'd2) || (cur_jump_type == 3'd3)))
    bit_num = 2'd1; //2-1
  else if(leaf_mode && (cur_jump_type == 3'd4))
    bit_num = 2'd2; //3-1
  else if(leaf_mode && (cur_jump_type == 3'd5))
    bit_num = 2'd3; //4-1
  else 
    bit_num = 2'd0; //1-1
end    

assign info_cnt_en = (ctrl2uph_uph_st && (!leaf_mode)) | bit_en_pre ;

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    info_cnt <= {WID_K{1'b0}} ;
  else if(pdec_st)  
    info_cnt <= {WID_K{1'b0}} ;
  else if(info_cnt_en)
    info_cnt <= info_cnt + 1'b1; 
end

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    bit_en_pre <= 1'b0;
  else if(ctrl2uph_uph_st && leaf_mode)  
    bit_en_pre <= 1'b1;
  else if(bit_en_pre && (bit_en_cnt == bit_num))
    bit_en_pre <= 1'b0;
end

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    bit_en_cnt <= 2'd0;
  else if(ctrl2uph_uph_st && leaf_mode)  
    bit_en_cnt <= 2'd0;
  else if(bit_en_pre)
    bit_en_cnt <= bit_en_cnt + 1'b1;
end

assign bit_st = {8{ctrl2uph_uph_st}} & ctrl2uph_srvl_bmp ;
assign bit_en = {8{bit_en_pre}}      & ctrl2uph_srvl_bmp ; 

//----dcrc information indication
generate
  for(jj=0 ; jj<NUM_K ; jj=jj+1)begin  : il_pattern_arr
    assign il_pattern_mem[jj] = il_pattern[(jj+1)*WID_K-1:jj*WID_K] ;
  end
endgenerate

generate
  for(kk=0 ; kk<NUM_DCRC_INFO ; kk=kk+1)begin  : dcrc_info_arr
    assign dcrc_info_bit_mem[kk] = dcrc_info_bit[(kk+1)*3-1:kk*3] ;
  end
endgenerate


always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    dcrc_ck_ind <= 3'd0;
  else
    dcrc_ck_ind <= {info_cnt_en & (dcrc_num == 2'd3) & (info_cnt == dcrc_idx[WID_K*3-1:WID_K*2]) ,
                    info_cnt_en & (dcrc_num >= 2'd2) & (info_cnt == dcrc_idx[WID_K*2-1:WID_K*1]) ,
                    info_cnt_en & (dcrc_num >= 2'd1) & (info_cnt == dcrc_idx[WID_K*1-1:WID_K*0]) };
end
assign dcrc_itlv_addr    = (info_cnt_en & (info_cnt <= (param_k - 5'd22)) & (dcrc_num != 2'd0)) ? il_pattern_mem[info_cnt] : {WID_K{1'b0}};
assign dcrc_info_ind_pre = (info_cnt_en & (dcrc_num != 2'd0)) ? dcrc_info_bit_mem[dcrc_itlv_addr] : 3'd0;
assign dcrc_info_ind     = {(dcrc_info_ind_pre[2] & (dcrc_num == 2'd3)),(dcrc_info_ind_pre[1] & (dcrc_num >= 2'd2)),(dcrc_info_ind_pre[0] & (dcrc_num >= 2'd1))};
//====================================================
//====               lazy copy 
//==== include llr_ptr/us_ptr/dcrc_reg
//====================================================
assign llr_updt_en    = {8{ctrl2uph_llr_updt_en}} & ctrl2uph_srvl_bmp; 
assign us_updt_en     = {8{ctrl2uph_us_updt_en }} & ctrl2uph_srvl_bmp;
assign uph2uus_us_ptr = uph2rdc_us_ptr ;
pdec_lazy_copy #(
  .WID_K                 (WID_K                     ) ,
  .NUM_K                 (NUM_K                     ) ,
  .NUM_PTR               (NUM_PTR                   ) ) 
U_pdec_lazy_copy (
  // Outputs
  .dcrc_reg              (dcrc_reg                  ) ,
  .llr_ptr               (uph2rdc_llr_ptr           ) ,
  .us_ptr                (uph2rdc_us_ptr            ) ,
  // Inputs
  .clk                   (clk                       ) ,
  .rst_n                 (rst_n                     ) ,
  .pdec_st               (pdec_st                   ) ,
  .cur_stage             (cur_stage                 ) ,
  .old_idx               (old_idx                   ) ,
  .lazy_copy_en          (bit_st                    ) ,
  .llr_copy_ind          (ctrl2uph_llr_cp_ind       ) ,
  .us_copy_ind           (ctrl2uph_us_cp_ind        ) ,
  .llr_updt_en           (llr_updt_en               ) ,
  .us_updt_en            (us_updt_en                ) ,
  .leaf_mode             (leaf_mode                 ) ,
  .bit_st                (bit_st                    ) ,
  .bit_en                (bit_en                    ) ,
  .dec_bit               (dec_bit                  ) ,
  .dcrc_reg_ini          (dcrc_reg_ini              ) ,
  .dcrc_info_ind         (dcrc_info_ind             ) ) ;

//====================================================
//====     calculate dec bit
//====================================================

generate
  for(ii=0 ; ii<8 ; ii=ii+1)begin  : hard_bit_proc
    //----calculate old_idx
    assign pm_idx_mem[ii]     = srt2uph_pm_idx[(ii+1)*5-1:ii*5];
    assign old_idx_mem[ii]    = (cur_jump_type == 4'd1) ? pm_idx_mem[ii][3:1] : pm_idx_mem[ii][4:2]; //repetion or stage2_info 
    assign old_idx[ii*3 +: 3] = old_idx_mem[ii];

    //----calculate dec_bit for dcrc check and trace back
    assign bit_val[4*ii  ] = upm2uph_bit_val[ii*16+4*1-1:ii*16+4*0];
    assign bit_val[4*ii+1] = upm2uph_bit_val[ii*16+4*2-1:ii*16+4*1];
    assign bit_val[4*ii+2] = upm2uph_bit_val[ii*16+4*3-1:ii*16+4*2];
    assign bit_val[4*ii+3] = upm2uph_bit_val[ii*16+4*4-1:ii*16+4*3];
        
    //----calculate hard bit for update us
    always @(posedge clk or negedge rst_n)begin
      if(!rst_n)
        hard_bit2us[ii] <= 4'd0;
      else if(bit_st[ii] && (!leaf_mode)) //jump_type == 0,1 
        hard_bit2us[ii] <= {pm_idx_mem[ii][0],3'd0};
      else if(bit_st[ii] && leaf_mode && (cur_jump_type <  3'd2)) //jump_type == 0,1
        hard_bit2us[ii] <= {pm_idx_mem[ii][0],3'd0};
      else if(bit_st[ii] && leaf_mode && (cur_jump_type >= 3'd2)) //jump_type == 2,3,4,5
        hard_bit2us[ii] <= bit_val[pm_idx_mem[ii]];
    end
    
    assign uph2uus_hard_bit[(ii+1)*4-1:ii*4] = hard_bit2us[ii];

    //calculate uHat
    
    always @(posedge clk or negedge rst_n)begin
      if(!rst_n)
        stage2_bit[ii] <= 4'd0;
      else if(bit_st[ii] && leaf_mode) //only for leaf_mode == 1
        stage2_bit[ii] <= bit_val[pm_idx_mem[ii]];
    end

    always @(*)begin
      if(bit_st[ii] && (~leaf_mode))  
        dec_bit[ii] = pm_idx_mem[ii][0];
      else if(bit_en[ii] && leaf_mode)begin
        //----
        if(cur_jump_type == 3'd1)
          dec_bit[ii] = pm_idx_mem[ii][0];
        //----
        else if(cur_jump_type == 3'd2 && (bit_en_cnt == 2'd0))
          dec_bit[ii] = stage2_bit[ii][3]^stage2_bit[ii][1];
        else if(cur_jump_type == 3'd2 && (bit_en_cnt == 2'd1))
          dec_bit[ii] = stage2_bit[ii][3];
        //----
        else if(cur_jump_type == 3'd3 && (bit_en_cnt == 2'd0))
          dec_bit[ii] = stage2_bit[ii][3]^stage2_bit[ii][2];
        else if(cur_jump_type == 3'd3 && (bit_en_cnt == 2'd1))
          dec_bit[ii] = stage2_bit[ii][3];
        //----
        else if(cur_jump_type == 3'd4 && (bit_en_cnt == 2'd0))
          dec_bit[ii] = stage2_bit[ii][3]^stage2_bit[ii][1];
        else if(cur_jump_type == 3'd4 && (bit_en_cnt == 2'd1))
          dec_bit[ii] = stage2_bit[ii][3]^stage2_bit[ii][2];
        else if(cur_jump_type == 3'd4 && (bit_en_cnt == 2'd2))
          dec_bit[ii] = stage2_bit[ii][3];
        //----
        else if(cur_jump_type == 3'd5 && (bit_en_cnt == 2'd0))
          dec_bit[ii] = stage2_bit[ii][3]^stage2_bit[ii][2]^stage2_bit[ii][1]^stage2_bit[ii][0];
        else if(cur_jump_type == 3'd5 && (bit_en_cnt == 2'd1))
          dec_bit[ii] = stage2_bit[ii][3]^stage2_bit[ii][1];
        else if(cur_jump_type == 3'd5 && (bit_en_cnt == 2'd2))
          dec_bit[ii] = stage2_bit[ii][3]^stage2_bit[ii][2];
        else if(cur_jump_type == 3'd5 && (bit_en_cnt == 2'd3))
          dec_bit[ii] = stage2_bit[ii][3];
        else 
          dec_bit[ii] = 1'b0;
      end
      else
        dec_bit[ii] = 1'b0;
    end

    always @(posedge clk or negedge rst_n)begin
      if(!rst_n)
        hat_list[ii] <= 1'b0;
      else if(pdec_st)
        hat_list[ii] <= 1'b0;
      else if(bit_st[ii] && (~leaf_mode))  
        hat_list[ii] <= dec_bit[ii];
      else if(bit_en[ii] && leaf_mode)
        hat_list[ii] <= dec_bit[ii];
    end

    //----calculate m_pp_list
    always @(posedge clk or negedge rst_n)begin
      if(!rst_n)begin
        pp_list[ii]    <= 3'd0;
        pp_list_en[ii] <= 1'b0;
      end
      else if(pdec_st)begin
        pp_list[ii]    <= 3'd0;
        pp_list_en[ii] <= 1'b0;
      end
      else if(bit_st[ii] && (~leaf_mode))begin  
        pp_list[ii]    <= old_idx_mem[ii];
        pp_list_en[ii] <= 1'b1;
      end  
      else if(bit_en[ii] && leaf_mode && (cur_jump_type == 3'd1))begin //repetion node
        pp_list[ii]    <= old_idx_mem[ii];
        pp_list_en[ii] <= 1'b1;
      end  
      else if(bit_en[ii] && leaf_mode && (cur_jump_type != 3'd1) && (bit_en_cnt == 2'd0))begin
        pp_list[ii]    <= old_idx_mem[ii];
        pp_list_en[ii] <= 1'b1;
      end  
      else if(bit_en[ii] && leaf_mode && (cur_jump_type != 3'd1) && (bit_en_cnt != 2'd0))begin
        pp_list[ii]    <= ii[2:0];
        pp_list_en[ii] <= 1'b1;
      end
      else
        pp_list_en[ii] <= 1'b0;
    end

    assign uph2sram_list_wdata[(ii+1)*4-1:ii*4] = {hat_list[ii],pp_list[ii]}; 

    //----calculate path valid

    always @(posedge clk or negedge rst_n)begin
      if(!rst_n)begin
        bit_st_r[ii] <= 1'b0;
        bit_en_r[ii] <= 1'b0;
      end  
      else begin
        bit_st_r[ii] <= bit_st[ii];
        bit_en_r[ii] <= bit_en[ii];
      end
    end
    
    assign dcrc_reg_mem[ii] = dcrc_reg[ii*3 +: 3];

    if(ii == 0)begin : case_ii0
      always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
          path_valid_mem[ii] <= 2'd3;
        else if(pdec_st)
          path_valid_mem[ii] <= 2'd1;   //valid path
        else if(ctrl2uph_uph_st && (!ctrl2uph_srvl_bmp[ii])) //dont need copy path will be set 3 ,ie. invalid path 
            path_valid_mem[ii] <= 2'd3; //invalid path
        else if(bit_st[ii])begin //copy
          if(path_valid_mem[old_idx_mem[ii]] == 2'd0) //CK
            path_valid_mem[ii] <= 2'd0; //CK path
          else
            path_valid_mem[ii] <= 2'd1; //valid path
        end
        else if(((bit_st_r[ii] && (!leaf_mode)) || bit_en_r[ii]) && ((dcrc_ck_ind[0] && dcrc_reg_mem[ii][0]) || (dcrc_ck_ind[1] && dcrc_reg_mem[ii][1]) || (dcrc_ck_ind[2] && dcrc_reg_mem[ii][2])))begin
          if(dcrc_mode == 1'b0) //CD
            path_valid_mem[ii] <= 2'd3; //invalid path  
          else //CK    
            path_valid_mem[ii] <= 2'd0; //CK path 
        end
      end
    end
    else begin : case_ii_others
      always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
          path_valid_mem[ii] <= 2'd3; //invalid path
        else if(pdec_st)
          path_valid_mem[ii] <= 2'd3; //invalid path 
        else if(ctrl2uph_uph_st && (!ctrl2uph_srvl_bmp[ii]))//dont need copy path will be set 3 ,ie. invalid path 
            path_valid_mem[ii] <= 2'd3; //invalid path
        else if(bit_st[ii])begin //copy
          if(path_valid_mem[old_idx_mem[ii]] == 2'd0) //CK
            path_valid_mem[ii] <= 2'd0; //CK path
          else
            path_valid_mem[ii] <= 2'd1; //valid path
        end
        else if(((bit_st_r[ii] && (!leaf_mode)) || bit_en_r[ii]) && ((dcrc_ck_ind[0] && dcrc_reg_mem[ii][0]) || (dcrc_ck_ind[1] && dcrc_reg_mem[ii][1]) || (dcrc_ck_ind[2] && dcrc_reg_mem[ii][2])))begin
          if(dcrc_mode == 1'b0) //CD
            path_valid_mem[ii] <= 2'd3;  //invalid path
          else //CK    
            path_valid_mem[ii] <= 2'd0;  //CK path 
        end
      end
    end
    
    assign path_valid[(ii+1)*2-1:ii*2] = path_valid_mem[ii];
  end
endgenerate

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    pp_list_waddr <= {WID_K{1'b0}};
  else if(ctrl2uph_uph_st && (!leaf_mode))
    pp_list_waddr <= info_cnt; 
  else if(bit_en_pre)  
    pp_list_waddr <= info_cnt; 
end    

assign uph2sram_list_wen   = pp_list_en   ;
assign uph2sram_list_waddr = pp_list_waddr;

//====================================================
//====      generate early termination flag
//====================================================
assign uph2ctrl_uph_done   = ((~leaf_mode) & (|bit_st_r)) | (leaf_mode & ((~(|bit_en)) & (|bit_en_r)));
assign early_term0         = (~dcrc_mode) & (&path_valid); //CD mode
assign early_term1         =   dcrc_mode  & (~((path_valid[ 0]^path_valid[ 1])| 
                                               (path_valid[ 2]^path_valid[ 3])|
                                               (path_valid[ 4]^path_valid[ 5])|
                                               (path_valid[ 6]^path_valid[ 7])|
                                               (path_valid[ 8]^path_valid[ 9])|
                                               (path_valid[10]^path_valid[11])|
                                               (path_valid[12]^path_valid[13])|
                                               (path_valid[14]^path_valid[15]))); //CK mode
assign uph2ctrl_early_term = early_term0 | early_term1;

//====================================================
//====            ICG
//====================================================
always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    path_proc <= 1'b0;
  else if(ctrl2uph_uph_st)  
    path_proc <= 1'b1;
  else if(uph2ctrl_uph_done)  
    path_proc <= 1'b0;
end    

assign pdec_clk_en5 = pdec_st              |
                      ctrl2uph_uph_st      |
                      path_proc            |
                      ctrl2uph_llr_updt_en |
                      ctrl2uph_us_updt_en  ;

endmodule
//Local Variables:
//verilog-library-flags:("-y ./ -y dir -y otherdir -y ./inc_dir/")
//verilog-auto-inst-param-value:t
//End:

