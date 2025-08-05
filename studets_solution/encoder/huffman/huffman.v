module huffman(
    input start, clk_in, rst, zig_zag_halt, fifo_full, eof_in,
    input [11:0] ram_d_in,
    input [5:0]  max_not_zero_idx,
    output 	 ram_rd, eof_out,
    output [5:0] ram_addr,
    output [32:0] d_out,
    output 	  d_qual
);
   
   wire [7:0] 		    rom_add;
   wire 		    ac_lum_rd;
   wire [20:0] 		    ac_lum_rom_out;
   wire 		    dc_lum_rd;
   wire [12:0] 		    dc_lum_rom_out;
   wire 		    ac_chrom_rd;
   wire [20:0] 		    ac_chrom_rom_out;
   wire 		    dc_chrom_rd;
   wire [14:0] 		    dc_chrom_rom_out;


   rom #("roms/huffman_ac_lum.rom", 162, 8, 21) ac_lom_rom (.clk(clk_in),
							    .address (rom_add),
							    .read_en (ac_lum_rd),
							    .data (ac_lum_rom_out));
   
   rom #("roms/huffman_dc_lum.rom", 12, 4, 13) dc_lum_rom (.clk (clk_in),
							   .address (rom_add[3:0]),
							   .read_en (dc_lum_rd),
							   .data (dc_lum_rom_out));
   
   rom #("roms/huffman_ac_chrom.rom", 162, 8, 21) ac_chrom_rom (.clk (clk_in),
								.address (rom_add),
								.read_en (ac_chrom_rd),
								.data (ac_chrom_rom_out));
   
   rom #("roms/huffman_dc_chrom.rom", 12, 4, 15) dc_chrom_rom (.clk (clk_in),
							       .address (rom_add[3:0]),
							       .read_en (dc_chrom_rd),
							       .data (dc_chrom_rom_out));
   
   huffman_control control(.clk_in(clk_in),
			   .rst(rst),
			   .ac_chrom_rd(ac_chrom_rd),
			   .dc_chrom_rd(dc_chrom_rd),
			   .ac_lum_rd(ac_lum_rd),
			   .dc_lum_rd(dc_lum_rd),
			   .ac_chrom_rom_data(ac_chrom_rom_out),
			   .dc_chrom_rom_data(dc_chrom_rom_out),
			   .ac_lum_rom_data(ac_lum_rom_out),
			   .dc_lum_rom_data(dc_lum_rom_out),
			   .rom_addr(rom_add),
			   .d_out(d_out),
			   .d_qual(d_qual),
			   .start (start),
			   .zig_zag_halt (zig_zag_halt),
			   .fifo_full (fifo_full),
                           .ram_rd(ram_rd),
                           .ram_addr(ram_addr),
			   .ram_d_in(ram_d_in),
			   .max_not_zero_idx (max_not_zero_idx),
			   .eof_in(eof_in),
			   .eof_out(eof_out));

endmodule