//////////////////////////////////////////////////////////////////////////////////
// Description:
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps

module pdec_wrap
(
  //----clock and reset
  input  wire               clk             , 
  input  wire               rst_n           , 
  input  wire               ptest_icg_mode  , 
  //----apb interface
  input  wire               pdec_psel       , 
  input  wire               pdec_pwrite     , 
  input  wire               pdec_penable    , 
  input  wire[32-1:0]       pdec_paddr      , 
  input  wire[32-1:0]       pdec_pwdata     , 
  output wire[32-1:0]       pdec_prdata     , 
  output wire               pdec_pready     , 
  output wire               pdec_pslverr    , 
  //----sram interface
  input  wire               pdec_sram_wen   , //write enable
  input  wire[13-1:0]       pdec_sram_waddr , //write address
  input  wire[32-1:0]       pdec_sram_wdata , //write data
  input  wire               pdec_sram_ren   , //read enable
  input  wire[13-1:0]       pdec_sram_raddr , //read address
  output wire[32-1:0]       pdec_sram_rdata , //read data
  //----interrupt
  output wire               pdec_int
);
//====================================================
//====         parameters
//====================================================
localparam   WID_LLR       = 6                 ; 
localparam   WID_INN       = 10                ; 
localparam   NUM_CLK_GATE  = 9                 ;
localparam   ADDR_WIDTH    = 32                ; 
localparam   DATA_WIDTH    = 32                ; 
localparam   PDEC_CFG_VER  = 16'h0000          ; 

`ifdef PDEC_BD
  localparam   WID_PM        = 11                ; 
  localparam   NUM_K         = 456               ;
  localparam   WID_N         = 12                ; //512->9 4096->12
  localparam   NUM_NODE      = 8190              ; 
  localparam   WID_NODE      = $clog2(NUM_NODE)  ; 
  localparam   WID_LLR_ADDR  = WID_N-3           ; //512->6,1024->7,2048->8,4096->9
  localparam   NUM_DCRC_INFO = NUM_K - 24 + 3    ; //NUM_K-24+3
  localparam   WID_K         = $clog2(NUM_K)     ; 
  localparam   WID_DEC       = WID_K-5           ; 
  
  localparam   PARA_NUM      = 513               ; //513-1 
  localparam   WID_PARA_ADDR = $clog2(PARA_NUM)  ; 
`else
  localparam   WID_PM        = 10                ; 
  localparam   NUM_K         = 164               ; 
  localparam   WID_N         = 9                 ; //512->9 4096->12
  localparam   NUM_NODE      = 1022              ; 
  localparam   WID_NODE      = $clog2(NUM_NODE)  ; 
  localparam   WID_LLR_ADDR  = WID_N-3           ; //512->6,1024->7,2048->8,4096->9
  localparam   NUM_DCRC_INFO = NUM_K - 24 + 3    ; //NUM_K-24+3
  localparam   WID_K         = $clog2(NUM_K)     ; 
  localparam   WID_DEC       = WID_K-5           ; 
  
  localparam   PARA_NUM      = 155               ;  
  localparam   WID_PARA_ADDR = $clog2(PARA_NUM)  ; 
`endif

//====================================================
//====         inner signals
//====================================================
//----pdec_para_cfg
//----
wire [WID_K-1:0]            param_a                  ; 
wire [WID_K-1:0]            param_k                  ; 
wire [2:0]                  param_n                  ; 
wire [3*NUM_NODE-1:0]       jump_type                ; 
wire [WID_K*NUM_K-1:0]      il_pattern               ; 
wire [3*NUM_DCRC_INFO-1:0]  dcrc_info_bit            ; 
wire [WID_K*3-1:0]          dcrc_info_idx            ; 
//----
wire [WID_PARA_ADDR-1:0]    para_raddr               ; 
wire [31:0]                 para_rdata               ; 
wire [1:0]                  para_ren                 ; 
wire                        ctrl2cfg_ftch_st         ; 
wire                        cfg2ctrl_ftch_done0      ; 
wire                        cfg2ctrl_ftch_done1      ; 
wire                        cfg2ctrl_ftch_done2      ; 
wire                        pdec_st                  ; 
wire                        pdec_soft_rst            ;
wire                        icg_mode                 ; 
wire                        icg_sw_en                ; 
wire                        leaf_mode                ; 
wire [1:0]                  list_num                 ;
wire                        dcrc_mode                ; 
wire [1:0]                  dcrc_num                 ; 
wire [2:0]                  dcrc_reg_ini             ; 
wire                        crc_flag                 ; 
wire [1:0]                  rnti_num                 ; 
wire [15:0]                 rnti_val0                ; 
wire [15:0]                 rnti_val1                ; 
wire [15:0]                 rnti_val2                ; 
wire [15:0]                 rnti_val3                ; 

//----pdec_top and pdec_sram_top
wire [31:0]                 ck2cfg_head_data         ; 
wire [31:0]                 pdec_debug_info          ; 

wire                        ctrl2sram_depth_ren      ; 
wire [WID_N-1:0]            ctrl2sram_depth_raddr    ; 
wire [3:0]                  sram2ctrl_depth_rdata    ; 

wire                        ctrl2sram_stage_ren      ; 
wire [WID_NODE-1:0]         ctrl2sram_stage_raddr    ; 
wire                        sram2ctrl_stage_rdata_en ; 
wire [4:0]                  sram2ctrl_stage_rdata    ; 

wire                        pdec2drm_llr_ren         ; 
wire [WID_LLR_ADDR-1:0]     pdec2drm_llr_raddr       ; 
wire [WID_LLR*8-1:0]        drm2pdec_llr_rdata       ; 

wire [7:0]                  ulr2sram_llr_wen         ; 
wire [WID_LLR_ADDR*8-1:0]   ulr2sram_llr_waddr       ; 
wire [79:0]                 ulr2sram_llr_wbyte       ; 
wire [WID_INN*64-1:0]       ulr2sram_llr_wdata       ; 

wire [7:0]                  rdc2sram_llr_ren         ; 
wire [WID_LLR_ADDR*8-1:0]   rdc2sram_llr_raddr       ; 
wire [WID_INN*64-1:0]       sram2rdc_llr_rdata       ; 

wire [7:0]                  uph2sram_list_wen        ; 
wire [WID_K-1:0]            uph2sram_list_waddr      ; 
wire [31:0]                 uph2sram_list_wdata      ; 

wire [7:0]                  ck2sram_list_ren         ; 
wire [WID_K-1:0]            ck2sram_list_raddr       ; 
wire [31:0]                 sram2ck_list_rdata       ; 

wire                        ck2sram_dec_wen          ; 
wire [WID_DEC-1:0]          ck2sram_dec_waddr        ; 
wire [3:0]                  ck2sram_dec_wbyte        ; 
wire [31:0]                 ck2sram_dec_wdata        ; 

wire                        drm_sram_int             ; 
wire                        dec_rpt_int              ; 


//====================================================
//====         ICG
//====================================================
wire[NUM_CLK_GATE-1:0] hw_en           ;
wire[NUM_CLK_GATE-1:0] clk_gated       ;
wire                   pdec_clk_en0    ;
wire                   pdec_clk_en1    ;
wire                   pdec_clk_en2    ;
wire                   pdec_clk_en3    ;
wire                   pdec_clk_en4    ;
wire                   pdec_clk_en5    ;
wire                   pdec_clk_en6    ;
wire                   pdec_clk_en7    ;
wire                   pdec_clk_en8    ;
wire                   clk_0           ;
wire                   clk_1           ;
wire                   clk_2           ;
wire                   clk_3           ;
wire                   clk_4           ;
wire                   clk_5           ;
wire                   clk_6           ;
wire                   clk_7           ;
wire                   clk_8           ;

assign hw_en = {pdec_clk_en8,
                pdec_clk_en7,
                pdec_clk_en6,
                pdec_clk_en5,
                pdec_clk_en4,
                pdec_clk_en3,
                pdec_clk_en2,
                pdec_clk_en1,
                pdec_clk_en0};

assign clk_0 = clk_gated[0];
assign clk_1 = clk_gated[1];
assign clk_2 = clk_gated[2];
assign clk_3 = clk_gated[3];
assign clk_4 = clk_gated[4];
assign clk_5 = clk_gated[5];
assign clk_6 = clk_gated[6];
assign clk_7 = clk_gated[7];
assign clk_8 = clk_gated[8];

genvar ii;
generate
  for (ii = 0 ; ii < NUM_CLK_GATE ; ii = ii + 1)begin : PDEC_CLK_GATE
    hgw_icg #(
      .SW_EN_ASYNC      (1                  ),
      .HW_EN_ASYNC      (0                  ),
      .SYNC_NUM         (2                  ))
    U_pdec_icg(
      .clk_i            (clk                ) ,
      .rst_n            (rst_n              ) ,
      .hw0_sw1_mode     (icg_mode           ) , 
      .hw_en            (hw_en[ii]          ) ,
      .sw_en            (icg_sw_en          ) ,
      .ptest_icg_mode   (ptest_icg_mode     ) ,
      .clk_gated        (clk_gated[ii]      ) );  
  end
endgenerate


//====================================================
//====         pdec_para_cfg
//====================================================
pdec_para_cfg#(
// Parameters
.ADDR_WIDTH              (ADDR_WIDTH                                    ) ,
.DATA_WIDTH              (DATA_WIDTH                                    ) ,
.PARA_NUM                (PARA_NUM                                      ) ,
.WID_PARA_ADDR           (WID_PARA_ADDR                                 ) ,
.NUM_K                   (NUM_K                                         ) , 
.WID_K                   (WID_K                                         ) ,
.NUM_NODE                (NUM_NODE                                      ) , 
.NUM_DCRC_INFO           (NUM_DCRC_INFO                                 ) ,
.PDEC_CFG_VER            (PDEC_CFG_VER                                  ) ) 
U_pdec_para_cfg(
// Outputs
.pdec_prdata            (pdec_prdata                                    ) ,
.pdec_pready            (pdec_pready                                    ) ,
.pdec_pslverr           (pdec_pslverr                                   ) ,
.para_ren               (para_ren                                       ) ,
.para_raddr             (para_raddr                                     ) ,
.cfg2ctrl_ftch_done0    (cfg2ctrl_ftch_done0                            ) ,
.cfg2ctrl_ftch_done1    (cfg2ctrl_ftch_done1                            ) ,
.cfg2ctrl_ftch_done2    (cfg2ctrl_ftch_done2                            ) ,
.pdec_st_w1p            (pdec_st                                        ) ,
.pdec_soft_rst          (pdec_soft_rst                                  ) ,
.list_num               (list_num                                       ) ,
.icg_mode               (icg_mode                                       ) ,
.icg_sw_en              (icg_sw_en                                      ) ,
.intr_group_0           (pdec_int                                       ) ,
.param_a                (param_a                                        ) ,
.param_k                (param_k                                        ) ,
.param_n                (param_n                                        ) ,
.leaf_mode              (leaf_mode                                      ) ,
.jump_type              (jump_type                                      ) ,
.il_pattern             (il_pattern                                     ) ,
.dcrc_mode              (dcrc_mode                                      ) ,
.dcrc_num               (dcrc_num                                       ) ,
.dcrc_reg_ini           (dcrc_reg_ini                                   ) ,
.dcrc_info_idx          (dcrc_info_idx                                  ) ,
.dcrc_info_bit          (dcrc_info_bit                                  ) ,
.crc_flag               (crc_flag                                       ) ,
.rnti_num               (rnti_num                                       ) ,
.rnti_val0              (rnti_val0                                      ) ,
.rnti_val1              (rnti_val1                                      ) ,
.rnti_val2              (rnti_val2                                      ) ,
.rnti_val3              (rnti_val3                                      ) ,
.pdec_clk_en8           (pdec_clk_en8                                   ) ,
// Inputs
.clk                    (clk_8                                          ) ,
.rst_n                  (rst_n                                          ) ,
.pdec_psel              (pdec_psel                                      ) ,
.pdec_pwrite            (pdec_pwrite                                    ) ,
.pdec_penable           (pdec_penable                                   ) ,
.pdec_paddr             (pdec_paddr                                     ) ,
.pdec_pwdata            (pdec_pwdata                                    ) ,
.para_rdata             (para_rdata                                     ) ,
.pdec_debug_info        (pdec_debug_info                                ) ,
.dec_rpt_int            (dec_rpt_int                                    ) ,
.drm_sram_int           (drm_sram_int                                   ) ,
.ctrl2cfg_ftch_st       (ctrl2cfg_ftch_st                               ) ,
.pdec_head_info         (ck2cfg_head_data                               )   ) ;

//====================================================
//====         pdec_top
//====================================================
pdec_top#(
// Parameters
.WID_LLR                      (WID_LLR                                  ) ,
.WID_INN                      (WID_INN                                  ) ,
.WID_PM                       (WID_PM                                   ) ,
.WID_N                        (WID_N                                    ) ,
.NUM_NODE                     (NUM_NODE                                 ) ,
.WID_NODE                     (WID_NODE                                 ) ,
.WID_LLR_ADDR                 (WID_LLR_ADDR                             ) ,
.NUM_K                        (NUM_K                                    ) ,
.NUM_DCRC_INFO                (NUM_DCRC_INFO                            ) ,
.WID_K                        (WID_K                                    ) ,
.WID_DEC                      (WID_DEC                                  )   ) 
U_pdec_top(
// Outputs
.ctrl2cfg_ftch_st            (ctrl2cfg_ftch_st                          ) ,
.ck2cfg_head_data            (ck2cfg_head_data                          ) ,
.dec_rpt_int                 (dec_rpt_int                               ) ,
.drm_sram_int                (drm_sram_int                              ) ,
.pdec_debug_info             (pdec_debug_info                           ) ,
.ctrl2sram_stage_raddr       (ctrl2sram_stage_raddr                     ) ,
.ctrl2sram_stage_ren         (ctrl2sram_stage_ren                       ) ,
.ctrl2sram_depth_ren         (ctrl2sram_depth_ren                       ) ,
.ctrl2sram_depth_raddr       (ctrl2sram_depth_raddr                     ) ,
.pdec2drm_llr_ren            (pdec2drm_llr_ren                          ) ,
.pdec2drm_llr_raddr          (pdec2drm_llr_raddr                        ) ,
.rdc2sram_llr_ren            (rdc2sram_llr_ren                          ) ,
.rdc2sram_llr_raddr          (rdc2sram_llr_raddr                        ) ,
.ulr2sram_llr_wen            (ulr2sram_llr_wen                          ) ,
.ulr2sram_llr_waddr          (ulr2sram_llr_waddr                        ) ,
.ulr2sram_llr_wbyte          (ulr2sram_llr_wbyte                        ) ,
.ulr2sram_llr_wdata          (ulr2sram_llr_wdata                        ) ,
.uph2sram_list_wen           (uph2sram_list_wen                         ) ,
.uph2sram_list_waddr         (uph2sram_list_waddr                       ) ,
.uph2sram_list_wdata         (uph2sram_list_wdata                       ) ,
.ck2sram_list_ren            (ck2sram_list_ren                          ) ,
.ck2sram_list_raddr          (ck2sram_list_raddr                        ) ,
.ck2sram_dec_wen             (ck2sram_dec_wen                           ) ,
.ck2sram_dec_waddr           (ck2sram_dec_waddr                         ) ,
.ck2sram_dec_wbyte           (ck2sram_dec_wbyte                         ) ,
.ck2sram_dec_wdata           (ck2sram_dec_wdata                         ) ,
.pdec_clk_en0                (pdec_clk_en0                              ) ,
.pdec_clk_en1                (pdec_clk_en1                              ) ,
.pdec_clk_en2                (pdec_clk_en2                              ) ,
.pdec_clk_en3                (pdec_clk_en3                              ) ,
.pdec_clk_en4                (pdec_clk_en4                              ) ,
.pdec_clk_en5                (pdec_clk_en5                              ) ,
.pdec_clk_en6                (pdec_clk_en6                              ) ,
.pdec_clk_en7                (pdec_clk_en7                              ) ,
// Inputs
//.clk                         (clk                                       ) ,
.clk_0                       (clk_0                                     ) ,
.clk_1                       (clk_1                                     ) ,
.clk_2                       (clk_2                                     ) ,
.clk_3                       (clk_3                                     ) ,
.clk_4                       (clk_4                                     ) ,
.clk_5                       (clk_5                                     ) ,
.clk_6                       (clk_6                                     ) ,
.clk_7                       (clk_7                                     ) ,
.rst_n                       (rst_n                                     ) ,
.pdec_st                     (pdec_st                                   ) ,
.pdec_soft_rst               (pdec_soft_rst                             ) ,
.param_n                     (param_n                                   ) ,
.param_a                     (param_a                                   ) ,
.param_k                     (param_k                                   ) ,
.leaf_mode                   (leaf_mode                                 ) ,
.list_num                    (list_num                                  ) ,
.jump_type                   (jump_type                                 ) ,
.dcrc_idx                    (dcrc_info_idx                             ) ,
.dcrc_info_bit               (dcrc_info_bit                             ) ,
.dcrc_mode                   (dcrc_mode                                 ) ,
.dcrc_num                    (dcrc_num                                  ) ,
.dcrc_reg_ini                (dcrc_reg_ini                              ) ,
.il_pattern                  (il_pattern                                ) ,
.crc_flag                    (crc_flag                                  ) ,
.rnti_num                    (rnti_num                                  ) ,
.rnti_val                    ({rnti_val3,rnti_val2,rnti_val1,rnti_val0} ) ,
.cfg2ctrl_ftch_done0         (cfg2ctrl_ftch_done0                       ) ,
.cfg2ctrl_ftch_done1         (cfg2ctrl_ftch_done1                       ) ,
.cfg2ctrl_ftch_done2         (cfg2ctrl_ftch_done2                       ) ,
.sram2ctrl_stage_rdata_en    (sram2ctrl_stage_rdata_en                  ) ,
.sram2ctrl_stage_rdata       (sram2ctrl_stage_rdata                     ) ,
.sram2ctrl_depth_rdata       (sram2ctrl_depth_rdata                     ) ,
.drm2pdec_llr_rdata          (drm2pdec_llr_rdata                        ) ,
.sram2rdc_llr_rdata          (sram2rdc_llr_rdata                        ) ,
.sram2ck_list_rdata          (sram2ck_list_rdata                        )   ) ;

//====================================================
//====         pdec_sram_top
//====================================================
pdec_sram_top#(
/*AUTOINSTPARAM*/
// Parameters
.WID_LLR                 (WID_LLR                                       ) ,
.WID_INN                 (WID_INN                                       ) ,
.WID_N                   (WID_N                                         ) ,
.WID_NODE                (WID_NODE                                      ) ,
.WID_LLR_ADDR            (WID_LLR_ADDR                                  ) ,
.WID_K                   (WID_K                                         ) ,
.WID_DEC                 (WID_DEC                                       )   ) 
U_pdec_sram_top(
/*AUTOINST*/
// Outputs
.pdec_sram_rdata         (pdec_sram_rdata                               ) ,
.para_rdata              (para_rdata                                    ) ,
.sram2ctrl_stage_rdata_en(sram2ctrl_stage_rdata_en                      ) ,
.sram2ctrl_stage_rdata   (sram2ctrl_stage_rdata                         ) ,
.sram2ctrl_depth_rdata   (sram2ctrl_depth_rdata                         ) ,
.drm2pdec_llr_rdata      (drm2pdec_llr_rdata                            ) ,
.sram2rdc_llr_rdata      (sram2rdc_llr_rdata                            ) ,
.sram2ck_list_rdata      (sram2ck_list_rdata                            ) ,
// Inputs
.clk                     (clk                                           ) ,
.rst_n                   (rst_n                                         ) ,
.pdec_sram_wen           (pdec_sram_wen                                 ) ,
.pdec_sram_waddr         (pdec_sram_waddr                               ) ,
.pdec_sram_wdata         (pdec_sram_wdata                               ) ,
.pdec_sram_ren           (pdec_sram_ren                                 ) ,
.pdec_sram_raddr         (pdec_sram_raddr                               ) ,
.para_ren                (para_ren                                      ) ,
.para_raddr              (para_raddr                                    ) ,
.ctrl2sram_stage_raddr   (ctrl2sram_stage_raddr                         ) ,
.ctrl2sram_stage_ren     (ctrl2sram_stage_ren                           ) ,
.ctrl2sram_depth_ren     (ctrl2sram_depth_ren                           ) ,
.ctrl2sram_depth_raddr   (ctrl2sram_depth_raddr                         ) ,
.pdec2drm_llr_ren        (pdec2drm_llr_ren                              ) ,
.pdec2drm_llr_raddr      (pdec2drm_llr_raddr                            ) ,
.rdc2sram_llr_ren        (rdc2sram_llr_ren                              ) ,
.rdc2sram_llr_raddr      (rdc2sram_llr_raddr                            ) ,
.ulr2sram_llr_wen        (ulr2sram_llr_wen                              ) ,
.ulr2sram_llr_waddr      (ulr2sram_llr_waddr                            ) ,
.ulr2sram_llr_wbyte      (ulr2sram_llr_wbyte                            ) ,
.ulr2sram_llr_wdata      (ulr2sram_llr_wdata                            ) ,
.uph2sram_list_wen       (uph2sram_list_wen                             ) ,
.uph2sram_list_waddr     (uph2sram_list_waddr                           ) ,
.uph2sram_list_wdata     (uph2sram_list_wdata                           ) ,
.ck2sram_list_ren        (ck2sram_list_ren                              ) ,
.ck2sram_list_raddr      (ck2sram_list_raddr                            ) ,
.ck2sram_dec_wen         (ck2sram_dec_wen                               ) ,
.ck2sram_dec_waddr       (ck2sram_dec_waddr                             ) ,
.ck2sram_dec_wbyte       (ck2sram_dec_wbyte                             ) ,
.ck2sram_dec_wdata       (ck2sram_dec_wdata                             )   ) ;


endmodule
//Local Variables:
//verilog-library-flags:("-y ./ -y dir -y otherdir -y ./inc_dir/")
//verilog-auto-inst-param-value:t
//End:

