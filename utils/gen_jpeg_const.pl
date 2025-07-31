# % function real2ver = real2ver(x,verbose)
# % 
# % converts real number to 24 bits floting point representation.

# function real2ver = real2ver(x,verbose)

################################################
use POSIX;


$x = 0.34;
$verbose = 1;

print "RGB transform R,G,B are unsigned by definition, after transform they are signed\n";
#define  Y(R,G,B) ((BYTE)( (YRtab[(R)]+YGtab[(G)]+YBtab[(B)])>>16 ) - 128)
#define Cb(R,G,B) ((BYTE)( (CbRtab[(R)]+CbGtab[(G)]+CbBtab[(B)])>>16 ) )
#define Cr(R,G,B) ((BYTE)( (CrRtab[(R)]+CrGtab[(G)]+CrBtab[(B)])>>16 ) )

foreach $x ( 
	     (65536*0.299+0.5)/2**16,                  # YRtab[R]=(SDWORD)(65536*0.299+0.5)*R;
	     (65536*-0.16874+0.5)/2**16,               # CbRtab[R]=(SDWORD)(65536*-0.16874+0.5)*R;
	     (32768)/2**16,                            # CrRtab[R]=(SDWORD)(32768)*R;
	     (65536*0.114+0.5)/2**16,                  # YGtab[G]=(SDWORD)(65536*0.587+0.5)*G;
	     (32768)/2**16,                            # CbGtab[G]=(SDWORD)(65536*-0.33126+0.5)*G;
	     (65536*-0.08131+0.5)/2**16,               # CrGtab[G]=(SDWORD)(65536*-0.41869+0.5)*G; 
	     (65536*0.114+0.5)/2**16,                  # YBtab[B]=(SDWORD)(65536*0.114+0.5)*B;
	     (32768)/2**16,                            # CbBtab[B]=(SDWORD)(32768)*B;
	     (65536*-0.08131+0.5)/2**16                # CrBtab[B]=(SDWORD)(65536*-0.08131+0.5)*B;  
	     ) {

    real2ver($x, $verbose);
}
print "std_luminance_qt\n";
foreach $x (   # std_luminance_qt
	       16,  11,  10,  16,  24,  40,  51,  61,
	       12,  12,  14,  19,  26,  58,  60,  55,
	       14,  13,  16,  24,  40,  57,  69,  56,
	       14,  17,  22,  29,  51,  87,  80,  62,
	       18,  22,  37,  56,  68, 109, 103,  77,
	       24,  35,  55,  64,  81, 104, 113,  92,
	       49,  64,  78,  87, 103, 121, 120, 101,
	       72,  92,  95,  98, 112, 100, 103,  99
	       ) {
    
    real2ver(1/$x, $verbose);
}
print "std_chrominance_qt\n";
foreach $x (   # std_chrominance_qt
	       17,  18,  24,  47,  99,  99,  99,  99,
	       18,  21,  26,  66,  99,  99,  99,  99,
	       24,  26,  56,  99,  99,  99,  99,  99,
	       47,  66,  99,  99,  99,  99,  99,  99,
	       99,  99,  99,  99,  99,  99,  99,  99,
	       99,  99,  99,  99,  99,  99,  99,  99,
	       99,  99,  99,  99,  99,  99,  99,  99,
	       99,  99,  99,  99,  99,  99,  99,  99
	       ) {
    
    real2ver(1/$x, $verbose);
}
print "dct section\n";
for ($i=0; $i<8; $i++){
    for ($j=0; $j<8; $j++){
	$x = cos((2*$i+1)*$j*3.1416/16);
	real2ver($x, $verbose);
    }
}
print "// Aharon Birnbaum numbers\n";     
&real2ver(-45, 1);
&real2ver(19, 1);
&ver2real(real2ver(-45, 0));
&ver2real(real2ver(19, 0));

# foreach $x ( 
# 	     20000 ,
# 	     40000,
# 	     80000,
# 	     10,
# 	     (1-2**-10),
# 	     ) {
#     real2ver($x, $verbose);
# }
# &ver2real("57fe_04");


################################################
################################################
################################################
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
################################################
################################################
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




################################################
################################################
sub log2 {
    my $n = shift;
    return log($n)/log(2);
}
