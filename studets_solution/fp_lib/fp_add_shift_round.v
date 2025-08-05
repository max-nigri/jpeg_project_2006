module fp_add_shift_round(
    input wire [15:0] 		  m,
    input wire [8:0] 		  shift_amount,
    output reg [15:0] 		  shifted_m
		   );
   
   always @(*)
     if (shift_amount == 0)
       shifted_m = m;
     else if (shift_amount > 15)
       shifted_m = 0;
     else
       //	 begin
       shifted_m =  {{16{m[15]}},m[15:0]} >> shift_amount;
   //	    if (m[shift_amount-1])
   //	      shifted_m = shifted_m + (m[15] ? -1: 1);
   //	 end // else: !if(shift_amount > 15)
   
endmodule // shift_round