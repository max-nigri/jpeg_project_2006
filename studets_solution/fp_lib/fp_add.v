module  fp_add  (
		 input wire [23:0] a,b,
		 input wire 	      op,
		 output wire [23:0] o,
		 output wire        valid,
		 output wire        over_flow, under_flow
		 );
   wire [15:0] 		ma, mb;
   wire [7:0] 		ea, eb;
   wire [8:0] 		shift_amount;
   wire 		shift_a;
   wire [15:0] 		shift_in, shift_out;
   wire [15:0] 		add_ma_in, add_mb_in;
   reg [16:0] 		add_m_out;
   wire [7:0] 		add_e_out;
   wire [15:0] 		mo;
   wire [7:0] 		eo;
   wire [16:0] 		ma_extended_in;
   wire [16:0] 		mb_extended_in;
   
   
   
   assign 		{ma,ea} = a;
   assign 		{mb,eb} = b;
   
   fp_add_shift_calc shift_calc(
			 .ea(ea), 
			 .eb(eb), 
			 .shift_a(shift_a), 
			 .shift_amount(shift_amount)
			 );

   assign 		shift_in = shift_a ? ma : mb;
   
   fp_add_shift_round shift_round (
			    .m(shift_in), 
			    .shift_amount(shift_amount), 
			    .shifted_m(shift_out)
			    );  

   assign 		add_ma_in = shift_a ? shift_out : ma;
   assign 		add_mb_in = shift_a ? mb : shift_out;

   assign 		ma_extended_in = {add_ma_in[15], add_ma_in};
   assign 		mb_extended_in = {add_mb_in[15], add_mb_in};

   assign 		ma_zero = ma == 16'h0;
   assign 		mb_zero = mb == 16'h0;

   assign 		add_e_out = shift_a ? eb : ea;

   always @(*)
     case ({mb_zero,ma_zero})
       2'b00: add_m_out = op ? ma_extended_in - mb_extended_in
		       : ma_extended_in + mb_extended_in;
       2'b01: add_m_out = op? -mb_extended_in : mb_extended_in;
       2'b10: add_m_out = ma_extended_in;
       2'b11: add_m_out = 17'h0;
     endcase
	  
   
   fp_add_justify justify (
		    .ma(add_m_out),
		    .ea(add_e_out),
		    .ma_justified(mo),
		    .ea_justified(eo),
		    .over_flow(over_flow), 
		    .under_flow(under_flow)
		    );
   
   assign 		o = {mo,eo};

   assign 		valid = !(under_flow | over_flow);
   
endmodule