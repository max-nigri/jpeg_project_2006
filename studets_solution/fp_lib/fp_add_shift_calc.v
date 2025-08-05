module fp_add_shift_calc(
    input wire [7:0] ea, eb,
    output reg 	     shift_a,
    output reg [8:0] shift_amount
		  );
   
   wire [8:0] 	     delta;  // widening by one bit
   
   
   assign 	     delta = {ea[7],ea[7:0]}-{eb[7],eb[7:0]};
   

   always @(*)
     begin
	shift_a = delta[8];
	if(delta[8])
	  shift_amount = ~delta+1;
	else
	  shift_amount = delta[8:0];
     end
   
   
endmodule // shift_calc