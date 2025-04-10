//////////////////////////////////////////////////////////////////////////////////
// Description:
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps

module pdec_sort_unit #(
    parameter                         WID_D     = 10 , 
    parameter                         WID_I     = 5
    )(
    input  wire[WID_D*16-1:0]         data_in        , //pair0:0/1, pair1:2/3,...,pair7:14/15
    input  wire[WID_I*16-1:0]         idx_in         , 
    input  wire[8-1:0]                sort_ind       , //0:descend 1:ascend

    output wire[WID_D*16-1:0]         data_out       , 
    output wire[WID_I*16-1:0]         idx_out
);

//====================================================
//==== sort
//====================================================
genvar            ii         ;
wire[WID_D-1:0]   data0[7:0] ;
wire[WID_D-1:0]   data1[7:0] ;
wire[WID_I-1:0]   idx0[7:0]  ;
wire[WID_I-1:0]   idx1[7:0]  ;
wire[7:0]         change_ind ;

generate
  for(ii=0 ; ii<8 ; ii=ii+1)begin  : sort_unit
    //extract data/idx0 and data/idx1
    assign data0[ii] = data_in[ 2*ii   *WID_D +: WID_D];
    assign data1[ii] = data_in[(2*ii+1)*WID_D +: WID_D];

    assign idx0[ii]  =  idx_in[ 2*ii   *WID_I +: WID_I];
    assign idx1[ii]  =  idx_in[(2*ii+1)*WID_I +: WID_I];

    //ascend and descend sort proc
    //ascend  : > : change, <= :hold;
    //descend : < : change, >= :hold;
    assign change_ind[ii]   = sort_ind[ii] ? ((data0[ii] > data1[ii]) ? 1'b1 : 1'b0) : ((data0[ii] < data1[ii]) ? 1'b1 : 1'b0);
    assign data_out[ 2*ii   *WID_D +: WID_D] = change_ind[ii] ? data1[ii] : data0[ii];
    assign data_out[(2*ii+1)*WID_D +: WID_D] = change_ind[ii] ? data0[ii] : data1[ii];
    
    assign idx_out[ 2*ii   *WID_I +: WID_I] = change_ind[ii] ? idx1[ii] : idx0[ii];
    assign idx_out[(2*ii+1)*WID_I +: WID_I] = change_ind[ii] ? idx0[ii] : idx1[ii];

  end
endgenerate

endmodule
//Local Variables:
//verilog-library-flags:("-y ./ -y dir -y otherdir -y ./inc_dir/")
//verilog-auto-inst-param-value:t
//End:

