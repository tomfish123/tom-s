//////////////////////////////////////////////////////////////////////////////////
// Description:
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps

module pdec_updt_pm#(
  parameter                         WID_PM  = 10       ,
  parameter                         WID_INN = 10
)(
  input   wire                      clk                ,
  input   wire                      rst_n              ,
  
  //----ICG
  output wire                       pdec_clk_en3       ,
  
  //----pdec_para_cfg inerface
  input  wire                       leaf_mode          , //0:stage0 is leaf node, 1:stage2 is leaf node

  //----braodcast control signals
  input  wire[2:0]                  cur_jump_type      , //0:frozen,1:repetion,2:info_20,3:info_21,4:info_3,5:info_4,7:normal
  input  wire[2*8-1:0]              path_valid         , //0:CK path, 1:valid path,3:invalid_path
  
  //----pdec_top_ctrl interface
  input  wire[1:0]                  ctrl2upm_pm_src_ind, //1:last pm updated by frozen,2:last pm updated by info
  output wire                       upm2ctrl_upm_done  , //used for state jump condition
  
  //----pdec_updt_pm interface
  input  wire[8-1:0]                ulr2upm_llr_st     , //1clk befor llr_en
  input  wire[8-1:0]                ulr2upm_llr_en     , 
  input  wire[WID_INN*4*8-1:0]      ulr2upm_llr_data   , //>=stage2:{llr3,llr2,llr1,llr0},stage1:{0,0,llr1,llr0},stage0:{0,0,0,llr0} 

  //---pdec_updt_path interface
  output wire[4*4*8-1:0]            upm2uph_bit_val    , //only valid for leaf_mode == 1

  //----pdec_pm_sort interface
  output wire[WID_PM*4*8-1:0]       upm2srt_pm_val     , //32 for stage2 and 16 for others
  input  wire[WID_PM*8-1:0]         srt2upm_pm_val     

);
//====================================================
//====           inner signals
//====================================================
genvar              ii             ;
reg [WID_PM-1:0]    pm_updt_in[7:0];  
wire[8-1:0]         llr_en         ;
wire[8-1:0]         pm_updt_out_en ;

//====================================================
//====  pm_unit
//====================================================
generate
  for(ii=0 ; ii<8 ; ii=ii+1)begin  : pm_unit
    //----select pm source
    always @(*)begin
      if(ulr2upm_llr_st[ii] && (ctrl2upm_pm_src_ind == 2'd1))  
        pm_updt_in[ii] = upm2srt_pm_val[WID_PM*ii*4 +: WID_PM]; 
      else if(ulr2upm_llr_st[ii] && (ctrl2upm_pm_src_ind == 2'd2))
        pm_updt_in[ii] = srt2upm_pm_val[WID_PM*ii   +: WID_PM];
      else 
        pm_updt_in[ii] = {WID_PM{1'b0}};
    end
    //0:CK path 1: valid path 3:invalid path,if path_valid[ii*2] == 0 ,it is CK path
    assign llr_en[ii] = ulr2upm_llr_en[ii] & (~((~path_valid[ii*2]) & (cur_jump_type != 3'd0))); //not ck path of info bit
    //----pm unit  
    pdec_pm_unit #(
      .WID_PM                  (WID_PM                                     ) ,
      .WID_INN                 (WID_INN                                    ) ) 
    U_pdec_pm_unit(
      // Outputs
      .pm_updt_out_en          (pm_updt_out_en [ii]                        ) ,
      .pm_updt_out             (upm2srt_pm_val [ii*WID_PM*4 +: WID_PM*4]   ) ,
      .bit_updt_out            (upm2uph_bit_val[ii*4     *4 +: 4     *4]   ) ,
      // Inputs
      .clk                     (clk                                        ) ,
      .rst_n                   (rst_n                                      ) ,
      .leaf_mode               (leaf_mode                                  ) ,
      .cur_jump_type           (cur_jump_type[2:0]                         ) ,
      .llr_st                  (ulr2upm_llr_st[ii]                         ) ,
      .llr_en                  (llr_en[ii]                         ) ,
      .llr_data                (ulr2upm_llr_data[ii*WID_INN*4 +: WID_INN*4]) ,
      .pm_updt_in              (pm_updt_in[ii]                             ) ) ;
  end
endgenerate

assign upm2ctrl_upm_done = (|pm_updt_out_en);//align with output pm value

//====================================================
//====  ICG
//====================================================
reg pm_proc;
always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    pm_proc <= 1'b0;
  else if((|ulr2upm_llr_st))  
    pm_proc <= 1'b1;
  else if(upm2ctrl_upm_done)  
    pm_proc <= 1'b0;
end    

assign pdec_clk_en3 = (|ulr2upm_llr_st) | 
                      pm_proc           ;

endmodule
//Local Variables:
//verilog-library-flags:("-y ./ -y dir -y otherdir -y ./inc_dir/")
//verilog-auto-inst-param-value:t
//End:

