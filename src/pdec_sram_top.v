//////////////////////////////////////////////////////////////////////////////////
// Description: include the following sram/rom/ram
//              index | name      | num | depth*width
//                1   | drm_sram  | 2   | 192*24 and 480*24
//                2   | para_sram | 1   | 1026*32
//                3   | llr_sram  | 16  | 256*80
//                4   | list_ram  | 8   | 456*4
//                5   | stage_rom | 1   | 8190*5
//                6   | depth_rom | 1   | 4096*4
//                7   | dec_ram   | 1   | 15*32
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps

module pdec_sram_top#(
  parameter                         WID_LLR       = 6              , 
  parameter                         WID_INN       = 10              , 
  parameter                         WID_N         = 9               , //512->9 4096->12
  parameter                         WID_NODE      = 10              , 
  parameter                         WID_LLR_ADDR  = 6               , //512->6 , 1024->7 , 2048->8 , 4096->9
  parameter                         WID_K         = 8               , 
  parameter                         WID_DEC       = 3                 //WID_K-5
)(
  //----clk and reset
  input  wire                        clk                            , 
  input  wire                        rst_n                          , 

  //----outer interface
  input  wire                        pdec_sram_wen                  , //write enable
  input  wire[13-1:0]                pdec_sram_waddr                , //write address
  input  wire[32-1:0]                pdec_sram_wdata                , //write data
  input  wire                        pdec_sram_ren                  , //read enable
  input  wire[13-1:0]                pdec_sram_raddr                , //read address
  output wire[32-1:0]                pdec_sram_rdata                , //read data //delay ren 1clk
  
  //----pdec_para_cfg interface
  input  wire[2-1:0]                 para_ren                       , 
  input  wire[10-1:0]                para_raddr                     , 
  output wire[31:0]                  para_rdata                     , //delay para_ren 2 cycle
  
  //----pdec_top interface
  input  wire[WID_NODE-1:0]          ctrl2sram_stage_raddr          , 
  input  wire                        ctrl2sram_stage_ren            , 
  output reg                         sram2ctrl_stage_rdata_en       , //for multi pdec read condition
  output reg [4:0]                   sram2ctrl_stage_rdata          , 
  
  input  wire                        ctrl2sram_depth_ren            , 
  input  wire[WID_N-1:0]             ctrl2sram_depth_raddr          , 
  output reg [3:0]                   sram2ctrl_depth_rdata          , 
  
  input  wire                        pdec2drm_llr_ren               , //read drm sram
  input  wire[WID_LLR_ADDR-1:0]      pdec2drm_llr_raddr             , 
  output wire[WID_LLR*8-1:0]         drm2pdec_llr_rdata             , 

  input  wire[7:0]                   rdc2sram_llr_ren               , 
  input  wire[WID_LLR_ADDR*8-1:0]    rdc2sram_llr_raddr             , 
  output wire[WID_INN*64-1:0]        sram2rdc_llr_rdata             , 

  input  wire[7:0]                   ulr2sram_llr_wen               , 
  input  wire[WID_LLR_ADDR*8-1:0]    ulr2sram_llr_waddr             , 
  input  wire[79:0]                  ulr2sram_llr_wbyte             , 
  input  wire[WID_INN*64-1:0]        ulr2sram_llr_wdata             , 

  input  wire[7:0]                   uph2sram_list_wen              , 
  input  wire[WID_K-1:0]             uph2sram_list_waddr            , 
  input  wire[31:0]                  uph2sram_list_wdata            , 

  input  wire[7:0]                   ck2sram_list_ren               , 
  input  wire[WID_K-1:0]             ck2sram_list_raddr             , 
  output wire[31:0]                  sram2ck_list_rdata             , 

  input  wire                        ck2sram_dec_wen                , 
  input  wire[WID_DEC-1:0]           ck2sram_dec_waddr              , 
  input  wire[3:0]                   ck2sram_dec_wbyte              , 
  input  wire[31:0]                  ck2sram_dec_wdata

);
//===============================================
//====          drm sram
//===============================================
wire            drm_sram0_wen      ; 
wire            drm_sram0_ren      ; 
wire[8-1:0]     drm_sram0_addr     ; 
wire            drm_sram0_ce       ; 
wire            drm_sram0_we       ; 
wire[24-1:0]    drm_sram0_wdata    ; 
wire[24-1:0]    drm_sram0_rdata    ; 

