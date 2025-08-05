module imager_parser(
    input rst,
    input clk_in,
    input pxq,
    input [7:0] d_in,
    output reg 	rgb_valid,
    output [31:0] line_width, pic_height,
    output reg	      dimensions_valid
);

   parameter CLK_RATIO = 8;
   
   reg [2:0] parser_state_ff, parser_state_nxt, parser_state_nxt_ff;
   reg [31:0] x_low, x_low_nxt, x_high, x_high_nxt, y_low, y_low_nxt, y_high, y_high_nxt;
   reg [3:0] timer;
   reg [1:0] byte_sel;
   reg 	     nxt_byte_sel;
   
   always @(*) begin
      rgb_valid = 0;
      parser_state_nxt = parser_state_nxt_ff;
      x_low_nxt = x_low;
      x_high_nxt = x_high;
      y_low_nxt = y_low;
      y_high_nxt = y_high;
      nxt_byte_sel = 0;
      dimensions_valid = 0;
      if (pxq) begin
	 if (timer == 1) begin
	   case (parser_state_ff)
	     `X_LOW: begin
		nxt_byte_sel = 1;
		x_low_nxt[8*byte_sel+:8] = d_in;
		parser_state_nxt = (byte_sel==2'd3) ? `X_HIGH : `X_LOW;
	     end
	     `X_HIGH: begin
		nxt_byte_sel = 1;
		x_high_nxt[8*byte_sel+:8] = d_in;
		parser_state_nxt = (byte_sel==2'd3) ? `Y_LOW : `X_HIGH;
	     end
	     `Y_LOW: begin
		nxt_byte_sel = 1;
		y_low_nxt[8*byte_sel+:8] = d_in;
		parser_state_nxt = (byte_sel==2'd3) ? `Y_HIGH : `Y_LOW;
	     end
	     `Y_HIGH: begin
		nxt_byte_sel = 1;
		y_high_nxt[8*byte_sel+:8] = d_in;
		parser_state_nxt = (byte_sel==2'd3) ? `RGB : `Y_HIGH;
	     end
	     `RGB: begin
		rgb_valid = 1;
		dimensions_valid = 1;
		parser_state_nxt = `RGB;
	     end
	   endcase
	 end
      end
      else
	parser_state_nxt = `X_LOW;
   end
      
   always @(posedge clk_in  or posedge rst) begin
     if (rst) begin
	timer <= #1 0;
	parser_state_ff <= #1 0;
	parser_state_nxt_ff <= #1 0;
	x_low <= #1 0;
	x_high <= #1 0;
	y_low <= #1 0;
	y_high <= #1 0;
	byte_sel <= #1 0;
     end
     else begin
	timer <= #1 (timer == (CLK_RATIO-1)) ? 0 : timer+1;
	if (timer == 0)
	  parser_state_ff <= #1 parser_state_nxt_ff;
	else if (timer == 1) begin
	   parser_state_nxt_ff <= #1 parser_state_nxt;
	   x_low <= #1 x_low_nxt;
	   x_high <= #1 x_high_nxt;
	   y_low <= #1 y_low_nxt;
	   y_high <= #1 y_high_nxt;
	   if (nxt_byte_sel)
	     byte_sel <= #1 byte_sel+1;
	end
     end
   end // always @ (posedge clk_in  or posedge rst)

   assign line_width = (x_high - x_low);
   assign pic_height = (y_high - y_low);
   
endmodule		      