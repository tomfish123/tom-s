//////////////////////////////////////////////////////////////////////////////////
// Description:
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps

module pdec_lazy_copy#(
  parameter                         WID_K         = 8  ,
  parameter                         NUM_K         = 164, 
  parameter                         NUM_PTR       = 9   //512->9,4096->12 
  )(

  input   wire                      clk                , 
  input   wire                      rst_n              , 
  //----for copy llr and us
  input  wire                       pdec_st            ,
  input  wire[3:0]                  cur_stage          ,
  
  input  wire[3*8-1:0]              old_idx            ,
  input  wire[8-1:0]                lazy_copy_en       ,//for copy llr and us pointer ig ctrl2uph_uph_st
  input  wire[NUM_PTR-1:0]          llr_copy_ind       ,//indicate if this stage need copy
  input  wire[NUM_PTR-1:0]          us_copy_ind        ,//indicate if this stage need copy
  input  wire[8-1:0]                llr_updt_en        ,//LLR have been update into mem,and then record its pointer
  input  wire[8-1:0]                us_updt_en         ,//us have been update into mem,and then record its pointer

  //----for copy dcrc
  input  wire                       leaf_mode          ,
  input  wire[8-1:0]                bit_st             ,//include path valid info 
  input  wire[8-1:0]                bit_en             ,//include path valid info,only when leaf_mode == 1
  input  wire[8-1:0]                dec_bit           ,//hard bit 
  input  wire[2:0]                  dcrc_reg_ini       ,//dcrc register initial value
  input  wire[2:0]                  dcrc_info_ind      ,//indicate this hard bit need xor 
  output wire[3*8-1:0]              dcrc_reg           ,
  
  //----pdec_rd_ctrl interface
  output wire[NUM_PTR*3*8-1:0]      llr_ptr            , 
  output wire[NUM_PTR*3*8-1:0]      us_ptr             

);

//====================================================
//====         lazy copy
//====================================================
genvar              ii                 ; 
genvar              jj                 ;

wire[3-1:0]         old_idx_mem[7:0]   ;

wire[NUM_PTR*3-1:0] llr_ptr2copy0[7:0] ; 
wire[NUM_PTR*3-1:0] llr_ptr2copy1[7:0] ; 
wire[NUM_PTR*3-1:0] llr_ptr2copy2[7:0] ; 
wire[NUM_PTR*3-1:0] llr_ptr2copy3[7:0] ; 
wire[NUM_PTR*3-1:0] llr_ptr2copy4[7:0] ; 
wire[NUM_PTR*3-1:0] llr_ptr2copy5[7:0] ; 
wire[NUM_PTR*3-1:0] llr_ptr2copy6[7:0] ; 
wire[NUM_PTR*3-1:0] llr_ptr2copy7[7:0] ; 

wire[NUM_PTR*3-1:0] us_ptr2copy0[7:0]  ; 
wire[NUM_PTR*3-1:0] us_ptr2copy1[7:0]  ; 
wire[NUM_PTR*3-1:0] us_ptr2copy2[7:0]  ; 
wire[NUM_PTR*3-1:0] us_ptr2copy3[7:0]  ; 
wire[NUM_PTR*3-1:0] us_ptr2copy4[7:0]  ; 
wire[NUM_PTR*3-1:0] us_ptr2copy5[7:0]  ; 
wire[NUM_PTR*3-1:0] us_ptr2copy6[7:0]  ; 
wire[NUM_PTR*3-1:0] us_ptr2copy7[7:0]  ; 

reg [NUM_PTR*3-1:0] llr_ptr_mem[7:0]   ; 
reg [NUM_PTR*3-1:0] us_ptr_mem [7:0]   ; 
reg [3-1:0]         dcrc_reg_mem[7:0]  ; 

generate
  for(ii=0 ; ii<8 ; ii=ii+1)begin  : lazy_copy
    assign old_idx_mem[ii] = old_idx[(ii+1)*3-1:ii*3];
    //----lazy copy of llr
    for(jj=0 ; jj< NUM_PTR; jj=jj+1)begin  : copy_data_gen
      assign llr_ptr2copy0[ii][(jj+1)*3-1:jj*3] = llr_copy_ind[jj] ? llr_ptr_mem[0][(jj+1)*3-1:jj*3] : llr_ptr_mem[ii][(jj+1)*3-1:jj*3];
      assign llr_ptr2copy1[ii][(jj+1)*3-1:jj*3] = llr_copy_ind[jj] ? llr_ptr_mem[1][(jj+1)*3-1:jj*3] : llr_ptr_mem[ii][(jj+1)*3-1:jj*3];
      assign llr_ptr2copy2[ii][(jj+1)*3-1:jj*3] = llr_copy_ind[jj] ? llr_ptr_mem[2][(jj+1)*3-1:jj*3] : llr_ptr_mem[ii][(jj+1)*3-1:jj*3];
      assign llr_ptr2copy3[ii][(jj+1)*3-1:jj*3] = llr_copy_ind[jj] ? llr_ptr_mem[3][(jj+1)*3-1:jj*3] : llr_ptr_mem[ii][(jj+1)*3-1:jj*3];
      assign llr_ptr2copy4[ii][(jj+1)*3-1:jj*3] = llr_copy_ind[jj] ? llr_ptr_mem[4][(jj+1)*3-1:jj*3] : llr_ptr_mem[ii][(jj+1)*3-1:jj*3];
      assign llr_ptr2copy5[ii][(jj+1)*3-1:jj*3] = llr_copy_ind[jj] ? llr_ptr_mem[5][(jj+1)*3-1:jj*3] : llr_ptr_mem[ii][(jj+1)*3-1:jj*3];
      assign llr_ptr2copy6[ii][(jj+1)*3-1:jj*3] = llr_copy_ind[jj] ? llr_ptr_mem[6][(jj+1)*3-1:jj*3] : llr_ptr_mem[ii][(jj+1)*3-1:jj*3];
      assign llr_ptr2copy7[ii][(jj+1)*3-1:jj*3] = llr_copy_ind[jj] ? llr_ptr_mem[7][(jj+1)*3-1:jj*3] : llr_ptr_mem[ii][(jj+1)*3-1:jj*3];
    
      assign us_ptr2copy0[ii][(jj+1)*3-1:jj*3] = us_copy_ind[jj] ? us_ptr_mem[0][(jj+1)*3-1:jj*3] : us_ptr_mem[ii][(jj+1)*3-1:jj*3];
      assign us_ptr2copy1[ii][(jj+1)*3-1:jj*3] = us_copy_ind[jj] ? us_ptr_mem[1][(jj+1)*3-1:jj*3] : us_ptr_mem[ii][(jj+1)*3-1:jj*3];
      assign us_ptr2copy2[ii][(jj+1)*3-1:jj*3] = us_copy_ind[jj] ? us_ptr_mem[2][(jj+1)*3-1:jj*3] : us_ptr_mem[ii][(jj+1)*3-1:jj*3];
      assign us_ptr2copy3[ii][(jj+1)*3-1:jj*3] = us_copy_ind[jj] ? us_ptr_mem[3][(jj+1)*3-1:jj*3] : us_ptr_mem[ii][(jj+1)*3-1:jj*3];
      assign us_ptr2copy4[ii][(jj+1)*3-1:jj*3] = us_copy_ind[jj] ? us_ptr_mem[4][(jj+1)*3-1:jj*3] : us_ptr_mem[ii][(jj+1)*3-1:jj*3];
      assign us_ptr2copy5[ii][(jj+1)*3-1:jj*3] = us_copy_ind[jj] ? us_ptr_mem[5][(jj+1)*3-1:jj*3] : us_ptr_mem[ii][(jj+1)*3-1:jj*3];
      assign us_ptr2copy6[ii][(jj+1)*3-1:jj*3] = us_copy_ind[jj] ? us_ptr_mem[6][(jj+1)*3-1:jj*3] : us_ptr_mem[ii][(jj+1)*3-1:jj*3];
      assign us_ptr2copy7[ii][(jj+1)*3-1:jj*3] = us_copy_ind[jj] ? us_ptr_mem[7][(jj+1)*3-1:jj*3] : us_ptr_mem[ii][(jj+1)*3-1:jj*3];
    end
    
    always @(posedge clk or negedge rst_n)begin
      if(!rst_n)
        llr_ptr_mem[ii] <= {NUM_PTR*3{1'b0}};
      else if(llr_updt_en[ii])begin
        case(cur_stage)
          4'd0    : llr_ptr_mem[ii][3*1 -1:3*0 ] <= ii[2:0];
          4'd1    : llr_ptr_mem[ii][3*2 -1:3*1 ] <= ii[2:0];
          4'd2    : llr_ptr_mem[ii][3*3 -1:3*2 ] <= ii[2:0];
          4'd3    : llr_ptr_mem[ii][3*4 -1:3*3 ] <= ii[2:0];
          4'd4    : llr_ptr_mem[ii][3*5 -1:3*4 ] <= ii[2:0];
          4'd5    : llr_ptr_mem[ii][3*6 -1:3*5 ] <= ii[2:0];
          4'd6    : llr_ptr_mem[ii][3*7 -1:3*6 ] <= ii[2:0];
          4'd7    : llr_ptr_mem[ii][3*8 -1:3*7 ] <= ii[2:0];
          4'd8    : llr_ptr_mem[ii][3*9 -1:3*8 ] <= ii[2:0];
          `ifdef PDEC_BD
          4'd9    : llr_ptr_mem[ii][3*10-1:3*9 ] <= ii[2:0];
          4'd10   : llr_ptr_mem[ii][3*11-1:3*10] <= ii[2:0];
          4'd11   : llr_ptr_mem[ii][3*12-1:3*11] <= ii[2:0];
          `endif
          default : llr_ptr_mem[ii][3*1 -1:3*0 ] <= ii[2:0];
        endcase    
      end
      else if(lazy_copy_en[ii])begin
        case(old_idx_mem[ii])
          3'd0    : llr_ptr_mem[ii] <= llr_ptr2copy0[ii] ;
          3'd1    : llr_ptr_mem[ii] <= llr_ptr2copy1[ii];
          3'd2    : llr_ptr_mem[ii] <= llr_ptr2copy2[ii];
          3'd3    : llr_ptr_mem[ii] <= llr_ptr2copy3[ii];
          3'd4    : llr_ptr_mem[ii] <= llr_ptr2copy4[ii];
          3'd5    : llr_ptr_mem[ii] <= llr_ptr2copy5[ii];
          3'd6    : llr_ptr_mem[ii] <= llr_ptr2copy6[ii];
          3'd7    : llr_ptr_mem[ii] <= llr_ptr2copy7[ii];
          default : llr_ptr_mem[ii] <= llr_ptr2copy0[ii]; 
        endcase
      end
    end
    
    //----lazy copy of us
    always @(posedge clk or negedge rst_n)begin
      if(!rst_n)
        us_ptr_mem[ii] <= {NUM_PTR*3{1'b0}};
      else if(us_updt_en[ii])begin
        case(cur_stage)
          4'd0    : us_ptr_mem[ii][3*1 -1:3*0 ] <= ii[2:0];
          4'd1    : us_ptr_mem[ii][3*2 -1:3*1 ] <= ii[2:0];
          4'd2    : us_ptr_mem[ii][3*3 -1:3*2 ] <= ii[2:0];
          4'd3    : us_ptr_mem[ii][3*4 -1:3*3 ] <= ii[2:0];
          4'd4    : us_ptr_mem[ii][3*5 -1:3*4 ] <= ii[2:0];
          4'd5    : us_ptr_mem[ii][3*6 -1:3*5 ] <= ii[2:0];
          4'd6    : us_ptr_mem[ii][3*7 -1:3*6 ] <= ii[2:0];
          4'd7    : us_ptr_mem[ii][3*8 -1:3*7 ] <= ii[2:0];
          4'd8    : us_ptr_mem[ii][3*9 -1:3*8 ] <= ii[2:0];
          `ifdef PDEC_BD
          4'd9    : us_ptr_mem[ii][3*10-1:3*9 ] <= ii[2:0];
          4'd10   : us_ptr_mem[ii][3*11-1:3*10] <= ii[2:0];
          4'd11   : us_ptr_mem[ii][3*12-1:3*11] <= ii[2:0];
          `endif
          default : us_ptr_mem[ii][3*1 -1:3*0 ] <= ii[2:0];
        endcase    
      end
      else if(lazy_copy_en[ii])begin
        case(old_idx_mem[ii])
          3'd0    : us_ptr_mem[ii] <= us_ptr2copy0[ii];
          3'd1    : us_ptr_mem[ii] <= us_ptr2copy1[ii];
          3'd2    : us_ptr_mem[ii] <= us_ptr2copy2[ii];
          3'd3    : us_ptr_mem[ii] <= us_ptr2copy3[ii];
          3'd4    : us_ptr_mem[ii] <= us_ptr2copy4[ii];
          3'd5    : us_ptr_mem[ii] <= us_ptr2copy5[ii];
          3'd6    : us_ptr_mem[ii] <= us_ptr2copy6[ii];
          3'd7    : us_ptr_mem[ii] <= us_ptr2copy7[ii];
          default : us_ptr_mem[ii] <= us_ptr2copy0[ii]; 
        endcase
      end
    end 

    //----dcrc_reg
    always @(posedge clk or negedge rst_n)begin
      if(!rst_n)
        dcrc_reg_mem[ii] <= 3'd0;
      else if(pdec_st)  
        dcrc_reg_mem[ii] <= dcrc_reg_ini;
      else if(bit_st[ii] && leaf_mode)begin //only copy
        case(old_idx_mem[ii])
          3'd0    : dcrc_reg_mem[ii] <= dcrc_reg_mem[0];
          3'd1    : dcrc_reg_mem[ii] <= dcrc_reg_mem[1];
          3'd2    : dcrc_reg_mem[ii] <= dcrc_reg_mem[2];
          3'd3    : dcrc_reg_mem[ii] <= dcrc_reg_mem[3];
          3'd4    : dcrc_reg_mem[ii] <= dcrc_reg_mem[4];
          3'd5    : dcrc_reg_mem[ii] <= dcrc_reg_mem[5];
          3'd6    : dcrc_reg_mem[ii] <= dcrc_reg_mem[6];
          3'd7    : dcrc_reg_mem[ii] <= dcrc_reg_mem[7];
          default : dcrc_reg_mem[ii] <= dcrc_reg_mem[0]; 
        endcase  
      end
      else if(bit_st[ii] && (!leaf_mode))begin //copy and check
        case(old_idx_mem[ii])
          3'd0    : dcrc_reg_mem[ii] <= {dcrc_info_ind[2] ? (dcrc_reg_mem[0][2]^dec_bit[ii]) : dcrc_reg_mem[0][2],   
                                         dcrc_info_ind[1] ? (dcrc_reg_mem[0][1]^dec_bit[ii]) : dcrc_reg_mem[0][1],   
                                         dcrc_info_ind[0] ? (dcrc_reg_mem[0][0]^dec_bit[ii]) : dcrc_reg_mem[0][0]};
          3'd1    : dcrc_reg_mem[ii] <= {dcrc_info_ind[2] ? (dcrc_reg_mem[1][2]^dec_bit[ii]) : dcrc_reg_mem[1][2],   
                                         dcrc_info_ind[1] ? (dcrc_reg_mem[1][1]^dec_bit[ii]) : dcrc_reg_mem[1][1],   
                                         dcrc_info_ind[0] ? (dcrc_reg_mem[1][0]^dec_bit[ii]) : dcrc_reg_mem[1][0]};
          3'd2    : dcrc_reg_mem[ii] <= {dcrc_info_ind[2] ? (dcrc_reg_mem[2][2]^dec_bit[ii]) : dcrc_reg_mem[2][2],   
                                         dcrc_info_ind[1] ? (dcrc_reg_mem[2][1]^dec_bit[ii]) : dcrc_reg_mem[2][1],   
                                         dcrc_info_ind[0] ? (dcrc_reg_mem[2][0]^dec_bit[ii]) : dcrc_reg_mem[2][0]};
          3'd3    : dcrc_reg_mem[ii] <= {dcrc_info_ind[2] ? (dcrc_reg_mem[3][2]^dec_bit[ii]) : dcrc_reg_mem[3][2],   
                                         dcrc_info_ind[1] ? (dcrc_reg_mem[3][1]^dec_bit[ii]) : dcrc_reg_mem[3][1],   
                                         dcrc_info_ind[0] ? (dcrc_reg_mem[3][0]^dec_bit[ii]) : dcrc_reg_mem[3][0]};
          3'd4    : dcrc_reg_mem[ii] <= {dcrc_info_ind[2] ? (dcrc_reg_mem[4][2]^dec_bit[ii]) : dcrc_reg_mem[4][2],   
                                         dcrc_info_ind[1] ? (dcrc_reg_mem[4][1]^dec_bit[ii]) : dcrc_reg_mem[4][1],   
                                         dcrc_info_ind[0] ? (dcrc_reg_mem[4][0]^dec_bit[ii]) : dcrc_reg_mem[4][0]};
          3'd5    : dcrc_reg_mem[ii] <= {dcrc_info_ind[2] ? (dcrc_reg_mem[5][2]^dec_bit[ii]) : dcrc_reg_mem[5][2],   
                                         dcrc_info_ind[1] ? (dcrc_reg_mem[5][1]^dec_bit[ii]) : dcrc_reg_mem[5][1],   
                                         dcrc_info_ind[0] ? (dcrc_reg_mem[5][0]^dec_bit[ii]) : dcrc_reg_mem[5][0]};
          3'd6    : dcrc_reg_mem[ii] <= {dcrc_info_ind[2] ? (dcrc_reg_mem[6][2]^dec_bit[ii]) : dcrc_reg_mem[6][2],   
                                         dcrc_info_ind[1] ? (dcrc_reg_mem[6][1]^dec_bit[ii]) : dcrc_reg_mem[6][1],   
                                         dcrc_info_ind[0] ? (dcrc_reg_mem[6][0]^dec_bit[ii]) : dcrc_reg_mem[6][0]};
          3'd7    : dcrc_reg_mem[ii] <= {dcrc_info_ind[2] ? (dcrc_reg_mem[7][2]^dec_bit[ii]) : dcrc_reg_mem[7][2],   
                                         dcrc_info_ind[1] ? (dcrc_reg_mem[7][1]^dec_bit[ii]) : dcrc_reg_mem[7][1],   
                                         dcrc_info_ind[0] ? (dcrc_reg_mem[7][0]^dec_bit[ii]) : dcrc_reg_mem[7][0]};
          default : dcrc_reg_mem[ii] <= {dcrc_info_ind[2] ? (dcrc_reg_mem[0][2]^dec_bit[ii]) : dcrc_reg_mem[0][2],   
                                         dcrc_info_ind[1] ? (dcrc_reg_mem[0][1]^dec_bit[ii]) : dcrc_reg_mem[0][1],   
                                         dcrc_info_ind[0] ? (dcrc_reg_mem[0][0]^dec_bit[ii]) : dcrc_reg_mem[0][0]};
        endcase
      end
      else if(bit_en[ii]) //only check
        dcrc_reg_mem[ii] <= {dcrc_info_ind[2] ? (dcrc_reg_mem[ii][2]^dec_bit[ii]) : dcrc_reg_mem[ii][2],   
                             dcrc_info_ind[1] ? (dcrc_reg_mem[ii][1]^dec_bit[ii]) : dcrc_reg_mem[ii][1],   
                             dcrc_info_ind[0] ? (dcrc_reg_mem[ii][0]^dec_bit[ii]) : dcrc_reg_mem[ii][0]};
    end      
    
    //----output 
    assign llr_ptr[(ii+1)*(NUM_PTR*3)-1:ii*(NUM_PTR*3)] = llr_ptr_mem[ii] ; 
    assign us_ptr[(ii+1)*(NUM_PTR*3)-1:ii*(NUM_PTR*3)]  = us_ptr_mem[ii]  ; 
    assign dcrc_reg[(ii+1)*3-1:ii*3]                    = dcrc_reg_mem[ii]; 

  end
endgenerate 

endmodule
//Local Variables:
//verilog-library-flags:("-y ./ -y dir -y otherdir -y ./inc_dir/")
//verilog-auto-inst-param-value:t
//End:

