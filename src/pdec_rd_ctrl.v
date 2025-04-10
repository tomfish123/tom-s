//////////////////////////////////////////////////////////////////////////////////
// Description:  1. for top_stage : read llr from drm_sram ,which address is
//                  0 to 2^(stage+1)/8 -1
//               2. for inn_stage : read llr from llr_sram ,which address is
//                  (1).stage <= 1 : 0
//                  (2).stage >= 2 : 2^(stage+1)/8 : (2^(stage+1)/8)*2 - 1
//               3. for llr_ptr : choose stage+1
//               4. for us_ptr  : choose stage
//               5. timing is :
//                  stage        :    <-----4------->
//                  inn_st       : /-\
//                  llr_ren      :    /----------\
//                  llr_raddr    :    <4><5><6><7> 
//                  llr_ren_r    :       /----------\
//                  llr_ren_done :                /-\
//               6. valid and CK path need to read llr and us to update llr
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps

module pdec_rd_ctrl#(
  parameter                         WID_LLR       = 6  ,
  parameter                         WID_INN       = 10 ,
  parameter                         WID_LLR_ADDR  = 6  ,//512->6,1024->7,2048->8,4096->9       
  parameter                         NUM_PTR       = 9  ,
  parameter                         NUM_US        = 256 //512->256,4096->2048
)(
  input  wire                       clk                , 
  input  wire                       rst_n              , 
  
  //----ICG
  output wire                       pdec_clk_en1       ,

  //----broacast control signals
  input  wire                       cur_fg             , //0:G function, 1:F function
  input  wire[3:0]                  cur_stage          , //
  input  wire[3:0]                  top_stage          ,
  input  wire[2*8-1:0]              path_valid         , //0:CK path, 1:valid path,3:invalid_path
  
  //----pdec_top_ctrl interface
  input  wire                       ctrl2rdc_drm_st    , //read drm llr start
  input  wire                       ctrl2rdc_inn_st    , //read inn llr start
  output wire                       rdc2ctrl_rd_done   ,
  
  //----pdec_updt_path interface
  input  wire[NUM_PTR*3*8-1:0]      uph2rdc_llr_ptr    , 
  input  wire[NUM_PTR*3*8-1:0]      uph2rdc_us_ptr     , 
  
  //----pdec_updt_us interface
  input  wire[NUM_US*8-1:0]         uus2rdc_us_data    ,
  
  //----pdec_updt_llr interface
  output wire[8-1:0]                rdc2ulr_llr_st     , //include path valid information
  output wire[8-1:0]                rdc2ulr_llr_en     , //include path valid information
  output wire[WID_INN*8*8-1:0]      rdc2ulr_llr_data   ,
  output wire[4*8-1:0]              rdc2ulr_us_data    ,
  
  //----pdec_sram_top interface
  output wire                       pdec2drm_llr_ren   ,
  output wire[WID_LLR_ADDR-1:0]     pdec2drm_llr_raddr ,
  input  wire[WID_LLR*8-1:0]        drm2pdec_llr_rdata ,

  output wire[8-1:0]                rdc2sram_llr_ren   , 
  output wire[WID_LLR_ADDR*8-1:0]   rdc2sram_llr_raddr , 
  input  wire[WID_INN*8*8-1:0]      sram2rdc_llr_rdata
);
//====================================================
//====          inner signals
//====================================================
genvar                  ii                 ; 
genvar                  jj                 ; 
//----top control
wire[3:0]               cur_stage_sub2     ; 
wire[WID_LLR_ADDR-1:0]  llr_addr_base      ; 
wire[WID_LLR_ADDR-1:0]  llr_addr_space     ; 
reg                     drm_llr_ren        ; 
reg [WID_LLR_ADDR-1:0]  drm_llr_raddr      ; 
reg                     inn_llr_ren        ; 
reg [WID_LLR_ADDR-1:0]  inn_llr_raddr      ; 
reg                     inn_llr_ren_r      ; 
reg                     inn_llr_ren_rr     ; 
reg                     drm_llr_ren_r      ; 
reg                     drm_llr_ren_rr     ; 
//----llr mux based on llr pointer
wire[NUM_PTR*3-1:0]     llr_ptr_mem[7:0]   ; 
wire[2:0]               llr_ptr_stage[7:0] ; 
wire[7:0]               llr_path_ind[7:0]  ; 
wire[7:0]               path_llr_ren[7:0]  ; 
reg [2:0]               llr_ptr_stage_r[7:0]; 
reg [2:0]               llr_ptr_stage_rr[7:0]; 
wire[7:0]               path_llr_en        ; 
wire[WID_INN*8-1:0]     path_llr_mem[7:0]  ; 
reg [WID_INN*8*8-1:0]   path_llr_data      ; 
wire[7:0]               drm_llr_en         ; 
wire[WID_INN*8-1:0]     drm_llr            ;
wire[7:0]               path_valid_r       ;
wire[7:0]               llr_st             ;
//----us mux based on us pointer
wire                    us_ren_r           ; 
reg [WID_LLR_ADDR-1:0]  us_raddr_r         ; 
wire[NUM_PTR*3-1:0]     us_ptr_mem[7:0]    ; 
wire[2:0]               us_ptr_stage[7:0]  ; 
wire[NUM_US-1:0]        us_data_mem[7:0]   ; 
reg [4*8-1:0]           path_us_data       ; 

//====================================================
//====          top control
//====================================================
assign cur_stage_sub2 = cur_stage < 4'd2 ? 4'd0 : cur_stage - 2'd2; //unsigned - unsigned
assign llr_addr_base  = cur_stage < 4'd2 ? {WID_LLR_ADDR{1'b0}} : (1 << cur_stage_sub2);  
assign llr_addr_space = llr_addr_base;  

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    drm_llr_ren <= 1'b0;
  else if(ctrl2rdc_drm_st)
    drm_llr_ren <= 1'b1;
  else if(drm_llr_ren && (drm_llr_raddr == (llr_addr_space - 1'b1))) //for N=512 : 0~63 
    drm_llr_ren <= 1'b0;
end

always @(posedge clk or negedge rst_n)begin //drm function is implemented in sram_top
  if(!rst_n)
    drm_llr_raddr <= {WID_LLR_ADDR{1'b0}};
  else if(ctrl2rdc_drm_st)
    drm_llr_raddr <= {WID_LLR_ADDR{1'b0}};
  else if(drm_llr_ren)
    drm_llr_raddr <= drm_llr_raddr + 1'b1;
end

assign pdec2drm_llr_ren    = drm_llr_ren   ; 
assign pdec2drm_llr_raddr  = drm_llr_raddr ; 

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    inn_llr_ren <= 1'b0;
  else if(ctrl2rdc_inn_st)
    inn_llr_ren <= 1'b1;
  else if(inn_llr_ren && (cur_stage < 4'd2) && (inn_llr_raddr == {WID_LLR_ADDR{1'b0}}))  
    inn_llr_ren <= 1'b0;
  else if(inn_llr_ren && (inn_llr_raddr == (llr_addr_base + llr_addr_space - 1'b1)))  
    inn_llr_ren <= 1'b0;
end

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    inn_llr_raddr <= {WID_LLR_ADDR{1'b0}};
  else if(ctrl2rdc_inn_st)
    inn_llr_raddr <= llr_addr_base;
  else if(inn_llr_ren)
    inn_llr_raddr <= inn_llr_raddr + 1'b1;
end

always @(posedge clk or negedge rst_n)begin 
  if(!rst_n)begin
    inn_llr_ren_r  <= 1'b0;
    inn_llr_ren_rr <= 1'b0;
    drm_llr_ren_r  <= 1'b0;
    drm_llr_ren_rr <= 1'b0;
  end
  else begin
    inn_llr_ren_r  <= inn_llr_ren  ;
    inn_llr_ren_rr <= inn_llr_ren_r; //align with sram_rdata
    drm_llr_ren_r  <= drm_llr_ren  ;
    drm_llr_ren_rr <= drm_llr_ren_r; //align with sram_rdata
  end
end
assign rdc2ctrl_rd_done = ((~drm_llr_ren) & drm_llr_ren_r) | ((~inn_llr_ren) & inn_llr_ren_r) ;
//====================================================
//====     inn llr mux based on llr pointer
//====================================================
generate
  for(ii=0 ; ii<8 ; ii=ii+1)begin  : inn_llr_mux
    //----read enable mux
    assign llr_ptr_mem[ii]   = uph2rdc_llr_ptr[(ii+1)*NUM_PTR*3-1:ii*NUM_PTR*3];
    assign llr_ptr_stage[ii] = (inn_llr_ren & (~path_valid[ii*2+1])) ? llr_ptr_mem[ii][(cur_stage+1)*3 +: 3] : 3'd0;
    assign llr_path_ind[ii]  = 1 << llr_ptr_stage[ii];
    assign path_llr_ren[ii]  = {8{inn_llr_ren & (~path_valid[ii*2+1])}} & llr_path_ind[ii];   //indicate which bank should be read
    //----read data mux
    always @(posedge clk or negedge rst_n)begin
      if(!rst_n)
        llr_ptr_stage_r[ii] <= 3'd0;
      else if(inn_llr_ren & (~path_valid[ii*2+1]))  
        llr_ptr_stage_r[ii] <= llr_ptr_stage[ii];
    end
    
    always @(posedge clk or negedge rst_n)begin
      if(!rst_n)
        llr_ptr_stage_rr[ii] <= 3'd0;
      else if(inn_llr_ren_r & (~path_valid[ii*2+1]))  
        llr_ptr_stage_rr[ii] <= llr_ptr_stage_r[ii];
    end

    assign path_llr_en[ii]  = inn_llr_ren_rr & (~path_valid[ii*2+1]); //valid and ck path
    assign path_llr_mem[ii] = path_llr_en[ii] ? sram2rdc_llr_rdata[llr_ptr_stage_rr[ii]*WID_INN*8 +: WID_INN*8] : {WID_INN*8{1'b0}};
    always @(*)begin
      if(path_llr_en[ii] && cur_stage == 4'd0)
        path_llr_data[ii*WID_INN*8 +: WID_INN*8] =  {{WID_INN*3{1'b0}},
                                                     {path_llr_mem[ii][WID_INN*4-1:WID_INN*3]},
                                                     {WID_INN*3{1'b0}},
                                                     {path_llr_mem[ii][WID_INN*3-1:WID_INN*2]}};
      else if(path_llr_en[ii] && cur_stage == 4'd1)
        path_llr_data[ii*WID_INN*8 +: WID_INN*8] =  {{WID_INN*2{1'b0}},
                                                     {path_llr_mem[ii][WID_INN*8-1:WID_INN*6]},
                                                     {WID_INN*2{1'b0}},
                                                     {path_llr_mem[ii][WID_INN*6-1:WID_INN*4]}};
      else if(path_llr_en[ii])
        path_llr_data[ii*WID_INN*8 +: WID_INN*8] =  path_llr_mem[ii];
      else 
        path_llr_data[ii*WID_INN*8 +: WID_INN*8] =  {WID_INN*8{1'b0}};
    end
  end
endgenerate
//---inner llr read signals
assign rdc2sram_llr_ren   =  path_llr_ren[0] | 
                             path_llr_ren[1] | 
                             path_llr_ren[2] | 
                             path_llr_ren[3] | 
                             path_llr_ren[4] | 
                             path_llr_ren[5] | 
                             path_llr_ren[6] | 
                             path_llr_ren[7] ;

assign rdc2sram_llr_raddr = {{WID_LLR_ADDR{rdc2sram_llr_ren[7]}} & inn_llr_raddr,
                             {WID_LLR_ADDR{rdc2sram_llr_ren[6]}} & inn_llr_raddr,
                             {WID_LLR_ADDR{rdc2sram_llr_ren[5]}} & inn_llr_raddr,
                             {WID_LLR_ADDR{rdc2sram_llr_ren[4]}} & inn_llr_raddr,
                             {WID_LLR_ADDR{rdc2sram_llr_ren[3]}} & inn_llr_raddr,
                             {WID_LLR_ADDR{rdc2sram_llr_ren[2]}} & inn_llr_raddr,
                             {WID_LLR_ADDR{rdc2sram_llr_ren[1]}} & inn_llr_raddr,
                             {WID_LLR_ADDR{rdc2sram_llr_ren[0]}} & inn_llr_raddr};
//----output to update llr
assign path_valid_r = {(~path_valid[15]),(~path_valid[13]),(~path_valid[11]),(~path_valid[9]),
                       (~path_valid[7 ]),(~path_valid[5 ]),(~path_valid[3 ]),(~path_valid[1])}; //valid or ck path

assign drm_llr_en = {8{drm_llr_ren_rr}} & path_valid_r;


assign drm_llr    = {{{WID_INN-WID_LLR{drm2pdec_llr_rdata[WID_LLR*8-1]}},drm2pdec_llr_rdata[WID_LLR*8-1:WID_LLR*7]},
                     {{WID_INN-WID_LLR{drm2pdec_llr_rdata[WID_LLR*7-1]}},drm2pdec_llr_rdata[WID_LLR*7-1:WID_LLR*6]},
                     {{WID_INN-WID_LLR{drm2pdec_llr_rdata[WID_LLR*6-1]}},drm2pdec_llr_rdata[WID_LLR*6-1:WID_LLR*5]},
                     {{WID_INN-WID_LLR{drm2pdec_llr_rdata[WID_LLR*5-1]}},drm2pdec_llr_rdata[WID_LLR*5-1:WID_LLR*4]},
                     {{WID_INN-WID_LLR{drm2pdec_llr_rdata[WID_LLR*4-1]}},drm2pdec_llr_rdata[WID_LLR*4-1:WID_LLR*3]},
                     {{WID_INN-WID_LLR{drm2pdec_llr_rdata[WID_LLR*3-1]}},drm2pdec_llr_rdata[WID_LLR*3-1:WID_LLR*2]},
                     {{WID_INN-WID_LLR{drm2pdec_llr_rdata[WID_LLR*2-1]}},drm2pdec_llr_rdata[WID_LLR*2-1:WID_LLR*1]},
                     {{WID_INN-WID_LLR{drm2pdec_llr_rdata[WID_LLR*1-1]}},drm2pdec_llr_rdata[WID_LLR*1-1:WID_LLR*0]}};

assign llr_st     = {8{((drm_llr_ren_r & (~drm_llr_ren_rr)) | (inn_llr_ren_r & (~inn_llr_ren_rr)))}} & path_valid_r;

assign rdc2ulr_llr_st     = llr_st;
assign rdc2ulr_llr_en     = drm_llr_en | path_llr_en;
assign rdc2ulr_llr_data   = {{WID_INN*8{drm_llr_en[7]}} & drm_llr,
                             {WID_INN*8{drm_llr_en[6]}} & drm_llr,
                             {WID_INN*8{drm_llr_en[5]}} & drm_llr,
                             {WID_INN*8{drm_llr_en[4]}} & drm_llr,
                             {WID_INN*8{drm_llr_en[3]}} & drm_llr,
                             {WID_INN*8{drm_llr_en[2]}} & drm_llr,
                             {WID_INN*8{drm_llr_en[1]}} & drm_llr,
                             {WID_INN*8{drm_llr_en[0]}} & drm_llr} | path_llr_data;

//====================================================
//====     us mux based on us pointer
//====================================================

assign us_ren_r = (drm_llr_ren_r | inn_llr_ren_r) & (cur_fg == 1'b0);

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    us_raddr_r <= {WID_LLR_ADDR{1'b0}};
  else if(drm_llr_ren & (cur_fg == 1'b0) & (top_stage == NUM_PTR - 1)) //cchdec top_stage == 8,bd top_stage == 11
    us_raddr_r <= drm_llr_raddr;
  else if(drm_llr_ren & (cur_fg == 1'b0)) 
    us_raddr_r <= drm_llr_raddr + llr_addr_base;
  else if(inn_llr_ren & (cur_fg == 1'b0)) 
    us_raddr_r <= inn_llr_raddr;  
end

generate
  for(jj=0 ; jj<8 ; jj=jj+1)begin  : us_mux
    assign us_ptr_mem[jj]   = uph2rdc_us_ptr[(jj+1)*NUM_PTR*3-1:jj*NUM_PTR*3];
    assign us_ptr_stage[jj] = us_ptr_mem[jj][cur_stage*3 +: 3];
    assign us_data_mem[jj]  = uus2rdc_us_data[(jj+1)*NUM_US-1:jj*NUM_US];
  
    always @(posedge clk or negedge rst_n)begin
      if(!rst_n)
        path_us_data[jj*4 +: 4] <= 4'd0;
      else if((us_ren_r && (!path_valid[jj*2+1])) && (cur_stage == 4'd0))
        path_us_data[jj*4 +: 4] <= {3'd0,us_data_mem[us_ptr_stage[jj]][1]};
      else if((us_ren_r && (!path_valid[jj*2+1])) && (cur_stage == 4'd1))
        path_us_data[jj*4 +: 4] <= {2'd0,us_data_mem[us_ptr_stage[jj]][3:2]};
      else if(us_ren_r && (!path_valid[jj*2+1]))
        path_us_data[jj*4 +: 4] <= us_data_mem[us_ptr_stage[jj]][us_raddr_r*4 +: 4];
    end
  end
endgenerate

assign rdc2ulr_us_data = path_us_data; //align with drm_llr_ren_rr | inn_llr_ren_rr


//====================================================
//====     ICG
//====================================================
assign pdec_clk_en1 = ctrl2rdc_drm_st | 
                      drm_llr_ren     | 
                      drm_llr_ren_r   | 
                      drm_llr_ren_rr  |
                      ctrl2rdc_inn_st |
                      inn_llr_ren     | 
                      inn_llr_ren_r   | 
                      inn_llr_ren_rr  ;

endmodule
//Local Variables:
//verilog-library-flags:("-y ./ -y dir -y otherdir -y ./inc_dir/")
//verilog-auto-inst-param-value:t
//End:

