`timescale 1ns / 1ns
module jpeg_encoder();
   
   wire [7:0]  rd_data;
   reg [7:0]   wr_data;
   
   reg 	       rd, wr;      
   reg 	       clk;
   reg 	       rst;
   reg [3:0]   div_cnt;
   wire        imager_clk;
        

   
   wire        full, empty;
   
   always #5   clk = !clk;
   assign      imager_clk = div_cnt[2];
   
 
   always @(posedge clk )
     if (rst)
       div_cnt <= 4'h0;
     else
       div_cnt <= div_cnt + 4'h1;
 
   
   fifo fifo1 (.clk(clk), .rd(rd), .wr(wr), .rst(rst),
	       .full(full), .empty(empty),
	       .wr_data(wr_data),
	       .rd_data(rd_data)
	       );
      
   
   initial
     begin
	rst = 1;
	clk = 0;
     end

   ////////////////////////////////////////////////////////////
   ////////////////////////////////////////////////////////////
   task shoot;
      input [4*8-1:0] date;
      input [7:0] quality_factor;
      
      begin
	 wait (ready);
	 
	 date_in = date;
	 
	 @(posedge clk);
	 go <= #1 1'b1;
	 @(posedge clk);
	 go <= #1 1'b0;
	 
      end
   endtask // shoot
   
   ////////////////////////////////////////////////////////////
   ////////////////////////////////////////////////////////////
   task read;
      begin
	 rd  = 1'b1;
	 @(posedge clk);
	 #1;
      end
   endtask // read
   
   ////////////////////////////////////////////////////////////
   ////////////////////////////////////////////////////////////
   task write;
      input [7:0] data;
      
      begin
	 wr  = 1'b1;
	 wr_data = data;
	 @(posedge clk);
	 #1;
      end
   endtask // write
   
   ////////////////////////////////////////////////////////////
   ////////////////////////////////////////////////////////////
   task nop_rd;
      input [7:0] i;     
      begin
	 rd  = 1'b0;
	 while(i>0)
	   begin
	      @(posedge clk);
	      #1;
	      i=i-1;
	   end
      end
   endtask // nop_rd

   ////////////////////////////////////////////////////////////
   ////////////////////////////////////////////////////////////
   task nop_wr;
      input [7:0] i;     
      begin
	 wr  = 1'b0;
	 while(i>0)
	   begin
	      @(posedge clk);
	      #1;
	      i=i-1;
	   end
      end
   endtask // nop_wr
   
endmodule

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
 
module fifo (input wire clk, rd, wr, rst, 
	     input wire [7:0] wr_data,
	     output reg full, empty,
	     output reg [7:0] rd_data
	     );

   
   dp_ram dp_ram1 (.clk(), .cs(), .rd(), .wr(), 
		   .rd_add(), .wr_add(),
		   .wr_data(), .rd_data()
		   );
   
   // put your code here 
   

endmodule
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////

module dp_ram (input wire clk, cs, rd, wr, 
	       input wire [3:0] rd_add, wr_add,
	       input wire [7:0] wr_data,
	       output reg [7:0] rd_data
	       );
     
   reg [7:0] 	      ram [15:0]; 
   
   always @(posedge clk)
     begin
	if (cs && rd)
	  begin
	     rd_data <= #1 8'hxx;
	     rd_data <= #5 ram[rd_add];
	  end
	if (cs && wr)
	  ram[wr_add] <= #1 wr_data;
     end
   
endmodule




