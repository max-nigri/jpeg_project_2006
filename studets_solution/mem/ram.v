module ram 
  #(parameter LINES = 19200, ADDRESS_WIDTH = 16, WORD_WIDTH = 24)
    (input wire clk, rnw, cs, 
     input wire [ADDRESS_WIDTH-1:0] add,
     input wire [WORD_WIDTH-1:0] wr_data,
     output reg [WORD_WIDTH-1:0] rd_data
     );

   localparam t_ac = 2;
   
   reg [WORD_WIDTH-1:0] mem [LINES-1:0];
   
   always @(posedge clk)
     if (cs && rnw)
       begin
	  rd_data <= #1 {WORD_WIDTH{1'bx}};
	  rd_data <= #(t_ac) mem[add];
       end
     else if (cs && !rnw)
       mem[add] <= #1 wr_data;

endmodule