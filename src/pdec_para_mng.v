

`timescale 1ns/10ps

module pdec_para_mng#(
  parameter                          ADDR_WIDTH    = 32       , 
  parameter                          DATA_WIDTH    = 32       , 
  parameter                          PARA_NUM      = 155      , 
  parameter                          WID_PARA_ADDR = 7        , 
  parameter                          NUM_K         = 164      , 
  parameter                          WID_K         = 8        ,
  parameter                          NUM_NODE      = 1022     , 
  parameter                          NUM_DCRC_INFO = 143      
  )(
  //----clk and reset
  input  wire                        clk                      , 
  input  wire                        rst_n                    , 
  
  //----ICG
  output wire                        pdec_clk_en8             ,
  
  //----
  input  wire[31:0]                  pdec_base_addr           , //only align with pdec_st
  
  //----dma interface
  output wire                        dma_valid                , //fetch pdec0 parameters
  output wire[31:0]                  dma_src_addr             , 
  input  wire                        dma_rvalid               , 
  input  wire[31:0]                  dma_rdata                , 
  input  wire                        dma_done                 ,      
  
  //----pdec_top interface
  input  wire                        ctrl2cfg_ftch_st         , 
  output wire                        cfg2ctrl_ftch_done0      , 
  output wire                        cfg2ctrl_ftch_done1      , 
  output wire                        cfg2ctrl_ftch_done2      , 
  
  //----dyn para
  output wire[WID_K-1:0]             param_a                  ,//type0 
  output wire[WID_K-1:0]             param_k                  , 
  output wire                        leaf_mode                , 
  output wire[1:0]                   list_num                 , 
  output wire[1:0]                   rm_mode                  ,
  output wire[2:0]                   param_n                  ,//type1 
  output wire[3*NUM_NODE-1:0]        jump_type                ,
  
  output wire[WID_K*NUM_K-1:0]       il_pattern               ,//type2
  output wire[1:0]                   dcrc_num                 , 
  output wire                        dcrc_mode                , 
  output wire[2:0]                   dcrc_reg_ini             , 
  output wire[WID_K*3-1:0]           dcrc_info_idx            , 
  output wire[3*NUM_DCRC_INFO-1:0]   dcrc_info_bit            , 
  output wire                        crc_flag                 , 
  output wire[1:0]                   rnti_num                 , 
  output wire[15:0]                  rnti_val0                , 
  output wire[15:0]                  rnti_val1                , 
  output wire[15:0]                  rnti_val2                , 
  output wire[15:0]                  rnti_val3                  
);
//=============================================
//====       inner signals
//=============================================
wire[1:0]                   param_n_pre     ;
wire[31:0]                  dcrc_info_bit0  ; 
wire[31:0]                  dcrc_info_bit1  ; 
wire[31:0]                  dcrc_info_bit10 ; 
wire[31:0]                  dcrc_info_bit11 ; 
wire[31:0]                  dcrc_info_bit12 ; 
wire[12:0]                  dcrc_info_bit13 ; 
wire[31:0]                  dcrc_info_bit2  ; 
wire[31:0]                  dcrc_info_bit3  ; 
wire[31:0]                  dcrc_info_bit4  ; 
wire[31:0]                  dcrc_info_bit5  ; 
wire[31:0]                  dcrc_info_bit6  ; 
wire[31:0]                  dcrc_info_bit7  ; 
wire[31:0]                  dcrc_info_bit8  ; 
wire[31:0]                  dcrc_info_bit9  ;

wire[31:0]                  jump_type0      ; 
wire[31:0]                  jump_type1      ; 
wire[31:0]                  jump_type10     ; 
wire[31:0]                  jump_type11     ; 
wire[31:0]                  jump_type12     ; 
wire[31:0]                  jump_type13     ; 
wire[31:0]                  jump_type14     ; 
wire[31:0]                  jump_type15     ; 
wire[31:0]                  jump_type16     ; 
wire[31:0]                  jump_type17     ; 
wire[31:0]                  jump_type18     ; 
wire[31:0]                  jump_type19     ; 
wire[31:0]                  jump_type2      ; 
wire[31:0]                  jump_type20     ; 
wire[31:0]                  jump_type21     ; 
wire[31:0]                  jump_type22     ; 
wire[31:0]                  jump_type23     ; 
wire[31:0]                  jump_type24     ; 
wire[31:0]                  jump_type25     ; 
wire[31:0]                  jump_type26     ; 
wire[31:0]                  jump_type27     ; 
wire[31:0]                  jump_type28     ; 
wire[31:0]                  jump_type29     ; 
wire[31:0]                  jump_type3      ; 
wire[31:0]                  jump_type30     ; 
wire[31:0]                  jump_type31     ; 
wire[31:0]                  jump_type32     ; 
wire[31:0]                  jump_type33     ; 
wire[31:0]                  jump_type34     ; 
wire[31:0]                  jump_type35     ; 
wire[31:0]                  jump_type36     ; 
wire[31:0]                  jump_type37     ; 
wire[31:0]                  jump_type38     ; 
wire[31:0]                  jump_type39     ; 
wire[31:0]                  jump_type4      ; 
wire[31:0]                  jump_type40     ; 
wire[31:0]                  jump_type41     ; 
wire[31:0]                  jump_type42     ; 
wire[31:0]                  jump_type43     ; 
wire[31:0]                  jump_type44     ; 
wire[31:0]                  jump_type45     ; 
wire[31:0]                  jump_type46     ; 
wire[31:0]                  jump_type47     ; 
wire[31:0]                  jump_type48     ; 
wire[31:0]                  jump_type49     ; 
wire[31:0]                  jump_type5      ; 
wire[31:0]                  jump_type50     ; 
wire[31:0]                  jump_type51     ; 
wire[31:0]                  jump_type52     ; 
wire[31:0]                  jump_type53     ; 
wire[31:0]                  jump_type54     ; 
wire[31:0]                  jump_type55     ; 
wire[31:0]                  jump_type56     ; 
wire[31:0]                  jump_type57     ; 
wire[31:0]                  jump_type58     ; 
wire[31:0]                  jump_type59     ; 
wire[31:0]                  jump_type6      ; 
wire[31:0]                  jump_type60     ; 
wire[31:0]                  jump_type61     ; 
wire[31:0]                  jump_type62     ; 
wire[31:0]                  jump_type63     ; 
wire[31:0]                  jump_type64     ; 
wire[31:0]                  jump_type65     ; 
wire[31:0]                  jump_type66     ; 
wire[31:0]                  jump_type67     ; 
wire[31:0]                  jump_type68     ; 
wire[31:0]                  jump_type69     ; 
wire[31:0]                  jump_type7      ; 
wire[31:0]                  jump_type70     ; 
wire[31:0]                  jump_type71     ; 
wire[31:0]                  jump_type72     ; 
wire[31:0]                  jump_type73     ; 
wire[31:0]                  jump_type74     ; 
wire[31:0]                  jump_type75     ; 
wire[31:0]                  jump_type76     ; 
wire[31:0]                  jump_type77     ; 
wire[31:0]                  jump_type78     ; 
wire[31:0]                  jump_type79     ; 
wire[31:0]                  jump_type8      ; 
wire[31:0]                  jump_type80     ; 
wire[31:0]                  jump_type81     ; 
wire[31:0]                  jump_type82     ; 
wire[31:0]                  jump_type83     ; 
wire[31:0]                  jump_type84     ; 
wire[31:0]                  jump_type85     ; 
wire[31:0]                  jump_type86     ; 
wire[31:0]                  jump_type87     ; 
wire[31:0]                  jump_type88     ; 
wire[31:0]                  jump_type89     ; 
wire[31:0]                  jump_type9      ; 
wire[31:0]                  jump_type90     ; 
wire[31:0]                  jump_type91     ; 
wire[31:0]                  jump_type92     ; 
wire[31:0]                  jump_type93     ; 
wire[31:0]                  jump_type94     ; 
wire[25:0]                  jump_type95     ;

wire[31:0]                  il_pattern0     ; 
wire[31:0]                  il_pattern1     ; 
wire[31:0]                  il_pattern2     ; 
wire[31:0]                  il_pattern3     ; 
wire[31:0]                  il_pattern4     ; 
wire[31:0]                  il_pattern5     ; 
wire[31:0]                  il_pattern6     ; 
wire[31:0]                  il_pattern7     ; 
wire[31:0]                  il_pattern8     ; 
wire[31:0]                  il_pattern9     ; 
wire[31:0]                  il_pattern10    ; 
wire[31:0]                  il_pattern11    ; 
wire[31:0]                  il_pattern12    ; 
wire[31:0]                  il_pattern13    ; 
wire[31:0]                  il_pattern14    ; 
wire[31:0]                  il_pattern15    ; 
wire[31:0]                  il_pattern16    ; 
wire[31:0]                  il_pattern17    ; 
wire[31:0]                  il_pattern18    ; 
wire[31:0]                  il_pattern19    ; 
wire[31:0]                  il_pattern20    ; 
wire[31:0]                  il_pattern21    ; 
wire[31:0]                  il_pattern22    ; 
wire[31:0]                  il_pattern23    ; 
wire[31:0]                  il_pattern24    ; 
wire[31:0]                  il_pattern25    ; 
wire[31:0]                  il_pattern26    ; 
wire[31:0]                  il_pattern27    ; 
wire[31:0]                  il_pattern28    ; 
wire[31:0]                  il_pattern29    ; 
wire[31:0]                  il_pattern30    ; 
wire[31:0]                  il_pattern31    ; 
wire[31:0]                  il_pattern32    ; 
wire[31:0]                  il_pattern33    ; 
wire[31:0]                  il_pattern34    ; 
wire[31:0]                  il_pattern35    ; 
wire[31:0]                  il_pattern36    ; 
wire[31:0]                  il_pattern37    ; 
wire[31:0]                  il_pattern38    ; 
wire[31:0]                  il_pattern39    ; 
wire[31:0]                  il_pattern40    ; 

reg [31:0]                  base_addr_r     ;
reg [WID_PARA_ADDR-1:0]     dma_rvalid_cnt  ;
reg                         para_wen        ; 
reg [WID_PARA_ADDR-1:0]     para_waddr      ; 
wire[31:0]                  para_wdata      ; 
wire[31:0]                  rdata_hg_nc     ;
//=============================================
//====          
//=============================================
assign jump_type     = {jump_type95,jump_type94,jump_type93,jump_type92,jump_type91,jump_type90,
                        jump_type89,jump_type88,jump_type87,jump_type86,jump_type85,jump_type84,
                        jump_type83,jump_type82,jump_type81,jump_type80,jump_type79,jump_type78,
                        jump_type77,jump_type76,jump_type75,jump_type74,jump_type73,jump_type72,
                        jump_type71,jump_type70,jump_type69,jump_type68,jump_type67,jump_type66,
                        jump_type65,jump_type64,jump_type63,jump_type62,jump_type61,jump_type60,
                        jump_type59,jump_type58,jump_type57,jump_type56,jump_type55,jump_type54,
                        jump_type53,jump_type52,jump_type51,jump_type50,jump_type49,jump_type48,
                        jump_type47,jump_type46,jump_type45,jump_type44,jump_type43,jump_type42,
                        jump_type41,jump_type40,jump_type39,jump_type38,jump_type37,jump_type36,
                        jump_type35,jump_type34,jump_type33,jump_type32,jump_type31,jump_type30,
                        jump_type29,jump_type28,jump_type27,jump_type26,jump_type25,jump_type24,
                        jump_type23,jump_type22,jump_type21,jump_type20,jump_type19,jump_type18,
                        jump_type17,jump_type16,jump_type15,jump_type14,jump_type13,jump_type12,
                        jump_type11,jump_type10,jump_type9 ,jump_type8 ,jump_type7 ,jump_type6 ,
                        jump_type5 ,jump_type4 ,jump_type3 ,jump_type2 ,jump_type1 ,jump_type0 };

assign il_pattern    = {             il_pattern40,il_pattern39,il_pattern38,il_pattern37,il_pattern36,
                        il_pattern35,il_pattern34,il_pattern33,il_pattern32,il_pattern31,il_pattern30,
                        il_pattern29,il_pattern28,il_pattern27,il_pattern26,il_pattern25,il_pattern24,
                        il_pattern23,il_pattern22,il_pattern21,il_pattern20,il_pattern19,il_pattern18,
                        il_pattern17,il_pattern16,il_pattern15,il_pattern14,il_pattern13,il_pattern12,
                        il_pattern11,il_pattern10,il_pattern9 ,il_pattern8 ,il_pattern7 ,il_pattern6 ,
                        il_pattern5 ,il_pattern4 ,il_pattern3 ,il_pattern2 ,il_pattern1 ,il_pattern0 };

assign dcrc_info_bit = { dcrc_info_bit13,dcrc_info_bit12,
                         dcrc_info_bit11,dcrc_info_bit10,dcrc_info_bit9 ,dcrc_info_bit8 ,dcrc_info_bit7 ,dcrc_info_bit6,
                         dcrc_info_bit5 ,dcrc_info_bit4 ,dcrc_info_bit3 ,dcrc_info_bit2 ,dcrc_info_bit1 ,dcrc_info_bit0};
  
assign param_n       = {1'b0,param_n_pre};
//=============================================
//====       dma control
//=============================================
assign dma_valid    = ctrl2cfg_ftch_st ; 
assign dma_src_addr = dma_valid ? pdec_base_addr : 32'd0;

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    dma_rvalid_cnt <= {WID_PARA_ADDR{1'b0}};
  else if(ctrl2cfg_ftch_st)  
    dma_rvalid_cnt <= {WID_PARA_ADDR{1'b0}};
  else if(dma_rvalid)
    dma_rvalid_cnt <= dma_rvalid_cnt + 1'b1;
end

assign para_wen   = dma_rvalid    ;
assign para_waddr = dma_rvalid_cnt;
assign para_wdata = dma_rdata     ;

assign cfg2ctrl_ftch_done0 = para_wen & (para_waddr == 6'd60);
assign cfg2ctrl_ftch_done2 = para_wen & (para_waddr == 7'd108);
assign cfg2ctrl_ftch_done1 = dma_done;
//=============================================
//====       pdec_reg_dyn
//=============================================
pdec_reg_dyn_cch
U_pdec_reg_dyn(
// Outputs
.rdata                   (rdata_hg_nc                                ) ,
.rnti_num                (rnti_num                                   ) ,
.crc_flag                (crc_flag                                   ) ,
.list_num                (list_num                                   ) ,
.rm_mode                 (rm_mode                                    ) ,
.leaf_mode               (leaf_mode                                  ) ,
.param_a                 (param_a                                    ) ,
.param_k                 (param_k                                    ) ,
.param_n                 (param_n_pre                                ) ,
.dcrc_info_idx           (dcrc_info_idx                              ) ,
.dcrc_mode               (dcrc_mode                                  ) ,
.dcrc_reg_ini            (dcrc_reg_ini                               ) ,
.dcrc_num                (dcrc_num                                   ) ,
.dcrc_info_bit0          (dcrc_info_bit0                             ) ,
.dcrc_info_bit1          (dcrc_info_bit1                             ) ,
.dcrc_info_bit2          (dcrc_info_bit2                             ) ,
.dcrc_info_bit3          (dcrc_info_bit3                             ) ,
.dcrc_info_bit4          (dcrc_info_bit4                             ) ,
.dcrc_info_bit5          (dcrc_info_bit5                             ) ,
.dcrc_info_bit6          (dcrc_info_bit6                             ) ,
.dcrc_info_bit7          (dcrc_info_bit7                             ) ,
.dcrc_info_bit8          (dcrc_info_bit8                             ) ,
.dcrc_info_bit9          (dcrc_info_bit9                             ) ,
.dcrc_info_bit10         (dcrc_info_bit10                            ) ,
.dcrc_info_bit11         (dcrc_info_bit11                            ) ,
.dcrc_info_bit12         (dcrc_info_bit12                            ) ,
.dcrc_info_bit13         (dcrc_info_bit13                            ) ,
.rnti_val1               (rnti_val1                                  ) ,
.rnti_val0               (rnti_val0                                  ) ,
.rnti_val3               (rnti_val3                                  ) ,
.rnti_val2               (rnti_val2                                  ) ,
.il_pattern0             (il_pattern0                                ) ,
.il_pattern1             (il_pattern1                                ) ,
.il_pattern2             (il_pattern2                                ) ,
.il_pattern3             (il_pattern3                                ) ,
.il_pattern4             (il_pattern4                                ) ,
.il_pattern5             (il_pattern5                                ) ,
.il_pattern6             (il_pattern6                                ) ,
.il_pattern7             (il_pattern7                                ) ,
.il_pattern8             (il_pattern8                                ) ,
.il_pattern9             (il_pattern9                                ) ,
.il_pattern10            (il_pattern10                               ) ,
.il_pattern11            (il_pattern11                               ) ,
.il_pattern12            (il_pattern12                               ) ,
.il_pattern13            (il_pattern13                               ) ,
.il_pattern14            (il_pattern14                               ) ,
.il_pattern15            (il_pattern15                               ) ,
.il_pattern16            (il_pattern16                               ) ,
.il_pattern17            (il_pattern17                               ) ,
.il_pattern18            (il_pattern18                               ) ,
.il_pattern19            (il_pattern19                               ) ,
.il_pattern20            (il_pattern20                               ) ,
.il_pattern21            (il_pattern21                               ) ,
.il_pattern22            (il_pattern22                               ) ,
.il_pattern23            (il_pattern23                               ) ,
.il_pattern24            (il_pattern24                               ) ,
.il_pattern25            (il_pattern25                               ) ,
.il_pattern26            (il_pattern26                               ) ,
.il_pattern27            (il_pattern27                               ) ,
.il_pattern28            (il_pattern28                               ) ,
.il_pattern29            (il_pattern29                               ) ,
.il_pattern30            (il_pattern30                               ) ,
.il_pattern31            (il_pattern31                               ) ,
.il_pattern32            (il_pattern32                               ) ,
.il_pattern33            (il_pattern33                               ) ,
.il_pattern34            (il_pattern34                               ) ,
.il_pattern35            (il_pattern35                               ) ,
.il_pattern36            (il_pattern36                               ) ,
.il_pattern37            (il_pattern37                               ) ,
.il_pattern38            (il_pattern38                               ) ,
.il_pattern39            (il_pattern39                               ) ,
.il_pattern40            (il_pattern40                               ) ,
.jump_type0              (jump_type0[32-1:0]                         ) ,
.jump_type1              (jump_type1[32-1:0]                         ) ,
.jump_type2              (jump_type2[32-1:0]                         ) ,
.jump_type3              (jump_type3[32-1:0]                         ) ,
.jump_type4              (jump_type4[32-1:0]                         ) ,
.jump_type5              (jump_type5[32-1:0]                         ) ,
.jump_type6              (jump_type6[32-1:0]                         ) ,
.jump_type7              (jump_type7[32-1:0]                         ) ,
.jump_type8              (jump_type8[32-1:0]                         ) ,
.jump_type9              (jump_type9[32-1:0]                         ) ,
.jump_type10             (jump_type10[32-1:0]                        ) ,
.jump_type11             (jump_type11[32-1:0]                        ) ,
.jump_type12             (jump_type12[32-1:0]                        ) ,
.jump_type13             (jump_type13[32-1:0]                        ) ,
.jump_type14             (jump_type14[32-1:0]                        ) ,
.jump_type15             (jump_type15[32-1:0]                        ) ,
.jump_type16             (jump_type16[32-1:0]                        ) ,
.jump_type17             (jump_type17[32-1:0]                        ) ,
.jump_type18             (jump_type18[32-1:0]                        ) ,
.jump_type19             (jump_type19[32-1:0]                        ) ,
.jump_type20             (jump_type20[32-1:0]                        ) ,
.jump_type21             (jump_type21[32-1:0]                        ) ,
.jump_type22             (jump_type22[32-1:0]                        ) ,
.jump_type23             (jump_type23[32-1:0]                        ) ,
.jump_type24             (jump_type24[32-1:0]                        ) ,
.jump_type25             (jump_type25[32-1:0]                        ) ,
.jump_type26             (jump_type26[32-1:0]                        ) ,
.jump_type27             (jump_type27[32-1:0]                        ) ,
.jump_type28             (jump_type28[32-1:0]                        ) ,
.jump_type29             (jump_type29[32-1:0]                        ) ,
.jump_type30             (jump_type30[32-1:0]                        ) ,
.jump_type31             (jump_type31[32-1:0]                        ) ,
.jump_type32             (jump_type32[32-1:0]                        ) ,
.jump_type33             (jump_type33[32-1:0]                        ) ,
.jump_type34             (jump_type34[32-1:0]                        ) ,
.jump_type35             (jump_type35[32-1:0]                        ) ,
.jump_type36             (jump_type36[32-1:0]                        ) ,
.jump_type37             (jump_type37[32-1:0]                        ) ,
.jump_type38             (jump_type38[32-1:0]                        ) ,
.jump_type39             (jump_type39[32-1:0]                        ) ,
.jump_type40             (jump_type40[32-1:0]                        ) ,
.jump_type41             (jump_type41[32-1:0]                        ) ,
.jump_type42             (jump_type42[32-1:0]                        ) ,
.jump_type43             (jump_type43[32-1:0]                        ) ,
.jump_type44             (jump_type44[32-1:0]                        ) ,
.jump_type45             (jump_type45[32-1:0]                        ) ,
.jump_type46             (jump_type46[32-1:0]                        ) ,
.jump_type47             (jump_type47[32-1:0]                        ) ,
.jump_type48             (jump_type48[32-1:0]                        ) ,
.jump_type49             (jump_type49[32-1:0]                        ) ,
.jump_type50             (jump_type50[32-1:0]                        ) ,
.jump_type51             (jump_type51[32-1:0]                        ) ,
.jump_type52             (jump_type52[32-1:0]                        ) ,
.jump_type53             (jump_type53[32-1:0]                        ) ,
.jump_type54             (jump_type54[32-1:0]                        ) ,
.jump_type55             (jump_type55[32-1:0]                        ) ,
.jump_type56             (jump_type56[32-1:0]                        ) ,
.jump_type57             (jump_type57[32-1:0]                        ) ,
.jump_type58             (jump_type58[32-1:0]                        ) ,
.jump_type59             (jump_type59[32-1:0]                        ) ,
.jump_type60             (jump_type60[32-1:0]                        ) ,
.jump_type61             (jump_type61[32-1:0]                        ) ,
.jump_type62             (jump_type62[32-1:0]                        ) ,
.jump_type63             (jump_type63[32-1:0]                        ) ,
.jump_type64             (jump_type64[32-1:0]                        ) ,
.jump_type65             (jump_type65[32-1:0]                        ) ,
.jump_type66             (jump_type66[32-1:0]                        ) ,
.jump_type67             (jump_type67[32-1:0]                        ) ,
.jump_type68             (jump_type68[32-1:0]                        ) ,
.jump_type69             (jump_type69[32-1:0]                        ) ,
.jump_type70             (jump_type70[32-1:0]                        ) ,
.jump_type71             (jump_type71[32-1:0]                        ) ,
.jump_type72             (jump_type72[32-1:0]                        ) ,
.jump_type73             (jump_type73[32-1:0]                        ) ,
.jump_type74             (jump_type74[32-1:0]                        ) ,
.jump_type75             (jump_type75[32-1:0]                        ) ,
.jump_type76             (jump_type76[32-1:0]                        ) ,
.jump_type77             (jump_type77[32-1:0]                        ) ,
.jump_type78             (jump_type78[32-1:0]                        ) ,
.jump_type79             (jump_type79[32-1:0]                        ) ,
.jump_type80             (jump_type80[32-1:0]                        ) ,
.jump_type81             (jump_type81[32-1:0]                        ) ,
.jump_type82             (jump_type82[32-1:0]                        ) ,
.jump_type83             (jump_type83[32-1:0]                        ) ,
.jump_type84             (jump_type84[32-1:0]                        ) ,
.jump_type85             (jump_type85[32-1:0]                        ) ,
.jump_type86             (jump_type86[32-1:0]                        ) ,
.jump_type87             (jump_type87[32-1:0]                        ) ,
.jump_type88             (jump_type88[32-1:0]                        ) ,
.jump_type89             (jump_type89[32-1:0]                        ) ,
.jump_type90             (jump_type90[32-1:0]                        ) ,
.jump_type91             (jump_type91[32-1:0]                        ) ,
.jump_type92             (jump_type92[32-1:0]                        ) ,
.jump_type93             (jump_type93[32-1:0]                        ) ,
.jump_type94             (jump_type94[32-1:0]                        ) ,
.jump_type95             (jump_type95[26-1:0]                        ) ,
// Inputs
.rst_n                   (rst_n                                      ) ,
.clk                     (clk                                        ) ,
.wen                     (para_wen                                   ) ,
.ren                     (1'b0                                       ) ,
.waddr                   ({{30-WID_PARA_ADDR{1'b0}},para_waddr,2'd0} ) ,
.raddr                   (32'd0                                      ) ,
.wdata                   (para_wdata[32-1:0]                         ) ) ;
//=============================================
//====       ICG
//=============================================
reg cfg_proc;
always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    cfg_proc <= 1'b0;
  else if(ctrl2cfg_ftch_st)  
    cfg_proc <= 1'b1;
  else if(cfg2ctrl_ftch_done1)  
    cfg_proc <= 1'b0;
end    

assign pdec_clk_en8 = ctrl2cfg_ftch_st |
                      cfg_proc         ;

endmodule
//Local Variables:
//verilog-library-flags:("-y ./ -y ../reg/ -y dir -y otherdir -y ./inc_dir/")
//verilog-auto-inst-param-value:t
//End:

