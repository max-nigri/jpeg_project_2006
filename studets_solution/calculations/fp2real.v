module fp2real();

   reg clk;
   reg [31:0] file_fd;
   reg [5:0] rom_add;
   reg rom_rd;
   wire [23:0] dct_rom_out;

   integer     i;

   always @(clk) clk <= #10 ~clk;
   
   initial begin
      file_fd = $fopen("dct_values.log");
      rom_add = 0;
      rom_rd = 0;
      clk = 0;
      @(posedge clk);
      for (i=0; i<64; i=i+1) begin
	 rom_rd = 1;
	 rom_add = i;
	 @(posedge clk);
      end
      @(posedge clk);
      @(posedge clk);
      @(posedge clk);
      $fclose(file_fd);
      $stop;
   end

   reg rd_ff;
   
   always @(posedge clk) begin
      rd_ff <= #1 rom_rd;
      if (rd_ff)
	$fwrite(file_fd, "%.3f\n", v2r(dct_rom_out));
   end
   
   rom #("roms/dct.rom", 64, 6, 24) dct_rom (.clk (clk),
					     .address (rom_add),
					     .read_en (rom_rd),
					     .data (dct_rom_out));
   
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
   
endmodule