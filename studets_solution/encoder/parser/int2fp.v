module int2fp (
    input [7:0] d_in,
    output [23:0] d_out
);

   reg [15:0] 	 ma;
   reg [7:0] 	 ea;

   integer 	 i;
   
   always @(*) begin
      ma= {d_in, 8'h0};
      ea = 8'h7;
      if (ma == 0)
	ea = 0;
      else begin
	 while (~(ma[15]^ma[14])) begin
	    ma = ma << 1;
	    ea = ea - 1;
	 end
      end
   end

   assign d_out = {ma, ea};
   
endmodule