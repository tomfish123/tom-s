//////////////////////////////////////////////////////////////////////////////////
// Description: saturature for the signed
//////////////////////////////////////////////////////////////////////////////////

module hgw_sat_signed
(
  i,o
);

  parameter I_W = 16;
  parameter O_W = 15;
  
  input  signed [I_W - 1 : 0] i;
  output signed [O_W - 1 : 0] o;
  
  reg signed [O_W-1:0]o;
  
  reg signed [O_W-1:0]o_pre;

  always @(*)
  begin
    if (i[I_W-1 : O_W-1] == {I_W-O_W+1{i[I_W-1]}}) //equals to 00000 or 111111
  	  o_pre = i[O_W-1:0];
    else
  	  o_pre = {i[I_W-1],{O_W-1{~i[I_W-1]}}};
  end

  always @(*)
  begin
    if(o_pre=={1'b1,{O_W-1{1'b0}}})
        o   =   {1'b1,{O_W-2{1'b0}},1'b1};
    else
        o   =   o_pre;
  end


  `ifdef RTL_SIM
  initial
    begin
      if(I_W <= O_W)
        begin
          $display("[ERROR/Error/error]-[hgw_sat_signed]-[time=%t]: I_W <= O_W", $time);
          $finish;
        end
    end
  `endif

endmodule
