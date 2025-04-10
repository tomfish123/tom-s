//////////////////////////////////////////////////////////////////////////////////
// Description:
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps

module pdec_us_unit #(
  parameter                         I_W = 1
)(
  input   wire[I_W-1:0]             in0 , //us
  input   wire[I_W-1:0]             in1 , //tmp_in

  output  wire[I_W*2-1:0]           out   //tmp_out
);

//====================================================
//====       us_unit
//====================================================
genvar ii;

generate
  for(ii=0 ; ii<I_W ; ii=ii+1)begin  : cal_us_loop
    assign out[ii]     = in0[ii]^in1[ii]; //
    assign out[ii+I_W] = in1[ii]    ;
  end
endgenerate

endmodule
//Local Variables:
//verilog-library-flags:("-y ./ -y dir -y otherdir -y ./inc_dir/")
//verilog-auto-inst-param-value:t
//End:

