module dct (
    input         clk_in, rst, valid_d_in,
    input [7:0]   d_in,
    output 	  rd,
    output  	  valid_d_out,
    output [23:0] d_out,
    output  	  eof
);

   wire [23:0] 		  dct_rom_data;
   wire [23:0] 		  f_mac_res, g_mac_res;
   wire [23:0] 		  g_ram0_rd_data, g_ram1_rd_data;
   wire [23:0] 		  mac_a;
   wire 		  g_ram_0_rnw, g_ram_1_rnw;
   wire 		  g_ram0_cs, g_ram1_cs;
   wire [5:0] 		  g_ram0_add, g_ram1_add;
   
   wire [23:0] 		  f_mac_acc, g_mac_acc;
   wire [23:0] 		  f_mac_b, g_mac_b;
   wire [23:0] 		  g_ram_wr_data;
   
   wire 		  rom_rd;
   wire [5:0] 		  rom_add;

   wire [23:0] 		  d_in_fp;
   
   int2fp i2fp (.d_in (d_in),
		.d_out (d_in_fp));
   
   dct_ctrl ctrl(.clk_in(clk_in),
		 .rst(rst),
		 .valid_d_in(valid_d_in),
		 .d_in(d_in_fp),
		 .dct_rom_data(dct_rom_data),
		 .f_mac_res(f_mac_res), 
		 .g_mac_res(g_mac_res),
		 .g_ram0_rd_data(g_ram0_rd_data),
		 .g_ram1_rd_data(g_ram1_rd_data),
		 .rd(rd),
		 .valid_d_out(valid_d_out),
		 .d_out(d_out),
		 .mac_a(mac_a),
		 .eof(eof),
		 .g_ram_0_rnw(g_ram_0_rnw),
		 .g_ram_1_rnw(g_ram_1_rnw),
		 .g_ram0_cs(g_ram0_cs), 
		 .g_ram1_cs(g_ram1_cs),
		 .g_ram0_add(g_ram0_add), 
		 .g_ram1_add(g_ram1_add),
		 .f_mac_acc(f_mac_acc),
		 .g_mac_acc(g_mac_acc),
		 .f_mac_b(f_mac_b), 
		 .g_mac_b(g_mac_b),
		 .g_ram_wr_data(g_ram_wr_data),
		 .rom_rd(rom_rd),
		 .rom_add(rom_add));
   
   
    
   fp_mac f_mac(.a(mac_a),
                .b(f_mac_b),
                .acc(f_mac_acc),
                .out(f_mac_res));
   
   fp_mac g_mac(.a(mac_a),
                .b(g_mac_b),
                .acc(g_mac_acc),
                .out(g_mac_res));
   
   
   ram #(64, 6, 24) g_ram0(.clk (clk_in),
			   .rnw (g_ram_0_rnw),
			   .cs (g_ram0_cs),
			   .add (g_ram0_add),
			   .wr_data (g_ram_wr_data),
			   .rd_data (g_ram0_rd_data));
   
   ram #(64, 6, 24) g_ram1(.clk (clk_in),
			   .rnw (g_ram_1_rnw),
			   .cs (g_ram1_cs),
			   .add (g_ram1_add),
			   .wr_data (g_ram_wr_data),
			   .rd_data (g_ram1_rd_data));
   
   
   rom #("roms/dct.rom", 64, 6, 24) dct_rom (.clk (clk_in),
					     .address (rom_add),
					     .read_en (rom_rd),
					     .data (dct_rom_data));

endmodule

