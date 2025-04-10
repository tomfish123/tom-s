

module hgw_icg
#(parameter SW_EN_ASYNC = 1, //if 1, indicate sw_en is async signal
  parameter HW_EN_ASYNC = 0, //if 1, indicate hw_en is async signal
  parameter SYNC_NUM   =  2) //if async, async process level
(
  input  clk_i,
  input  rst_n,
  input  hw0_sw1_mode,
  input  hw_en,
  input  sw_en,
  input  ptest_icg_mode,
  output clk_gated
);
 
  wire hw0_sw1_mode_synced;
  wire sw_en_synced;
  generate 
    if (SW_EN_ASYNC==1) begin:U_sw_cdc_proc
      hgw_async_bus #(.DW(2), .SYNC_NUM(SYNC_NUM), .SCLK_P(20))
        U_async_sw_en_mode(
          .clk        (clk_i),
          .rst_n      (rst_n),
          .din        ({hw0_sw1_mode,sw_en}),
          .dout       ({hw0_sw1_mode_synced,sw_en_synced}));
    end
    else begin:U_bypass_sw_cdc_proc
      assign hw0_sw1_mode_synced = hw0_sw1_mode;
      assign sw_en_synced        = sw_en;
    end
   endgenerate

  wire hw_en_synced;
  generate 
    if (HW_EN_ASYNC==1) begin:U_hw_cdc_proc
      hgw_async_bus #(.DW(1), .SYNC_NUM(SYNC_NUM), .SCLK_P(20))
        U_async_hw_en (
          .clk        (clk_i),
          .rst_n      (rst_n),
          .din        (hw_en),
          .dout       (hw_en_synced));
    end
    else begin:U_bypass_hw_cdc_proc
      assign hw_en_synced        = hw_en;
    end
   endgenerate

  wire clk_en = hw0_sw1_mode_synced ? sw_en_synced : hw_en_synced;

  hgw_clk_gate U_clk_gate
  (
    .clk_i (clk_i),
    .en    (clk_en),
    .test  (ptest_icg_mode),
    .clk_o (clk_gated)
   );
endmodule
