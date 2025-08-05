module date_writer
  #(parameter MIN_WIDTH = 100, MIN_HEIGHT = 60) // I've limited the size of the pictures that could have a date print.
(
   input clk_in, rst, print_date,
   input [31:0] line_width,
   input [31:0] pic_height,
   input [63:0] date_string,
   input rgb_valid,
   output reg date_ovr_en
);
   
   wire [6:0] dig_mask;
   reg       dig_rd;
   reg [31:0] line, pxl;
   reg [1:0]  rgb;
   
   wire        month_is_1dig = ~(date_string[43:40]);
   wire        day_is_1dig = ~(date_string[59:56]);
   
   // date_pixels = 8 digits and 2 dots - maximum 2 digits if the day and month are one digit each.
   wire [5:0] date_pixels = (7*(8 - month_is_1dig - !day_is_1dig) + 4*2);
			     
   wire [39:0] date;
   assign date[39:16] = {date_string[3:0],
			 date_string[11:8],
			 date_string[19:16],
			 date_string[27:24],  
			 4'ha,
			 date_string[35:32]};
   assign date[15:12] = month_is_1dig ? 4'ha : date_string[43:40];
   assign date[11:8] = month_is_1dig ? date_string[51:48] : 4'ha;
   assign date[7:4] = month_is_1dig ? (day_is_1dig ? 4'hf : date_string[59:56]) : date_string[51:48];
   assign date[3:0] = (month_is_1dig | day_is_1dig) ? 4'hf : date_string[59:56];

   wire   print_date_is_valid = print_date & (line_width > MIN_WIDTH) & (pic_height > MIN_HEIGHT);
   reg [1:0] state_ff, state_nxt;
   reg [6:0] dig_addr;
   reg [6:0] mask, nxt_mask;
   reg [3:0] dig_num, nxt_dig_num;
   reg [2:0] dig_pxl, nxt_dig_pxl;
   wire [31:0] date_line =  line + 20 - pic_height; // 10 pixels date height + 10 pixels from the edge
   wire [35:0] junk;
   wire [3:0]  current_digit;
   assign      {junk, current_digit} = date >> (4*dig_num);
   
   always @(*) begin
      state_nxt = state_ff;
      dig_rd = 0;
      dig_addr = 0;
      nxt_mask = mask;
      date_ovr_en = 0;
      nxt_dig_pxl = dig_pxl;
      nxt_dig_num = dig_num;
      
      case (state_ff)
	`DATE_IDLE: begin
	   if (print_date_is_valid & (date_line < 10) & (date_line >= 0) & (pxl==(line_width-74))) begin
	      state_nxt = `DATE_READ_DIGIT;
	      dig_rd = (~(&current_digit));
	      dig_addr = (&current_digit) ? 0 : (10*current_digit + date_line);
	   end
	end
	`DATE_READ_DIGIT: begin
	   nxt_mask = (&current_digit) ? 7'h00 : dig_mask;
	   state_nxt = `DATE_MASK;
	end
	`DATE_MASK: begin
	   date_ovr_en = mask[dig_pxl];
	   if (rgb==2'd3) begin
	      if ((dig_pxl==3'd6) || ((current_digit==4'ha)&(dig_pxl==3'd3))) begin
		 nxt_dig_pxl = 0;
		 if (dig_num==4'd9) begin
		    nxt_dig_num = 0;		    
		    state_nxt = `DATE_IDLE;
		 end
		 else begin
		    nxt_dig_num = dig_num+1;
		    state_nxt = `DATE_NXT_MASK;
		 end
	      end
	      else
		nxt_dig_pxl = dig_pxl+1;
	   end
	end
	`DATE_NXT_MASK: begin
	   dig_rd = (~(&current_digit));
	   dig_addr = (&current_digit) ? 0 : (10*current_digit + date_line);
	   state_nxt = `DATE_READ_DIGIT;
	end
      endcase
   end
   
   always @(posedge clk_in or posedge rst)
     if (rst) begin
	state_ff <= #1 `DATE_IDLE;
	mask <= #1 0;
	dig_pxl <= #1 0;	
	dig_num <= #1 0;	
	line <= #1 0;
	pxl <= #1 0;
	rgb <= #1 0;
     end
     else begin
	state_ff <= #1 state_nxt;
	mask <= #1 nxt_mask;
	dig_pxl <= #1 nxt_dig_pxl;
	dig_num <= #1 nxt_dig_num;
	if (rgb_valid) begin
	   rgb <= #1 rgb + 1;
	   if (rgb==2'd2) begin
	      if (pxl==(line_width-1)) begin
		 line <= #1 line + 1;
		 pxl <= #1 0;
	      end
	      else
		pxl <= #1 pxl + 1;
	   end
	end
	if (rgb==2'd3)
	  rgb <= #1 0;
     end
   
   rom #("roms/digits.rom", 110, 7, 7) digits_rom (.clk (clk_in),
						   .address (dig_addr),
						   .read_en (dig_rd),
						   .data (dig_mask));
   
endmodule