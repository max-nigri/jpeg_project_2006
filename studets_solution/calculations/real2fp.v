module real2fp ();

   integer int_num,int_num1;
   real    real_num;
   reg [6:0] lum_quan [127:0];
   integer j,q;
   reg 	   clk;
   reg [31:0] fd;
   
   always @(clk) clk <= #10 ~clk;
   
   initial begin
      clk = 0;      
      lum_quan[0] = 16;
      lum_quan[1] = 11;
      lum_quan[2] = 10;
      lum_quan[3] = 16;
      lum_quan[4] = 24;
      lum_quan[5] = 40;
      lum_quan[6] = 51;
      lum_quan[7] = 61;
      lum_quan[8] = 12;
      lum_quan[9] = 12;
      lum_quan[10] = 14;
      lum_quan[11] = 19;
      lum_quan[12] = 26;
      lum_quan[13] = 58;
      lum_quan[14] = 60;
      lum_quan[15] = 55;
      lum_quan[16] = 14;
      lum_quan[17] = 13;
      lum_quan[18] = 16;
      lum_quan[19] = 24;
      lum_quan[20] = 40;
      lum_quan[21] = 57;
      lum_quan[22] = 69;
      lum_quan[23] = 56;
      lum_quan[24] = 14;
      lum_quan[25] = 17;
      lum_quan[26] = 22;
      lum_quan[27] = 29;
      lum_quan[28] = 51;
      lum_quan[29] = 87;
      lum_quan[30] = 80;
      lum_quan[31] = 62;
      lum_quan[32] = 18;
      lum_quan[33] = 22;
      lum_quan[34] = 37;
      lum_quan[35] = 56;
      lum_quan[36] = 68;
      lum_quan[37] =109;
      lum_quan[38] =103;
      lum_quan[39] = 77;
      lum_quan[40] = 24;
      lum_quan[41] = 35;
      lum_quan[42] = 55;
      lum_quan[43] = 64;
      lum_quan[44] = 81;
      lum_quan[45] =104;
      lum_quan[46] =113;
      lum_quan[47] = 92;
      lum_quan[48] = 49;
      lum_quan[49] = 64;
      lum_quan[50] = 78;
      lum_quan[51] = 87;
      lum_quan[52] =103;
      lum_quan[53] =121;
      lum_quan[54] =120;
      lum_quan[55] =101;
      lum_quan[56] = 72;
      lum_quan[57] = 92;
      lum_quan[58] = 95;
      lum_quan[59] = 98;
      lum_quan[60] =112;
      lum_quan[61] =100;
      lum_quan[62] =103;
      lum_quan[63] = 99;
      lum_quan[64] = 17;
      lum_quan[65] = 18;
      lum_quan[66] = 24;
      lum_quan[67] = 47;
      lum_quan[68] = 99;
      lum_quan[69] = 99;
      lum_quan[70] = 99;
      lum_quan[71] = 99;
      lum_quan[72] = 18;
      lum_quan[73] = 21;
      lum_quan[74] = 26;
      lum_quan[75] = 66;
      lum_quan[76] = 99;
      lum_quan[77] = 99;
      lum_quan[78] = 99;
      lum_quan[79] = 99;
      lum_quan[80] = 24;
      lum_quan[81] = 26;
      lum_quan[82] = 56;
      lum_quan[83] = 99;
      lum_quan[84] = 99;
      lum_quan[85] = 99;
      lum_quan[86] = 99;
      lum_quan[87] = 99;
      lum_quan[88] = 47;
      lum_quan[89] = 66;
      lum_quan[90] = 99;
      lum_quan[91] = 99;
      lum_quan[92] = 99;
      lum_quan[93] = 99;
      lum_quan[94] = 99;
      lum_quan[95] = 99;
      lum_quan[96] = 99;
      lum_quan[97] = 99;
      lum_quan[98] = 99;
      lum_quan[99] = 99;
      lum_quan[100] = 99;
      lum_quan[101] = 99;
      lum_quan[102] = 99;
      lum_quan[103] = 99;
      lum_quan[104] = 99;
      lum_quan[105] = 99;
      lum_quan[106] = 99;
      lum_quan[107] = 99;
      lum_quan[108] = 99;
      lum_quan[109] = 99;
      lum_quan[110] = 99;
      lum_quan[111] = 99;
      lum_quan[112] = 99;
      lum_quan[113] = 99;
      lum_quan[114] = 99;
      lum_quan[115] = 99;
      lum_quan[116] = 99;
      lum_quan[117] = 99;
      lum_quan[118] = 99;
      lum_quan[119] = 99;
      lum_quan[120] = 99;
      lum_quan[121] = 99;
      lum_quan[122] = 99;
      lum_quan[123] = 99;
      lum_quan[124] = 99;
      lum_quan[125] = 99;
      lum_quan[126] = 99;
      lum_quan[127] = 99;
      fd = $fopen("quantization.rom");
      for (q=0; q<4; q=q+1) begin
	 $fwrite(fd, "\n///// Quality factor = %d ////\n",(q+1)*25);
	 $fwrite(fd, "// Luminance quantization table\n");
	 for (j=0; j<64; j=j+1) begin
	    @(posedge clk);
	    int_num = (lum_quan[j]*(q+1)*25.0+50.0);
	    int_num1 = int_num/100;
	    if (100*int_num1 > int_num)
	      int_num1 = int_num1-1;
	    if (int_num1 > 255) int_num1 = 255;
	    else if (int_num1 <= 0) int_num1 = 1;
	    real_num = int_num1;
	    $display("%d, %.4f\n",int_num1,real_num);
	    $fwrite(fd, "%h\t//\t%d\n",r2fp(1/real_num), lum_quan[j]);
	 end
	 $fwrite(fd, "\n// Chrominance quantization table\n");
	 for (j=64; j<128; j=j+1) begin
	    @(posedge clk);
	    int_num = (lum_quan[j]*(q+1)*25.0+50.0);
	    int_num1 = int_num/100;
	    if (100*int_num1 > int_num)
	      int_num1 = int_num1-1;
	    if (int_num1 > 255) int_num1 = 255;
	    else if (int_num1 <= 0) int_num1 = 1;
	    real_num = int_num1;
	    $fwrite(fd, "%h\t//\t%d\n",r2fp(1/real_num), lum_quan[j]);
	 end
      end // for (q=0; q<4; q=q+1)
      $fclose(fd);
      $stop;      
   end
   
   function [23:0] r2fp;
      
      input real num;
      reg [16:0] ma;
      reg [7:0] ea;
      real tmp;
      reg sign;
      
      integer i;
      
      begin	 
	 ma = 0;
	 ea = 0;
	 sign = (num<0);	 
	 tmp = sign? (-num) : num;
	 i=15;
	 
	 while ((i>=0)&(tmp!=0)) begin
	    tmp = 2*tmp;
	    if (tmp >= 1) begin
	       tmp = tmp-1;
	       ma[i] = 1'b1;
	    end
	    if (ma[16]==ma[15])
	      ea = ea-1;
	    else
	      i=i-1;	    
	 end
	 ma = {1'b0, (ma[16:1]+ma[0])};
	 if (sign)
	   ma = ~ma+1;
	 while (ma[15]==ma[14]) begin
	    ma [14:0] = ma[14:0] << 1;
	    ea = ea-1;	    
	 end
	 
	 r2fp = {ma[15:0], ea};	 
      end
   endfunction
   
endmodule
