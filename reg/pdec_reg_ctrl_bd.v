//////////////////////////////////////////////////////////////////////////////////
// Description   : pdec_reg_ctrl_bd regfile cfg
/////////////////////////////////////////////////////////////////////////////////

module pdec_reg_ctrl_bd (
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

    //pdec_cfg_ver
    input        [15:0] pdec_cfg_ver        ,

    //pdec_st
    output reg          pdec_st_w1p         ,

    //pdec_ctrl_sig
    output reg          pdec_soft_rst       ,
    output reg          icg_sw_en           ,
    output reg          icg_mode            ,
    output reg [ 2-1:0] list_num            ,
    output reg          pdec_type           ,

    //pdec_head_info
    input      [32-1:0] pdec_head_info      ,

    //pdec_debug_info
    input      [32-1:0] pdec_debug_info     ,

    //pdec_int
    input               drm_sram_int        ,
    input               dec_rpt_int         ,
    output              intr_group_0        
);

//----------------------------local parameter---------------------------------------------
localparam PDEC_CFG_VER_REG            = 32'h0 ;
localparam PDEC_ST_REG                 = 32'h4 ;
localparam PDEC_CTRL_SIG_REG           = 32'h8 ;
localparam PDEC_HEAD_INFO_REG          = 32'hc ;
localparam PDEC_DEBUG_INFO_REG         = 32'h10;
localparam PDEC_INT_RAW_REG            = 32'h14;
localparam PDEC_INT_STATUS_REG         = 32'h18;
localparam PDEC_INT_MASK_REG           = 32'h1c;
localparam PDEC_INT_CLR_REG            = 32'h20;
localparam PDEC_INT_SET_REG            = 32'h24;

//----------------------------local wire/reg declaration------------------------------------------
reg           drm_sram_int_raw               ;
wire          drm_sram_int_status            ;
reg           drm_sram_int_mask              ;
wire          drm_sram_int_clr               ;
wire          drm_sram_int_set               ;
reg           dec_rpt_int_raw                ;
wire          dec_rpt_int_status             ;
reg           dec_rpt_int_mask               ;
wire          dec_rpt_int_clr                ;
wire          dec_rpt_int_set                ;
wire [32-1:0] pdec_cfg_ver_reg               ;
wire [32-1:0] pdec_st_reg                    ;
wire [32-1:0] pdec_ctrl_sig_reg              ;
wire [32-1:0] pdec_head_info_reg             ;
wire [32-1:0] pdec_debug_info_reg            ;
wire [32-1:0] pdec_int_status_reg            ;
wire [32-1:0] pdec_int_mask_reg              ;
wire [32-1:0] pdec_int_raw_reg               ;

//----------------------------control logic---------------------------------------------
wire pdec_st_wr                      = ( waddr == PDEC_ST_REG ) && wen;
wire pdec_ctrl_sig_wr                = ( waddr == PDEC_CTRL_SIG_REG ) && wen;
wire pdec_int_mask_wr                = ( waddr == PDEC_INT_MASK_REG ) && wen;
wire pdec_int_clr_wr                 = ( waddr == PDEC_INT_CLR_REG ) && wen;
wire pdec_int_set_wr                 = ( waddr == PDEC_INT_SET_REG ) && wen;

//--------------------------------processing------------------------------------------------

//pdec_cfg_ver
assign pdec_cfg_ver_reg[31:16]  = pdec_cfg_ver                ;
assign pdec_cfg_ver_reg[15: 0]  = 16'h0;

//pdec_st
assign pdec_st_reg[31:1]    = 31'h0                   ;
assign pdec_st_reg[0]       = 1'h0;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        pdec_st_w1p <= 1'h0;
    else if( pdec_st_wr )
        pdec_st_w1p <= wdata[0];
    else
        pdec_st_w1p <= 1'h0;
end


//pdec_ctrl_sig
assign pdec_ctrl_sig_reg[31:6]   = 26'h0                        ;
assign pdec_ctrl_sig_reg[5]      = pdec_soft_rst                ;
assign pdec_ctrl_sig_reg[4]      = icg_sw_en                    ;
assign pdec_ctrl_sig_reg[3]      = icg_mode                     ;
assign pdec_ctrl_sig_reg[2:1]    = list_num                     ;
assign pdec_ctrl_sig_reg[0]      = pdec_type                    ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        pdec_soft_rst <= 1'h0;
    else if( pdec_ctrl_sig_wr )
        pdec_soft_rst <= wdata[5];
end

always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        icg_sw_en <= 1'h0;
    else if( pdec_ctrl_sig_wr )
        icg_sw_en <= wdata[4];
end

always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        icg_mode <= 1'h0;
    else if( pdec_ctrl_sig_wr )
        icg_mode <= wdata[3];
end

always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        list_num <= 2'h0;
    else if( pdec_ctrl_sig_wr )
        list_num <= wdata[2:1];
end

always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        pdec_type <= 1'h0;
    else if( pdec_ctrl_sig_wr )
        pdec_type <= wdata[0];
end


//pdec_head_info
assign pdec_head_info_reg[31:0]   = pdec_head_info                ;

//pdec_debug_info
assign pdec_debug_info_reg[31:0]   = pdec_debug_info                ;

//pdec_int
assign pdec_int_mask_reg[31:2]  = 30'h0                       ;
assign pdec_int_status_reg[31:2] = 30'h0                       ;
assign pdec_int_raw_reg[31:2]   = 30'h0                       ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        drm_sram_int_raw <= 1'h0;
    else if( drm_sram_int )
        drm_sram_int_raw <= 1'b1;
    else if( drm_sram_int_clr )
        drm_sram_int_raw <= 1'b0;
    else if( drm_sram_int_set )
        drm_sram_int_raw <= 1'b1;
end

assign pdec_int_raw_reg[1]      = drm_sram_int_raw            ;
assign pdec_int_status_reg[1]   = drm_sram_int_status         ;
assign drm_sram_int_status      = drm_sram_int_raw & (~drm_sram_int_mask);
assign pdec_int_mask_reg[1]     = drm_sram_int_mask           ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        drm_sram_int_mask <= 1'h1;
    else if( pdec_int_mask_wr )
        drm_sram_int_mask <= wdata[1];
end

assign drm_sram_int_clr         = pdec_int_clr_wr & wdata[1];
assign drm_sram_int_set         = pdec_int_set_wr & wdata[1];
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        dec_rpt_int_raw <= 1'h0;
    else if( dec_rpt_int )
        dec_rpt_int_raw <= 1'b1;
    else if( dec_rpt_int_clr )
        dec_rpt_int_raw <= 1'b0;
    else if( dec_rpt_int_set )
        dec_rpt_int_raw <= 1'b1;
end

assign pdec_int_raw_reg[0]      = dec_rpt_int_raw             ;
assign pdec_int_status_reg[0]   = dec_rpt_int_status          ;
assign dec_rpt_int_status       = dec_rpt_int_raw & (~dec_rpt_int_mask);
assign pdec_int_mask_reg[0]     = dec_rpt_int_mask            ;
always @ ( posedge clk or negedge rst_n)
begin
    if( ~rst_n )
        dec_rpt_int_mask <= 1'h1;
    else if( pdec_int_mask_wr )
        dec_rpt_int_mask <= wdata[0];
end

assign dec_rpt_int_clr          = pdec_int_clr_wr & wdata[0];
assign dec_rpt_int_set          = pdec_int_set_wr & wdata[0];

//merger interrupt with group
assign intr_group_0 = drm_sram_int_status | dec_rpt_int_status;

//read
reg        [32-1:0]        rdata_tmp;
always @ ( * )
begin
    if ( ren )
    begin
        case( raddr )
            PDEC_CFG_VER_REG:
                rdata_tmp = pdec_cfg_ver_reg;
            PDEC_ST_REG:
                rdata_tmp = pdec_st_reg;
            PDEC_CTRL_SIG_REG:
                rdata_tmp = pdec_ctrl_sig_reg;
            PDEC_HEAD_INFO_REG:
                rdata_tmp = pdec_head_info_reg;
            PDEC_DEBUG_INFO_REG:
                rdata_tmp = pdec_debug_info_reg;
            PDEC_INT_STATUS_REG:
                rdata_tmp = pdec_int_status_reg;
            PDEC_INT_MASK_REG:
                rdata_tmp = pdec_int_mask_reg;
            PDEC_INT_RAW_REG:
                rdata_tmp = pdec_int_raw_reg;
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
