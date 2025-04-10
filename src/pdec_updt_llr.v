//////////////////////////////////////////////////////////////////////////////////
// Description:  :
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps

module pdec_updt_llr #(
  parameter                         WID_LLR_ADDR = 6   ,//512->6,1024->7,2048->8,4096->9       
  parameter                         WID_INN      = 10          
)(
  input  wire                       clk                , 
  input  wire                       rst_n              , 
  
  //----ICG
  output wire                       pdec_clk_en2       ,
  
  //----pdec_para_cfg
  input  wire                       leaf_mode          , //0:stage0 is leaf node, 1:stage2 is leaf node

  //----broadcast control signals
  input  wire                       cur_fg             , //0:G function, 1:F function
  input  wire[3:0]                  cur_stage          , //
  input  wire[2:0]                  cur_jump_type      , //0:frozen,1:repetion,2:info_20,3:info_21,4:info_3,5:info_4,7:normal

  //----pdec_rd_ctrl interface
  input  wire[8-1:0]                rdc2ulr_llr_st     , //1clk befor llr_en 
  input  wire[8-1:0]                rdc2ulr_llr_en     , //include path_valid info, if path is invalid ,llr_en is 0
  input  wire[WID_INN*8*8-1:0]      rdc2ulr_llr_data   , //llr of stage+1 ;format is : {llr_N/2+3,llr_N/2+2,llr_N/2+1,llr_N/2,llr3,llr2,llr1,llr0},N is LLR number of current stage
  input  wire[4*8-1:0]              rdc2ulr_us_data    , //us of stag     ;format is : {us3,us2,us1,us0}

  //----pdec_updt_pm interface
  output reg [8-1:0]                ulr2upm_llr_st     , 
  output reg [8-1:0]                ulr2upm_llr_en     , 
  output reg [WID_INN*4*8-1:0]      ulr2upm_llr_data   , //>=stage2:{llr3,llr2,llr1,llr0},stage1:{0,0,llr1,llr0},stage0:{0,0,0,llr0} 

  //----pdec_sram_top interface
  output reg [8-1:0]                ulr2sram_llr_wen   , 
  output wire[WID_LLR_ADDR*8-1:0]   ulr2sram_llr_waddr , 
  output wire[10*8-1:0]             ulr2sram_llr_wbyte , 
  output reg [WID_INN*8*8-1:0]      ulr2sram_llr_wdata

);
//====================================================
//====         inner signals
//====================================================
genvar                  ii             ; 
wire[WID_INN*4*8-1:0]   llr_out_data   ; 
wire                    cal_pm_node    ; 
wire[3:0]               cur_stage_sub3 ; 
wire[WID_LLR_ADDR-1:0]  llr_base_addr  ; 
reg [WID_LLR_ADDR-1:0]  llr_cnt        ; 
reg [10-1:0]            llr_wbyte      ; 
reg [WID_LLR_ADDR-1:0]  llr_waddr      ; 

//====================================================
//====         F/G function
//====================================================
assign cal_pm_node = (cur_jump_type == 2'd0) || (cur_jump_type == 2'd1) || ((cur_stage == 4'd2) && (leaf_mode == 1'b1));

generate
  for(ii=0 ; ii<8 ; ii=ii+1)begin  : llr_unit
    //----calculate f/g function
    pdec_llr_unit #(
      .WID_INN              (WID_INN                                    ))
    U_pdec_llr_unit(
      /*AUTOINST*/
      // Outputs
      .llr_out_data         (llr_out_data[ii*WID_INN*4 +: WID_INN*4]    ) ,
      // Inputs
      .cur_fg               (cur_fg                                     ) ,
      .llr_in_en            (rdc2ulr_llr_en[ii]                         ) ,
      .llr_in_data          (rdc2ulr_llr_data[ii*WID_INN*8 +: WID_INN*8]) ,
      .us_in_data           (rdc2ulr_us_data[ii*4 +:4]                  )); 
    
    //----output llr to calculate pm
    //start
    always @(posedge clk or negedge rst_n)begin
      if(!rst_n)
        ulr2upm_llr_st[ii] <=  1'b0;
      else if(rdc2ulr_llr_st[ii] && cal_pm_node)
        ulr2upm_llr_st[ii] <=  1'b1;
      else 
        ulr2upm_llr_st[ii] <=  1'b0;
    end
    //enable
    always @(posedge clk or negedge rst_n)begin
      if(!rst_n)
        ulr2upm_llr_en[ii] <=  1'b0;
      else if(rdc2ulr_llr_en[ii] && cal_pm_node)
        ulr2upm_llr_en[ii] <=  1'b1;
      else 
        ulr2upm_llr_en[ii] <=  1'b0;
    end
    //data
    always @(posedge clk or negedge rst_n)begin
      if(!rst_n)
        ulr2upm_llr_data[ii*WID_INN*4 +: WID_INN*4] <=  {WID_INN*4{1'b0}};
      else if(rdc2ulr_llr_en[ii] && cal_pm_node)
        ulr2upm_llr_data[ii*WID_INN*4 +: WID_INN*4] <=  llr_out_data[ii*WID_INN*4 +: WID_INN*4];
    end
  end
endgenerate
//====================================================
//====            write llr sram   
//====================================================
assign cur_stage_sub3 = cur_stage < 4'd3 ? 4'd0 : cur_stage - 2'd3; //unsigned - unsigned 
assign llr_base_addr  = cur_stage < 4'd3 ? {WID_LLR_ADDR{1'b0}} : (1 << cur_stage_sub3);  

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    llr_cnt <= {WID_LLR_ADDR{1'b0}};
  else if(|rdc2ulr_llr_st)
    llr_cnt <= {WID_LLR_ADDR{1'b0}};
  else if(|rdc2ulr_llr_en)
    llr_cnt <= llr_cnt + 1'b1;
end

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    llr_wbyte <= 10'd0;
  else if(|rdc2ulr_llr_en)begin
    if(cur_stage == 4'd0)
      llr_wbyte <= 10'h000;
    else if(cur_stage == 4'd1)  
      llr_wbyte <= 10'h01F; 
    else if(cur_stage == 4'd2)  
      llr_wbyte <= 10'h3E0;
    else if(llr_cnt[cur_stage_sub3] == 1'b0)
      llr_wbyte <= 10'h01F;
    else if(llr_cnt[cur_stage_sub3] == 1'b1)
      llr_wbyte <= 10'h3E0;
  end
end

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    llr_waddr <= {WID_LLR_ADDR{1'b0}};
  else if(|rdc2ulr_llr_en)begin
    if(cur_stage <= 4'd2)
      llr_waddr <= {WID_LLR_ADDR{1'b0}};
    else begin
      case(cur_stage_sub3)
        4'd0    : llr_waddr <= llr_base_addr;
        4'd1    : llr_waddr <= llr_base_addr + llr_cnt[0];
        4'd2    : llr_waddr <= llr_base_addr + llr_cnt[1:0];
        4'd3    : llr_waddr <= llr_base_addr + llr_cnt[2:0];
        4'd4    : llr_waddr <= llr_base_addr + llr_cnt[3:0];
        4'd5    : llr_waddr <= llr_base_addr + llr_cnt[4:0];
        4'd6    : llr_waddr <= llr_base_addr + llr_cnt[5:0];
        `ifdef PDEC_BD
        4'd7    : llr_waddr <= llr_base_addr + llr_cnt[6:0];
        4'd8    : llr_waddr <= llr_base_addr + llr_cnt[7:0];
        4'd9    : llr_waddr <= llr_base_addr + llr_cnt[8:0];
        `endif
        default : llr_waddr <= llr_base_addr; 
      endcase
    end
  end
end

//----mux

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    ulr2sram_llr_wen <= 8'd0;
  else
    ulr2sram_llr_wen <= rdc2ulr_llr_en ;
end

assign ulr2sram_llr_waddr = {{WID_LLR_ADDR{ulr2sram_llr_wen[7]}} & llr_waddr,
                             {WID_LLR_ADDR{ulr2sram_llr_wen[6]}} & llr_waddr,
                             {WID_LLR_ADDR{ulr2sram_llr_wen[5]}} & llr_waddr,
                             {WID_LLR_ADDR{ulr2sram_llr_wen[4]}} & llr_waddr,
                             {WID_LLR_ADDR{ulr2sram_llr_wen[3]}} & llr_waddr,
                             {WID_LLR_ADDR{ulr2sram_llr_wen[2]}} & llr_waddr,
                             {WID_LLR_ADDR{ulr2sram_llr_wen[1]}} & llr_waddr,
                             {WID_LLR_ADDR{ulr2sram_llr_wen[0]}} & llr_waddr};


assign ulr2sram_llr_wbyte = {{10{ulr2sram_llr_wen[7]}} & llr_wbyte,
                             {10{ulr2sram_llr_wen[6]}} & llr_wbyte,
                             {10{ulr2sram_llr_wen[5]}} & llr_wbyte,
                             {10{ulr2sram_llr_wen[4]}} & llr_wbyte,
                             {10{ulr2sram_llr_wen[3]}} & llr_wbyte,
                             {10{ulr2sram_llr_wen[2]}} & llr_wbyte,
                             {10{ulr2sram_llr_wen[1]}} & llr_wbyte,
                             {10{ulr2sram_llr_wen[0]}} & llr_wbyte};


always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    ulr2sram_llr_wdata <= {WID_INN*8*8{1'b0}};
  else if(|rdc2ulr_llr_en)begin
    if(cur_stage == 4'd0)
      ulr2sram_llr_wdata <= {WID_INN*8*8{1'b0}};
    else if(cur_stage == 4'd1)  
      ulr2sram_llr_wdata <= {{WID_INN*4{1'b0}},llr_out_data[7*(WID_INN*4) +: WID_INN*2],{WID_INN*2{1'b0}},
                             {WID_INN*4{1'b0}},llr_out_data[6*(WID_INN*4) +: WID_INN*2],{WID_INN*2{1'b0}},
                             {WID_INN*4{1'b0}},llr_out_data[5*(WID_INN*4) +: WID_INN*2],{WID_INN*2{1'b0}},
                             {WID_INN*4{1'b0}},llr_out_data[4*(WID_INN*4) +: WID_INN*2],{WID_INN*2{1'b0}},
                             {WID_INN*4{1'b0}},llr_out_data[3*(WID_INN*4) +: WID_INN*2],{WID_INN*2{1'b0}},
                             {WID_INN*4{1'b0}},llr_out_data[2*(WID_INN*4) +: WID_INN*2],{WID_INN*2{1'b0}},
                             {WID_INN*4{1'b0}},llr_out_data[1*(WID_INN*4) +: WID_INN*2],{WID_INN*2{1'b0}},
                             {WID_INN*4{1'b0}},llr_out_data[0*(WID_INN*4) +: WID_INN*2],{WID_INN*2{1'b0}}};
    else if(cur_stage == 4'd2) 
      ulr2sram_llr_wdata <= {llr_out_data[7*(WID_INN*4) +: WID_INN*4],{WID_INN*4{1'b0}},
                             llr_out_data[6*(WID_INN*4) +: WID_INN*4],{WID_INN*4{1'b0}},
                             llr_out_data[5*(WID_INN*4) +: WID_INN*4],{WID_INN*4{1'b0}},
                             llr_out_data[4*(WID_INN*4) +: WID_INN*4],{WID_INN*4{1'b0}},
                             llr_out_data[3*(WID_INN*4) +: WID_INN*4],{WID_INN*4{1'b0}},
                             llr_out_data[2*(WID_INN*4) +: WID_INN*4],{WID_INN*4{1'b0}},
                             llr_out_data[1*(WID_INN*4) +: WID_INN*4],{WID_INN*4{1'b0}},
                             llr_out_data[0*(WID_INN*4) +: WID_INN*4],{WID_INN*4{1'b0}}};
    else if(llr_cnt[cur_stage_sub3] == 1'b0)
      ulr2sram_llr_wdata <= {{WID_INN*4{1'b0}},llr_out_data[7*(WID_INN*4) +: WID_INN*4],
                             {WID_INN*4{1'b0}},llr_out_data[6*(WID_INN*4) +: WID_INN*4],
                             {WID_INN*4{1'b0}},llr_out_data[5*(WID_INN*4) +: WID_INN*4],
                             {WID_INN*4{1'b0}},llr_out_data[4*(WID_INN*4) +: WID_INN*4],
                             {WID_INN*4{1'b0}},llr_out_data[3*(WID_INN*4) +: WID_INN*4],
                             {WID_INN*4{1'b0}},llr_out_data[2*(WID_INN*4) +: WID_INN*4],
                             {WID_INN*4{1'b0}},llr_out_data[1*(WID_INN*4) +: WID_INN*4],
                             {WID_INN*4{1'b0}},llr_out_data[0*(WID_INN*4) +: WID_INN*4]};
    else if(llr_cnt[cur_stage_sub3] == 1'b1)
      ulr2sram_llr_wdata <= {llr_out_data[7*(WID_INN*4) +: WID_INN*4],{WID_INN*4{1'b0}},
                             llr_out_data[6*(WID_INN*4) +: WID_INN*4],{WID_INN*4{1'b0}},
                             llr_out_data[5*(WID_INN*4) +: WID_INN*4],{WID_INN*4{1'b0}},
                             llr_out_data[4*(WID_INN*4) +: WID_INN*4],{WID_INN*4{1'b0}},
                             llr_out_data[3*(WID_INN*4) +: WID_INN*4],{WID_INN*4{1'b0}},
                             llr_out_data[2*(WID_INN*4) +: WID_INN*4],{WID_INN*4{1'b0}},
                             llr_out_data[1*(WID_INN*4) +: WID_INN*4],{WID_INN*4{1'b0}},
                             llr_out_data[0*(WID_INN*4) +: WID_INN*4],{WID_INN*4{1'b0}}};
  end
end

//====================================================
//====            ICG   
//====================================================
assign pdec_clk_en2 = (|rdc2ulr_llr_st)   |
                      (|rdc2ulr_llr_en)   |
                      (|ulr2sram_llr_wen) ;

endmodule
//Local Variables:
//verilog-library-flags:("-y ./ -y dir -y otherdir -y ./inc_dir/")
//verilog-auto-inst-param-value:t
//End:

