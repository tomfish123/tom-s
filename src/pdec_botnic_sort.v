//////////////////////////////////////////////////////////////////////////////////
// Description: support 2/4/8/16 sort
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps

module pdec_botnic_sort #(
  parameter                          WID_D   = 10,
  parameter                          WID_I   = 5

)(
  input   wire                       clk         ,
  input   wire                       rst_n       ,
  //----control signals
  input   wire[1:0]                  sort_num    , //0:sort2 1:sort4,2:sort8,3:sort16
  input   wire                       sort_in_en  ,
  input   wire[WID_D*16-1:0]         sort_in     ,
  input   wire[WID_I*16-1:0]         sort_in_idx ,

  output  reg [WID_I*16-1:0]         sort_out_idx,
  output  reg [WID_D*16-1:0]         sort_out    , 

  output  reg                        sort_done     //align with sort_out
);
//====================================================
//==== inner signals
//====================================================
genvar                  kk               ; 
reg                     sort_in_en_r     ; 
reg                     sort_in_en_rr    ; 

wire                    change_ind       ; 
wire [WID_D-1:0]        data0            ; 
wire [WID_D-1:0]        data1            ; 
wire [WID_I-1:0]        idx0             ; 
wire [WID_I-1:0]        idx1             ; 

wire                    sort_stage0_en   ; 

wire [WID_D*16-1:0]     data_in_s0_0     ; 
wire [WID_I*16-1:0]     idx_in_s0_0      ; 
wire [8-1:0]            sort_ind_s0_0    ; 

wire [WID_D*16-1:0]     data_in_s0_1     ; 
wire [WID_I*16-1:0]     idx_in_s0_1      ; 
wire [8-1:0]            sort_ind_s0_1    ; 

wire [WID_D*16-1:0]     data_in_s0_2     ; 
wire [WID_I*16-1:0]     idx_in_s0_2      ; 
wire [8-1:0]            sort_ind_s0_2    ; 

wire [WID_D*16*3-1:0]   data_in_s0       ; 
wire [WID_I*16*3-1:0]   idx_in_s0        ; 
wire [8*3-1:0]          sort_ind_s0      ; 

wire                    sort_stage1_en   ; 
wire [WID_D*16-1:0]     data_in_s1_0     ; 
wire [WID_I*16-1:0]     idx_in_s1_0      ; 
wire [8-1:0]            sort_ind_s1_0    ; 

wire [WID_D*16-1:0]     data_in_s1_1     ; 
wire [WID_I*16-1:0]     idx_in_s1_1      ; 
wire [8-1:0]            sort_ind_s1_1    ; 

wire [WID_D*16-1:0]     data_in_s1_2     ; 
wire [WID_I*16-1:0]     idx_in_s1_2      ; 
wire [8-1:0]            sort_ind_s1_2    ; 

wire [WID_D*16*3-1:0]   data_in_s1       ; 
wire [WID_I*16*3-1:0]   idx_in_s1        ; 
wire [8*3-1:0]          sort_ind_s1      ; 

wire                    sort_stage2_en   ;
wire [WID_D*16-1:0]     data_in_s2_0     ; 
wire [WID_I*16-1:0]     idx_in_s2_0      ; 
wire [8-1:0]            sort_ind_s2_0    ; 

wire [WID_D*16-1:0]     data_in_s2_1     ; 
wire [WID_I*16-1:0]     idx_in_s2_1      ; 
wire [8-1:0]            sort_ind_s2_1    ; 

wire [WID_D*16-1:0]     data_in_s2_2     ; 
wire [WID_I*16-1:0]     idx_in_s2_2      ; 
wire [8-1:0]            sort_ind_s2_2    ; 

wire [WID_D*16-1:0]     data_in_s2_3     ; 
wire [WID_I*16-1:0]     idx_in_s2_3      ; 
wire [8-1:0]            sort_ind_s2_3    ; 

wire [WID_D*16*4-1:0]   data_in_s2       ; 
wire [WID_I*16*4-1:0]   idx_in_s2        ; 
wire [8*4-1:0]          sort_ind_s2      ; 

reg [WID_D*16-1:0]      data_in [3:0]    ; 
reg [WID_I*16-1:0]      idx_in  [3:0]    ; 
reg [8-1:0]             sort_ind[3:0]    ; 

wire[WID_D*16-1:0]      data_out[3:0]    ; 
wire[WID_I*16-1:0]      idx_out [3:0]    ; 

//====================================================
//==== top ctrl
//====================================================
always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    sort_in_en_r <= 1'b0;
  else
    sort_in_en_r <= sort_in_en && (sort_num >=2'd2); // >= sort 8
end

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    sort_in_en_rr <= 1'b0;
  else
    sort_in_en_rr <= sort_in_en_r && (sort_num ==2'd3); //sort 16
end

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    sort_done <= 1'b0;
  else if(sort_in_en && (sort_num <= 2'd1))
    sort_done <= 1'b1;
  else if(sort_in_en_r && (sort_num == 2'd2))
    sort_done <= 1'b1;
  else if(sort_in_en_rr && (sort_num == 2'd3))
    sort_done <= 1'b1;
  else 
    sort_done <= 1'b0;
end

//====================================================
//==== sort_num == 0 : descend sort
//====================================================
assign change_ind   = (sort_in_en && (sort_in[WID_D*2-1:WID_D] < sort_in[WID_D-1:0])) ? 1'b1 : 1'b0;

assign data0        = change_ind ? sort_in[WID_D*2-1:WID_D*1] : sort_in[WID_D*1-1:WID_D*0]; // ? 1 : 0
assign data1        = change_ind ? sort_in[WID_D*1-1:WID_D*0] : sort_in[WID_D*2-1:WID_D*1]; // ? 0 : 1

assign idx0         = change_ind ? {{WID_I-1{1'b0}},1'b1} : {WID_I{1'b0}}         ; 
assign idx1         = change_ind ? {WID_I{1'b0}}          : {{WID_I-1{1'b0}},1'b1};

//====================================================
//==== stage 0
//====================================================
//----step1
assign sort_stage0_en = (sort_in_en && (sort_num != 2'd0));
assign data_in_s0_0  = sort_stage0_en ? sort_in     : {WID_D*16{1'b1}};
assign idx_in_s0_0   = sort_stage0_en ? sort_in_idx : {WID_I*16{1'b0}};
assign sort_ind_s0_0 = 8'b01010101;//1:ascend 0:descend

//----step2 :4*ii+{3,1,2,0},ii=0,1,2,3
assign data_in_s0_1  = {data_out[0][WID_D*15+:WID_D],data_out[0][WID_D*13+:WID_D],data_out[0][WID_D*14+:WID_D],data_out[0][WID_D*12+:WID_D],
                         data_out[0][WID_D*11+:WID_D],data_out[0][WID_D* 9+:WID_D],data_out[0][WID_D*10+:WID_D],data_out[0][WID_D* 8+:WID_D],
                         data_out[0][WID_D* 7+:WID_D],data_out[0][WID_D* 5+:WID_D],data_out[0][WID_D* 6+:WID_D],data_out[0][WID_D* 4+:WID_D],
                         data_out[0][WID_D* 3+:WID_D],data_out[0][WID_D* 1+:WID_D],data_out[0][WID_D* 2+:WID_D],data_out[0][WID_D* 0+:WID_D]};

assign idx_in_s0_1   = { idx_out[0][WID_I*15+:WID_I], idx_out[0][WID_I*13+:WID_I], idx_out[0][WID_I*14+:WID_I], idx_out[0][WID_I*12+:WID_I],
                          idx_out[0][WID_I*11+:WID_I], idx_out[0][WID_I* 9+:WID_I], idx_out[0][WID_I*10+:WID_I], idx_out[0][WID_I* 8+:WID_I],
                          idx_out[0][WID_I* 7+:WID_I], idx_out[0][WID_I* 5+:WID_I], idx_out[0][WID_I* 6+:WID_I], idx_out[0][WID_I* 4+:WID_I],
                          idx_out[0][WID_I* 3+:WID_I], idx_out[0][WID_I* 1+:WID_I], idx_out[0][WID_I* 2+:WID_I], idx_out[0][WID_I* 0+:WID_I]};

assign sort_ind_s0_1 = 8'b00110011;//1:ascend 0:descend

//----step3 : 4*ii+{3,1,2,0},ii=0,1,2,3
assign data_in_s0_2  = {data_out[1][WID_D*15+:WID_D],data_out[1][WID_D*13+:WID_D],data_out[1][WID_D*14+:WID_D],data_out[1][WID_D*12+:WID_D],
                         data_out[1][WID_D*11+:WID_D],data_out[1][WID_D* 9+:WID_D],data_out[1][WID_D*10+:WID_D],data_out[1][WID_D* 8+:WID_D],
                         data_out[1][WID_D* 7+:WID_D],data_out[1][WID_D* 5+:WID_D],data_out[1][WID_D* 6+:WID_D],data_out[1][WID_D* 4+:WID_D],
                         data_out[1][WID_D* 3+:WID_D],data_out[1][WID_D* 1+:WID_D],data_out[1][WID_D* 2+:WID_D],data_out[1][WID_D* 0+:WID_D]};

assign idx_in_s0_2   = { idx_out[1][WID_I*15+:WID_I], idx_out[1][WID_I*13+:WID_I], idx_out[1][WID_I*14+:WID_I], idx_out[1][WID_I*12+:WID_I],
                          idx_out[1][WID_I*11+:WID_I], idx_out[1][WID_I* 9+:WID_I], idx_out[1][WID_I*10+:WID_I], idx_out[1][WID_I* 8+:WID_I],
                          idx_out[1][WID_I* 7+:WID_I], idx_out[1][WID_I* 5+:WID_I], idx_out[1][WID_I* 6+:WID_I], idx_out[1][WID_I* 4+:WID_I],
                          idx_out[1][WID_I* 3+:WID_I], idx_out[1][WID_I* 1+:WID_I], idx_out[1][WID_I* 2+:WID_I], idx_out[1][WID_I* 0+:WID_I]};

assign sort_ind_s0_2 = 8'b00110011;//1:ascend 0:descend

assign data_in_s0  = { data_in_s0_2, data_in_s0_1, data_in_s0_0};
assign idx_in_s0   = {  idx_in_s0_2,  idx_in_s0_1,  idx_in_s0_0};
assign sort_ind_s0 = {sort_ind_s0_2,sort_ind_s0_1,sort_ind_s0_0};
//====================================================
//==== stage 1
//====================================================
//----step1 : ii*8+{7,3,6,2,5,1,4,0},ii=0,1
assign sort_stage1_en = (sort_in_en_r && sort_num >= 2'd2);
assign data_in_s1_0  = sort_stage1_en ?  
                        {    sort_out[WID_D*15+:WID_D],    sort_out[WID_D*11+:WID_D],    sort_out[WID_D*14+:WID_D],    sort_out[WID_D*10+:WID_D],
                             sort_out[WID_D*13+:WID_D],    sort_out[WID_D* 9+:WID_D],    sort_out[WID_D*12+:WID_D],    sort_out[WID_D* 8+:WID_D],
                             sort_out[WID_D* 7+:WID_D],    sort_out[WID_D* 3+:WID_D],    sort_out[WID_D* 6+:WID_D],    sort_out[WID_D* 2+:WID_D],
                             sort_out[WID_D* 5+:WID_D],    sort_out[WID_D* 1+:WID_D],    sort_out[WID_D* 4+:WID_D],    sort_out[WID_D* 0+:WID_D]}
                        :{WID_D*16{1'b1}};
assign idx_in_s1_0   = sort_stage1_en ?
                        {sort_out_idx[WID_I*15+:WID_I],sort_out_idx[WID_I*11+:WID_I],sort_out_idx[WID_I*14+:WID_I],sort_out_idx[WID_I*10+:WID_I],
                         sort_out_idx[WID_I*13+:WID_I],sort_out_idx[WID_I* 9+:WID_I],sort_out_idx[WID_I*12+:WID_I],sort_out_idx[WID_I* 8+:WID_I],
                         sort_out_idx[WID_I* 7+:WID_I],sort_out_idx[WID_I* 3+:WID_I],sort_out_idx[WID_I* 6+:WID_I],sort_out_idx[WID_I* 2+:WID_I],
                         sort_out_idx[WID_I* 5+:WID_I],sort_out_idx[WID_I* 1+:WID_I],sort_out_idx[WID_I* 4+:WID_I],sort_out_idx[WID_I* 0+:WID_I]}
                        : {WID_I*16{1'b0}} ;

assign sort_ind_s1_0 = 8'b00001111;//1:ascend 0:descend

//----step2 : ii*8+{7,3,5,1,6,2,4,0},ii=0,1
assign data_in_s1_1  = {data_out[0][WID_D*15+:WID_D],data_out[0][WID_D*11+:WID_D],data_out[0][WID_D*13+:WID_D],data_out[0][WID_D*9+:WID_D],
                         data_out[0][WID_D*14+:WID_D],data_out[0][WID_D*10+:WID_D],data_out[0][WID_D*12+:WID_D],data_out[0][WID_D*8+:WID_D],
                         data_out[0][WID_D* 7+:WID_D],data_out[0][WID_D* 3+:WID_D],data_out[0][WID_D* 5+:WID_D],data_out[0][WID_D*1+:WID_D],
                         data_out[0][WID_D* 6+:WID_D],data_out[0][WID_D* 2+:WID_D],data_out[0][WID_D* 4+:WID_D],data_out[0][WID_D*0+:WID_D]};

assign idx_in_s1_1   = { idx_out[0][WID_I*15+:WID_I], idx_out[0][WID_I*11+:WID_I], idx_out[0][WID_I*13+:WID_I], idx_out[0][WID_I*9+:WID_I],
                          idx_out[0][WID_I*14+:WID_I], idx_out[0][WID_I*10+:WID_I], idx_out[0][WID_I*12+:WID_I], idx_out[0][WID_I*8+:WID_I],
                          idx_out[0][WID_I* 7+:WID_I], idx_out[0][WID_I* 3+:WID_I], idx_out[0][WID_I* 5+:WID_I], idx_out[0][WID_I*1+:WID_I],
                          idx_out[0][WID_I* 6+:WID_I], idx_out[0][WID_I* 2+:WID_I], idx_out[0][WID_I* 4+:WID_I], idx_out[0][WID_I*0+:WID_I]};

assign sort_ind_s1_1 = 8'b00001111;//1:ascend 0:descend

//----step3 : ii*4+{3,1,2,0},ii=0,1,2,3
assign data_in_s1_2  = {data_out[1][WID_D*15+:WID_D],data_out[1][WID_D*13+:WID_D],data_out[1][WID_D*14+:WID_D],data_out[1][WID_D*12+:WID_D],
                         data_out[1][WID_D*11+:WID_D],data_out[1][WID_D* 9+:WID_D],data_out[1][WID_D*10+:WID_D],data_out[1][WID_D* 8+:WID_D],
                         data_out[1][WID_D* 7+:WID_D],data_out[1][WID_D* 5+:WID_D],data_out[1][WID_D* 6+:WID_D],data_out[1][WID_D* 4+:WID_D],
                         data_out[1][WID_D* 3+:WID_D],data_out[1][WID_D* 1+:WID_D],data_out[1][WID_D* 2+:WID_D],data_out[1][WID_D* 0+:WID_D]};

assign idx_in_s1_2   = { idx_out[1][WID_I*15+:WID_I], idx_out[1][WID_I*13+:WID_I], idx_out[1][WID_I*14+:WID_I], idx_out[1][WID_I*12+:WID_I],
                          idx_out[1][WID_I*11+:WID_I], idx_out[1][WID_I* 9+:WID_I], idx_out[1][WID_I*10+:WID_I], idx_out[1][WID_I* 8+:WID_I],
                          idx_out[1][WID_I* 7+:WID_I], idx_out[1][WID_I* 5+:WID_I], idx_out[1][WID_I* 6+:WID_I], idx_out[1][WID_I* 4+:WID_I],
                          idx_out[1][WID_I* 3+:WID_I], idx_out[1][WID_I* 1+:WID_I], idx_out[1][WID_I* 2+:WID_I], idx_out[1][WID_I* 0+:WID_I]};

assign sort_ind_s1_2 = 8'b00001111;//1:ascend 0:descend

assign  data_in_s1  = { data_in_s1_2, data_in_s1_1, data_in_s1_0};
assign   idx_in_s1  = {  idx_in_s1_2,  idx_in_s1_1,  idx_in_s1_0};
assign sort_ind_s1  = {sort_ind_s1_2,sort_ind_s1_1,sort_ind_s1_0};
//====================================================
//==== stage 2
//====================================================
//----step1 :ii*2+{8:0},ii=0,1,2,3,4,5,6,7
assign sort_stage2_en = (sort_in_en_rr && sort_num == 2'd3);
assign data_in_s2_0  = sort_stage2_en ? 
                        {    sort_out[WID_D*15+:WID_D],    sort_out[WID_D*7+:WID_D],    sort_out[WID_D*14+:WID_D],    sort_out[WID_D*6+:WID_D],
                             sort_out[WID_D*13+:WID_D],    sort_out[WID_D*5+:WID_D],    sort_out[WID_D*12+:WID_D],    sort_out[WID_D*4+:WID_D],
                             sort_out[WID_D*11+:WID_D],    sort_out[WID_D*3+:WID_D],    sort_out[WID_D*10+:WID_D],    sort_out[WID_D*2+:WID_D],
                             sort_out[WID_D* 9+:WID_D],    sort_out[WID_D*1+:WID_D],    sort_out[WID_D* 8+:WID_D],    sort_out[WID_D*0+:WID_D]} 
                        :{WID_D*16{1'b1}};
assign idx_in_s2_0   = sort_stage2_en ?
                        {sort_out_idx[WID_I*15+:WID_I],sort_out_idx[WID_I*7+:WID_I],sort_out_idx[WID_I*14+:WID_I],sort_out_idx[WID_I*6+:WID_I],
                         sort_out_idx[WID_I*13+:WID_I],sort_out_idx[WID_I*5+:WID_I],sort_out_idx[WID_I*12+:WID_I],sort_out_idx[WID_I*4+:WID_I],
                         sort_out_idx[WID_I*11+:WID_I],sort_out_idx[WID_I*3+:WID_I],sort_out_idx[WID_I*10+:WID_I],sort_out_idx[WID_I*2+:WID_I],
                         sort_out_idx[WID_I* 9+:WID_I],sort_out_idx[WID_I*1+:WID_I],sort_out_idx[WID_I* 8+:WID_I],sort_out_idx[WID_I*0+:WID_I]} 
                         : {WID_I*16{1'b0}} ;

assign sort_ind_s2_0 = 8'b11111111;//1:ascend 0:descend

//----step2 : ii+{14,6,12,4,10,2,8,0},ii=0,1
assign data_in_s2_1  = {data_out[0][WID_D*15+:WID_D],data_out[0][WID_D*7+:WID_D],data_out[0][WID_D*13+:WID_D],data_out[0][WID_D*5+:WID_D],
                         data_out[0][WID_D*11+:WID_D],data_out[0][WID_D*3+:WID_D],data_out[0][WID_D* 9+:WID_D],data_out[0][WID_D*1+:WID_D],
                         data_out[0][WID_D*14+:WID_D],data_out[0][WID_D*6+:WID_D],data_out[0][WID_D*12+:WID_D],data_out[0][WID_D*4+:WID_D],
                         data_out[0][WID_D*10+:WID_D],data_out[0][WID_D*2+:WID_D],data_out[0][WID_D* 8+:WID_D],data_out[0][WID_D*0+:WID_D]};

assign idx_in_s2_1   = { idx_out[0][WID_I*15+:WID_I], idx_out[0][WID_I*7+:WID_I], idx_out[0][WID_I*13+:WID_I], idx_out[0][WID_I*5+:WID_I],
                          idx_out[0][WID_I*11+:WID_I], idx_out[0][WID_I*3+:WID_I], idx_out[0][WID_I* 9+:WID_I], idx_out[0][WID_I*1+:WID_I],
                          idx_out[0][WID_I*14+:WID_I], idx_out[0][WID_I*6+:WID_I], idx_out[0][WID_I*12+:WID_I], idx_out[0][WID_I*4+:WID_I],
                          idx_out[0][WID_I*10+:WID_I], idx_out[0][WID_I*2+:WID_I], idx_out[0][WID_I* 8+:WID_I], idx_out[0][WID_I*0+:WID_I]};

assign sort_ind_s2_1 = 8'b11111111;//1:ascend 0:descend

//----step3 ii*8+{7,3,5,1,6,2,4,0},ii=0,1
assign data_in_s2_2  = {data_out[1][WID_D*15+:WID_D],data_out[1][WID_D*11+:WID_D],data_out[1][WID_D*13+:WID_D],data_out[1][WID_D*9+:WID_D],
                         data_out[1][WID_D*14+:WID_D],data_out[1][WID_D*10+:WID_D],data_out[1][WID_D*12+:WID_D],data_out[1][WID_D*8+:WID_D],
                         data_out[1][WID_D* 7+:WID_D],data_out[1][WID_D* 3+:WID_D],data_out[1][WID_D* 5+:WID_D],data_out[1][WID_D*1+:WID_D],
                         data_out[1][WID_D* 6+:WID_D],data_out[1][WID_D* 2+:WID_D],data_out[1][WID_D* 4+:WID_D],data_out[1][WID_D*0+:WID_D]};

assign idx_in_s2_2   = { idx_out[1][WID_I*15+:WID_I], idx_out[1][WID_I*11+:WID_I], idx_out[1][WID_I*13+:WID_I], idx_out[1][WID_I*9+:WID_I],
                          idx_out[1][WID_I*14+:WID_I], idx_out[1][WID_I*10+:WID_I], idx_out[1][WID_I*12+:WID_I], idx_out[1][WID_I*8+:WID_I],
                          idx_out[1][WID_I* 7+:WID_I], idx_out[1][WID_I* 3+:WID_I], idx_out[1][WID_I* 5+:WID_I], idx_out[1][WID_I*1+:WID_I],
                          idx_out[1][WID_I* 6+:WID_I], idx_out[1][WID_I* 2+:WID_I], idx_out[1][WID_I* 4+:WID_I], idx_out[1][WID_I*0+:WID_I]};

assign sort_ind_s2_2 = 8'b11111111;//1:ascend 0:descend

//----step4 : ii*4+{3,1,2,0},ii=0,1,2,3
assign data_in_s2_3  = {data_out[2][WID_D*15+:WID_D],data_out[2][WID_D*13+:WID_D],data_out[2][WID_D*14+:WID_D],data_out[2][WID_D*12+:WID_D],
                         data_out[2][WID_D*11+:WID_D],data_out[2][WID_D* 9+:WID_D],data_out[2][WID_D*10+:WID_D],data_out[2][WID_D* 8+:WID_D],
                         data_out[2][WID_D* 7+:WID_D],data_out[2][WID_D* 5+:WID_D],data_out[2][WID_D* 6+:WID_D],data_out[2][WID_D* 4+:WID_D],
                         data_out[2][WID_D* 3+:WID_D],data_out[2][WID_D* 1+:WID_D],data_out[2][WID_D* 2+:WID_D],data_out[2][WID_D* 0+:WID_D]};

assign idx_in_s2_3   = { idx_out[2][WID_I*15+:WID_I], idx_out[2][WID_I*13+:WID_I], idx_out[2][WID_I*14+:WID_I], idx_out[2][WID_I*12+:WID_I],
                          idx_out[2][WID_I*11+:WID_I], idx_out[2][WID_I* 9+:WID_I], idx_out[2][WID_I*10+:WID_I], idx_out[2][WID_I* 8+:WID_I],
                          idx_out[2][WID_I* 7+:WID_I], idx_out[2][WID_I* 5+:WID_I], idx_out[2][WID_I* 6+:WID_I], idx_out[2][WID_I* 4+:WID_I],
                          idx_out[2][WID_I* 3+:WID_I], idx_out[2][WID_I* 1+:WID_I], idx_out[2][WID_I* 2+:WID_I], idx_out[2][WID_I* 0+:WID_I]};

assign sort_ind_s2_3 = 8'b11111111;//1:ascend 0:descend

assign  data_in_s2  = { data_in_s2_3, data_in_s2_2, data_in_s2_1, data_in_s2_0};
assign   idx_in_s2  = {  idx_in_s2_3,  idx_in_s2_2,  idx_in_s2_1,  idx_in_s2_0};
assign sort_ind_s2  = {sort_ind_s2_3,sort_ind_s2_2,sort_ind_s2_1,sort_ind_s2_0};
//====================================================
//==== sort
//====================================================
generate
  for(kk=0 ; kk<4 ; kk=kk+1)begin  : sort_stage2
    if(kk == 3)begin : sort_step3
      always @(*)begin
        if(sort_stage2_en)begin
          data_in[kk]  = data_in_s2[kk*WID_D*16 +: WID_D*16];
          idx_in[kk]   = idx_in_s2[kk*WID_I*16 +: WID_I*16];
          sort_ind[kk] = sort_ind_s2[kk*8 +: 8];
        end  
        else begin  
          data_in[kk]  = {WID_D*16{1'b1}};
          idx_in[kk]   = {WID_I*16{1'b0}};
          sort_ind[kk] = 8'd0;
        end
      end 
    end
    else begin : sort_step0to2
      always @(*)begin
        if(sort_stage0_en)begin
          data_in[kk]  = data_in_s0[kk*WID_D*16 +: WID_D*16];
          idx_in[kk]   = idx_in_s0[kk*WID_I*16 +: WID_I*16]; 
          sort_ind[kk] = sort_ind_s0[kk*8 +: 8];
        end  
        else if(sort_stage1_en)begin
          data_in[kk]  = data_in_s1[kk*WID_D*16 +: WID_D*16];
          idx_in[kk]   = idx_in_s1[kk*WID_I*16 +: WID_I*16];
          sort_ind[kk] = sort_ind_s1[kk*8 +: 8];
        end
        else if(sort_stage2_en)begin
          data_in[kk]  = data_in_s2[kk*WID_D*16 +: WID_D*16];
          idx_in[kk]   = idx_in_s2[kk*WID_I*16 +: WID_I*16];
          sort_ind[kk] = sort_ind_s2[kk*8 +: 8];
        end  
        else begin  
          data_in[kk]  = {WID_D*16{1'b1}};
          idx_in[kk]   = {WID_I*16{1'b0}};
          sort_ind[kk] = 8'd0;
        end
      end        
    end
    //sort_unit
    pdec_sort_unit #(
      .WID_D     (WID_D         ),
      .WID_I     (WID_I         )
    )
    U_sort_unit
    (
      .data_in  (data_in[kk]    ),
      .idx_in   (idx_in[kk]     ),
      .sort_ind (sort_ind[kk]   ),
      .data_out (data_out[kk]   ),
      .idx_out  (idx_out[kk]    )
    );
      
  end
endgenerate

//====================================================
//==== reg
//====================================================
always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin
    sort_out     <= {WID_D*16{1'b1}};
    sort_out_idx <= {WID_I*16{1'b0}};
  end  
  else if(sort_in_en && (sort_num == 2'd0))begin // sort2
    sort_out     <= {{WID_D*14{1'b1}},data1,data0};
    sort_out_idx <= {{WID_I*14{1'b0}},idx1,idx0};
  end  
  else if(sort_in_en && (sort_num > 2'd0))begin  // sort4
    sort_out     <= data_out[2];
    sort_out_idx <= idx_out[2];
  end  
  else if(sort_in_en_r && (sort_num > 2'd1))begin // sort8
    sort_out     <= data_out[2];
    sort_out_idx <= idx_out[2];
  end
  else if(sort_in_en_rr && (sort_num > 2'd2))begin // sort16
    sort_out     <= data_out[3];
    sort_out_idx <= idx_out[3];
  end
end    

endmodule
//Local Variables:
//verilog-library-flags:("-y ./ -y dir -y otherdir -y ./inc_dir/")
//verilog-auto-inst-param-value:t
//End:

