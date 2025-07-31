`timescale 1ns / 1ns

// one can play with the defines in order to control the rate
`define  MAX_READ_LEN   5
`define  MAX_READ_IDLE  2
`define  MAX_WRITE_LEN  5
`define  MAX_WRITE_IDLE 3
   

module var_fifo;

   reg clk, rst_b;
   reg [5:0] wr_addr, rd_addr;
   reg [6:0]  len;
   reg [6:0] wr_len, rd_len;
   reg 	      empty, full;
   reg [63:0] fifo_data;
   
   reg 	      rd_int;
   
   
   
   
   wire [135:0] ram_di;
   wire [135:0] ram_do;
   wire 	wr, rd;
  
   wire [2:0] 	ram_rd_addr;
   wire [2:0] 	ram_wr_addr;
   
   
   reg rd_req, wr_req;
   reg [135:0] write_data, read_data;
   reg [135:0] exp_read_data;

   wire [127:0] wr_data_pre;
   reg [31:0] 	wr_data;
   wire [63:0] 	wr_data_aligned;
   wire [31:0] 	wr_mask_pre;
   wire [127:0] wr_en_pre;
   wire [63:0] 	wr_en;
   reg 		wr_toggle ;
   
   

   // read alignment logic
   wire [127:0] rd_data_pre;
   wire [31:0] 	rd_mask_pre;
   wire [31:0] 	rd_data;
	
   integer 	i;
   

//////////////////////////////////////////////////////////////

   // the fifo logic
   
   assign 	wr = wr_req && !full;
   assign 	rd = rd_req && !empty;
 
   // write alignment logic
   assign 	wr_data_pre[127:0]  = {32'h0,wr_data,32'h0,wr_data} << wr_addr;
   assign 	wr_data_aligned[63:0]       = wr_data_pre[127:64];	
   assign       wr_mask_pre[31:0]   = {32'h0,32'hffffffff} >> (32-wr_len);
   assign 	wr_en_pre[127:0]    = {32'h0,wr_mask_pre,32'h0,wr_mask_pre} << wr_addr;
   assign 	wr_en[63:0]         = wr_en_pre[127:64];

   // read alignment logic
   assign       rd_data_pre[127:0]  = {fifo_data,fifo_data} >> rd_addr;
   assign 	rd_mask_pre[31:0]   = {32'h0,32'hffffffff} >> (32-rd_len);

   assign 	rd_data[31:0]       = rd_data_pre[31:0] & rd_mask_pre[31:0];
	
  
	
	  


	  
   always @(posedge clk or negedge rst_b)
     if (!rst_b)
       begin
	  wr_addr   <= #1 0;
	  rd_addr   <= #1 0;
	  len       <= #1 0;
	  empty     <= #1 1;
	  full      <= #1 0;
	  fifo_data <= #1 64'h0;	  
       end
     else
       begin

	  
	  if (wr && rd && !full && !empty)
	    begin
	       for (i=0; i<64; i=i+1)
		 if (wr_en[i])
		   fifo_data[i] <= #1 wr_data_aligned[i];
	       
	       if ((len + wr_len - rd_len) >= 32)
		 empty <= #1 0;
	       else
		 empty <= #1 1;
		 
	       if ((len + wr_len - rd_len) > 32)
		 full <= #1 1;
	       else
		 full <= #1 0;
	       len     <= #1 len + wr_len - rd_len;
	 
	       wr_addr <= #1 wr_addr + wr_len;
	       rd_addr <= #1 rd_addr + rd_len;
	    end   
	  else if (wr && !full)
	    begin
	       for (i=0; i<64; i=i+1)
		 if (wr_en[i])
		   fifo_data[i] <= #1 wr_data_aligned[i];
	       
	       if ((len + wr_len) >= 32)
		 empty <= #1 0;
	       if ((len + wr_len) > 32)
		 full <= #1 1;
	       
	       wr_addr <= #1 wr_addr + wr_len;		 
	       len     <= #1 len + wr_len;
	    end
	  else if (rd && !empty)
	    begin
	       if ((len - rd_len) < 32)
		 empty <= #1 1;
	       if ((len - rd_len) <= 32)
		 full <= #1 0;
	       
	       len     <= #1 len - rd_len;
	       rd_addr <= #1 rd_addr + rd_len;		 
	       
	    end // if (rd)
       end
   

   //////////////////////////////////////////////////////////////
   
   // the test bench
   
   always #5 clk = !clk;

   initial
     begin
	rst_b = 0;
	clk = 0;
	wr_req = 0;
	rd_req = 0;
	write_data = 0;
	wr_toggle = 0;
	
	read_data = 0;
	exp_read_data = 0;
	
	
	#31 rst_b = 1;

     end

   integer sr, sw;
   integer read_len, write_len;
   integer read_idle, write_idle;
   integer write_i;
   

   initial  // write process
     begin
	write_i = 0;
	sw = 23232;	
	wait (rst_b);
	delay_w(3);
	write;
	write;
	delay_w(1);
	write;
	delay_w(2);
	write;
	delay_w(10);
	
	while (1)
	  begin
	     write_len = $dist_uniform(sw,0,`MAX_WRITE_LEN);
	     while (write_len > 0) 
	       begin
		  write;
		  write_len = write_len -1;
	       end
	     write_idle = $dist_uniform(sw,0,`MAX_WRITE_IDLE);
	     delay_w(write_idle);	     
	  end


	       
	delay_w(6);
	write;
	delay_w(6);
	write;
	write;
	write;
	write;
	write;
	write;
	
	

     end

     
   
   initial  // read process
     begin
	sr = 4366;	
	wait (rst_b);
	delay_r(3);
	delay_r(2);
	read;
	read;
	delay_r(4);
	read;
	read;

	while (1)
	  begin
	     read_len = $dist_uniform(sr,0,`MAX_READ_LEN);
	     while (read_len > 0) 
	       begin
		  read;
		  read_len = read_len -1;
	       end
	     read_idle = $dist_uniform(sr,0,`MAX_READ_IDLE);
	     delay_r(read_idle);	     
	  end	       
	     
	delay_r(3);
	read;
	delay_r(6);
	read;
	delay_r(4);
	read;
	read;
	read;
	read;
	read;



     end
   //////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////
   // read monitor
   reg rd_for_monitor;
   
   always @(negedge clk)
     begin
	rd_for_monitor <= #1 rd;
	if (rd)
	  begin
	     if ((exp_read_data[135:124]) == ram_do[135:124])
	       $display("%t, %s %s %s %s data captured : %h  %h      ",
			$time, (rd ? "n" : "-"), 
			(empty ? "e" : "-"), (rd ? "r" : "-"), 
			(wr ? "w" : "-"), ram_do[135:120], ram_rd_addr );
	     else
	       $display("%t, %s %s %s %s data captured : %h  %h      bad",
			$time, (rd ? "n" : "-"), 
			(empty ? "e" : "-"), (rd ? "r" : "-"), 
			(wr ? "w" : "-"), ram_do[135:120], ram_rd_addr );
	     exp_read_data[135:124] <= #1 exp_read_data[135:124]+ 12'h1;
	  end
	else 
	  $display("%t, %s %s %s %s ram_do        : %h  %h        ",
			$time, (rd_int ? "i" : "-"), 
			(empty ? "e" : "-"), (rd ? "r" : "-"), 
			(wr ? "w" : "-"), ram_do[135:120], ram_rd_addr );
		   	  
     end

   // write data generator
   always @(negedge clk)
     if (wr)
       begin
	  write_i <= #1 write_i +1;	
	  // !!!!! we always write the write address to the data and some running index
	  // in order to be able to tell that data is new  
          write_data  <= #1  {{8{write_i[11:0], 1'b0,wr_addr}}, 8'h0};
          // write_data  <= #1  {{1{write_i[11:0], 1'b0,wr_addr}}, {7{16'h0}},8'h0};
      end

   assign 	ram_di = write_data;
   
   
   //////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////
   task delay_w;
      input [7:0] len;
      reg [7:0] i;
      begin
         i=len;
         while(i>0)
           begin
              @(posedge clk);
              i=i-1;
 	      #1;
          end
      end
   endtask // delay
   //////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////
   task delay_r;
      input [7:0] len;
      reg [7:0] i;
      begin
         i=len;
         while(i>0)
           begin
              @(posedge clk);
              i=i-1;
	      #1;
           end
      end
   endtask // delay
   //////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////
   task write;
      begin
	 wait (!full);	 
	 wr_req <=  1;
	 wr_data <=  {32{wr_toggle}};	
	 wr_toggle <=  !wr_toggle;	 
	 wr_len <= $dist_uniform(sw,0,`MAX_WRITE_LEN);
	 @(posedge clk);
	 wr_req <= #1 0;
 	 #1;
     end
   endtask // write
   //////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////
   task read;
      begin
	 wait (!empty);	 
	 rd_req <=  1;
	 // rd_len <= $dist_uniform(sr,0,`MAX_READ_LEN);
	 rd_len <= 32; 
         @(posedge clk);
	 rd_req <= #1 0;
	 #1;
      end
   endtask // read

   
	  
   
	









endmodule // simple_rfile_fifo




  
