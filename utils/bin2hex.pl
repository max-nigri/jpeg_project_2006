#! /usr/local/bin/perl 

if (@ARGV == 0) {
    die "Usage :\n\t bin2hex  <bin file name>\n\n";
}

$debug = 0;

$fname0 = $ARGV[0];
$fname1 = $ARGV[1];

if (!(-s $fname0)) {
    print "ERROR - could not open $fname0\n";
    die "Usage :\n\t bin2hex  <bin file name>\n\n";
}

open(g,"$fname0") || print "can not open $fname0 file ...\n";
binmode(g);
$i=0;
$for_print = "";
while(read(g, $one_byte, 1)){

    $for_print = sprintf ("%02x", ord($one_byte)).$for_print;
    if ($i%4 == 3){
	$j=$i-3;
	printf("%s // add %5d, %10d %10d\n", $for_print,int($i/4), $i,$j);
	$for_print = "";
    }
    $i++;	
    # last if ($i>60);
}

# calculating padding bytes $p
$p= 4-(($i-1)%4+1);
# building padding string
for ($k=0; $k<$p; $k++) {
    $for_print = 'XX'.$for_print;
}
# appending the padding
if ($p>0){
    printf("%s // add %5d, %10d %10d\n", $for_print, int($i/4), $j+7,$j+4);
}
else {
    printf("XXXXXXXX // add %5d, %10d %10d\n",  int($i/4), $j+7,$j+4);
}

close(g);

exit 0;


