#! /usr/local/bin/perl
# % function real2ver = real2ver(x,verbose)
# % 
# % converts real number to 24 bits floting point representation.

# function real2ver = real2ver(x,verbose)

################################################
use POSIX;
    $h2b{"0"} = "0000";
    $h2b{"1"} = "0001";
    $h2b{"2"} = "0010";
    $h2b{"3"} = "0011";
    $h2b{"4"} = "0100";
    $h2b{"5"} = "0101";
    $h2b{"6"} = "0110";
    $h2b{"7"} = "0111";
    $h2b{"8"} = "1000";
    $h2b{"9"} = "1001";
    $h2b{"a"} = "1010";
    $h2b{"b"} = "1011";
    $h2b{"c"} = "1100";
    $h2b{"d"} = "1101";
    $h2b{"e"} = "1110";
    $h2b{"f"} = "1111";


$x = 0.34;
$verbose = 1;
$add =0;
# for ($x=-1.1; $x<=1.1; $x=$x+0.01){
# for ($i=0; $i<32; $i=$i+1){

# foreach $x ( 0, 1, -1, 0.5, -0.5, 0.25, -0.25, 1/(1<<15),-1/(1<<15), 16383, 16384, 16385) {
#     # real2ver(rand(10), $verbose);
#     # real2ver((16380+$i), $verbose);
#     real2ver($x, $verbose);
# }
# &ver2real("4000_FF");
# &ver2real("C000_F2");
# &ver2real("C001_F2");
# &ver2real("8000_00");
# &ver2real("8001_00");
# &ver2real("ffff_00");

foreach $x ( 0, 1, -1, -45, 19,
	     (2**-15), -0.25, -0.375, -0.5, 
	     -1, -2, -3, -4, -5, 78, -78, 0, 1,
	     123*2**30, 123*2**-30) {
    real2ver($x, $verbose);
}

&ver2real("7fff_7f");
&ver2real("4000_80");
&ver2real("8000_7f");
&ver2real("bfff_80");

foreach $x ( 
	     20000 ,
	     40000,
	     80000,
	     10,
	     (1-2**-10),
	     ) {
    real2ver($x, $verbose);
}
&ver2real("57fe_04");
&real2ver(-45, 1);
&real2ver(19, 1);

for ($x=0; $x<16; $x++){
    if ($x>7){
	$x1=$x-16;
    }
    else {
	$x1=$x;
    }
    $h1 = sprintf("%1x", $x);
    printf("%01x  %s  %+2d  %+2d/8  %+2.3f\n", $x, $h2b{$h1}, $x1, $x1, $x1/8);
}

for ($x=-16; $x<16; $x++){
    &real2ver($x, 1);
}

sub real2ver{
    my($x) = shift;
    my($verbose) = shift;
    my($s, $logx2, $exp1, $exp2, $log_man1, $man1, $man2, $man3);
    my($label, $x1);
    my($t1,$fx_t1,$Xm, $Xmm,$Xee,$x_back, $for_print);


    if ($x ==0){ 
	printf("%04X_%02X // x = % .5e\n", 0,0,$x) if $verbose; 
	return "0000_00";
    }
    if ($x>0){
	$s=1;
    }
    else {
	$s=-1;
    }
    $log2x     = log2(abs($x));
    $exp1      = int ($log2x)+1;
    $log_man1  = $log2x - $exp1 ;#  range is  -1 >= x < 0 
    $man1      = 2**$log_man1;   #  range is 0.5 >= x < 1
    if ($s==-1)  {
	# man should be aligned to 0.5 <  x <= 1
	$man3      = $man1;
	if ($man3 == 0.5){
	    $man3 = $man3 * 2;
	    $exp1 = $exp1-1;
	}
        $x1       = 2**$exp1 * $man3 * $s; # adjusting the exponent
	$man2     = 2**16 - int(32768 * $man3  + 0.5);	    
    }
    else {
	# man should be aligned to 0.5 <= x <  1
	$man3      = $man1;
	if ($man3 == 1){
	    $man3 = $man3 * 0.5;
	    $exp1 = $exp1+1;
	}
        $x1       = 2**$exp1 * $man3; # adjusting the exponent
	$man2     = int(32768 * $man3 + 0.5);
    }	

    if ($exp1 > 127) {
	$label = "OF";
    }
    elsif ($exp1 < -128) {
	$label = "UF";
    }
    else {
	$label = "OK";
    }
    if ($exp1<0){
	$exp2 = 2**8 - $exp1;
    }
    else {
	$exp2 = $exp1;
    }
    printf("%04X_%02X // x = % .5e, log2x = % .5e, exp1 = %3d, log_man1 = % .5f, man1 = % .5f, %+ .5f,  c = % .5e %s\n", 
	   $man2,
	   $exp2,
	   $x, 
	   $log2x,
	   $exp1,
	   $log_man1, 
	   $man1,
	   $s*$man3,
	   $x1,
	   $label
	   ) if $verbose;

    return (sprintf("%04X_%02X", $man2,$exp2));
    # real2ver($x, $verbose);
}

##########################################################################
##########################################################################
##########################################################################

sub ver2real{
    my($x) = shift;
    my($verbose) = shift;
    my($s, $t1,$fx_t1,$Xm, $Xmm,$Xee,$x_back, $for_print);
    my($ma,$ea,$ref_ma,$ref_ea ,$sm,$ma_tc ,$se,$ea_tc,$r);
    my($ma_frac);
    $x =~ s/_//g;
    $x =~ m/(\w{4})(\w{2})/; # [0-9ABCDEF]{4}
    $ma = $1;
    $ea = $2;
    $ref_ma = $ma;
    $ref_ea = $ea;
    $ma = hex($ma);
    $ea = hex($ea);
    if ($ma >= 2**15){
	$sm = -1;
	$ma_tc = 2**16-$ma;
	$ma_frac = 2 - $ma/2**15;
    }
    else {
	$sm = 1;
	$ma_tc = $ma;
	$ma_frac = $ma/2**15;
    }

    if ($ea >= 2**7){
	$se = -1;
	$ea_tc = 2**8-$ea;
    }
    else {
	$se = 1;
	$ea_tc = $ea;
    }

    $r = $sm * $ma_tc * 2**($se*$ea_tc-15);
    # printf("%4s_%2s // %6d * 2 ^ %3d %+10e\n", $ref_ma, $ref_ea, $ma_tc, $ea_tc, $r);
    # printf("%4s_%2s // %6d * 2 ^ %3d %+10e\n", $ref_ma, $ref_ea, $ma, $ea, $r);
    # printf("%4s_%2s // %6d * 2 ^ %3d = %+10e\n", $ref_ma, $ref_ea, $ma_tc*$sm, $se*$ea_tc, $r);
    printf("%4s_%2s // x = %+.5e, Xm = %+8.7f * 2^ %4d address = %4d\n",
			$ref_ma, $ref_ea, $r, ,$sm*$ma_frac,$se*$ea_tc, $add++);


}


##########################################################################
##########################################################################
##########################################################################

sub real2ver{
    my($x) = shift;
    my($verbose) = shift;
    my($s, $logx2, $exp1, $exp2, $log_man1, $man1, $man2, $man3);
    my($label, $x1);
    my($t1,$fx_t1,$Xm, $Xmm,$Xee,$x_back, $for_print);


    if ($x ==0){ 
	printf("%04X_%02X // x = % .5e\n", 0,0,$x) if $verbose; 
	return "0000_00";
    }
    if ($x>0){
	$s=1;
    }
    else {
	$s=-1;
    }
    $log2x     = log2(abs($x));
    $exp1      = 1 + floor ($log2x);
    $log_man1  = $log2x - $exp1 ;#  range is  -1 >= x < 0 
    $man1      = 2**$log_man1;   #  range is 0.5 >= x < 1
    if ($s==-1)  {
	# man should be aligned to 0.5 <  x <= 1
	$man3      = $man1;
	while ($man3 <= 0.5){
	    $man3 = $man3 * 2;
	    $exp1 = $exp1-1;
	}
        $x1       = 2**$exp1 * $man3 * $s; # reconstructing the number
	$man2     = 2**16 - int(32768 * $man3  + 0.5);	    
    }
    else {
	# man should be aligned to 0.5 <= x <  1
	$man3      = $man1;
	while ($man3 >= 1){
	    $man3 = $man3 * 0.5;
	    $exp1 = $exp1+1;
	}
        $x1       = 2**$exp1 * $man3; # reconstructing the number
	$man2     = int(32768 * $man3 + 0.5);
    }	

    if ($exp1 > 127) {
	$label = "OF";
    }
    elsif ($exp1 < -128) {
	$label = "UF";
    }
    else {
	$label = "OK";
    }
    if ($exp1<0){
	$exp2 = 2**8 - (-$exp1);
    }
    else {
	$exp2 = $exp1;
    }
    printf("%04X_%02X // x = % .5e, log2x = % .5e, exp1 = %3d, log_man1 = % .5f, man1 = % .5f, %+ .5f,  c = % .5e %s\n", 
	   $man2,
	   $exp2,
	   $x, 
	   $log2x,
	   $exp1,
	   $log_man1, 
	   $man1,
	   $s*$man3,
	   $x1,
	   $label
	   ) if $verbose;

    return (sprintf("%04X_%02X", $man2,$exp2));
}



##########################################################################
##########################################################################
##########################################################################
sub log2 {
    my $n = shift;
    return log($n)/log(2);
}

# real2ver=for_print;



# %t0 = log2((2^14-1)/x);
# %fx_t0 = fix(t0);
# %fx_t1 = fix(t1);
# % Xm= fix(s * fix(    x * 2^fx_t1));
