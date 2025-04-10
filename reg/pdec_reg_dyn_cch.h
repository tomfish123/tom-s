//////////////////////////////////////////////////////////////////////////////////
// Description   : pdec_reg_dyn_cch regfile cfg
/////////////////////////////////////////////////////////////////////////////////

#ifndef _PDEC_REG_DYN_CCH_
#define _PDEC_REG_DYN_CCH_

struct PDEC_REG_DYN_CCH_COMMON_PARA
{
    int param_n         : 2 ;
    int param_a         : 8 ;
    int param_k         : 8 ;
    int leaf_mode       : 1 ;
    int list_num        : 2 ;
    int crc_flag        : 1 ;
    int rnti_num        : 2 ;
    int rm_mode         : 2 ;
};

struct PDEC_REG_DYN_CCH_DCRC_PARA
{
    int dcrc_num        : 2 ;
    int dcrc_reg_ini    : 3 ;
    int dcrc_mode       : 1 ;
    int dcrc_info_idx   : 24;
};

struct PDEC_REG_DYN_CCH_DCRC_INFO_BIT0
{
    int dcrc_info_bit0  : 32;
};

struct PDEC_REG_DYN_CCH_DCRC_INFO_BIT1
{
    int dcrc_info_bit1  : 32;
};

struct PDEC_REG_DYN_CCH_DCRC_INFO_BIT2
{
    int dcrc_info_bit2  : 32;
};

struct PDEC_REG_DYN_CCH_DCRC_INFO_BIT3
{
    int dcrc_info_bit3  : 32;
};

struct PDEC_REG_DYN_CCH_DCRC_INFO_BIT4
{
    int dcrc_info_bit4  : 32;
};

struct PDEC_REG_DYN_CCH_DCRC_INFO_BIT5
{
    int dcrc_info_bit5  : 32;
};

struct PDEC_REG_DYN_CCH_DCRC_INFO_BIT6
{
    int dcrc_info_bit6  : 32;
};

struct PDEC_REG_DYN_CCH_DCRC_INFO_BIT7
{
    int dcrc_info_bit7  : 32;
};

struct PDEC_REG_DYN_CCH_DCRC_INFO_BIT8
{
    int dcrc_info_bit8  : 32;
};

struct PDEC_REG_DYN_CCH_DCRC_INFO_BIT9
{
    int dcrc_info_bit9  : 32;
};

struct PDEC_REG_DYN_CCH_DCRC_INFO_BIT10
{
    int dcrc_info_bit10 : 32;
};

struct PDEC_REG_DYN_CCH_DCRC_INFO_BIT11
{
    int dcrc_info_bit11 : 32;
};

struct PDEC_REG_DYN_CCH_DCRC_INFO_BIT12
{
    int dcrc_info_bit12 : 32;
};

struct PDEC_REG_DYN_CCH_DCRC_INFO_BIT13
{
    int dcrc_info_bit13 : 13;
};

struct PDEC_REG_DYN_CCH_RNTI_VAL01
{
    int rnti_val0       : 16;
    int rnti_val1       : 16;
};

