module fp_mac (
   input [23:0] a, b, acc,
   output [23:0] out
);

   wire [23:0] 	 mult_out;
   
   fp_mult mult (.a (a),
		 .b (b),
		 .o (mult_out),
		 .valid (),
		 .over_flow (),
		 .under_flow ());	 

   fp_add add (.a (mult_out),
	       .b (acc),
	       .op (1'b0),
	       .o (out),
	       .valid (),
	       .over_flow (), 
	       .under_flow ());
   
endmodule