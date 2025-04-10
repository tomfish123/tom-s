//////////////////////////////////////////////////////////////////////////////////
// Description   : pdec_reg_dyn_cch regfile cfg
/////////////////////////////////////////////////////////////////////////////////

module pdec_reg_dyn_cch (
    //System
    input               rst_n               ,
    input               clk                 ,

    //w/r interface
    input               wen                 ,
    input               ren                 ,
    input      [32-1:0] waddr               ,
    input      [32-1:0] raddr               ,
    input      [32-1:0] wdata               ,
    output reg [32-1:0] rdata               ,

    //common_para
    output reg [ 2-1:0] rm_mode             ,
    output reg [ 2-1:0] rnti_num            ,
    output reg          crc_flag            ,
    output reg [ 2-1:0] list_num            ,
    output reg          leaf_mode           ,
    output reg [ 8-1:0] param_k             ,
    output reg [ 8-1:0] param_a             ,
    output reg [ 2-1:0] param_n             ,

    //dcrc_para
    output reg [24-1:0] dcrc_info_idx       ,
    output reg          dcrc_mode           ,
    output reg [ 3-1:0] dcrc_reg_ini        ,
    output reg [ 2-1:0] dcrc_num            ,

    //dcrc_info_bit0
    output reg [32-1:0] dcrc_info_bit0      ,

    //dcrc_info_bit1
    output reg [32-1:0] dcrc_info_bit1      ,

    //dcrc_info_bit2
    output reg [32-1:0] dcrc_info_bit2      ,

    //dcrc_info_bit3
    output reg [32-1:0] dcrc_info_bit3      ,

    //dcrc_info_bit4
    output reg [32-1:0] dcrc_info_bit4      ,

    //dcrc_info_bit5
    output reg [32-1:0] dcrc_info_bit5      ,

    //dcrc_info_bit6
    output reg [32-1:0] dcrc_info_bit6      ,

    //dcrc_info_bit7
    output reg [32-1:0] dcrc_info_bit7      ,

    //dcrc_info_bit8
    output reg [32-1:0] dcrc_info_bit8      ,

    //dcrc_info_bit9
    output reg [32-1:0] dcrc_info_bit9      ,

    //dcrc_info_bit10
    output reg [32-1:0] dcrc_info_bit10     ,

    //dcrc_info_bit11
    output reg [32-1:0] dcrc_info_bit11     ,

    //dcrc_info_bit12
    output reg [32-1:0] dcrc_info_bit12     ,

    //dcrc_info_bit13
    output reg [13-1:0] dcrc_info_bit13     ,

    //rnti_val01
    output reg [16-1:0] rnti_val1           ,
    output reg [16-1:0] rnti_val0           ,

    //rnti_val23
    output reg [16-1:0] rnti_val3           ,
    output reg [16-1:0] rnti_val2           ,

    //il_pattern0
    output reg [32-1:0] il_pattern0         ,

    //il_pattern1
    output reg [32-1:0] il_pattern1         ,

    //il_pattern2
    output reg [32-1:0] il_pattern2         ,

    //il_pattern3
    output reg [32-1:0] il_pattern3         ,

    //il_pattern4
    output reg [32-1:0] il_pattern4         ,

    //il_pattern5
    output reg [32-1:0] il_pattern5         ,

    //il_pattern6
    output reg [32-1:0] il_pattern6         ,

    //il_pattern7
    output reg [32-1:0] il_pattern7         ,

    //il_pattern8
    output reg [32-1:0] il_pattern8         ,

    //il_pattern9
    output reg [32-1:0] il_pattern9         ,

    //il_pattern10
    output reg [32-1:0] il_pattern10        ,

    //il_pattern11
    output reg [32-1:0] il_pattern11        ,

    //il_pattern12
    output reg [32-1:0] il_pattern12        ,

    //il_pattern13
    output reg [32-1:0] il_pattern13        ,

    //il_pattern14
    output reg [32-1:0] il_pattern14        ,

    //il_pattern15
    output reg [32-1:0] il_pattern15        ,

    //il_pattern16
    output reg [32-1:0] il_pattern16        ,

    //il_pattern17
    output reg [32-1:0] il_pattern17        ,

    //il_pattern18
    output reg [32-1:0] il_pattern18        ,

    //il_pattern19
    output reg [32-1:0] il_pattern19        ,

    //il_pattern20
    output reg [32-1:0] il_pattern20        ,

    //il_pattern21
    output reg [32-1:0] il_pattern21        ,

    //il_pattern22
    output reg [32-1:0] il_pattern22        ,

    //il_pattern23
    output reg [32-1:0] il_pattern23        ,

    //il_pattern24
    output reg [32-1:0] il_pattern24        ,

    //il_pattern25
    output reg [32-1:0] il_pattern25        ,

    //il_pattern26
    output reg [32-1:0] il_pattern26        ,

    //il_pattern27
    output reg [32-1:0] il_pattern27        ,

    //il_pattern28
    output reg [32-1:0] il_pattern28        ,

    //il_pattern29
    output reg [32-1:0] il_pattern29        ,

    //il_pattern30
    output reg [32-1:0] il_pattern30        ,

    //il_pattern31
    output reg [32-1:0] il_pattern31        ,

    //il_pattern32
    output reg [32-1:0] il_pattern32        ,

    //il_pattern33
    output reg [32-1:0] il_pattern33        ,

    //il_pattern34
    output reg [32-1:0] il_pattern34        ,

    //il_pattern35
    output reg [32-1:0] il_pattern35        ,

    //il_pattern36
    output reg [32-1:0] il_pattern36        ,

    //il_pattern37
    output reg [32-1:0] il_pattern37        ,

    //il_pattern38
    output reg [32-1:0] il_pattern38        ,

    //il_pattern39
    output reg [32-1:0] il_pattern39        ,

    //il_pattern40
    output reg [32-1:0] il_pattern40        ,

    //jump_type0
    output reg [32-1:0] jump_type0          ,

    //jump_type1
    output reg [32-1:0] jump_type1          ,

    //jump_type2
    output reg [32-1:0] jump_type2          ,

    //jump_type3
    output reg [32-1:0] jump_type3          ,

    //jump_type4
    output reg [32-1:0] jump_type4          ,

    //jump_type5
    output reg [32-1:0] jump_type5          ,

    //jump_type6
    output reg [32-1:0] jump_type6          ,

    //jump_type7
    output reg [32-1:0] jump_type7          ,

    //jump_type8
    output reg [32-1:0] jump_type8          ,

    //jump_type9
    output reg [32-1:0] jump_type9          ,

    //jump_type10
    output reg [32-1:0] jump_type10         ,

    //jump_type11
    output reg [32-1:0] jump_type11         ,

    //jump_type12
    output reg [32-1:0] jump_type12         ,

    //jump_type13
    output reg [32-1:0] jump_type13         ,

    //jump_type14
    output reg [32-1:0] jump_type14         ,

    //jump_type15
    output reg [32-1:0] jump_type15         ,

    //jump_type16
    output reg [32-1:0] jump_type16         ,

    //jump_type17
    output reg [32-1:0] jump_type17         ,

    //jump_type18
    output reg [32-1:0] jump_type18         ,

    //jump_type19
    output reg [32-1:0] jump_type19         ,

    //jump_type20
    output reg [32-1:0] jump_type20         ,

    //jump_type21
    output reg [32-1:0] jump_type21         ,

    //jump_type22
    output reg [32-1:0] jump_type22         ,

    //jump_type23
    output reg [32-1:0] jump_type23         ,

    //jump_type24
    output reg [32-1:0] jump_type24         ,

    //jump_type25
    output reg [32-1:0] jump_type25         ,

    //jump_type26
    output reg [32-1:0] jump_type26         ,

    //jump_type27
    output reg [32-1:0] jump_type27         ,

    //jump_type28
    output reg [32-1:0] jump_type28         ,

    //jump_type29
    output reg [32-1:0] jump_type29         ,

    //jump_type30
    output reg [32-1:0] jump_type30         ,

    //jump_type31
    output reg [32-1:0] jump_type31         ,

    //jump_type32
    output reg [32-1:0] jump_type32         ,

    //jump_type33
    output reg [32-1:0] jump_type33         ,

    //jump_type34
    output reg [32-1:0] jump_type34         ,

    //jump_type35
    output reg [32-1:0] jump_type35         ,

    //jump_type36
    output reg [32-1:0] jump_type36         ,

    //jump_type37
    output reg [32-1:0] jump_type37         ,

    //jump_type38
    output reg [32-1:0] jump_type38         ,

    //jump_type39
    output reg [32-1:0] jump_type39         ,

    //jump_type40
    output reg [32-1:0] jump_type40         ,

    //jump_type41
    output reg [32-1:0] jump_type41         ,

    //jump_type42
    output reg [32-1:0] jump_type42         ,

    //jump_type43
    output reg [32-1:0] jump_type43         ,

    //jump_type44
    output reg [32-1:0] jump_type44         ,

    //jump_type45
    output reg [32-1:0] jump_type45         ,

    //jump_type46
    output reg [32-1:0] jump_type46         ,

    //jump_type47
    output reg [32-1:0] jump_type47         ,

    //jump_type48
    output reg [32-1:0] jump_type48         ,

    //jump_type49
    output reg [32-1:0] jump_type49         ,

    //jump_type50
    output reg [32-1:0] jump_type50         ,

    //jump_type51
    output reg [32-1:0] jump_type51         ,

    //jump_type52
    output reg [32-1:0] jump_type52         ,

    //jump_type53
    output reg [32-1:0] jump_type53         ,

    //jump_type54
    output reg [32-1:0] jump_type54         ,

    //jump_type55
    output reg [32-1:0] jump_type55         ,

    //jump_type56
    output reg [32-1:0] jump_type56         ,

    //jump_type57
    output reg [32-1:0] jump_type57         ,

    //jump_type58
    output reg [32-1:0] jump_type58         ,

    //jump_type59
    output reg [32-1:0] jump_type59         ,

    //jump_type60
    output reg [32-1:0] jump_type60         ,

    //jump_type61
    output reg [32-1:0] jump_type61         ,

    //jump_type62
    output reg [32-1:0] jump_type62         ,

    //jump_type63
    output reg [32-1:0] jump_type63         ,

    //jump_type64
    output reg [32-1:0] jump_type64         ,

    //jump_type65
    output reg [32-1:0] jump_type65         ,

    //jump_type66
    output reg [32-1:0] jump_type66         ,

    //jump_type67
    output reg [32-1:0] jump_type67         ,

    //jump_type68
    output reg [32-1:0] jump_type68         ,

    //jump_type69
    output reg [32-1:0] jump_type69         ,

    //jump_type70
    output reg [32-1:0] jump_type70         ,

    //jump_type71
    output reg [32-1:0] jump_type71         ,

    //jump_type72
    output reg [32-1:0] jump_type72         ,

    //jump_type73
    output reg [32-1:0] jump_type73         ,

    //jump_type74
    output reg [32-1:0] jump_type74         ,

    //jump_type75
    output reg [32-1:0] jump_type75         ,

    //jump_type76
    output reg [32-1:0] jump_type76         ,

    //jump_type77
    output reg [32-1:0] jump_type77         ,

    //jump_type78
    output reg [32-1:0] jump_type78         ,

    //jump_type79
    output reg [32-1:0] jump_type79         ,

    //jump_type80
    output reg [32-1:0] jump_type80         ,

    //jump_type81
    output reg [32-1:0] jump_type81         ,

    //jump_type82
    output reg [32-1:0] jump_type82         ,

    //jump_type83
    output reg [32-1:0] jump_type83         ,

    //jump_type84
    output reg [32-1:0] jump_type84         ,

    //jump_type85
    output reg [32-1:0] jump_type85         ,

    //jump_type86
    output reg [32-1:0] jump_type86         ,

    //jump_type87
    output reg [32-1:0] jump_type87         ,

    //jump_type88
    output reg [32-1:0] jump_type88         ,

    //jump_type89
    output reg [32-1:0] jump_type89         ,

    //jump_type90
    output reg [32-1:0] jump_type90         ,

    //jump_type91
    output reg [32-1:0] jump_type91         ,

    //jump_type92
    output reg [32-1:0] jump_type92         ,

    //jump_type93
    output reg [32-1:0] jump_type93         ,

    //jump_type94
    output reg [32-1:0] jump_type94         ,

    //jump_type95
    output reg [26-1:0] jump_type95         
);

//----------------------------local parameter---------------------------------------------
localparam COMMON_PARA_REG             = 32'h0  ;
localparam DCRC_PARA_REG               = 32'h4  ;
localparam DCRC_INFO_BIT0_REG          = 32'h8  ;
localparam DCRC_INFO_BIT1_REG          = 32'hc  ;
localparam DCRC_INFO_BIT2_REG          = 32'h10 ;
localparam DCRC_INFO_BIT3_REG          = 32'h14 ;
localparam DCRC_INFO_BIT4_REG          = 32'h18 ;
localparam DCRC_INFO_BIT5_REG          = 32'h1c ;
localparam DCRC_INFO_BIT6_REG          = 32'h20 ;
localparam DCRC_INFO_BIT7_REG          = 32'h24 ;
localparam DCRC_INFO_BIT8_REG          = 32'h28 ;
localparam DCRC_INFO_BIT9_REG          = 32'h2c ;
localparam DCRC_INFO_BIT10_REG         = 32'h30 ;
localparam DCRC_INFO_BIT11_REG         = 32'h34 ;
localparam DCRC_INFO_BIT12_REG         = 32'h38 ;
localparam DCRC_INFO_BIT13_REG         = 32'h3c ;
localparam RNTI_VAL01_REG              = 32'h40 ;
localparam RNTI_VAL23_REG              = 32'h44 ;
localparam IL_PATTERN0_REG             = 32'h48 ;
localparam IL_PATTERN1_REG             = 32'h4c ;
localparam IL_PATTERN2_REG             = 32'h50 ;
localparam IL_PATTERN3_REG             = 32'h54 ;
localparam IL_PATTERN4_REG             = 32'h58 ;
localparam IL_PATTERN5_REG             = 32'h5c ;
localparam IL_PATTERN6_REG             = 32'h60 ;
localparam IL_PATTERN7_REG             = 32'h64 ;
localparam IL_PATTERN8_REG             = 32'h68 ;
localparam IL_PATTERN9_REG             = 32'h6c ;
localparam IL_PATTERN10_REG            = 32'h70 ;
localparam IL_PATTERN11_REG            = 32'h74 ;
localparam IL_PATTERN12_REG            = 32'h78 ;
localparam IL_PATTERN13_REG            = 32'h7c ;
localparam IL_PATTERN14_REG            = 32'h80 ;
localparam IL_PATTERN15_REG            = 32'h84 ;
localparam IL_PATTERN16_REG            = 32'h88 ;
localparam IL_PATTERN17_REG            = 32'h8c ;
localparam IL_PATTERN18_REG            = 32'h90 ;
localparam IL_PATTERN19_REG            = 32'h94 ;
localparam IL_PATTERN20_REG            = 32'h98 ;
localparam IL_PATTERN21_REG            = 32'h9c ;
localparam IL_PATTERN22_REG            = 32'ha0 ;
localparam IL_PATTERN23_REG            = 32'ha4 ;
localparam IL_PATTERN24_REG            = 32'ha8 ;
localparam IL_PATTERN25_REG            = 32'hac ;
localparam IL_PATTERN26_REG            = 32'hb0 ;
localparam IL_PATTERN27_REG            = 32'hb4 ;
localparam IL_PATTERN28_REG            = 32'hb8 ;
localparam IL_PATTERN29_REG            = 32'hbc ;
localparam IL_PATTERN30_REG            = 32'hc0 ;
localparam IL_PATTERN31_REG            = 32'hc4 ;
localparam IL_PATTERN32_REG            = 32'hc8 ;
localparam IL_PATTERN33_REG            = 32'hcc ;
localparam IL_PATTERN34_REG            = 32'hd0 ;
localparam IL_PATTERN35_REG            = 32'hd4 ;
localparam IL_PATTERN36_REG            = 32'hd8 ;
localparam IL_PATTERN37_REG            = 32'hdc ;
localparam IL_PATTERN38_REG            = 32'he0 ;
localparam IL_PATTERN39_REG            = 32'he4 ;
localparam IL_PATTERN40_REG            = 32'he8 ;
localparam JUMP_TYPE0_REG              = 32'hec ;
localparam JUMP_TYPE1_REG              = 32'hf0 ;
localparam JUMP_TYPE2_REG              = 32'hf4 ;
localparam JUMP_TYPE3_REG              = 32'hf8 ;
localparam JUMP_TYPE4_REG              = 32'hfc ;
localparam JUMP_TYPE5_REG              = 32'h100;
localparam JUMP_TYPE6_REG              = 32'h104;
localparam JUMP_TYPE7_REG              = 32'h108;
localparam JUMP_TYPE8_REG              = 32'h10c;
localparam JUMP_TYPE9_REG              = 32'h110;
localparam JUMP_TYPE10_REG             = 32'h114;
localparam JUMP_TYPE11_REG             = 32'h118;
localparam JUMP_TYPE12_REG             = 32'h11c;
localparam JUMP_TYPE13_REG             = 32'h120;
localparam JUMP_TYPE14_REG             = 32'h124;
localparam JUMP_TYPE15_REG             = 32'h128;
localparam JUMP_TYPE16_REG             = 32'h12c;
localparam JUMP_TYPE17_REG             = 32'h130;
localparam JUMP_TYPE18_REG             = 32'h134;
localparam JUMP_TYPE19_REG             = 32'h138;
localparam JUMP_TYPE20_REG             = 32'h13c;
localparam JUMP_TYPE21_REG             = 32'h140;
localparam JUMP_TYPE22_REG             = 32'h144;
localparam JUMP_TYPE23_REG             = 32'h148;
localparam JUMP_TYPE24_REG             = 32'h14c;
localparam JUMP_TYPE25_REG             = 32'h150;
localparam JUMP_TYPE26_REG             = 32'h154;
localparam JUMP_TYPE27_REG             = 32'h158;
localparam JUMP_TYPE28_REG             = 32'h15c;
localparam JUMP_TYPE29_REG             = 32'h160;
localparam JUMP_TYPE30_REG             = 32'h164;
localparam JUMP_TYPE31_REG             = 32'h168;
localparam JUMP_TYPE32_REG             = 32'h16c;
localparam JUMP_TYPE33_REG             = 32'h170;
localparam JUMP_TYPE34_REG             = 32'h174;
localparam JUMP_TYPE35_REG             = 32'h178;
localparam JUMP_TYPE36_REG             = 32'h17c;
localparam JUMP_TYPE37_REG             = 32'h180;
localparam JUMP_TYPE38_REG             = 32'h184;
localparam JUMP_TYPE39_REG             = 32'h188;
localparam JUMP_TYPE40_REG             = 32'h18c;
localparam JUMP_TYPE41_REG             = 32'h190;
localparam JUMP_TYPE42_REG             = 32'h194;
localparam JUMP_TYPE43_REG             = 32'h198;
localparam JUMP_TYPE44_REG             = 32'h19c;
localparam JUMP_TYPE45_REG             = 32'h1a0;
localparam JUMP_TYPE46_REG             = 32'h1a4;
localparam JUMP_TYPE47_REG             = 32'h1a8;
localparam JUMP_TYPE48_REG             = 32'h1ac;
localparam JUMP_TYPE49_REG             = 32'h1b0;
localparam JUMP_TYPE50_REG             = 32'h1b4;
localparam JUMP_TYPE51_REG             = 32'h1b8;
localparam JUMP_TYPE52_REG             = 32'h1bc;
localparam JUMP_TYPE53_REG             = 32'h1c0;
localparam JUMP_TYPE54_REG             = 32'h1c4;
localparam JUMP_TYPE55_REG             = 32'h1c8;
localparam JUMP_TYPE56_REG             = 32'h1cc;
localparam JUMP_TYPE57_REG             = 32'h1d0;
localparam JUMP_TYPE58_REG             = 32'h1d4;
localparam JUMP_TYPE59_REG             = 32'h1d8;
localparam JUMP_TYPE60_REG             = 32'h1dc;
localparam JUMP_TYPE61_REG             = 32'h1e0;
localparam JUMP_TYPE62_REG             = 32'h1e4;
localparam JUMP_TYPE63_REG             = 32'h1e8;
localparam JUMP_TYPE64_REG             = 32'h1ec;
localparam JUMP_TYPE65_REG             = 32'h1f0;
localparam JUMP_TYPE66_REG             = 32'h1f4;
localparam JUMP_TYPE67_REG             = 32'h1f8;
localparam JUMP_TYPE68_REG             = 32'h1fc;
localparam JUMP_TYPE69_REG             = 32'h200;
localparam JUMP_TYPE70_REG             = 32'h204;
localparam JUMP_TYPE71_REG             = 32'h208;
localparam JUMP_TYPE72_REG             = 32'h20c;
localparam JUMP_TYPE73_REG             = 32'h210;
localparam JUMP_TYPE74_REG             = 32'h214;
localparam JUMP_TYPE75_REG             = 32'h218;
localparam JUMP_TYPE76_REG             = 32'h21c;
localparam JUMP_TYPE77_REG             = 32'h220;
localparam JUMP_TYPE78_REG             = 32'h224;
localparam JUMP_TYPE79_REG             = 32'h228;
localparam JUMP_TYPE80_REG             = 32'h22c;
localparam JUMP_TYPE81_REG             = 32'h230;
localparam JUMP_TYPE82_REG             = 32'h234;
localparam JUMP_TYPE83_REG             = 32'h238;
localparam JUMP_TYPE84_REG             = 32'h23c;
localparam JUMP_TYPE85_REG             = 32'h240;
localparam JUMP_TYPE86_REG             = 32'h244;
localparam JUMP_TYPE87_REG             = 32'h248;
localparam JUMP_TYPE88_REG             = 32'h24c;
localparam JUMP_TYPE89_REG             = 32'h250;
localparam JUMP_TYPE90_REG             = 32'h254;
localparam JUMP_TYPE91_REG             = 32'h258;
localparam JUMP_TYPE92_REG             = 32'h25c;
localparam JUMP_TYPE93_REG             = 32'h260;
localparam JUMP_TYPE94_REG             = 32'h264;
localparam JUMP_TYPE95_REG             = 32'h268;

//----------------------------local wire/reg declaration------------------------------------------
wire [32-1:0] common_para_reg                ;
wire [32-1:0] dcrc_para_reg                  ;
wire [32-1:0] dcrc_info_bit0_reg             ;
wire [32-1:0] dcrc_info_bit1_reg             ;
wire [32-1:0] dcrc_info_bit2_reg             ;
wire [32-1:0] dcrc_info_bit3_reg             ;
wire [32-1:0] dcrc_info_bit4_reg             ;
wire [32-1:0] dcrc_info_bit5_reg             ;
wire [32-1:0] dcrc_info_bit6_reg             ;
wire [32-1:0] dcrc_info_bit7_reg             ;
wire [32-1:0] dcrc_info_bit8_reg             ;
wire [32-1:0] dcrc_info_bit9_reg             ;
wire [32-1:0] dcrc_info_bit10_reg            ;
wire [32-1:0] dcrc_info_bit11_reg            ;
wire [32-1:0] dcrc_info_bit12_reg            ;
wire [32-1:0] dcrc_info_bit13_reg            ;
wire [32-1:0] rnti_val01_reg                 ;
wire [32-1:0] rnti_val23_reg                 ;
wire [32-1:0] il_pattern0_reg                ;
wire [32-1:0] il_pattern1_reg                ;
wire [32-1:0] il_pattern2_reg                ;
wire [32-1:0] il_pattern3_reg                ;
wire [32-1:0] il_pattern4_reg                ;
wire [32-1:0] il_pattern5_reg                ;
wire [32-1:0] il_pattern6_reg                ;
wire [32-1:0] il_pattern7_reg                ;
wire [32-1:0] il_pattern8_reg                ;
wire [32-1:0] il_pattern9_reg                ;
wire [32-1:0] il_pattern10_reg               ;
wire [32-1:0] il_pattern11_reg               ;
wire [32-1:0] il_pattern12_reg               ;
wire [32-1:0] il_pattern13_reg               ;
wire [32-1:0] il_pattern14_reg               ;
wire [32-1:0] il_pattern15_reg               ;
wire [32-1:0] il_pattern16_reg               ;
wire [32-1:0] il_pattern17_reg               ;
wire [32-1:0] il_pattern18_reg               ;
wire [32-1:0] il_pattern19_reg               ;
wire [32-1:0] il_pattern20_reg               ;
wire [32-1:0] il_pattern21_reg               ;
wire [32-1:0] il_pattern22_reg               ;
wire [32-1:0] il_pattern23_reg               ;
wire [32-1:0] il_pattern24_reg               ;
wire [32-1:0] il_pattern25_reg               ;
wire [32-1:0] il_pattern26_reg               ;
wire [32-1:0] il_pattern27_reg               ;
wire [32-1:0] il_pattern28_reg               ;
wire [32-1:0] il_pattern29_reg               ;
wire [32-1:0] il_pattern30_reg               ;
wire [32-1:0] il_pattern31_reg               ;
wire [32-1:0] il_pattern32_reg               ;
wire [32-1:0] il_pattern33_reg               ;
wire [32-1:0] il_pattern34_reg               ;
wire [32-1:0] il_pattern35_reg               ;
wire [32-1:0] il_pattern36_reg               ;
wire [32-1:0] il_pattern37_reg               ;
wire [32-1:0] il_pattern38_reg               ;
wire [32-1:0] il_pattern39_reg               ;
wire [32-1:0] il_pattern40_reg               ;
wire [32-1:0] jump_type0_reg                 ;
wire [32-1:0] jump_type1_reg                 ;
wire [32-1:0] jump_type2_reg                 ;
wire [32-1:0] jump_type3_reg                 ;
wire [32-1:0] jump_type4_reg                 ;
wire [32-1:0] jump_type5_reg                 ;
wire [32-1:0] jump_type6_reg                 ;
wire [32-1:0] jump_type7_reg                 ;
wire [32-1:0] jump_type8_reg                 ;
wire [32-1:0] jump_type9_reg                 ;
wire [32-1:0] jump_type10_reg                ;
wire [32-1:0] jump_type11_reg                ;
wire [32-1:0] jump_type12_reg                ;
wire [32-1:0] jump_type13_reg                ;
wire [32-1:0] jump_type14_reg                ;
wire [32-1:0] jump_type15_reg                ;
wire [32-1:0] jump_type16_reg                ;
wire [32-1:0] jump_type17_reg                ;
wire [32-1:0] jump_type18_reg                ;
wire [32-1:0] jump_type19_reg                ;
wire [32-1:0] jump_type20_reg                ;
wire [32-1:0] jump_type21_reg                ;
wire [32-1:0] jump_type22_reg                ;
wire [32-1:0] jump_type23_reg                ;
wire [32-1:0] jump_type24_reg                ;
wire [32-1:0] jump_type25_reg                ;
wire [32-1:0] jump_type26_reg                ;
wire [32-1:0] jump_type27_reg                ;
wire [32-1:0] jump_type28_reg                ;
wire [32-1:0] jump_type29_reg                ;
wire [32-1:0] jump_type30_reg                ;
wire [32-1:0] jump_type31_reg                ;
wire [32-1:0] jump_type32_reg                ;
wire [32-1:0] jump_type33_reg                ;
wire [32-1:0] jump_type34_reg                ;
wire [32-1:0] jump_type35_reg                ;
wire [32-1:0] jump_type36_reg                ;
wire [32-1:0] jump_type37_reg                ;
wire [32-1:0] jump_type38_reg                ;
wire [32-1:0] jump_type39_reg                ;
wire [32-1:0] jump_type40_reg                ;
wire [32-1:0] jump_type41_reg                ;
wire [32-1:0] jump_type42_reg                ;
wire [32-1:0] jump_type43_reg                ;
wire [32-1:0] jump_type44_reg                ;
wire [32-1:0] jump_type45_reg                ;
wire [32-1:0] jump_type46_reg                ;
wire [32-1:0] jump_type47_reg                ;
wire [32-1:0] jump_type48_reg                ;
wire [32-1:0] jump_type49_reg                ;
wire [32-1:0] jump_type50_reg                ;
wire [32-1:0] jump_type51_reg                ;
wire [32-1:0] jump_type52_reg                ;
wire [32-1:0] jump_type53_reg                ;
wire [32-1:0] jump_type54_reg                ;
wire [32-1:0] jump_type55_reg                ;
wire [32-1:0] jump_type56_reg                ;
wire [32-1:0] jump_type57_reg                ;
wire [32-1:0] jump_type58_reg                ;
wire [32-1:0] jump_type59_reg                ;
wire [32-1:0] jump_type60_reg                ;
wire [32-1:0] jump_type61_reg                ;
wire [32-1:0] jump_type62_reg                ;
wire [32-1:0] jump_type63_reg                ;
wire [32-1:0] jump_type64_reg                ;
wire [32-1:0] jump_type65_reg                ;
wire [32-1:0] jump_type66_reg                ;
wire [32-1:0] jump_type67_reg                ;
wire [32-1:0] jump_type68_reg                ;
wire [32-1:0] jump_type69_reg                ;
wire [32-1:0] jump_type70_reg                ;
wire [32-1:0] jump_type71_reg                ;
wire [32-1:0] jump_type72_reg                ;
wire [32-1:0] jump_type73_reg                ;
wire [32-1:0] jump_type74_reg                ;
wire [32-1:0] jump_type75_reg                ;
wire [32-1:0] jump_type76_reg                ;
wire [32-1:0] jump_type77_reg                ;
wire [32-1:0] jump_type78_reg                ;
wire [32-1:0] jump_type79_reg                ;
wire [32-1:0] jump_type80_reg                ;
wire [32-1:0] jump_type81_reg                ;
wire [32-1:0] jump_type82_reg                ;
wire [32-1:0] jump_type83_reg                ;
wire [32-1:0] jump_type84_reg                ;
wire [32-1:0] jump_type85_reg                ;
wire [32-1:0] jump_type86_reg                ;
wire [32-1:0] jump_type87_reg                ;
wire [32-1:0] jump_type88_reg                ;
wire [32-1:0] jump_type89_reg                ;
wire [32-1:0] jump_type90_reg                ;
wire [32-1:0] jump_type91_reg                ;
wire [32-1:0] jump_type92_reg                ;
wire [32-1:0] jump_type93_reg                ;
wire [32-1:0] jump_type94_reg                ;
wire [32-1:0] jump_type95_reg                ;

