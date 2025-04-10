//////////////////////////////////////////////////////////////////////////////////
// Description: 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps

module pdec_top#(
  parameter                         WID_LLR       = 6   ,
  parameter                         WID_INN       = 10  ,
  parameter                         WID_PM        = 10  ,
  
  parameter                         WID_N         = 9   , //512->9 4096->12
  parameter                         NUM_NODE      = 1022,
  parameter                         WID_NODE      = 10  ,
  parameter                         WID_LLR_ADDR  = 6   , //512->6,1024->7,2048->8,4096->9       

  parameter                         NUM_K         = 164 ,
  parameter                         NUM_DCRC_INFO = 143 , //NUM_K-24+3
  parameter                         WID_K         = 8   ,
  parameter                         WID_DEC       = 3     //WID_K-5
)(
  //----clk and reset
  //input  wire                        clk                     , 
  input  wire                        clk_0                    , 
  input  wire                        clk_1                    , 
  input  wire                        clk_2                    , 
  input  wire                        clk_3                    , 
  input  wire                        clk_4                    , 
  input  wire                        clk_5                    , 
  input  wire                        clk_6                    , 
  input  wire                        clk_7                    , 
  input  wire                        rst_n                    , 

  //----ICG
  output wire                        pdec_clk_en0             ,
  output wire                        pdec_clk_en1             ,
  output wire                        pdec_clk_en2             ,
  output wire                        pdec_clk_en3             ,
  output wire                        pdec_clk_en4             ,
  output wire                        pdec_clk_en5             ,
  output wire                        pdec_clk_en6             ,
  output wire                        pdec_clk_en7             ,
  
  //----pdec_para_cfg interface
  input  wire                        pdec_st                  , 
  input  wire                        pdec_soft_rst            , 
  input  wire[2:0]                   param_n                  , 
  input  wire[WID_K-1:0]             param_a                  , 
  input  wire[WID_K-1:0]             param_k                  , 
  input  wire                        leaf_mode                , 
  input  wire[1:0]                   list_num                 , 
  input  wire[3*NUM_NODE-1:0]        jump_type                , 
  input  wire[WID_K*3-1:0]           dcrc_idx                 , 
  input  wire[NUM_DCRC_INFO*3-1:0]   dcrc_info_bit            , 
  input  wire                        dcrc_mode                , 
  input  wire[1:0]                   dcrc_num                 , 
  input  wire[2:0]                   dcrc_reg_ini             , 
  input  wire[WID_K*NUM_K-1:0]       il_pattern               , 
  input  wire                        crc_flag                 , 
  input  wire[1:0]                   rnti_num                 , 
  input  wire[63:0]                  rnti_val                 ,
  output wire                        ctrl2cfg_ftch_st         , 
  input  wire                        cfg2ctrl_ftch_done0      , 
  input  wire                        cfg2ctrl_ftch_done1      , 
  input  wire                        cfg2ctrl_ftch_done2      , 
  output wire[31:0]                  ck2cfg_head_data         , 
  output wire                        dec_rpt_int              , 
  output wire                        drm_sram_int             , 
  output wire[31:0]                  pdec_debug_info          ,
  //----pdec_sram_top interface
  output wire[WID_NODE-1:0]          ctrl2sram_stage_raddr    , 
  output wire                        ctrl2sram_stage_ren      , 
  input  wire                        sram2ctrl_stage_rdata_en ,//for multi pdec read condition 
  input  wire[4:0]                   sram2ctrl_stage_rdata    , 
  
  output wire                        ctrl2sram_depth_ren      , 
  output wire[WID_N-1:0]             ctrl2sram_depth_raddr    , 
  input  wire[3:0]                   sram2ctrl_depth_rdata    , 
  
  output wire                        pdec2drm_llr_ren         , 
  output wire[WID_LLR_ADDR-1:0]      pdec2drm_llr_raddr       , 
  input  wire[WID_LLR*8-1:0]         drm2pdec_llr_rdata       , 

  output wire[7:0]                   rdc2sram_llr_ren         , 
  output wire[WID_LLR_ADDR*8-1:0]    rdc2sram_llr_raddr       , 
  input  wire[WID_INN*64-1:0]        sram2rdc_llr_rdata       , 

  output wire[7:0]                   ulr2sram_llr_wen         , 
  output wire[WID_LLR_ADDR*8-1:0]    ulr2sram_llr_waddr       , 
  output wire[79:0]                  ulr2sram_llr_wbyte       , 
  output wire[WID_INN*64-1:0]        ulr2sram_llr_wdata       , 

  output wire[7:0]                   uph2sram_list_wen        , 
  output wire[WID_K-1:0]             uph2sram_list_waddr      , 
  output wire[31:0]                  uph2sram_list_wdata      , 

  output wire[7:0]                   ck2sram_list_ren         , 
  output wire[WID_K-1:0]             ck2sram_list_raddr       , 
  input  wire[31:0]                  sram2ck_list_rdata       , 

  output wire                        ck2sram_dec_wen          , 
  output wire[WID_DEC-1:0]           ck2sram_dec_waddr        , 
  output wire[3:0]                   ck2sram_dec_wbyte        , 
  output wire[31:0]                  ck2sram_dec_wdata         
);

//=============================================
//====       local parameters
//=============================================
localparam      NUM_US        = 1<<(WID_N-1) ;//512->256,4096->2048
localparam      NUM_PTR       = WID_N        ;

//=============================================
//====       inner signals
//=============================================
//----pdec_top_ctrl

wire                    ctrl2ck_tb_st        ; 
wire [8-1:0]            ctrl2ck_tb_ind       ; 
wire                    ctrl2rdc_drm_st      ; 
wire                    ctrl2rdc_inn_st      ; 
wire                    ctrl2srt_srt_st      ; 
wire [NUM_PTR-1:0]      ctrl2uph_llr_cp_ind  ; 
wire                    ctrl2uph_llr_updt_en ; 
wire [7:0]              ctrl2uph_srvl_bmp    ; 
wire                    ctrl2uph_uph_st      ; 
wire [NUM_PTR-1:0]      ctrl2uph_us_cp_ind   ; 
wire                    ctrl2uph_us_updt_en  ; 
wire [1:0]              ctrl2upm_pm_src_ind  ; 
wire                    ctrl2uus_uus_st      ; 
wire [3:0]              cur_depth            ; 
wire                    cur_fg               ; 
wire [2:0]              cur_jump_type        ; 
wire [3:0]              cur_stage            ; 
wire [3:0]              path_num             ; 
wire [3:0]              top_stage            ; 
wire [2:0]              sort_num             ; 

//----pdec_rd_ctrl
wire [WID_INN*64-1:0]   rdc2ulr_llr_data     ; 
wire [7:0]              rdc2ulr_llr_en       ; 
wire [7:0]              rdc2ulr_llr_st       ; 
wire [31:0]             rdc2ulr_us_data      ; 
wire                    rdc2ctrl_rd_done     ; 

//----pdec_updt_llr
wire [WID_INN*32-1:0]   ulr2upm_llr_data     ; 
wire [7:0]              ulr2upm_llr_en       ; 
wire [7:0]              ulr2upm_llr_st       ; 

//----pdec_updt_pm
wire                    upm2ctrl_upm_done    ; 
wire [WID_PM*32-1:0]    upm2srt_pm_val       ; 
wire [127:0]            upm2uph_bit_val      ;

//----pdec_pm_sort
wire                    srt2ctrl_srt_done    ; 
wire [39:0]             srt2uph_pm_idx       ; 
wire [WID_PM*8-1:0]     srt2upm_pm_val       ; 

//----pdec_updt_path
wire [15:0]             path_valid           ; 
wire                    uph2ctrl_early_term  ; 
wire                    uph2ctrl_uph_done    ; 
wire [NUM_PTR*24-1:0]   uph2rdc_llr_ptr      ; 
wire [NUM_PTR*24-1:0]   uph2rdc_us_ptr       ; 
wire [31:0]             uph2uus_hard_bit     ; 
wire [NUM_PTR*24-1:0]   uph2uus_us_ptr       ; 
//----pdec_updt_us
wire                    uus2ctrl_uus_done    ; 
wire [NUM_US*8-1:0]     uus2rdc_us_data      ; 
//----pdec_crc_ck
wire                    ck2ctrl_ck_done      ; 

//=============================================
//====       pdec_top_ctrl
//=============================================
pdec_top_ctrl #(
// Parameters
.NUM_NODE                     (NUM_NODE                               ) ,
.WID_NODE                     (WID_NODE                               ) ,
.WID_N                        (WID_N                                  ) ,
.NUM_PTR                      (NUM_PTR                                ) ) 
U_pdec_top_ctrl(
// Outputs
.drm_sram_int                 (drm_sram_int                           ) ,
.dec_rpt_int                  (dec_rpt_int                            ) ,
.cur_stage                    (cur_stage[3:0]                         ) ,
.cur_depth                    (cur_depth[3:0]                         ) ,
.cur_jump_type                (cur_jump_type[2:0]                     ) ,
.cur_fg                       (cur_fg                                 ) ,
.top_stage                    (top_stage[3:0]                         ) ,
.sort_num                     (sort_num[2:0]                          ) ,
.path_num                     (path_num[3:0]                          ) ,
.ctrl2cfg_ftch_st             (ctrl2cfg_ftch_st                       ) ,
.ctrl2rdc_drm_st              (ctrl2rdc_drm_st                        ) ,
.ctrl2rdc_inn_st              (ctrl2rdc_inn_st                        ) ,
.ctrl2upm_pm_src_ind          (ctrl2upm_pm_src_ind[1:0]               ) ,
.ctrl2srt_srt_st              (ctrl2srt_srt_st                        ) ,
.ctrl2uph_uph_st              (ctrl2uph_uph_st                        ) ,
.ctrl2uph_srvl_bmp            (ctrl2uph_srvl_bmp[7:0]                 ) ,
.ctrl2uph_llr_updt_en         (ctrl2uph_llr_updt_en                   ) ,
.ctrl2uph_us_updt_en          (ctrl2uph_us_updt_en                    ) ,
.ctrl2uph_llr_cp_ind          (ctrl2uph_llr_cp_ind[NUM_PTR-1:0]       ) ,
.ctrl2uph_us_cp_ind           (ctrl2uph_us_cp_ind[NUM_PTR-1:0]        ) ,
.ctrl2uus_uus_st              (ctrl2uus_uus_st                        ) ,
.ctrl2ck_tb_st                (ctrl2ck_tb_st                          ) ,
.ctrl2ck_tb_ind               (ctrl2ck_tb_ind                         ) ,
.ctrl2sram_stage_ren          (ctrl2sram_stage_ren                    ) ,
.ctrl2sram_stage_raddr        (ctrl2sram_stage_raddr[WID_NODE-1:0]    ) ,
.ctrl2sram_depth_ren          (ctrl2sram_depth_ren                    ) ,
.ctrl2sram_depth_raddr        (ctrl2sram_depth_raddr[WID_N-1:0]       ) ,
.pdec_debug_info              (pdec_debug_info                        ) ,
.pdec_clk_en0                 (pdec_clk_en0                           ) ,
// Inputs
.clk                          (clk_0                                  ) ,
.rst_n                        (rst_n                                  ) ,
.pdec_st                      (pdec_st                                ) ,
.pdec_soft_rst                (pdec_soft_rst                          ) ,
.param_n                      (param_n[2:0]                           ) ,
.jump_type                    (jump_type[3*NUM_NODE-1:0]              ) ,
.leaf_mode                    (leaf_mode                              ) ,
.list_num                     (list_num[1:0]                          ) ,
.path_valid                   (path_valid                             ) ,
.cfg2ctrl_ftch_done0          (cfg2ctrl_ftch_done0                    ) ,
.cfg2ctrl_ftch_done1          (cfg2ctrl_ftch_done1                    ) ,
.cfg2ctrl_ftch_done2          (cfg2ctrl_ftch_done2                    ) ,
.rdc2ctrl_rd_done             (rdc2ctrl_rd_done                       ) ,
.upm2ctrl_upm_done            (upm2ctrl_upm_done                      ) ,
.srt2ctrl_srt_done            (srt2ctrl_srt_done                      ) ,
.uph2ctrl_uph_done            (uph2ctrl_uph_done                      ) ,
.uph2ctrl_early_term          (uph2ctrl_early_term                    ) ,
.uus2ctrl_uus_done            (uus2ctrl_uus_done                      ) ,
.ck2ctrl_ck_done              (ck2ctrl_ck_done                        ) ,
.sram2ctrl_stage_rdata        (sram2ctrl_stage_rdata[4:0]             ) ,
.sram2ctrl_stage_rdata_en     (sram2ctrl_stage_rdata_en               ) ,
.sram2ctrl_depth_rdata        (sram2ctrl_depth_rdata[3:0]             )   ) ;

