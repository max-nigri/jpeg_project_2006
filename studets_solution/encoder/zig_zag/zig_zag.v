module zig_zag(
    input clk_in, rst,
    input zig_zag_rd_en, zig_zag_wr_en,
    input [11:0] d_in,
    input [5:0]  zig_zag_wr_addr,
    input [5:0]  zig_zag_rd_addr,
    input 	 eof_in,
    output 	 halt,
    output [11:0] zig_zag_rd_data,
    output 	  huffman_start,
    output 	  eof_out	       
);

   wire 	      wr_en_delay;
   wire [11:0] 	      wr_data_delay;
   wire [5:0] 	      wr_addr_delay;
   

   zig_zag_delay zig_zag_d (.clk_in (clk_in),
			    .rst (rst),
			    .zig_zag_wr_en (zig_zag_wr_en),
			    .zig_zag_wr_addr (zig_zag_wr_addr),
			    .wr_data (d_in),
			    .eof_in (eof_in),
			    .wr_en_out (wr_en_delay),
			    .wr_addr_out (wr_addr_delay),
			    .wr_data_out (wr_data_delay),
			    .huffman_start (huffman_start),
			    .eof_out (eof_out));
   
   wire [5:0]  zig_zag_addr = zig_zag_rd_en ? zig_zag_rd_addr : wr_addr_delay;
   
   ram #(64, 6, 12) zig_zag_ram(.clk (clk_in),
				.rnw (zig_zag_rd_en),
				.cs (zig_zag_rd_en|wr_en_delay),
				.add (zig_zag_addr),
				.wr_data (wr_data_delay),
				.rd_data (zig_zag_rd_data));

   assign      halt = wr_en_delay;
     
endmodule