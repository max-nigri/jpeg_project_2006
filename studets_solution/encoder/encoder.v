module encoder
  #(parameter RAM_SIZE = 19200, ADDRESS_WIDTH = 16)
  (input rst,
   input clk_in,
   input shoot,
   input [159:0] file_name,
   input [1:0] factor_sel,
   input [63:0] date_string,
   input print_date,
   input pxq,
   input [7:0] d_in,
   input s_halt,
   output qual2flash,
   output [31:0] data2flash,
   output [3:0] be2flash,
   output [1:0] m_cmd,
   output m_halt,
   output eof2flash
);
   
   wire [31:0] line_width, pic_height;
   wire        parser_buf_dqual;
   wire [7:0] parser_buf_data;
   wire        dct_buf_rd;
   wire        buf_dct_valid;
   wire [7:0]  buf_dct_data;
   wire [23:0] buf_fp_data;
   wire        date_ovr_en;
   wire        zig_zag_wr_en;
   wire [5:0]  zig_zag_wr_addr;
   wire [11:0] quan_d_out;
   wire [11:0] zig_zag_rd_data;
   wire        zig_zag_rd_en;
   wire [5:0]  zig_zag_rd_addr;
   wire [32:0] huff_d_out;
   wire        huff_d_qual;

   wire        dct_and_quan_eof_out;
   wire        huffman_eof_out;
   wire        fwc_eof_out;

   wire        fifo_full;
   wire        fifo_rd;
   wire        fifo_empty;
   wire [32:0] fifo_rd_data;
   wire [31:0] flash_data;
   wire        flash_stop;
   wire [5:0]  max_not_zero_idx;
   
   parser parser (.clk_in (clk_in),
		  .rst (rst),
		  .pxq (pxq),
		  .d_in (d_in),
		  .print_date (print_date),
		  .date_string (date_string),
		  .line_width (line_width),
		  .pic_height (pic_height),
		  .dimensions_valid (dimensions_valid),
		  .d_qual (parser_buf_dqual),
		  .dout (parser_buf_data));

   buffer #(RAM_SIZE, ADDRESS_WIDTH) buff (.clk_in (clk_in),
					   .rst (rst),
					   .rd (dct_buf_rd),
					   .wr (parser_buf_dqual),
					   .wr_data (parser_buf_data),
					   .line_width (line_width),
					   .pic_height (pic_height),
					   .rd_data (buf_dct_data),
					   .valid (buf_dct_valid));

   dct_and_quantization dct_quan (.clk_in (clk_in),
				  .rst (rst),
				  .d_in (buf_dct_data),
				  .valid (buf_dct_valid),
				  .factor_sel (factor_sel),
				  .zig_zag_wr_addr (zig_zag_wr_addr),
				  .zig_zag_wr_en (zig_zag_wr_en),
				  .d_out (quan_d_out),
				  .rd (dct_buf_rd),
				  .eof(dct_and_quan_eof_out),
				  .max_not_zero_idx (max_not_zero_idx));

   zig_zag zig_zag (.clk_in (clk_in),
		    .rst (rst),
		    .zig_zag_rd_en (zig_zag_rd_en),
		    .zig_zag_wr_en (zig_zag_wr_en),
		    .d_in (quan_d_out),
		    .zig_zag_wr_addr (zig_zag_wr_addr),
		    .zig_zag_rd_addr (zig_zag_rd_addr),
		    .eof_in (dct_and_quan_eof_out),
		    .halt (zig_zag_halt),
		    .zig_zag_rd_data (zig_zag_rd_data),
		    .huffman_start (huff_start),
		    .eof_out (zig_zag_eof));

   huffman huff (.start (huff_start),		 
		 .clk_in (clk_in),		 
		 .rst (rst),
		 .zig_zag_halt (zig_zag_halt),
		 .fifo_full (fifo_full),
		 .ram_d_in (zig_zag_rd_data),
		 .max_not_zero_idx (max_not_zero_idx),
		 .ram_rd (zig_zag_rd_en),
		 .ram_addr (zig_zag_rd_addr),
		 .d_out (huff_d_out),
		 .d_qual (huff_d_qual),
		 .eof_in(zig_zag_eof),
		 .eof_out(huffman_eof_out));

      
   fifo #(512,9,33) huff_fifo (.clk (clk_in),
			       .rd (fifo_rd),
			       .wr (huff_d_qual),
			       .rst (rst), 
			       .wr_data (huff_d_out),
			       .full (fifo_full),
			       .empty (fifo_empty),
			       .rd_data (fifo_rd_data));
   
   flash_writer flash_wr (.clk_in (clk_in),
			  .rst (rst),
			  .start (shoot),
			  .s_halt (s_halt),
			  .line_width (line_width),
			  .pic_height (pic_height),
			  .dimensions_valid (dimensions_valid),
			  .file_name (file_name),
			  .factor_sel (factor_sel),
			  .fifo_rd_data (fifo_rd_data),
			  .fifo_empty (fifo_empty),
			  .eof_in (huffman_eof_out),
			  .m_cmd (m_cmd),
			  .write_data (data2flash),
			  .write_be (be2flash),
			  .d_qual (qual2flash),
			  .m_halt (m_halt),
			  .fifo_rd (fifo_rd),
			  .eof_out(eof2flash));
   
endmodule