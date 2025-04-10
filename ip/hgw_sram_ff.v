
module hgw_sram_ff
#(parameter D=128,
  parameter W=32,
  parameter RD_TYPE=0) //0=delay address by 1T;1=delay rdata
(
  input                 clk,
  input                 ce,   //high active
  input                 we,   //high active
  input  [$clog2(D)-1:0]addr,
  input  [W-1:0]        wdata,
  output [W-1:0]        rdata
);

`ifdef FPGA
  generate

    if ((D*W) > `BRAM_SIZE_TH) begin:block_ram

      (* ram_style="block" *)reg [W-1:0]mem[0:D-1]/*synthesis syn_ramstyle="block_ram" */;

      if (RD_TYPE==0)
      begin:U_type0

        reg [$clog2(D)-1:0]addr_d1;

        always @(posedge clk)
        begin
          if(we & ce)
            mem[addr] <= wdata;
        end        

        always @(posedge clk)
        begin
          if((!we) & ce)
            addr_d1 <= addr;
        end

        assign rdata = mem[addr_d1];
      end
      else 
      begin:U_type1

        reg [W-1:0]rdata_int;

        always @(posedge clk)
        begin
          if(we & ce)
            mem[addr] <= wdata;
        end   

        always @(posedge clk)
        begin
          if((!we) & ce)
            rdata_int <= mem[addr];
        end

        assign rdata = rdata_int;
      end

    end
    else begin:distributed_ram

      (* ram_style="distributed" *)reg [W-1:0]mem[0:D-1];

      if (RD_TYPE==0)
      begin:U_type0
        reg [$clog2(D)-1:0]addr_d1;

        always @(posedge clk)
        begin
          if(we & ce)
            mem[addr] <= wdata;
        end

        always @(posedge clk)
        begin
          if((!we) & ce)
            addr_d1 <= addr;
        end

        assign rdata = mem[addr_d1];
      end
      else 
      begin:U_type1

        reg [W-1:0]rdata_int;
        
        always @(posedge clk)
        begin
          if(we & ce)
            mem[addr] <= wdata;
        end
        
        always @(posedge clk)
        begin
          if((!we) & ce)
            rdata_int <= mem[addr];
        end

        assign rdata = rdata_int;
      end

    end

  endgenerate
`else 
  reg [W-1:0]mem[0:D-1];

  always @(posedge clk)
  begin
    if(we & ce)
      mem[addr] <= wdata;
  end

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

    reg [W-1:0]rdata_int;
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
