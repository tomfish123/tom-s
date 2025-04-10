//////////////////////////////////////////////////////////////////////////////////
// Description: sort_num is calculated by top ctrl
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps

module pdec_pm_sort #(
  parameter                          WID_PM  = 10      ,
  parameter                          WID_N   = 9         //512->9,4096->12
)(
  input   wire                       clk               , 
  input   wire                       rst_n             , 
  
  //----ICG
  output  wire                       pdec_clk_en4      ,
  
  //----broadcast control signals
  input   wire[3-1:0]                cur_jump_type     ,
  input   wire[2:0]                  sort_num          , //0:sort2 , 1:sort4 , 2:sort8 , 3:sort16 , 4:sort32
  input   wire[2*8-1:0]              path_valid        , //0:CK path, 1:valid path,3:invalid_path

  //----pdec_top_ctrl interface
  input   wire                       ctrl2srt_srt_st   , //align with upm2srt_pm_val
  output  wire                       srt2ctrl_srt_done , //align with srt2uph_pm_idx

  //----pdec_updt_pm interface
  input   wire[WID_PM*4*8-1:0]       upm2srt_pm_val    , //{pm_pair7,pm_pair6,pm_pair5,pm_pair4,pm_pair3,pm_pair2,pm_pair1,pm_pair0},every pair have 4 pm,{pm3,pm2,pm1,pm0}
  output  wire[WID_PM  *8-1:0]       srt2upm_pm_val    , //{pm7,pm6,pm5,pm4,pm3,pm2,pm1,pm0},pm0 is min value and pm7 is max value

  //----pdec_updt_path interface
  output  wire[5*8-1:0]              srt2uph_pm_idx     //{idx7,idx6,idx5,idx4,idx3,idx2,idx1,idx0}
);
//====================================================
//====             parameters
//====================================================
localparam    WID_IDX = 5;

//====================================================
//====             inner signal
//====================================================
genvar                      ii                 ;
genvar                      jj                 ;
genvar                      kk                 ;
genvar                      pp                 ;
reg [1:0]                   sort_done_cnt      ;
wire[WID_PM*4*8-1:0]        pm_val             ; 

wire[WID_IDX*8-1:0]         sort_out_idx_hg_nc ; 
wire[WID_IDX*8-1:0]         sort_out_idx       ; 
wire[(WID_PM+1)*8-1:0]      sort_out_hg_nc ; 
wire[(WID_PM+1)*8-1:0]      sort_out           ; 
wire                        sort_done          ; 

wire[WID_IDX*16-1:0]        sort0_in_idx       ; 
reg [(WID_PM+1)*16-1:0]     sort0_in           ; 
wire                        sort0_in_en        ; 
wire                        sort0_out_en        ; 
reg [WID_IDX*8-1:0]         sort_out_idx_r     ; 
reg [(WID_PM+1)*8-1:0]      sort_out_r         ; 

wire[WID_IDX*16-1:0]        sort1_in_idx       ; 
reg [(WID_PM+1)*16-1:0]     sort1_in           ; 
wire                        sort1_in_en        ; 
wire                        sort1_out_en        ; 

reg [(WID_PM+1)*16-1:0]     sort2_in0_rep      ;
reg [(WID_PM+1)*16-1:0]     sort2_in0_info     ;
wire[WID_IDX*16-1:0]        sort2_in_idx0      ; 
wire[WID_IDX*16-1:0]        sort2_in_idx1      ; 
wire[(WID_PM+1)*16-1:0]     sort2_in0          ; 
wire[(WID_PM+1)*16-1:0]     sort2_in1          ; 
wire                        sort2_in_en0       ; 
wire                        sort2_in_en1       ; 

reg [WID_IDX*16-1:0]        sort_in_idx        ; 
reg [(WID_PM+1)*16-1:0]     sort_in            ; 
wire                        sort_in_en         ; 
wire[1:0]                   sort_in_num        ; 

wire[WID_PM-1:0]            pm_out0_pre        ;
wire[WID_PM-1:0]            pm_out1_pre        ;
wire[WID_PM-1:0]            pm_out2_pre        ;
wire[WID_PM-1:0]            pm_out3_pre        ;
wire[WID_PM-1:0]            pm_out4_pre        ;
wire[WID_PM-1:0]            pm_out5_pre        ;
wire[WID_PM-1:0]            pm_out6_pre        ;
wire[WID_PM-1:0]            pm_out7_pre        ;

wire[WID_PM-1:0]            pm_out1            ;
wire[WID_PM-1:0]            pm_out2            ;
wire[WID_PM-1:0]            pm_out3            ;
wire[WID_PM-1:0]            pm_out4            ;
wire[WID_PM-1:0]            pm_out5            ;
wire[WID_PM-1:0]            pm_out6            ;
wire[WID_PM-1:0]            pm_out7            ;

reg                         sort_proc          ;
//====================================================
//====             control signal
//====================================================
//----sort_done counter
always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    sort_done_cnt <= 2'd0;
  else if(ctrl2srt_srt_st)
    sort_done_cnt <= 2'd0;
  else if(sort_done)  
    sort_done_cnt <= sort_done_cnt + 1'b1;
end

assign pm_val = upm2srt_pm_val;
//====================================================
//====             sort_stage0
//====================================================
assign sort0_in_idx = {5'd15,5'd14,5'd13,5'd12,5'd11,5'd10,5'd9,5'd8,5'd7,5'd6,5'd5,5'd4,5'd3,5'd2,5'd1,5'd0};
generate
  for(ii=0 ; ii<4 ; ii=ii+1)begin  : sort_stage0
    always @(*)begin
      if(ctrl2srt_srt_st && sort_num[2] && (path_valid[ii*2 +: 2] == 2'd1)) //valid_path
        sort0_in[(WID_PM+1)*4*ii +: (WID_PM+1)*4] = {{1'b0,pm_val[(WID_PM*4*ii)+WID_PM*3 +: WID_PM]},//spread 1bit with 0
                                                     {1'b0,pm_val[(WID_PM*4*ii)+WID_PM*2 +: WID_PM]},
                                                     {1'b0,pm_val[(WID_PM*4*ii)+WID_PM*1 +: WID_PM]},
                                                     {1'b0,pm_val[(WID_PM*4*ii)+WID_PM*0 +: WID_PM]}};
      else if(ctrl2srt_srt_st && sort_num[2] && (path_valid[ii*2 +: 2] == 2'd0)) //CK path
        sort0_in[(WID_PM+1)*4*ii +: (WID_PM+1)*4] = {{(WID_PM+1)*3{1'b1}},
                                                     {1'b0,pm_val[(WID_PM*4*ii)+WID_PM*0 +: WID_PM]}};
      else //invalid_path
        sort0_in[(WID_PM+1)*4*ii +: (WID_PM+1)*4] = {{(WID_PM+1)*4{1'b1}}};
    end
  end
endgenerate
    
assign sort0_in_en  = ctrl2srt_srt_st & sort_num[2]; //sort32

assign sort0_out_en = sort_done && (sort_done_cnt == 2'd0) && sort_num[2];

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin
    sort_out_r     <= {(WID_PM+1)*8{1'b1}};
    sort_out_idx_r <= {WID_IDX*8{1'b0}}   ;
  end  
  else if(sort0_out_en)begin
    sort_out_r     <= sort_out    ;
    sort_out_idx_r <= sort_out_idx;
  end  
end

//====================================================
//====             sort_stage1
//====================================================
assign sort1_in_idx = {5'd31,5'd30,5'd29,5'd28,5'd27,5'd26,5'd25,5'd24,5'd23,5'd22,5'd21,5'd20,5'd19,5'd18,5'd17,5'd16};

generate
  for(jj=0 ; jj<4 ; jj=jj+1)begin  : sort_stage1
    always @(*)begin
      if(sort0_out_en && (path_valid[8+jj*2 +: 2] == 2'd1)) //valid_path
        sort1_in[(WID_PM+1)*4*jj +: (WID_PM+1)*4] = {{1'b0,pm_val[WID_PM*16+(WID_PM*4*jj)+WID_PM*3 +: WID_PM]},
                                                     {1'b0,pm_val[WID_PM*16+(WID_PM*4*jj)+WID_PM*2 +: WID_PM]},
                                                     {1'b0,pm_val[WID_PM*16+(WID_PM*4*jj)+WID_PM*1 +: WID_PM]},
                                                     {1'b0,pm_val[WID_PM*16+(WID_PM*4*jj)+WID_PM*0 +: WID_PM]}};
      else if(sort0_out_en && (path_valid[8+jj*2 +: 2] == 2'd0)) //CK path
        sort1_in[(WID_PM+1)*4*jj +: (WID_PM+1)*4] = {{(WID_PM+1)*3{1'b1}},
                                                     {1'b0,pm_val[WID_PM*16+(WID_PM*4*jj)+WID_PM*0 +: WID_PM]}};
      else //invalid_path
        sort1_in[(WID_PM+1)*4*jj +: (WID_PM+1)*4] = {{(WID_PM+1)*4{1'b1}}};
    end
  end
endgenerate

assign sort1_in_en = sort0_out_en;

assign sort1_out_en = sort_done && (sort_done_cnt == 2'd1) && sort_num[2];
//====================================================
//====             sort_stage2
//====================================================
assign sort2_in_idx0 = {5'd15,5'd14,5'd13,5'd12,5'd11,5'd10,5'd9,5'd8,5'd7,5'd6,5'd5,5'd4,5'd3,5'd2,5'd1,5'd0};
assign sort2_in_idx1 = {sort_out_idx,sort_out_idx_r};

generate
  for(kk=0 ; kk<8 ; kk=kk+1)begin  : sort_stage2_rep
    always @(*)begin
      if(ctrl2srt_srt_st && (path_valid[kk*2 +: 2] == 2'd1)) //valid_path
        sort2_in0_rep[(WID_PM+1)*2*kk +: (WID_PM+1)*2] = {{1'b0,pm_val[(WID_PM*4*kk)+WID_PM*1 +: WID_PM]},
                                                          {1'b0,pm_val[(WID_PM*4*kk)+WID_PM*0 +: WID_PM]}};
      else if(ctrl2srt_srt_st && (path_valid[kk*2 +: 2] == 2'd0)) //CK path
        sort2_in0_rep[(WID_PM+1)*2*kk +: (WID_PM+1)*2] = {{WID_PM+1{1'b1}},
                                                          {1'b0,pm_val[(WID_PM*4*kk)+WID_PM*0 +: WID_PM]}};
      else //invalid_path
        sort2_in0_rep[(WID_PM+1)*2*kk +: (WID_PM+1)*2] = {{(WID_PM+1)*2{1'b1}}};
    end
  end
endgenerate

generate
  for(pp=0 ; pp<4 ; pp=pp+1)begin  : sort_stage2_info
    always @(*)begin
      if(ctrl2srt_srt_st && (path_valid[pp*2 +: 2] == 2'd1)) //valid_path
        sort2_in0_info[(WID_PM+1)*4*pp +: (WID_PM+1)*4] = {{1'b0,pm_val[(WID_PM*4*pp)+WID_PM*3 +: WID_PM]},
                                                           {1'b0,pm_val[(WID_PM*4*pp)+WID_PM*2 +: WID_PM]},
                                                           {1'b0,pm_val[(WID_PM*4*pp)+WID_PM*1 +: WID_PM]},
                                                           {1'b0,pm_val[(WID_PM*4*pp)+WID_PM*0 +: WID_PM]}};
      else if(ctrl2srt_srt_st && (path_valid[pp*2 +: 2] == 2'd0)) //CK path
        sort2_in0_info[(WID_PM+1)*4*pp +: (WID_PM+1)*4] = {{(WID_PM+1)*3{1'b1}},
                                                           {1'b0,pm_val[(WID_PM*4*pp)+WID_PM*0 +: WID_PM]}};
      else //invalid_path
        sort2_in0_info[(WID_PM+1)*4*pp +: (WID_PM+1)*4] = {{(WID_PM+1)*4{1'b1}}};
    end
  end
endgenerate

assign sort2_in0 = (cur_jump_type == 3'd1) ? sort2_in0_rep : sort2_in0_info;
assign sort2_in1 = {sort_out,sort_out_r};

assign sort2_in_en0  = ctrl2srt_srt_st && (~sort_num[2]);
assign sort2_in_en1  = sort1_out_en;

//====================================================
//====             input mux
//====================================================
always @(*)begin
  if(sort0_in_en)
    sort_in_idx = sort0_in_idx;
  else if(sort1_in_en)
    sort_in_idx = sort1_in_idx;
  else if(sort2_in_en0)
    sort_in_idx = sort2_in_idx0;
  else if(sort2_in_en1)
    sort_in_idx = sort2_in_idx1;
  else
    sort_in_idx = {WID_IDX*16{1'b0}};
end

always @(*)begin
  if(sort0_in_en)
    sort_in = sort0_in;
  else if(sort1_in_en)
    sort_in = sort1_in;
  else if(sort2_in_en0)
    sort_in = sort2_in0;
  else if(sort2_in_en1)
    sort_in = sort2_in1;
  else
    sort_in = {(WID_PM+1)*16{1'b1}};
end

assign sort_in_en  = sort0_in_en | sort1_in_en | sort2_in_en0 | sort2_in_en1;
assign sort_in_num = sort_num[2] ? 2'd3 : sort_num[1:0] ;

//====================================================
//====             sort
//====================================================
pdec_botnic_sort #(
  .WID_D               (WID_PM+1                        ),
  .WID_I               (WID_IDX                         ))
U_pm_sort
(
 // Outputs           
 .sort_out_idx         ({sort_out_idx_hg_nc,sort_out_idx}),
 .sort_out             ({sort_out_hg_nc    ,sort_out    }),
 .sort_done            (sort_done                        ),
 // Inputs
 .clk                  (clk                             ),
 .rst_n                (rst_n                           ),
 .sort_num             (sort_in_num                     ),
 .sort_in_en           (sort_in_en                      ),
 .sort_in              (sort_in                         ),
 .sort_in_idx          (sort_in_idx                     ));




assign pm_out0_pre = sort_out[(WID_PM+1)*1-2:(WID_PM+1)*0];
assign pm_out1_pre = sort_out[(WID_PM+1)*2-2:(WID_PM+1)*1];
assign pm_out2_pre = sort_out[(WID_PM+1)*3-2:(WID_PM+1)*2];
assign pm_out3_pre = sort_out[(WID_PM+1)*4-2:(WID_PM+1)*3];
assign pm_out4_pre = sort_out[(WID_PM+1)*5-2:(WID_PM+1)*4];
assign pm_out5_pre = sort_out[(WID_PM+1)*6-2:(WID_PM+1)*5];
assign pm_out6_pre = sort_out[(WID_PM+1)*7-2:(WID_PM+1)*6];
assign pm_out7_pre = sort_out[(WID_PM+1)*8-2:(WID_PM+1)*7];

assign pm_out1 = pm_out1_pre - pm_out0_pre; //normalize
assign pm_out2 = pm_out2_pre - pm_out0_pre;
assign pm_out3 = pm_out3_pre - pm_out0_pre;
assign pm_out4 = pm_out4_pre - pm_out0_pre;
assign pm_out5 = pm_out5_pre - pm_out0_pre;
assign pm_out6 = pm_out6_pre - pm_out0_pre;
assign pm_out7 = pm_out7_pre - pm_out0_pre;

assign srt2upm_pm_val     = {pm_out7,pm_out6,pm_out5,pm_out4,pm_out3,pm_out2,pm_out1,{WID_PM{1'b0}}};

assign srt2uph_pm_idx     = sort_out_idx[WID_IDX*8-1:0];
assign srt2ctrl_srt_done  = sort_done && (((sort_done_cnt == 2'd0) && (~sort_num[2])) || ((sort_done_cnt == 2'd2) && sort_num[2]));

//====================================================
//====             ICG
//====================================================
always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    sort_proc <= 1'b0;
  else if(ctrl2srt_srt_st)  
    sort_proc <= 1'b1;
  else if(srt2ctrl_srt_done)  
    sort_proc <= 1'b0;
end    

assign pdec_clk_en4 = ctrl2srt_srt_st |
                      sort_proc       ;


endmodule
//Local Variables:
//verilog-library-flags:("-y ./ -y dir -y otherdir -y ./inc_dir/")
//verilog-auto-inst-param-value:t
//End:

