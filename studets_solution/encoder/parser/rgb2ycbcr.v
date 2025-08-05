module rgb2ycbcr (
    input rst,
    input clk_in,
    input [7:0] d_in,
    input 	rgb_valid,
    input 	date_ovr_en,
    input [23:0] mac_out,		  
    output [7:0] rgb_muxed,
    output reg [23:0] mac_mult, mac_acc,
    output reg 	      d_qual,
    output reg [23:0] dout
);

// YCbCr (256 levels) can be computed directly from 8-bit RGB as follows:
//     Y = 0.299 R + 0.587 G + 0.114 B -128
//    Cb = - 0.1687 R - 0.3313 G + 0.5 B
//    Cr = 0.5 R - 0.4187 G - 0.0813 B
   
   parameter [23:0] DATE_RGB = 24'hffffff;
   
   reg [23:0] y_reg, cb_reg, cr_reg, y_nxt, cb_nxt, cr_nxt;
   reg [3:0]   state_ff, state_nxt;

   wire r_calc = (state_ff==`R0) | (state_ff==`R1) | (state_ff==`R2);
   wire g_calc = (state_ff==`G0) | (state_ff==`G1) | (state_ff==`G2);
   wire b_calc = (state_ff==`B0) | (state_ff==`B1) | (state_ff==`B2) | (state_ff==`B3);
   
   assign rgb_muxed = date_ovr_en ? (r_calc ? DATE_RGB[23:16] : 
				     (g_calc ? DATE_RGB[15:8] :
				      (b_calc ? DATE_RGB[7:0] : 8'h0))) : d_in;
   
   always @(*) begin
      state_nxt = state_ff;
      y_nxt = y_reg; 
      cb_nxt = cb_reg;
      cr_nxt = cr_reg;
      mac_mult = 0;
      mac_acc = 0;
      dout = 24'hxxxxxx;
      d_qual = 0;
      case (state_ff) 
	`R0: begin
	   if (rgb_valid) begin
	      mac_mult = `FP_0P299;
	      mac_acc = `FP_MINUS_128;
	      y_nxt = mac_out;
	      state_nxt = `R1;
	   end
	end
	`R1: begin
	   mac_mult = `FP_MINUS_0P1687;
	   cb_nxt = mac_out;
	   state_nxt = `R2;
	end
	`R2: begin
	   mac_mult = `FP_0P5;
	   cr_nxt = mac_out;
	   state_nxt = `G0;
	end
	`G0: begin
	   if (rgb_valid) begin
	      mac_mult = `FP_0P587;
	      mac_acc = y_reg;
	      y_nxt = mac_out;
	      state_nxt = `G1;
	   end
	end
	`G1: begin
	   mac_mult = `FP_MINUS_0P3313;
	   mac_acc = cb_reg;
	   cb_nxt = mac_out;
	   state_nxt = `G2;
	end
	`G2: begin
	   mac_mult = `FP_MINUS_0P4187;
	   mac_acc = cr_reg;
	   cr_nxt = mac_out;
	   state_nxt = `B0;
	end
	`B0: begin
	   if (rgb_valid) begin
	      mac_mult = `FP_0P114;
	      mac_acc = y_reg;
	      y_nxt = mac_out;
	      state_nxt = `B1;
	   end
	end
	`B1: begin
	   mac_mult = `FP_0P5;
	   mac_acc = cb_reg;
	   cb_nxt = mac_out;
	   dout = y_reg;
	   d_qual = 1;
	   state_nxt = `B2;
	end
	`B2: begin
	   mac_mult = `FP_MINUS_0P0813;
	   mac_acc = cr_reg;
	   cr_nxt = mac_out;
	   dout = cb_reg;
	   d_qual = 1;
	   state_nxt = `B3;
	end
	`B3: begin
	   dout = cr_reg;
	   d_qual = 1;
	   state_nxt = `R0;
	end
      endcase
   end
   
   always @(posedge clk_in or posedge rst)
     if (rst) begin
	state_ff <= #1 2'd0;
	y_reg <= #1 24'h0;
	cb_reg <= #1 24'h0;
	cr_reg <= #1 24'h0;
     end
     else begin
	state_ff <= #1 state_nxt;
	y_reg <= #1 y_nxt;
	cb_reg <= #1 cb_nxt;
	cr_reg <= #1 cr_nxt;
     end
   
endmodule
   