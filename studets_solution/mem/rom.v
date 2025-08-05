module rom
  #(parameter ROM_FILE = "encoder/dct.rom", LINES = 64, ADDRESS_WIDTH = 6, WORD_WIDTH = 24)
  (input clk,
   input [ADDRESS_WIDTH-1:0] address,
   input read_en,
   output reg [WORD_WIDTH-1:0] data
 );

   localparam t_ac = 2;
   
   reg [WORD_WIDTH-1:0] mem [LINES-1:0] ;  
   
   initial begin
      $readmemh(ROM_FILE, mem);
   end
   
   always @(posedge clk)
     if (read_en) begin
	data <= #1 {WORD_WIDTH{1'bx}};
	data <= #(t_ac) mem[address];
     end
   
endmodule
