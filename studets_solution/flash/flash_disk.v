module flash_disk(
     input rst,
     input clk_in,
     input [1:0] m_cmd,
     input d_qual,
     inout [31:0] d_inout,
     input [3:0] m_be,
     output [3:0] s_be,
     output err,
     input m_halt,
     output s_halt,
     input m_eof,
     output s_eof
);

   parameter LINES = 512;

   reg [31:0] file_buf [LINES-1:0];
   reg [2:0] state_ff, state_nxt;
   reg [159:0] file_name, file_name_nxt;
   reg 	      o_en;
   reg [31:0] d_out;
   wire [31:0] d_in;
   reg [2:0]  file_words, file_words_ff;
   reg [31:0] write_fd, write_fd_nxt;
   reg 	      write2file;
   reg 	      close_wr_file;
   reg [8:0]  halt_count;
   reg [4:0]  halt_width;
   
   always @(posedge clk_in or posedge rst)
     if (rst) begin
	state_ff <= #1 `FLASH_IDLE;
	file_words_ff <= #1 0;
	write_fd <= #1 0;
	file_name <= #1 0;
	halt_count <= #1 ($random) %512;
	halt_width <= #1 ($random) %32;
     end
     else begin
	state_ff <= #1 state_nxt;
	file_words_ff <= #1 file_words;
	write_fd <= #1 write_fd_nxt;
	file_name <= #1 file_name_nxt;
	if (halt_count == 0) begin
	   halt_count <= #1 ($random) %512 ;
	   halt_width <= #1 ($random) %32;
	end
	else
	  halt_count <= #1 halt_count - 1;
	if (write2file & (~m_halt) & (m_cmd!=`CMD_NOP)) begin
	   if (m_be[3])
	     $fwriteh(write_fd_nxt, d_in[31:24]);
	   if (m_be[2])
	     $fwriteh(write_fd_nxt, d_in[23:16]);
	   if (m_be[1])
	     $fwriteh(write_fd_nxt, d_in[15:8]);
	   if (m_be[0])
	     $fwriteh(write_fd_nxt, d_in[7:0]);
	   if (|m_be)
	     $fwrite(write_fd_nxt, "\n");
	end
	if (close_wr_file)
	  $fclose(write_fd);
     end

   assign d_inout = o_en ? d_out : 32'hzzzzzzzz;
   assign d_in = o_en ? 32'hzzzzzzzz : d_inout;	      
   assign s_halt = (halt_count <= halt_width);
   
   wire [31:0] mask = {{8{m_be[3]}}, {8{m_be[2]}}, {8{m_be[1]}}, {8{m_be[0]}}};
   
   always @(*) begin
      state_nxt = state_ff;
      o_en = 0;
      d_out = 0;
      file_words = file_words_ff;
      write_fd_nxt = write_fd;
      file_name_nxt = file_name;
      write2file = 0;
      close_wr_file = 0;

      if (~(m_halt|(m_cmd==`CMD_NOP))) begin
	 case (state_ff)
	   `FLASH_IDLE: begin
	      if (d_qual == 1) begin
		 file_name_nxt[31:0] = d_in & mask;
		 file_words = 1;
		 state_nxt = `FLASH_GET_FILE_NAME;
	      end
	   end
	   `FLASH_GET_FILE_NAME: begin
	      if ((d_qual == 1) ) begin
		 file_name_nxt[(32*file_words_ff)+:32] = d_in & mask;
		 file_words = file_words_ff+1;
		 state_nxt = `FLASH_GET_FILE_NAME;
	      end
	      else if (m_cmd == `CMD_READ) begin
		 $readmemh(file_name, file_buf);
		 state_nxt = `FLASH_READ;
	      end
	      else if (m_cmd == `CMD_WRITE) begin
		 write_fd_nxt = $fopen(file_name);
		 write2file = 1;
		 state_nxt = `FLASH_WRITE;
	      end
	   end
	   `FLASH_READ: begin
	   end
	   `FLASH_WRITE: begin	      
	      if (m_eof) begin
		 state_nxt = `FLASH_IDLE;
		 close_wr_file = 1;
	      end
	      else
		write2file = 1;
	   end
	 endcase
      end
   end
   
endmodule