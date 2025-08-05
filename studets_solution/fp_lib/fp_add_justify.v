module fp_add_justify(
    input wire [16:0] 		  ma,
    input wire [7:0] 		  ea,
    output wire [15:0] 		  ma_justified,
    output wire [7:0] 		  ea_justified,
    output reg                    under_flow, over_flow 
 );
   
   integer 			  i;
   reg [3:0] 			  shifted;
   reg [15:0] 			  ma_pre;
   reg [8:0] 			  ea_pre;

   always @(*) begin
      shifted = 0;
      over_flow = 0;
      under_flow = 0;
      ma_pre = ma[15:0]; 
      ea_pre = {ea[7],ea};
      if (ma[16] ^ ma[15]) begin
	 ma_pre = ma[16:1] + {15'b0, ma[0]};
	 ea_pre = ea_pre + 1;
	 over_flow = ea_pre[8] ^ ea_pre[7];
      end
      if (ma_pre == 0)
	ea_pre = 0;
      else begin
	 for (i=0; i<15; i=i+1)
	   if (ma_pre[15] == ma_pre[14]) begin
	      ma_pre[14:0] = ma_pre[14:0] << 1;
	      shifted = shifted+1;
	   end
	 ea_pre = ( ea_pre - {5'b0, shifted} );
	 under_flow = (ea_pre[8] ^ ea_pre[7]) & !over_flow;
      end
   end
   
   assign ma_justified = ma_pre;
   assign ea_justified = ea_pre[7:0];

endmodule // justify