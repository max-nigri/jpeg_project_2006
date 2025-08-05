module jpeg_encoder ();

   reg encoder_clk, imager_clk;
   reg rst;
   reg shoot_imgr, ready;
   reg [127:0] hex_file_name;
   reg [159:0] output_hex_file_name;   
   reg 	      vid_type;
   reg [63:0] date_string;
   reg 	      print_date;
   reg [1:0]  factor_sel;
   
   wire [7:0] imager_dout;
   wire       enc_dqual;
   wire [7:0] enc_dout;
   wire       d_qual;
   wire [1:0] m_cmd;
   wire [3:0] m_be, s_be;
   wire [31:0] d_inout, flash_d_out, enc_d_out;
   
   initial begin
      encoder_clk = 1;
      imager_clk = 1;
      rst = 1;
      ready = 1; 
      shoot_imgr = 0;
      vid_type = 1;      
      print_date = 1;
      #100;
      @(posedge imager_clk);
      rst = 0;
      #100;
      shoot("pics/peretz.hex", 0,"05032007");
      @(posedge ready);
      repeat(100) @(posedge encoder_clk);
      
      $stop;
   end

   always #5 encoder_clk = !encoder_clk;
   always #40 imager_clk = !imager_clk;

   imager imgr (.rst (rst),
		.clk_in (imager_clk),
		.file_name (hex_file_name),
		.hd (hd),
		.vd (vd),
		.pxq (pxq),
		.dout (imager_dout[7:0]),
		.shoot (shoot_imgr),
		.vid_type (vid_type)
		);

   encoder jpeg_enc(.rst (rst),
		    .clk_in (encoder_clk),
		    .factor_sel (factor_sel),
		    .shoot (shoot_imgr),
		    .file_name (output_hex_file_name),
		    .date_string (date_string),
		    .print_date (print_date),
		    .pxq (pxq),
		    .d_in (imager_dout),
		    .s_halt (s_halt),
		    .qual2flash (d_qual),
		    .data2flash (enc_d_out),
		    .be2flash (m_be),
		    .m_cmd (m_cmd),
		    .m_halt (m_halt),
		    .eof2flash (m_eof));      

   assign      d_inout = (|m_be) ? enc_d_out : 32'hzzzzzzzz;
   
   flash_disk fd (.rst (rst),
		  .clk_in (encoder_clk),
		  .m_cmd (m_cmd),
		  .d_qual (d_qual),
		  .d_inout (d_inout),
		  .m_be (m_be),
		  .s_be (s_be),
		  .err (err),
		  .m_halt (m_halt),
		  .s_halt (s_halt),
		  .m_eof (m_eof),
      		  .s_eof (s_eof));

   always@(posedge encoder_clk or posedge rst)
     if (rst | m_eof)
       ready <= #1 1;
     else if (shoot_imgr)
       ready <= #1 0;
   
   task shoot;
      input [127:0] file_name;
      input [1:0]   factor;
      input [63:0] date;

      begin
	 wait (ready);
	 date_string = date;
	 factor_sel = factor;
	 hex_file_name = file_name;
	 output_hex_file_name = {file_name[127:32],"_jpg",file_name[31:0]};
	 @(posedge imager_clk);
	 shoot_imgr = 1;
	 @(posedge imager_clk);
	 shoot_imgr = 0;
	 $display("converting %s to %s.\n",hex_file_name,output_hex_file_name);	 
      end
   endtask

endmodule
