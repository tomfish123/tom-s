//////////////////////////////////////////////////////////////////////////////////
// Description:
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps

module pdec_updt_us#(
  parameter                         NUM_US        = 256,//512->256,4096->2048
  parameter                         NUM_PTR       = 9   //512->9,4096->12
)(
  input   wire                      clk                , 
  input   wire                      rst_n              , 
  
  //----ICG
  output wire                       pdec_clk_en6        ,
  
  //----broadcast control signals
  input  wire[3:0]                  cur_stage          ,
  input  wire[3:0]                  cur_depth          ,
  input  wire[2:0]                  cur_jump_type      ,
  input  wire[2*8-1:0]              path_valid         , //3:invalid path,0:CK path,1:valid_path
  
  //----pdec_top_ctrl interface
  input  wire                       ctrl2uus_uus_st    ,
  output reg                        uus2ctrl_uus_done  ,

  //----pdec_updt_path interface
  input  wire[8*4-1:0]              uph2uus_hard_bit    , //repetion node : {bit0,3'd0}, stage2 node exclue repetion: {bit3,bit2,bit1,bit0} ,inclue frozen bit
  input  wire[NUM_PTR*3*8-1:0]      uph2uus_us_ptr      , 
  
  //----pdec_rd_ctrl interface
  output wire[NUM_US*8-1:0]         uus2rdc_us_data       

);
//====================================================
//====       us_unit
//====================================================
genvar              ii;
genvar              jj;
wire[7:0]           path_valid_mem;
wire[7:0]           us_updt_en;
wire[3:0]           hard_bit[7:0];
wire[NUM_PTR*3-1:0] us_ptr[7:0];
reg [NUM_US-1:0]    us_data[7:0];

wire[7:0]           s0_en      ;
wire                s0_in0[7:0];
wire                s0_in1[7:0];
wire[1:0]           s0_out[7:0];

wire[7:0]           s1_en      ;
wire[1:0]           s1_in0[7:0];
wire[1:0]           s1_in1[7:0];
wire[3:0]           s1_out[7:0];

wire[7:0]           s2_en      ;
wire[3:0]           s2_in0[7:0];
wire[3:0]           s2_in1[7:0];
wire[7:0]           s2_out[7:0];

wire[7:0]           s3_en      ;
wire[7:0]           s3_in0[7:0];
wire[7:0]           s3_in1[7:0];
wire[15:0]          s3_out[7:0];

wire[7:0]           s4_en      ;
wire[15:0]          s4_in0[7:0];
wire[15:0]          s4_in1[7:0];
wire[31:0]          s4_out[7:0];

wire[7:0]           s5_en      ;
wire[31:0]          s5_in0[7:0];
wire[31:0]          s5_in1[7:0];
wire[63:0]          s5_out[7:0];

wire[7:0]           s6_en      ;
wire[63:0]          s6_in0[7:0];
wire[63:0]          s6_in1[7:0];
wire[127:0]         s6_out[7:0];

