module dct_and_quantization (
    input clk_in,
    input rst,
    input [7:0] d_in,
    input 	valid,
    input [1:0] factor_sel,
    output [5:0] zig_zag_wr_addr,
    output 	 zig_zag_wr_en,
    output [11:0] d_out, 
    output 	  rd,
    output 	  eof,
    output [5:0]  max_not_zero_idx
);
   
   wire 			    dct_valid_data;
   wire [23:0] 			    dct_d_out;
   wire 			    eof_dct_out;
   
   dct dct(.clk_in (clk_in),
	   .rst (rst),
	   .valid_d_in (valid),
           .d_in (d_in),
           .rd (rd),
           .valid_d_out (dct_valid_data),
	   .d_out (dct_d_out),
	   .eof (eof_dct_out));

   quantization quan (.clk_in (clk_in),
		      .rst (rst),
		      .d_in (dct_d_out),
		      .valid_d_in (dct_valid_data),
		      .factor_sel (factor_sel),		     
		      .d_out (d_out),
		      .zig_zag_wr_addr (zig_zag_wr_addr),
		      .zig_zag_wr_en (zig_zag_wr_en),
		      .eof_in(eof_dct_out),
		      .eof_out(eof),
		      .max_not_zero_idx (max_not_zero_idx));
   
   
endmodule