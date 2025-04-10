//////////////////////////////////////////////////////////////////////////////////
// Description:              
//              llr_st  : /--\_______________________________________________
//--------------------------------------frozen node---------------------------
//              llr_en  :    /----------------------\
//              llr_data:    <0><1><2><3><4><5><6><7>
//              pm_out_en:                           /-\
//              pm_out                               <-----{0,0,0,pm0}-------
//--------------------------------------repetion node---------------------------
//              llr_en  :    /----------------------\
//              llr_data:    <0><1><2><3><4><5><6><7>
//              pm_out_en:                           /-\
//              pm_out                               <-----{0,0,pm1,pm0}-----
//--------------------------------------info_20/21 node---------------------------
//              llr_en  :    /-\
//              llr_data:    <0>
//              pm_out_en:      /-\
//              pm_out          <-----{pm3,pm2,pm1,pm0}-----
//--------------------------------------info_3 node---------------------------
//              llr_en  :    /-\
//              llr_data:    <0>
//              delay   :       /----\(2cycle)
//              pm_out_en:            /-\
//              pm_out                <-----{pm3,pm2,pm1,pm0}-----
//--------------------------------------info_4 node---------------------------
//              llr_en  :    /-\
//              llr_data:    <0>
//              delay   :       /------\(3cycle)
//              pm_out_en:              /-\
//              pm_out                  <-----{pm3,pm2,pm1,pm0}-----
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps

module pdec_pm_unit #(
  parameter                         WID_PM  = 10   ,
  parameter                         WID_INN = 10
)(
  input   wire                      clk            ,
  input   wire                      rst_n          ,

  input  wire                       leaf_mode      , //1:stage2,0:stage0 : TBD
  input  wire[2:0]                  cur_jump_type  , //0:frozen,1:repetion,2:info_20,3:info_21,4:info_3,5:info_4,7:normal

  input  wire                       llr_st         , //1 clk befor llr_en
  input  wire                       llr_en         , 
  input  wire[WID_INN*4-1:0]        llr_data       , //>=stage2:{llr3,llr2,llr1,llr0},stage1:{0,0,llr1,llr0},stage0:{0,0,0,llr0}

  input  wire[WID_PM-1:0]           pm_updt_in     ,
  
  output wire                       pm_updt_out_en , //align with pm_updt_out and bit_updt_out
  output wire[WID_PM*4-1:0]         pm_updt_out    , //forzen node:{0,0,0,pm0},repetion node:{0,0,pm1,pm0},stage2 node:{pm3,pm2,pm1,pm0}
  output wire[4*4-1:0]              bit_updt_out     //forzen/repetion node:4'b0,stage2 node:{b3,b2,b1,b0}
);

//====================================================
//====  inner signals
//====================================================
wire[WID_INN-1:0]           llr0_abs           ; 
wire[WID_INN-1:0]           llr1_abs           ; 
wire[WID_INN-1:0]           llr2_abs           ; 
wire[WID_INN-1:0]           llr3_abs           ; 
wire                        llr0_sgn           ; 
wire                        llr1_sgn           ; 
wire                        llr2_sgn           ; 
wire                        llr3_sgn           ; 

reg [WID_INN-1:0]           llr0_abs_r         ; 
reg [WID_INN-1:0]           llr1_abs_r         ; 
reg [WID_INN-1:0]           llr2_abs_r         ; 
reg [WID_INN-1:0]           llr3_abs_r         ; 
reg                         llr0_sgn_r         ; 
reg                         llr1_sgn_r         ; 
reg                         llr2_sgn_r         ; 
reg                         llr3_sgn_r         ; 

wire[WID_INN-1:0]           llr0_for_pm0       ; 
wire[WID_INN-1:0]           llr1_for_pm0       ; 
wire[WID_INN-1:0]           llr2_for_pm0       ; 
wire[WID_INN-1:0]           llr3_for_pm0       ; 
wire[WID_INN-1:0]           llr0_for_pm1       ; 
wire[WID_INN-1:0]           llr1_for_pm1       ; 
wire[WID_INN-1:0]           llr2_for_pm1       ; 
wire[WID_INN-1:0]           llr3_for_pm1       ; 
wire[WID_PM+2:0]            pm0_add_llr        ; 
wire[WID_PM+2:0]            pm1_add_llr        ; 
wire[WID_PM-1:0]            pm0_add_llr_sat    ; 
wire[WID_PM-1:0]            pm1_add_llr_sat    ; 

reg [4*4-1:0]               ind_idx            ; 

wire[WID_INN:0]             llr23_add          ; 
wire[WID_INN:0]             llr13_add          ;
wire[WID_INN:0]             llr12_add          ;
wire[WID_INN:0]             llr03_add          ;
wire[WID_INN:0]             llr02_add          ;
wire[WID_INN:0]             llr01_add          ;

wire[WID_INN+1:0]           llr123_add         ; 
wire[WID_INN+1:0]           llr013_add         ;
wire[WID_INN+1:0]           llr023_add         ;
wire[WID_INN+1:0]           llr012_add         ;

wire[WID_PM-1:0]           llr23_add_sat      ; 
wire[WID_PM-1:0]           llr13_add_sat      ;
wire[WID_PM-1:0]           llr12_add_sat      ;
wire[WID_PM-1:0]           llr03_add_sat      ;
wire[WID_PM-1:0]           llr02_add_sat      ;
wire[WID_PM-1:0]           llr01_add_sat      ;

wire[WID_PM-1:0]           llr123_add_sat     ; 
wire[WID_PM-1:0]           llr013_add_sat     ;
wire[WID_PM-1:0]           llr023_add_sat     ;
wire[WID_PM-1:0]           llr012_add_sat     ;

reg [4*16-1:0]              sort_idx_in        ; 
reg [(WID_PM+1)*16-1:0]     sort_data_in       ; 
wire                        sort_in_en         ; 
wire[1:0]                   sort_num           ; 
wire[4*4-1:0]               sort_out_idx       ; 
wire[4*12-1:0]              sort_out_idx_hg_nc ; 
wire[(WID_PM+1)*16-1:0]     sort_out_hg_nc     ;  
wire                        sort_out_en        ; 

reg [WID_PM+2:0]            pm0_stage2_pre     ; 
reg [WID_PM+2:0]            pm1_stage2_pre     ; 
reg [WID_PM+2:0]            pm2_stage2_pre     ; 
reg [WID_PM+2:0]            pm3_stage2_pre     ; 
wire[WID_PM-1:0]            pm0_stage2_sat     ; 
wire[WID_PM-1:0]            pm1_stage2_sat     ; 
wire[WID_PM-1:0]            pm2_stage2_sat     ; 
wire[WID_PM-1:0]            pm3_stage2_sat     ; 
reg [WID_PM-1:0]            pm_temp0           ; 
reg [WID_PM-1:0]            pm_temp1           ; 
reg [WID_PM-1:0]            pm_temp2           ; 
reg [WID_PM-1:0]            pm_temp3           ; 
reg [3:0]                   bit_temp0          ; 
reg [3:0]                   bit_temp1          ; 
reg [3:0]                   bit_temp2          ; 
reg [3:0]                   bit_temp3          ; 

reg                         llr_en_r           ; 
reg                         sort_out_en_r      ; 
//====================================================
//====  llr abs
//====================================================
//----calculate abs for llr
hgw_abs #(.I_W(WID_INN)) U_llr0_abs(.i(llr_data[WID_INN*1-1:WID_INN*0]),.o(llr0_abs));
hgw_abs #(.I_W(WID_INN)) U_llr1_abs(.i(llr_data[WID_INN*2-1:WID_INN*1]),.o(llr1_abs));
hgw_abs #(.I_W(WID_INN)) U_llr2_abs(.i(llr_data[WID_INN*3-1:WID_INN*2]),.o(llr2_abs));
hgw_abs #(.I_W(WID_INN)) U_llr3_abs(.i(llr_data[WID_INN*4-1:WID_INN*3]),.o(llr3_abs));

//---calculate sign for llr
assign llr0_sgn = llr_data[WID_INN*1-1]; 
assign llr1_sgn = llr_data[WID_INN*2-1];
assign llr2_sgn = llr_data[WID_INN*3-1];
assign llr3_sgn = llr_data[WID_INN*4-1];

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin
    llr0_abs_r <= {WID_INN{1'b0}};
    llr1_abs_r <= {WID_INN{1'b0}};
    llr2_abs_r <= {WID_INN{1'b0}};
    llr3_abs_r <= {WID_INN{1'b0}};

    llr0_sgn_r <= 1'b0;
    llr1_sgn_r <= 1'b0;
    llr2_sgn_r <= 1'b0;
    llr3_sgn_r <= 1'b0;
  end
  else if(llr_en && leaf_mode && ((cur_jump_type == 3'd4) || (cur_jump_type == 3'd5)))begin //wait for sort result
    llr0_abs_r <= llr0_abs ; 
    llr1_abs_r <= llr1_abs ; 
    llr2_abs_r <= llr2_abs ; 
    llr3_abs_r <= llr3_abs ; 
                           
    llr0_sgn_r <= llr0_sgn ; 
    llr1_sgn_r <= llr1_sgn ; 
    llr2_sgn_r <= llr2_sgn ; 
    llr3_sgn_r <= llr3_sgn ; 
  end
end

//====================================================
//====  frozen and repetion
//====  include all stage
//====================================================
assign llr0_for_pm0 = (llr_en && ((cur_jump_type == 3'd0) || (cur_jump_type == 3'd1))) ? (llr0_sgn ? llr0_abs : {WID_INN{1'b0}}) : {WID_INN{1'b0}};
assign llr1_for_pm0 = (llr_en && ((cur_jump_type == 3'd0) || (cur_jump_type == 3'd1))) ? (llr1_sgn ? llr1_abs : {WID_INN{1'b0}}) : {WID_INN{1'b0}};
assign llr2_for_pm0 = (llr_en && ((cur_jump_type == 3'd0) || (cur_jump_type == 3'd1))) ? (llr2_sgn ? llr2_abs : {WID_INN{1'b0}}) : {WID_INN{1'b0}};
assign llr3_for_pm0 = (llr_en && ((cur_jump_type == 3'd0) || (cur_jump_type == 3'd1))) ? (llr3_sgn ? llr3_abs : {WID_INN{1'b0}}) : {WID_INN{1'b0}};

assign llr0_for_pm1 = (llr_en && (cur_jump_type == 3'd1)) ? (llr0_sgn ? {WID_INN{1'b0}} : llr0_abs) : {WID_INN{1'b0}};
assign llr1_for_pm1 = (llr_en && (cur_jump_type == 3'd1)) ? (llr1_sgn ? {WID_INN{1'b0}} : llr1_abs) : {WID_INN{1'b0}};
assign llr2_for_pm1 = (llr_en && (cur_jump_type == 3'd1)) ? (llr2_sgn ? {WID_INN{1'b0}} : llr2_abs) : {WID_INN{1'b0}};
assign llr3_for_pm1 = (llr_en && (cur_jump_type == 3'd1)) ? (llr3_sgn ? {WID_INN{1'b0}} : llr3_abs) : {WID_INN{1'b0}};

assign pm0_add_llr = pm_temp0 + llr0_for_pm0 + llr1_for_pm0 + llr2_for_pm0 + llr3_for_pm0; //width : 10+10+10+10+10 = 13
assign pm1_add_llr = pm_temp1 + llr0_for_pm1 + llr1_for_pm1 + llr2_for_pm1 + llr3_for_pm1;

hgw_sat_unsigned #(.I_W(WID_PM+3),.O_W(WID_PM)) U_pm0_add_llr_sat(.i(pm0_add_llr),.o(pm0_add_llr_sat));
hgw_sat_unsigned #(.I_W(WID_PM+3),.O_W(WID_PM)) U_pm1_add_llr_sat(.i(pm1_add_llr),.o(pm1_add_llr_sat));

//====================================================
//====             calculate ind_idx
//====================================================
always @(*)begin
  //----jump_type == 3'd2 : info_20
  if(     llr_en && leaf_mode && (cur_jump_type == 3'd2) && ((llr0_sgn == llr1_sgn) && (llr2_sgn == llr3_sgn)))
    ind_idx = {4'd15,4'd12,4'd3,4'd0};
  else if(llr_en && leaf_mode && (cur_jump_type == 3'd2) && ((llr0_sgn == llr1_sgn) && (llr2_sgn != llr3_sgn)))
    ind_idx = {4'd11,4'd7,4'd8,4'd4};
  else if(llr_en && leaf_mode && (cur_jump_type == 3'd2) && ((llr0_sgn != llr1_sgn) && (llr2_sgn == llr3_sgn)))
    ind_idx = {4'd14,4'd13,4'd2,4'd1};
  else if(llr_en && leaf_mode && (cur_jump_type == 3'd2) && ((llr0_sgn != llr1_sgn) && (llr2_sgn != llr3_sgn)))
    ind_idx = {4'd10,4'd9,4'd6,4'd5};
  
  //----jump_type == 3'd3 : info_21
  else if(llr_en && leaf_mode && (cur_jump_type == 3'd3) && ((llr0_sgn == llr2_sgn) && (llr1_sgn == llr3_sgn)))
    ind_idx = {4'd15,4'd10,4'd5,4'd0};
  else if(llr_en && leaf_mode && (cur_jump_type == 3'd3) && ((llr0_sgn == llr2_sgn) && (llr1_sgn != llr3_sgn)))
    ind_idx = {4'd13,4'd7,4'd8,4'd2};
  else if(llr_en && leaf_mode && (cur_jump_type == 3'd3) && ((llr0_sgn != llr2_sgn) && (llr1_sgn == llr3_sgn)))
    ind_idx = {4'd14,4'd11,4'd4,4'd1};
  else if(llr_en && leaf_mode && (cur_jump_type == 3'd3) && ((llr0_sgn != llr2_sgn) && (llr1_sgn != llr3_sgn)))
    ind_idx = {4'd12,4'd9,4'd6,4'd3};

  //----jump_type == 3'd4 : info_3
  else if(sort_out_en && leaf_mode && (cur_jump_type == 3'd4) && (((llr0_sgn == llr2_sgn) && (llr1_sgn == llr3_sgn)) || ((llr0_sgn != llr2_sgn) && (llr1_sgn != llr3_sgn))))
    ind_idx = {sort_out_idx[11:0],4'd0};
  else if(sort_out_en && leaf_mode && (cur_jump_type == 3'd4))
    ind_idx = sort_out_idx[15:0];
  
  //----jump_type == 3'd5 : info_4
  else if(sort_out_en && leaf_mode && (cur_jump_type == 3'd5))
    ind_idx = {sort_out_idx[11:0],4'd0};
  else
    ind_idx = {4*4{1'b0}};
end

//====================================================
//====   
//====================================================


assign llr23_add = llr2_abs + llr3_abs;
assign llr13_add = llr1_abs + llr3_abs;
assign llr12_add = llr1_abs + llr2_abs;
assign llr03_add = llr0_abs + llr3_abs;
assign llr02_add = llr0_abs + llr2_abs;
assign llr01_add = llr0_abs + llr1_abs;

assign llr123_add = llr1_abs+llr2_abs+llr3_abs; 
assign llr013_add = llr0_abs+llr1_abs+llr3_abs;
assign llr023_add = llr0_abs+llr2_abs+llr3_abs;
assign llr012_add = llr0_abs+llr1_abs+llr2_abs;

//cchdec : 11->10 bd : 11->11
`ifdef PDEC_BD
  assign llr23_add_sat = llr23_add; 
  assign llr13_add_sat = llr13_add;
  assign llr12_add_sat = llr12_add;
  assign llr03_add_sat = llr03_add;
  assign llr02_add_sat = llr02_add;
  assign llr01_add_sat = llr01_add;
`else
  hgw_sat_unsigned #(.I_W(WID_INN+1),.O_W(WID_PM)) U_llr23_add_sat(.i(llr23_add),.o(llr23_add_sat));
  hgw_sat_unsigned #(.I_W(WID_INN+1),.O_W(WID_PM)) U_llr13_add_sat(.i(llr13_add),.o(llr13_add_sat));
  hgw_sat_unsigned #(.I_W(WID_INN+1),.O_W(WID_PM)) U_llr12_add_sat(.i(llr12_add),.o(llr12_add_sat));
  hgw_sat_unsigned #(.I_W(WID_INN+1),.O_W(WID_PM)) U_llr03_add_sat(.i(llr03_add),.o(llr03_add_sat));
  hgw_sat_unsigned #(.I_W(WID_INN+1),.O_W(WID_PM)) U_llr02_add_sat(.i(llr02_add),.o(llr02_add_sat));
  hgw_sat_unsigned #(.I_W(WID_INN+1),.O_W(WID_PM)) U_llr01_add_sat(.i(llr01_add),.o(llr01_add_sat));
`endif
//cchdec : 12->10 : bd : 12->11
hgw_sat_unsigned #(.I_W(WID_INN+2),.O_W(WID_PM)) U_llr123_add_sat(.i(llr123_add),.o(llr123_add_sat)); 
hgw_sat_unsigned #(.I_W(WID_INN+2),.O_W(WID_PM)) U_llr013_add_sat(.i(llr013_add),.o(llr013_add_sat));
hgw_sat_unsigned #(.I_W(WID_INN+2),.O_W(WID_PM)) U_llr023_add_sat(.i(llr023_add),.o(llr023_add_sat));
hgw_sat_unsigned #(.I_W(WID_INN+2),.O_W(WID_PM)) U_llr012_add_sat(.i(llr012_add),.o(llr012_add_sat));


always @(*)begin //if timing cant meet,then delay one cycle;
  if(llr_en && leaf_mode && (cur_jump_type == 3'd4) && (((llr0_sgn == llr2_sgn) && (llr1_sgn == llr3_sgn)) || ((llr0_sgn != llr2_sgn) && (llr1_sgn != llr3_sgn))))begin
    sort_idx_in  = {32'd0,{4'd14,4'd13,4'd12,4'd10,4'd6,4'd9,4'd5,4'd3}}; //4'd14 and 4'd13 is filled value
    sort_data_in = {{10*(WID_PM+1){1'b1}},
                    {1'b0,llr23_add_sat  },
                    {1'b0,llr13_add_sat  },
                    {1'b0,llr12_add_sat  },
                    {1'b0,llr03_add_sat  },
                    {1'b0,llr02_add_sat  },
                    {1'b0,llr01_add_sat  }};
  end  
  else if(llr_en && leaf_mode && (cur_jump_type == 3'd4))begin
    sort_idx_in  = {32'd0,{4'd14,4'd11,4'd13,4'd7,4'd8,4'd4,4'd2,4'd1}};
    sort_data_in = {{8*(WID_PM+1){1'b1}},
                    {1'b0,llr123_add_sat},
                    {1'b0,llr013_add_sat},
                    {1'b0,llr023_add_sat},
                    {1'b0,llr012_add_sat},
                    {1'b0,llr3_abs      },
                    {1'b0,llr2_abs      },
                    {1'b0,llr1_abs      },
                    {1'b0,llr0_abs      }};
  end
  else if(llr_en && leaf_mode && (cur_jump_type == 3'd5))begin
    sort_idx_in  = {4'd15,4'd15,4'd14,4'd11,4'd13,4'd7,4'd12,4'd10,4'd6,4'd9,4'd5,4'd3,4'd8,4'd4,4'd2,4'd1};
    sort_data_in = {{2*(WID_PM+1){1'b1}},
                    {1'b0,llr123_add_sat},
                    {1'b0,llr013_add_sat},
                    {1'b0,llr023_add_sat},
                    {1'b0,llr012_add_sat},
                    {1'b0,llr23_add_sat },
                    {1'b0,llr13_add_sat },
                    {1'b0,llr12_add_sat },
                    {1'b0,llr03_add_sat },
                    {1'b0,llr02_add_sat },
                    {1'b0,llr01_add_sat },
                    {1'b0,llr3_abs      },
                    {1'b0,llr2_abs      },
                    {1'b0,llr1_abs      },
                    {1'b0,llr0_abs      }};
  end
  else begin
    sort_idx_in  = 64'd0;
    sort_data_in = {16*(WID_PM+1){1'b1}};
  end
end

assign sort_num   = leaf_mode ? (cur_jump_type == 3'd4 ? 2'd2 : 2'd3) : 2'd0 ; //sort8 or sort16
assign sort_in_en = leaf_mode && llr_en && ((cur_jump_type == 3'd4) || (cur_jump_type == 3'd5));

pdec_botnic_sort #(
  .WID_D       (WID_PM+1                           ),
  .WID_I       (4                                   )
)
U_sort_stage2
(
  .clk         (clk                                 ),
  .rst_n       (rst_n                               ),
  .sort_num    (sort_num                            ), //0:sort2 1:sort4,2:sort8,3:sort16
  .sort_in_en  (sort_in_en                          ),
  .sort_in     (sort_data_in                        ),
  .sort_in_idx (sort_idx_in                         ),
  .sort_out_idx({sort_out_idx_hg_nc,sort_out_idx}   ),
  .sort_out    (sort_out_hg_nc                      ), 
  .sort_done   (sort_out_en                         )  // align with sort_out,can be treated as sort_out_en
);
//====================================================
//====        calculate pm 
//====================================================
always @(*)begin
  if(llr_en && leaf_mode && ((cur_jump_type == 3'd2) || (cur_jump_type == 3'd3)))begin
    pm0_stage2_pre = pm_temp0 + ({WID_INN{ind_idx[0 ]}} & llr0_abs) + ({WID_INN{ind_idx[1 ]}} & llr1_abs) + ({WID_INN{ind_idx[2 ]}} & llr2_abs) + ({WID_INN{ind_idx[3 ]}} & llr3_abs);
    pm1_stage2_pre = pm_temp1 + ({WID_INN{ind_idx[4 ]}} & llr0_abs) + ({WID_INN{ind_idx[5 ]}} & llr1_abs) + ({WID_INN{ind_idx[6 ]}} & llr2_abs) + ({WID_INN{ind_idx[7 ]}} & llr3_abs);
    pm2_stage2_pre = pm_temp2 + ({WID_INN{ind_idx[8 ]}} & llr0_abs) + ({WID_INN{ind_idx[9 ]}} & llr1_abs) + ({WID_INN{ind_idx[10]}} & llr2_abs) + ({WID_INN{ind_idx[11]}} & llr3_abs);
    pm3_stage2_pre = pm_temp3 + ({WID_INN{ind_idx[12]}} & llr0_abs) + ({WID_INN{ind_idx[13]}} & llr1_abs) + ({WID_INN{ind_idx[14]}} & llr2_abs) + ({WID_INN{ind_idx[15]}} & llr3_abs);
  end
  else if(sort_out_en && leaf_mode && ((cur_jump_type == 3'd4) || (cur_jump_type == 3'd5)))begin
    pm0_stage2_pre = pm_temp0 + ({WID_INN{ind_idx[0 ]}} & llr0_abs_r) + ({WID_INN{ind_idx[1 ]}} & llr1_abs_r) + ({WID_INN{ind_idx[2 ]}} & llr2_abs_r) + ({WID_INN{ind_idx[3 ]}} & llr3_abs_r);
    pm1_stage2_pre = pm_temp1 + ({WID_INN{ind_idx[4 ]}} & llr0_abs_r) + ({WID_INN{ind_idx[5 ]}} & llr1_abs_r) + ({WID_INN{ind_idx[6 ]}} & llr2_abs_r) + ({WID_INN{ind_idx[7 ]}} & llr3_abs_r);
    pm2_stage2_pre = pm_temp2 + ({WID_INN{ind_idx[8 ]}} & llr0_abs_r) + ({WID_INN{ind_idx[9 ]}} & llr1_abs_r) + ({WID_INN{ind_idx[10]}} & llr2_abs_r) + ({WID_INN{ind_idx[11]}} & llr3_abs_r);
    pm3_stage2_pre = pm_temp3 + ({WID_INN{ind_idx[12]}} & llr0_abs_r) + ({WID_INN{ind_idx[13]}} & llr1_abs_r) + ({WID_INN{ind_idx[14]}} & llr2_abs_r) + ({WID_INN{ind_idx[15]}} & llr3_abs_r);
  end
  else begin
    pm0_stage2_pre = {WID_PM+3{1'b0}};
    pm1_stage2_pre = {WID_PM+3{1'b0}};
    pm2_stage2_pre = {WID_PM+3{1'b0}};
    pm3_stage2_pre = {WID_PM+3{1'b0}};
  end
end

hgw_sat_unsigned #(.I_W(WID_PM+3),.O_W(WID_PM)) U_pm0_stage2_sat(.i(pm0_stage2_pre),.o(pm0_stage2_sat));
hgw_sat_unsigned #(.I_W(WID_PM+3),.O_W(WID_PM)) U_pm1_stage2_sat(.i(pm1_stage2_pre),.o(pm1_stage2_sat));
hgw_sat_unsigned #(.I_W(WID_PM+3),.O_W(WID_PM)) U_pm2_stage2_sat(.i(pm2_stage2_pre),.o(pm2_stage2_sat));
hgw_sat_unsigned #(.I_W(WID_PM+3),.O_W(WID_PM)) U_pm3_stage2_sat(.i(pm3_stage2_pre),.o(pm3_stage2_sat));

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    pm_temp0 <= {WID_PM{1'b0}};
  else if(llr_st)
    pm_temp0 <= pm_updt_in;
  else if(llr_en && ((cur_jump_type == 3'd0)||(cur_jump_type == 3'd1))) //frozen and repetion
    pm_temp0 <= pm0_add_llr_sat;
  else if(llr_en && leaf_mode && ((cur_jump_type == 3'd2) || (cur_jump_type == 3'd3))) //info_20 and info_21
    pm_temp0 <= pm0_stage2_sat;
  else if(sort_out_en && leaf_mode && ((cur_jump_type == 3'd4) || (cur_jump_type == 3'd5))) //info_3 and info_4
    pm_temp0 <= pm0_stage2_sat;
end    

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    pm_temp1 <= {WID_PM{1'b0}};
  else if(llr_st && (cur_jump_type != 3'd0))
    pm_temp1 <= pm_updt_in;
  else if(llr_en && (cur_jump_type == 3'd1)) //repetion
    pm_temp1 <= pm1_add_llr_sat;
  else if(llr_en && leaf_mode && ((cur_jump_type == 3'd2) || (cur_jump_type == 3'd3))) //info_20 and info_21
    pm_temp1 <= pm1_stage2_sat;
  else if(sort_out_en && leaf_mode && ((cur_jump_type == 3'd4) || (cur_jump_type == 3'd5))) //info_3 and info_4
    pm_temp1 <= pm1_stage2_sat;
end    

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    pm_temp2 <= {WID_PM{1'b0}};
  else if(llr_st && leaf_mode && ((cur_jump_type != 3'd0) || (cur_jump_type != 3'd1)))
    pm_temp2 <= pm_updt_in;
  else if(llr_en && leaf_mode && ((cur_jump_type == 3'd2) || (cur_jump_type == 3'd3))) //info_20 and info_21
    pm_temp2 <= pm2_stage2_sat;
  else if(sort_out_en && leaf_mode && ((cur_jump_type == 3'd4) || (cur_jump_type == 3'd5))) //info_3 and info_4
    pm_temp2 <= pm2_stage2_sat;
end    

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    pm_temp3 <= {WID_PM{1'b0}};
  else if(llr_st  && leaf_mode && ((cur_jump_type != 3'd0) || (cur_jump_type != 3'd1)))
    pm_temp3 <= pm_updt_in;
  else if(llr_en && leaf_mode && ((cur_jump_type == 3'd2) || (cur_jump_type == 3'd3))) //info_20 and info_21
    pm_temp3 <= pm3_stage2_sat;
  else if(sort_out_en && leaf_mode && ((cur_jump_type == 3'd4) || (cur_jump_type == 3'd5))) //info_3 and info_4
    pm_temp3 <= pm3_stage2_sat;
end    


//====================================================
//====      calculate hard bit of stage2
//====  1. used for update us after sorted
//====  2. used for write into list after sort and inverse coding
//====================================================
always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin
    bit_temp0 <= 4'd0;
    bit_temp1 <= 4'd0;
    bit_temp2 <= 4'd0;
    bit_temp3 <= 4'd0;
  end
  else if(llr_st  && leaf_mode)begin
    bit_temp0 <= 4'd0;
    bit_temp1 <= 4'd0;
    bit_temp2 <= 4'd0;
    bit_temp3 <= 4'd0;
  end
  else if(llr_en && leaf_mode && ((cur_jump_type == 3'd2) || (cur_jump_type == 3'd3)))begin //info_20 and info_21
    bit_temp0 <= {ind_idx[3 ]^llr3_sgn,ind_idx[2 ]^llr2_sgn,ind_idx[1 ]^llr1_sgn,ind_idx[0 ]^llr0_sgn};
    bit_temp1 <= {ind_idx[7 ]^llr3_sgn,ind_idx[6 ]^llr2_sgn,ind_idx[5 ]^llr1_sgn,ind_idx[4 ]^llr0_sgn};
    bit_temp2 <= {ind_idx[11]^llr3_sgn,ind_idx[10]^llr2_sgn,ind_idx[9 ]^llr1_sgn,ind_idx[8 ]^llr0_sgn};
    bit_temp3 <= {ind_idx[15]^llr3_sgn,ind_idx[14]^llr2_sgn,ind_idx[13]^llr1_sgn,ind_idx[12]^llr0_sgn};
  end  
  else if(sort_out_en && leaf_mode && ((cur_jump_type == 3'd4) || (cur_jump_type == 3'd5)))begin //info_3 and info_4
    bit_temp0 <= {ind_idx[3 ]^llr3_sgn_r,ind_idx[2 ]^llr2_sgn_r,ind_idx[1 ]^llr1_sgn_r,ind_idx[0 ]^llr0_sgn_r};
    bit_temp1 <= {ind_idx[7 ]^llr3_sgn_r,ind_idx[6 ]^llr2_sgn_r,ind_idx[5 ]^llr1_sgn_r,ind_idx[4 ]^llr0_sgn_r};
    bit_temp2 <= {ind_idx[11]^llr3_sgn_r,ind_idx[10]^llr2_sgn_r,ind_idx[9 ]^llr1_sgn_r,ind_idx[8 ]^llr0_sgn_r};
    bit_temp3 <= {ind_idx[15]^llr3_sgn_r,ind_idx[14]^llr2_sgn_r,ind_idx[13]^llr1_sgn_r,ind_idx[12]^llr0_sgn_r};
  end
end
//====================================================
//====                 output
//====================================================
always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    llr_en_r <= 1'b0;
  else
    llr_en_r <= llr_en;
end

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    sort_out_en_r <= 1'b0;
  else
    sort_out_en_r <= sort_out_en;
end

assign pm_updt_out_en = (((~llr_en) & llr_en_r) && (((cur_jump_type == 3'd0) || (cur_jump_type == 3'd1)) || (leaf_mode && ((cur_jump_type == 3'd2) || (cur_jump_type == 3'd3))))) || (sort_out_en_r && leaf_mode && ((cur_jump_type == 3'd4) || (cur_jump_type == 3'd5))) ;

assign pm_updt_out  = {pm_temp3 ,pm_temp2 ,pm_temp1 ,pm_temp0 };
assign bit_updt_out = {bit_temp3,bit_temp2,bit_temp1,bit_temp0};

endmodule
//Local Variables:
//verilog-library-flags:("-y ./ -y dir -y otherdir -y ./inc_dir/")
//verilog-auto-inst-param-value:t
//End:

