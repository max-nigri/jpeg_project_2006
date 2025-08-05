module parser(input clk_in,
	      input rst,
	      input pxq,
	      input [7:0] d_in,
	      input print_date,
	      input [63:0] date_string,
	      output [31:0] line_width,
	      output [31:0] pic_height,
	      output dimensions_valid,
	      output d_qual,
	      output [7:0] dout
);

   wire 		  parser_rgb_valid;
   wire 		  x_low, x_high, y_low, y_high;
   wire 		  date_ovr_en;
   wire [7:0] 		  rgb_muxed;
   wire [23:0] 		  rgb_fp ,mac_mult, mac_acc, mac_out;
   wire [23:0] 		  dout_fp;
   
   imager_parser parser (.rst (rst),
			 .clk_in (clk_in),
			 .pxq (pxq),
			 .d_in (d_in),
			 .rgb_valid (parser_rgb_valid),
			 .line_width (line_width),
			 .pic_height (pic_height),
			 .dimensions_valid (dimensions_valid));
   
   date_writer date_wr (.clk_in (clk_in),
			.rst (rst),
			.print_date (print_date),
			.line_width (line_width),
			.pic_height (pic_height),
			.date_string (date_string),
			.rgb_valid (parser_rgb_valid),
			.date_ovr_en (date_ovr_en));
   
   rgb2ycbcr rgb2ycbcr(.rst (rst),
		       .clk_in (clk_in),
		       .d_in (d_in),
		       .rgb_valid (parser_rgb_valid),
		       .date_ovr_en (date_ovr_en),
		       .mac_out (mac_out),
		       .rgb_muxed (rgb_muxed),
		       .mac_mult (mac_mult),
		       .mac_acc (mac_acc),
		       .d_qual (d_qual),
		       .dout (dout_fp));

   uint2fp ui2fp (.d_in(rgb_muxed),
		  .d_out(rgb_fp));
   
   fp_mac mac (.a (rgb_fp),
	       .b (mac_mult),
	       .acc (mac_acc),
	       .out (mac_out));

   fp2int #(8) fp2i (.d_in (dout_fp),
		     .d_out (dout));
   
endmodule