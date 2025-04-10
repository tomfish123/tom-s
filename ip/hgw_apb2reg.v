module hgw_apb2reg
#(
  parameter  BW = 16,
  parameter  DELAY = 0
)(   
//APB interface  
  input  wire   [BW-1:0]     paddr     ,
  input  wire                psel      ,
  input  wire                penable   ,
  input  wire                pwrite    ,
  input  wire   [32-1:0]     pwdata    ,
  output wire                pready    ,
  output wire   [32-1:0]     prdata    ,
  output wire                pslverr   ,
//Regsiter interface
  output wire                o_wen     ,
  output wire                o_ren     ,
  output wire   [BW-1:0]     o_waddr   ,
  output wire   [BW-1:0]     o_raddr   ,
  output wire   [32-1:0]     o_wdata   ,
  input  wire   [32-1:0]     i_rdata   
);

//registers write and read enable
assign o_wen = psel & penable & pwrite;

generate
  if(DELAY == 0) begin : u
    assign o_ren = psel & penable &(~pwrite);
  end
  else begin : u
    assign o_ren = psel & !penable &(~pwrite);
  end  
endgenerate
//registers write and read address
assign o_waddr = paddr;
assign o_raddr = paddr;
//APB write to register.
assign o_wdata = pwdata;
//APB read from register.
assign prdata = i_rdata;

assign pready = 1'b1;
assign pslverr = 1'b0;

endmodule