wire[7:0]           s7_en      ;
wire[127:0]         s7_in0[7:0];
wire[127:0]         s7_in1[7:0];
wire[255:0]         s7_out[7:0];
`ifdef PDEC_BD
  reg [7:0]           us_updt_en_r;
  reg [255:0]         s7_out_r[7:0];
  
  wire[7:0]           s8_en      ;
  wire[255:0]         s8_in0[7:0];
  wire[255:0]         s8_in1[7:0];
  wire[511:0]         s8_out[7:0];
  
  wire[7:0]           s9_en      ;
  wire[511:0]         s9_in0[7:0];
  wire[511:0]         s9_in1[7:0];
  wire[1023:0]        s9_out[7:0];
  
  wire[7:0]           s10_en      ;
  wire[1023:0]        s10_in0[7:0];
  wire[1023:0]        s10_in1[7:0];
  wire[2047:0]        s10_out[7:0];
`endif
generate
  for(ii=0 ; ii<8 ; ii=ii+1)begin  : us_path_loop
    assign path_valid_mem[ii] = (~path_valid[ii*2+1]);//valid or CK 
    assign us_updt_en[ii]     = ctrl2uus_uus_st & path_valid_mem[ii];
    assign hard_bit[ii]       = cur_jump_type == 3'd0 ? 4'd0 : uph2uus_hard_bit[(ii+1)*4-1:ii*4];
    assign us_ptr[ii]         = uph2uus_us_ptr[(ii+1)*NUM_PTR*3-1:ii*NUM_PTR*3];
    
    //----stage0
    assign s0_en [ii] = us_updt_en[ii] & (cur_stage == 4'd0) & (cur_depth > 4'd0);
    assign s0_in0[ii] = s0_en[ii] ? us_data[us_ptr[ii][3*0 +: 3]][1] : 1'b0;
    assign s0_in1[ii] = s0_en[ii] ? hard_bit[ii][3] : 1'b0;
    pdec_us_unit #(.I_W(1)) U_us_stage0 (.in0(s0_in0[ii]),.in1(s0_in1[ii]),.out(s0_out[ii])); //depth == 1 : s0_out   
    
    //----stage1
    assign s1_en [ii] = us_updt_en[ii] & (cur_stage <= 4'd1) & (cur_depth > 4'd1);
    assign s1_in0[ii] = s1_en[ii] ? us_data[us_ptr[ii][3*1 +: 3]][3:2] : 2'd0;
    assign s1_in1[ii] = s1_en[ii] ? ((cur_stage == 4'd1) ? {2{hard_bit[ii][3]}} : s0_out[ii]) : 2'd0;
    pdec_us_unit #(.I_W(2)) U_us_stage1 (.in0(s1_in0[ii]),.in1(s1_in1[ii]),.out(s1_out[ii])); //depth == 2  : s1_out
    
    //----stage2
    assign s2_en [ii] = us_updt_en[ii] & (cur_stage <= 4'd2) & (cur_depth > 4'd2);
    assign s2_in0[ii] = s2_en[ii] ? us_data[us_ptr[ii][3*2 +: 3]][7:4] : 4'd0;
    assign s2_in1[ii] = s2_en[ii] ? ((cur_stage == 4'd2) ? ((cur_jump_type <= 3'd1) ? {4{hard_bit[ii][3]}} : hard_bit[ii][3:0]): s1_out[ii]) : 4'd0;
    pdec_us_unit #(.I_W(4)) U_us_stage2 (.in0(s2_in0[ii]),.in1(s2_in1[ii]),.out(s2_out[ii])); //depth == 3  : s2_out

    //----stage3
    assign s3_en [ii] = us_updt_en[ii] & (cur_stage <= 4'd3) & (cur_depth > 4'd3);
    assign s3_in0[ii] = s3_en[ii] ? us_data[us_ptr[ii][3*3 +: 3]][15:8] : 8'd0;
    assign s3_in1[ii] = s3_en[ii] ? ((cur_stage == 4'd3) ? {8{hard_bit[ii][3]}} : s2_out[ii]) : 8'd0;
    pdec_us_unit #(.I_W(8)) U_us_stage3 (.in0(s3_in0[ii]),.in1(s3_in1[ii]),.out(s3_out[ii])); //depth == 4  : s3_out

    //----stage4
    assign s4_en [ii] = us_updt_en[ii] & (cur_stage <= 4'd4) & (cur_depth > 4'd4);
    assign s4_in0[ii] = s4_en[ii] ? us_data[us_ptr[ii][3*4 +: 3]][31:16] : 16'd0;
    assign s4_in1[ii] = s4_en[ii] ? ((cur_stage == 4'd4) ? {16{hard_bit[ii][3]}} : s3_out[ii]) : 16'd0;
    pdec_us_unit #(.I_W(16)) U_us_stage4 (.in0(s4_in0[ii]),.in1(s4_in1[ii]),.out(s4_out[ii])); //depth == 5  : s4_out
    
    //----stage5
    assign s5_en [ii] = us_updt_en[ii] & (cur_stage <= 4'd5) & (cur_depth > 4'd5);
    assign s5_in0[ii] = s5_en[ii] ? us_data[us_ptr[ii][3*5 +: 3]][63:32] : 32'd0;
    assign s5_in1[ii] = s5_en[ii] ? ((cur_stage == 4'd5) ? {32{hard_bit[ii][3]}} : s4_out[ii]) : 32'd0;
    pdec_us_unit #(.I_W(32)) U_us_stage5 (.in0(s5_in0[ii]),.in1(s5_in1[ii]),.out(s5_out[ii])); //depth == 6  : s5_out

    //----stage6
    assign s6_en [ii] = us_updt_en[ii] & (cur_stage <= 4'd6) & (cur_depth > 4'd6);
    assign s6_in0[ii] = s6_en[ii] ? us_data[us_ptr[ii][3*6 +: 3]][127:64] : 64'd0;
    assign s6_in1[ii] = s6_en[ii] ? ((cur_stage == 4'd6) ? {64{hard_bit[ii][3]}} : s5_out[ii]) : 64'd0;
    pdec_us_unit #(.I_W(64)) U_us_stage6 (.in0(s6_in0[ii]),.in1(s6_in1[ii]),.out(s6_out[ii])); //depth == 7  : s6_out

    //----stage7
    assign s7_en [ii] = us_updt_en[ii] & (cur_stage <= 4'd7) & (cur_depth > 4'd7);
    assign s7_in0[ii] = s7_en[ii] ? us_data[us_ptr[ii][3*7 +: 3]][255:128] : 128'd0;
    assign s7_in1[ii] = s7_en[ii] ? ((cur_stage == 4'd7) ? {128{hard_bit[ii][3]}} : s6_out[ii]) : 128'd0;
    pdec_us_unit #(.I_W(128)) U_us_stage7 (.in0(s7_in0[ii]),.in1(s7_in1[ii]),.out(s7_out[ii])); //depth == 8  : s7_out

    `ifdef PDEC_BD
      //----delay 1 clk
      always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
          s7_out_r[ii]     <= 256'd0 ;
          us_updt_en_r[ii] <= 1'b0;
        end  
        else if(us_updt_en[ii])begin
          s7_out_r[ii]     <= s7_out[ii] ;
          us_updt_en_r[ii] <= 1'b1;
        end   
        else
          us_updt_en_r[ii] <= 1'b0;
      end    
      
      //----stage8
      assign s8_en [ii] = us_updt_en_r[ii] & (cur_stage <= 4'd8) & (cur_depth > 4'd8);
      assign s8_in0[ii] = s8_en[ii] ? us_data[us_ptr[ii][3*8 +: 3]][511:256] : 256'd0;
      assign s8_in1[ii] = s8_en[ii] ? ((cur_stage == 4'd8) ? {256{hard_bit[ii][3]}} : s7_out_r[ii]) : 256'd0;
      pdec_us_unit #(.I_W(256)) U_us_stage8 (.in0(s8_in0[ii]),.in1(s8_in1[ii]),.out(s8_out[ii])); //depth == 9  : s8_out
      
      //----stage9
      assign s9_en [ii] = us_updt_en_r[ii] & (cur_stage <= 4'd9) & (cur_depth > 4'd9);
      assign s9_in0[ii] = s9_en[ii] ? us_data[us_ptr[ii][3*9 +: 3]][1023:512] : 512'd0;
      assign s9_in1[ii] = s9_en[ii] ? ((cur_stage == 4'd9) ? {512{hard_bit[ii][3]}} : s8_out[ii]) : 512'd0;
      pdec_us_unit #(.I_W(512)) U_us_stage9 (.in0(s9_in0[ii]),.in1(s9_in1[ii]),.out(s9_out[ii])); //depth == 10  : s9_out
      
      //----stage10
      assign s10_en [ii] = us_updt_en_r[ii] & (cur_stage <= 4'd10) & (cur_depth > 4'd10);
      assign s10_in0[ii] = s10_en[ii] ? us_data[us_ptr[ii][3*10 +: 3]][2047:1024] : 1024'd0;
      assign s10_in1[ii] = s10_en[ii] ? ((cur_stage == 4'd10) ? {1024{hard_bit[ii][3]}} : s9_out[ii]) : 1024'd0;
      pdec_us_unit #(.I_W(1024)) U_us_stage10 (.in0(s10_in0[ii]),.in1(s10_in1[ii]),.out(s10_out[ii])); //depth == 11  : s10_out

      always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
          us_data[ii] <= {NUM_US{1'b0}} ;
        else if(us_updt_en[ii] && (cur_stage == cur_depth))begin
          case(cur_depth)
            4'd0  : us_data[ii][        1] <= {1   {hard_bit[ii][3]}};
            4'd1  : us_data[ii][3   :   2] <= {2   {hard_bit[ii][3]}};
            4'd2  : us_data[ii][7   :  4]  <= (cur_jump_type <= 3'd1) ? {4{hard_bit[ii][3]}} : hard_bit[ii][3:0];
            4'd3  : us_data[ii][15  :   8] <= {8{hard_bit[ii][3]}};
            4'd4  : us_data[ii][31  :  16] <= {16  {hard_bit[ii][3]}};
            4'd5  : us_data[ii][63  :  32] <= {32  {hard_bit[ii][3]}};
            4'd6  : us_data[ii][127 :  64] <= {64  {hard_bit[ii][3]}};
            4'd7  : us_data[ii][255 : 128] <= {128 {hard_bit[ii][3]}};
            4'd8  : us_data[ii][511 : 256] <= {256 {hard_bit[ii][3]}};
            4'd9  : us_data[ii][1023: 512] <= {512 {hard_bit[ii][3]}};
            4'd10 : us_data[ii][2047:1024] <= {1024{hard_bit[ii][3]}};
            4'd11 : us_data[ii][2047:   0] <= {2048{hard_bit[ii][3]}};
           default: us_data[ii]            <= us_data[ii];
          endcase
        end
        else if(us_updt_en[ii] && (cur_stage != cur_depth)) begin
          case(cur_depth)
            4'd1  : us_data[ii][3  :  2] <= s0_out[ii];
            4'd2  : us_data[ii][7  :  4] <= s1_out[ii];
            4'd3  : us_data[ii][15 :  8] <= s2_out[ii];
            4'd4  : us_data[ii][31 : 16] <= s3_out[ii];
            4'd5  : us_data[ii][63 : 32] <= s4_out[ii];
            4'd6  : us_data[ii][127: 64] <= s5_out[ii];
            4'd7  : us_data[ii][255:128] <= s6_out[ii];
            4'd8  : us_data[ii][511:256] <= s7_out[ii];
           default: us_data[ii]          <= us_data[ii];
          endcase
        end
        else if(us_updt_en_r[ii] && (cur_stage != cur_depth))begin
          case(cur_depth)
            4'd9  : us_data[ii][1023: 512] <= s8_out[ii];
            4'd10 : us_data[ii][2047:1024] <= s9_out[ii];
            4'd11 : us_data[ii][2047:   0] <= s10_out[ii];
           default: us_data[ii]            <= us_data[ii];
          endcase
        end
      end
    `else   
      always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
          us_data[ii] <= {NUM_US{1'b0}} ;
        else if(us_updt_en[ii])begin
          if(cur_stage == cur_depth)begin
            case(cur_depth)
              4'd0  : us_data[ii][      1] <= {  1{hard_bit[ii][3]}};
              4'd1  : us_data[ii][3  :  2] <= {  2{hard_bit[ii][3]}};
              4'd2  : us_data[ii][7  :  4] <= (cur_jump_type <= 3'd1) ? {4{hard_bit[ii][3]}} : hard_bit[ii][3:0];
              4'd3  : us_data[ii][15 :  8] <= {  8{hard_bit[ii][3]}};
              4'd4  : us_data[ii][31 : 16] <= { 16{hard_bit[ii][3]}};
              4'd5  : us_data[ii][63 : 32] <= { 32{hard_bit[ii][3]}};
              4'd6  : us_data[ii][127: 64] <= { 64{hard_bit[ii][3]}};
              4'd7  : us_data[ii][255:128] <= {128{hard_bit[ii][3]}};
              4'd8  : us_data[ii][255:  0] <= {256{hard_bit[ii][3]}};
             default: us_data[ii]          <= us_data[ii];
            endcase
          end
          else begin
            case(cur_depth)
              4'd1  : us_data[ii][3  :  2] <= s0_out[ii];
              4'd2  : us_data[ii][7  :  4] <= s1_out[ii];
              4'd3  : us_data[ii][15 :  8] <= s2_out[ii];
              4'd4  : us_data[ii][31 : 16] <= s3_out[ii];
              4'd5  : us_data[ii][63 : 32] <= s4_out[ii];
              4'd6  : us_data[ii][127: 64] <= s5_out[ii];
              4'd7  : us_data[ii][255:128] <= s6_out[ii];
              4'd8  : us_data[ii][255:  0] <= s7_out[ii];
             default: us_data[ii]          <= us_data[ii];
            endcase
          end
        end
      end
    `endif

    assign uus2rdc_us_data[(ii+1)*NUM_US-1:ii*NUM_US] = us_data[ii];

  end
endgenerate

`ifdef PDEC_BD
  always @(posedge clk or negedge rst_n)begin
    if(!rst_n)
      uus2ctrl_uus_done <= 1'b0 ;
    else if((|us_updt_en) && (cur_stage == cur_depth))
      uus2ctrl_uus_done <= 1'b1 ;
    else if((|us_updt_en) && (cur_stage != cur_depth) && (cur_depth <= 4'd8))
      uus2ctrl_uus_done <= 1'b1 ;
    else if((|us_updt_en_r) && (cur_stage != cur_depth) && (cur_depth > 4'd8))
      uus2ctrl_uus_done <= 1'b1 ;
    else
      uus2ctrl_uus_done <= 1'b0 ;
  end
`else
  always @(posedge clk or negedge rst_n)begin
    if(!rst_n)
      uus2ctrl_uus_done <= 1'b0 ;
    else
//      uus2ctrl_uus_done <= (|us_updt_en) ;
      uus2ctrl_uus_done <= ctrl2uus_uus_st ;
  end
`endif

//====================================================
//====       ICG
//====================================================
reg uus_proc;

always @(posedge clk or negedge rst_n)begin
  if(!rst_n)
    uus_proc <= 1'b0;
  else if(ctrl2uus_uus_st)  
    uus_proc <= 1'b1;
  else if(uus2ctrl_uus_done)  
    uus_proc <= 1'b0;
end    

assign pdec_clk_en6 = ctrl2uus_uus_st |
                      uus_proc        ;

endmodule
//Local Variables:
//verilog-library-flags:("-y ./ -y dir -y otherdir -y ./inc_dir/")
//verilog-auto-inst-param-value:t
//End:

