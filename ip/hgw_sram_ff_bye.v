//////////////////////////////////////////////////////////////////////////////////
// Description:  sram which can be accessed in byte
//////////////////////////////////////////////////////////////////////////////////

module hgw_sram_ff_bye
#(parameter D=128,
  parameter W=4,       //in byte
  parameter RD_TYPE=0) //0=delay address by 1T;1=delay rdata
(
  input                 clk,
  input                 ce,   //high active
  input                 we,   //high active
  input  [W-1:0]        byte_en,   //high active
  input  [$clog2(D)-1:0]addr,
  input  [W*8-1:0]      wdata,
  output [W*8-1:0]      rdata
);

`ifdef FPGA
  genvar i;
  generate

    if ((D*W*8) > `BRAM_SIZE_TH) begin:block_ram

      (* ram_style="block" *)reg [W*8-1:0]mem[0:D-1]/*synthesis syn_ramstyle="block_ram" */;

      for (i=0; i<W; i=i+1)
      begin
        
          always @(posedge clk)
            begin
              if(we && ce && byte_en[i])
                mem[addr][i*8+7:i*8] <= wdata[i*8+7:i*8];
            end

      end

      reg [W*8-1:0]rdata_int;
      always @(posedge clk)
      begin
        if((!we) & ce)
          rdata_int <= mem[addr];
      end

      assign rdata = rdata_int;

    end
    else begin:distributed_ram

      (* ram_style="distributed" *)reg [W*8-1:0]mem[0:D-1];

      for (i=0; i<W; i=i+1)
      begin
        
          always @(posedge clk)
            begin
              if(we && ce && byte_en[i])
                mem[addr][i*8+7:i*8] <= wdata[i*8+7:i*8];
            end

      end

      reg [W*8-1:0]rdata_int;
      always @(posedge clk)
      begin
        if((!we) & ce)
          rdata_int <= mem[addr];
      end

      assign rdata = rdata_int;

    end
  endgenerate
`else //simulation
  reg [W*8-1:0]mem[0:D-1];

  genvar i;
  generate

      for (i=0; i<W; i=i+1)
      begin
        
        always @(posedge clk)
          begin
            if(we && ce && byte_en[i])
              mem[addr][i*8+7:i*8] <= wdata[i*8+7:i*8];
          end

      end

  endgenerate

  generate 
  if (RD_TYPE==0)
  begin:U_type0
    reg [$clog2(D)-1:0]addr_d1;

    always @(posedge clk)
    begin
      if((!we) & ce)
        addr_d1 <= addr;
    end

    assign rdata = mem[addr_d1];
  end
  else 
  begin:U_type1

    reg [W*8-1:0]rdata_int;
    always @(posedge clk)
    begin
      if((!we) & ce)
        rdata_int <= mem[addr];
    end

    assign rdata = rdata_int;
  end
  endgenerate

`endif

endmodule
