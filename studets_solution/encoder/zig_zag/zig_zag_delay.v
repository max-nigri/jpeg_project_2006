module zig_zag_delay (
    input clk_in, rst,
    input zig_zag_wr_en,
    input [5:0] zig_zag_wr_addr,
    input [11:0] wr_data,
    input 	 eof_in,
    output reg 	 wr_en_out,
    output reg [5:0] wr_addr_out,
    output reg [11:0] wr_data_out,
    output reg 	      huffman_start,
    output reg	      eof_out
);

   reg wr_en_d1, wr_en_d2;
   reg [5:0] wr_addr_d1, wr_addr_d2;
   reg [11:0] wr_data_d1, wr_data_d2;
   reg [3:0]  count;
   reg 	      eof_out_nxt;
   
   always @(posedge clk_in or posedge rst)
     if (rst) begin
	wr_en_d1 <= #1 0;
	wr_en_d2 <= #1 0;
	wr_addr_d1 <= #1 0;
	wr_addr_d2 <= #1 0;
	wr_addr_out <= #1 0;
	wr_data_d1 <= #1 0;
	wr_data_d2 <= #1 0;
	wr_data_out <= #1 0;
	count <= #1 0;
	eof_out_nxt <= #1 0;
	eof_out <= #1 0;
     end
     else begin
	if (zig_zag_wr_en | (&count[2:0])) begin
	   wr_en_d1 <= #1 zig_zag_wr_en;
	   wr_en_d2 <= #1 wr_en_d1;
	   wr_addr_d1 <= #1 zig_zag_wr_addr;
	   wr_addr_d2 <= #1 wr_addr_d1;
	   wr_addr_out <= #1 wr_addr_d2;
	   wr_data_d1 <= #1 wr_data;
	   wr_data_d2 <= #1 wr_data_d1;
	   wr_data_out <= #1 wr_data_d2;
	end

	wr_en_out = (wr_en_d2 & zig_zag_wr_en) | (&count[2:0]);
	huffman_start =   (&zig_zag_wr_addr) & zig_zag_wr_en;
	
	if (eof_in | (|count))
	  count <= #1 count+1;
	
	eof_out_nxt <= #1 (&count);
	eof_out <= #1 eof_out_nxt;
     end

   

endmodule
