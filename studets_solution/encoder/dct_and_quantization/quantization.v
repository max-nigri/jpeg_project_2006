module quantization(
    input clk_in, rst,
    input [23:0] d_in,
    input 	 valid_d_in,
    input [1:0]  factor_sel,
    input 	 eof_in,
    output [11:0] d_out,
    output [5:0]  zig_zag_wr_addr,
    output 	  zig_zag_wr_en,
    output 	  eof_out,
    output [5:0] max_not_zero_idx   
);

   wire [8:0] 	rom_addr;
   wire 	rom_rd;
   wire [23:0] 	quan_rom_out;
   wire [5:0] zig_zag_rom_out;
   wire [23:0] 	quan_val;
   wire [23:0] 	mult_out;
   
   quantization_ctrl ctrl(.clk_in (clk_in),
			  .rst (rst),
			  .valid_d_in (valid_d_in),
			  .factor_sel (factor_sel),
			  .mult_out (mult_out),
			  .quan_rom_in (quan_rom_out),
			  .zig_zag_rom_in (zig_zag_rom_out),
			  .eof_in (eof_in),
			  .quan_val (quan_val),
			  .rom_addr (rom_addr),
			  .rom_rd (rom_rd),
			  .d_out (d_out),
			  .zig_zag_wr_addr (zig_zag_wr_addr),
			  .zig_zag_wr_en (zig_zag_wr_en),
			  .eof_out (eof_out),
			  .max_not_zero_idx (max_not_zero_idx));
   
   fp_mult quan_mult (.a (d_in),
		      .b (quan_val),
		      .o (mult_out),
		      .valid (),
		      .over_flow (),
		      .under_flow ());
   
   rom #("roms/quantization.rom", 512, 9, 24) quan_rom (.clk (clk_in),
							.address (rom_addr),
							.read_en (rom_rd),
							.data (quan_rom_out));
   
   rom #("roms/zig_zag.rom", 64, 6, 6) zig_zag_rom (.clk (clk_in),
						    .address (rom_addr[5:0]),
						    .read_en (rom_rd),
						    .data (zig_zag_rom_out));
   
`ifdef DBG
   reg [31:0] 	log_fd_in, log_fd_out;
   
   initial begin
      log_fd_in = $fopen("log/quantization_in.log");
      log_fd_out = $fopen("log/quantization_out.log");
   end

   reg [2:0] out_line, out_col, in_line, in_col;
   reg 	     eof_out_ff;
   
   always @(posedge clk_in or posedge rst)
     if (rst) begin
	out_line <= #1 0;
	out_col <= #1 0;
	in_line <= #1 0;
	in_col <= #1 0;
     end
     else begin
	if (valid_d_in) begin
	   in_col <= #1 in_col+1;
	   $fwrite(log_fd_in, "%.2f", v2r(d_in));
	   if (&in_col) begin
	      in_line <= #1 in_line+1;	      
	      $fwrite(log_fd_in, "\n");
	      if (&in_line)
		$fwrite(log_fd_in, "\n\/\/ new block at time %t:\n", $time);
	   end
	   else
	     $fwrite(log_fd_in, ", ");
	end
	if (zig_zag_wr_en) begin
	   out_col <= #1 out_col+1;
	   $fwrite(log_fd_out, "%d(%d)", d_out, zig_zag_wr_addr);
	   if (&out_col) begin
	      out_line <= #1 out_line+1;	      
	      $fwrite(log_fd_out, "\n");
	      if (&out_line)
		$fwrite(log_fd_out, "\n\/\/ new block at time %t:\n", $time);	   
	   end
	   else
	     $fwrite(log_fd_out, ", ");
	end
	eof_out_ff <= #1 eof_out;
	if (eof_in)
	  $fclose(log_fd_in);
	if (eof_out_ff)
	  $fclose(log_fd_out);
     end
   
   function real v2r;
      input [23:0] a;
      reg [15:0]   ma;
      reg [7:0]    ea;
      
      real 	   tmp;
      
      begin
	 {ma,ea} = a;
	 if (ma[15])
	   if (ea[7])
	     tmp = -((-ma)/power(-ea)/32768);
	   else
	     tmp = -((-ma)*power(ea)/32768);
	 else
	   if (ea[7])
	     tmp = (ma)/power(-ea)/32768;
	   else
	     tmp = (ma)*power(ea)/32768;
	 v2r = tmp;	 
      end
   endfunction
   
   function real power;
      input [7:0] ea;
      
      integer 	  i;
      begin
	 i = ea;
	 power = 1;
	 
	 while (i>0)
	   begin
	      power = 2 * power;
	      i=i-1;
	   end
      end
   endfunction
`endif
   
endmodule