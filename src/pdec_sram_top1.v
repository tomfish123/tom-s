//////////////////////////////////////////////////////////////////////////////////
// Description: include the following sram/rom/ram
//              index | name      | num | depth*width
//                1   | llr_sram  | 16  | 256*80
//                2   | list_ram  | 8   | 456*4
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps

module pdec_sram_top1#(
  parameter                         WID_INN       = 10              , 
  parameter                         WID_LLR_ADDR  = 6               , //512->6 , 1024->7 , 2048->8 , 4096->9
  parameter                         WID_K         = 8                
)(
  //----clk and reset
  input  wire                        clk                            , 
  input  wire                        rst_n                          , 

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
  output wire[31:0]                  sram2ck_list_rdata              
);
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
      .D        (32                    ),
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
      .D        (32                    ),
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
     .D        (164                 ) ,
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

endmodule
//Local Variables:
//verilog-library-flags:("-y ./ -y dir -y otherdir -y ./inc_dir/")
//verilog-auto-inst-param-value:t
//End:

