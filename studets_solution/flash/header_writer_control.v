module header_writer_control(
    input clk_in, rst, start, s_halt,
    input [31:0] line_width, pic_height,
    input dimensions_valid,
    input [159:0] file_name,
    input [1:0]   factor_sel,		     
    input [31:0]  header_dqt_data,
    input [31:0]  header_dht_data,	    
    output [1:0]  m_cmd,
    output reg [4:0] header_dqt_addr,
    output reg 	     header_dqt_rd,
    output reg [6:0] header_dht_addr,
    output reg 	     header_dht_rd,		     
    output [31:0]    write_data,
    output reg [3:0] write_be,
    output reg	     d_qual
);
  
   reg [4:0] 	     header_word;
   reg [31:0] 		   header_data;
   reg [31:0] 		   dqt_val, dqt_val_ff, dqt_val_fff;
   reg [4:0] 		   dqt_addr_nxt;
   reg [31:0] 		   dht_data_ff;
   reg [6:0] 		   dht_addr_nxt;
   reg 			   pause;
   reg [31:0] 		   junk;
   reg [1:0] 		   shift_bytes_nxt, shift_bytes;
   reg 			   writer_state, writer_state_nxt;
   
   wire [6:0] 		   scale_factor = (factor_sel+1)*25;   

   reg [31:0] 		   tmp [3:0];
   
   integer 		   i;
		  
always @(*) begin
   header_dqt_rd = 0;
   header_dht_rd = 0;
   dqt_addr_nxt = 0;
   dht_addr_nxt = 0;
   pause = 0;
   shift_bytes_nxt = shift_bytes;
   junk = 0;
   write_be = 4'b1111;
   writer_state_nxt = writer_state;
   d_qual = 0;

   for (i=0; i<4; i=i+1) begin
      tmp[i] = (({24'b0, header_dqt_data[(8*i)+:8]}*{24'b0, scale_factor}+50) / 100);
      dqt_val[(8*i)+:8] = ((tmp[i] > 255) ? 8'd255 : ((tmp[i] == 0) ? 8'd1 : tmp[i][7:0]));
   end
   
   case (writer_state)
   `HEADER_IDLE: begin
      if (start) 
	writer_state_nxt = `HEADER_WRITE;
      write_be = 4'b0;
      pause = 1;
   end
   `HEADER_WRITE: begin
      if (s_halt) begin
	 pause = 1;
	 dqt_addr_nxt = header_dqt_addr;
	 dht_addr_nxt = header_dht_addr;
	 write_be = 4'b0;      
      end
      else begin
	 case (header_word)
	   0: begin
	      header_data = {file_name[31:0]};
	      d_qual = 1;
	   end
	   1: begin
	      header_data = {file_name[63:32]};
	      d_qual = 1;
	   end
	   2: begin
	      header_data = {file_name[95:64]};
	      d_qual = 1;
	   end
	   3: begin
	      header_data = {file_name[127:96]};
	      d_qual = 1;
	   end
	   4: begin
	      header_data = {file_name[159:128]};
	      d_qual = 1;
	   end
	   5: header_data = {`SOI,`APP0};
	   6: header_data = `APP1;
	   7: header_data = `APP2;
	   8: header_data = `APP3;
	   9: begin
	      header_data = `APP4;
	      header_dqt_rd = 1;
	      dqt_addr_nxt = header_dqt_addr+1;
	   end
	   10: begin
	      header_data = `DQT0;
	      header_dqt_rd = 1;
	      dqt_addr_nxt = header_dqt_addr+1;
	   end
	   11: begin
	      if (header_dqt_addr == 5'd2) begin
		 header_data = {`DQT1, dqt_val_ff[31:8]};
		 shift_bytes_nxt = 3;	
	      end
	      else if (header_dqt_addr == 5'd18) begin
		 header_data = {dqt_val_fff[7:0], `DQT2, dqt_val_ff[31:16]};
		 shift_bytes_nxt = 2;
	      end
	      else
		{header_data, junk} = {dqt_val_fff, dqt_val_ff} << (8*shift_bytes);
	      header_dqt_rd = ~((header_dqt_addr==5'd0)|(header_dqt_addr==5'd1));
	      dqt_addr_nxt = header_dqt_addr+1;
	      pause = (header_dqt_addr!=5'd1);	
	   end
	   12: header_data = {dqt_val_fff[15:0], `SOF0};	   
	   13: begin
	      if (dimensions_valid)
		header_data = {`SOF_LENGTH, `SOF_PRECISION, pic_height[15:8]};
	      else begin
		 write_be = 4'b0;
		 pause = 1;
	      end
	   end
	   14: header_data = {pic_height[7:0], line_width[15:0], `SOF_NROFCOMPONENTS};
	   15: header_data = `SOF1;
	   16: begin
	      header_data = `SOF2;
	      header_dht_rd = 1;
	      dht_addr_nxt = header_dht_addr+1;	
	   end
	   17: begin
	      header_data = {`SOF_QTCR,`DHT0};
	      header_dht_rd = 1;
	      dht_addr_nxt = header_dht_addr+1;
	   end
	   18: begin
	      header_data = dht_data_ff;
	      header_dht_rd = (header_dht_addr < 104);
	      dht_addr_nxt = header_dht_addr+1;
	      pause = (header_dht_addr != 105);
	   end
	   19: header_data = {`DHT1,`SOS0};
	   20: header_data = `SOS1;
	   21: header_data = `SOS2;
	   22: begin
	      header_data = {`SOS3,8'h0};
	      write_be = 4'b0111;
	      writer_state_nxt = `HEADER_IDLE;
	   end
	 endcase
      end
   end
   endcase
end

   always @(posedge clk_in or posedge rst)
     if (rst) begin
	dqt_val_ff <= #1 0;
	dqt_val_fff <= #1 0;	
	header_word <= #1 0;
	header_dqt_addr <= #1 0;
	header_dht_addr <= #1 0;
	dht_data_ff <= #1 0;	
	shift_bytes <= #1 0;
	writer_state <= #1 0;
     end
     else begin
	dqt_val_ff <= #1 dqt_val;
	dqt_val_fff <= #1 dqt_val_ff;	
	header_dqt_addr <= #1 dqt_addr_nxt;
	header_dht_addr <= #1 dht_addr_nxt;
	dht_data_ff <= #1 header_dht_data;	
	shift_bytes <= #1 shift_bytes_nxt;
	writer_state <= #1  writer_state_nxt;
	if (!pause)
	  header_word <= #1 header_word+1;	
     end

   assign write_data = d_qual ? header_data : {header_data[7:0],header_data[15:8],header_data[23:16],header_data[31:24]};
   assign m_cmd = 2'b10;

endmodule

