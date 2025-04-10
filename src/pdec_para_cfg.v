

`timescale 1ns/10ps

module pdec_para_cfg#(
  parameter                          ADDR_WIDTH    = 32       , 
  parameter                          DATA_WIDTH    = 32       , 
  parameter                          PARA_NUM      = 155      , 
  parameter                          WID_PARA_ADDR = 7        , 
  parameter                          NUM_K         = 164      , 
  parameter                          WID_K         = 8        ,
  parameter                          NUM_NODE      = 1022     , 
  parameter                          NUM_DCRC_INFO = 143      ,
  parameter                          PDEC_CFG_VER  = 16'h0000  
  )(
  //----clk and reset
  input  wire                        clk                      , 
  input  wire                        rst_n                    , 
  //----ICG
  output wire                        pdec_clk_en8             ,
  //----apb interface
  input  wire                        pdec_psel                , 
  input  wire                        pdec_pwrite              , 
  input  wire                        pdec_penable             , 
  input  wire[ADDR_WIDTH-1:0]        pdec_paddr               , 
  input  wire[DATA_WIDTH-1:0]        pdec_pwdata              , 
  output wire[DATA_WIDTH-1:0]        pdec_prdata              , 
  output wire                        pdec_pready              , 
  output wire                        pdec_pslverr             , 
  //----pdec_sram_top interface
  output wire[2-1:0]                 para_ren                 , 
  output wire[WID_PARA_ADDR-1:0]     para_raddr               , 
  input  wire[31:0]                  para_rdata               , //delay para_ren 2 cycle
  //----pdec_top interface
  input  wire                        ctrl2cfg_ftch_st         , 
  output wire                        cfg2ctrl_ftch_done0      , 
  output wire                        cfg2ctrl_ftch_done1      , 
  output wire                        cfg2ctrl_ftch_done2      , 
  input  wire[31:0]                  pdec_debug_info          , 
  input  wire                        dec_rpt_int              , 
  input  wire                        drm_sram_int             , 
  input  wire[31:0]                  pdec_head_info           , 
  
  //----cfg para
  output wire                        pdec_st_w1p              ,
  output wire                        pdec_soft_rst            ,
  output wire [1:0]                  list_num                 , 

  output wire                        icg_mode                 , 
  output wire                        icg_sw_en                , 
  output wire                        intr_group_0             , 

  //----dyn para
  output wire[WID_K-1:0]             param_a                  ,//type0 
  output wire[WID_K-1:0]             param_k                  , 
  output wire                        leaf_mode                , 
  output wire[1:0]                   dcrc_num                 , 
  
  output wire[2:0]                   param_n                  ,//type1 
  output wire[3*NUM_NODE-1:0]        jump_type                ,
  
  output wire[WID_K*NUM_K-1:0]       il_pattern               ,//type2
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
`ifdef PDEC_BD
  genvar                      ii              ;
  genvar                      jj              ;
  wire[31:0]                  jump_type_bd_0  ;   
  wire[31:0]                  jump_type_bd_1  ;
  wire[31:0]                  jump_type_bd_2  ;
  wire[31:0]                  jump_type_bd_3  ;
  wire[31:0]                  jump_type_bd_4  ;
  wire[31:0]                  jump_type_bd_5  ;
  wire[31:0]                  jump_type_bd_6  ;
  wire[31:0]                  jump_type_bd_7  ;
  wire[31:0]                  jump_type_bd_8  ;
  wire[31:0]                  jump_type_bd_9  ;
  wire[31:0]                  jump_type_bd_10 ; 
  wire[31:0]                  jump_type_bd_11 ; 
  wire[31:0]                  jump_type_bd_12 ;
  wire[31:0]                  jump_type_bd_13 ;
  wire[31:0]                  jump_type_bd_14 ;
  wire[31:0]                  jump_type_bd_15 ;
  wire[31:0]                  jump_type_bd_16 ;
  wire[31:0]                  jump_type_bd_17 ;
  wire[31:0]                  jump_type_bd_18 ;
  wire[31:0]                  jump_type_bd_19 ;
  wire[31:0]                  jump_type_bd_20 ;
  wire[31:0]                  jump_type_bd_21 ;
  wire[31:0]                  jump_type_bd_22 ;
  wire[31:0]                  jump_type_bd_23 ;
  wire[31:0]                  jump_type_bd_24 ;
  wire[31:0]                  jump_type_bd_25 ;
  wire[31:0]                  jump_type_bd_26 ;
  wire[31:0]                  jump_type_bd_27 ;
  wire[31:0]                  jump_type_bd_28 ;
  wire[31:0]                  jump_type_bd_29 ;
  wire[31:0]                  jump_type_bd_30 ;
  wire[31:0]                  jump_type_bd_31 ;
  wire[31:0]                  jump_type_bd_32 ;
  wire[31:0]                  jump_type_bd_33 ;
  wire[31:0]                  jump_type_bd_34 ;
  wire[31:0]                  jump_type_bd_35 ;
  wire[31:0]                  jump_type_bd_36 ;
  wire[31:0]                  jump_type_bd_37 ;
  wire[31:0]                  jump_type_bd_38 ;
  wire[31:0]                  jump_type_bd_39 ;
  wire[31:0]                  jump_type_bd_40 ;
  wire[31:0]                  jump_type_bd_41 ;
  wire[31:0]                  jump_type_bd_42 ;
  wire[31:0]                  jump_type_bd_43 ;
  wire[31:0]                  jump_type_bd_44 ;
  wire[31:0]                  jump_type_bd_45 ;
  wire[31:0]                  jump_type_bd_46 ;
  wire[31:0]                  jump_type_bd_47 ;
  wire[31:0]                  jump_type_bd_48 ;
  wire[31:0]                  jump_type_bd_49 ;
  wire[31:0]                  jump_type_bd_50 ;
  wire[31:0]                  jump_type_bd_51 ;
  wire[31:0]                  jump_type_bd_52 ;
  wire[31:0]                  jump_type_bd_53 ;
  wire[31:0]                  jump_type_bd_54 ;
  wire[31:0]                  jump_type_bd_55 ;
  wire[31:0]                  jump_type_bd_56 ;
  wire[31:0]                  jump_type_bd_57 ;
  wire[31:0]                  jump_type_bd_58 ;
  wire[31:0]                  jump_type_bd_59 ;
  wire[31:0]                  jump_type_bd_60 ;
  wire[31:0]                  jump_type_bd_61 ;
  wire[31:0]                  jump_type_bd_62 ;
  wire[31:0]                  jump_type_bd_63 ;
  wire[31:0]                  jump_type_bd_64 ;
  wire[31:0]                  jump_type_bd_65 ;
  wire[31:0]                  jump_type_bd_66 ;
  wire[31:0]                  jump_type_bd_67 ;
  wire[31:0]                  jump_type_bd_68 ;
  wire[31:0]                  jump_type_bd_69 ;
  wire[31:0]                  jump_type_bd_70 ;
  wire[31:0]                  jump_type_bd_71 ;
  wire[31:0]                  jump_type_bd_72 ;
  wire[31:0]                  jump_type_bd_73 ;
  wire[31:0]                  jump_type_bd_74 ;
  wire[31:0]                  jump_type_bd_75 ;
  wire[31:0]                  jump_type_bd_76 ;
  wire[31:0]                  jump_type_bd_77 ;
  wire[31:0]                  jump_type_bd_78 ;
  wire[31:0]                  jump_type_bd_79 ;
  wire[31:0]                  jump_type_bd_80 ;
  wire[31:0]                  jump_type_bd_81 ;
  wire[31:0]                  jump_type_bd_82 ;
  wire[31:0]                  jump_type_bd_83 ;
  wire[31:0]                  jump_type_bd_84 ;
  wire[31:0]                  jump_type_bd_85 ;
  wire[31:0]                  jump_type_bd_86 ;
  wire[31:0]                  jump_type_bd_87 ;
  wire[31:0]                  jump_type_bd_88 ;
  wire[31:0]                  jump_type_bd_89 ;
  wire[31:0]                  jump_type_bd_90 ;
  wire[31:0]                  jump_type_bd_91 ;
  wire[31:0]                  jump_type_bd_92 ;
  wire[31:0]                  jump_type_bd_93 ;
  wire[31:0]                  jump_type_bd_94 ;
  wire[31:0]                  jump_type_bd_95 ;
  wire[31:0]                  jump_type_bd_96 ;
  wire[31:0]                  jump_type_bd_97 ;
  wire[31:0]                  jump_type_bd_98 ;
  wire[31:0]                  jump_type_bd_99 ;
  wire[31:0]                  jump_type_bd_100;
  wire[31:0]                  jump_type_bd_101;
  wire[31:0]                  jump_type_bd_102;
  wire[31:0]                  jump_type_bd_103;
  wire[31:0]                  jump_type_bd_104;
  wire[31:0]                  jump_type_bd_105;
  wire[31:0]                  jump_type_bd_106;
  wire[31:0]                  jump_type_bd_107;
  wire[31:0]                  jump_type_bd_108;
  wire[31:0]                  jump_type_bd_109;
  wire[31:0]                  jump_type_bd_110;
  wire[31:0]                  jump_type_bd_111;
  wire[31:0]                  jump_type_bd_112;
  wire[31:0]                  jump_type_bd_113;
  wire[31:0]                  jump_type_bd_114;
  wire[31:0]                  jump_type_bd_115;
  wire[31:0]                  jump_type_bd_116;
  wire[31:0]                  jump_type_bd_117;
  wire[31:0]                  jump_type_bd_118;
  wire[31:0]                  jump_type_bd_119;
  wire[31:0]                  jump_type_bd_120;
  wire[31:0]                  jump_type_bd_121;
  wire[31:0]                  jump_type_bd_122;
  wire[31:0]                  jump_type_bd_123;
  wire[31:0]                  jump_type_bd_124;
  wire[31:0]                  jump_type_bd_125;
  wire[31:0]                  jump_type_bd_126;
  wire[31:0]                  jump_type_bd_127;
  wire[31:0]                  jump_type_bd_128;
  wire[31:0]                  jump_type_bd_129;
  wire[31:0]                  jump_type_bd_130;
  wire[31:0]                  jump_type_bd_131;
  wire[31:0]                  jump_type_bd_132;
  wire[31:0]                  jump_type_bd_133;
  wire[31:0]                  jump_type_bd_134;
  wire[31:0]                  jump_type_bd_135;
  wire[31:0]                  jump_type_bd_136;
  wire[31:0]                  jump_type_bd_137;
  wire[31:0]                  jump_type_bd_138;
  wire[31:0]                  jump_type_bd_139;
  wire[31:0]                  jump_type_bd_140;
  wire[31:0]                  jump_type_bd_141;
  wire[31:0]                  jump_type_bd_142;
  wire[31:0]                  jump_type_bd_143;
  wire[31:0]                  jump_type_bd_144;
  wire[31:0]                  jump_type_bd_145;
  wire[31:0]                  jump_type_bd_146;
  wire[31:0]                  jump_type_bd_147;
  wire[31:0]                  jump_type_bd_148;
  wire[31:0]                  jump_type_bd_149;
  wire[31:0]                  jump_type_bd_150;
  wire[31:0]                  jump_type_bd_151;
  wire[31:0]                  jump_type_bd_152;
  wire[31:0]                  jump_type_bd_153;
  wire[31:0]                  jump_type_bd_154;
  wire[31:0]                  jump_type_bd_155;
  wire[31:0]                  jump_type_bd_156;
  wire[31:0]                  jump_type_bd_157;
  wire[31:0]                  jump_type_bd_158;
  wire[31:0]                  jump_type_bd_159;
  wire[31:0]                  jump_type_bd_160;
  wire[31:0]                  jump_type_bd_161;
  wire[31:0]                  jump_type_bd_162;
  wire[31:0]                  jump_type_bd_163;
  wire[31:0]                  jump_type_bd_164;
  wire[31:0]                  jump_type_bd_165;
  wire[31:0]                  jump_type_bd_166;
  wire[31:0]                  jump_type_bd_167;
  wire[31:0]                  jump_type_bd_168;
  wire[31:0]                  jump_type_bd_169;
  wire[31:0]                  jump_type_bd_170;
  wire[31:0]                  jump_type_bd_171;
  wire[31:0]                  jump_type_bd_172;
  wire[31:0]                  jump_type_bd_173;
  wire[31:0]                  jump_type_bd_174;
  wire[31:0]                  jump_type_bd_175;
  wire[31:0]                  jump_type_bd_176;
  wire[31:0]                  jump_type_bd_177;
  wire[31:0]                  jump_type_bd_178;
  wire[31:0]                  jump_type_bd_179;
  wire[31:0]                  jump_type_bd_180;
  wire[31:0]                  jump_type_bd_181;
  wire[31:0]                  jump_type_bd_182;
  wire[31:0]                  jump_type_bd_183;
  wire[31:0]                  jump_type_bd_184;
  wire[31:0]                  jump_type_bd_185;
  wire[31:0]                  jump_type_bd_186;
  wire[31:0]                  jump_type_bd_187;
  wire[31:0]                  jump_type_bd_188;
  wire[31:0]                  jump_type_bd_189;
  wire[31:0]                  jump_type_bd_190;
  wire[31:0]                  jump_type_bd_191;
  wire[31:0]                  jump_type_bd_192;
  wire[31:0]                  jump_type_bd_193;
  wire[31:0]                  jump_type_bd_194;
  wire[31:0]                  jump_type_bd_195;
  wire[31:0]                  jump_type_bd_196;
  wire[31:0]                  jump_type_bd_197;
  wire[31:0]                  jump_type_bd_198;
  wire[31:0]                  jump_type_bd_199;
  wire[31:0]                  jump_type_bd_200;
  wire[31:0]                  jump_type_bd_201;
  wire[31:0]                  jump_type_bd_202;
  wire[31:0]                  jump_type_bd_203;
  wire[31:0]                  jump_type_bd_204;
  wire[31:0]                  jump_type_bd_205;
  wire[31:0]                  jump_type_bd_206;
  wire[31:0]                  jump_type_bd_207;
  wire[31:0]                  jump_type_bd_208;
  wire[31:0]                  jump_type_bd_209;
  wire[31:0]                  jump_type_bd_210;
  wire[31:0]                  jump_type_bd_211;
  wire[31:0]                  jump_type_bd_212;
  wire[31:0]                  jump_type_bd_213;
  wire[31:0]                  jump_type_bd_214;
  wire[31:0]                  jump_type_bd_215;
  wire[31:0]                  jump_type_bd_216;
  wire[31:0]                  jump_type_bd_217;
  wire[31:0]                  jump_type_bd_218;
  wire[31:0]                  jump_type_bd_219;
  wire[31:0]                  jump_type_bd_220;
  wire[31:0]                  jump_type_bd_221;
  wire[31:0]                  jump_type_bd_222;
  wire[31:0]                  jump_type_bd_223;
  wire[31:0]                  jump_type_bd_224;
  wire[31:0]                  jump_type_bd_225;
  wire[31:0]                  jump_type_bd_226;
  wire[31:0]                  jump_type_bd_227;
  wire[31:0]                  jump_type_bd_228;
  wire[31:0]                  jump_type_bd_229;
  wire[31:0]                  jump_type_bd_230;
  wire[31:0]                  jump_type_bd_231;
  wire[31:0]                  jump_type_bd_232;
  wire[31:0]                  jump_type_bd_233;
  wire[31:0]                  jump_type_bd_234;
  wire[31:0]                  jump_type_bd_235;
  wire[31:0]                  jump_type_bd_236;
  wire[31:0]                  jump_type_bd_237;
  wire[31:0]                  jump_type_bd_238;
  wire[31:0]                  jump_type_bd_239;
  wire[31:0]                  jump_type_bd_240;
  wire[31:0]                  jump_type_bd_241;
  wire[31:0]                  jump_type_bd_242;
  wire[31:0]                  jump_type_bd_243;
  wire[31:0]                  jump_type_bd_244;
  wire[31:0]                  jump_type_bd_245;
  wire[31:0]                  jump_type_bd_246;
  wire[31:0]                  jump_type_bd_247;
  wire[31:0]                  jump_type_bd_248;
  wire[31:0]                  jump_type_bd_249;
  wire[31:0]                  jump_type_bd_250;
  wire[31:0]                  jump_type_bd_251;
  wire[31:0]                  jump_type_bd_252;
  wire[31:0]                  jump_type_bd_253;
  wire[31:0]                  jump_type_bd_254;
  wire[31:0]                  jump_type_bd_255;
  wire[31:0]                  jump_type_bd_256;
  wire[31:0]                  jump_type_bd_257;
  wire[31:0]                  jump_type_bd_258;
  wire[31:0]                  jump_type_bd_259;
  wire[31:0]                  jump_type_bd_260;
  wire[31:0]                  jump_type_bd_261;
  wire[31:0]                  jump_type_bd_262;
  wire[31:0]                  jump_type_bd_263;
  wire[31:0]                  jump_type_bd_264;
  wire[31:0]                  jump_type_bd_265;
  wire[31:0]                  jump_type_bd_266;
  wire[31:0]                  jump_type_bd_267;
  wire[31:0]                  jump_type_bd_268;
  wire[31:0]                  jump_type_bd_269;
  wire[31:0]                  jump_type_bd_270;
  wire[31:0]                  jump_type_bd_271;
  wire[31:0]                  jump_type_bd_272;
  wire[31:0]                  jump_type_bd_273;
  wire[31:0]                  jump_type_bd_274;
  wire[31:0]                  jump_type_bd_275;
  wire[31:0]                  jump_type_bd_276;
  wire[31:0]                  jump_type_bd_277;
  wire[31:0]                  jump_type_bd_278;
  wire[31:0]                  jump_type_bd_279;
  wire[31:0]                  jump_type_bd_280;
  wire[31:0]                  jump_type_bd_281;
  wire[31:0]                  jump_type_bd_282;
  wire[31:0]                  jump_type_bd_283;
  wire[31:0]                  jump_type_bd_284;
  wire[31:0]                  jump_type_bd_285;
  wire[31:0]                  jump_type_bd_286;
  wire[31:0]                  jump_type_bd_287;
  wire[31:0]                  jump_type_bd_288;
  wire[31:0]                  jump_type_bd_289;
  wire[31:0]                  jump_type_bd_290;
  wire[31:0]                  jump_type_bd_291;
  wire[31:0]                  jump_type_bd_292;
  wire[31:0]                  jump_type_bd_293;
  wire[31:0]                  jump_type_bd_294;
  wire[31:0]                  jump_type_bd_295;
  wire[31:0]                  jump_type_bd_296;
  wire[31:0]                  jump_type_bd_297;
  wire[31:0]                  jump_type_bd_298;
  wire[31:0]                  jump_type_bd_299;
  wire[31:0]                  jump_type_bd_300;
  wire[31:0]                  jump_type_bd_301;
  wire[31:0]                  jump_type_bd_302;
  wire[31:0]                  jump_type_bd_303;
  wire[31:0]                  jump_type_bd_304;
  wire[31:0]                  jump_type_bd_305;
  wire[31:0]                  jump_type_bd_306;
  wire[31:0]                  jump_type_bd_307;
  wire[31:0]                  jump_type_bd_308;
  wire[31:0]                  jump_type_bd_309;
  wire[31:0]                  jump_type_bd_310;
  wire[31:0]                  jump_type_bd_311;
  wire[31:0]                  jump_type_bd_312;
  wire[31:0]                  jump_type_bd_313;
  wire[31:0]                  jump_type_bd_314;
  wire[31:0]                  jump_type_bd_315;
  wire[31:0]                  jump_type_bd_316;
  wire[31:0]                  jump_type_bd_317;
  wire[31:0]                  jump_type_bd_318;
  wire[31:0]                  jump_type_bd_319;
  wire[31:0]                  jump_type_bd_320;
  wire[31:0]                  jump_type_bd_321;
  wire[31:0]                  jump_type_bd_322;
  wire[31:0]                  jump_type_bd_323;
  wire[31:0]                  jump_type_bd_324;
  wire[31:0]                  jump_type_bd_325;
  wire[31:0]                  jump_type_bd_326;
  wire[31:0]                  jump_type_bd_327;
  wire[31:0]                  jump_type_bd_328;
  wire[31:0]                  jump_type_bd_329;
  wire[31:0]                  jump_type_bd_330;
  wire[31:0]                  jump_type_bd_331;
  wire[31:0]                  jump_type_bd_332;
  wire[31:0]                  jump_type_bd_333;
  wire[31:0]                  jump_type_bd_334;
  wire[31:0]                  jump_type_bd_335;
  wire[31:0]                  jump_type_bd_336;
  wire[31:0]                  jump_type_bd_337;
  wire[31:0]                  jump_type_bd_338;
  wire[31:0]                  jump_type_bd_339;
  wire[31:0]                  jump_type_bd_340;
  wire[31:0]                  jump_type_bd_341;
  wire[31:0]                  jump_type_bd_342;
  wire[31:0]                  jump_type_bd_343;
  wire[31:0]                  jump_type_bd_344;
  wire[31:0]                  jump_type_bd_345;
  wire[31:0]                  jump_type_bd_346;
  wire[31:0]                  jump_type_bd_347;
  wire[31:0]                  jump_type_bd_348;
  wire[31:0]                  jump_type_bd_349;
  wire[31:0]                  jump_type_bd_350;
  wire[31:0]                  jump_type_bd_351;
  wire[31:0]                  jump_type_bd_352;
  wire[31:0]                  jump_type_bd_353;
  wire[31:0]                  jump_type_bd_354;
  wire[31:0]                  jump_type_bd_355;
  wire[31:0]                  jump_type_bd_356;
  wire[31:0]                  jump_type_bd_357;
  wire[31:0]                  jump_type_bd_358;
  wire[31:0]                  jump_type_bd_359;
  wire[31:0]                  jump_type_bd_360;
  wire[31:0]                  jump_type_bd_361;
  wire[31:0]                  jump_type_bd_362;
  wire[31:0]                  jump_type_bd_363;
  wire[31:0]                  jump_type_bd_364;
  wire[31:0]                  jump_type_bd_365;
  wire[31:0]                  jump_type_bd_366;
  wire[31:0]                  jump_type_bd_367;
  wire[31:0]                  jump_type_bd_368;
  wire[31:0]                  jump_type_bd_369;
  wire[31:0]                  jump_type_bd_370;
  wire[31:0]                  jump_type_bd_371;
  wire[31:0]                  jump_type_bd_372;
  wire[31:0]                  jump_type_bd_373;
  wire[31:0]                  jump_type_bd_374;
  wire[31:0]                  jump_type_bd_375;
  wire[31:0]                  jump_type_bd_376;
  wire[31:0]                  jump_type_bd_377;
  wire[31:0]                  jump_type_bd_378;
  wire[31:0]                  jump_type_bd_379;
  wire[31:0]                  jump_type_bd_380;
  wire[31:0]                  jump_type_bd_381;
  wire[31:0]                  jump_type_bd_382;
  wire[31:0]                  jump_type_bd_383;
  wire[31:0]                  jump_type_bd_384;
  wire[31:0]                  jump_type_bd_385;
  wire[31:0]                  jump_type_bd_386;
  wire[31:0]                  jump_type_bd_387;
  wire[31:0]                  jump_type_bd_388;
  wire[31:0]                  jump_type_bd_389;
  wire[31:0]                  jump_type_bd_390;
  wire[31:0]                  jump_type_bd_391;
  wire[31:0]                  jump_type_bd_392;
  wire[31:0]                  jump_type_bd_393;
  wire[31:0]                  jump_type_bd_394;
  wire[31:0]                  jump_type_bd_395;
  wire[31:0]                  jump_type_bd_396;
  wire[31:0]                  jump_type_bd_397;
  wire[31:0]                  jump_type_bd_398;
  wire[31:0]                  jump_type_bd_399;
  wire[31:0]                  jump_type_bd_400;
  wire[31:0]                  jump_type_bd_401;
  wire[31:0]                  jump_type_bd_402;
  wire[31:0]                  jump_type_bd_403;
  wire[31:0]                  jump_type_bd_404;
  wire[31:0]                  jump_type_bd_405;
  wire[31:0]                  jump_type_bd_406;
  wire[31:0]                  jump_type_bd_407;
  wire[31:0]                  jump_type_bd_408;
  wire[31:0]                  jump_type_bd_409;
  wire[31:0]                  jump_type_bd_410;
  wire[31:0]                  jump_type_bd_411;
  wire[31:0]                  jump_type_bd_412;
  wire[31:0]                  jump_type_bd_413;
  wire[31:0]                  jump_type_bd_414;
  wire[31:0]                  jump_type_bd_415;
  wire[31:0]                  jump_type_bd_416;
  wire[31:0]                  jump_type_bd_417;
  wire[31:0]                  jump_type_bd_418;
  wire[31:0]                  jump_type_bd_419;
  wire[31:0]                  jump_type_bd_420;
  wire[31:0]                  jump_type_bd_421;
  wire[31:0]                  jump_type_bd_422;
  wire[31:0]                  jump_type_bd_423;
  wire[31:0]                  jump_type_bd_424;
  wire[31:0]                  jump_type_bd_425;
  wire[31:0]                  jump_type_bd_426;
  wire[31:0]                  jump_type_bd_427;
  wire[31:0]                  jump_type_bd_428;
  wire[31:0]                  jump_type_bd_429;
  wire[31:0]                  jump_type_bd_430;
  wire[31:0]                  jump_type_bd_431;
  wire[31:0]                  jump_type_bd_432;
  wire[31:0]                  jump_type_bd_433;
  wire[31:0]                  jump_type_bd_434;
  wire[31:0]                  jump_type_bd_435;
  wire[31:0]                  jump_type_bd_436;
  wire[31:0]                  jump_type_bd_437;
  wire[31:0]                  jump_type_bd_438;
  wire[31:0]                  jump_type_bd_439;
  wire[31:0]                  jump_type_bd_440;
  wire[31:0]                  jump_type_bd_441;
  wire[31:0]                  jump_type_bd_442;
  wire[31:0]                  jump_type_bd_443;
  wire[31:0]                  jump_type_bd_444;
  wire[31:0]                  jump_type_bd_445;
  wire[31:0]                  jump_type_bd_446;
  wire[31:0]                  jump_type_bd_447;
  wire[31:0]                  jump_type_bd_448;
  wire[31:0]                  jump_type_bd_449;
  wire[31:0]                  jump_type_bd_450;
  wire[31:0]                  jump_type_bd_451;
  wire[31:0]                  jump_type_bd_452;
  wire[31:0]                  jump_type_bd_453;
  wire[31:0]                  jump_type_bd_454;
  wire[31:0]                  jump_type_bd_455;
  wire[31:0]                  jump_type_bd_456;
  wire[31:0]                  jump_type_bd_457;
  wire[31:0]                  jump_type_bd_458;
  wire[31:0]                  jump_type_bd_459;
  wire[31:0]                  jump_type_bd_460;
  wire[31:0]                  jump_type_bd_461;
  wire[31:0]                  jump_type_bd_462;
  wire[31:0]                  jump_type_bd_463;
  wire[31:0]                  jump_type_bd_464;
  wire[31:0]                  jump_type_bd_465;
  wire[31:0]                  jump_type_bd_466;
  wire[31:0]                  jump_type_bd_467;
  wire[31:0]                  jump_type_bd_468;
  wire[31:0]                  jump_type_bd_469;
  wire[31:0]                  jump_type_bd_470;
  wire[31:0]                  jump_type_bd_471;
  wire[31:0]                  jump_type_bd_472;
  wire[31:0]                  jump_type_bd_473;
  wire[31:0]                  jump_type_bd_474;
  wire[31:0]                  jump_type_bd_475;
  wire[31:0]                  jump_type_bd_476;
  wire[31:0]                  jump_type_bd_477;
  wire[31:0]                  jump_type_bd_478;
  wire[31:0]                  jump_type_bd_479;
  wire[31:0]                  jump_type_bd_480;
  wire[31:0]                  jump_type_bd_481;
  wire[31:0]                  jump_type_bd_482;
  wire[31:0]                  jump_type_bd_483;
  wire[31:0]                  jump_type_bd_484;
  wire[31:0]                  jump_type_bd_485;
  wire[31:0]                  jump_type_bd_486;
  wire[31:0]                  jump_type_bd_487;
  wire[31:0]                  jump_type_bd_488;
  wire[31:0]                  jump_type_bd_489;
  wire[31:0]                  jump_type_bd_490;
  wire[31:0]                  jump_type_bd_491;
  wire[31:0]                  jump_type_bd_492;
  wire[31:0]                  jump_type_bd_493;
  wire[31:0]                  jump_type_bd_494;
  wire[31:0]                  jump_type_bd_495;
  wire[31:0]                  jump_type_bd_496;
  wire[31:0]                  jump_type_bd_497;
  wire[31:0]                  jump_type_bd_498;
  wire[31:0]                  jump_type_bd_499;
  wire[31:0]                  jump_type_bd_500;
  wire[31:0]                  jump_type_bd_501;
  wire[31:0]                  jump_type_bd_502;
  wire[31:0]                  jump_type_bd_503;
  wire[31:0]                  jump_type_bd_504;
  wire[31:0]                  jump_type_bd_505;
  wire[31:0]                  jump_type_bd_506;
  wire[31:0]                  jump_type_bd_507;
  wire[31:0]                  jump_type_bd_508;
  wire[31:0]                  jump_type_bd_509;
  wire[31:0]                  jump_type_bd_510;
  wire[27:0]                  jump_type_bd_511;
  wire[2*NUM_NODE-1:0]        jump_type_bd_pre;
  wire[1:0]                   jump_type2_bd_mem[NUM_NODE-1:0];
  wire[WID_K-1:0]             il_pattern_mem[NUM_K-1:0]      ;

`else
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
`endif
  
wire                        pdec_type       ;
wire                        cfg_wen         ; 
wire                        cfg_ren         ; 
wire[32-1:0]                cfg_waddr       ; 
wire[32-1:0]                cfg_raddr       ; 
wire[32-1:0]                cfg_wdata       ; 
wire[32-1:0]                cfg_rdata       ; 
reg                         para_ren_pre    ; 
reg [WID_PARA_ADDR-1:0]     para_ren_cnt    ; 
wire                        para_ren0       ; 
wire                        para_ren1       ; 
reg                         para_ren_r      ; 
reg [WID_PARA_ADDR-1:0]     para_ren_cnt_r  ; 
reg                         para_wen        ; 
reg [WID_PARA_ADDR-1:0]     para_waddr      ; 
wire[31:0]                  para_wdata      ; 
wire[31:0]                  rdata_hg_nc     ;
wire[1:0]                   list_num_hg_nc  ;
//=============================================
//====          
//=============================================
`ifdef PDEC_BD
  //jump_type proc
  assign jump_type_bd_pre = {
         jump_type_bd_511,jump_type_bd_510,jump_type_bd_509,jump_type_bd_508,jump_type_bd_507,jump_type_bd_506,jump_type_bd_505,jump_type_bd_504,
         jump_type_bd_503,jump_type_bd_502,jump_type_bd_501,jump_type_bd_500,jump_type_bd_499,jump_type_bd_498,jump_type_bd_497,jump_type_bd_496,
         jump_type_bd_495,jump_type_bd_494,jump_type_bd_493,jump_type_bd_492,jump_type_bd_491,jump_type_bd_490,jump_type_bd_489,jump_type_bd_488,
         jump_type_bd_487,jump_type_bd_486,jump_type_bd_485,jump_type_bd_484,jump_type_bd_483,jump_type_bd_482,jump_type_bd_481,jump_type_bd_480,
         jump_type_bd_479,jump_type_bd_478,jump_type_bd_477,jump_type_bd_476,jump_type_bd_475,jump_type_bd_474,jump_type_bd_473,jump_type_bd_472,
         jump_type_bd_471,jump_type_bd_470,jump_type_bd_469,jump_type_bd_468,jump_type_bd_467,jump_type_bd_466,jump_type_bd_465,jump_type_bd_464,
         jump_type_bd_463,jump_type_bd_462,jump_type_bd_461,jump_type_bd_460,jump_type_bd_459,jump_type_bd_458,jump_type_bd_457,jump_type_bd_456,
         jump_type_bd_455,jump_type_bd_454,jump_type_bd_453,jump_type_bd_452,jump_type_bd_451,jump_type_bd_450,jump_type_bd_449,jump_type_bd_448,
         jump_type_bd_447,jump_type_bd_446,jump_type_bd_445,jump_type_bd_444,jump_type_bd_443,jump_type_bd_442,jump_type_bd_441,jump_type_bd_440,
         jump_type_bd_439,jump_type_bd_438,jump_type_bd_437,jump_type_bd_436,jump_type_bd_435,jump_type_bd_434,jump_type_bd_433,jump_type_bd_432,
         jump_type_bd_431,jump_type_bd_430,jump_type_bd_429,jump_type_bd_428,jump_type_bd_427,jump_type_bd_426,jump_type_bd_425,jump_type_bd_424,
         jump_type_bd_423,jump_type_bd_422,jump_type_bd_421,jump_type_bd_420,jump_type_bd_419,jump_type_bd_418,jump_type_bd_417,jump_type_bd_416,
         jump_type_bd_415,jump_type_bd_414,jump_type_bd_413,jump_type_bd_412,jump_type_bd_411,jump_type_bd_410,jump_type_bd_409,jump_type_bd_408,
         jump_type_bd_407,jump_type_bd_406,jump_type_bd_405,jump_type_bd_404,jump_type_bd_403,jump_type_bd_402,jump_type_bd_401,jump_type_bd_400,
         jump_type_bd_399,jump_type_bd_398,jump_type_bd_397,jump_type_bd_396,jump_type_bd_395,jump_type_bd_394,jump_type_bd_393,jump_type_bd_392,
         jump_type_bd_391,jump_type_bd_390,jump_type_bd_389,jump_type_bd_388,jump_type_bd_387,jump_type_bd_386,jump_type_bd_385,jump_type_bd_384,
         jump_type_bd_383,jump_type_bd_382,jump_type_bd_381,jump_type_bd_380,jump_type_bd_379,jump_type_bd_378,jump_type_bd_377,jump_type_bd_376,
         jump_type_bd_375,jump_type_bd_374,jump_type_bd_373,jump_type_bd_372,jump_type_bd_371,jump_type_bd_370,jump_type_bd_369,jump_type_bd_368,
         jump_type_bd_367,jump_type_bd_366,jump_type_bd_365,jump_type_bd_364,jump_type_bd_363,jump_type_bd_362,jump_type_bd_361,jump_type_bd_360,
         jump_type_bd_359,jump_type_bd_358,jump_type_bd_357,jump_type_bd_356,jump_type_bd_355,jump_type_bd_354,jump_type_bd_353,jump_type_bd_352,
         jump_type_bd_351,jump_type_bd_350,jump_type_bd_349,jump_type_bd_348,jump_type_bd_347,jump_type_bd_346,jump_type_bd_345,jump_type_bd_344,
         jump_type_bd_343,jump_type_bd_342,jump_type_bd_341,jump_type_bd_340,jump_type_bd_339,jump_type_bd_338,jump_type_bd_337,jump_type_bd_336,
         jump_type_bd_335,jump_type_bd_334,jump_type_bd_333,jump_type_bd_332,jump_type_bd_331,jump_type_bd_330,jump_type_bd_329,jump_type_bd_328,
         jump_type_bd_327,jump_type_bd_326,jump_type_bd_325,jump_type_bd_324,jump_type_bd_323,jump_type_bd_322,jump_type_bd_321,jump_type_bd_320,
         jump_type_bd_319,jump_type_bd_318,jump_type_bd_317,jump_type_bd_316,jump_type_bd_315,jump_type_bd_314,jump_type_bd_313,jump_type_bd_312,
         jump_type_bd_311,jump_type_bd_310,jump_type_bd_309,jump_type_bd_308,jump_type_bd_307,jump_type_bd_306,jump_type_bd_305,jump_type_bd_304,
         jump_type_bd_303,jump_type_bd_302,jump_type_bd_301,jump_type_bd_300,jump_type_bd_299,jump_type_bd_298,jump_type_bd_297,jump_type_bd_296,
         jump_type_bd_295,jump_type_bd_294,jump_type_bd_293,jump_type_bd_292,jump_type_bd_291,jump_type_bd_290,jump_type_bd_289,jump_type_bd_288,
         jump_type_bd_287,jump_type_bd_286,jump_type_bd_285,jump_type_bd_284,jump_type_bd_283,jump_type_bd_282,jump_type_bd_281,jump_type_bd_280,
         jump_type_bd_279,jump_type_bd_278,jump_type_bd_277,jump_type_bd_276,jump_type_bd_275,jump_type_bd_274,jump_type_bd_273,jump_type_bd_272,
         jump_type_bd_271,jump_type_bd_270,jump_type_bd_269,jump_type_bd_268,jump_type_bd_267,jump_type_bd_266,jump_type_bd_265,jump_type_bd_264,
         jump_type_bd_263,jump_type_bd_262,jump_type_bd_261,jump_type_bd_260,jump_type_bd_259,jump_type_bd_258,jump_type_bd_257,jump_type_bd_256,
         jump_type_bd_255,jump_type_bd_254,jump_type_bd_253,jump_type_bd_252,jump_type_bd_251,jump_type_bd_250,jump_type_bd_249,jump_type_bd_248,
         jump_type_bd_247,jump_type_bd_246,jump_type_bd_245,jump_type_bd_244,jump_type_bd_243,jump_type_bd_242,jump_type_bd_241,jump_type_bd_240,
         jump_type_bd_239,jump_type_bd_238,jump_type_bd_237,jump_type_bd_236,jump_type_bd_235,jump_type_bd_234,jump_type_bd_233,jump_type_bd_232,
         jump_type_bd_231,jump_type_bd_230,jump_type_bd_229,jump_type_bd_228,jump_type_bd_227,jump_type_bd_226,jump_type_bd_225,jump_type_bd_224,
         jump_type_bd_223,jump_type_bd_222,jump_type_bd_221,jump_type_bd_220,jump_type_bd_219,jump_type_bd_218,jump_type_bd_217,jump_type_bd_216,
         jump_type_bd_215,jump_type_bd_214,jump_type_bd_213,jump_type_bd_212,jump_type_bd_211,jump_type_bd_210,jump_type_bd_209,jump_type_bd_208,
         jump_type_bd_207,jump_type_bd_206,jump_type_bd_205,jump_type_bd_204,jump_type_bd_203,jump_type_bd_202,jump_type_bd_201,jump_type_bd_200,
         jump_type_bd_199,jump_type_bd_198,jump_type_bd_197,jump_type_bd_196,jump_type_bd_195,jump_type_bd_194,jump_type_bd_193,jump_type_bd_192,
         jump_type_bd_191,jump_type_bd_190,jump_type_bd_189,jump_type_bd_188,jump_type_bd_187,jump_type_bd_186,jump_type_bd_185,jump_type_bd_184,
         jump_type_bd_183,jump_type_bd_182,jump_type_bd_181,jump_type_bd_180,jump_type_bd_179,jump_type_bd_178,jump_type_bd_177,jump_type_bd_176,
         jump_type_bd_175,jump_type_bd_174,jump_type_bd_173,jump_type_bd_172,jump_type_bd_171,jump_type_bd_170,jump_type_bd_169,jump_type_bd_168,
         jump_type_bd_167,jump_type_bd_166,jump_type_bd_165,jump_type_bd_164,jump_type_bd_163,jump_type_bd_162,jump_type_bd_161,jump_type_bd_160,
         jump_type_bd_159,jump_type_bd_158,jump_type_bd_157,jump_type_bd_156,jump_type_bd_155,jump_type_bd_154,jump_type_bd_153,jump_type_bd_152,
         jump_type_bd_151,jump_type_bd_150,jump_type_bd_149,jump_type_bd_148,jump_type_bd_147,jump_type_bd_146,jump_type_bd_145,jump_type_bd_144,
         jump_type_bd_143,jump_type_bd_142,jump_type_bd_141,jump_type_bd_140,jump_type_bd_139,jump_type_bd_138,jump_type_bd_137,jump_type_bd_136,
         jump_type_bd_135,jump_type_bd_134,jump_type_bd_133,jump_type_bd_132,jump_type_bd_131,jump_type_bd_130,jump_type_bd_129,jump_type_bd_128,
         jump_type_bd_127,jump_type_bd_126,jump_type_bd_125,jump_type_bd_124,jump_type_bd_123,jump_type_bd_122,jump_type_bd_121,jump_type_bd_120,
         jump_type_bd_119,jump_type_bd_118,jump_type_bd_117,jump_type_bd_116,jump_type_bd_115,jump_type_bd_114,jump_type_bd_113,jump_type_bd_112,
         jump_type_bd_111,jump_type_bd_110,jump_type_bd_109,jump_type_bd_108,jump_type_bd_107,jump_type_bd_106,jump_type_bd_105,jump_type_bd_104,
         jump_type_bd_103,jump_type_bd_102,jump_type_bd_101,jump_type_bd_100,jump_type_bd_99 ,jump_type_bd_98 ,jump_type_bd_97 ,jump_type_bd_96 ,
         jump_type_bd_95 ,jump_type_bd_94 ,jump_type_bd_93 ,jump_type_bd_92 ,jump_type_bd_91 ,jump_type_bd_90 ,jump_type_bd_89 ,jump_type_bd_88 ,
         jump_type_bd_87 ,jump_type_bd_86 ,jump_type_bd_85 ,jump_type_bd_84 ,jump_type_bd_83 ,jump_type_bd_82 ,jump_type_bd_81 ,jump_type_bd_80 ,
         jump_type_bd_79 ,jump_type_bd_78 ,jump_type_bd_77 ,jump_type_bd_76 ,jump_type_bd_75 ,jump_type_bd_74 ,jump_type_bd_73 ,jump_type_bd_72 ,
         jump_type_bd_71 ,jump_type_bd_70 ,jump_type_bd_69 ,jump_type_bd_68 ,jump_type_bd_67 ,jump_type_bd_66 ,jump_type_bd_65 ,jump_type_bd_64 ,
         jump_type_bd_63 ,jump_type_bd_62 ,jump_type_bd_61 ,jump_type_bd_60 ,jump_type_bd_59 ,jump_type_bd_58 ,jump_type_bd_57 ,jump_type_bd_56 ,
         jump_type_bd_55 ,jump_type_bd_54 ,jump_type_bd_53 ,jump_type_bd_52 ,jump_type_bd_51 ,jump_type_bd_50 ,jump_type_bd_49 ,jump_type_bd_48 ,
         jump_type_bd_47 ,jump_type_bd_46 ,jump_type_bd_45 ,jump_type_bd_44 ,jump_type_bd_43 ,jump_type_bd_42 ,jump_type_bd_41 ,jump_type_bd_40 ,
         jump_type_bd_39 ,jump_type_bd_38 ,jump_type_bd_37 ,jump_type_bd_36 ,jump_type_bd_35 ,jump_type_bd_34 ,jump_type_bd_33 ,jump_type_bd_32 ,
         jump_type_bd_31 ,jump_type_bd_30 ,jump_type_bd_29 ,jump_type_bd_28 ,jump_type_bd_27 ,jump_type_bd_26 ,jump_type_bd_25 ,jump_type_bd_24 ,
         jump_type_bd_23 ,jump_type_bd_22 ,jump_type_bd_21 ,jump_type_bd_20 ,jump_type_bd_19 ,jump_type_bd_18 ,jump_type_bd_17 ,jump_type_bd_16 ,
         jump_type_bd_15 ,jump_type_bd_14 ,jump_type_bd_13 ,jump_type_bd_12 ,jump_type_bd_11 ,jump_type_bd_10 ,jump_type_bd_9  ,jump_type_bd_8  ,
         jump_type_bd_7  ,jump_type_bd_6  ,jump_type_bd_5  ,jump_type_bd_4  ,jump_type_bd_3  ,jump_type_bd_2  ,jump_type_bd_1  ,jump_type_bd_0  };
  
  //generate
  //  for(ii=0 ; ii<NUM_NODE ; ii=ii+1)begin  : jump_type_proc
  //    assign jump_type2_bd_mem[ii] = jump_type_bd_pre[ii*2 +: 2] ;
  //    assign jump_type[ii*3 +: 3]  = {jump_type2_bd_mem[ii][1],jump_type2_bd_mem[ii]};
  //  end
  //endgenerate
  
  generate
    for(ii=0 ; ii<4096 ; ii=ii+1)begin  : jump_type_proc0
      assign jump_type2_bd_mem[ii] = jump_type_bd_pre[ii*2 +: 2] ;
      assign jump_type[ii*3 +: 3]  = {jump_type2_bd_mem[ii][1],jump_type2_bd_mem[ii]};
    end
  endgenerate

  generate
    for(ii=4096 ; ii<NUM_NODE ; ii=ii+1)begin  : jump_type_proc1
      assign jump_type2_bd_mem[ii] = jump_type_bd_pre[ii*2 +: 2] ;
      assign jump_type[ii*3 +: 3]  = {jump_type2_bd_mem[ii][1],jump_type2_bd_mem[ii]};
    end
  endgenerate

  //----il_pattern
  generate
    for(jj=0 ; jj<NUM_K ; jj=jj+1)begin  : il_pattern_proc
      assign il_pattern_mem[jj]             = jj[WID_K-1:0]     ; //0~NUM_K-1
      assign il_pattern[jj*WID_K +: WID_K]  = il_pattern_mem[jj];
    end
  endgenerate

  //----signals not used in bd
  assign dcrc_mode    = 1'b0;
  assign dcrc_reg_ini = 3'd0;
  assign crc_flag     = 1'b0;
  assign rnti_num     = 2'd0;
  assign rnti_val0    = 16'd0;
  assign rnti_val1    = 16'd0;
  assign rnti_val2    = 16'd0;
  assign rnti_val3    = 16'd0;
  assign dcrc_info_idx= {WID_K*3{1'b0}};
  assign dcrc_info_bit= {3*NUM_DCRC_INFO{1'b0}};

`else
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
`endif
//=============================================
//====            apb2reg
//=============================================
hgw_apb2reg #(
// Parameters
.BW                     (ADDR_WIDTH                          ) ,
.DELAY                  (1                                   ) ) 
U_pdec_apb2reg(
// Outputs
.pready                 (pdec_pready                         ) ,
.prdata                 (pdec_prdata[DATA_WIDTH-1:0]         ) ,
.pslverr                (pdec_pslverr                        ) ,
.o_wen                  (cfg_wen                             ) ,
.o_ren                  (cfg_ren                             ) ,
.o_waddr                (cfg_waddr[31:0]                     ) ,
.o_raddr                (cfg_raddr[31:0]                     ) ,
.o_wdata                (cfg_wdata[31:0]                     ) ,
// Inputs
.paddr                  (pdec_paddr[ADDR_WIDTH-1:0]          ) ,
.psel                   (pdec_psel                           ) ,
.penable                (pdec_penable                        ) ,
.pwrite                 (pdec_pwrite                         ) ,
.pwdata                 (pdec_pwdata[DATA_WIDTH-1:0]         ) ,
.i_rdata                (cfg_rdata[31:0]                     ) ) ;

//=============================================
//====       read control
//=============================================

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    para_ren_pre <= 1'b0;
  else if(ctrl2cfg_ftch_st)
    para_ren_pre <= 1'b1;
  else if(para_ren_cnt == (PARA_NUM-1'b1))
    para_ren_pre <= 1'b0;
end    

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    para_ren_cnt <= {WID_PARA_ADDR{1'b0}};
  else if(ctrl2cfg_ftch_st)  
    para_ren_cnt <= {WID_PARA_ADDR{1'b0}};
  else if(para_ren_pre)
    para_ren_cnt <= para_ren_cnt + 1'b1;
end

assign para_ren0  = para_ren_pre & (pdec_type == 1'b0); 
assign para_ren1  = para_ren_pre & (pdec_type == 1'b1);
assign para_ren   = {para_ren1,para_ren0};
assign para_raddr = para_ren_cnt;

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin
    para_ren_r  <= 1'b0;
    para_wen    <= 1'b0;
  end  
  else begin
    para_ren_r  <= para_ren_pre;
    para_wen    <= para_ren_r;
  end
end

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    para_ren_cnt_r <= {WID_PARA_ADDR{1'b0}};
  else if(para_ren_pre)
    para_ren_cnt_r <= para_ren_cnt;
end

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    para_waddr <= {WID_PARA_ADDR{1'b0}};
  else if(para_ren_r)
    para_waddr <= para_ren_cnt_r;
end

assign para_wdata = para_rdata;

assign cfg2ctrl_ftch_done0 = para_wen & (para_waddr == 6'd60);
assign cfg2ctrl_ftch_done2 = para_wen & (para_waddr == 7'd108);
assign cfg2ctrl_ftch_done1 = (~para_ren_r) & para_wen;
//=============================================
//====       pdec_reg_cfg
//=============================================
pdec_reg_ctrl_bd
U_pdec_reg_ctrl(
// Outputs
.rdata                  (cfg_rdata[32-1:0]       ) ,
.pdec_st_w1p            (pdec_st_w1p             ) ,
.pdec_soft_rst          (pdec_soft_rst           ) ,
.icg_sw_en              (icg_sw_en               ) ,
.icg_mode               (icg_mode                ) ,
.list_num               (list_num[2-1:0]         ) ,
.pdec_type              (pdec_type               ) ,
.intr_group_0           (intr_group_0            ) ,
// Inputs
.rst_n                  (rst_n                   ) ,
.clk                    (clk                     ) ,
.wen                    (cfg_wen                 ) ,
.ren                    (cfg_ren                 ) ,
.waddr                  (cfg_waddr[32-1:0]       ) ,
.raddr                  (cfg_raddr[32-1:0]       ) ,
.wdata                  (cfg_wdata[32-1:0]       ) ,
.pdec_cfg_ver           (PDEC_CFG_VER            ) ,
.pdec_head_info         (pdec_head_info[32-1:0]  ) ,
.pdec_debug_info        (pdec_debug_info[32-1:0] ) ,
.drm_sram_int           (drm_sram_int            ) ,
.dec_rpt_int            (dec_rpt_int             )   ) ;
//=============================================
//====       pdec_reg_dyn
//=============================================
`ifdef PDEC_BD
  pdec_reg_dyn_bd
  U_pdec_reg_dyn(
  // Outputs
  .rdata                   (rdata_hg_nc                                ) ,
  .dcrc_num                (dcrc_num                                   ) ,
  .list_num                (list_num_hg_nc                             ) ,
  .leaf_mode               (leaf_mode                                  ) ,
  .param_k                 (param_k                                    ) ,
  .param_a                 (param_a                                    ) ,
  .param_n                 (param_n                                    ) ,
  .jump_type0              (jump_type_bd_0                            ) ,
  .jump_type1              (jump_type_bd_1                            ) ,
  .jump_type2              (jump_type_bd_2                            ) ,
  .jump_type3              (jump_type_bd_3                            ) ,
  .jump_type4              (jump_type_bd_4                            ) ,
  .jump_type5              (jump_type_bd_5                            ) ,
  .jump_type6              (jump_type_bd_6                            ) ,
  .jump_type7              (jump_type_bd_7                            ) ,
  .jump_type8              (jump_type_bd_8                            ) ,
  .jump_type9              (jump_type_bd_9                            ) ,
  .jump_type10             (jump_type_bd_10                           ) ,
  .jump_type11             (jump_type_bd_11                           ) ,
  .jump_type12             (jump_type_bd_12                           ) ,
  .jump_type13             (jump_type_bd_13                           ) ,
  .jump_type14             (jump_type_bd_14                           ) ,
  .jump_type15             (jump_type_bd_15                           ) ,
  .jump_type16             (jump_type_bd_16                           ) ,
  .jump_type17             (jump_type_bd_17                           ) ,
  .jump_type18             (jump_type_bd_18                           ) ,
  .jump_type19             (jump_type_bd_19                           ) ,
  .jump_type20             (jump_type_bd_20                           ) ,
  .jump_type21             (jump_type_bd_21                           ) ,
  .jump_type22             (jump_type_bd_22                           ) ,
  .jump_type23             (jump_type_bd_23                           ) ,
  .jump_type24             (jump_type_bd_24                           ) ,
  .jump_type25             (jump_type_bd_25                           ) ,
  .jump_type26             (jump_type_bd_26                           ) ,
  .jump_type27             (jump_type_bd_27                           ) ,
  .jump_type28             (jump_type_bd_28                           ) ,
  .jump_type29             (jump_type_bd_29                           ) ,
  .jump_type30             (jump_type_bd_30                           ) ,
  .jump_type31             (jump_type_bd_31                           ) ,
  .jump_type32             (jump_type_bd_32                           ) ,
  .jump_type33             (jump_type_bd_33                           ) ,
  .jump_type34             (jump_type_bd_34                           ) ,
  .jump_type35             (jump_type_bd_35                           ) ,
  .jump_type36             (jump_type_bd_36                           ) ,
  .jump_type37             (jump_type_bd_37                           ) ,
  .jump_type38             (jump_type_bd_38                           ) ,
  .jump_type39             (jump_type_bd_39                           ) ,
  .jump_type40             (jump_type_bd_40                           ) ,
  .jump_type41             (jump_type_bd_41                           ) ,
  .jump_type42             (jump_type_bd_42                           ) ,
  .jump_type43             (jump_type_bd_43                           ) ,
  .jump_type44             (jump_type_bd_44                           ) ,
  .jump_type45             (jump_type_bd_45                           ) ,
  .jump_type46             (jump_type_bd_46                           ) ,
  .jump_type47             (jump_type_bd_47                           ) ,
  .jump_type48             (jump_type_bd_48                           ) ,
  .jump_type49             (jump_type_bd_49                           ) ,
  .jump_type50             (jump_type_bd_50                           ) ,
  .jump_type51             (jump_type_bd_51                           ) ,
  .jump_type52             (jump_type_bd_52                           ) ,
  .jump_type53             (jump_type_bd_53                           ) ,
  .jump_type54             (jump_type_bd_54                           ) ,
  .jump_type55             (jump_type_bd_55                           ) ,
  .jump_type56             (jump_type_bd_56                           ) ,
  .jump_type57             (jump_type_bd_57                           ) ,
  .jump_type58             (jump_type_bd_58                           ) ,
  .jump_type59             (jump_type_bd_59                           ) ,
  .jump_type60             (jump_type_bd_60                           ) ,
  .jump_type61             (jump_type_bd_61                           ) ,
  .jump_type62             (jump_type_bd_62                           ) ,
  .jump_type63             (jump_type_bd_63                           ) ,
  .jump_type64             (jump_type_bd_64                           ) ,
  .jump_type65             (jump_type_bd_65                           ) ,
  .jump_type66             (jump_type_bd_66                           ) ,
  .jump_type67             (jump_type_bd_67                           ) ,
  .jump_type68             (jump_type_bd_68                           ) ,
  .jump_type69             (jump_type_bd_69                           ) ,
  .jump_type70             (jump_type_bd_70                           ) ,
  .jump_type71             (jump_type_bd_71                           ) ,
  .jump_type72             (jump_type_bd_72                           ) ,
  .jump_type73             (jump_type_bd_73                           ) ,
  .jump_type74             (jump_type_bd_74                           ) ,
  .jump_type75             (jump_type_bd_75                           ) ,
  .jump_type76             (jump_type_bd_76                           ) ,
  .jump_type77             (jump_type_bd_77                           ) ,
  .jump_type78             (jump_type_bd_78                           ) ,
  .jump_type79             (jump_type_bd_79                           ) ,
  .jump_type80             (jump_type_bd_80                           ) ,
  .jump_type81             (jump_type_bd_81                           ) ,
  .jump_type82             (jump_type_bd_82                           ) ,
  .jump_type83             (jump_type_bd_83                           ) ,
  .jump_type84             (jump_type_bd_84                           ) ,
  .jump_type85             (jump_type_bd_85                           ) ,
  .jump_type86             (jump_type_bd_86                           ) ,
  .jump_type87             (jump_type_bd_87                           ) ,
  .jump_type88             (jump_type_bd_88                           ) ,
  .jump_type89             (jump_type_bd_89                           ) ,
  .jump_type90             (jump_type_bd_90                           ) ,
  .jump_type91             (jump_type_bd_91                           ) ,
  .jump_type92             (jump_type_bd_92                           ) ,
  .jump_type93             (jump_type_bd_93                           ) ,
  .jump_type94             (jump_type_bd_94                           ) ,
  .jump_type95             (jump_type_bd_95                           ) ,
  .jump_type96             (jump_type_bd_96                           ) ,
  .jump_type97             (jump_type_bd_97                           ) ,
  .jump_type98             (jump_type_bd_98                           ) ,
  .jump_type99             (jump_type_bd_99                           ) ,
  .jump_type100            (jump_type_bd_100                          ) ,
  .jump_type101            (jump_type_bd_101                          ) ,
  .jump_type102            (jump_type_bd_102                          ) ,
  .jump_type103            (jump_type_bd_103                          ) ,
  .jump_type104            (jump_type_bd_104                          ) ,
  .jump_type105            (jump_type_bd_105                          ) ,
  .jump_type106            (jump_type_bd_106                          ) ,
  .jump_type107            (jump_type_bd_107                          ) ,
  .jump_type108            (jump_type_bd_108                          ) ,
  .jump_type109            (jump_type_bd_109                          ) ,
  .jump_type110            (jump_type_bd_110                          ) ,
  .jump_type111            (jump_type_bd_111                          ) ,
  .jump_type112            (jump_type_bd_112                          ) ,
  .jump_type113            (jump_type_bd_113                          ) ,
  .jump_type114            (jump_type_bd_114                          ) ,
  .jump_type115            (jump_type_bd_115                          ) ,
  .jump_type116            (jump_type_bd_116                          ) ,
  .jump_type117            (jump_type_bd_117                          ) ,
  .jump_type118            (jump_type_bd_118                          ) ,
  .jump_type119            (jump_type_bd_119                          ) ,
  .jump_type120            (jump_type_bd_120                          ) ,
  .jump_type121            (jump_type_bd_121                          ) ,
  .jump_type122            (jump_type_bd_122                          ) ,
  .jump_type123            (jump_type_bd_123                          ) ,
  .jump_type124            (jump_type_bd_124                          ) ,
  .jump_type125            (jump_type_bd_125                          ) ,
  .jump_type126            (jump_type_bd_126                          ) ,
  .jump_type127            (jump_type_bd_127                          ) ,
  .jump_type128            (jump_type_bd_128                          ) ,
  .jump_type129            (jump_type_bd_129                          ) ,
  .jump_type130            (jump_type_bd_130                          ) ,
  .jump_type131            (jump_type_bd_131                          ) ,
  .jump_type132            (jump_type_bd_132                          ) ,
  .jump_type133            (jump_type_bd_133                          ) ,
  .jump_type134            (jump_type_bd_134                          ) ,
  .jump_type135            (jump_type_bd_135                          ) ,
  .jump_type136            (jump_type_bd_136                          ) ,
  .jump_type137            (jump_type_bd_137                          ) ,
  .jump_type138            (jump_type_bd_138                          ) ,
  .jump_type139            (jump_type_bd_139                          ) ,
  .jump_type140            (jump_type_bd_140                          ) ,
  .jump_type141            (jump_type_bd_141                          ) ,
  .jump_type142            (jump_type_bd_142                          ) ,
  .jump_type143            (jump_type_bd_143                          ) ,
  .jump_type144            (jump_type_bd_144                          ) ,
  .jump_type145            (jump_type_bd_145                          ) ,
  .jump_type146            (jump_type_bd_146                          ) ,
  .jump_type147            (jump_type_bd_147                          ) ,
  .jump_type148            (jump_type_bd_148                          ) ,
  .jump_type149            (jump_type_bd_149                          ) ,
  .jump_type150            (jump_type_bd_150                          ) ,
  .jump_type151            (jump_type_bd_151                          ) ,
  .jump_type152            (jump_type_bd_152                          ) ,
  .jump_type153            (jump_type_bd_153                          ) ,
  .jump_type154            (jump_type_bd_154                          ) ,
  .jump_type155            (jump_type_bd_155                          ) ,
  .jump_type156            (jump_type_bd_156                          ) ,
  .jump_type157            (jump_type_bd_157                          ) ,
  .jump_type158            (jump_type_bd_158                          ) ,
  .jump_type159            (jump_type_bd_159                          ) ,
  .jump_type160            (jump_type_bd_160                          ) ,
  .jump_type161            (jump_type_bd_161                          ) ,
  .jump_type162            (jump_type_bd_162                          ) ,
  .jump_type163            (jump_type_bd_163                          ) ,
  .jump_type164            (jump_type_bd_164                          ) ,
  .jump_type165            (jump_type_bd_165                          ) ,
  .jump_type166            (jump_type_bd_166                          ) ,
  .jump_type167            (jump_type_bd_167                          ) ,
  .jump_type168            (jump_type_bd_168                          ) ,
  .jump_type169            (jump_type_bd_169                          ) ,
  .jump_type170            (jump_type_bd_170                          ) ,
  .jump_type171            (jump_type_bd_171                          ) ,
  .jump_type172            (jump_type_bd_172                          ) ,
  .jump_type173            (jump_type_bd_173                          ) ,
  .jump_type174            (jump_type_bd_174                          ) ,
  .jump_type175            (jump_type_bd_175                          ) ,
  .jump_type176            (jump_type_bd_176                          ) ,
  .jump_type177            (jump_type_bd_177                          ) ,
  .jump_type178            (jump_type_bd_178                          ) ,
  .jump_type179            (jump_type_bd_179                          ) ,
  .jump_type180            (jump_type_bd_180                          ) ,
  .jump_type181            (jump_type_bd_181                          ) ,
  .jump_type182            (jump_type_bd_182                          ) ,
  .jump_type183            (jump_type_bd_183                          ) ,
  .jump_type184            (jump_type_bd_184                          ) ,
  .jump_type185            (jump_type_bd_185                          ) ,
  .jump_type186            (jump_type_bd_186                          ) ,
  .jump_type187            (jump_type_bd_187                          ) ,
  .jump_type188            (jump_type_bd_188                          ) ,
  .jump_type189            (jump_type_bd_189                          ) ,
  .jump_type190            (jump_type_bd_190                          ) ,
  .jump_type191            (jump_type_bd_191                          ) ,
  .jump_type192            (jump_type_bd_192                          ) ,
  .jump_type193            (jump_type_bd_193                          ) ,
  .jump_type194            (jump_type_bd_194                          ) ,
  .jump_type195            (jump_type_bd_195                          ) ,
  .jump_type196            (jump_type_bd_196                          ) ,
  .jump_type197            (jump_type_bd_197                          ) ,
  .jump_type198            (jump_type_bd_198                          ) ,
  .jump_type199            (jump_type_bd_199                          ) ,
  .jump_type200            (jump_type_bd_200                          ) ,
  .jump_type201            (jump_type_bd_201                          ) ,
  .jump_type202            (jump_type_bd_202                          ) ,
  .jump_type203            (jump_type_bd_203                          ) ,
  .jump_type204            (jump_type_bd_204                          ) ,
  .jump_type205            (jump_type_bd_205                          ) ,
  .jump_type206            (jump_type_bd_206                          ) ,
  .jump_type207            (jump_type_bd_207                          ) ,
  .jump_type208            (jump_type_bd_208                          ) ,
  .jump_type209            (jump_type_bd_209                          ) ,
  .jump_type210            (jump_type_bd_210                          ) ,
  .jump_type211            (jump_type_bd_211                          ) ,
  .jump_type212            (jump_type_bd_212                          ) ,
  .jump_type213            (jump_type_bd_213                          ) ,
  .jump_type214            (jump_type_bd_214                          ) ,
  .jump_type215            (jump_type_bd_215                          ) ,
  .jump_type216            (jump_type_bd_216                          ) ,
  .jump_type217            (jump_type_bd_217                          ) ,
  .jump_type218            (jump_type_bd_218                          ) ,
  .jump_type219            (jump_type_bd_219                          ) ,
  .jump_type220            (jump_type_bd_220                          ) ,
  .jump_type221            (jump_type_bd_221                          ) ,
  .jump_type222            (jump_type_bd_222                          ) ,
  .jump_type223            (jump_type_bd_223                          ) ,
  .jump_type224            (jump_type_bd_224                          ) ,
  .jump_type225            (jump_type_bd_225                          ) ,
  .jump_type226            (jump_type_bd_226                          ) ,
  .jump_type227            (jump_type_bd_227                          ) ,
  .jump_type228            (jump_type_bd_228                          ) ,
  .jump_type229            (jump_type_bd_229                          ) ,
  .jump_type230            (jump_type_bd_230                          ) ,
  .jump_type231            (jump_type_bd_231                          ) ,
  .jump_type232            (jump_type_bd_232                          ) ,
  .jump_type233            (jump_type_bd_233                          ) ,
  .jump_type234            (jump_type_bd_234                          ) ,
  .jump_type235            (jump_type_bd_235                          ) ,
  .jump_type236            (jump_type_bd_236                          ) ,
  .jump_type237            (jump_type_bd_237                          ) ,
  .jump_type238            (jump_type_bd_238                          ) ,
  .jump_type239            (jump_type_bd_239                          ) ,
  .jump_type240            (jump_type_bd_240                          ) ,
  .jump_type241            (jump_type_bd_241                          ) ,
  .jump_type242            (jump_type_bd_242                          ) ,
  .jump_type243            (jump_type_bd_243                          ) ,
  .jump_type244            (jump_type_bd_244                          ) ,
  .jump_type245            (jump_type_bd_245                          ) ,
  .jump_type246            (jump_type_bd_246                          ) ,
  .jump_type247            (jump_type_bd_247                          ) ,
  .jump_type248            (jump_type_bd_248                          ) ,
  .jump_type249            (jump_type_bd_249                          ) ,
  .jump_type250            (jump_type_bd_250                          ) ,
  .jump_type251            (jump_type_bd_251                          ) ,
  .jump_type252            (jump_type_bd_252                          ) ,
  .jump_type253            (jump_type_bd_253                          ) ,
  .jump_type254            (jump_type_bd_254                          ) ,
  .jump_type255            (jump_type_bd_255                          ) ,
  .jump_type256            (jump_type_bd_256                          ) ,
  .jump_type257            (jump_type_bd_257                          ) ,
  .jump_type258            (jump_type_bd_258                          ) ,
  .jump_type259            (jump_type_bd_259                          ) ,
  .jump_type260            (jump_type_bd_260                          ) ,
  .jump_type261            (jump_type_bd_261                          ) ,
  .jump_type262            (jump_type_bd_262                          ) ,
  .jump_type263            (jump_type_bd_263                          ) ,
  .jump_type264            (jump_type_bd_264                          ) ,
  .jump_type265            (jump_type_bd_265                          ) ,
  .jump_type266            (jump_type_bd_266                          ) ,
  .jump_type267            (jump_type_bd_267                          ) ,
  .jump_type268            (jump_type_bd_268                          ) ,
  .jump_type269            (jump_type_bd_269                          ) ,
  .jump_type270            (jump_type_bd_270                          ) ,
  .jump_type271            (jump_type_bd_271                          ) ,
  .jump_type272            (jump_type_bd_272                          ) ,
  .jump_type273            (jump_type_bd_273                          ) ,
  .jump_type274            (jump_type_bd_274                          ) ,
  .jump_type275            (jump_type_bd_275                          ) ,
  .jump_type276            (jump_type_bd_276                          ) ,
  .jump_type277            (jump_type_bd_277                          ) ,
  .jump_type278            (jump_type_bd_278                          ) ,
  .jump_type279            (jump_type_bd_279                          ) ,
  .jump_type280            (jump_type_bd_280                          ) ,
  .jump_type281            (jump_type_bd_281                          ) ,
  .jump_type282            (jump_type_bd_282                          ) ,
  .jump_type283            (jump_type_bd_283                          ) ,
  .jump_type284            (jump_type_bd_284                          ) ,
  .jump_type285            (jump_type_bd_285                          ) ,
  .jump_type286            (jump_type_bd_286                          ) ,
  .jump_type287            (jump_type_bd_287                          ) ,
  .jump_type288            (jump_type_bd_288                          ) ,
  .jump_type289            (jump_type_bd_289                          ) ,
  .jump_type290            (jump_type_bd_290                          ) ,
  .jump_type291            (jump_type_bd_291                          ) ,
  .jump_type292            (jump_type_bd_292                          ) ,
  .jump_type293            (jump_type_bd_293                          ) ,
  .jump_type294            (jump_type_bd_294                          ) ,
  .jump_type295            (jump_type_bd_295                          ) ,
  .jump_type296            (jump_type_bd_296                          ) ,
  .jump_type297            (jump_type_bd_297                          ) ,
  .jump_type298            (jump_type_bd_298                          ) ,
  .jump_type299            (jump_type_bd_299                          ) ,
  .jump_type300            (jump_type_bd_300                          ) ,
  .jump_type301            (jump_type_bd_301                          ) ,
  .jump_type302            (jump_type_bd_302                          ) ,
  .jump_type303            (jump_type_bd_303                          ) ,
  .jump_type304            (jump_type_bd_304                          ) ,
  .jump_type305            (jump_type_bd_305                          ) ,
  .jump_type306            (jump_type_bd_306                          ) ,
  .jump_type307            (jump_type_bd_307                          ) ,
  .jump_type308            (jump_type_bd_308                          ) ,
  .jump_type309            (jump_type_bd_309                          ) ,
  .jump_type310            (jump_type_bd_310                          ) ,
  .jump_type311            (jump_type_bd_311                          ) ,
  .jump_type312            (jump_type_bd_312                          ) ,
  .jump_type313            (jump_type_bd_313                          ) ,
  .jump_type314            (jump_type_bd_314                          ) ,
  .jump_type315            (jump_type_bd_315                          ) ,
  .jump_type316            (jump_type_bd_316                          ) ,
  .jump_type317            (jump_type_bd_317                          ) ,
  .jump_type318            (jump_type_bd_318                          ) ,
  .jump_type319            (jump_type_bd_319                          ) ,
  .jump_type320            (jump_type_bd_320                          ) ,
  .jump_type321            (jump_type_bd_321                          ) ,
  .jump_type322            (jump_type_bd_322                          ) ,
  .jump_type323            (jump_type_bd_323                          ) ,
  .jump_type324            (jump_type_bd_324                          ) ,
  .jump_type325            (jump_type_bd_325                          ) ,
  .jump_type326            (jump_type_bd_326                          ) ,
  .jump_type327            (jump_type_bd_327                          ) ,
  .jump_type328            (jump_type_bd_328                          ) ,
  .jump_type329            (jump_type_bd_329                          ) ,
  .jump_type330            (jump_type_bd_330                          ) ,
  .jump_type331            (jump_type_bd_331                          ) ,
  .jump_type332            (jump_type_bd_332                          ) ,
  .jump_type333            (jump_type_bd_333                          ) ,
  .jump_type334            (jump_type_bd_334                          ) ,
  .jump_type335            (jump_type_bd_335                          ) ,
  .jump_type336            (jump_type_bd_336                          ) ,
  .jump_type337            (jump_type_bd_337                          ) ,
  .jump_type338            (jump_type_bd_338                          ) ,
  .jump_type339            (jump_type_bd_339                          ) ,
  .jump_type340            (jump_type_bd_340                          ) ,
  .jump_type341            (jump_type_bd_341                          ) ,
  .jump_type342            (jump_type_bd_342                          ) ,
  .jump_type343            (jump_type_bd_343                          ) ,
  .jump_type344            (jump_type_bd_344                          ) ,
  .jump_type345            (jump_type_bd_345                          ) ,
  .jump_type346            (jump_type_bd_346                          ) ,
  .jump_type347            (jump_type_bd_347                          ) ,
  .jump_type348            (jump_type_bd_348                          ) ,
  .jump_type349            (jump_type_bd_349                          ) ,
  .jump_type350            (jump_type_bd_350                          ) ,
  .jump_type351            (jump_type_bd_351                          ) ,
  .jump_type352            (jump_type_bd_352                          ) ,
  .jump_type353            (jump_type_bd_353                          ) ,
  .jump_type354            (jump_type_bd_354                          ) ,
  .jump_type355            (jump_type_bd_355                          ) ,
  .jump_type356            (jump_type_bd_356                          ) ,
  .jump_type357            (jump_type_bd_357                          ) ,
  .jump_type358            (jump_type_bd_358                          ) ,
  .jump_type359            (jump_type_bd_359                          ) ,
  .jump_type360            (jump_type_bd_360                          ) ,
  .jump_type361            (jump_type_bd_361                          ) ,
  .jump_type362            (jump_type_bd_362                          ) ,
  .jump_type363            (jump_type_bd_363                          ) ,
  .jump_type364            (jump_type_bd_364                          ) ,
  .jump_type365            (jump_type_bd_365                          ) ,
  .jump_type366            (jump_type_bd_366                          ) ,
  .jump_type367            (jump_type_bd_367                          ) ,
  .jump_type368            (jump_type_bd_368                          ) ,
  .jump_type369            (jump_type_bd_369                          ) ,
  .jump_type370            (jump_type_bd_370                          ) ,
  .jump_type371            (jump_type_bd_371                          ) ,
  .jump_type372            (jump_type_bd_372                          ) ,
  .jump_type373            (jump_type_bd_373                          ) ,
  .jump_type374            (jump_type_bd_374                          ) ,
  .jump_type375            (jump_type_bd_375                          ) ,
  .jump_type376            (jump_type_bd_376                          ) ,
  .jump_type377            (jump_type_bd_377                          ) ,
  .jump_type378            (jump_type_bd_378                          ) ,
  .jump_type379            (jump_type_bd_379                          ) ,
  .jump_type380            (jump_type_bd_380                          ) ,
  .jump_type381            (jump_type_bd_381                          ) ,
  .jump_type382            (jump_type_bd_382                          ) ,
  .jump_type383            (jump_type_bd_383                          ) ,
  .jump_type384            (jump_type_bd_384                          ) ,
  .jump_type385            (jump_type_bd_385                          ) ,
  .jump_type386            (jump_type_bd_386                          ) ,
  .jump_type387            (jump_type_bd_387                          ) ,
  .jump_type388            (jump_type_bd_388                          ) ,
  .jump_type389            (jump_type_bd_389                          ) ,
  .jump_type390            (jump_type_bd_390                          ) ,
  .jump_type391            (jump_type_bd_391                          ) ,
  .jump_type392            (jump_type_bd_392                          ) ,
  .jump_type393            (jump_type_bd_393                          ) ,
  .jump_type394            (jump_type_bd_394                          ) ,
  .jump_type395            (jump_type_bd_395                          ) ,
  .jump_type396            (jump_type_bd_396                          ) ,
  .jump_type397            (jump_type_bd_397                          ) ,
  .jump_type398            (jump_type_bd_398                          ) ,
  .jump_type399            (jump_type_bd_399                          ) ,
  .jump_type400            (jump_type_bd_400                          ) ,
  .jump_type401            (jump_type_bd_401                          ) ,
  .jump_type402            (jump_type_bd_402                          ) ,
  .jump_type403            (jump_type_bd_403                          ) ,
  .jump_type404            (jump_type_bd_404                          ) ,
  .jump_type405            (jump_type_bd_405                          ) ,
  .jump_type406            (jump_type_bd_406                          ) ,
  .jump_type407            (jump_type_bd_407                          ) ,
  .jump_type408            (jump_type_bd_408                          ) ,
  .jump_type409            (jump_type_bd_409                          ) ,
  .jump_type410            (jump_type_bd_410                          ) ,
  .jump_type411            (jump_type_bd_411                          ) ,
  .jump_type412            (jump_type_bd_412                          ) ,
  .jump_type413            (jump_type_bd_413                          ) ,
  .jump_type414            (jump_type_bd_414                          ) ,
  .jump_type415            (jump_type_bd_415                          ) ,
  .jump_type416            (jump_type_bd_416                          ) ,
  .jump_type417            (jump_type_bd_417                          ) ,
  .jump_type418            (jump_type_bd_418                          ) ,
  .jump_type419            (jump_type_bd_419                          ) ,
  .jump_type420            (jump_type_bd_420                          ) ,
  .jump_type421            (jump_type_bd_421                          ) ,
  .jump_type422            (jump_type_bd_422                          ) ,
  .jump_type423            (jump_type_bd_423                          ) ,
  .jump_type424            (jump_type_bd_424                          ) ,
  .jump_type425            (jump_type_bd_425                          ) ,
  .jump_type426            (jump_type_bd_426                          ) ,
  .jump_type427            (jump_type_bd_427                          ) ,
  .jump_type428            (jump_type_bd_428                          ) ,
  .jump_type429            (jump_type_bd_429                          ) ,
  .jump_type430            (jump_type_bd_430                          ) ,
  .jump_type431            (jump_type_bd_431                          ) ,
  .jump_type432            (jump_type_bd_432                          ) ,
  .jump_type433            (jump_type_bd_433                          ) ,
  .jump_type434            (jump_type_bd_434                          ) ,
  .jump_type435            (jump_type_bd_435                          ) ,
  .jump_type436            (jump_type_bd_436                          ) ,
  .jump_type437            (jump_type_bd_437                          ) ,
  .jump_type438            (jump_type_bd_438                          ) ,
  .jump_type439            (jump_type_bd_439                          ) ,
  .jump_type440            (jump_type_bd_440                          ) ,
  .jump_type441            (jump_type_bd_441                          ) ,
  .jump_type442            (jump_type_bd_442                          ) ,
  .jump_type443            (jump_type_bd_443                          ) ,
  .jump_type444            (jump_type_bd_444                          ) ,
  .jump_type445            (jump_type_bd_445                          ) ,
  .jump_type446            (jump_type_bd_446                          ) ,
  .jump_type447            (jump_type_bd_447                          ) ,
  .jump_type448            (jump_type_bd_448                          ) ,
  .jump_type449            (jump_type_bd_449                          ) ,
  .jump_type450            (jump_type_bd_450                          ) ,
  .jump_type451            (jump_type_bd_451                          ) ,
  .jump_type452            (jump_type_bd_452                          ) ,
  .jump_type453            (jump_type_bd_453                          ) ,
  .jump_type454            (jump_type_bd_454                          ) ,
  .jump_type455            (jump_type_bd_455                          ) ,
  .jump_type456            (jump_type_bd_456                          ) ,
  .jump_type457            (jump_type_bd_457                          ) ,
  .jump_type458            (jump_type_bd_458                          ) ,
  .jump_type459            (jump_type_bd_459                          ) ,
  .jump_type460            (jump_type_bd_460                          ) ,
  .jump_type461            (jump_type_bd_461                          ) ,
  .jump_type462            (jump_type_bd_462                          ) ,
  .jump_type463            (jump_type_bd_463                          ) ,
  .jump_type464            (jump_type_bd_464                          ) ,
  .jump_type465            (jump_type_bd_465                          ) ,
  .jump_type466            (jump_type_bd_466                          ) ,
  .jump_type467            (jump_type_bd_467                          ) ,
  .jump_type468            (jump_type_bd_468                          ) ,
  .jump_type469            (jump_type_bd_469                          ) ,
  .jump_type470            (jump_type_bd_470                          ) ,
  .jump_type471            (jump_type_bd_471                          ) ,
  .jump_type472            (jump_type_bd_472                          ) ,
  .jump_type473            (jump_type_bd_473                          ) ,
  .jump_type474            (jump_type_bd_474                          ) ,
  .jump_type475            (jump_type_bd_475                          ) ,
  .jump_type476            (jump_type_bd_476                          ) ,
  .jump_type477            (jump_type_bd_477                          ) ,
  .jump_type478            (jump_type_bd_478                          ) ,
  .jump_type479            (jump_type_bd_479                          ) ,
  .jump_type480            (jump_type_bd_480                          ) ,
  .jump_type481            (jump_type_bd_481                          ) ,
  .jump_type482            (jump_type_bd_482                          ) ,
  .jump_type483            (jump_type_bd_483                          ) ,
  .jump_type484            (jump_type_bd_484                          ) ,
  .jump_type485            (jump_type_bd_485                          ) ,
  .jump_type486            (jump_type_bd_486                          ) ,
  .jump_type487            (jump_type_bd_487                          ) ,
  .jump_type488            (jump_type_bd_488                          ) ,
  .jump_type489            (jump_type_bd_489                          ) ,
  .jump_type490            (jump_type_bd_490                          ) ,
  .jump_type491            (jump_type_bd_491                          ) ,
  .jump_type492            (jump_type_bd_492                          ) ,
  .jump_type493            (jump_type_bd_493                          ) ,
  .jump_type494            (jump_type_bd_494                          ) ,
  .jump_type495            (jump_type_bd_495                          ) ,
  .jump_type496            (jump_type_bd_496                          ) ,
  .jump_type497            (jump_type_bd_497                          ) ,
  .jump_type498            (jump_type_bd_498                          ) ,
  .jump_type499            (jump_type_bd_499                          ) ,
  .jump_type500            (jump_type_bd_500                          ) ,
  .jump_type501            (jump_type_bd_501                          ) ,
  .jump_type502            (jump_type_bd_502                          ) ,
  .jump_type503            (jump_type_bd_503                          ) ,
  .jump_type504            (jump_type_bd_504                          ) ,
  .jump_type505            (jump_type_bd_505                          ) ,
  .jump_type506            (jump_type_bd_506                          ) ,
  .jump_type507            (jump_type_bd_507                          ) ,
  .jump_type508            (jump_type_bd_508                          ) ,
  .jump_type509            (jump_type_bd_509                          ) ,
  .jump_type510            (jump_type_bd_510                          ) ,
  .jump_type511            (jump_type_bd_511                           ) ,
  // Inputs
  .rst_n                   (rst_n                                      ) ,
  .clk                     (clk                                        ) ,
  .wen                     (para_wen                                   ) ,
  .ren                     (1'b0                                       ) ,
  .waddr                   ({{30-WID_PARA_ADDR{1'b0}},para_waddr,2'd0} ) ,
  .raddr                   (32'd0                                      ) ,
  .wdata                   (para_wdata[32-1:0]                         ) ) ;

`else
  pdec_reg_dyn_cch
  U_pdec_reg_dyn(
  // Outputs
  .rdata                   (rdata_hg_nc                                ) ,
  .rnti_num                (rnti_num                                   ) ,
  .crc_flag                (crc_flag                                   ) ,
  .list_num                (list_num_hg_nc                             ) ,
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
`endif
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

assign pdec_clk_en8 = pdec_psel        | 
                      ctrl2cfg_ftch_st |
                      cfg_proc         |
                      dec_rpt_int      |
                      drm_sram_int     ;

endmodule
//Local Variables:
//verilog-library-flags:("-y ./ -y ../reg/ -y dir -y otherdir -y ./inc_dir/")
//verilog-auto-inst-param-value:t
//End:

