module quantization_ctrl(
	 input clk_in, rst,
	 input valid_d_in,
	 input [1:0] factor_sel,
	 input [23:0] mult_out,
	 input [23:0] quan_rom_in,
	 input [5:0] zig_zag_rom_in,
	 input eof_in,
	 output reg [23:0] quan_val,
	 output [8:0] rom_addr,
	 output rom_rd,
	 output reg [11:0] d_out,
	 output reg [5:0] zig_zag_wr_addr,
	 output reg zig_zag_wr_en,
	 output reg eof_out,
	 output reg [5:0] max_not_zero_idx
);
  
   reg [5:0] 	nxt_addr, addr;
   reg [1:0] 	quan_state, quan_state_nxt;
   reg [1:0] 	ycbcr, ycbcr_nxt;
   reg [23:0] 	quan_val_nxt;
   reg [5:0] 	zig_zag_wr_addr_nxt;
   reg [11:0] 	nxt_d_out;
   reg 		nxt_zig_zag_wr_en;
   reg [5:0] 	max_not_zero_idx_nxt;
   
   wire [15:0] 	ma = mult_out[23:8];
   wire [7:0] 	exp = mult_out[7:0];
   
   wire [26:0] 	shifted_mult_out = exp[7] ? 0 :{ {11{ma[15]}}, ma} << exp;

   wire [11:0] 	mult_out_int = shifted_mult_out[26:15] + shifted_mult_out[14];
	  
   always @(*) begin
      nxt_addr = addr;
      ycbcr_nxt = ycbcr;
      quan_state_nxt = quan_state;
      quan_val_nxt = quan_val;
      zig_zag_wr_addr_nxt = zig_zag_wr_addr;
      nxt_d_out = d_out;
      nxt_zig_zag_wr_en = 0;
      
      case (quan_state)
	`QUAN_IDLE: begin
	   if (valid_d_in) begin
	      quan_state_nxt = `QUAN_WAIT;
	      nxt_addr = addr+1;
	      if (&addr)
		ycbcr_nxt = (&ycbcr) ? 2'b01 : (ycbcr + 1);
	   end
	end
	`QUAN_WAIT: begin
	   quan_val_nxt = quan_rom_in;
	   zig_zag_wr_addr_nxt = zig_zag_rom_in;
	   quan_state_nxt = `QUAN_CALC;
	end
	`QUAN_CALC: begin
	   nxt_d_out = mult_out_int;
	   nxt_zig_zag_wr_en = 1;
	   quan_state_nxt = `QUAN_IDLE;
	end
      endcase
   end

   always @(posedge clk_in or posedge rst)
     if (rst) begin
	quan_state <= #1 `QUAN_IDLE;
	addr <= #1 0;
	ycbcr <= #1 2'b01;
	quan_val <= #1 0;
	zig_zag_wr_addr <= #1 0;
	d_out <= #1 0;
	zig_zag_wr_en <= #1 0;
	eof_out <= #1 0;
	max_not_zero_idx_nxt <= #1 0;
	max_not_zero_idx <= #1 0;
     end
     else begin
	quan_state <= #1 quan_state_nxt;
	addr <= #1 nxt_addr;
	ycbcr <= #1 ycbcr_nxt;
	quan_val <= #1 quan_val_nxt;
	zig_zag_wr_addr <= #1 zig_zag_wr_addr_nxt;
	d_out <= #1 nxt_d_out;
	zig_zag_wr_en <= #1 nxt_zig_zag_wr_en;
	eof_out <= #1 eof_in;
	if (zig_zag_wr_en & (|d_out) & (zig_zag_wr_addr>max_not_zero_idx))
	  max_not_zero_idx_nxt <= #1 zig_zag_wr_addr;
	if ((&zig_zag_wr_addr) & zig_zag_wr_en)
	  max_not_zero_idx_nxt <= #1 0;
	max_not_zero_idx <= #1 max_not_zero_idx_nxt;
     end

   assign rom_rd = valid_d_in;
   assign rom_addr = {factor_sel, ycbcr[1], addr[2:0], addr[5:3]};
	
endmodule