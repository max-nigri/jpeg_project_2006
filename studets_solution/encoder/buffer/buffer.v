module buffer
  #(parameter RAM_SIZE = 19200, ADDRESS_WIDTH = 16)
    (input clk_in,
    input rst,
    input rd,
    input wr,
    input [7:0] wr_data,
    input [31:0] line_width,
    input [31:0] pic_height,
    output [7:0] rd_data,
    output 	  valid
     );
   
   reg [15:0] 	  wr_addr, rd_addr, wr_addr_nxt, rd_addr_nxt;
   reg 		  ram_sel, ram_change;
   reg [2:0] 	  wr_line, nxt_wr_line;
   reg [12:0] 	  wr_block, nxt_wr_block;
   reg [2:0] 	  wr_shift, nxt_wr_shift;
   reg [1:0] 	  wr_ycbcr, nxt_wr_ycbcr;
   reg [31:0] 	  lines_left;
   reg 		  end_of_line;
   reg 		  valid_ff;
   reg [23:0] 	  extra_buf [1:0];
   reg 		  valid_nxt;		  
		  
   wire 	  ram0_cs, ram1_cs;
   wire [15:0] 	  ram0_add, ram1_add;
   wire [7:0] 	  ram0_rd_data, ram1_rd_data;
   wire [31:0] 	  nxt_lines_left;
   wire 	  cs_rd = rd | (valid & (~valid_ff));
   
   wire 	  last_block = (8*(wr_block+1)==line_width);

   wire 	  rd_from_buf = ((rd_addr==0) | (rd_addr==1)) & cs_rd;

   wire 	  extra_buf_write = (wr_addr_nxt<2) & wr;
   
   assign 	  ram0_cs = ram_sel? cs_rd : wr;
   assign 	  ram1_cs = ram_sel? wr : cs_rd;
   assign 	  ram0_add = ram_sel? rd_addr_nxt : wr_addr_nxt;
   assign 	  ram1_add = ram_sel? wr_addr_nxt : rd_addr_nxt;
   assign 	  rd_data =  rd_from_buf ? extra_buf[rd_addr[0]] : (ram_sel? ram0_rd_data : ram1_rd_data);
   
   ram #(RAM_SIZE, ADDRESS_WIDTH, 8) ram0 (.clk (clk_in), 
					   .rnw (ram_sel), 
					   .cs (ram0_cs), 
					   .add (ram0_add),
					   .wr_data (wr_data),
					   .rd_data (ram0_rd_data));
   
   ram #(RAM_SIZE, ADDRESS_WIDTH, 8) ram1 (.clk (clk_in), 
					   .rnw (!ram_sel), 
					   .cs (ram1_cs), 
					   .add (ram1_add),
					   .wr_data (wr_data),
					   .rd_data (ram1_rd_data));
   
   integer 	  i;
   
   always @(*) begin
      ram_change = 0;
      nxt_wr_block = wr_block;
      nxt_wr_shift = wr_shift;
      nxt_wr_line = wr_line;
      nxt_wr_ycbcr = wr_ycbcr;
      wr_addr_nxt = wr_addr;
      rd_addr_nxt = rd_addr;
      end_of_line = 0;
      valid_nxt = valid;
      
      if (wr) begin
	 nxt_wr_ycbcr = wr_ycbcr+1;
	 if (wr_ycbcr==2'd2) begin
	    nxt_wr_ycbcr = 0;
	    nxt_wr_shift = wr_shift+1;
	    if (wr_shift == 3'd7) begin
	       nxt_wr_shift = 0;
	       nxt_wr_block = wr_block+1;
	       if (last_block) begin
		  nxt_wr_block = 0;
		  nxt_wr_line = wr_line+1;
		  end_of_line = 1;
		  if (&wr_line)
		    ram_change = 1;
	       end
	    end
	 end
	 wr_addr_nxt = 192*wr_block + 64*wr_ycbcr + 8*wr_line + wr_shift;
      end
      if (rd & valid) begin
	 rd_addr_nxt = rd_addr+1;
	 if (rd_addr==(line_width*3*8 - 1))
	   valid_nxt = 0;
      end
   end
   
   always @(posedge clk_in or posedge rst)
     if (rst) begin
	wr_addr <= #1 0;
	rd_addr <= #1 0;
	ram_sel <= #1 0;
	wr_ycbcr <= #1 0;
	wr_shift <= #1 0;
	wr_block <= #1 0;
	wr_line <= #1 0;
	valid_ff <= #1 0;
	lines_left <= #1 0;
	for (i=0; i<2; i=i+1)
	  extra_buf[i] = 0;
     end
     else begin
	lines_left <= #1 nxt_lines_left;
	valid_ff <= #1 valid_nxt;
	if (rd & valid) begin
	   if (rd_addr == (line_width*3*8 - 1))
	     rd_addr <= #1 0;
	   else
	     rd_addr <= #1 rd_addr_nxt;
	end
	if ((wr_addr_nxt<2) & wr)
	  extra_buf[wr_addr_nxt[0]] = wr_data;	
	if (ram_change) begin
	   wr_addr <= #1 0;
	   ram_sel <= #1 !ram_sel;
	   wr_ycbcr <= #1 0;
	   wr_shift <= #1 0;
	   wr_block <= #1 0;
	   wr_line <= #1 0;
	end
	else begin
	   wr_addr <= #1 wr_addr_nxt;
	   if (wr) begin
	      wr_ycbcr <= #1 nxt_wr_ycbcr;
	      wr_shift <= #1 nxt_wr_shift;
	      wr_block <= #1 nxt_wr_block;
	      wr_line <= #1 nxt_wr_line;
	   end	   
	end
     end

   assign valid = (((&{wr_line,wr_shift}) & last_block & (wr_ycbcr==1)) | valid_ff);
   assign nxt_lines_left = (~(|lines_left)& wr) ? pic_height : (lines_left - end_of_line);
   
endmodule