//////////////////////////////////////////////////////////////////////////////////
// Description: saturature for the unsigned data
//////////////////////////////////////////////////////////////////////////////////

module hgw_sat_unsigned
(
  i,o
);

  parameter I_W = 16;
  parameter O_W = 15;
  
  input   [I_W - 1 : 0] i;
  output  [O_W - 1 : 0] o;
  
  wire sat = |(i[I_W-1:O_W]);
  
  assign o = i[O_W-1 : 0] | {O_W{sat}};

  `ifdef RTL_SIM
  initial
    begin
      if(I_W <= O_W)
        begin
          $display("[ERROR/Error/error]-[hgw_sat_unsigned]-[time=%t]: I_W <= O_W", $time);
          $finish;
        end
    end
  `endif

endmodule
