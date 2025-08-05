module category(
    input [11:0] d_in,
    output reg [3:0] category
);

   wire [11:0] 	 ones_comp = d_in-d_in[11];
   
   integer 	 i;

   always @(*) begin
      category = d_in[11];
      for (i=0; i<11; i=i+1)
	if (ones_comp[11] != ones_comp[i])
	  category = i+1;
   end
   
endmodule