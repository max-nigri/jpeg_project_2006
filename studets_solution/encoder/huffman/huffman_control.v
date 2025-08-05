module huffman_control(
    input clk_in, rst, start, zig_zag_halt, fifo_full, eof_in,
    input [20:0] ac_chrom_rom_data,
    input [14:0] dc_chrom_rom_data,
    input [20:0] ac_lum_rom_data,
    input [12:0] dc_lum_rom_data,
    input [11:0] ram_d_in,
    input [5:0]  max_not_zero_idx,
		       
    output 	 ac_chrom_rd, dc_chrom_rd, 
    output reg 	 eof_out,
    output 	 ac_lum_rd, dc_lum_rd,
    output reg [7:0] rom_addr,
    output [32:0]    d_out,
    output 	     d_qual,
    output 	     ram_rd,
    output reg [5:0] ram_addr
);
 
   integer 				i;
   
   reg [1:0] 		      type, type_nxt;
   reg [3:0] 		      zeros_counter, next_zeros_counter;
   reg [11:0] 		      dc_diff;
   reg [11:0] 		      mask, junk;
   reg [11:0] 		      choped_ram_val, sign_bit_mask;
   reg [27:0] 		      stream_out_nxt;
   reg [4:0] 		      stream_out_size_nxt;
   reg [11:0] 		      prev_dc_value[2:0];
   reg [27:0] 		      stream_out;
   reg [4:0] 		      stream_out_size;   
   reg [1:0] 		      read_state, read_state_nxt;
   reg [1:0] 		      ram_wait_state, ram_wait_state_nxt;
   reg [1:0] 		      ram_sample_state, rom_sample_state;
   reg [1:0] 		      rom_wait_state, rom_wait_state_nxt;
   reg [11:0] 		      ram_in_data_ff, ram_in_data_ff_rom_wait;
   reg [11:0] 		      ram_in_data_ff_rom_sample;
   reg 			      rom_rd, start_ff;
   
   reg [3:0] 		      category_rom_wait, category_rom_sample;

   reg 			      eof_in_ff_nxt, eof_in_ff;
   reg 			      eof_out_nxt;
   reg [5:0] 		      max_not_zero_idx_ff;

   wire 		      halt = zig_zag_halt | fifo_full;
   
   assign 		      ac_chrom_rd = rom_rd & type[1] & (ram_sample_state != `HUFFMAN_DC_CALC);
   assign 		      dc_chrom_rd = rom_rd & type[1] & (ram_sample_state == `HUFFMAN_DC_CALC );
   assign 		      ac_lum_rd = rom_rd & ~type[1] & (ram_sample_state != `HUFFMAN_DC_CALC);
   assign 		      dc_lum_rd = rom_rd & ~type[1] & (ram_sample_state == `HUFFMAN_DC_CALC);

   assign 		      ram_rd = (start_ff | ((read_state != `HUFFMAN_IDLE) && (read_state != `HUFFMAN_PRO_CALC))) & (~halt);
   wire [7:0] 		      ram_addr_nxt = ram_addr + ram_rd;

   wire [20:0] 		      lum_rom_data = (rom_wait_state == `HUFFMAN_DC_CALC) ?
			      {1'b0, dc_lum_rom_data[12:9], 7'b0, dc_lum_rom_data[8:0]} : ac_lum_rom_data;

   wire [20:0] 		      chrom_rom_data = (rom_wait_state == `HUFFMAN_DC_CALC) ? {1'b0, dc_chrom_rom_data[14:11],5'b0,dc_chrom_rom_data[10:0]} : ac_chrom_rom_data;

   wire [20:0] 		      rom_data_in = type[1] ? chrom_rom_data : lum_rom_data;

   reg [4:0] 		      huffman_size;
   reg [15:0] 		      huffman_code;
   reg [11:0] 		      cat_d_in;
   wire [3:0] 		      category;
   
   category cat (.d_in (cat_d_in),
		 .category (category));
   
   always @(*) begin

      type_nxt = type;
      read_state_nxt = read_state;
      ram_wait_state_nxt = ram_wait_state;
      rom_wait_state_nxt = rom_wait_state;
      next_zeros_counter = zeros_counter;
      rom_wait_state_nxt = rom_wait_state;

      dc_diff = 0;
      mask = 0;
      junk = 0;
      choped_ram_val = 0;
      sign_bit_mask = 0;
      stream_out_nxt = 0;
      stream_out_size_nxt = 0;
      rom_addr = 0;
      rom_rd = 0;

      cat_d_in = 0;
	
      eof_out_nxt = 1'b0;
      
      eof_in_ff_nxt = eof_in_ff;      
      if (~eof_in_ff)
	eof_in_ff_nxt = eof_in;
      
      case (read_state)
	`HUFFMAN_IDLE: begin
           if (start_ff) begin
	      if (type==2'b11)
		type_nxt=2'b01;
	      else
		type_nxt=type+1;
	      read_state_nxt = `HUFFMAN_DC_CALC;
	      ram_wait_state_nxt = `HUFFMAN_DC_CALC;
	   end
	   else begin
	      ram_wait_state_nxt = `HUFFMAN_IDLE;
           end
	end
	`HUFFMAN_DC_CALC: begin
	   if (halt)
	     ram_wait_state_nxt = `HUFFMAN_IDLE;
	   else
	     if (max_not_zero_idx_ff==1) begin
		read_state_nxt = `HUFFMAN_PRO_CALC;
		ram_wait_state_nxt = `HUFFMAN_IDLE;
	     end
	     else begin
		read_state_nxt = `HUFFMAN_CALC;
		ram_wait_state_nxt = `HUFFMAN_CALC;
	     end	   
	end
	`HUFFMAN_CALC: begin
           if (halt)
	     ram_wait_state_nxt = `HUFFMAN_IDLE;
	   else begin	  
	      if (ram_addr==max_not_zero_idx_ff)
		read_state_nxt = `HUFFMAN_PRO_CALC;
	      else
		ram_wait_state_nxt = `HUFFMAN_CALC;
	   end
	end
	`HUFFMAN_PRO_CALC: begin
	   read_state_nxt = `HUFFMAN_IDLE;
           ram_wait_state_nxt = `HUFFMAN_PRO_CALC;
	end
      endcase

      case (ram_sample_state)
        `HUFFMAN_IDLE: begin
	   rom_wait_state_nxt = `HUFFMAN_IDLE;
        end
	`HUFFMAN_DC_CALC: begin
	   dc_diff = ram_in_data_ff - prev_dc_value[type-1];
	   cat_d_in = dc_diff;
           rom_wait_state_nxt = `HUFFMAN_DC_CALC;
           rom_addr = category;
	   rom_rd = 1;
	end
	`HUFFMAN_CALC: begin
	   if (~(|ram_in_data_ff)) begin
	      next_zeros_counter = zeros_counter + 1;
	      if (|next_zeros_counter)
	        rom_wait_state_nxt = `HUFFMAN_IDLE;
	      else begin
		 rom_wait_state_nxt = `HUFFMAN_CALC;
	         rom_rd = 1;
	      end
           end
	   else begin
	      next_zeros_counter = 0;
	      rom_rd = 1;
	      rom_wait_state_nxt = `HUFFMAN_CALC;
	      cat_d_in = ram_in_data_ff;
	   end
           rom_addr = 10*zeros_counter + category + (&zeros_counter);
	end
	`HUFFMAN_PRO_CALC: begin
	   if (|max_not_zero_idx_ff) begin
              next_zeros_counter = 0;
              rom_rd = 1;
	      rom_addr = 0;
              rom_wait_state_nxt = `HUFFMAN_PRO_CALC;
	   end
           else begin
              rom_wait_state_nxt = `HUFFMAN_IDLE;
	   end
	end
      endcase

      case (rom_sample_state)
        `HUFFMAN_DC_CALC, `HUFFMAN_CALC: begin
           {mask, junk} = 24'hfff<<(category_rom_sample);
	   stream_out_size_nxt = huffman_size + category_rom_sample;
	   stream_out_nxt = ({12'b0, huffman_code}<<category_rom_sample) | 
			    {12'b0, ((ram_in_data_ff_rom_sample - ram_in_data_ff_rom_sample[11]) & mask)};
        end
        `HUFFMAN_PRO_CALC: begin
	   stream_out_nxt = {12'b0, huffman_code};
	   stream_out_size_nxt = huffman_size;
	end
      endcase
      
      if (({read_state,ram_wait_state,ram_sample_state,rom_wait_state,rom_sample_state}==0) & eof_in_ff) begin
	 eof_out_nxt = 1'b1;
	 eof_in_ff_nxt = 1'b0;
      end
      
   end

   always @(posedge clk_in or posedge rst) begin
      if (rst) begin
	 read_state <= #1 `HUFFMAN_IDLE;
	 ram_wait_state <= #1 `HUFFMAN_IDLE;
	 ram_sample_state <= #1 `HUFFMAN_IDLE;
	 rom_wait_state <= #1 `HUFFMAN_IDLE;
	 rom_sample_state <= #1 `HUFFMAN_IDLE;
	 zeros_counter <= #1 0;
	 ram_addr <= #1 0;
	 huffman_size <= #1 0;
	 huffman_code <= #1 0;
	 start_ff <= #1 0;
	 type <= #1 2'b0;
	 for (i=0; i<3; i=i+1)
           prev_dc_value[i] <= #1 0;
	 ram_in_data_ff <= #1 0;
	 ram_in_data_ff_rom_wait <= #1 0;
	 ram_in_data_ff_rom_sample <= #1 0;
	 category_rom_wait <= #1 0;
	 category_rom_sample <= #1 0;
	 stream_out_size <= #1 0;
	 stream_out <= #1 0;
	 eof_in_ff <= #1 0;
	 eof_out_nxt <= #1 0;
	 eof_out <= #1 0;
	 max_not_zero_idx_ff <= #1 0;
      end
      else begin
	 read_state <= #1 read_state_nxt;
	 ram_wait_state <= #1 ram_wait_state_nxt;
	 ram_sample_state <= #1 ram_wait_state;
	 rom_wait_state <= #1 rom_wait_state_nxt;
	 rom_sample_state <= #1 rom_wait_state;
	 zeros_counter <= #1 next_zeros_counter;
	 ram_addr <= #1 start ? 0 : ram_addr_nxt;
	 huffman_size <= #1 rom_data_in[20:16];
	 huffman_code <= #1 rom_data_in[15:0];
	 type <= #1 type_nxt;
	 start_ff <= #1 start;	 
	 if (ram_wait_state!=`HUFFMAN_IDLE)
           ram_in_data_ff <= #1 ram_d_in;
	 else
           ram_in_data_ff <= #1 0;
	 if (ram_sample_state==`HUFFMAN_DC_CALC) begin
            ram_in_data_ff_rom_wait <= #1 dc_diff;
            prev_dc_value[type-1] <= #1 ram_in_data_ff;
	 end
	 else
           ram_in_data_ff_rom_wait <= #1 ram_in_data_ff;
	 ram_in_data_ff_rom_sample <= #1 ram_in_data_ff_rom_wait;
	 category_rom_wait <= #1 category;
	 category_rom_sample <= #1 category_rom_wait;
	 
	 stream_out_size <= #1 stream_out_size_nxt;
	 stream_out <= #1 stream_out_nxt;
	 
	 eof_in_ff <= #1 eof_in_ff_nxt;
	 eof_out <= #1 eof_out_nxt;	

	 if (start)
	   max_not_zero_idx_ff <= #1 max_not_zero_idx+1;
      
      end
   end

   assign d_out = {stream_out, stream_out_size};
   assign d_qual = |stream_out_size;
   
endmodule