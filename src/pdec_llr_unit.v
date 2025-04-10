//////////////////////////////////////////////////////////////////////////////////
// Description:   |         stage >=2                        |         stage ==1           |         stage ==1     |
//    llr_in_data |{llr7,llr6,llr5,llr4,llr3,llr2,llr1,llr0} |{0,0,llr3,llr2,0,0,llr1,llr0}|{0,0,0,llr1,0,0,0,llr0}|
//    us_in_data  |{us3,us2,us1,us0}                         |{0,0,us1,us0}                |{0,0,0,us0}            |  
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps

module pdec_llr_unit#(
  parameter                          WID_INN = 10          
)(
  //----parameter signals
  input  wire                        cur_fg              , 

  //----pdec_rd_ctrl interface
  input  wire                        llr_in_en           , 
  input  wire[WID_INN*8-1:0]         llr_in_data         , //stage+1 : {llr7,llr6,llr5,llr4,llr3,llr2,llr1,llr0}
  input  wire[4-1:0]                 us_in_data          , //stage   : {us3,us2,us1,us0}

  //----pdec_updt_pm interface
  output wire[WID_INN*4-1:0]         llr_out_data          //{llr3,llr2,llr1,llr0}

);

//====================================================
//====               inner signals
//====================================================
genvar              ii                       ; 

wire[WID_INN-1:0]   f_llr_in[7:0]            ; 
wire[WID_INN-1:0]   f_llr_abs[7:0]           ; 
wire[WID_INN-1:0]   f_llr_abs_min[3:0]       ; 
wire[WID_INN-1:0]   f_func_out[3:0]          ; 

wire[WID_INN-1:0]   g_llr_in[7:0]            ; 
wire[WID_INN-1:0]   g_llr_in_us_mux[3:0]     ; 
wire[WID_INN  :0]   g_llr0_add_llr1[3:0]     ; 
wire[WID_INN-1:0]   g_func_out[3:0]          ; 

//====================================================
//====               F/G function
//====================================================
generate
  for(ii=0 ; ii<4 ; ii=ii+1)begin  : fg_func
    //----arrange llr format 
    assign f_llr_in[2*ii  ] = cur_fg ? llr_in_data[ii*WID_INN           +: WID_INN] : {WID_INN{1'b0}}; // 0/4 1/5 2/6 3/7
    assign f_llr_in[2*ii+1] = cur_fg ? llr_in_data[ii*WID_INN+WID_INN*4 +: WID_INN] : {WID_INN{1'b0}};
    
    //----calculate f function
    hgw_abs #(.I_W(WID_INN)) U_llr0_abs(.i(f_llr_in[2*ii  ]),.o(f_llr_abs[2*ii  ]));
    hgw_abs #(.I_W(WID_INN)) U_llr1_abs(.i(f_llr_in[2*ii+1]),.o(f_llr_abs[2*ii+1]));

    assign f_llr_abs_min[ii] = f_llr_abs[2*ii] >= f_llr_abs[2*ii+1] ? f_llr_abs[2*ii+1] : f_llr_abs[2*ii]; //min(abs0,abs1);
    assign f_func_out[ii]    = (f_llr_in[2*ii][WID_INN-1] != f_llr_in[2*ii+1][WID_INN-1]) ? (-f_llr_abs_min[ii]) : f_llr_abs_min[ii];
 
    //----arrange llr format 
    assign g_llr_in[2*ii  ] = (~cur_fg) ? llr_in_data[ii*WID_INN           +: WID_INN] : {WID_INN{1'b0}};// 0/4 1/5 2/6 3/7
    assign g_llr_in[2*ii+1] = (~cur_fg) ? llr_in_data[ii*WID_INN+WID_INN*4 +: WID_INN] : {WID_INN{1'b0}};

    assign g_llr_in_us_mux[ii] = us_in_data[ii] ? (-g_llr_in[2*ii]) : g_llr_in[2*ii]; 
 
    assign g_llr0_add_llr1[ii] = $signed(g_llr_in_us_mux[ii]) + $signed(g_llr_in[2*ii+1]);

    hgw_sat_signed #(.I_W(WID_INN+1),.O_W(WID_INN)) U_llr_sat(.i(g_llr0_add_llr1[ii]),.o(g_func_out[ii]));

    //----F/G function mux
    
    assign llr_out_data[(ii+1)*WID_INN-1:ii*WID_INN] = llr_in_en ? (cur_fg ? f_func_out[ii] : g_func_out[ii]) : {WID_INN{1'b0}};
  
  end
endgenerate 

endmodule
//Local Variables:
//verilog-library-flags:("-y ./ -y dir -y otherdir -y ./inc_dir/")
//verilog-auto-inst-param-value:t
//End:

