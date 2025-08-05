module fp_mult_justify(
    input wire [29:0] 		  ma,
    input wire [9:0] 		  ea,
    input wire                    sign,
    output wire [15:0] 		  ma_justified,
    output wire [7:0] 		  ea_justified,
    output wire                   under_flow, over_flow 
 );

   wire [30:0]                    ma_in;
   reg [15:0] 			  ma_pre;
   reg [9:0] 			  ea_pre;
   reg 				  round;
   reg [4:0] 			  shift;
   reg [14:0] 			  junk;
   integer 			  i;

   assign  ma_in = ( (ma==0) ? 0 : 
		              (sign ? {1'b1,  ~ma+1} :
			              {1'b0, ma}) );

   
   always @(*) begin
      ma_pre = 0;
      ea_pre = 0;
      round = 0;
      shift = 0;
      junk = 0;
      if (ma_in != 0) begin
	 for (i=29; i>14; i=i-1)
	   if ((shift == 0) & (ma_in[i] != ma_in[30]))
	     shift = i-14;
	 {junk, ma_pre, round} = {ma_in, 1'b0} >> shift;
	 if (round & (ma_pre == 16'h7fff)) begin
	    ma_pre = 16'h4000;
	    shift = shift + 1;
	 end
	 else if (round & (ma_pre == 16'hbfff)) begin
	    ma_pre = 16'h4000;
	    shift = shift - 1;
	 end
	 else
	   ma_pre = ma_pre + round;
	 ea_pre = ea + shift;
      end
   end

   assign over_flow = ( (ea_pre[8]^ea_pre[7]) & !ea_pre[9] );
   assign under_flow = ( (ea_pre[8]^ea_pre[7]) & ea_pre[9] );
   
   assign ma_justified = ma_pre;
   assign ea_justified = ea_pre[7:0];
   
endmodule
   
   
	    