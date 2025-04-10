//////////////////////////////////////////////////////////////////////////////////
// Description:
// CRC polynomial coefficients: x^24 + x^23 + x^6 + x^5 + x + 1
//                              0xC60001 (hex)
// CRC width:                   24 bits
// CRC shift direction:         right (little endian)
// Input word width:            1 bits

// CRC polynomial coefficients: x^24 + x^23 + x^21 + x^20 + x^17 + x^15 + x^13 + x^12 + x^8 + x^4 + x^2 + x + 1
//                              0xE88D4D (hex)
// CRC width:                   24 bits
// CRC shift direction:         right (little endian)
// Input word width:            1 bits
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps

module pdec_crc_24c
(
  input  wire [0:0 ]  dat_in ,
  input  wire [23:0]  crc_in ,
  output wire [23:0]  crc_out
);
assign crc_out[0] = crc_in[0] ^ crc_in[1] ^ dat_in[0];
assign crc_out[1] = crc_in[2];
assign crc_out[2] = crc_in[0] ^ crc_in[3] ^ dat_in[0];
assign crc_out[3] = crc_in[0] ^ crc_in[4] ^ dat_in[0];
assign crc_out[4] = crc_in[5];
assign crc_out[5] = crc_in[6];
assign crc_out[6] = crc_in[0] ^ crc_in[7] ^ dat_in[0];
assign crc_out[7] = crc_in[8];
assign crc_out[8] = crc_in[0] ^ crc_in[9] ^ dat_in[0];
assign crc_out[9] = crc_in[10];
assign crc_out[10] = crc_in[0] ^ crc_in[11] ^ dat_in[0];
assign crc_out[11] = crc_in[0] ^ crc_in[12] ^ dat_in[0];
assign crc_out[12] = crc_in[13];
assign crc_out[13] = crc_in[14];
assign crc_out[14] = crc_in[15];
assign crc_out[15] = crc_in[0] ^ crc_in[16] ^ dat_in[0];
assign crc_out[16] = crc_in[17];
assign crc_out[17] = crc_in[18];
assign crc_out[18] = crc_in[19];
assign crc_out[19] = crc_in[0] ^ crc_in[20] ^ dat_in[0];
assign crc_out[20] = crc_in[21];
assign crc_out[21] = crc_in[0] ^ crc_in[22] ^ dat_in[0];
assign crc_out[22] = crc_in[0] ^ crc_in[23] ^ dat_in[0];
assign crc_out[23] = crc_in[0] ^ dat_in[0];

endmodule
//Local Variables:
//verilog-library-flags:("-y ./ -y dir -y otherdir -y ./inc_dir/")
//verilog-auto-inst-param-value:t
//End:

