module fp2int
  #(parameter INT_WIDTH = 8)	       
    (input [23:0] d_in,
    output [INT_WIDTH-1:0] d_out	       
);
   
   wire [15:0] 	 ma = d_in[23:8];
   wire [7:0] 	 exp = d_in[7:0];
   
   wire [15+INT_WIDTH-1:0] shifted_d_in = exp[7] ? 0 :{ {11{ma[15]}}, ma} << exp;
   
   assign 		   d_out = shifted_d_in[15+INT_WIDTH-1:15];
   
endmodule