//=============================================
//====       pdec_rd_ctrl
//=============================================
pdec_rd_ctrl #(
// Parameters
.WID_LLR                      (WID_LLR                                ) ,
.WID_INN                      (WID_INN                                ) ,
.WID_LLR_ADDR                 (WID_LLR_ADDR                           ) ,
.NUM_PTR                      (NUM_PTR                                ) ,
.NUM_US                       (NUM_US                                 )   ) 
U_pdec_rd_ctrl(
// Outputs
.rdc2ctrl_rd_done             (rdc2ctrl_rd_done                       ) ,
.rdc2ulr_llr_st               (rdc2ulr_llr_st[7:0]                    ) ,
.rdc2ulr_llr_en               (rdc2ulr_llr_en[7:0]                    ) ,
.rdc2ulr_llr_data             (rdc2ulr_llr_data[WID_INN*64-1:0]       ) ,
.rdc2ulr_us_data              (rdc2ulr_us_data[31:0]                  ) ,
.pdec2drm_llr_ren             (pdec2drm_llr_ren                       ) ,
.pdec2drm_llr_raddr           (pdec2drm_llr_raddr[WID_LLR_ADDR-1:0]   ) ,
.rdc2sram_llr_ren             (rdc2sram_llr_ren[7:0]                  ) ,
.rdc2sram_llr_raddr           (rdc2sram_llr_raddr[WID_LLR_ADDR*8-1:0] ) ,
.pdec_clk_en1                 (pdec_clk_en1                           ) ,
// Inputs
.clk                          (clk_1                                  ) ,
.rst_n                        (rst_n                                  ) ,
.cur_fg                       (cur_fg                                 ) ,
.cur_stage                    (cur_stage[3:0]                         ) ,
.top_stage                    (top_stage[3:0]                         ) ,
.path_valid                   (path_valid[15:0]                       ) ,
.ctrl2rdc_drm_st              (ctrl2rdc_drm_st                        ) ,
.ctrl2rdc_inn_st              (ctrl2rdc_inn_st                        ) ,
.uph2rdc_llr_ptr              (uph2rdc_llr_ptr[NUM_PTR*24-1:0]        ) ,
.uph2rdc_us_ptr               (uph2rdc_us_ptr[NUM_PTR*24-1:0]         ) ,
.uus2rdc_us_data              (uus2rdc_us_data[NUM_US*8-1:0]          ) ,
.drm2pdec_llr_rdata           (drm2pdec_llr_rdata[WID_LLR*8-1:0]      ) ,
.sram2rdc_llr_rdata           (sram2rdc_llr_rdata[WID_INN*64-1:0]     )   ) ;

