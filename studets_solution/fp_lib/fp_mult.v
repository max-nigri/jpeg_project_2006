module fp_mult  (
		 input wire [23:0] a,b,
		 output wire [23:0] o,
		 output wire        valid,
		 output wire        over_flow, under_flow
		 );	       

   wire [14:0] 		ma, mb;
   wire [7:0] 		ea, eb;
   wire 		sign_a, sign_b;
   wire 		mult_sign_out;
   reg [14:0] 		mult_ma_in, mult_mb_in;
   reg [9:0] 		mult_ea_in, mult_eb_in;		
   wire [29:0] 		mult_m_out;
   wire [9:0] 		mult_e_out;
   wire [15:0] 		mo;
   wire [7:0] 		eo;
	      
   assign 		{sign_a, ma, ea} = a;
   assign 		{sign_b, mb, eb} = b;

   assign mult_sign_out = sign_a ^ sign_b;

   always @(*) begin
      mult_ma_in = ma;
      mult_mb_in = mb;
      mult_ea_in = {{2{ea[7]}}, ea};
      mult_eb_in = {{2{eb[7]}}, eb};
      if (sign_a) begin
	 if (ma == 0) begin
	    mult_ma_in = 15'h4000;
	    mult_ea_in = mult_ea_in + 1;
	 end
	 else
	   mult_ma_in = ~ma + 1;
      end
      if (sign_b) begin
	 if (mb == 0) begin
	    mult_mb_in = 15'h4000;
	    mult_eb_in = mult_eb_in + 1;
	 end
	 else
	   mult_mb_in = ~mb + 1;
      end
   end

   assign mult_m_out = ( {15'b0, mult_ma_in} * {15'b0, mult_mb_in} );
   assign mult_e_out = (mult_ea_in + mult_eb_in - 15);

   fp_mult_justify justify(
		   .ma (mult_m_out),
		   .ea (mult_e_out),
		   .sign (mult_sign_out),
		   .ma_justified (mo),
		   .ea_justified (eo),
		   .under_flow (under_flow),
		   .over_flow (over_flow)
		   );

   assign o = {mo,eo}; 

   assign 		valid = !(under_flow | over_flow);
   
endmodule
   
	 
      