//----------------------------control logic---------------------------------------------
wire common_para_wr                  = ( waddr == COMMON_PARA_REG ) && wen;
wire dcrc_para_wr                    = ( waddr == DCRC_PARA_REG ) && wen;
wire dcrc_info_bit0_wr               = ( waddr == DCRC_INFO_BIT0_REG ) && wen;
wire dcrc_info_bit1_wr               = ( waddr == DCRC_INFO_BIT1_REG ) && wen;
wire dcrc_info_bit2_wr               = ( waddr == DCRC_INFO_BIT2_REG ) && wen;
wire dcrc_info_bit3_wr               = ( waddr == DCRC_INFO_BIT3_REG ) && wen;
wire dcrc_info_bit4_wr               = ( waddr == DCRC_INFO_BIT4_REG ) && wen;
wire dcrc_info_bit5_wr               = ( waddr == DCRC_INFO_BIT5_REG ) && wen;
wire dcrc_info_bit6_wr               = ( waddr == DCRC_INFO_BIT6_REG ) && wen;
wire dcrc_info_bit7_wr               = ( waddr == DCRC_INFO_BIT7_REG ) && wen;
wire dcrc_info_bit8_wr               = ( waddr == DCRC_INFO_BIT8_REG ) && wen;
wire dcrc_info_bit9_wr               = ( waddr == DCRC_INFO_BIT9_REG ) && wen;
wire dcrc_info_bit10_wr              = ( waddr == DCRC_INFO_BIT10_REG ) && wen;
wire dcrc_info_bit11_wr              = ( waddr == DCRC_INFO_BIT11_REG ) && wen;
wire dcrc_info_bit12_wr              = ( waddr == DCRC_INFO_BIT12_REG ) && wen;
wire dcrc_info_bit13_wr              = ( waddr == DCRC_INFO_BIT13_REG ) && wen;
wire rnti_val01_wr                   = ( waddr == RNTI_VAL01_REG ) && wen;
wire rnti_val23_wr                   = ( waddr == RNTI_VAL23_REG ) && wen;
wire il_pattern0_wr                  = ( waddr == IL_PATTERN0_REG ) && wen;
wire il_pattern1_wr                  = ( waddr == IL_PATTERN1_REG ) && wen;
wire il_pattern2_wr                  = ( waddr == IL_PATTERN2_REG ) && wen;
wire il_pattern3_wr                  = ( waddr == IL_PATTERN3_REG ) && wen;
wire il_pattern4_wr                  = ( waddr == IL_PATTERN4_REG ) && wen;
wire il_pattern5_wr                  = ( waddr == IL_PATTERN5_REG ) && wen;
wire il_pattern6_wr                  = ( waddr == IL_PATTERN6_REG ) && wen;
wire il_pattern7_wr                  = ( waddr == IL_PATTERN7_REG ) && wen;
wire il_pattern8_wr                  = ( waddr == IL_PATTERN8_REG ) && wen;
wire il_pattern9_wr                  = ( waddr == IL_PATTERN9_REG ) && wen;
wire il_pattern10_wr                 = ( waddr == IL_PATTERN10_REG ) && wen;
wire il_pattern11_wr                 = ( waddr == IL_PATTERN11_REG ) && wen;
wire il_pattern12_wr                 = ( waddr == IL_PATTERN12_REG ) && wen;
wire il_pattern13_wr                 = ( waddr == IL_PATTERN13_REG ) && wen;
wire il_pattern14_wr                 = ( waddr == IL_PATTERN14_REG ) && wen;
wire il_pattern15_wr                 = ( waddr == IL_PATTERN15_REG ) && wen;
wire il_pattern16_wr                 = ( waddr == IL_PATTERN16_REG ) && wen;
wire il_pattern17_wr                 = ( waddr == IL_PATTERN17_REG ) && wen;
wire il_pattern18_wr                 = ( waddr == IL_PATTERN18_REG ) && wen;
wire il_pattern19_wr                 = ( waddr == IL_PATTERN19_REG ) && wen;
wire il_pattern20_wr                 = ( waddr == IL_PATTERN20_REG ) && wen;
wire il_pattern21_wr                 = ( waddr == IL_PATTERN21_REG ) && wen;
wire il_pattern22_wr                 = ( waddr == IL_PATTERN22_REG ) && wen;
wire il_pattern23_wr                 = ( waddr == IL_PATTERN23_REG ) && wen;
wire il_pattern24_wr                 = ( waddr == IL_PATTERN24_REG ) && wen;
wire il_pattern25_wr                 = ( waddr == IL_PATTERN25_REG ) && wen;
wire il_pattern26_wr                 = ( waddr == IL_PATTERN26_REG ) && wen;
wire il_pattern27_wr                 = ( waddr == IL_PATTERN27_REG ) && wen;
wire il_pattern28_wr                 = ( waddr == IL_PATTERN28_REG ) && wen;
wire il_pattern29_wr                 = ( waddr == IL_PATTERN29_REG ) && wen;
wire il_pattern30_wr                 = ( waddr == IL_PATTERN30_REG ) && wen;
wire il_pattern31_wr                 = ( waddr == IL_PATTERN31_REG ) && wen;
wire il_pattern32_wr                 = ( waddr == IL_PATTERN32_REG ) && wen;
wire il_pattern33_wr                 = ( waddr == IL_PATTERN33_REG ) && wen;
wire il_pattern34_wr                 = ( waddr == IL_PATTERN34_REG ) && wen;
wire il_pattern35_wr                 = ( waddr == IL_PATTERN35_REG ) && wen;
wire il_pattern36_wr                 = ( waddr == IL_PATTERN36_REG ) && wen;
wire il_pattern37_wr                 = ( waddr == IL_PATTERN37_REG ) && wen;
wire il_pattern38_wr                 = ( waddr == IL_PATTERN38_REG ) && wen;
wire il_pattern39_wr                 = ( waddr == IL_PATTERN39_REG ) && wen;
wire il_pattern40_wr                 = ( waddr == IL_PATTERN40_REG ) && wen;
wire jump_type0_wr                   = ( waddr == JUMP_TYPE0_REG ) && wen;
wire jump_type1_wr                   = ( waddr == JUMP_TYPE1_REG ) && wen;
wire jump_type2_wr                   = ( waddr == JUMP_TYPE2_REG ) && wen;
wire jump_type3_wr                   = ( waddr == JUMP_TYPE3_REG ) && wen;
wire jump_type4_wr                   = ( waddr == JUMP_TYPE4_REG ) && wen;
wire jump_type5_wr                   = ( waddr == JUMP_TYPE5_REG ) && wen;
wire jump_type6_wr                   = ( waddr == JUMP_TYPE6_REG ) && wen;
wire jump_type7_wr                   = ( waddr == JUMP_TYPE7_REG ) && wen;
wire jump_type8_wr                   = ( waddr == JUMP_TYPE8_REG ) && wen;
wire jump_type9_wr                   = ( waddr == JUMP_TYPE9_REG ) && wen;
wire jump_type10_wr                  = ( waddr == JUMP_TYPE10_REG ) && wen;
wire jump_type11_wr                  = ( waddr == JUMP_TYPE11_REG ) && wen;
wire jump_type12_wr                  = ( waddr == JUMP_TYPE12_REG ) && wen;
wire jump_type13_wr                  = ( waddr == JUMP_TYPE13_REG ) && wen;
wire jump_type14_wr                  = ( waddr == JUMP_TYPE14_REG ) && wen;
wire jump_type15_wr                  = ( waddr == JUMP_TYPE15_REG ) && wen;
wire jump_type16_wr                  = ( waddr == JUMP_TYPE16_REG ) && wen;
wire jump_type17_wr                  = ( waddr == JUMP_TYPE17_REG ) && wen;
wire jump_type18_wr                  = ( waddr == JUMP_TYPE18_REG ) && wen;
wire jump_type19_wr                  = ( waddr == JUMP_TYPE19_REG ) && wen;
wire jump_type20_wr                  = ( waddr == JUMP_TYPE20_REG ) && wen;
wire jump_type21_wr                  = ( waddr == JUMP_TYPE21_REG ) && wen;
wire jump_type22_wr                  = ( waddr == JUMP_TYPE22_REG ) && wen;
wire jump_type23_wr                  = ( waddr == JUMP_TYPE23_REG ) && wen;
wire jump_type24_wr                  = ( waddr == JUMP_TYPE24_REG ) && wen;
wire jump_type25_wr                  = ( waddr == JUMP_TYPE25_REG ) && wen;
wire jump_type26_wr                  = ( waddr == JUMP_TYPE26_REG ) && wen;
wire jump_type27_wr                  = ( waddr == JUMP_TYPE27_REG ) && wen;
wire jump_type28_wr                  = ( waddr == JUMP_TYPE28_REG ) && wen;
wire jump_type29_wr                  = ( waddr == JUMP_TYPE29_REG ) && wen;
wire jump_type30_wr                  = ( waddr == JUMP_TYPE30_REG ) && wen;
wire jump_type31_wr                  = ( waddr == JUMP_TYPE31_REG ) && wen;
wire jump_type32_wr                  = ( waddr == JUMP_TYPE32_REG ) && wen;
wire jump_type33_wr                  = ( waddr == JUMP_TYPE33_REG ) && wen;
wire jump_type34_wr                  = ( waddr == JUMP_TYPE34_REG ) && wen;
wire jump_type35_wr                  = ( waddr == JUMP_TYPE35_REG ) && wen;
wire jump_type36_wr                  = ( waddr == JUMP_TYPE36_REG ) && wen;
wire jump_type37_wr                  = ( waddr == JUMP_TYPE37_REG ) && wen;
wire jump_type38_wr                  = ( waddr == JUMP_TYPE38_REG ) && wen;
wire jump_type39_wr                  = ( waddr == JUMP_TYPE39_REG ) && wen;
wire jump_type40_wr                  = ( waddr == JUMP_TYPE40_REG ) && wen;
wire jump_type41_wr                  = ( waddr == JUMP_TYPE41_REG ) && wen;
wire jump_type42_wr                  = ( waddr == JUMP_TYPE42_REG ) && wen;
wire jump_type43_wr                  = ( waddr == JUMP_TYPE43_REG ) && wen;
wire jump_type44_wr                  = ( waddr == JUMP_TYPE44_REG ) && wen;
wire jump_type45_wr                  = ( waddr == JUMP_TYPE45_REG ) && wen;
wire jump_type46_wr                  = ( waddr == JUMP_TYPE46_REG ) && wen;
wire jump_type47_wr                  = ( waddr == JUMP_TYPE47_REG ) && wen;
wire jump_type48_wr                  = ( waddr == JUMP_TYPE48_REG ) && wen;
wire jump_type49_wr                  = ( waddr == JUMP_TYPE49_REG ) && wen;
wire jump_type50_wr                  = ( waddr == JUMP_TYPE50_REG ) && wen;
wire jump_type51_wr                  = ( waddr == JUMP_TYPE51_REG ) && wen;
wire jump_type52_wr                  = ( waddr == JUMP_TYPE52_REG ) && wen;
wire jump_type53_wr                  = ( waddr == JUMP_TYPE53_REG ) && wen;
wire jump_type54_wr                  = ( waddr == JUMP_TYPE54_REG ) && wen;
wire jump_type55_wr                  = ( waddr == JUMP_TYPE55_REG ) && wen;
wire jump_type56_wr                  = ( waddr == JUMP_TYPE56_REG ) && wen;
wire jump_type57_wr                  = ( waddr == JUMP_TYPE57_REG ) && wen;
wire jump_type58_wr                  = ( waddr == JUMP_TYPE58_REG ) && wen;
wire jump_type59_wr                  = ( waddr == JUMP_TYPE59_REG ) && wen;
wire jump_type60_wr                  = ( waddr == JUMP_TYPE60_REG ) && wen;
wire jump_type61_wr                  = ( waddr == JUMP_TYPE61_REG ) && wen;
wire jump_type62_wr                  = ( waddr == JUMP_TYPE62_REG ) && wen;
wire jump_type63_wr                  = ( waddr == JUMP_TYPE63_REG ) && wen;
wire jump_type64_wr                  = ( waddr == JUMP_TYPE64_REG ) && wen;
wire jump_type65_wr                  = ( waddr == JUMP_TYPE65_REG ) && wen;
wire jump_type66_wr                  = ( waddr == JUMP_TYPE66_REG ) && wen;
wire jump_type67_wr                  = ( waddr == JUMP_TYPE67_REG ) && wen;
wire jump_type68_wr                  = ( waddr == JUMP_TYPE68_REG ) && wen;
wire jump_type69_wr                  = ( waddr == JUMP_TYPE69_REG ) && wen;
wire jump_type70_wr                  = ( waddr == JUMP_TYPE70_REG ) && wen;
wire jump_type71_wr                  = ( waddr == JUMP_TYPE71_REG ) && wen;
wire jump_type72_wr                  = ( waddr == JUMP_TYPE72_REG ) && wen;
wire jump_type73_wr                  = ( waddr == JUMP_TYPE73_REG ) && wen;
wire jump_type74_wr                  = ( waddr == JUMP_TYPE74_REG ) && wen;
wire jump_type75_wr                  = ( waddr == JUMP_TYPE75_REG ) && wen;
wire jump_type76_wr                  = ( waddr == JUMP_TYPE76_REG ) && wen;
wire jump_type77_wr                  = ( waddr == JUMP_TYPE77_REG ) && wen;
wire jump_type78_wr                  = ( waddr == JUMP_TYPE78_REG ) && wen;
wire jump_type79_wr                  = ( waddr == JUMP_TYPE79_REG ) && wen;
wire jump_type80_wr                  = ( waddr == JUMP_TYPE80_REG ) && wen;
wire jump_type81_wr                  = ( waddr == JUMP_TYPE81_REG ) && wen;
wire jump_type82_wr                  = ( waddr == JUMP_TYPE82_REG ) && wen;
wire jump_type83_wr                  = ( waddr == JUMP_TYPE83_REG ) && wen;
wire jump_type84_wr                  = ( waddr == JUMP_TYPE84_REG ) && wen;
wire jump_type85_wr                  = ( waddr == JUMP_TYPE85_REG ) && wen;
wire jump_type86_wr                  = ( waddr == JUMP_TYPE86_REG ) && wen;
wire jump_type87_wr                  = ( waddr == JUMP_TYPE87_REG ) && wen;
wire jump_type88_wr                  = ( waddr == JUMP_TYPE88_REG ) && wen;
wire jump_type89_wr                  = ( waddr == JUMP_TYPE89_REG ) && wen;
wire jump_type90_wr                  = ( waddr == JUMP_TYPE90_REG ) && wen;
wire jump_type91_wr                  = ( waddr == JUMP_TYPE91_REG ) && wen;
wire jump_type92_wr                  = ( waddr == JUMP_TYPE92_REG ) && wen;
wire jump_type93_wr                  = ( waddr == JUMP_TYPE93_REG ) && wen;
wire jump_type94_wr                  = ( waddr == JUMP_TYPE94_REG ) && wen;
wire jump_type95_wr                  = ( waddr == JUMP_TYPE95_REG ) && wen;

//--------------------------------processing------------------------------------------------

//common_para
assign common_para_reg[31:26] = 6'h0                     ;
assign common_para_reg[25:24] = rm_mode                  ;
assign common_para_reg[23:22] = rnti_num                 ;
assign common_para_reg[21]   = crc_flag                 ;
assign common_para_reg[20:19] = list_num                 ;
assign common_para_reg[18]   = leaf_mode                ;
assign common_para_reg[17:10] = param_k                  ;
assign common_para_reg[9:2]  = param_a                  ;
assign common_para_reg[1:0]  = param_n                  ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        rm_mode <= 2'h0;
    else if( common_para_wr )
        rm_mode <= wdata[25:24];
end

always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        rnti_num <= 2'h0;
    else if( common_para_wr )
        rnti_num <= wdata[23:22];
end

always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        crc_flag <= 1'h0;
    else if( common_para_wr )
        crc_flag <= wdata[21];
end

always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        list_num <= 2'h0;
    else if( common_para_wr )
        list_num <= wdata[20:19];
end

always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        leaf_mode <= 1'h0;
    else if( common_para_wr )
        leaf_mode <= wdata[18];
end

always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        param_k <= 8'h0;
    else if( common_para_wr )
        param_k <= wdata[17:10];
end

always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        param_a <= 8'h0;
    else if( common_para_wr )
        param_a <= wdata[9:2];
end

always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        param_n <= 2'h0;
    else if( common_para_wr )
        param_n <= wdata[1:0];
end


//dcrc_para
assign dcrc_para_reg[31:30]      = 2'h0                         ;
assign dcrc_para_reg[29:6]       = dcrc_info_idx                ;
assign dcrc_para_reg[5]          = dcrc_mode                    ;
assign dcrc_para_reg[4:2]        = dcrc_reg_ini                 ;
assign dcrc_para_reg[1:0]        = dcrc_num                     ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        dcrc_info_idx <= 24'h0;
    else if( dcrc_para_wr )
        dcrc_info_idx <= wdata[29:6];
end

always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        dcrc_mode <= 1'h0;
    else if( dcrc_para_wr )
        dcrc_mode <= wdata[5];
end

always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        dcrc_reg_ini <= 3'h0;
    else if( dcrc_para_wr )
        dcrc_reg_ini <= wdata[4:2];
end

always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        dcrc_num <= 2'h0;
    else if( dcrc_para_wr )
        dcrc_num <= wdata[1:0];
end


//dcrc_info_bit0
assign dcrc_info_bit0_reg[31:0]   = dcrc_info_bit0                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        dcrc_info_bit0 <= 32'h0;
    else if( dcrc_info_bit0_wr )
        dcrc_info_bit0 <= wdata[31:0];
end


//dcrc_info_bit1
assign dcrc_info_bit1_reg[31:0]   = dcrc_info_bit1                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        dcrc_info_bit1 <= 32'h0;
    else if( dcrc_info_bit1_wr )
        dcrc_info_bit1 <= wdata[31:0];
end


//dcrc_info_bit2
assign dcrc_info_bit2_reg[31:0]   = dcrc_info_bit2                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        dcrc_info_bit2 <= 32'h0;
    else if( dcrc_info_bit2_wr )
        dcrc_info_bit2 <= wdata[31:0];
end


//dcrc_info_bit3
assign dcrc_info_bit3_reg[31:0]   = dcrc_info_bit3                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        dcrc_info_bit3 <= 32'h0;
    else if( dcrc_info_bit3_wr )
        dcrc_info_bit3 <= wdata[31:0];
end


//dcrc_info_bit4
assign dcrc_info_bit4_reg[31:0]   = dcrc_info_bit4                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        dcrc_info_bit4 <= 32'h0;
    else if( dcrc_info_bit4_wr )
        dcrc_info_bit4 <= wdata[31:0];
end


//dcrc_info_bit5
assign dcrc_info_bit5_reg[31:0]   = dcrc_info_bit5                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        dcrc_info_bit5 <= 32'h0;
    else if( dcrc_info_bit5_wr )
        dcrc_info_bit5 <= wdata[31:0];
end


//dcrc_info_bit6
assign dcrc_info_bit6_reg[31:0]   = dcrc_info_bit6                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        dcrc_info_bit6 <= 32'h0;
    else if( dcrc_info_bit6_wr )
        dcrc_info_bit6 <= wdata[31:0];
end


//dcrc_info_bit7
assign dcrc_info_bit7_reg[31:0]   = dcrc_info_bit7                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        dcrc_info_bit7 <= 32'h0;
    else if( dcrc_info_bit7_wr )
        dcrc_info_bit7 <= wdata[31:0];
end


//dcrc_info_bit8
assign dcrc_info_bit8_reg[31:0]   = dcrc_info_bit8                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        dcrc_info_bit8 <= 32'h0;
    else if( dcrc_info_bit8_wr )
        dcrc_info_bit8 <= wdata[31:0];
end


//dcrc_info_bit9
assign dcrc_info_bit9_reg[31:0]   = dcrc_info_bit9                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        dcrc_info_bit9 <= 32'h0;
    else if( dcrc_info_bit9_wr )
        dcrc_info_bit9 <= wdata[31:0];
end


//dcrc_info_bit10
assign dcrc_info_bit10_reg[31:0]   = dcrc_info_bit10                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        dcrc_info_bit10 <= 32'h0;
    else if( dcrc_info_bit10_wr )
        dcrc_info_bit10 <= wdata[31:0];
end


//dcrc_info_bit11
assign dcrc_info_bit11_reg[31:0]   = dcrc_info_bit11                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        dcrc_info_bit11 <= 32'h0;
    else if( dcrc_info_bit11_wr )
        dcrc_info_bit11 <= wdata[31:0];
end


//dcrc_info_bit12
assign dcrc_info_bit12_reg[31:0]   = dcrc_info_bit12                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        dcrc_info_bit12 <= 32'h0;
    else if( dcrc_info_bit12_wr )
        dcrc_info_bit12 <= wdata[31:0];
end


//dcrc_info_bit13
assign dcrc_info_bit13_reg[31:13]  = 19'h0                          ;
assign dcrc_info_bit13_reg[12:0]   = dcrc_info_bit13                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        dcrc_info_bit13 <= 13'h0;
    else if( dcrc_info_bit13_wr )
        dcrc_info_bit13 <= wdata[12:0];
end


//rnti_val01
assign rnti_val01_reg[31:16] = rnti_val1                ;
assign rnti_val01_reg[15:0]  = rnti_val0                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        rnti_val1 <= 16'h0;
    else if( rnti_val01_wr )
        rnti_val1 <= wdata[31:16];
end

always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        rnti_val0 <= 16'h0;
    else if( rnti_val01_wr )
        rnti_val0 <= wdata[15:0];
end


//rnti_val23
assign rnti_val23_reg[31:16] = rnti_val3                ;
assign rnti_val23_reg[15:0]  = rnti_val2                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        rnti_val3 <= 16'h0;
    else if( rnti_val23_wr )
        rnti_val3 <= wdata[31:16];
end

always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        rnti_val2 <= 16'h0;
    else if( rnti_val23_wr )
        rnti_val2 <= wdata[15:0];
end


//il_pattern0
assign il_pattern0_reg[31:0]   = il_pattern0                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern0 <= 32'h0;
    else if( il_pattern0_wr )
        il_pattern0 <= wdata[31:0];
end


//il_pattern1
assign il_pattern1_reg[31:0]   = il_pattern1                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern1 <= 32'h0;
    else if( il_pattern1_wr )
        il_pattern1 <= wdata[31:0];
end


//il_pattern2
assign il_pattern2_reg[31:0]   = il_pattern2                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern2 <= 32'h0;
    else if( il_pattern2_wr )
        il_pattern2 <= wdata[31:0];
end


//il_pattern3
assign il_pattern3_reg[31:0]   = il_pattern3                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern3 <= 32'h0;
    else if( il_pattern3_wr )
        il_pattern3 <= wdata[31:0];
end


//il_pattern4
assign il_pattern4_reg[31:0]   = il_pattern4                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern4 <= 32'h0;
    else if( il_pattern4_wr )
        il_pattern4 <= wdata[31:0];
end


//il_pattern5
assign il_pattern5_reg[31:0]   = il_pattern5                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern5 <= 32'h0;
    else if( il_pattern5_wr )
        il_pattern5 <= wdata[31:0];
end


//il_pattern6
assign il_pattern6_reg[31:0]   = il_pattern6                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern6 <= 32'h0;
    else if( il_pattern6_wr )
        il_pattern6 <= wdata[31:0];
end


//il_pattern7
assign il_pattern7_reg[31:0]   = il_pattern7                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern7 <= 32'h0;
    else if( il_pattern7_wr )
        il_pattern7 <= wdata[31:0];
end


//il_pattern8
assign il_pattern8_reg[31:0]   = il_pattern8                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern8 <= 32'h0;
    else if( il_pattern8_wr )
        il_pattern8 <= wdata[31:0];
end


//il_pattern9
assign il_pattern9_reg[31:0]   = il_pattern9                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern9 <= 32'h0;
    else if( il_pattern9_wr )
        il_pattern9 <= wdata[31:0];
end


//il_pattern10
assign il_pattern10_reg[31:0]   = il_pattern10                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern10 <= 32'h0;
    else if( il_pattern10_wr )
        il_pattern10 <= wdata[31:0];
end


//il_pattern11
assign il_pattern11_reg[31:0]   = il_pattern11                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern11 <= 32'h0;
    else if( il_pattern11_wr )
        il_pattern11 <= wdata[31:0];
end


//il_pattern12
assign il_pattern12_reg[31:0]   = il_pattern12                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern12 <= 32'h0;
    else if( il_pattern12_wr )
        il_pattern12 <= wdata[31:0];
end


//il_pattern13
assign il_pattern13_reg[31:0]   = il_pattern13                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern13 <= 32'h0;
    else if( il_pattern13_wr )
        il_pattern13 <= wdata[31:0];
end


//il_pattern14
assign il_pattern14_reg[31:0]   = il_pattern14                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern14 <= 32'h0;
    else if( il_pattern14_wr )
        il_pattern14 <= wdata[31:0];
end


//il_pattern15
assign il_pattern15_reg[31:0]   = il_pattern15                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern15 <= 32'h0;
    else if( il_pattern15_wr )
        il_pattern15 <= wdata[31:0];
end


//il_pattern16
assign il_pattern16_reg[31:0]   = il_pattern16                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern16 <= 32'h0;
    else if( il_pattern16_wr )
        il_pattern16 <= wdata[31:0];
end


//il_pattern17
assign il_pattern17_reg[31:0]   = il_pattern17                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern17 <= 32'h0;
    else if( il_pattern17_wr )
        il_pattern17 <= wdata[31:0];
end


//il_pattern18
assign il_pattern18_reg[31:0]   = il_pattern18                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern18 <= 32'h0;
    else if( il_pattern18_wr )
        il_pattern18 <= wdata[31:0];
end


//il_pattern19
assign il_pattern19_reg[31:0]   = il_pattern19                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern19 <= 32'h0;
    else if( il_pattern19_wr )
        il_pattern19 <= wdata[31:0];
end


//il_pattern20
assign il_pattern20_reg[31:0]   = il_pattern20                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern20 <= 32'h0;
    else if( il_pattern20_wr )
        il_pattern20 <= wdata[31:0];
end


//il_pattern21
assign il_pattern21_reg[31:0]   = il_pattern21                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern21 <= 32'h0;
    else if( il_pattern21_wr )
        il_pattern21 <= wdata[31:0];
end


//il_pattern22
assign il_pattern22_reg[31:0]   = il_pattern22                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern22 <= 32'h0;
    else if( il_pattern22_wr )
        il_pattern22 <= wdata[31:0];
end


//il_pattern23
assign il_pattern23_reg[31:0]   = il_pattern23                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern23 <= 32'h0;
    else if( il_pattern23_wr )
        il_pattern23 <= wdata[31:0];
end


//il_pattern24
assign il_pattern24_reg[31:0]   = il_pattern24                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern24 <= 32'h0;
    else if( il_pattern24_wr )
        il_pattern24 <= wdata[31:0];
end


//il_pattern25
assign il_pattern25_reg[31:0]   = il_pattern25                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern25 <= 32'h0;
    else if( il_pattern25_wr )
        il_pattern25 <= wdata[31:0];
end


//il_pattern26
assign il_pattern26_reg[31:0]   = il_pattern26                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern26 <= 32'h0;
    else if( il_pattern26_wr )
        il_pattern26 <= wdata[31:0];
end


//il_pattern27
assign il_pattern27_reg[31:0]   = il_pattern27                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern27 <= 32'h0;
    else if( il_pattern27_wr )
        il_pattern27 <= wdata[31:0];
end


//il_pattern28
assign il_pattern28_reg[31:0]   = il_pattern28                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern28 <= 32'h0;
    else if( il_pattern28_wr )
        il_pattern28 <= wdata[31:0];
end


//il_pattern29
assign il_pattern29_reg[31:0]   = il_pattern29                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern29 <= 32'h0;
    else if( il_pattern29_wr )
        il_pattern29 <= wdata[31:0];
end


//il_pattern30
assign il_pattern30_reg[31:0]   = il_pattern30                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern30 <= 32'h0;
    else if( il_pattern30_wr )
        il_pattern30 <= wdata[31:0];
end


//il_pattern31
assign il_pattern31_reg[31:0]   = il_pattern31                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern31 <= 32'h0;
    else if( il_pattern31_wr )
        il_pattern31 <= wdata[31:0];
end


//il_pattern32
assign il_pattern32_reg[31:0]   = il_pattern32                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern32 <= 32'h0;
    else if( il_pattern32_wr )
        il_pattern32 <= wdata[31:0];
end


//il_pattern33
assign il_pattern33_reg[31:0]   = il_pattern33                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern33 <= 32'h0;
    else if( il_pattern33_wr )
        il_pattern33 <= wdata[31:0];
end


//il_pattern34
assign il_pattern34_reg[31:0]   = il_pattern34                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern34 <= 32'h0;
    else if( il_pattern34_wr )
        il_pattern34 <= wdata[31:0];
end


//il_pattern35
assign il_pattern35_reg[31:0]   = il_pattern35                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern35 <= 32'h0;
    else if( il_pattern35_wr )
        il_pattern35 <= wdata[31:0];
end


//il_pattern36
assign il_pattern36_reg[31:0]   = il_pattern36                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern36 <= 32'h0;
    else if( il_pattern36_wr )
        il_pattern36 <= wdata[31:0];
end


//il_pattern37
assign il_pattern37_reg[31:0]   = il_pattern37                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern37 <= 32'h0;
    else if( il_pattern37_wr )
        il_pattern37 <= wdata[31:0];
end


//il_pattern38
assign il_pattern38_reg[31:0]   = il_pattern38                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern38 <= 32'h0;
    else if( il_pattern38_wr )
        il_pattern38 <= wdata[31:0];
end


//il_pattern39
assign il_pattern39_reg[31:0]   = il_pattern39                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern39 <= 32'h0;
    else if( il_pattern39_wr )
        il_pattern39 <= wdata[31:0];
end


//il_pattern40
assign il_pattern40_reg[31:0]   = il_pattern40                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        il_pattern40 <= 32'h0;
    else if( il_pattern40_wr )
        il_pattern40 <= wdata[31:0];
end


//jump_type0
assign jump_type0_reg[31:0]   = jump_type0                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type0 <= 32'h0;
    else if( jump_type0_wr )
        jump_type0 <= wdata[31:0];
end


//jump_type1
assign jump_type1_reg[31:0]   = jump_type1                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type1 <= 32'h0;
    else if( jump_type1_wr )
        jump_type1 <= wdata[31:0];
end


//jump_type2
assign jump_type2_reg[31:0]   = jump_type2                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type2 <= 32'h0;
    else if( jump_type2_wr )
        jump_type2 <= wdata[31:0];
end


//jump_type3
assign jump_type3_reg[31:0]   = jump_type3                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type3 <= 32'h0;
    else if( jump_type3_wr )
        jump_type3 <= wdata[31:0];
end


//jump_type4
assign jump_type4_reg[31:0]   = jump_type4                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type4 <= 32'h0;
    else if( jump_type4_wr )
        jump_type4 <= wdata[31:0];
end


//jump_type5
assign jump_type5_reg[31:0]   = jump_type5                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type5 <= 32'h0;
    else if( jump_type5_wr )
        jump_type5 <= wdata[31:0];
end


//jump_type6
assign jump_type6_reg[31:0]   = jump_type6                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type6 <= 32'h0;
    else if( jump_type6_wr )
        jump_type6 <= wdata[31:0];
end


//jump_type7
assign jump_type7_reg[31:0]   = jump_type7                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type7 <= 32'h0;
    else if( jump_type7_wr )
        jump_type7 <= wdata[31:0];
end


//jump_type8
assign jump_type8_reg[31:0]   = jump_type8                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type8 <= 32'h0;
    else if( jump_type8_wr )
        jump_type8 <= wdata[31:0];
end


//jump_type9
assign jump_type9_reg[31:0]   = jump_type9                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type9 <= 32'h0;
    else if( jump_type9_wr )
        jump_type9 <= wdata[31:0];
end


//jump_type10
assign jump_type10_reg[31:0]   = jump_type10                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type10 <= 32'h0;
    else if( jump_type10_wr )
        jump_type10 <= wdata[31:0];
end


//jump_type11
assign jump_type11_reg[31:0]   = jump_type11                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type11 <= 32'h0;
    else if( jump_type11_wr )
        jump_type11 <= wdata[31:0];
end


//jump_type12
assign jump_type12_reg[31:0]   = jump_type12                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type12 <= 32'h0;
    else if( jump_type12_wr )
        jump_type12 <= wdata[31:0];
end


//jump_type13
assign jump_type13_reg[31:0]   = jump_type13                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type13 <= 32'h0;
    else if( jump_type13_wr )
        jump_type13 <= wdata[31:0];
end


//jump_type14
assign jump_type14_reg[31:0]   = jump_type14                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type14 <= 32'h0;
    else if( jump_type14_wr )
        jump_type14 <= wdata[31:0];
end


//jump_type15
assign jump_type15_reg[31:0]   = jump_type15                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type15 <= 32'h0;
    else if( jump_type15_wr )
        jump_type15 <= wdata[31:0];
end


//jump_type16
assign jump_type16_reg[31:0]   = jump_type16                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type16 <= 32'h0;
    else if( jump_type16_wr )
        jump_type16 <= wdata[31:0];
end


//jump_type17
assign jump_type17_reg[31:0]   = jump_type17                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type17 <= 32'h0;
    else if( jump_type17_wr )
        jump_type17 <= wdata[31:0];
end


//jump_type18
assign jump_type18_reg[31:0]   = jump_type18                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type18 <= 32'h0;
    else if( jump_type18_wr )
        jump_type18 <= wdata[31:0];
end


//jump_type19
assign jump_type19_reg[31:0]   = jump_type19                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type19 <= 32'h0;
    else if( jump_type19_wr )
        jump_type19 <= wdata[31:0];
end


//jump_type20
assign jump_type20_reg[31:0]   = jump_type20                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type20 <= 32'h0;
    else if( jump_type20_wr )
        jump_type20 <= wdata[31:0];
end


//jump_type21
assign jump_type21_reg[31:0]   = jump_type21                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type21 <= 32'h0;
    else if( jump_type21_wr )
        jump_type21 <= wdata[31:0];
end


//jump_type22
assign jump_type22_reg[31:0]   = jump_type22                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type22 <= 32'h0;
    else if( jump_type22_wr )
        jump_type22 <= wdata[31:0];
end


//jump_type23
assign jump_type23_reg[31:0]   = jump_type23                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type23 <= 32'h0;
    else if( jump_type23_wr )
        jump_type23 <= wdata[31:0];
end


//jump_type24
assign jump_type24_reg[31:0]   = jump_type24                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type24 <= 32'h0;
    else if( jump_type24_wr )
        jump_type24 <= wdata[31:0];
end


//jump_type25
assign jump_type25_reg[31:0]   = jump_type25                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type25 <= 32'h0;
    else if( jump_type25_wr )
        jump_type25 <= wdata[31:0];
end


//jump_type26
assign jump_type26_reg[31:0]   = jump_type26                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type26 <= 32'h0;
    else if( jump_type26_wr )
        jump_type26 <= wdata[31:0];
end


//jump_type27
assign jump_type27_reg[31:0]   = jump_type27                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type27 <= 32'h0;
    else if( jump_type27_wr )
        jump_type27 <= wdata[31:0];
end


//jump_type28
assign jump_type28_reg[31:0]   = jump_type28                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type28 <= 32'h0;
    else if( jump_type28_wr )
        jump_type28 <= wdata[31:0];
end


//jump_type29
assign jump_type29_reg[31:0]   = jump_type29                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type29 <= 32'h0;
    else if( jump_type29_wr )
        jump_type29 <= wdata[31:0];
end


//jump_type30
assign jump_type30_reg[31:0]   = jump_type30                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type30 <= 32'h0;
    else if( jump_type30_wr )
        jump_type30 <= wdata[31:0];
end


//jump_type31
assign jump_type31_reg[31:0]   = jump_type31                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type31 <= 32'h0;
    else if( jump_type31_wr )
        jump_type31 <= wdata[31:0];
end


//jump_type32
assign jump_type32_reg[31:0]   = jump_type32                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type32 <= 32'h0;
    else if( jump_type32_wr )
        jump_type32 <= wdata[31:0];
end


//jump_type33
assign jump_type33_reg[31:0]   = jump_type33                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type33 <= 32'h0;
    else if( jump_type33_wr )
        jump_type33 <= wdata[31:0];
end


//jump_type34
assign jump_type34_reg[31:0]   = jump_type34                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type34 <= 32'h0;
    else if( jump_type34_wr )
        jump_type34 <= wdata[31:0];
end


//jump_type35
assign jump_type35_reg[31:0]   = jump_type35                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type35 <= 32'h0;
    else if( jump_type35_wr )
        jump_type35 <= wdata[31:0];
end


//jump_type36
assign jump_type36_reg[31:0]   = jump_type36                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type36 <= 32'h0;
    else if( jump_type36_wr )
        jump_type36 <= wdata[31:0];
end


//jump_type37
assign jump_type37_reg[31:0]   = jump_type37                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type37 <= 32'h0;
    else if( jump_type37_wr )
        jump_type37 <= wdata[31:0];
end


//jump_type38
assign jump_type38_reg[31:0]   = jump_type38                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type38 <= 32'h0;
    else if( jump_type38_wr )
        jump_type38 <= wdata[31:0];
end


//jump_type39
assign jump_type39_reg[31:0]   = jump_type39                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type39 <= 32'h0;
    else if( jump_type39_wr )
        jump_type39 <= wdata[31:0];
end


//jump_type40
assign jump_type40_reg[31:0]   = jump_type40                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type40 <= 32'h0;
    else if( jump_type40_wr )
        jump_type40 <= wdata[31:0];
end


//jump_type41
assign jump_type41_reg[31:0]   = jump_type41                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type41 <= 32'h0;
    else if( jump_type41_wr )
        jump_type41 <= wdata[31:0];
end


//jump_type42
assign jump_type42_reg[31:0]   = jump_type42                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type42 <= 32'h0;
    else if( jump_type42_wr )
        jump_type42 <= wdata[31:0];
end


//jump_type43
assign jump_type43_reg[31:0]   = jump_type43                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type43 <= 32'h0;
    else if( jump_type43_wr )
        jump_type43 <= wdata[31:0];
end


//jump_type44
assign jump_type44_reg[31:0]   = jump_type44                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type44 <= 32'h0;
    else if( jump_type44_wr )
        jump_type44 <= wdata[31:0];
end


//jump_type45
assign jump_type45_reg[31:0]   = jump_type45                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type45 <= 32'h0;
    else if( jump_type45_wr )
        jump_type45 <= wdata[31:0];
end


//jump_type46
assign jump_type46_reg[31:0]   = jump_type46                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type46 <= 32'h0;
    else if( jump_type46_wr )
        jump_type46 <= wdata[31:0];
end


//jump_type47
assign jump_type47_reg[31:0]   = jump_type47                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type47 <= 32'h0;
    else if( jump_type47_wr )
        jump_type47 <= wdata[31:0];
end


//jump_type48
assign jump_type48_reg[31:0]   = jump_type48                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type48 <= 32'h0;
    else if( jump_type48_wr )
        jump_type48 <= wdata[31:0];
end


//jump_type49
assign jump_type49_reg[31:0]   = jump_type49                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type49 <= 32'h0;
    else if( jump_type49_wr )
        jump_type49 <= wdata[31:0];
end


//jump_type50
assign jump_type50_reg[31:0]   = jump_type50                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type50 <= 32'h0;
    else if( jump_type50_wr )
        jump_type50 <= wdata[31:0];
end


//jump_type51
assign jump_type51_reg[31:0]   = jump_type51                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type51 <= 32'h0;
    else if( jump_type51_wr )
        jump_type51 <= wdata[31:0];
end


//jump_type52
assign jump_type52_reg[31:0]   = jump_type52                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type52 <= 32'h0;
    else if( jump_type52_wr )
        jump_type52 <= wdata[31:0];
end


//jump_type53
assign jump_type53_reg[31:0]   = jump_type53                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type53 <= 32'h0;
    else if( jump_type53_wr )
        jump_type53 <= wdata[31:0];
end


//jump_type54
assign jump_type54_reg[31:0]   = jump_type54                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type54 <= 32'h0;
    else if( jump_type54_wr )
        jump_type54 <= wdata[31:0];
end


//jump_type55
assign jump_type55_reg[31:0]   = jump_type55                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type55 <= 32'h0;
    else if( jump_type55_wr )
        jump_type55 <= wdata[31:0];
end


//jump_type56
assign jump_type56_reg[31:0]   = jump_type56                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type56 <= 32'h0;
    else if( jump_type56_wr )
        jump_type56 <= wdata[31:0];
end


//jump_type57
assign jump_type57_reg[31:0]   = jump_type57                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type57 <= 32'h0;
    else if( jump_type57_wr )
        jump_type57 <= wdata[31:0];
end


//jump_type58
assign jump_type58_reg[31:0]   = jump_type58                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type58 <= 32'h0;
    else if( jump_type58_wr )
        jump_type58 <= wdata[31:0];
end


//jump_type59
assign jump_type59_reg[31:0]   = jump_type59                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type59 <= 32'h0;
    else if( jump_type59_wr )
        jump_type59 <= wdata[31:0];
end


//jump_type60
assign jump_type60_reg[31:0]   = jump_type60                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type60 <= 32'h0;
    else if( jump_type60_wr )
        jump_type60 <= wdata[31:0];
end


//jump_type61
assign jump_type61_reg[31:0]   = jump_type61                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type61 <= 32'h0;
    else if( jump_type61_wr )
        jump_type61 <= wdata[31:0];
end


//jump_type62
assign jump_type62_reg[31:0]   = jump_type62                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type62 <= 32'h0;
    else if( jump_type62_wr )
        jump_type62 <= wdata[31:0];
end


//jump_type63
assign jump_type63_reg[31:0]   = jump_type63                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type63 <= 32'h0;
    else if( jump_type63_wr )
        jump_type63 <= wdata[31:0];
end


//jump_type64
assign jump_type64_reg[31:0]   = jump_type64                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type64 <= 32'h0;
    else if( jump_type64_wr )
        jump_type64 <= wdata[31:0];
end


//jump_type65
assign jump_type65_reg[31:0]   = jump_type65                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type65 <= 32'h0;
    else if( jump_type65_wr )
        jump_type65 <= wdata[31:0];
end


//jump_type66
assign jump_type66_reg[31:0]   = jump_type66                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type66 <= 32'h0;
    else if( jump_type66_wr )
        jump_type66 <= wdata[31:0];
end


//jump_type67
assign jump_type67_reg[31:0]   = jump_type67                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type67 <= 32'h0;
    else if( jump_type67_wr )
        jump_type67 <= wdata[31:0];
end


//jump_type68
assign jump_type68_reg[31:0]   = jump_type68                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type68 <= 32'h0;
    else if( jump_type68_wr )
        jump_type68 <= wdata[31:0];
end


//jump_type69
assign jump_type69_reg[31:0]   = jump_type69                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type69 <= 32'h0;
    else if( jump_type69_wr )
        jump_type69 <= wdata[31:0];
end


//jump_type70
assign jump_type70_reg[31:0]   = jump_type70                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type70 <= 32'h0;
    else if( jump_type70_wr )
        jump_type70 <= wdata[31:0];
end


//jump_type71
assign jump_type71_reg[31:0]   = jump_type71                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type71 <= 32'h0;
    else if( jump_type71_wr )
        jump_type71 <= wdata[31:0];
end


//jump_type72
assign jump_type72_reg[31:0]   = jump_type72                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type72 <= 32'h0;
    else if( jump_type72_wr )
        jump_type72 <= wdata[31:0];
end


//jump_type73
assign jump_type73_reg[31:0]   = jump_type73                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type73 <= 32'h0;
    else if( jump_type73_wr )
        jump_type73 <= wdata[31:0];
end


//jump_type74
assign jump_type74_reg[31:0]   = jump_type74                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type74 <= 32'h0;
    else if( jump_type74_wr )
        jump_type74 <= wdata[31:0];
end


//jump_type75
assign jump_type75_reg[31:0]   = jump_type75                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type75 <= 32'h0;
    else if( jump_type75_wr )
        jump_type75 <= wdata[31:0];
end


//jump_type76
assign jump_type76_reg[31:0]   = jump_type76                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type76 <= 32'h0;
    else if( jump_type76_wr )
        jump_type76 <= wdata[31:0];
end


//jump_type77
assign jump_type77_reg[31:0]   = jump_type77                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type77 <= 32'h0;
    else if( jump_type77_wr )
        jump_type77 <= wdata[31:0];
end


//jump_type78
assign jump_type78_reg[31:0]   = jump_type78                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type78 <= 32'h0;
    else if( jump_type78_wr )
        jump_type78 <= wdata[31:0];
end


//jump_type79
assign jump_type79_reg[31:0]   = jump_type79                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type79 <= 32'h0;
    else if( jump_type79_wr )
        jump_type79 <= wdata[31:0];
end


//jump_type80
assign jump_type80_reg[31:0]   = jump_type80                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type80 <= 32'h0;
    else if( jump_type80_wr )
        jump_type80 <= wdata[31:0];
end


//jump_type81
assign jump_type81_reg[31:0]   = jump_type81                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type81 <= 32'h0;
    else if( jump_type81_wr )
        jump_type81 <= wdata[31:0];
end


//jump_type82
assign jump_type82_reg[31:0]   = jump_type82                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type82 <= 32'h0;
    else if( jump_type82_wr )
        jump_type82 <= wdata[31:0];
end


//jump_type83
assign jump_type83_reg[31:0]   = jump_type83                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type83 <= 32'h0;
    else if( jump_type83_wr )
        jump_type83 <= wdata[31:0];
end


//jump_type84
assign jump_type84_reg[31:0]   = jump_type84                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type84 <= 32'h0;
    else if( jump_type84_wr )
        jump_type84 <= wdata[31:0];
end


//jump_type85
assign jump_type85_reg[31:0]   = jump_type85                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type85 <= 32'h0;
    else if( jump_type85_wr )
        jump_type85 <= wdata[31:0];
end


//jump_type86
assign jump_type86_reg[31:0]   = jump_type86                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type86 <= 32'h0;
    else if( jump_type86_wr )
        jump_type86 <= wdata[31:0];
end


//jump_type87
assign jump_type87_reg[31:0]   = jump_type87                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type87 <= 32'h0;
    else if( jump_type87_wr )
        jump_type87 <= wdata[31:0];
end


//jump_type88
assign jump_type88_reg[31:0]   = jump_type88                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type88 <= 32'h0;
    else if( jump_type88_wr )
        jump_type88 <= wdata[31:0];
end


//jump_type89
assign jump_type89_reg[31:0]   = jump_type89                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type89 <= 32'h0;
    else if( jump_type89_wr )
        jump_type89 <= wdata[31:0];
end


//jump_type90
assign jump_type90_reg[31:0]   = jump_type90                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type90 <= 32'h0;
    else if( jump_type90_wr )
        jump_type90 <= wdata[31:0];
end


//jump_type91
assign jump_type91_reg[31:0]   = jump_type91                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type91 <= 32'h0;
    else if( jump_type91_wr )
        jump_type91 <= wdata[31:0];
end


//jump_type92
assign jump_type92_reg[31:0]   = jump_type92                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type92 <= 32'h0;
    else if( jump_type92_wr )
        jump_type92 <= wdata[31:0];
end


//jump_type93
assign jump_type93_reg[31:0]   = jump_type93                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type93 <= 32'h0;
    else if( jump_type93_wr )
        jump_type93 <= wdata[31:0];
end


//jump_type94
assign jump_type94_reg[31:0]   = jump_type94                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type94 <= 32'h0;
    else if( jump_type94_wr )
        jump_type94 <= wdata[31:0];
end


//jump_type95
assign jump_type95_reg[31:26]  = 6'h0                       ;
assign jump_type95_reg[25:0]   = jump_type95                ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        jump_type95 <= 26'h0;
    else if( jump_type95_wr )
        jump_type95 <= wdata[25:0];
end


//merger interrupt with group

//read
reg        [32-1:0]        rdata_tmp;
always @ ( * )
begin
    if ( ren )
    begin
        case( raddr )
            COMMON_PARA_REG:
                rdata_tmp = common_para_reg;
            DCRC_PARA_REG:
                rdata_tmp = dcrc_para_reg;
            DCRC_INFO_BIT0_REG:
                rdata_tmp = dcrc_info_bit0_reg;
            DCRC_INFO_BIT1_REG:
                rdata_tmp = dcrc_info_bit1_reg;
            DCRC_INFO_BIT2_REG:
                rdata_tmp = dcrc_info_bit2_reg;
            DCRC_INFO_BIT3_REG:
                rdata_tmp = dcrc_info_bit3_reg;
            DCRC_INFO_BIT4_REG:
                rdata_tmp = dcrc_info_bit4_reg;
            DCRC_INFO_BIT5_REG:
                rdata_tmp = dcrc_info_bit5_reg;
            DCRC_INFO_BIT6_REG:
                rdata_tmp = dcrc_info_bit6_reg;
            DCRC_INFO_BIT7_REG:
                rdata_tmp = dcrc_info_bit7_reg;
            DCRC_INFO_BIT8_REG:
                rdata_tmp = dcrc_info_bit8_reg;
            DCRC_INFO_BIT9_REG:
                rdata_tmp = dcrc_info_bit9_reg;
            DCRC_INFO_BIT10_REG:
                rdata_tmp = dcrc_info_bit10_reg;
            DCRC_INFO_BIT11_REG:
                rdata_tmp = dcrc_info_bit11_reg;
            DCRC_INFO_BIT12_REG:
                rdata_tmp = dcrc_info_bit12_reg;
            DCRC_INFO_BIT13_REG:
                rdata_tmp = dcrc_info_bit13_reg;
            RNTI_VAL01_REG:
                rdata_tmp = rnti_val01_reg;
            RNTI_VAL23_REG:
                rdata_tmp = rnti_val23_reg;
            IL_PATTERN0_REG:
                rdata_tmp = il_pattern0_reg;
            IL_PATTERN1_REG:
                rdata_tmp = il_pattern1_reg;
            IL_PATTERN2_REG:
                rdata_tmp = il_pattern2_reg;
            IL_PATTERN3_REG:
                rdata_tmp = il_pattern3_reg;
            IL_PATTERN4_REG:
                rdata_tmp = il_pattern4_reg;
            IL_PATTERN5_REG:
                rdata_tmp = il_pattern5_reg;
            IL_PATTERN6_REG:
                rdata_tmp = il_pattern6_reg;
            IL_PATTERN7_REG:
                rdata_tmp = il_pattern7_reg;
            IL_PATTERN8_REG:
                rdata_tmp = il_pattern8_reg;
            IL_PATTERN9_REG:
                rdata_tmp = il_pattern9_reg;
            IL_PATTERN10_REG:
                rdata_tmp = il_pattern10_reg;
            IL_PATTERN11_REG:
                rdata_tmp = il_pattern11_reg;
            IL_PATTERN12_REG:
                rdata_tmp = il_pattern12_reg;
            IL_PATTERN13_REG:
                rdata_tmp = il_pattern13_reg;
            IL_PATTERN14_REG:
                rdata_tmp = il_pattern14_reg;
            IL_PATTERN15_REG:
                rdata_tmp = il_pattern15_reg;
            IL_PATTERN16_REG:
                rdata_tmp = il_pattern16_reg;
            IL_PATTERN17_REG:
                rdata_tmp = il_pattern17_reg;
            IL_PATTERN18_REG:
                rdata_tmp = il_pattern18_reg;
            IL_PATTERN19_REG:
                rdata_tmp = il_pattern19_reg;
            IL_PATTERN20_REG:
                rdata_tmp = il_pattern20_reg;
            IL_PATTERN21_REG:
                rdata_tmp = il_pattern21_reg;
            IL_PATTERN22_REG:
                rdata_tmp = il_pattern22_reg;
            IL_PATTERN23_REG:
                rdata_tmp = il_pattern23_reg;
            IL_PATTERN24_REG:
                rdata_tmp = il_pattern24_reg;
            IL_PATTERN25_REG:
                rdata_tmp = il_pattern25_reg;
            IL_PATTERN26_REG:
                rdata_tmp = il_pattern26_reg;
            IL_PATTERN27_REG:
                rdata_tmp = il_pattern27_reg;
            IL_PATTERN28_REG:
                rdata_tmp = il_pattern28_reg;
            IL_PATTERN29_REG:
                rdata_tmp = il_pattern29_reg;
            IL_PATTERN30_REG:
                rdata_tmp = il_pattern30_reg;
            IL_PATTERN31_REG:
                rdata_tmp = il_pattern31_reg;
            IL_PATTERN32_REG:
                rdata_tmp = il_pattern32_reg;
            IL_PATTERN33_REG:
                rdata_tmp = il_pattern33_reg;
            IL_PATTERN34_REG:
                rdata_tmp = il_pattern34_reg;
            IL_PATTERN35_REG:
                rdata_tmp = il_pattern35_reg;
            IL_PATTERN36_REG:
                rdata_tmp = il_pattern36_reg;
            IL_PATTERN37_REG:
                rdata_tmp = il_pattern37_reg;
            IL_PATTERN38_REG:
                rdata_tmp = il_pattern38_reg;
            IL_PATTERN39_REG:
                rdata_tmp = il_pattern39_reg;
            IL_PATTERN40_REG:
                rdata_tmp = il_pattern40_reg;
            JUMP_TYPE0_REG:
                rdata_tmp = jump_type0_reg;
            JUMP_TYPE1_REG:
                rdata_tmp = jump_type1_reg;
            JUMP_TYPE2_REG:
                rdata_tmp = jump_type2_reg;
            JUMP_TYPE3_REG:
                rdata_tmp = jump_type3_reg;
            JUMP_TYPE4_REG:
                rdata_tmp = jump_type4_reg;
            JUMP_TYPE5_REG:
                rdata_tmp = jump_type5_reg;
            JUMP_TYPE6_REG:
                rdata_tmp = jump_type6_reg;
            JUMP_TYPE7_REG:
                rdata_tmp = jump_type7_reg;
            JUMP_TYPE8_REG:
                rdata_tmp = jump_type8_reg;
            JUMP_TYPE9_REG:
                rdata_tmp = jump_type9_reg;
            JUMP_TYPE10_REG:
                rdata_tmp = jump_type10_reg;
            JUMP_TYPE11_REG:
                rdata_tmp = jump_type11_reg;
            JUMP_TYPE12_REG:
                rdata_tmp = jump_type12_reg;
            JUMP_TYPE13_REG:
                rdata_tmp = jump_type13_reg;
            JUMP_TYPE14_REG:
                rdata_tmp = jump_type14_reg;
            JUMP_TYPE15_REG:
                rdata_tmp = jump_type15_reg;
            JUMP_TYPE16_REG:
                rdata_tmp = jump_type16_reg;
            JUMP_TYPE17_REG:
                rdata_tmp = jump_type17_reg;
            JUMP_TYPE18_REG:
                rdata_tmp = jump_type18_reg;
            JUMP_TYPE19_REG:
                rdata_tmp = jump_type19_reg;
            JUMP_TYPE20_REG:
                rdata_tmp = jump_type20_reg;
            JUMP_TYPE21_REG:
                rdata_tmp = jump_type21_reg;
            JUMP_TYPE22_REG:
                rdata_tmp = jump_type22_reg;
            JUMP_TYPE23_REG:
                rdata_tmp = jump_type23_reg;
            JUMP_TYPE24_REG:
                rdata_tmp = jump_type24_reg;
            JUMP_TYPE25_REG:
                rdata_tmp = jump_type25_reg;
            JUMP_TYPE26_REG:
                rdata_tmp = jump_type26_reg;
            JUMP_TYPE27_REG:
                rdata_tmp = jump_type27_reg;
            JUMP_TYPE28_REG:
                rdata_tmp = jump_type28_reg;
            JUMP_TYPE29_REG:
                rdata_tmp = jump_type29_reg;
            JUMP_TYPE30_REG:
                rdata_tmp = jump_type30_reg;
            JUMP_TYPE31_REG:
                rdata_tmp = jump_type31_reg;
            JUMP_TYPE32_REG:
                rdata_tmp = jump_type32_reg;
            JUMP_TYPE33_REG:
                rdata_tmp = jump_type33_reg;
            JUMP_TYPE34_REG:
                rdata_tmp = jump_type34_reg;
            JUMP_TYPE35_REG:
                rdata_tmp = jump_type35_reg;
            JUMP_TYPE36_REG:
                rdata_tmp = jump_type36_reg;
            JUMP_TYPE37_REG:
                rdata_tmp = jump_type37_reg;
            JUMP_TYPE38_REG:
                rdata_tmp = jump_type38_reg;
            JUMP_TYPE39_REG:
                rdata_tmp = jump_type39_reg;
            JUMP_TYPE40_REG:
                rdata_tmp = jump_type40_reg;
            JUMP_TYPE41_REG:
                rdata_tmp = jump_type41_reg;
            JUMP_TYPE42_REG:
                rdata_tmp = jump_type42_reg;
            JUMP_TYPE43_REG:
                rdata_tmp = jump_type43_reg;
            JUMP_TYPE44_REG:
                rdata_tmp = jump_type44_reg;
            JUMP_TYPE45_REG:
                rdata_tmp = jump_type45_reg;
            JUMP_TYPE46_REG:
                rdata_tmp = jump_type46_reg;
            JUMP_TYPE47_REG:
                rdata_tmp = jump_type47_reg;
            JUMP_TYPE48_REG:
                rdata_tmp = jump_type48_reg;
            JUMP_TYPE49_REG:
                rdata_tmp = jump_type49_reg;
            JUMP_TYPE50_REG:
                rdata_tmp = jump_type50_reg;
            JUMP_TYPE51_REG:
                rdata_tmp = jump_type51_reg;
            JUMP_TYPE52_REG:
                rdata_tmp = jump_type52_reg;
            JUMP_TYPE53_REG:
                rdata_tmp = jump_type53_reg;
            JUMP_TYPE54_REG:
                rdata_tmp = jump_type54_reg;
            JUMP_TYPE55_REG:
                rdata_tmp = jump_type55_reg;
            JUMP_TYPE56_REG:
                rdata_tmp = jump_type56_reg;
            JUMP_TYPE57_REG:
                rdata_tmp = jump_type57_reg;
            JUMP_TYPE58_REG:
                rdata_tmp = jump_type58_reg;
            JUMP_TYPE59_REG:
                rdata_tmp = jump_type59_reg;
            JUMP_TYPE60_REG:
                rdata_tmp = jump_type60_reg;
            JUMP_TYPE61_REG:
                rdata_tmp = jump_type61_reg;
            JUMP_TYPE62_REG:
                rdata_tmp = jump_type62_reg;
            JUMP_TYPE63_REG:
                rdata_tmp = jump_type63_reg;
            JUMP_TYPE64_REG:
                rdata_tmp = jump_type64_reg;
            JUMP_TYPE65_REG:
                rdata_tmp = jump_type65_reg;
            JUMP_TYPE66_REG:
                rdata_tmp = jump_type66_reg;
            JUMP_TYPE67_REG:
                rdata_tmp = jump_type67_reg;
            JUMP_TYPE68_REG:
                rdata_tmp = jump_type68_reg;
            JUMP_TYPE69_REG:
                rdata_tmp = jump_type69_reg;
            JUMP_TYPE70_REG:
                rdata_tmp = jump_type70_reg;
            JUMP_TYPE71_REG:
                rdata_tmp = jump_type71_reg;
            JUMP_TYPE72_REG:
                rdata_tmp = jump_type72_reg;
            JUMP_TYPE73_REG:
                rdata_tmp = jump_type73_reg;
            JUMP_TYPE74_REG:
                rdata_tmp = jump_type74_reg;
            JUMP_TYPE75_REG:
                rdata_tmp = jump_type75_reg;
            JUMP_TYPE76_REG:
                rdata_tmp = jump_type76_reg;
            JUMP_TYPE77_REG:
                rdata_tmp = jump_type77_reg;
            JUMP_TYPE78_REG:
                rdata_tmp = jump_type78_reg;
            JUMP_TYPE79_REG:
                rdata_tmp = jump_type79_reg;
            JUMP_TYPE80_REG:
                rdata_tmp = jump_type80_reg;
            JUMP_TYPE81_REG:
                rdata_tmp = jump_type81_reg;
            JUMP_TYPE82_REG:
                rdata_tmp = jump_type82_reg;
            JUMP_TYPE83_REG:
                rdata_tmp = jump_type83_reg;
            JUMP_TYPE84_REG:
                rdata_tmp = jump_type84_reg;
            JUMP_TYPE85_REG:
                rdata_tmp = jump_type85_reg;
            JUMP_TYPE86_REG:
                rdata_tmp = jump_type86_reg;
            JUMP_TYPE87_REG:
                rdata_tmp = jump_type87_reg;
            JUMP_TYPE88_REG:
                rdata_tmp = jump_type88_reg;
            JUMP_TYPE89_REG:
                rdata_tmp = jump_type89_reg;
            JUMP_TYPE90_REG:
                rdata_tmp = jump_type90_reg;
            JUMP_TYPE91_REG:
                rdata_tmp = jump_type91_reg;
            JUMP_TYPE92_REG:
                rdata_tmp = jump_type92_reg;
            JUMP_TYPE93_REG:
                rdata_tmp = jump_type93_reg;
            JUMP_TYPE94_REG:
                rdata_tmp = jump_type94_reg;
            JUMP_TYPE95_REG:
                rdata_tmp = jump_type95_reg;
            default:
                rdata_tmp = 32'h0;
        endcase
    end
    else
        rdata_tmp = 32'h0;
end

always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        rdata <= 32'h0;
    else if ( ren )
        rdata <= rdata_tmp;
end


endmodule
