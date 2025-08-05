module uint2fp (
   input [7:0] d_in,
   output [23:0] d_out
);

   reg [15:0] 	 ma;
   reg [7:0] 	 ea;

   integer 	 i;
   
   always @(*) begin
      ma= {1'b0, d_in, 7'h0};
      ea = 8'h8;
      if (ma == 0)
	ea = 0;
      else begin
	 for (i=0; i<8; i=i+1)
	   if (!ma[14]) begin
	      ma = ma << 1;
	      ea = ea - 1;
	   end
      end
   end

   assign d_out = {ma, ea};
   
endmodule