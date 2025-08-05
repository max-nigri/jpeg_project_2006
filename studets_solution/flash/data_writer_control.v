module data_writer_control (
    input clk_in, rst, fifo_empty, halt, eof_in,
    input [27:0] stream_in,
    input [4:0]  stream_in_size,
    output reg [31:0] flash_data,
    output 	      fifo_rd,
    output reg 	      flash_stop, eof_out,
    output [3:0]      byte_en_mask
);

   reg [1:0] 	      write_state;
   wire [1:0] 	      write_state_nxt;
   reg [1:0] 	      read_state, read_state_nxt;
   reg [1:0] 	      reader_advice_state;
   reg [5:0] 	      write_size, write_size_nxt;
   reg 		      data_not_writen, data_not_writen_nxt;
   reg [31:0] 	      flash_data_prev, sampeled_allign_d_out;
   reg [5:0] 	      size, size_nxt;
   reg [43:0] 	      buffer, buffer_nxt, buffer_nxt_calc;
   reg [5:0] 	      size_after_input;
   reg [59:0] 	      buffer_after_input;
   reg 		      eof_ff, eof_nxt;
   reg 		      get_next_data;
   
   reg [27:0] 	      d_in_ff [1:0];
   reg [4:0] 	      d_in_size_ff [1:0];
   reg [27:0] 	      d_in_nxt [1:0];
   reg [4:0] 	      d_in_size_nxt [1:0];
   reg [1:0] 	      d_in_valid_ff; 
   reg 		      cur_rd_ff, cur_wr_ff, cur_wr_nxt, fifo_rd_ff;
   
   assign 	      byte_en_mask = {write_size > 24,
				      write_size > 16,
				      write_size > 8,
				      write_size > 0};
   
   wire [3:0] 	      ffBytes = {(&buffer_after_input[59:52]) & (size_after_input>0),
				 (&buffer_after_input[51:44]) & (size_after_input>8),
				 (&buffer_after_input[43:36]) & (size_after_input>16),
				 (&buffer_after_input[35:28]) & (size_after_input>24)};
   
   wire [39:0] 	      mask0 = {buffer_after_input[59:52], 32'b0};
   wire [39:0] 	      mask1 = {8'b0, buffer_after_input[51:44], 24'b0} >> (ffBytes[3]*8);
   wire [39:0] 	      mask2 = {16'b0, buffer_after_input[43:36], 16'b0} >> ((ffBytes[3]+ffBytes[2])*8);
   wire [39:0] 	      mask3 = {24'b0, buffer_after_input[35:28], 8'b0} >> ((ffBytes[3]+ffBytes[2]+ffBytes[1])*8);
   wire [39:0] 	      mask4 = (|ffBytes) ? 40'b0 : {32'b0, buffer_after_input[27:20]};
   
   wire [39:0] 	      or_all_masks = mask0 | mask1 | mask2 | mask3 | mask4;
   
   wire [31:0] 	      allign_d_out = {or_all_masks[15:8],
				      or_all_masks[23:16],
				      or_all_masks[31:24],
				      or_all_masks[39:32]};

   wire [1:0] 	      additional_size = ((ffBytes[3]+ffBytes[2]+ffBytes[1]) -
					 (&ffBytes[3:1])+(ffBytes==4'b0001));

   wire [6:0] 	      total_size = size_after_input+ (8*additional_size);
   wire [5:0] 	      min_size = (total_size<32) ? total_size[5:0] : 32;
   wire 	      fw_write = (write_state==`FW_WRITE);

   wire 	      no_data_in_pipe = ~(|d_in_valid_ff);
   wire 	      flush_data = eof_ff & no_data_in_pipe & fifo_empty;

   wire [2:0] 	      padding_size = (|size[2:0]) ? 3'b0 : 8-size[2:0];
   wire [1:0] 	      d_in_valid_nxt;
   
   wire 	      cur_rd_nxt = get_next_data ? (~cur_rd_ff) : cur_rd_ff;
   assign 	      fifo_rd = ~fifo_empty & (no_data_in_pipe | get_next_data);
   assign 	      d_in_valid_nxt[0] = (~cur_wr_ff && fifo_rd) | (d_in_valid_ff[0] & (cur_rd_ff | ~get_next_data));
   assign 	      d_in_valid_nxt[1] = (cur_wr_ff && fifo_rd) | (d_in_valid_ff[1] & (~cur_rd_ff | ~get_next_data));
   
   always @(*) begin      
      get_next_data = 1'b0;
      buffer_nxt = buffer;
      size_nxt = size;
      write_size_nxt = write_size;
      
      size_after_input = size;
      buffer_after_input = {buffer,16'b0};

      reader_advice_state = `FW_IDLE;
      read_state_nxt = read_state;

      eof_out = 1'b0;
      cur_wr_nxt = cur_wr_ff;
      eof_nxt = eof_ff;
      
      if (~eof_ff)
	eof_nxt = eof_in;

      d_in_nxt[0] = d_in_ff[0];
      d_in_nxt[1] = d_in_ff[1];
      
      d_in_size_nxt[0] = d_in_size_ff[0];
      d_in_size_nxt[1] = d_in_size_ff[1];
      if (fifo_rd) begin
	 d_in_nxt[cur_wr_ff] = stream_in;
	 d_in_size_nxt[cur_wr_ff] = stream_in_size;
	 cur_wr_nxt = ~cur_wr_ff;
      end
      
      case (read_state)
	`FW_IDLE: begin
	   if (d_in_valid_ff[cur_rd_ff] | flush_data) begin
	      if (~flush_data) begin
		 size_after_input = size + d_in_size_ff[cur_rd_ff];
    		 buffer_after_input = {buffer, 16'b0} | ({32'b0, d_in_ff[cur_rd_ff]} << (60 - size_after_input));
	      end
	      else begin
		 size_after_input = size + padding_size;
		 buffer_after_input = {buffer, 16'b0} | ((60'd1<<(60-size))-1);
	      end
	      if ((size_after_input<32) & (~flush_data) ) begin
		 if (~data_not_writen_nxt) begin
		    size_nxt = size_after_input;
		    buffer_nxt = buffer_after_input[59:16];
		    reader_advice_state = `FW_IDLE;
		    get_next_data = 1'b1;
		 end
	      end
	      else begin
		 reader_advice_state = `FW_WRITE;
		 if (~data_not_writen_nxt) begin
		    if (~flush_data)
		      get_next_data = 1'b1;
		    size_nxt  = total_size - min_size;
		    write_size_nxt = min_size;
		    buffer_nxt = buffer_nxt_calc;
		    if (size_nxt>32)
		      read_state_nxt = `FW_MOD_CALC;
		    else
		      if (flush_data & size_nxt==0)
			read_state_nxt = `FW_EOF_WRITE;
		 end
	      end
	   end
	end
	`FW_MOD_CALC: begin
	   if (~data_not_writen_nxt) begin
	      buffer_nxt = buffer_nxt_calc;
	      read_state_nxt = `FW_IDLE;
	   end
	   else
	     read_state_nxt = `FW_MOD_CALC;
	end
	`FW_EOF_WRITE: begin
	   reader_advice_state = `FW_PRO_WRITE;
	   if (~data_not_writen_nxt) begin
	      read_state_nxt = `FW_DONE;
	      write_size_nxt = 16;
	   end
	   else
	     read_state_nxt = `FW_EOF_WRITE;
	end
	`FW_DONE: begin
	   reader_advice_state = `FW_IDLE;
	   if (write_state==`FW_IDLE) begin
	      eof_out = 1'b1;
	      read_state_nxt = `FW_IDLE;
	      eof_nxt = 1'b0;
	   end
	   else
	     read_state_nxt = `FW_DONE;
	end
      endcase
   end

   always @(*) begin
      flash_stop = 1'b0;
//      write_state_nxt = write_state;
      data_not_writen_nxt = 1'b0;
      
      case (write_state)
	`FW_IDLE: begin
	   if (~eof_out) 
	     flash_stop = 1;
	   //	   write_state_nxt = reader_advice_state;
	end
	`FW_WRITE, `FW_PRO_WRITE: begin
	   casex ({data_not_writen, fw_write})
	     2'b00: flash_data = `EOF_TAG;
	     2'b01: flash_data = sampeled_allign_d_out;
	     2'b1x: flash_data = flash_data_prev;
	   endcase
	   
	   if (~halt) begin
	      //	     write_state_nxt = reader_advice_state;
	      flash_stop = 1'b0;
	   end
	   else begin
	      flash_stop = 1'b1;
	      //	      write_state_nxt = write_state;
	      data_not_writen_nxt = 1'b1;
	   end
	end
      endcase
   end

   assign write_state_nxt = ((write_state==`FW_IDLE)|(~halt))? reader_advice_state : write_state;

   always @(*)
     case (additional_size)
       0: buffer_nxt_calc = {buffer_after_input[27:0], 16'b0};
       1: buffer_nxt_calc = {or_all_masks[7:0], buffer_after_input[27:0], 8'b0};
       2: buffer_nxt_calc = {or_all_masks[7:0], buffer_after_input[35:0]};
       default: buffer_nxt_calc = 0;
     endcase

   integer i;
   
   always @(posedge clk_in or posedge rst) begin
      if (rst) begin
	 data_not_writen <= #1 0;
	 write_state <= #1 0;
	 read_state <= #1 0;
	 buffer <= #1 0;
	 size <= #1 0;
	 write_size <= #1 0;
	 flash_data_prev <= #1 0;
	 eof_ff <= #1 0;
	 cur_rd_ff <= #1 0;
	 cur_wr_ff <= #1 0;
	 fifo_rd_ff <= #1 0;
	 for (i=0; i<2; i=i+1) begin
	    d_in_ff[i] <= #1 0;
	    d_in_size_ff[i] <= #1 0;
	    d_in_valid_ff[i] <= #1 0;
	 end
      end
      else begin
	 data_not_writen <= #1 data_not_writen_nxt;
	 write_state <= #1 write_state_nxt;
	 read_state <= #1 read_state_nxt;
	 buffer <= #1 buffer_nxt;
	 size <= #1 size_nxt;
	 write_size <= #1 write_size_nxt;
	 sampeled_allign_d_out <= #1 allign_d_out;
	 flash_data_prev <= #1 flash_data;
	 eof_ff <= #1 eof_nxt;
	 cur_rd_ff <= #1 cur_rd_nxt;
	 cur_wr_ff <= #1 cur_wr_nxt;
	 fifo_rd_ff <= #1 fifo_rd;
	 for (i=0; i<2; i=i+1) begin
	    d_in_ff[i] <= #1 d_in_nxt[i];
	    d_in_size_ff[i] <= #1 d_in_size_nxt[i];
	    d_in_valid_ff[i] <= #1 d_in_valid_nxt[i];
	 end       
      end

   end

endmodule
