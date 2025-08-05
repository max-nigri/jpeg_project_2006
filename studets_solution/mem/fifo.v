module fifo
  #(parameter LINES = 16, ADDRESS_WIDTH = 4, WORD_WIDTH = 33)
  (input wire clk, rd, wr, rst, 
    input wire [32:0] wr_data,
    output reg 	      full, empty,
    output wire [32:0] rd_data
   );
   
   reg [ADDRESS_WIDTH-1:0] rd_add_ff, wr_add_ff;
   wire [ADDRESS_WIDTH-1:0] wr_add_nxt, rd_add_nxt;
   wire 		    empty_nxt, full_nxt;
   wire 		    rd_dp_ram, wr_dp_ram;
   reg 			    empty_d1; // delay of 1 cycle to remember if exit empty in the previous cycle.
   reg 			    wr_ff;
   
   dp_ram #(LINES, ADDRESS_WIDTH, WORD_WIDTH) ram (.clk(clk),
						   .cs(rd_dp_ram|wr_dp_ram),
						   .rd(rd_dp_ram),
						   .wr(wr_dp_ram),
						   .rd_add(rd_add_nxt),
						   .wr_add(wr_add_ff),
						   .wr_data(wr_data),
						   .rd_data(rd_data));
   
   always @(posedge clk or posedge rst)
     if (rst) begin
	rd_add_ff <= #1 {ADDRESS_WIDTH{1'b0}};
	wr_add_ff <= #1 {ADDRESS_WIDTH{1'b0}};
	empty <= #1 1'b1;
	full <= #1 1'b0;
	empty_d1 <= #1 1'b0;
	wr_ff <= #1 0;
     end 
     else begin
	rd_add_ff <= #1 rd_add_nxt;
	wr_add_ff <= #1 wr_add_nxt;
	empty <= #1 empty_nxt;
	full <= #1 full_nxt;
	empty_d1 <= #1 empty;
	wr_ff <= #1 wr;
     end
   
   assign rd_add_nxt = (rd & ~empty) ? rd_add_ff + 1 : rd_add_ff;
   assign wr_add_nxt = (wr & ~full) ? wr_add_ff + 1 : wr_add_ff;
   assign empty_nxt = ~wr_ff & (empty | (rd & rd_add_nxt == wr_add_ff));
   assign full_nxt = ~rd & (full | (wr & wr_add_nxt == rd_add_ff));
	  
   assign rd_dp_ram = ~empty_nxt & ((rd & ~empty_nxt) | empty);
   assign wr_dp_ram = wr & ~full;

endmodule