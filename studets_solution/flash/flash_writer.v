module flash_writer (
    input clk_in, rst,
    input start,
    input s_halt,
    input [31:0] line_width, pic_height,
    input 	 dimensions_valid,
    input [159:0] file_name,
    input [1:0]   factor_sel,
    input [32:0]  fifo_rd_data,
    input 	  fifo_empty,
    input 	  eof_in,
    output [1:0]  m_cmd,
    output [31:0] write_data,
    output [3:0]  write_be,
    output 	  d_qual,
    output 	  m_halt,
    output 	  fifo_rd,
    output 	  eof_out
   );

   wire [6:0] 	  dht_addr;
   wire [4:0] 	  dqt_addr;
   wire [31:0] 	  dht_data, dqt_data;
   wire 	  header_d_qual;
   wire [31:0] 	  header_write_data;
   wire [3:0] 	  header_write_be;
   
   header_writer_control header_wr_ctrl (.clk_in (clk_in),
					 .rst (rst),
					 .start (start),
					 .s_halt (s_halt),
					 .line_width (line_width),
					 .pic_height (pic_height),
					 .dimensions_valid (dimensions_valid),
					 .file_name (file_name),
					 .factor_sel (factor_sel),		     
					 .header_dqt_data (dqt_data),
					 .header_dht_data (dht_data),
					 .m_cmd (m_cmd),
					 .header_dqt_addr (dqt_addr),
					 .header_dqt_rd (dqt_rd),
					 .header_dht_addr (dht_addr),
					 .header_dht_rd (dht_rd),		     
					 .write_data (header_write_data),
					 .write_be (header_write_be),
					 .d_qual (header_d_qual));

   rom #("roms/header_dqt.rom", 32, 5, 32) dqt_rom (.clk (clk_in),
						    .address (dqt_addr),
						    .read_en (dqt_rd),
						    .data (dqt_data));
   
   rom #("roms/header_dht.rom", 104, 7, 32) dht_rom (.clk (clk_in),
						     .address (dht_addr),
						     .read_en (dht_rd),
						     .data (dht_data));

   wire 	  flash_stop;
   wire 	  header_writing = |header_write_be;
   wire 	  data_writer_halt = s_halt | header_writing;   
   wire [31:0] 	  data_write_data;
   wire [3:0] 	  data_write_be;
   
   data_writer_control data_wr_ctrl (.clk_in (clk_in),
				     .rst (rst),
				     .fifo_empty (fifo_empty),
				     .halt (data_writer_halt),
				     .eof_in (eof_in),
				     .stream_in (fifo_rd_data[32:5]),
				     .stream_in_size (fifo_rd_data[4:0]),
				     .flash_data (data_write_data),
				     .flash_stop (flash_stop),
				     .fifo_rd (fifo_rd),
				     .eof_out (eof_out),
				     .byte_en_mask (data_write_be));
   
   assign 	  write_data = header_writing ? header_write_data : data_write_data;
   assign 	  write_be = header_writing ? header_write_be : data_write_be;
   assign 	  m_halt = header_writing ? 1'b0 : flash_stop;
   assign 	  d_qual = header_writing ? header_d_qual : 0;

endmodule