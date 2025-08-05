module imager (
    input rst, // reset the device,  active high
    input clk_in, // clock input. 12Mhz typical.
    input [127:0] file_name, // the hex file's name
    input 	  shoot, // instruct the imager to take a new picture
    input 	  vid_type, // 1 for RGB, 0 for YUV.
    output reg 	  hd, // synch for horizontal data
    output reg 	  vd, // synch for vertical data
    output reg 	  pxq, // pixel qualifier
    output reg [7:0] dout // pixels output data	       
);
   
   parameter 	    LINES = 65536;
   parameter 	    x_low = 0;
   parameter 	    y_low = 0;
   
   reg [31:0] pic_mem [LINES-1:0];
   reg [2:0]  status_ff, status_nxt;
   reg [1:0]  byte_sel;
   reg [17:0] byte_idx, nxt_byte_idx;
   reg [1:0]  rgb, nxt_rgb;
   reg 	      nxt_byte_sel;
   reg [31:0] bfSize, biWidth, biHeight, bfOffBits, sent, nxt_sent;
   reg 	      done;

   wire [31:0] x_high = x_low + biWidth;
   wire [31:0] y_high = y_low + biHeight;

   always @(posedge clk_in or posedge rst)
     if (rst) begin
	status_ff <= #1 `IDLE;
	sent <= #1 0;
	byte_sel <= #1 0;
	byte_idx <= #1 0;
	rgb <= #1 2;
     end
     else if (done) begin
	status_ff <= #1 `IDLE;
	sent <= #1 0;
	byte_sel <= #1 0;
	byte_idx <= #1 0;
	rgb <= #1 2;
     end
     else begin
	status_ff <= #1 status_nxt;
	sent <= #1 nxt_sent;
	byte_idx <= #1 nxt_byte_idx;
	rgb <= #1 nxt_rgb;
	if (nxt_byte_sel)
	  byte_sel <= #1 byte_sel+1;	   
     end
   
   always @(*) begin
      status_nxt = `IDLE;
      hd = 0;
      vd = 0;
      pxq = 0;
      dout = 0;
      nxt_sent = sent;
      nxt_byte_idx = byte_idx;
      nxt_rgb = rgb;
      done = 0;

      case (status_ff)
	`IDLE: begin
	   if (shoot) begin
	      $readmemh(file_name, pic_mem);
	      bfSize = {pic_mem[1][15:0],pic_mem[0][31:16]};
	      bfOffBits = {pic_mem[3][15:0],pic_mem[2][31:16]};	      
	      biWidth = {pic_mem[5][15:0],pic_mem[4][31:16]};  
	      biHeight = {pic_mem[6][15:0],pic_mem[5][31:16]};
	      nxt_byte_idx = bfSize-3*biWidth;
	      nxt_sent = 0;
	      status_nxt = `IMAGER_X_LOW;
	   end
	   else
	     status_nxt = `IDLE;
	end
	`IMAGER_X_LOW: begin
	   nxt_byte_sel = 1;
	   dout = x_low[8*byte_sel+:8];
	   status_nxt = (byte_sel==2'd3)? `IMAGER_X_HIGH : `IMAGER_X_LOW;
	   pxq = 1;
	end
	`IMAGER_X_HIGH: begin
	   nxt_byte_sel = 1;
	   dout = x_high[8*byte_sel+:8];
	   status_nxt = (byte_sel==2'd3)? `IMAGER_Y_LOW : `IMAGER_X_HIGH;
	   pxq = 1;
	end
	`IMAGER_Y_LOW: begin
	   nxt_byte_sel = 1;
	   dout = y_low[8*byte_sel+:8];
	   status_nxt = (byte_sel==2'd3)? `IMAGER_Y_HIGH : `IMAGER_Y_LOW;
	   pxq = 1;
	end
	`IMAGER_Y_HIGH: begin
	   nxt_byte_sel = 1;
	   dout = y_high[8*byte_sel+:8];
	   if (byte_sel==2'd3) begin
	      if (vid_type)
		status_nxt = `IMAGE_RGB_DATA;
	      else
		status_nxt = `IMAGE_YUV_DATA;
	   end
	   else
	     status_nxt = `IMAGER_Y_HIGH;
	   pxq = 1;
	end
	`IMAGE_RGB_DATA: begin
	   dout = pic_mem[(byte_idx+rgb)/4][8*((byte_idx+rgb)%4)+:8];
	   nxt_sent = sent+1;
	   if (rgb==0) begin
	      nxt_rgb = 2;
	      if ((nxt_sent % (biWidth*3)) == 0)
		nxt_byte_idx = byte_idx-2*3*biWidth+3;
	      else
		nxt_byte_idx = byte_idx+3;
	   end
	   else
	     nxt_rgb = rgb - 1;
	   pxq = 1;	   
	   vd = (sent == 0);
	   hd = ((sent % (biWidth*3)) == 0);	   
	   if (nxt_sent == (bfSize - bfOffBits)) begin
	      status_nxt = `IDLE;
	      done = 1;
	   end
	   else
	     status_nxt = `IMAGE_RGB_DATA;
	end
	`IMAGE_YUV_DATA: begin
	   // don't know what to do here !!!
	end
      endcase
   end

`ifdef DBG
   reg [31:0] log_fd;
   reg [31:0] pxl_out;
   initial begin
      log_fd = $fopen("log/imager.log");
   end

   always @(posedge clk_in or posedge rst)
     if (rst) begin
	pxl_out <= #1 0;
     end
     else if ((status_nxt == `IMAGE_RGB_DATA) && (status_ff == `IMAGER_Y_HIGH))
	$fwrite (log_fd, "x_high = %d\ny_high = %d\n\n",x_high, y_high);
     else if (status_ff == `IMAGE_RGB_DATA) begin
	$fwrite (log_fd, "%h",dout);
	if (pxl_out==(x_high*3-1)) begin
	   pxl_out <= #1 0;
	   $fwrite (log_fd, "\n");
	end
	else begin
	   pxl_out <= #1 pxl_out+1;
	   if (pxl_out%3==2)
	     $fwrite (log_fd, " ");
	   else
	     $fwrite (log_fd, ",");
	end
	if (status_nxt == `IDLE)
	  $fclose(log_fd);
     end

`endif
endmodule