struct PDEC_REG_DYN_CCH_RNTI_VAL23
{
    int rnti_val2       : 16;
    int rnti_val3       : 16;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN0
{
    int il_pattern0     : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN1
{
    int il_pattern1     : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN2
{
    int il_pattern2     : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN3
{
    int il_pattern3     : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN4
{
    int il_pattern4     : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN5
{
    int il_pattern5     : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN6
{
    int il_pattern6     : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN7
{
    int il_pattern7     : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN8
{
    int il_pattern8     : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN9
{
    int il_pattern9     : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN10
{
    int il_pattern10    : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN11
{
    int il_pattern11    : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN12
{
    int il_pattern12    : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN13
{
    int il_pattern13    : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN14
{
    int il_pattern14    : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN15
{
    int il_pattern15    : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN16
{
    int il_pattern16    : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN17
{
    int il_pattern17    : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN18
{
    int il_pattern18    : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN19
{
    int il_pattern19    : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN20
{
    int il_pattern20    : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN21
{
    int il_pattern21    : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN22
{
    int il_pattern22    : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN23
{
    int il_pattern23    : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN24
{
    int il_pattern24    : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN25
{
    int il_pattern25    : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN26
{
    int il_pattern26    : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN27
{
    int il_pattern27    : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN28
{
    int il_pattern28    : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN29
{
    int il_pattern29    : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN30
{
    int il_pattern30    : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN31
{
    int il_pattern31    : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN32
{
    int il_pattern32    : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN33
{
    int il_pattern33    : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN34
{
    int il_pattern34    : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN35
{
    int il_pattern35    : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN36
{
    int il_pattern36    : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN37
{
    int il_pattern37    : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN38
{
    int il_pattern38    : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN39
{
    int il_pattern39    : 32;
};

struct PDEC_REG_DYN_CCH_IL_PATTERN40
{
    int il_pattern40    : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE0
{
    int jump_type0      : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE1
{
    int jump_type1      : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE2
{
    int jump_type2      : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE3
{
    int jump_type3      : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE4
{
    int jump_type4      : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE5
{
    int jump_type5      : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE6
{
    int jump_type6      : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE7
{
    int jump_type7      : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE8
{
    int jump_type8      : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE9
{
    int jump_type9      : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE10
{
    int jump_type10     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE11
{
    int jump_type11     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE12
{
    int jump_type12     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE13
{
    int jump_type13     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE14
{
    int jump_type14     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE15
{
    int jump_type15     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE16
{
    int jump_type16     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE17
{
    int jump_type17     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE18
{
    int jump_type18     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE19
{
    int jump_type19     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE20
{
    int jump_type20     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE21
{
    int jump_type21     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE22
{
    int jump_type22     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE23
{
    int jump_type23     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE24
{
    int jump_type24     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE25
{
    int jump_type25     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE26
{
    int jump_type26     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE27
{
    int jump_type27     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE28
{
    int jump_type28     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE29
{
    int jump_type29     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE30
{
    int jump_type30     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE31
{
    int jump_type31     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE32
{
    int jump_type32     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE33
{
    int jump_type33     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE34
{
    int jump_type34     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE35
{
    int jump_type35     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE36
{
    int jump_type36     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE37
{
    int jump_type37     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE38
{
    int jump_type38     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE39
{
    int jump_type39     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE40
{
    int jump_type40     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE41
{
    int jump_type41     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE42
{
    int jump_type42     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE43
{
    int jump_type43     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE44
{
    int jump_type44     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE45
{
    int jump_type45     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE46
{
    int jump_type46     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE47
{
    int jump_type47     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE48
{
    int jump_type48     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE49
{
    int jump_type49     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE50
{
    int jump_type50     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE51
{
    int jump_type51     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE52
{
    int jump_type52     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE53
{
    int jump_type53     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE54
{
    int jump_type54     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE55
{
    int jump_type55     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE56
{
    int jump_type56     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE57
{
    int jump_type57     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE58
{
    int jump_type58     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE59
{
    int jump_type59     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE60
{
    int jump_type60     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE61
{
    int jump_type61     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE62
{
    int jump_type62     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE63
{
    int jump_type63     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE64
{
    int jump_type64     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE65
{
    int jump_type65     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE66
{
    int jump_type66     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE67
{
    int jump_type67     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE68
{
    int jump_type68     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE69
{
    int jump_type69     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE70
{
    int jump_type70     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE71
{
    int jump_type71     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE72
{
    int jump_type72     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE73
{
    int jump_type73     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE74
{
    int jump_type74     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE75
{
    int jump_type75     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE76
{
    int jump_type76     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE77
{
    int jump_type77     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE78
{
    int jump_type78     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE79
{
    int jump_type79     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE80
{
    int jump_type80     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE81
{
    int jump_type81     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE82
{
    int jump_type82     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE83
{
    int jump_type83     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE84
{
    int jump_type84     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE85
{
    int jump_type85     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE86
{
    int jump_type86     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE87
{
    int jump_type87     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE88
{
    int jump_type88     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE89
{
    int jump_type89     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE90
{
    int jump_type90     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE91
{
    int jump_type91     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE92
{
    int jump_type92     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE93
{
    int jump_type93     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE94
{
    int jump_type94     : 32;
};

struct PDEC_REG_DYN_CCH_JUMP_TYPE95
{
    int jump_type95     : 26;
};

struct PDEC_REG_DYN_CCH
{
    PDEC_REG_DYN_CCH_COMMON_PARA     common_para;
    PDEC_REG_DYN_CCH_DCRC_PARA       dcrc_para;
    PDEC_REG_DYN_CCH_DCRC_INFO_BIT0  dcrc_info_bit0;
    PDEC_REG_DYN_CCH_DCRC_INFO_BIT1  dcrc_info_bit1;
    PDEC_REG_DYN_CCH_DCRC_INFO_BIT2  dcrc_info_bit2;
    PDEC_REG_DYN_CCH_DCRC_INFO_BIT3  dcrc_info_bit3;
    PDEC_REG_DYN_CCH_DCRC_INFO_BIT4  dcrc_info_bit4;
    PDEC_REG_DYN_CCH_DCRC_INFO_BIT5  dcrc_info_bit5;
    PDEC_REG_DYN_CCH_DCRC_INFO_BIT6  dcrc_info_bit6;
    PDEC_REG_DYN_CCH_DCRC_INFO_BIT7  dcrc_info_bit7;
    PDEC_REG_DYN_CCH_DCRC_INFO_BIT8  dcrc_info_bit8;
    PDEC_REG_DYN_CCH_DCRC_INFO_BIT9  dcrc_info_bit9;
    PDEC_REG_DYN_CCH_DCRC_INFO_BIT10 dcrc_info_bit10;
    PDEC_REG_DYN_CCH_DCRC_INFO_BIT11 dcrc_info_bit11;
    PDEC_REG_DYN_CCH_DCRC_INFO_BIT12 dcrc_info_bit12;
    PDEC_REG_DYN_CCH_DCRC_INFO_BIT13 dcrc_info_bit13;
    PDEC_REG_DYN_CCH_RNTI_VAL01      rnti_val01;
    PDEC_REG_DYN_CCH_RNTI_VAL23      rnti_val23;
    PDEC_REG_DYN_CCH_IL_PATTERN0     il_pattern0;
    PDEC_REG_DYN_CCH_IL_PATTERN1     il_pattern1;
    PDEC_REG_DYN_CCH_IL_PATTERN2     il_pattern2;
    PDEC_REG_DYN_CCH_IL_PATTERN3     il_pattern3;
    PDEC_REG_DYN_CCH_IL_PATTERN4     il_pattern4;
    PDEC_REG_DYN_CCH_IL_PATTERN5     il_pattern5;
    PDEC_REG_DYN_CCH_IL_PATTERN6     il_pattern6;
    PDEC_REG_DYN_CCH_IL_PATTERN7     il_pattern7;
    PDEC_REG_DYN_CCH_IL_PATTERN8     il_pattern8;
    PDEC_REG_DYN_CCH_IL_PATTERN9     il_pattern9;
    PDEC_REG_DYN_CCH_IL_PATTERN10    il_pattern10;
    PDEC_REG_DYN_CCH_IL_PATTERN11    il_pattern11;
    PDEC_REG_DYN_CCH_IL_PATTERN12    il_pattern12;
    PDEC_REG_DYN_CCH_IL_PATTERN13    il_pattern13;
    PDEC_REG_DYN_CCH_IL_PATTERN14    il_pattern14;
    PDEC_REG_DYN_CCH_IL_PATTERN15    il_pattern15;
    PDEC_REG_DYN_CCH_IL_PATTERN16    il_pattern16;
    PDEC_REG_DYN_CCH_IL_PATTERN17    il_pattern17;
    PDEC_REG_DYN_CCH_IL_PATTERN18    il_pattern18;
    PDEC_REG_DYN_CCH_IL_PATTERN19    il_pattern19;
    PDEC_REG_DYN_CCH_IL_PATTERN20    il_pattern20;
    PDEC_REG_DYN_CCH_IL_PATTERN21    il_pattern21;
    PDEC_REG_DYN_CCH_IL_PATTERN22    il_pattern22;
    PDEC_REG_DYN_CCH_IL_PATTERN23    il_pattern23;
    PDEC_REG_DYN_CCH_IL_PATTERN24    il_pattern24;
    PDEC_REG_DYN_CCH_IL_PATTERN25    il_pattern25;
    PDEC_REG_DYN_CCH_IL_PATTERN26    il_pattern26;
    PDEC_REG_DYN_CCH_IL_PATTERN27    il_pattern27;
    PDEC_REG_DYN_CCH_IL_PATTERN28    il_pattern28;
    PDEC_REG_DYN_CCH_IL_PATTERN29    il_pattern29;
    PDEC_REG_DYN_CCH_IL_PATTERN30    il_pattern30;
    PDEC_REG_DYN_CCH_IL_PATTERN31    il_pattern31;
    PDEC_REG_DYN_CCH_IL_PATTERN32    il_pattern32;
    PDEC_REG_DYN_CCH_IL_PATTERN33    il_pattern33;
    PDEC_REG_DYN_CCH_IL_PATTERN34    il_pattern34;
    PDEC_REG_DYN_CCH_IL_PATTERN35    il_pattern35;
    PDEC_REG_DYN_CCH_IL_PATTERN36    il_pattern36;
    PDEC_REG_DYN_CCH_IL_PATTERN37    il_pattern37;
    PDEC_REG_DYN_CCH_IL_PATTERN38    il_pattern38;
    PDEC_REG_DYN_CCH_IL_PATTERN39    il_pattern39;
    PDEC_REG_DYN_CCH_IL_PATTERN40    il_pattern40;
    PDEC_REG_DYN_CCH_JUMP_TYPE0      jump_type0;
    PDEC_REG_DYN_CCH_JUMP_TYPE1      jump_type1;
    PDEC_REG_DYN_CCH_JUMP_TYPE2      jump_type2;
    PDEC_REG_DYN_CCH_JUMP_TYPE3      jump_type3;
    PDEC_REG_DYN_CCH_JUMP_TYPE4      jump_type4;
    PDEC_REG_DYN_CCH_JUMP_TYPE5      jump_type5;
    PDEC_REG_DYN_CCH_JUMP_TYPE6      jump_type6;
    PDEC_REG_DYN_CCH_JUMP_TYPE7      jump_type7;
    PDEC_REG_DYN_CCH_JUMP_TYPE8      jump_type8;
    PDEC_REG_DYN_CCH_JUMP_TYPE9      jump_type9;
    PDEC_REG_DYN_CCH_JUMP_TYPE10     jump_type10;
    PDEC_REG_DYN_CCH_JUMP_TYPE11     jump_type11;
    PDEC_REG_DYN_CCH_JUMP_TYPE12     jump_type12;
    PDEC_REG_DYN_CCH_JUMP_TYPE13     jump_type13;
    PDEC_REG_DYN_CCH_JUMP_TYPE14     jump_type14;
    PDEC_REG_DYN_CCH_JUMP_TYPE15     jump_type15;
    PDEC_REG_DYN_CCH_JUMP_TYPE16     jump_type16;
    PDEC_REG_DYN_CCH_JUMP_TYPE17     jump_type17;
    PDEC_REG_DYN_CCH_JUMP_TYPE18     jump_type18;
    PDEC_REG_DYN_CCH_JUMP_TYPE19     jump_type19;
    PDEC_REG_DYN_CCH_JUMP_TYPE20     jump_type20;
    PDEC_REG_DYN_CCH_JUMP_TYPE21     jump_type21;
    PDEC_REG_DYN_CCH_JUMP_TYPE22     jump_type22;
    PDEC_REG_DYN_CCH_JUMP_TYPE23     jump_type23;
    PDEC_REG_DYN_CCH_JUMP_TYPE24     jump_type24;
    PDEC_REG_DYN_CCH_JUMP_TYPE25     jump_type25;
    PDEC_REG_DYN_CCH_JUMP_TYPE26     jump_type26;
    PDEC_REG_DYN_CCH_JUMP_TYPE27     jump_type27;
    PDEC_REG_DYN_CCH_JUMP_TYPE28     jump_type28;
    PDEC_REG_DYN_CCH_JUMP_TYPE29     jump_type29;
    PDEC_REG_DYN_CCH_JUMP_TYPE30     jump_type30;
    PDEC_REG_DYN_CCH_JUMP_TYPE31     jump_type31;
    PDEC_REG_DYN_CCH_JUMP_TYPE32     jump_type32;
    PDEC_REG_DYN_CCH_JUMP_TYPE33     jump_type33;
    PDEC_REG_DYN_CCH_JUMP_TYPE34     jump_type34;
    PDEC_REG_DYN_CCH_JUMP_TYPE35     jump_type35;
    PDEC_REG_DYN_CCH_JUMP_TYPE36     jump_type36;
    PDEC_REG_DYN_CCH_JUMP_TYPE37     jump_type37;
    PDEC_REG_DYN_CCH_JUMP_TYPE38     jump_type38;
    PDEC_REG_DYN_CCH_JUMP_TYPE39     jump_type39;
    PDEC_REG_DYN_CCH_JUMP_TYPE40     jump_type40;
    PDEC_REG_DYN_CCH_JUMP_TYPE41     jump_type41;
    PDEC_REG_DYN_CCH_JUMP_TYPE42     jump_type42;
    PDEC_REG_DYN_CCH_JUMP_TYPE43     jump_type43;
    PDEC_REG_DYN_CCH_JUMP_TYPE44     jump_type44;
    PDEC_REG_DYN_CCH_JUMP_TYPE45     jump_type45;
    PDEC_REG_DYN_CCH_JUMP_TYPE46     jump_type46;
    PDEC_REG_DYN_CCH_JUMP_TYPE47     jump_type47;
    PDEC_REG_DYN_CCH_JUMP_TYPE48     jump_type48;
    PDEC_REG_DYN_CCH_JUMP_TYPE49     jump_type49;
    PDEC_REG_DYN_CCH_JUMP_TYPE50     jump_type50;
    PDEC_REG_DYN_CCH_JUMP_TYPE51     jump_type51;
    PDEC_REG_DYN_CCH_JUMP_TYPE52     jump_type52;
    PDEC_REG_DYN_CCH_JUMP_TYPE53     jump_type53;
    PDEC_REG_DYN_CCH_JUMP_TYPE54     jump_type54;
    PDEC_REG_DYN_CCH_JUMP_TYPE55     jump_type55;
    PDEC_REG_DYN_CCH_JUMP_TYPE56     jump_type56;
    PDEC_REG_DYN_CCH_JUMP_TYPE57     jump_type57;
    PDEC_REG_DYN_CCH_JUMP_TYPE58     jump_type58;
    PDEC_REG_DYN_CCH_JUMP_TYPE59     jump_type59;
    PDEC_REG_DYN_CCH_JUMP_TYPE60     jump_type60;
    PDEC_REG_DYN_CCH_JUMP_TYPE61     jump_type61;
    PDEC_REG_DYN_CCH_JUMP_TYPE62     jump_type62;
    PDEC_REG_DYN_CCH_JUMP_TYPE63     jump_type63;
    PDEC_REG_DYN_CCH_JUMP_TYPE64     jump_type64;
    PDEC_REG_DYN_CCH_JUMP_TYPE65     jump_type65;
    PDEC_REG_DYN_CCH_JUMP_TYPE66     jump_type66;
    PDEC_REG_DYN_CCH_JUMP_TYPE67     jump_type67;
    PDEC_REG_DYN_CCH_JUMP_TYPE68     jump_type68;
    PDEC_REG_DYN_CCH_JUMP_TYPE69     jump_type69;
    PDEC_REG_DYN_CCH_JUMP_TYPE70     jump_type70;
    PDEC_REG_DYN_CCH_JUMP_TYPE71     jump_type71;
    PDEC_REG_DYN_CCH_JUMP_TYPE72     jump_type72;
    PDEC_REG_DYN_CCH_JUMP_TYPE73     jump_type73;
    PDEC_REG_DYN_CCH_JUMP_TYPE74     jump_type74;
    PDEC_REG_DYN_CCH_JUMP_TYPE75     jump_type75;
    PDEC_REG_DYN_CCH_JUMP_TYPE76     jump_type76;
    PDEC_REG_DYN_CCH_JUMP_TYPE77     jump_type77;
    PDEC_REG_DYN_CCH_JUMP_TYPE78     jump_type78;
    PDEC_REG_DYN_CCH_JUMP_TYPE79     jump_type79;
    PDEC_REG_DYN_CCH_JUMP_TYPE80     jump_type80;
    PDEC_REG_DYN_CCH_JUMP_TYPE81     jump_type81;
    PDEC_REG_DYN_CCH_JUMP_TYPE82     jump_type82;
    PDEC_REG_DYN_CCH_JUMP_TYPE83     jump_type83;
    PDEC_REG_DYN_CCH_JUMP_TYPE84     jump_type84;
    PDEC_REG_DYN_CCH_JUMP_TYPE85     jump_type85;
    PDEC_REG_DYN_CCH_JUMP_TYPE86     jump_type86;
    PDEC_REG_DYN_CCH_JUMP_TYPE87     jump_type87;
    PDEC_REG_DYN_CCH_JUMP_TYPE88     jump_type88;
    PDEC_REG_DYN_CCH_JUMP_TYPE89     jump_type89;
    PDEC_REG_DYN_CCH_JUMP_TYPE90     jump_type90;
    PDEC_REG_DYN_CCH_JUMP_TYPE91     jump_type91;
    PDEC_REG_DYN_CCH_JUMP_TYPE92     jump_type92;
    PDEC_REG_DYN_CCH_JUMP_TYPE93     jump_type93;
    PDEC_REG_DYN_CCH_JUMP_TYPE94     jump_type94;
    PDEC_REG_DYN_CCH_JUMP_TYPE95     jump_type95;
};

#endif
