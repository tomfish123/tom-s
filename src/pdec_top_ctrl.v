//////////////////////////////////////////////////////////////////////////////////
// Description:
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps

module pdec_top_ctrl #(
  parameter                         NUM_NODE = 1022 ,
  parameter                         WID_NODE = 10   ,
  parameter                         WID_N    = 9    , //512->9 4096->12
  parameter                         NUM_PTR  = 9      //512->9 4096->12
)(
  input   wire                      clk                     , 
  input   wire                      rst_n                   ,
  
  //----ICG
  output wire                       pdec_clk_en0            ,

  //----
  input   wire                      pdec_st                 ,//dec start signal
  input   wire                      pdec_soft_rst           ,//force state to idle
  
  //----pdec_para_cfg
  input  wire[2:0]                  param_n                 , //0:N=128,1:N=256,2:N=512,3:N=1024,4:N=2048,5:N=4096,
  input  wire[3*NUM_NODE-1:0]       jump_type               , //0:frozen,1:repetion,2:bit2_type0,3:bit2_type1,4:bit3,5:bit4,7:normal
  input  wire                       leaf_mode               , //0:stage0,1:stage2
  input  wire[1:0]                  list_num                , //0:1list,1:2list,2:3list,3:8list;
  output wire                       drm_sram_int            , //DRM SRAM can be writen into 
  output wire                       dec_rpt_int             , //pdec over
  
  //----broadcast control signals
  input  wire[2*8-1:0]              path_valid              ,
  output wire[3:0]                  cur_stage               , 
  output wire[3:0]                  cur_depth               ,
  output wire[2:0]                  cur_jump_type           ,
  output wire                       cur_fg                  ,
  output reg [3:0]                  top_stage               ,
  output reg [2:0]                  sort_num                , //pm sort num 0:sort2 , 1:sort4 , 2:sort8 , 3:sort16 , 4:sort32
  output wire[3:0]                  path_num                , // 1,2,4,8
  
  //----pdec_para_cfg interface
  output wire                       ctrl2cfg_ftch_st        ,
  input  wire                       cfg2ctrl_ftch_done0     , //para for 1st F function fetch done
  input  wire                       cfg2ctrl_ftch_done1     , //para all done
  input  wire                       cfg2ctrl_ftch_done2     , //para half done
  
  //----pdec_rd_ctrl interface
  output wire                       ctrl2rdc_drm_st         , //read drm llr start
  output wire                       ctrl2rdc_inn_st         , //read inn llr start
  input  wire                       rdc2ctrl_rd_done        , //read llr done

  //----pdec_updt_pm interface
  input  wire                       upm2ctrl_upm_done       , //update pm done 
  output wire[1:0]                  ctrl2upm_pm_src_ind     ,
  
  //----pdec_pm_sort interface
  output wire                       ctrl2srt_srt_st         , //pm sort start
  input  wire                       srt2ctrl_srt_done       , //pm sort done

  //----pdec_updt_path interface
  output wire                       ctrl2uph_uph_st         , //update path start signal
  input  wire                       uph2ctrl_uph_done       , //update path done signal
  output reg [7:0]                  ctrl2uph_srvl_bmp       ,
  
  input  wire                       uph2ctrl_early_term     , //early termination flag 
  
  output wire                       ctrl2uph_llr_updt_en    , //llr update done, then update llr pointer 
  output wire                       ctrl2uph_us_updt_en     , //us update done, then update llr pointer 

  output wire[NUM_PTR-1:0]          ctrl2uph_llr_cp_ind     ,
  output wire[NUM_PTR-1:0]          ctrl2uph_us_cp_ind      ,

  //----pdec_updt_us interface
  output wire                       ctrl2uus_uus_st         ,
  input  wire                       uus2ctrl_uus_done       ,

  //----pdec_crc_ck interface
  output wire                       ctrl2ck_tb_st           ,//trace back start
  input  wire                       ck2ctrl_ck_done         ,//crc check done
  output wire[8-1:0]                ctrl2ck_tb_ind          ,
  
  //----debug information
  output wire[31:0]                 pdec_debug_info         ,//debug information

  //----pdec_sram_top interface
  output wire                       ctrl2sram_stage_ren     ,
  output wire[WID_NODE-1:0]         ctrl2sram_stage_raddr   ,
  input  wire[5-1:0]                sram2ctrl_stage_rdata   ,
  input  wire                       sram2ctrl_stage_rdata_en,//for multi pdec share param rom

  output wire                       ctrl2sram_depth_ren     ,
  output wire[WID_N-1:0]            ctrl2sram_depth_raddr   ,
  input  wire[4-1:0]                sram2ctrl_depth_rdata   

);
//============================================
//====      local parameters
//============================================
localparam  IDLE      = 3'd0;
localparam  FTCH      = 3'd1;
localparam  UPDT_LLR0 = 3'd2;
localparam  UPDT_LLR  = 3'd3;
localparam  PM_SRT    = 3'd4;
localparam  UPDT_PTH  = 3'd5;
localparam  UPDT_US   = 3'd6;
localparam  CRC_CK    = 3'd7;
//============================================
//====        inner signals
//============================================
genvar             ii                           ; 
reg [13-1:0]       node_num                     ; 

reg [WID_NODE-1:0] nxt_node_cnt                 ; 
reg [WID_NODE-1:0] cur_node_cnt                 ; 
wire               updt_llr_st                  ; 
reg                updt_llr_st_r                ; 
wire[3:0]          nxt_stage                    ; 
wire               nxt_fg                       ;
wire               jump_type_ren                ;
reg [2:0]          nxt_jump_type                ; 
reg [3:0]          cur_stage_p                  ; 
reg                cur_fg_p                     ; 
reg [2:0]          cur_jump_type_p              ; 

reg [WID_N-1:0]    dec_bit_idx                  ; 
wire[WID_N-1:0]    dec_bit_idx_sub1             ; 
reg                dec_bit_idx_en               ; 

wire               copy_ind_cal                 ; 
wire[NUM_PTR-1:0]  stage_node[NUM_PTR-1:0]      ; 
wire[NUM_PTR-1:0]  stage_node_div2[NUM_PTR-1:0] ; 
reg                llr_cp_ind0                  ; 
reg                llr_cp_ind1                  ; 
reg                llr_cp_ind2                  ; 
reg                llr_cp_ind3                  ; 
reg                llr_cp_ind4                  ; 
reg                llr_cp_ind5                  ; 
reg                llr_cp_ind6                  ; 
reg                llr_cp_ind7                  ; 
reg                llr_cp_ind8                  ; 
`ifdef PDEC_BD
reg                llr_cp_ind9                  ; 
reg                llr_cp_ind10                 ; 
reg                llr_cp_ind11                 ;
`endif
reg                us_cp_ind0                   ; 
reg                us_cp_ind1                   ; 
reg                us_cp_ind2                   ; 
reg                us_cp_ind3                   ; 
reg                us_cp_ind4                   ; 
reg                us_cp_ind5                   ; 
reg                us_cp_ind6                   ; 
reg                us_cp_ind7                   ; 
reg                us_cp_ind8                   ;
`ifdef PDEC_BD
reg                us_cp_ind9                   ; 
reg                us_cp_ind10                  ; 
reg                us_cp_ind11                  ;
`endif
reg [2:0]          cur_stat                     ; 
reg [2:0]          nxt_stat                     ; 
wire               cur_normal_node              ; 
reg                cur_normal_node_r            ; 
wire               cur_frozen_node              ; 
wire               cur_judge_node               ; 
wire               updt_llr_done0               ; 
wire               updt_llr_done1               ; 
wire               updt_llr_done2               ; 
wire               updt_llr_done                ; 
reg                ftch_proc                    ; 
reg                wait_ftch_done               ; 
wire               updt_llr0_done               ; 
wire               cond_idle2ftch               ; 
wire               cond_ftch2zero               ; 
wire               cond_zero2llr                ; 
wire               cond_zero2us                 ; 
wire               cond_zero2srt                ; 
wire               cond_llr2llr                 ; 
wire               cond_llr2us                  ; 
wire               cond_llr2srt                 ; 
wire               cond_srt2pth                 ; 
wire               cond_pth2us                  ; 
wire               cond_pth2ck                  ; 
wire               cond_us2llr                  ; 
wire               cond_us2ck                   ; 
wire               cond_ck2idle                 ; 

reg [1:0]          pm_src_ind                   ;
reg                rdc2ctrl_rd_done_r           ; 
reg                rdc2ctrl_rd_done_rr          ;
//============================================
//====        read stage/fg
//============================================
//----node_num = 2*N-2 
always @(*)begin
  if(param_n == 3'd0)
    node_num = 13'd254; //128*2-2
  else if(param_n == 3'd1)
    node_num = 13'd510; //256*2-2
  else if(param_n == 3'd2)
    node_num = 13'd1022; //512*2-2
`ifdef PDEC_BD
  else if(param_n == 3'd3)
    node_num = 13'd2046; //1024*2-2
  else if(param_n == 3'd4)
    node_num = 13'd4094; //2048*2-2
  else if(param_n == 3'd5)
    node_num = 13'd8190; //4096*2-2
`endif
  else
    node_num = 13'd254; //128*2-2
end
//----top_stage = log2(N)-1
always @(*)begin
  if(param_n == 3'd0)
    top_stage = 4'd6; //log2(128)-1
  else if(param_n == 3'd1)
    top_stage = 4'd7; //log2(256)-1
  else if(param_n == 3'd2)
    top_stage = 4'd8; //log2(512)-1
`ifdef PDEC_BD
  else if(param_n == 3'd3)
    top_stage = 4'd9; //log2(1024)-1
  else if(param_n == 3'd4)
    top_stage = 4'd10; //log2(2048)-1
  else if(param_n == 3'd5)
    top_stage = 4'd11; //log2(4096)-1
`endif
  else
    top_stage = 4'd6; //log2(128)-1
end
//============================================
//====        read stage/fg
//============================================
//----normal node : + 1
//----jump   node : + 2^(stage+1) - 1
always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    nxt_node_cnt <= {WID_NODE{1'b0}};
  else if(pdec_st)  
    nxt_node_cnt <= {WID_NODE{1'b0}};
  else if(updt_llr_st & (~leaf_mode))begin
    if((nxt_jump_type == 3'd0) || (nxt_jump_type == 3'd1))
      nxt_node_cnt <= nxt_node_cnt + (1<<(nxt_stage+1)) - 2'd1; //algo : +(1<<(stage+1)) - 2, and then +1 in for loop
    else
      nxt_node_cnt <= nxt_node_cnt + 1'b1;
  end
  else if(updt_llr_st & leaf_mode)begin
    if(nxt_jump_type == 3'd7)
      nxt_node_cnt <= nxt_node_cnt + 1'b1;
    else
      nxt_node_cnt <= nxt_node_cnt + (1<<(nxt_stage+1)) - 2'd1; //algo : +(1<<(stage+1)) - 2, and then +1 in for loop
  end
end

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    cur_node_cnt <= {WID_NODE{1'b0}};
  else if(updt_llr_st)
    cur_node_cnt <= nxt_node_cnt;
end

assign updt_llr_st = cond_ftch2zero | cond_zero2llr | cond_llr2llr | cond_us2llr ;

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    updt_llr_st_r <= 1'b0;
  else
    updt_llr_st_r <= updt_llr_st ;
end

assign ctrl2sram_stage_ren   = cfg2ctrl_ftch_done0 | (updt_llr_st_r & (cur_node_cnt < (node_num - 1'b1))); 
//assign ctrl2sram_stage_raddr = ctrl2sram_stage_ren ? (nxt_node_cnt + WID_N -1'b1 - top_stage) : {WID_NODE{1'b0}}; //add base address
assign ctrl2sram_stage_raddr = nxt_node_cnt + WID_N -1'b1 - top_stage ; 
assign nxt_stage             = sram2ctrl_stage_rdata[3:0];
assign nxt_fg                = sram2ctrl_stage_rdata[4];

assign jump_type_ren = cfg2ctrl_ftch_done0 |
                       cfg2ctrl_ftch_done2 |
                       (updt_llr_st_r & ((cur_node_cnt < (node_num - 1'b1)) | (cur_node_cnt > {WID_NODE{1'b0}})));
                       
always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    nxt_jump_type <= 3'd0 ;
  else if(jump_type_ren)
    nxt_jump_type <= jump_type[nxt_node_cnt*3 +: 3]; //select out jump type
end

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin
    cur_stage_p     <= 4'd0;
    cur_fg_p        <= 1'b0;
    cur_jump_type_p <= 3'd0 ;
  end  
  else if(updt_llr_st)begin
    cur_stage_p     <= nxt_stage;
    cur_fg_p        <= nxt_fg;
    cur_jump_type_p <= nxt_jump_type ;
  end  
end

assign cur_stage     = updt_llr_st ? nxt_stage : cur_stage_p ;
assign cur_fg        = cur_fg_p        ;
assign cur_jump_type = cur_jump_type_p ;

//============================================
//====        read depth
//============================================
always @(posedge clk or negedge rst_n)begin 
  if(!rst_n)
    dec_bit_idx <= {WID_N{1'b0}};
  else if(pdec_st)  
    dec_bit_idx <= {WID_N{1'b0}};
  else if(updt_llr_st && ((nxt_jump_type == 3'd0) || (nxt_jump_type == 3'd1) || (leaf_mode & (nxt_stage == 4'd2)))) //frozen repetion and stage2  
    dec_bit_idx <= dec_bit_idx + (1<<nxt_stage); // sub 1 when use it
end

assign dec_bit_idx_sub1 = dec_bit_idx - 1'b1;

always @(posedge clk or negedge rst_n)begin 
  if(!rst_n)
    dec_bit_idx_en <= 1'b0;
  else
    dec_bit_idx_en <= updt_llr_st && ((nxt_jump_type == 3'd0) || (nxt_jump_type == 3'd1) || (leaf_mode & (nxt_stage == 4'd2)));
end

assign ctrl2sram_depth_ren     = dec_bit_idx_en       ;
assign ctrl2sram_depth_raddr   = dec_bit_idx_sub1     ;
assign cur_depth               = sram2ctrl_depth_rdata; //the last depth should be forced to zero

//============================================
//====    calculate llr us copy indication
//============================================
assign copy_ind_cal = dec_bit_idx_en & (cur_jump_type_p != 3'd0) ; //node which will update path

generate
  for(ii=0 ; ii<NUM_PTR ; ii=ii+1)begin  : lazy_copy_ind
    assign stage_node[ii]      = (1<<ii);
    assign stage_node_div2[ii] = {1'b0,stage_node[ii][NUM_PTR-1:1]};
  end
endgenerate
//----calculate llr_cp_ind
always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin
    llr_cp_ind0  <= 1'b0;
    llr_cp_ind1  <= 1'b0;
    llr_cp_ind2  <= 1'b0;
    llr_cp_ind3  <= 1'b0;
    llr_cp_ind4  <= 1'b0;
    llr_cp_ind5  <= 1'b0;
    llr_cp_ind6  <= 1'b0;
    llr_cp_ind7  <= 1'b0;
    llr_cp_ind8  <= 1'b0;
`ifdef PDEC_BD
    llr_cp_ind9  <= 1'b0;
    llr_cp_ind10 <= 1'b0;
    llr_cp_ind11 <= 1'b0;
`endif
  end
  else if(copy_ind_cal)begin 
    llr_cp_ind0  <= ( {NUM_PTR{1'b0}}                            < stage_node_div2[ 0]) ? 1'b1 : 1'b0;
    llr_cp_ind1  <= ({{NUM_PTR- 1{1'b0}},dec_bit_idx_sub1[  0]}  < stage_node_div2[ 1]) ? 1'b1 : 1'b0;
    llr_cp_ind2  <= ({{NUM_PTR- 2{1'b0}},dec_bit_idx_sub1[1:0]}  < stage_node_div2[ 2]) ? 1'b1 : 1'b0;
    llr_cp_ind3  <= ({{NUM_PTR- 3{1'b0}},dec_bit_idx_sub1[2:0]}  < stage_node_div2[ 3]) ? 1'b1 : 1'b0;
    llr_cp_ind4  <= ({{NUM_PTR- 4{1'b0}},dec_bit_idx_sub1[3:0]}  < stage_node_div2[ 4]) ? 1'b1 : 1'b0;
    llr_cp_ind5  <= ({{NUM_PTR- 5{1'b0}},dec_bit_idx_sub1[4:0]}  < stage_node_div2[ 5]) ? 1'b1 : 1'b0;
    llr_cp_ind6  <= ({{NUM_PTR- 6{1'b0}},dec_bit_idx_sub1[5:0]}  < stage_node_div2[ 6]) ? 1'b1 : 1'b0;
    llr_cp_ind7  <= ({{NUM_PTR- 7{1'b0}},dec_bit_idx_sub1[6:0]}  < stage_node_div2[ 7]) ? 1'b1 : 1'b0;
    llr_cp_ind8  <= ({{NUM_PTR- 8{1'b0}},dec_bit_idx_sub1[7:0]}  < stage_node_div2[ 8]) ? 1'b1 : 1'b0;
`ifdef PDEC_BD
    llr_cp_ind9  <= ({{NUM_PTR- 9{1'b0}},dec_bit_idx_sub1[8:0]}  < stage_node_div2[ 9]) ? 1'b1 : 1'b0;
    llr_cp_ind10 <= ({{NUM_PTR-10{1'b0}},dec_bit_idx_sub1[9:0]}  < stage_node_div2[10]) ? 1'b1 : 1'b0;
    llr_cp_ind11 <= ({{NUM_PTR-11{1'b0}},dec_bit_idx_sub1[10:0]} < stage_node_div2[11]) ? 1'b1 : 1'b0;
`endif
  end
end
  
`ifdef PDEC_BD
  assign ctrl2uph_llr_cp_ind = {llr_cp_ind11,llr_cp_ind10,llr_cp_ind9,llr_cp_ind8,llr_cp_ind7,llr_cp_ind6,
                                llr_cp_ind5 ,llr_cp_ind4 ,llr_cp_ind3,llr_cp_ind2,llr_cp_ind1,llr_cp_ind0};
`else
  assign ctrl2uph_llr_cp_ind = {                                      llr_cp_ind8,llr_cp_ind7,llr_cp_ind6,
                                llr_cp_ind5 ,llr_cp_ind4 ,llr_cp_ind3,llr_cp_ind2,llr_cp_ind1,llr_cp_ind0};
`endif
//----calculate us_cp_ind
always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin
    us_cp_ind0  <= 1'b0;
    us_cp_ind1  <= 1'b0;
    us_cp_ind2  <= 1'b0;
    us_cp_ind3  <= 1'b0;
    us_cp_ind4  <= 1'b0;
    us_cp_ind5  <= 1'b0;
    us_cp_ind6  <= 1'b0;
    us_cp_ind7  <= 1'b0;
    us_cp_ind8  <= 1'b0;
`ifdef PDEC_BD
    us_cp_ind9  <= 1'b0;
    us_cp_ind10 <= 1'b0;
    us_cp_ind11 <= 1'b0;
`endif  
  end
  else if(copy_ind_cal)begin 
    us_cp_ind0  <= ({{NUM_PTR- 1{1'b0}},dec_bit_idx_sub1[   0]} >= stage_node[ 0]) ? 1'b1 : 1'b0;
    us_cp_ind1  <= ({{NUM_PTR- 2{1'b0}},dec_bit_idx_sub1[1 :0]} >= stage_node[ 1]) ? 1'b1 : 1'b0;
    us_cp_ind2  <= ({{NUM_PTR- 3{1'b0}},dec_bit_idx_sub1[2 :0]} >= stage_node[ 2]) ? 1'b1 : 1'b0;
    us_cp_ind3  <= ({{NUM_PTR- 4{1'b0}},dec_bit_idx_sub1[3 :0]} >= stage_node[ 3]) ? 1'b1 : 1'b0;
    us_cp_ind4  <= ({{NUM_PTR- 5{1'b0}},dec_bit_idx_sub1[4 :0]} >= stage_node[ 4]) ? 1'b1 : 1'b0;
    us_cp_ind5  <= ({{NUM_PTR- 6{1'b0}},dec_bit_idx_sub1[5 :0]} >= stage_node[ 5]) ? 1'b1 : 1'b0;
    us_cp_ind6  <= ({{NUM_PTR- 7{1'b0}},dec_bit_idx_sub1[6 :0]} >= stage_node[ 6]) ? 1'b1 : 1'b0;
    us_cp_ind7  <= ({{NUM_PTR- 8{1'b0}},dec_bit_idx_sub1[7 :0]} >= stage_node[ 7]) ? 1'b1 : 1'b0;
    us_cp_ind8  <= ({{NUM_PTR- 9{1'b0}},dec_bit_idx_sub1[8 :0]} >= stage_node[ 8]) ? 1'b1 : 1'b0;
`ifdef PDEC_BD
    us_cp_ind9  <= ({{NUM_PTR-10{1'b0}},dec_bit_idx_sub1[9 :0]} >= stage_node[ 9]) ? 1'b1 : 1'b0;
    us_cp_ind10 <= ({{NUM_PTR-11{1'b0}},dec_bit_idx_sub1[10:0]} >= stage_node[10]) ? 1'b1 : 1'b0;
    us_cp_ind11 <= (                    dec_bit_idx_sub1[11:0]  >= stage_node[11]) ? 1'b1 : 1'b0;
`endif  
  end
end 

`ifdef PDEC_BD
  assign ctrl2uph_us_cp_ind = {us_cp_ind11,us_cp_ind10,us_cp_ind9,us_cp_ind8,us_cp_ind7,us_cp_ind6,
                               us_cp_ind5 ,us_cp_ind4 ,us_cp_ind3,us_cp_ind2,us_cp_ind1,us_cp_ind0};
`else
  assign ctrl2uph_us_cp_ind = {                                   us_cp_ind8,us_cp_ind7,us_cp_ind6,
                               us_cp_ind5 ,us_cp_ind4 ,us_cp_ind3,us_cp_ind2,us_cp_ind1,us_cp_ind0};
`endif

//============================================
//====                FSM
//============================================
//----llr done
assign cur_normal_node = (leaf_mode & (cur_jump_type_p == 3'd7)) | ((~leaf_mode) & ((cur_jump_type_p !=3'd0) & (cur_jump_type_p !=3'd1)));
assign cur_frozen_node = (cur_jump_type_p == 3'd0) ;
assign cur_judge_node  = (leaf_mode & ((cur_jump_type_p != 3'd7) & (cur_jump_type_p != 3'd0))) | ((~leaf_mode) & (cur_jump_type_p ==3'd1));


always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    cur_normal_node_r <= 1'b0;
  else if(rdc2ctrl_rd_done_rr)
    cur_normal_node_r <= cur_normal_node;
end

assign updt_llr_done0 = rdc2ctrl_rd_done_rr  & cur_normal_node; //dont have upm_done
assign updt_llr_done1 = upm2ctrl_upm_done    & cur_frozen_node & (~cur_normal_node_r);
assign updt_llr_done2 = upm2ctrl_upm_done    & cur_judge_node  & (~cur_normal_node_r);
assign updt_llr_done  = updt_llr_done0 | updt_llr_done1 | updt_llr_done2;
//----param ftch and llr0 done handshake

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    ftch_proc <= 1'b0;
  else if(ctrl2cfg_ftch_st)  
    ftch_proc <= 1'b1;
  else if(cfg2ctrl_ftch_done1)
    ftch_proc <= 1'b0;
end

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    wait_ftch_done <= 1'b0;
  else if(ftch_proc && updt_llr_done)  
    wait_ftch_done <= 1'b1;
  else if(cfg2ctrl_ftch_done1)  
    wait_ftch_done <= 1'b0;
end    

assign updt_llr0_done = (updt_llr_done & (~ftch_proc) & (cur_stat == UPDT_LLR0)) | (cfg2ctrl_ftch_done1 & wait_ftch_done) ;

//----jump condition
assign cond_idle2ftch  = pdec_st & (cur_stat == IDLE);
assign cond_ftch2zero  = sram2ctrl_stage_rdata_en & (cur_stat == FTCH);
assign cond_zero2llr   = updt_llr0_done & (cur_jump_type_p == 3'd7); 
assign cond_zero2us    = updt_llr0_done & (cur_jump_type_p == 3'd0);
assign cond_zero2srt   = updt_llr0_done & (cur_jump_type_p == 3'd1);
assign cond_llr2llr    = updt_llr_done0 & (cur_stat == UPDT_LLR); 
assign cond_llr2us     = updt_llr_done1 & (cur_stat == UPDT_LLR); 
assign cond_llr2srt    = updt_llr_done2 & (cur_stat == UPDT_LLR); 
assign cond_srt2pth    = srt2ctrl_srt_done ;
assign cond_pth2us     = uph2ctrl_uph_done & (nxt_node_cnt <  node_num); //not last node
assign cond_pth2ck     = uph2ctrl_uph_done & (nxt_node_cnt >= node_num); //    last node
assign cond_us2llr     = uus2ctrl_uus_done & (~uph2ctrl_early_term) & (nxt_node_cnt <  node_num) ;
assign cond_us2ck      = uus2ctrl_uus_done & ( uph2ctrl_early_term  | (nxt_node_cnt >= node_num));
assign cond_ck2idle    = ck2ctrl_ck_done;
//----fsm
always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    cur_stat <= 3'd0;
  else
    cur_stat <= nxt_stat; 
end

always @(*)begin
  nxt_stat = IDLE;
  case(cur_stat)
    IDLE : begin
      if(cond_idle2ftch)
        nxt_stat = FTCH;
      else 
        nxt_stat = IDLE; 
    end
    FTCH : begin
      if(pdec_soft_rst)
        nxt_stat = IDLE; 
      else if(cond_ftch2zero)
        nxt_stat = UPDT_LLR0;
      else
        nxt_stat = FTCH;
    end
    UPDT_LLR0 : begin
      if(pdec_soft_rst)
        nxt_stat = IDLE; 
      else if(cond_zero2llr)
        nxt_stat = UPDT_LLR;
      else if(cond_zero2us)
        nxt_stat = UPDT_US;
      else if(cond_zero2srt)
        nxt_stat = PM_SRT;
      else
        nxt_stat = UPDT_LLR0;
    end
    UPDT_LLR : begin
      if(pdec_soft_rst)
        nxt_stat = IDLE; 
      else if(cond_llr2llr)
        nxt_stat = UPDT_LLR;
      else if(cond_llr2us)
        nxt_stat = UPDT_US;
      else if(cond_llr2srt)
        nxt_stat = PM_SRT;
      else
        nxt_stat = UPDT_LLR;  
    end
    PM_SRT: begin
      if(pdec_soft_rst)
        nxt_stat = IDLE; 
      else if(cond_srt2pth)
        nxt_stat = UPDT_PTH;
      else
        nxt_stat = PM_SRT;            
    end
    UPDT_PTH: begin
      if(pdec_soft_rst)
        nxt_stat = IDLE; 
      else if(cond_pth2ck)
        nxt_stat = CRC_CK;
      else if(cond_pth2us)
        nxt_stat = UPDT_US;
      else
        nxt_stat = UPDT_PTH;            
    end
    UPDT_US: begin
      if(pdec_soft_rst)
        nxt_stat = IDLE; 
      else if(cond_us2ck)
        nxt_stat = CRC_CK;
      else if(cond_us2llr)
        nxt_stat = UPDT_LLR;
      else
        nxt_stat = UPDT_US;            
    end
    CRC_CK: begin
      if(pdec_soft_rst)
        nxt_stat = IDLE; 
      else if(cond_ck2idle)
        nxt_stat = IDLE;
      else
        nxt_stat = CRC_CK;            
    end
    default : nxt_stat = IDLE;
  endcase 
end 

//============================================
//====       generate start signals
//============================================
assign ctrl2cfg_ftch_st = cond_idle2ftch                          ;
assign ctrl2rdc_drm_st  = updt_llr_st & (nxt_stage == top_stage)  ; 
assign ctrl2rdc_inn_st  = updt_llr_st & (nxt_stage != top_stage)  ; 
assign ctrl2srt_srt_st  = cond_zero2srt | cond_llr2srt            ;
assign ctrl2uph_uph_st  = cond_srt2pth                            ;
assign ctrl2uus_uus_st  = cond_zero2us | cond_llr2us | cond_pth2us;
assign ctrl2ck_tb_st    = cond_pth2ck  | cond_us2ck               ;


//============================================
//====       generate control signals
//============================================
//----control update pm
always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    pm_src_ind <= 2'd0;
  else if(cond_ftch2zero)
    pm_src_ind <= 2'd0;
  else if(cond_zero2us || cond_llr2us)
    pm_src_ind <= 2'd1;
  else if(cond_zero2srt || cond_llr2srt)  
    pm_src_ind <= 2'd2;
end

assign ctrl2upm_pm_src_ind = pm_src_ind;
//----control update path
always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin
    rdc2ctrl_rd_done_r  <= 1'b0;
    rdc2ctrl_rd_done_rr <= 1'b0;
  end
  else begin
    rdc2ctrl_rd_done_r  <= rdc2ctrl_rd_done;
    rdc2ctrl_rd_done_rr <= rdc2ctrl_rd_done_r;
  end
end

assign ctrl2uph_llr_updt_en = rdc2ctrl_rd_done_r ; 
assign ctrl2uph_us_updt_en  = uus2ctrl_uus_done   ;
//============================================
//====  survial path to indicate useful pm_out
//============================================
wire[7:0]             valid_path_ind     ;
wire[7:0]             ck_path_ind        ;
wire[3:0]             valid_path_num     ;
wire[3:0]             ck_path_num        ;
wire[5:0]             valid_path_num_sum ;
wire[3:0]             srvl_path          ;

assign valid_path_ind = {(path_valid[15:14] == 2'd1),(path_valid[13:12] == 2'd1),(path_valid[11:10] == 2'd1),(path_valid[9 : 8] == 2'd1),
                         (path_valid[7 : 6] == 2'd1),(path_valid[5 : 4] == 2'd1),(path_valid[3 : 2] == 2'd1),(path_valid[1 : 0] == 2'd1)};

assign ck_path_ind    = {(path_valid[15:14] == 2'd0),(path_valid[13:12] == 2'd0),(path_valid[11:10] == 2'd0),(path_valid[9 : 8] == 2'd0),
                         (path_valid[7 : 6] == 2'd0),(path_valid[5 : 4] == 2'd0),(path_valid[3 : 2] == 2'd0),(path_valid[1 : 0] == 2'd0)};

assign valid_path_num = valid_path_ind[0] + valid_path_ind[1] + valid_path_ind[2] + valid_path_ind[3] + 
                        valid_path_ind[4] + valid_path_ind[5] + valid_path_ind[6] + valid_path_ind[7] ;

assign ck_path_num    = ck_path_ind[0] + ck_path_ind[1] + ck_path_ind[2] + ck_path_ind[3] + 
                        ck_path_ind[4] + ck_path_ind[5] + ck_path_ind[6] + ck_path_ind[7] ;


assign valid_path_num_sum = (cur_jump_type == 3'd1) ? {valid_path_num,1'b0} + ck_path_num : {valid_path_num,2'd0} + ck_path_num; //max value is 32,so 6bit can conver
assign path_num           = (1<<list_num);
assign srvl_path          = ({2'd0,path_num} <= valid_path_num_sum) ? path_num :  valid_path_num_sum[3:0];

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    ctrl2uph_srvl_bmp <= 8'h00;
  else if(ctrl2srt_srt_st)begin
    case(srvl_path)
      4'd0    : ctrl2uph_srvl_bmp <= 8'h00;
      4'd1    : ctrl2uph_srvl_bmp <= 8'h01;
      4'd2    : ctrl2uph_srvl_bmp <= 8'h03;
      4'd3    : ctrl2uph_srvl_bmp <= 8'h07;
      4'd4    : ctrl2uph_srvl_bmp <= 8'h0F;
      4'd5    : ctrl2uph_srvl_bmp <= 8'h1F;
      4'd6    : ctrl2uph_srvl_bmp <= 8'h3F;
      4'd7    : ctrl2uph_srvl_bmp <= 8'h7F;
      4'd8    : ctrl2uph_srvl_bmp <= 8'hFF;
      default : ctrl2uph_srvl_bmp <= 8'h00; 
    endcase
  end
end

//assign ctrl2ck_tb_ind = {valid_path_num,valid_path_ind}; // 4+8 = 12
assign ctrl2ck_tb_ind = valid_path_ind; 
//============================================
//====            sort num 
//============================================
always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    sort_num <= 3'd0; //0,1,2,3,4
  else if(pdec_st)
    sort_num <= 3'd0;
  else if(updt_llr_st_r && (cur_jump_type == 3'd1))begin
    if(list_num == 2'd0)
      sort_num <= 3'd0;
    else if(list_num == 2'd1)    
      sort_num <= 3'd1;
    else if(list_num == 2'd2)    
      sort_num <= 3'd2;
    else // == 2'd3    
      sort_num <= 3'd3;
  end
  else if(updt_llr_st_r && leaf_mode && (cur_stage == 4'd2))begin
    if(list_num == 2'd0)
      sort_num <= 3'd1;
    else if(list_num == 2'd1)    
      sort_num <= 3'd2;
    else if(list_num == 2'd2)    
      sort_num <= 3'd3;
    else // == 2'd3    
      sort_num <= 3'd4;
  end
end

//============================================
//====       ICG control signal
//============================================
assign pdec_clk_en0 = pdec_st | pdec_soft_rst | (cur_stat != IDLE) ;

//============================================
//====       generate interrupt signals
//============================================
assign drm_sram_int = rdc2ctrl_rd_done_rr & (cur_stat == UPDT_LLR) & (cur_stage_p == top_stage);
assign dec_rpt_int  = cond_ck2idle;

//============================================
//====       generate debug information
//============================================
assign pdec_debug_info = {{28-WID_NODE{1'b0}},
                          cur_node_cnt       , //WID_NODE
                          ftch_proc          , //1bit
                          cur_stat           };//3bit
                          
endmodule
//Local Variables:
//verilog-library-flags:("-y ./ -y dir -y otherdir -y ./inc_dir/")
//verilog-auto-inst-param-value:t
//End:

