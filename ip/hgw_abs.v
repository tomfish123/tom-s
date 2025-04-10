
module hgw_abs
(
  i,o
);

  parameter I_W = 16;
  
  input  signed [I_W-1:0]i;
  output [I_W-1:0]o;
  
  wire  [I_W:0]o_pre;

  assign o_pre = ({I_W{i[I_W-1]}} ^ i) + i[I_W-1];
  assign o     = o_pre[I_W-1:0];

  `ifdef RTL_SIM
    always @(*)
    begin
      if(i[I_W-1:0] == {1'b1, {I_W-1{1'b0}}})
        begin
          $display("[ERROR/Error/error]-[hgw_abs]-[time=%t]: input data is the negative minimum", $time);
          $finish;
        end
    end
  `endif

endmodule
