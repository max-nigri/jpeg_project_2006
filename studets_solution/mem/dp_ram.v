module dp_ram 
  #(parameter LINES = 64, ADDRESS_WIDTH = 6, WORD_WIDTH = 12)
    (input wire clk, cs, rd, wr, 
     input wire [ADDRESS_WIDTH-1:0] rd_add, wr_add,
     input wire [WORD_WIDTH-1:0] wr_data,
     output reg [WORD_WIDTH-1:0] rd_data
     );

   localparam t_ac = 2;
   
   reg [WORD_WIDTH-1:0] mem [LINES-1:0]; 
   
   always @(posedge clk)
     begin
	if (cs && rd)
	  begin
	     rd_data <= #1 {WORD_WIDTH{1'bx}};
	     rd_data <= #(t_ac) mem[rd_add];
	  end
	if (cs && wr)
	  mem[wr_add] <= #1 wr_data;
     end
   
endmodule