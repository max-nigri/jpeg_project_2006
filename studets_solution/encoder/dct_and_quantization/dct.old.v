module dct (
    input clk_in, rst, valid_d_in,
    input [23:0] d_in,
    output 	 rd,
    output reg 	 valid_d_out,
    output reg [23:0] d_out,
    output reg 	      eof
);
    
   reg [23:0] 	   f_vector [7:0];
   reg [23:0] 	   f_vector_nxt [7:0];
   reg [2:0] 	   f_cell, f_cell_nxt;
   reg [2:0] 	   line, column,  idx; 
   reg [23:0] 	   f_mac_out_ff, g_mac_out_ff;
   reg [23:0] 	   g_ram_rd_data_ff;
   reg [23:0] 	   dct_rom_out_ff;
   reg 		   rd_en, wr_en;
   wire [5:0] 	   wr_add;
   reg [5:0] 	   rd_add;
   reg 		   g_ram_sel;
   reg [1:0] 	   read_state, read_state_nxt;
   reg 		   write_state, write_state_nxt;
   reg 		   nxt_read_f, read_f;
   reg 		   switch_rams, g_valid, g_valid_nxt;
   reg 		   nxt_valid_d_out;
   reg [23:0] 	   first3gValues[2:0], first3gValues_nxt[2:0];
   reg 		   eof_nxt, eof_nxt_nxt;
   
   wire 	   rom_rd;
   wire [2:0] 	   nxt_line, nxt_column, nxt_idx;
   wire [23:0] 	   f_mac_acc, g_mac_acc;
   wire [23:0] 	   f_mac_out, g_mac_out;
   wire [23:0] 	   g_ram_rd_data;
   wire [5:0] 	   rom_add;
   
   integer 	   i;
   
   assign 	   rd = read_f;
   
   
   always @(*) begin
      f_cell_nxt = f_cell;
      nxt_read_f = read_f;

      for (i=0; i<3; i=i+1)
	first3gValues_nxt[i] = first3gValues[i];
      
      for (i=0; i<8; i=i+1)
	f_vector_nxt[i] = f_vector[i];
      
      read_state_nxt = read_state;
      wr_en = 0;
      rd_en = 0;
      rd_add = 0;
      switch_rams = 0;
      g_valid_nxt = g_valid;
      
      write_state_nxt = write_state;
      nxt_valid_d_out = 0;

      eof_nxt_nxt = 0;
            
      if (read_f) begin
         f_vector_nxt[f_cell] = d_in;
         f_cell_nxt = f_cell+1;
         nxt_read_f = (|f_cell_nxt);
      end
      
      case (read_state)
        `DCT_IDLE: begin
           if (valid_d_in) begin
              nxt_read_f = 1;
	      read_state_nxt = `DCT_PRE_CALC;
           end
        end
        `DCT_PRE_CALC: begin
           read_state_nxt = `DCT_CALC;
        end
        `DCT_CALC: begin
	   g_valid_nxt = 1;
           if (~(|idx)) begin
	      wr_en = 1;
	      casex ({line,column})
		0: switch_rams = 1;
		1: first3gValues_nxt[0]=f_mac_out_ff;
		9: first3gValues_nxt[1]=f_mac_out_ff;
		17: first3gValues_nxt[2]=f_mac_out_ff;
	      endcase 
	   end
	   if ({column,idx}==6'b111_110)
	     nxt_read_f = 1;
	   if (&{line,column,idx} & ~valid_d_in) begin
              read_state_nxt = `DCT_PRO_CALC;
           end
        end
	`DCT_PRO_CALC: begin
           read_state_nxt = `DCT_IDLE;
           wr_en = 1;
           switch_rams = 1;
	   g_valid_nxt = 0;
	end
        
      endcase
      
      case (write_state)
        `DCT_IDLE: begin
	   if ((&{line,column,idx}) & g_valid)
	     write_state_nxt = `DCT_CALC;
	end
        `DCT_CALC: begin
	   rd_add = {idx+2, (line + (&{column,idx[2:1]}))};
	   rd_en = |{line,column,idx};
	   nxt_valid_d_out = &idx;
           if (&{line,column,idx} & (~g_valid)) begin 
	      write_state_nxt = `DCT_IDLE;
	      eof_nxt_nxt = 1'b1;
	   end
	end
      endcase
   end
   

   wire in_pre_calc = (read_state == `DCT_PRE_CALC);
   wire in_calc = ((read_state == `DCT_CALC)|
                   (write_state == `DCT_CALC));
   
   assign {nxt_line, nxt_column, nxt_idx} = ( {line, column, idx} +  in_calc );
   assign rom_add = ({column,idx} + (in_calc*2) + in_pre_calc);
   assign f_mac_acc = (idx==0) ? 0 : f_mac_out_ff; 
   assign g_mac_acc = (idx==0) ? 0 : g_mac_out_ff;
   
   wire [23:0] g_mac_b = ({line, column, idx}>2) ? g_ram_rd_data_ff : first3gValues[idx[1:0]];

   wire [23:0] dct_rom_out;
   
   fp_mac f_mac(.a(dct_rom_out_ff),
                .b(f_vector[idx]),
                .acc(f_mac_acc),
                .out(f_mac_out));

   fp_mac g_mac(.a(dct_rom_out_ff),
                .b(g_mac_b),
                .acc(g_mac_acc),
                .out(g_mac_out));
   
   wire [23:0] g_ram0_rd_data, g_ram1_rd_data;

   assign      wr_add = {line, column}-1;

   wire        g_ram0_cs = g_ram_sel ? rd_en : wr_en;
   wire        g_ram1_cs = g_ram_sel ? wr_en : rd_en;
   wire [5:0]  g_ram0_add = g_ram_sel ? rd_add : wr_add;
   wire [5:0]  g_ram1_add = g_ram_sel ? wr_add : rd_add;
   
   assign      g_ram_rd_data = g_ram_sel ? g_ram0_rd_data : g_ram1_rd_data;
   
   ram #(64, 6, 24) g_ram0(.clk (clk_in),
			   .rnw (g_ram_sel),
			   .cs (g_ram0_cs),
			   .add (g_ram0_add),
			   .wr_data (f_mac_out_ff),
			   .rd_data (g_ram0_rd_data));
   
   ram #(64, 6, 24) g_ram1(.clk (clk_in),
			   .rnw (!g_ram_sel),
			   .cs (g_ram1_cs),
			   .add (g_ram1_add),
			   .wr_data (f_mac_out_ff),
			   .rd_data (g_ram1_rd_data));

   assign      rom_rd = ((read_state != `IDLE) | (write_state != `IDLE) | valid_d_in);
   
   rom #("roms/dct.rom", 64, 6, 24) dct_rom (.clk (clk_in),
					     .address (rom_add),
					     .read_en (rom_rd),
					     .data (dct_rom_out));
   
   always @(posedge clk_in or posedge rst)
     if (rst) begin
	read_state <= #1 `DCT_IDLE;
	write_state <= #1 `DCT_IDLE;
	for (i=0; i<8; i=i+1)
	  f_vector[i] <= #1 0;
        f_cell <= #1 0;
	line <= #1 0;
	column <= #1 0;
	idx <= #1 0;
        read_f <= #1 0;
        f_mac_out_ff <= #1 0;
	g_mac_out_ff <= #1 0;
        g_ram_sel <= #1 0;
	g_valid <= #1 0;
        dct_rom_out_ff <= #1 0;
        d_out <= #1 0;
        valid_d_out <= #1 0;
        g_ram_rd_data_ff <= #1 0;
	eof_nxt <= #1 0;
	eof <= #1 0;
	for (i=0; i<3; i=i+1)
	  first3gValues[i] <= #1 0;
	
     end       
     else begin
	for (i=0; i<3; i=i+1)
	  first3gValues[i] <= #1 first3gValues_nxt[i];
	read_state <= #1 read_state_nxt;
	write_state <= #1 write_state_nxt;
	for (i=0; i<8; i=i+1)
	  f_vector[i] <= #1 f_vector_nxt[i];
        f_cell <= #1 f_cell_nxt;
	line <= #1 nxt_line;
	column <= #1 nxt_column;
	idx <= #1 nxt_idx;
        read_f <= #1 nxt_read_f;
	g_valid <= #1 g_valid_nxt;
        f_mac_out_ff <= #1 f_mac_out;
	g_mac_out_ff <= #1 g_mac_out;
        valid_d_out <= #1 nxt_valid_d_out;
	g_ram_rd_data_ff <= #1 g_ram_rd_data;
        dct_rom_out_ff <= #1 dct_rom_out;
	eof_nxt <= #1 eof_nxt_nxt;
	eof <= #1 eof_nxt;
	if (nxt_valid_d_out)
          d_out <= #1 g_mac_out;
        if (switch_rams)
          g_ram_sel <= #1 !g_ram_sel;     
     end

`ifdef DBG
   reg [31:0] log_fd_in, log_fd_out, log_fd_g;
       
   initial begin
      log_fd_in = $fopen("log/dct_in.log");
      log_fd_g = $fopen("log/dct_g_ram.log");
      log_fd_out = $fopen("log/dct_out.log");
   end

   reg [2:0] out_line, out_col, in_line, in_col;
   
   always @(posedge clk_in or posedge rst)
     if (rst) begin
	out_line <= #1 0;
	out_col <= #1 0;
	in_line <= #1 0;
	in_col <= #1 0;
     end
     else begin
	if (valid_d_out) begin
	   out_col <= #1 out_col+1;
	   $fwrite(log_fd_out, "%.2f", v2r(d_out));
	   if (&out_col) begin
	   out_line <= #1 out_line+1;	      
	      $fwrite(log_fd_out, "\n");
	      if (&out_line)
		$fwrite(log_fd_out, "\n\/\/ new block at time %t:\n", $time);	   
	   end
	   else
	     $fwrite(log_fd_out, ", ");
	end
	if (read_f) begin
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
	if (wr_en) begin
	   $fwrite(log_fd_g, "%.2f", v2r(f_mac_out_ff));
	   if ((wr_add%8)==7) begin
	      $fwrite(log_fd_g, "\n");
	      if (&wr_add)
		$fwrite(log_fd_g, "\n\/\/ new block at time %t:\n", $time);
	   end
	   else
	     $fwrite(log_fd_g, ", ");
	end
	if (eof) begin
	   $fclose(log_fd_out);
           $fclose(log_fd_in);
	   $fclose(log_fd_g);
	end
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