//=============================================
//====       pdec_updt_llr
//=============================================
pdec_updt_llr #(
// Parameters
.WID_LLR_ADDR                 (WID_LLR_ADDR                           ) ,
.WID_INN                      (WID_INN                                )   ) 
U_pdec_updt_llr(
// Outputs
.ulr2upm_llr_st               (ulr2upm_llr_st[7:0]                    ) ,
.ulr2upm_llr_en               (ulr2upm_llr_en[7:0]                    ) ,
.ulr2upm_llr_data             (ulr2upm_llr_data[WID_INN*32-1:0]       ) ,
.ulr2sram_llr_wen             (ulr2sram_llr_wen[7:0]                  ) ,
.ulr2sram_llr_waddr           (ulr2sram_llr_waddr[WID_LLR_ADDR*8-1:0] ) ,
.ulr2sram_llr_wbyte           (ulr2sram_llr_wbyte[79:0]               ) ,
.ulr2sram_llr_wdata           (ulr2sram_llr_wdata[WID_INN*64-1:0]     ) ,
.pdec_clk_en2                 (pdec_clk_en2                           ) ,
// Inputs
.clk                          (clk_2                                  ) ,
.rst_n                        (rst_n                                  ) ,
.leaf_mode                    (leaf_mode                              ) ,
.cur_fg                       (cur_fg                                 ) ,
.cur_stage                    (cur_stage[3:0]                         ) ,
.cur_jump_type                (cur_jump_type[2:0]                     ) ,
.rdc2ulr_llr_st               (rdc2ulr_llr_st[7:0]                    ) ,
.rdc2ulr_llr_en               (rdc2ulr_llr_en[7:0]                    ) ,
.rdc2ulr_llr_data             (rdc2ulr_llr_data[WID_INN*64-1:0]       ) ,
.rdc2ulr_us_data              (rdc2ulr_us_data[31:0]                  )   ) ;

//=============================================
//====       pdec_updt_pm
//=============================================
pdec_updt_pm #(
// Parameters
.WID_PM                       (WID_PM                                 ) ,
.WID_INN                      (WID_INN                                )   ) 
U_pdec_updt_pm(
// Outputs
.upm2ctrl_upm_done            (upm2ctrl_upm_done                      ) ,
.upm2uph_bit_val              (upm2uph_bit_val[127:0]                 ) ,
.upm2srt_pm_val               (upm2srt_pm_val[WID_PM*32-1:0]          ) ,
.pdec_clk_en3                 (pdec_clk_en3                           ) ,
// Inputs
.clk                          (clk_3                                  ) ,
.rst_n                        (rst_n                                  ) ,
.leaf_mode                    (leaf_mode                              ) ,
.cur_jump_type                (cur_jump_type[2:0]                     ) ,
.path_valid                   (path_valid[15:0]                       ) ,
.ctrl2upm_pm_src_ind          (ctrl2upm_pm_src_ind[1:0]               ) ,
.ulr2upm_llr_st               (ulr2upm_llr_st[7:0]                    ) ,
.ulr2upm_llr_en               (ulr2upm_llr_en[7:0]                    ) ,
.ulr2upm_llr_data             (ulr2upm_llr_data[WID_INN*32-1:0]       ) ,
.srt2upm_pm_val               (srt2upm_pm_val[WID_PM*8-1:0]           )   ) ;

//=============================================
//====       pdec_pm_sort
//=============================================
pdec_pm_sort #(
// Parameters
.WID_PM                       (WID_PM                                 ) ,
.WID_N                        (WID_N                                  )   ) 
U_pdec_pm_sort(
// Outputs
.srt2ctrl_srt_done            (srt2ctrl_srt_done                      ) ,
.srt2upm_pm_val               (srt2upm_pm_val[WID_PM*8-1:0]           ) ,
.srt2uph_pm_idx               (srt2uph_pm_idx[39:0]                   ) ,
.pdec_clk_en4                 (pdec_clk_en4                           ) ,
// Inputs
.clk                          (clk_4                                  ) ,
.rst_n                        (rst_n                                  ) ,
.cur_jump_type                (cur_jump_type[2:0]                     ) ,
.sort_num                     (sort_num[2:0]                          ) ,
.path_valid                   (path_valid[15:0]                       ) ,
.ctrl2srt_srt_st              (ctrl2srt_srt_st                        ) ,
.upm2srt_pm_val               (upm2srt_pm_val[WID_PM*32-1:0]          )   ) ;

//=============================================
//====       pdec_updt_path
//=============================================
pdec_updt_path #(
// Parameters
.WID_N                        (WID_N                                  ) ,
.WID_K                        (WID_K                                  ) ,
.NUM_K                        (NUM_K                                  ) ,
.NUM_PTR                      (NUM_PTR                                ) ,
.NUM_DCRC_INFO                (NUM_DCRC_INFO                          )   ) 
U_pdec_updt_path(
// Outputs
.path_valid                   (path_valid[15:0]                       ) ,
.uph2ctrl_uph_done            (uph2ctrl_uph_done                      ) ,
.uph2ctrl_early_term          (uph2ctrl_early_term                    ) ,
.uph2rdc_llr_ptr              (uph2rdc_llr_ptr[NUM_PTR*24-1:0]        ) ,
.uph2rdc_us_ptr               (uph2rdc_us_ptr[NUM_PTR*24-1:0]         ) ,
.uph2uus_hard_bit             (uph2uus_hard_bit[31:0]                 ) ,
.uph2uus_us_ptr               (uph2uus_us_ptr[NUM_PTR*24-1:0]         ) ,
.uph2sram_list_wen            (uph2sram_list_wen[7:0]                 ) ,
.uph2sram_list_waddr          (uph2sram_list_waddr[WID_K-1:0]         ) ,
.uph2sram_list_wdata          (uph2sram_list_wdata[31:0]              ) ,
.pdec_clk_en5                 (pdec_clk_en5                           ) ,
// Inputs
.clk                          (clk_5                                  ) ,
.rst_n                        (rst_n                                  ) ,
.param_k                      (param_k[WID_K-1:0]                     ) ,
.leaf_mode                    (leaf_mode                              ) ,
.il_pattern                   (il_pattern[WID_K*NUM_K-1:0]            ) ,
.dcrc_num                     (dcrc_num[1:0]                          ) ,
.dcrc_mode                    (dcrc_mode                              ) ,
.dcrc_idx                     (dcrc_idx[WID_K*3-1:0]                  ) ,
.dcrc_reg_ini                 (dcrc_reg_ini[2:0]                      ) ,
.dcrc_info_bit                (dcrc_info_bit[NUM_DCRC_INFO*3-1:0]     ) ,
.cur_stage                    (cur_stage[3:0]                         ) ,
.cur_jump_type                (cur_jump_type[2:0]                     ) ,
.pdec_st                      (cfg2ctrl_ftch_done0                    ) ,
.ctrl2uph_uph_st              (ctrl2uph_uph_st                        ) ,
.ctrl2uph_llr_updt_en         (ctrl2uph_llr_updt_en                   ) ,
.ctrl2uph_us_updt_en          (ctrl2uph_us_updt_en                    ) ,
.ctrl2uph_llr_cp_ind          (ctrl2uph_llr_cp_ind[NUM_PTR-1:0]       ) ,
.ctrl2uph_us_cp_ind           (ctrl2uph_us_cp_ind[NUM_PTR-1:0]        ) ,
.ctrl2uph_srvl_bmp            (ctrl2uph_srvl_bmp[7:0]                 ) ,
.srt2uph_pm_idx               (srt2uph_pm_idx[40-1:0]                 ) ,
.upm2uph_bit_val              (upm2uph_bit_val[127:0]                 ) ) ;

//=============================================
//====       pdec_updt_us
//=============================================
pdec_updt_us #(
// Parameters
.NUM_US                       (NUM_US                                 ) ,
.NUM_PTR                      (NUM_PTR                                )   ) 
U_pdec_updt_us
(
// Outputs
.uus2ctrl_uus_done            (uus2ctrl_uus_done                      ) ,
.uus2rdc_us_data              (uus2rdc_us_data[NUM_US*8-1:0]          ) ,
.pdec_clk_en6                 (pdec_clk_en6                           ) ,
// Inputs
.clk                          (clk_6                                  ) ,
.rst_n                        (rst_n                                  ) ,
.cur_stage                    (cur_stage[3:0]                         ) ,
.cur_depth                    (cur_depth[3:0]                         ) ,
.cur_jump_type                (cur_jump_type[2:0]                     ) ,
.path_valid                   (path_valid[15:0]                       ) ,
.ctrl2uus_uus_st              (ctrl2uus_uus_st                        ) ,
.uph2uus_hard_bit             (uph2uus_hard_bit[31:0]                 ) ,
.uph2uus_us_ptr               (uph2uus_us_ptr[NUM_PTR*24-1:0]         )   ) ;
//=============================================
//====       pdec_crc_ck
//=============================================
pdec_crc_ck #(
// Parameters
.WID_PM                       (WID_PM                                 ) ,
.WID_K                        (WID_K                                  ) ,
.WID_DEC                      (WID_DEC                                ) ,
.NUM_K                        (NUM_K                                  ) ) 
U_pdec_crc_ck(
// Outputs
.ck2cfg_head_data             (ck2cfg_head_data                       ) ,
.ck2ctrl_ck_done              (ck2ctrl_ck_done                        ) ,
.ck2sram_list_ren             (ck2sram_list_ren[7:0]                  ) ,
.ck2sram_list_raddr           (ck2sram_list_raddr[WID_K-1:0]          ) ,
.ck2sram_dec_wen              (ck2sram_dec_wen                        ) ,
.ck2sram_dec_wbyte            (ck2sram_dec_wbyte[3:0]                 ) ,
.ck2sram_dec_waddr            (ck2sram_dec_waddr[WID_DEC-1:0]         ) ,
.ck2sram_dec_wdata            (ck2sram_dec_wdata[31:0]                ) ,
.pdec_clk_en7                 (pdec_clk_en7                           ) ,
// Inputs
.clk                          (clk_7                                  ) ,
.rst_n                        (rst_n                                  ) ,
.pdec_st                      (cfg2ctrl_ftch_done0                    ) ,
.param_a                      (param_a[WID_K-1:0]                     ) ,
.param_k                      (param_k[WID_K-1:0]                     ) ,
.crc_flag                     (crc_flag                               ) ,
.rnti_val                     (rnti_val[63:0]                         ) ,
.rnti_num                     (rnti_num[1:0]                          ) ,
.il_pattern                   (il_pattern                             ) ,
.path_num                     (path_num[3:0]                          ) ,
.path_valid                   (path_valid                             ) ,
.ctrl2ck_tb_st                (ctrl2ck_tb_st                          ) ,
.ctrl2ck_tb_ind               (ctrl2ck_tb_ind                         ) ,
.srt2ck_pm_val                (srt2upm_pm_val[WID_PM*8-1:0]           ) ,
.uph2ck_early_term            (uph2ctrl_early_term                    ) ,
.sram2ck_list_rdata           (sram2ck_list_rdata[31:0]               )   ) ;

endmodule
//Local Variables:
//verilog-library-flags:("-y ./ -y dir -y otherdir -y ./inc_dir/")
//verilog-auto-inst-param-value:t
//End:

