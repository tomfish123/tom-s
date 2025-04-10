//////////////////////////////////////////////////////////////////////////////////
// Description:
// This module is used for fifo with dpram. That is to say, only when 
// write/read address of dpram is continuous can this module be used.
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps


module pdec_dp2sp #(
    parameter       DW  =   16,
    parameter       AW  =   8,
    parameter       SRAM_DLY = 2
) (
    input                   clk,
    input                   rst_n,

    input                   dpram_wen,
    input                   dpram_ren,
    input   [DW-1:0]        dpram_wdata,
    input   [AW-1:0]        dpram_waddr,
    output  [DW-1:0]        dpram_rdata,
    input   [AW-1:0]        dpram_raddr,

    output                  spram_we_0,
    output                  spram_ce_0,
    output  [AW-1-1:0]      spram_addr_0,
    output  [DW-1:0]        spram_wdata_0,
    input   [DW-1:0]        spram_rdata_0,

    output                  spram_we_1,
    output                  spram_ce_1,
    output  [AW-1-1:0]      spram_addr_1,
    output  [DW-1:0]        spram_wdata_1,
    input   [DW-1:0]        spram_rdata_1
);

wire            conflict;
//reg             w_sel;
//reg             r_sel;
wire            w_sel;
wire            r_sel;
reg [DW-1:0]    w_data_buf;
reg             w_en_buf;  
reg [AW-1:0]    w_addr_buf;  
reg             w_sel_d;
wire            spram_wen_0;     
wire            spram_wen_1;
wire            spram_wen_conf_0;
wire            spram_wen_conf_1;
wire            spram_wen_unconf_0;
wire            spram_wen_unconf_1;
wire            spram_ren_0;
wire            spram_ren_1;
reg  [SRAM_DLY-1:0] r_sel_d;

assign conflict     = dpram_wen & dpram_ren & (w_sel ^! r_sel);

assign w_sel        = dpram_waddr[0];
assign r_sel        = dpram_raddr[0];

//always @(posedge clk or negedge rst_n)
//begin
//    if(rst_n==1'b0)
//        w_sel   <=      1'b0;
//    else if(dpram_wen)
//        w_sel   <=      !w_sel;
//end
//
//always @(posedge clk or negedge rst_n)
//begin
//    if(rst_n==1'b0)
//        r_sel   <=      1'b0;
//    else if(dpram_ren)
//        r_sel   <=      !r_sel;
//end

always @(posedge clk or negedge rst_n)
begin
    if(rst_n==1'b0)
        w_data_buf      <=      {DW{1'b0}};
    else if(conflict)
        w_data_buf      <=      dpram_wdata;
end

always @(posedge clk or negedge rst_n)
begin
    if(rst_n==1'b0)
        w_en_buf        <=      1'b0;
    else if(conflict)
        w_en_buf        <=      1'b1;
    else if(w_en_buf)
        w_en_buf        <=      1'b0;
end

always @(posedge clk or negedge rst_n)
begin
    if(rst_n==1'b0)
        w_addr_buf      <=      {AW{1'b0}};
    else if(conflict)
        w_addr_buf      <=      dpram_waddr;
end

always @(posedge clk or negedge rst_n)
begin
    if(rst_n==1'b0)
        w_sel_d         <=      1'b0;
    else
        w_sel_d         <=      w_sel;
end

always @(posedge clk or negedge rst_n)
begin
    if(rst_n==1'b0)
        r_sel_d         <=      {SRAM_DLY{1'b0}};
    else if(r_sel | (|r_sel_d))
        r_sel_d         <=      {r_sel_d[SRAM_DLY-2:0], r_sel};
end

assign spram_ren_0 = dpram_ren & (!r_sel);
assign spram_ren_1 = dpram_ren &   r_sel;

assign spram_wen_conf_0 = w_en_buf & (!w_sel_d);
assign spram_wen_conf_1 = w_en_buf &   w_sel_d ;

assign spram_wen_unconf_0 = dpram_wen & (!w_sel) & (!conflict);
assign spram_wen_unconf_1 = dpram_wen &   w_sel  & (!conflict);

assign spram_wen_0 = spram_wen_conf_0 | spram_wen_unconf_0;
assign spram_wen_1 = spram_wen_conf_1 | spram_wen_unconf_1;

assign spram_ce_0  = spram_ren_0|spram_wen_0;
assign spram_ce_1  = spram_ren_1|spram_wen_1;

assign spram_we_0  = spram_wen_0;
assign spram_we_1  = spram_wen_1;

assign spram_addr_0 = {AW-1{spram_ren_0}} & dpram_raddr[AW-1:1] | 
                      {AW-1{spram_wen_conf_0}} & w_addr_buf[AW-1:1] |
                      {AW-1{spram_wen_unconf_0}} & dpram_waddr[AW-1:1] ;
assign spram_addr_1 = {AW-1{spram_ren_1}} & dpram_raddr[AW-1:1] | 
                      {AW-1{spram_wen_conf_1}} & w_addr_buf[AW-1:1] |
                      {AW-1{spram_wen_unconf_1}} & dpram_waddr[AW-1:1] ;

assign spram_wdata_0 = {DW{spram_wen_conf_0}} & w_data_buf |
                       {DW{spram_wen_unconf_0}} & dpram_wdata ;
assign spram_wdata_1 = {DW{spram_wen_conf_1}} & w_data_buf |
                       {DW{spram_wen_unconf_1}} & dpram_wdata ;

assign dpram_rdata  =  {DW{!r_sel_d[SRAM_DLY-1]}} & spram_rdata_0 |
                       {DW{ r_sel_d[SRAM_DLY-1]}} & spram_rdata_1 ;

endmodule