wire            drm_sram1_wen      ; 
wire            drm_sram1_ren      ; 
wire[9-1:0]     drm_sram1_addr     ; 
wire            drm_sram1_ce       ; 
wire            drm_sram1_we       ; 
wire[24-1:0]    drm_sram1_wdata    ; 
wire[24-1:0]    drm_sram1_rdata    ; 

reg             drm_sram0_ren_r    ; 
reg             drm_sram1_ren_r    ; 
reg             pdec2drm_llr_ren_r ; 
reg[24-1:0]     drm_sram0_rdata_rr ; 
reg[24-1:0]     drm_sram1_rdata_rr ; 

assign drm_sram0_wen = pdec_sram_wen & pdec_sram_waddr[12:10] == 2'd2;
assign drm_sram1_wen = pdec_sram_wen & pdec_sram_waddr[12:10] == 2'd3;

`ifdef PDEC_BD
  assign drm_sram0_ren = pdec2drm_llr_ren & (pdec2drm_llr_raddr >= 9'd320);
  assign drm_sram1_ren = pdec2drm_llr_ren & (pdec2drm_llr_raddr >= 9'd32 );
  assign drm_sram0_addr = drm_sram0_wen ? pdec_sram_waddr[7:0] : (drm_sram0_ren ? pdec2drm_llr_raddr - 9'd320 : 8'd0);
  assign drm_sram1_addr = drm_sram1_wen ? pdec_sram_waddr[8:0] : (drm_sram1_ren ? pdec2drm_llr_raddr - 9'd32  : 9'd0);
`else
  assign drm_sram0_ren  = pdec2drm_llr_ren;
  assign drm_sram1_ren  = pdec2drm_llr_ren;
  assign drm_sram0_addr = drm_sram0_wen ? pdec_sram_waddr[8:0] : pdec2drm_llr_raddr;
  assign drm_sram1_addr = drm_sram1_wen ? pdec_sram_waddr[8:0] : pdec2drm_llr_raddr;
`endif

assign drm_sram0_ce = drm_sram0_wen | drm_sram0_ren;
assign drm_sram1_ce = drm_sram1_wen | drm_sram1_ren;

assign drm_sram0_we = drm_sram0_wen;
assign drm_sram1_we = drm_sram1_wen;

assign drm_sram0_wdata = drm_sram0_wen ? {pdec_sram_wdata[29:24],pdec_sram_wdata[21:16],pdec_sram_wdata[13:8],pdec_sram_wdata[5:0]} : 24'd0;
assign drm_sram1_wdata = drm_sram1_wen ? {pdec_sram_wdata[29:24],pdec_sram_wdata[21:16],pdec_sram_wdata[13:8],pdec_sram_wdata[5:0]} : 24'd0;

hgw_sram_ff#(
  .D        (192             ),
  .W        (24              ),//in bit
  .RD_TYPE  (0               )) //0=delay address by 1T;1=delay rdata
U_drm_sram0 (
  .clk      (clk             ),
  .ce       (drm_sram0_ce    ),//high active
  .we       (drm_sram0_we    ),//high active
  .addr     (drm_sram0_addr  ),
  .wdata    (drm_sram0_wdata ),
  .rdata    (drm_sram0_rdata ));

hgw_sram_ff#(
  .D        (480             ),
  .W        (24              ),//in bit
  .RD_TYPE  (0               )) //0=delay address by 1T;1=delay rdata
U_drm_sram1 (
  .clk      (clk             ),
  .ce       (drm_sram1_ce    ),//high active
  .we       (drm_sram1_we    ),//high active
  .addr     (drm_sram1_addr  ),
  .wdata    (drm_sram1_wdata ),
  .rdata    (drm_sram1_rdata ));
//----

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin
    drm_sram0_ren_r     <= 1'b0;
    drm_sram1_ren_r     <= 1'b0;
    pdec2drm_llr_ren_r  <= 1'b0;
  end
  else begin
    drm_sram0_ren_r     <= drm_sram0_ren;
    drm_sram1_ren_r     <= drm_sram1_ren;
    pdec2drm_llr_ren_r  <= pdec2drm_llr_ren;
  end
end

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    drm_sram0_rdata_rr <= 24'd0;
  else if(pdec2drm_llr_ren_r)begin
    if(drm_sram0_ren_r)
      drm_sram0_rdata_rr <= drm_sram0_rdata;
    else 
      drm_sram0_rdata_rr <= 24'd0;
  end
end

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    drm_sram1_rdata_rr <= 24'd0;
  else if(pdec2drm_llr_ren_r)begin
    if(drm_sram1_ren_r)
      drm_sram1_rdata_rr <= drm_sram1_rdata;
    else 
      drm_sram1_rdata_rr <= 24'd0;
  end
end

assign drm2pdec_llr_rdata = {drm_sram1_rdata_rr,drm_sram0_rdata_rr};//llr7~llr0

//===============================================
//====          para sram
//===============================================
wire         para_sram0_wen     ; 
wire         para_sram1_wen     ; 
wire[11-1:0] para_sram0_waddr   ; 
wire[11-1:0] para_sram1_waddr   ; 

wire         para_sram0_ren     ; 
wire         para_sram1_ren     ; 
wire[11-1:0] para_sram0_raddr   ; 
wire[11-1:0] para_sram1_raddr   ; 

wire         para_sram_ce       ; 
wire         para_sram_we       ; 
reg [11-1:0] para_sram_addr     ; 
wire[32-1:0] para_sram_wdata    ; 
wire[32-1:0] para_sram_rdata    ; 

reg          para_sram_ren_r    ; 
reg [31:0]   para_sram_rdata_rr ; 

assign para_sram0_wen = pdec_sram_wen & pdec_sram_waddr[12:10] == 2'd0;
assign para_sram1_wen = pdec_sram_wen & pdec_sram_waddr[12:10] == 2'd1;

assign para_sram0_waddr = para_sram0_wen ? pdec_sram_waddr[9:0]           : 11'd0;
assign para_sram1_waddr = para_sram1_wen ? pdec_sram_waddr[9:0] + 10'd513 : 11'd0;

assign para_sram0_ren = para_ren[0];
assign para_sram1_ren = para_ren[1];

assign para_sram0_raddr = para_sram0_ren ? para_raddr[9:0]           : 11'd0;
assign para_sram1_raddr = para_sram1_ren ? para_raddr[9:0] + 10'd513 : 11'd0;

assign para_sram_ce = para_sram0_wen | para_sram1_wen | para_sram0_ren | para_sram1_ren;
assign para_sram_we = para_sram0_wen | para_sram1_wen;

always @(*)begin
  if(para_sram0_wen)
    para_sram_addr <= para_sram0_waddr;
  else if(para_sram1_wen)
    para_sram_addr <= para_sram1_waddr;
  else if(para_sram0_ren)
    para_sram_addr <= para_sram0_raddr;
  else if(para_sram1_ren)
    para_sram_addr <= para_sram1_raddr;
  else   
    para_sram_addr <= 11'd0;
end

assign para_sram_wdata = pdec_sram_wdata; 

hgw_sram_ff#(
  .D        (1026             ),//513*2
  .W        (32               ),//in bit
  .RD_TYPE  (0                )) //0=delay address by 1T;1=delay rdata
U_para_sram (
  .clk      (clk              ),
  .ce       (para_sram_ce     ),//high active
  .we       (para_sram_we     ),//high active
  .addr     (para_sram_addr   ),
  .wdata    (para_sram_wdata  ),
  .rdata    (para_sram_rdata  ));

//----
always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    para_sram_ren_r <= 1'b0;
  else   
    para_sram_ren_r <= (para_sram0_ren | para_sram1_ren);
end
always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    para_sram_rdata_rr <= 32'd0;
  else if(para_sram_ren_r)   
    para_sram_rdata_rr <= para_sram_rdata;
end

assign para_rdata = para_sram_rdata_rr; 

//===============================================
//====          llr sram
//===============================================
genvar                              ii                       ; 
wire[7:0]                           dpram_ren                ; 
wire[WID_LLR_ADDR-1:0]              dpram_raddr[7:0]         ; 
wire[7:0]                           dpram_wen                ; 
wire[WID_LLR_ADDR-1:0]              dpram_waddr[7:0]         ; 
wire[10*9-1:0]                      dpram_wdata[7:0]         ; 
wire[10*9-1:0]                      dpram_rdata_pre[7:0]     ; 
wire[10*8-1:0]                      dpram_rdata[7:0]         ; 

wire[7:0]                           spram_we_0               ; 
wire[7:0]                           spram_ce_0               ; 
wire[WID_LLR_ADDR-2:0]              spram_addr_0[7:0]        ; 
wire[10*9-1:0]                      spram_wdata_0_pre[7:0]   ; 
wire[10-1:0]                        spram_wbyte_0[7:0]       ; 
wire[10*8-1:0]                      spram_wdata_0[7:0]       ; 
wire[10*9-1:0]                      spram_rdata_0[7:0]       ; 
wire[10*8-1:0]                      spram_rdata_0_pre[7:0]   ; 

wire[7:0]                           spram_we_1               ; 
wire[7:0]                           spram_ce_1               ; 
wire[WID_LLR_ADDR-2:0]              spram_addr_1[7:0]        ; 
wire[10*9-1:0]                      spram_wdata_1_pre[7:0]   ; 
wire[10-1:0]                        spram_wbyte_1[7:0]       ; 
wire[10*8-1:0]                      spram_wdata_1[7:0]       ; 
wire[10*9-1:0]                      spram_rdata_1[7:0]       ; 
wire[10*8-1:0]                      spram_rdata_1_pre[7:0]   ; 
reg [7:0]                           spram_rdata_0_en         ; 
reg [7:0]                           spram_rdata_1_en         ; 
reg [10*8-1:0]                      spram_rdata_0_pre_r[7:0] ; 
reg [10*8-1:0]                      spram_rdata_1_pre_r[7:0] ; 

generate
  for(ii=0 ; ii<8 ; ii=ii+1)begin  : llr_sram
    assign dpram_ren[ii]   = rdc2sram_llr_ren[ii];
    assign dpram_raddr[ii] = rdc2sram_llr_raddr[WID_LLR_ADDR*ii +: WID_LLR_ADDR];
    assign dpram_wen[ii]   = ulr2sram_llr_wen[ii];
    assign dpram_waddr[ii] = ulr2sram_llr_waddr[WID_LLR_ADDR*ii +: WID_LLR_ADDR];
    assign dpram_wdata[ii] = {ulr2sram_llr_wbyte[10*ii+9],ulr2sram_llr_wdata[10*8*ii+8*9 +: 8], 
                              ulr2sram_llr_wbyte[10*ii+8],ulr2sram_llr_wdata[10*8*ii+8*8 +: 8],
                              ulr2sram_llr_wbyte[10*ii+7],ulr2sram_llr_wdata[10*8*ii+8*7 +: 8],
                              ulr2sram_llr_wbyte[10*ii+6],ulr2sram_llr_wdata[10*8*ii+8*6 +: 8],
                              ulr2sram_llr_wbyte[10*ii+5],ulr2sram_llr_wdata[10*8*ii+8*5 +: 8],
                              ulr2sram_llr_wbyte[10*ii+4],ulr2sram_llr_wdata[10*8*ii+8*4 +: 8],
                              ulr2sram_llr_wbyte[10*ii+3],ulr2sram_llr_wdata[10*8*ii+8*3 +: 8],
                              ulr2sram_llr_wbyte[10*ii+2],ulr2sram_llr_wdata[10*8*ii+8*2 +: 8],
                              ulr2sram_llr_wbyte[10*ii+1],ulr2sram_llr_wdata[10*8*ii+8*1 +: 8],
                              ulr2sram_llr_wbyte[10*ii+0],ulr2sram_llr_wdata[10*8*ii+8*0 +: 8]};
    //----dp2sp
    //hgw_pseudo_dpram_pipo #(
    pdec_dp2sp #(
        .DW             (10*9                   ),
        .AW             (WID_LLR_ADDR           ),
        .SRAM_DLY       (2                      ))
    u_llr_dp2sp(
        .clk            (clk                    ),
        .rst_n          (rst_n                  ),
        .dpram_wen      (dpram_wen[ii]          ),
        .dpram_ren      (dpram_ren[ii]          ),
        .dpram_wdata    (dpram_wdata[ii]        ),
        .dpram_waddr    (dpram_waddr[ii]        ),
        .dpram_rdata    (dpram_rdata_pre[ii]    ),
        .dpram_raddr    (dpram_raddr[ii]        ),
        .spram_we_0     (spram_we_0[ii]         ),
        .spram_ce_0     (spram_ce_0[ii]         ),
        .spram_addr_0   (spram_addr_0[ii]       ),
        .spram_wdata_0  (spram_wdata_0_pre[ii]  ),
        .spram_rdata_0  (spram_rdata_0[ii]      ),
        .spram_we_1     (spram_we_1[ii]         ),
        .spram_ce_1     (spram_ce_1[ii]         ),
        .spram_addr_1   (spram_addr_1[ii]       ),
        .spram_wdata_1  (spram_wdata_1_pre[ii]  ),
        .spram_rdata_1  (spram_rdata_1[ii]      ));

    //----llr ping pong sram
    assign spram_wdata_0[ii] = {spram_wdata_0_pre[ii][9*9 +: 8],spram_wdata_0_pre[ii][9*8 +: 8],
                                spram_wdata_0_pre[ii][9*7 +: 8],spram_wdata_0_pre[ii][9*6 +: 8],
                                spram_wdata_0_pre[ii][9*5 +: 8],spram_wdata_0_pre[ii][9*4 +: 8],
                                spram_wdata_0_pre[ii][9*3 +: 8],spram_wdata_0_pre[ii][9*2 +: 8],
                                spram_wdata_0_pre[ii][9*1 +: 8],spram_wdata_0_pre[ii][9*0 +: 8]};
    
    assign spram_wbyte_0[ii] = {spram_wdata_0_pre[ii][9*9 + 8],spram_wdata_0_pre[ii][9*8 + 8],
                                spram_wdata_0_pre[ii][9*7 + 8],spram_wdata_0_pre[ii][9*6 + 8],
                                spram_wdata_0_pre[ii][9*5 + 8],spram_wdata_0_pre[ii][9*4 + 8],
                                spram_wdata_0_pre[ii][9*3 + 8],spram_wdata_0_pre[ii][9*2 + 8],
                                spram_wdata_0_pre[ii][9*1 + 8],spram_wdata_0_pre[ii][9*0 + 8]};

    assign spram_wdata_1[ii] = {spram_wdata_1_pre[ii][9*9 +: 8],spram_wdata_1_pre[ii][9*8 +: 8],
                                spram_wdata_1_pre[ii][9*7 +: 8],spram_wdata_1_pre[ii][9*6 +: 8],
                                spram_wdata_1_pre[ii][9*5 +: 8],spram_wdata_1_pre[ii][9*4 +: 8],
                                spram_wdata_1_pre[ii][9*3 +: 8],spram_wdata_1_pre[ii][9*2 +: 8],
                                spram_wdata_1_pre[ii][9*1 +: 8],spram_wdata_1_pre[ii][9*0 +: 8]};

    assign spram_wbyte_1[ii] = {spram_wdata_1_pre[ii][9*9 + 8],spram_wdata_1_pre[ii][9*8 + 8],
                                spram_wdata_1_pre[ii][9*7 + 8],spram_wdata_1_pre[ii][9*6 + 8],
                                spram_wdata_1_pre[ii][9*5 + 8],spram_wdata_1_pre[ii][9*4 + 8],
                                spram_wdata_1_pre[ii][9*3 + 8],spram_wdata_1_pre[ii][9*2 + 8],
                                spram_wdata_1_pre[ii][9*1 + 8],spram_wdata_1_pre[ii][9*0 + 8]};
    //----
    hgw_sram_ff_bye#(
      .D        (256                    ),
      .W        (10                     ),//in byte
      .RD_TYPE  (0                      ))//0=delay address by 1T;1=delay rdata
    U_llr_sram0 (
      .clk      (clk                    ),
      .ce       (spram_ce_0[ii]         ),//high active
      .we       (spram_we_0[ii]         ),//high active
      .addr     (spram_addr_0[ii]       ),
      .byte_en  (spram_wbyte_0[ii]      ),  //high active
      .wdata    (spram_wdata_0[ii]      ),
      .rdata    (spram_rdata_0_pre[ii]  ));
   
   hgw_sram_ff_bye#(
      .D        (256                    ),
      .W        (10                     ),//in byte
      .RD_TYPE  (0                      ))//0=delay address by 1T;1=delay rdata
    U_llr_sram1 (
      .clk      (clk                    ),
      .ce       (spram_ce_1[ii]         ),//high active
      .we       (spram_we_1[ii]         ),//high active
      .addr     (spram_addr_1[ii]       ),
      .byte_en  (spram_wbyte_1[ii]      ),  //high active
      .wdata    (spram_wdata_1[ii]      ),
      .rdata    (spram_rdata_1_pre[ii]  ));

    //----
    always @(posedge clk or negedge rst_n)begin
      if(!rst_n)begin
        spram_rdata_0_en[ii] <= 1'b0;
        spram_rdata_1_en[ii] <= 1'b0;
      end
      else begin
        spram_rdata_0_en[ii] <= (~spram_we_0[ii]) & spram_ce_0[ii];
        spram_rdata_1_en[ii] <= (~spram_we_1[ii]) & spram_ce_1[ii];
      end
    end
    
    always @(posedge clk or negedge rst_n)begin
      if(!rst_n)
        spram_rdata_0_pre_r[ii] <= {10*8{1'b0}};
      else if(spram_rdata_0_en[ii])
        spram_rdata_0_pre_r[ii] <= spram_rdata_0_pre[ii];
    end
    
    always @(posedge clk or negedge rst_n)begin
      if(!rst_n)
        spram_rdata_1_pre_r[ii] <= {10*8{1'b0}};
      else if(spram_rdata_1_en[ii])
        spram_rdata_1_pre_r[ii] <= spram_rdata_1_pre[ii];
    end
    
    assign spram_rdata_0[ii] = {1'b0,spram_rdata_0_pre_r[ii][8*9 +: 8], 
                                1'b0,spram_rdata_0_pre_r[ii][8*8 +: 8],
                                1'b0,spram_rdata_0_pre_r[ii][8*7 +: 8],
                                1'b0,spram_rdata_0_pre_r[ii][8*6 +: 8],
                                1'b0,spram_rdata_0_pre_r[ii][8*5 +: 8],
                                1'b0,spram_rdata_0_pre_r[ii][8*4 +: 8],
                                1'b0,spram_rdata_0_pre_r[ii][8*3 +: 8],
                                1'b0,spram_rdata_0_pre_r[ii][8*2 +: 8],
                                1'b0,spram_rdata_0_pre_r[ii][8*1 +: 8],
                                1'b0,spram_rdata_0_pre_r[ii][8*0 +: 8]};

    assign spram_rdata_1[ii] = {1'b0,spram_rdata_1_pre_r[ii][8*9 +: 8], 
                                1'b0,spram_rdata_1_pre_r[ii][8*8 +: 8],
                                1'b0,spram_rdata_1_pre_r[ii][8*7 +: 8],
                                1'b0,spram_rdata_1_pre_r[ii][8*6 +: 8],
                                1'b0,spram_rdata_1_pre_r[ii][8*5 +: 8],
                                1'b0,spram_rdata_1_pre_r[ii][8*4 +: 8],
                                1'b0,spram_rdata_1_pre_r[ii][8*3 +: 8],
                                1'b0,spram_rdata_1_pre_r[ii][8*2 +: 8],
                                1'b0,spram_rdata_1_pre_r[ii][8*1 +: 8],
                                1'b0,spram_rdata_1_pre_r[ii][8*0 +: 8]};

    assign dpram_rdata[ii]   = {dpram_rdata_pre[ii][9*9 +: 8], 
                                dpram_rdata_pre[ii][9*8 +: 8],
                                dpram_rdata_pre[ii][9*7 +: 8],
                                dpram_rdata_pre[ii][9*6 +: 8],
                                dpram_rdata_pre[ii][9*5 +: 8],
                                dpram_rdata_pre[ii][9*4 +: 8],
                                dpram_rdata_pre[ii][9*3 +: 8],
                                dpram_rdata_pre[ii][9*2 +: 8],
                                dpram_rdata_pre[ii][9*1 +: 8],
                                dpram_rdata_pre[ii][9*0 +: 8]};

    assign sram2rdc_llr_rdata[WID_INN*8*ii +: WID_INN*8] = dpram_rdata[ii];

  end
endgenerate
//===============================================
//====      list sram
//===============================================
wire[7:0]       list_ram_we           ; 
wire[7:0]       list_ram_re           ; 
wire[7:0]       list_ram_ce           ; 
wire[WID_K-1:0] list_ram_addr[7:0]    ; 
wire[4-1:0]     list_ram_wdata[7:0]   ; 
wire[4-1:0]     list_ram_rdata[7:0]   ; 
reg [7:0]       list_ram_re_r         ; 
reg [3:0]       list_ram_rdata_r[7:0] ; 

generate
  for(ii=0 ; ii<8 ; ii=ii+1)begin  : list_ram
    assign list_ram_we[ii]    = uph2sram_list_wen[ii];
    assign list_ram_re[ii]    = ck2sram_list_ren[ii];
    assign list_ram_ce[ii]    = list_ram_we[ii] | list_ram_re[ii];
    assign list_ram_addr[ii]  = list_ram_we[ii] ? uph2sram_list_waddr : ck2sram_list_raddr;
    assign list_ram_wdata[ii] = uph2sram_list_wdata[ii*4 +: 4];

    hgw_sram_ff #(
     .D        (456                 ) ,
     .W        (4                   ) ,   //in bit
     .RD_TYPE  (0                   ) ) 
    U_list_ram(
     .clk      (clk                 ) ,
     .ce       (list_ram_ce[ii]     ) ,   //high active
     .we       (list_ram_we[ii]     ) ,   //high active
     .addr     (list_ram_addr[ii]   ) ,
     .wdata    (list_ram_wdata[ii]  ) ,
     .rdata    (list_ram_rdata[ii]  ) ) ; 


    always @(posedge clk or negedge rst_n)begin
      if(!rst_n)
        list_ram_re_r[ii] <= 1'b0;
      else 
        list_ram_re_r[ii] <= list_ram_re[ii];
    end
     
    always @(posedge clk or negedge rst_n)begin
      if(!rst_n)
        list_ram_rdata_r[ii] <= 4'd0;
      else if(list_ram_re_r[ii])
        list_ram_rdata_r[ii] <= list_ram_rdata[ii];
    end
     
     assign sram2ck_list_rdata[ii*4 +: 4] = list_ram_rdata_r[ii]; 
  end
endgenerate
//===============================================
//====      stage/fg rom
//===============================================
wire               stage_rom_ce   ;
wire[WID_NODE-1:0] stage_rom_addr ;
wire[5-1:0]        stage_rom_rdata;
reg                stage_rom_ren_r;

assign stage_rom_ce   = ctrl2sram_stage_ren;
assign stage_rom_addr = ctrl2sram_stage_raddr;
`ifdef PDEC_BD
  pdec_rom_stage_bd #(
   .D        (8190                ) ,
   .W        (5                   ) ,
   .RD_TYPE  (0                   ) ) 
  U_stage_rom(
   .clk      (clk                 ) ,
   .ce       (stage_rom_ce        ) ,   //high active
   .we       (1'b0                ) ,   //high active
   .addr     (stage_rom_addr      ) ,
   .wdata    (5'd0                ) ,
   .rdata    (stage_rom_rdata     ) ) ; 
`else
  pdec_rom_stage #(
   .D        (1022                ) ,
   .W        (5                   ) ,
   .RD_TYPE  (0                   ) ) 
  U_stage_rom(
   .clk      (clk                 ) ,
   .ce       (stage_rom_ce        ) ,   //high active
   .we       (1'b0                ) ,   //high active
   .addr     (stage_rom_addr      ) ,
   .wdata    (5'd0                ) ,
   .rdata    (stage_rom_rdata     ) ) ; 
`endif
always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    stage_rom_ren_r <= 1'b0;
  else
    stage_rom_ren_r <= stage_rom_ce;
end

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin
    sram2ctrl_stage_rdata    <= 5'd0;
    sram2ctrl_stage_rdata_en <= 1'b0;
  end
  else if(stage_rom_ren_r)begin
    sram2ctrl_stage_rdata    <= stage_rom_rdata;
    sram2ctrl_stage_rdata_en <= 1'b1;
  end
  else
    sram2ctrl_stage_rdata_en <= 1'b0;
end
//===============================================
//====      depth rom
//===============================================
wire               depth_rom_ce   ;
wire[WID_N-1:0]    depth_rom_addr ;
wire[4-1:0]        depth_rom_rdata;
reg                depth_rom_ren_r;

assign depth_rom_ce   = ctrl2sram_depth_ren;
assign depth_rom_addr = ctrl2sram_depth_raddr;
`ifdef PDEC_BD
  pdec_rom_depth_bd #(
   .D        (4096                ) ,
   .W        (4                   ) ,
   .RD_TYPE  (0                   ) ) 
  U_depth_rom(
   .clk      (clk                 ) ,
   .ce       (depth_rom_ce        ) ,   //high active
   .we       (1'b0                ) ,   //high active
   .addr     (depth_rom_addr      ) ,
   .wdata    (4'd0                ) ,
   .rdata    (depth_rom_rdata     ) ) ; 
`else
  pdec_rom_depth #(
   .D        (512                 ) ,
   .W        (4                   ) ,
   .RD_TYPE  (0                   ) ) 
  U_depth_rom(
   .clk      (clk                 ) ,
   .ce       (depth_rom_ce        ) ,   //high active
   .we       (1'b0                ) ,   //high active
   .addr     (depth_rom_addr      ) ,
   .wdata    (4'd0                ) ,
   .rdata    (depth_rom_rdata     ) ) ; 
`endif
always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    depth_rom_ren_r <= 1'b0;
  else
    depth_rom_ren_r <= depth_rom_ce;
end

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    sram2ctrl_depth_rdata    <= 4'd0;
  else if(depth_rom_ren_r)
    sram2ctrl_depth_rdata    <= depth_rom_rdata;
end

//===============================================
//====        dec_ram
//===============================================
wire                dec_ram_we   ; 
wire                dec_ram_re   ;
wire                dec_ram_ce   ;
wire[WID_DEC-1:0]   dec_ram_addr ;
wire[3:0]           dec_ram_wbyte;
wire[31:0]          dec_ram_wdata;
wire[31:0]          dec_ram_rdata;

assign dec_ram_we    = ck2sram_dec_wen;
assign dec_ram_re    = pdec_sram_ren && pdec_sram_raddr[12:10] == 3'd4;
assign dec_ram_ce    = dec_ram_we | dec_ram_re;
assign dec_ram_addr  = dec_ram_we ? ck2sram_dec_waddr : pdec_sram_raddr[WID_DEC-1:0];
assign dec_ram_wbyte = ck2sram_dec_wbyte;
assign dec_ram_wdata = ck2sram_dec_wdata;

hgw_sram_ff_bye #(
 .D        (15                  ) ,
 .W        (4                   ) ,
 .RD_TYPE  (0                   ) ) 
U_dec_ram(
 .clk      (clk                 ) ,
 .ce       (dec_ram_ce          ) ,   //high active
 .we       (dec_ram_we          ) ,   //high active
 .addr     (dec_ram_addr        ) ,
 .byte_en  (dec_ram_wbyte       ) ,  //high active
 .wdata    (dec_ram_wdata       ) ,
 .rdata    (dec_ram_rdata       ) ) ; 

assign pdec_sram_rdata =  dec_ram_rdata; //delay one cycle

endmodule
//Local Variables:
//verilog-library-flags:("-y ./ -y dir -y otherdir -y ./inc_dir/")
//verilog-auto-inst-param-value:t
//End:

