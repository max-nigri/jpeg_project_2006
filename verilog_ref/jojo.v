`timescale 1ns /1ps
module jojo();

 

  wire kk;
  wire jj;
  reg  reg1;

  reg  clk, rst, go;
  reg [7:0] d,p;
  wire [7:0] minus_d, minus_p;
  reg [15:0] mul_pre;
  reg [15:0] mul_pre1;
  wire [19:0] acc_pre;

  reg [15:0] mul;
  reg [19:0] acc;

  reg [7:0]  state;
  reg 	     start_acc;
  reg [19:0] copy_result;
  
  integer    i;
  integer    s, s1,s2;
  
  
  initial
    begin
      s = 70;
      s1 = 30;
      s2 = 55;
      
      i = 0;
      go = 0;
      clk = 0;
      rst = 1;
      #105;
      rst = 0;

      fork
	while (i<100)
	  begin
	    @(posedge clk);
	    #1;
	    d = $dist_uniform(s1,-100,100);
	    p = $dist_uniform(s1,-100,100);	    
	    i = i+1;
	  end
	
	begin
	  #77;
	  go = 1;
	  @(posedge clk);
	  #1;
	  go = 0;
	end
      join
      
      end // initial begin
  
  always #10 clk = ~clk;



////////////////////////////////////////////////
// here the design starts
////////////////////////////////////////////////

  reg [3:0] clk_cnt;
  reg 	    img_clk ;
  reg [7:0] pixle;
  
  
  always @(posedge clk)
    if (rst)
      begin
	clk_cnt <= #1 7;
	img_clk <= 0;
      end
    else if (clk_cnt > 1)
      clk_cnt <= #1 clk_cnt-1;
    else if (clk_cnt == 1)
      begin
	clk_cnt <= #1 clk_cnt-1;
	img_clk <= 1;
      end
    else
      begin
	clk_cnt <= #1 7;
 	img_clk <= 0;
      end    
	
    always @(posedge img_clk or posedge rst)
      if (rst)
	pixle <= #1 0;
      else
	// pixle <= #1 pixle + 5;
	pixle <= #1 $dist_uniform(s,0,100);

	
   
      

  
  always @(*)
    case({d[7],p[7]})
      2'b00 : mul_pre =  d *  p;
      2'b01 : mul_pre =  -(d * minus_p);
      2'b10 : mul_pre = -(minus_d *  p);
      2'b11 : mul_pre = minus_d * minus_p;
    endcase // case ({d[7],p[7]})


  always @(*)
    mul_pre1 =  {{8{d[7]}},d} * {{8{p[7]}},p};
 

  
  assign minus_d = -d;
  assign minus_p = -p;
  
  always @(posedge clk)
    mul <= #1 mul_pre;

  assign acc_pre = (start_acc ? 0 : acc) + {{4{mul[15]}},mul};

  always @(posedge clk)
    acc <= #1 acc_pre;
  

  always @(posedge clk)
    if (rst)
      begin
	start_acc   <= #1 0;
	state       <= #1 0;
	copy_result <= #1 0;
      end
    else
      begin
	case (state)
	  0 : if (go)
	    begin
	      start_acc <= #1 1;
	      state     <= #1 1;
	    end
	  1,2,3,4,5,6,7,8 :begin
	    start_acc   <= #1 0;
	    state       <= #1 state +1;
	  end
	  9 : begin
	    copy_result <= #1 acc;
	    state       <= #1 0;
	  end
	endcase
      end


//   always @(*)
//     case(sel_08)
//       0 : out = 94;
//       1 : out = 34;
//     endcase // case(sel_08)
  
  
endmodule // jojo




