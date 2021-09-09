#!/usr/bin/perl
#
use Date::Calc qw(Day_of_Week);

$ampm=$ARGV[1] ;
$ratID=$1 if ($ARGV[0]=~/(.+)\.csv/);

#the last Sun is added to be compatible with other scirpts
my @abbrw= qw(Sun Mon Tue Wed Thu Fri Sat Sun);
#my @abbr = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );

if ( $ratID=~s/(20\d\d)-(\d\d)-(\d\d)//) {
	$day="$2-$3-$1";
	$wday=Day_of_Week($1,$2,$3);
} else {
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	$year += 1900; ## $year contains no. of years since 1900, to add 1900 to make Y2K compliant
	$mday=$mday;
	$wday=$wday;
	$mon++;
	my $day="$mon\-$mday\-$year"; 
}

open(W, "sort /home/hao/Dropbox/medpc/bodyweight.csv|") || die "missing bodyweight file";
while (<W>) {
	chomp;
	@ary=split(/\t/,$_);
	next if ($ary[2]!~/\d/);
	$weight{uc($ary[1])}=$ary[2] if ($ary[2]>20);
}

#$match{"c135"}=$drops{"c130"};
#$match{"c137"}=$drops{"c131"};
#$match{"c138"}=$drops{"c132"};
#$match{"c136"}=$drops{"c133"};
open(IN, $ARGV[0]) || die; 
while (<IN>) { 
	$out1.="\\x$_"; 
	chomp; 
	$_=~s/"//g;
	$_=~s/\//_/g;
	@l=split(/,|\t/, $_); 
	next if (!$l[2]); 
	next if (!$l[9]);

	if (uc(substr($l[10],-4)) eq uc($l[2])){
		$aid=$l[10]; 
	}else{
		$aid=$l[2];
	}
	$aid=uc($aid);

	$warning.="! 6ml Syringe is not nicotine for $aid in box $l[1] to run Nic SA\n" if (($l[9]=~/nic\d\d/i) && ($l[4] !~/nic/i));
	#$warning.="! 6ml Syringe is not saline for $aid in box $l[1] to run Saline SA\n" if (($l[9]=~/sal\d\d/i) && ($l[4] !~/sal|x/i));
	#$warning.="! remove demo for $aid in box $l[1] to run extinction\n" if (($l[9]=~/ext/i) && ($l[5] !~/x|^$/i));
	#$warning.="! remove bottle for $aid in box $l[1] to run extinction\n" if (($l[9]=~/ext/i) && ($l[6] !~/x|^$/i));
	#$warning.="! remove syring for $aid in box $l[1] to run extinction\n" if (($l[9]=~/ext/i) && ($l[4] !~/x|^$/i));
	#$warning.="! clean spout is needed for $aid in box $l[1] to run extinction\n" if (($l[9]=~/ext/i) && ($l[8] !~/clean/i));
	#$warning.="! 10ml syring is not GrapeOnly for $aid in box $l[1] to run OdorReinstatment\n" if (($l[9]=~/odorRein/i) && ($l[8] !~/GrapeOnly/i));
	#$warning.="! remove bottle for $aid in box $l[1] to run OdorReinstatment\n" if (($l[9]=~/odorRein/i) && ($l[6] !~/x/i));
	#$warning.="! remove demo for $aid in box $l[1] to run OdorReinstatment\n" if (($l[9]=~/odorRein/i) && ($l[5] !~/x/i));
	#$warning.="! 10ml syring is not QuinineOnly for $aid in box $l[1] to run TasteReinstatment\n" if (($l[9]=~/TasteRein/i) && ($l[8] !~/QuinineOnly/i));
	#$warning.="! remove bottle for $aid in box $l[1] to run TasteReinstatment\n" if (($l[9]=~/TasteRein/i) && ($l[6] !~/x/i));
	#$warning.="! remove demo for $aid in box $l[1] to run TasteReinstatment\n" if (($l[9]=~/TasteRein/i) && ($l[5] !~/x/i));
	#	$warning.="! pse need demo rat $aid in box $l[1]\n" if (($l[9]=~/pse/i) && ($l[5] !~/cgmt|rndm/i));
	#$warning.="! nse need demo rat $aid in box $l[1]\n" if (($l[9]=~/nse/i) && ($l[5] !~/cgmt|rndm/i));
	#$warning.="! pse need bottle for demo $aid in box $l[1]\n" if (($l[9]=~/pse/i) && ($l[6] =~/x/i));
	$warning.="! remove bottle for nse $aid in box $l[1]\n" if (($l[9]=~/nse/i) && ($l[6] !~/x/i));
	$warning.="! quinine rats should be run with noav: $aid in box $l[1]\n" if (($l[9]!~/noav/i) && ($l[8] =~/quin/i) && $l[9]!~/cue/i);
	$warning.="! full cue reinst needs quinine or sacc syring: $aid in box $l[1]\n" if (($l[8] !~/quin|sacc/i) && $l[9]=~/fullcue/i);
	$warning.="! full cue reinst needs demo: $aid in box $l[1]\n" if (($l[5] !~/demo|rndm|cgmt/i) && $l[9]=~/fullcue/i);
	$warning.="! full cue reinst needs SaccGrape bottle: $aid in box $l[1]\n" if (($l[6] !~/sacc/i) && $l[9]=~/fullcue/i);

#FR
	$prog="R_FRx_IR_AV23h_122012"   if (($l[9]=~/23h/i) & ($l[9]=~/fr/i) & ($l[9]!~/noav/i));
	$prog="R_FRx_IR_noAV23h_102113" if (($l[9]=~/23h/i) & ($l[9]=~/fr/i) & ($l[9]=~/noav/i));
	$prog="R_FRx_IR_AV_120413"   if ($l[9]=~/fr/i); # & ($l[9]=~/av/i));
	#$prog="R_FRx_IR_noAV_112513" if ($l[9]=~/noav/i);
	$prog="R_FRx_IR_noAV_041416" if ($l[9]=~/noav/i); # default run time is 150 min 
	$prog="R_HS_FR10_150min" if (($l[9]=~/noav/i) & ($l[3]=~/^\wb\d+g\d/i));
	$prog="R_FRx_OSS_HC" if ($l[9]=~/oss/i);
	$prog="R_FRx_IR_noAV_init8injmax05272014" if ($l[9]=~/noav/i & $l[9]=~/day1/i);
	$prog="R_FRx_AV_16h_noIR_houselight10ml20ml" if (($l[9]=~/_av/i) & ($l[9]=~/16h/i) & ($l[9]=~/fr/i) & ($l[9]=~/1rat/i));

	#	$prog="R_FRx_IR_noAV_yoked_".$1 if ($aid=~/(k\d+)/i);

	#mice
	$prog="SA_FR10_ir_081710" 	   if (($l[3]=~/mn/i) & ($l[9]=~/fr10/i) & ($l[9]!~/noav/i));
	$prog="SA_FR10_ir_noav_062012" if (($l[3]=~/mn/i) & ($l[9]=~/fr10/i) & ($l[9]=~/noav/i));

## PR
	$prog="SA_PR_020411" if ($l[9]=~/PR/i);
	$prog="SA_PR_noav_012611" if ($l[9]=~/prnoav|pr\.noav|noav.*pr/i);
	$prog="micePR_noav_061812" if (($l[3]=~/mn/i) & ($l[9]=~/pr/i) & ($l[9]=~/noav/i));
	$prog="M_nic_pr" if ($l[9]=~/micepr|micelnic\d*pr/i);

#reinstate
	$prog="R_OGScue_Reins_3h_100312 " if  ($l[9]=~/reinst/i);
	$prog="R_OGScue_Reins_072612 " if  (($l[9]=~/reinst/i) & ($l[9]=~/1h/));
	$prog="M_OGScue_Reins_072812 " if (($l[9]=~/reinst/i) & ($l[3]=~/mn/i));

#ext
	$prog="SA_ext081610" if ($l[9]=~/ext/i) ;   # & ($l[3]=~/mn/)); 
	$prog="R_ext1h" if (($l[9]=~/ext_1h|ext1h/i) & ($l[3]!~/mn/)); 


#oxycodone 
	$prog="R_FRx_IR_AV_1h_20180221" if ($l[9]=~/oxy_/i);
	$prog="R_FRx_IR_AV_1h_20180221" if ($l[9]=~/oxy_/i);
	$prog="R_FRx_oxycodone_visual"  if ($l[9]=~/oxy_vis/i);
	$prog="R_FRx_oxycodone"         if ($l[9]=~/oxyav_fr/i);
	$prog="R_PR_oxycodone"          if ($l[9]=~/oxyav_pr/i);
	$prog="R_PR_oxycodone_visual"   if ($l[9]=~/oxyvis_pr|oxy_vis_pr|oxy_vispr|oxyvispr/i);

#Ethanol SA
	$prog="R_VR10_IR_DVOnly_02042015" if ($l[9] =~/dvonly/i & $l[9]=~/vr10/i);
	$prog="R_FRx_IR_Vonly_070115" if ($l[9]=~/dvonly/i & $l[9]=~/fr\d/i);
	$prog="R_VR10_IR_CAV_01262015" if ($l[9] =~/cAdV/i & $l[9] =~/vr10/i);
	$prog="R_VR20_IR_CAV_01262015" if ($l[9] =~/cAdV/i & $l[9] =~/vr20/i);
	$prog="R_FRx_IR_CAV_01212015" if ($l[9] =~/cAdV/i & $l[9] =~/fr/i);
	$prog="R_FRx_IR_noAV_OGReinst_041615" if ($l[9]=~/etohreinst/i);
	$prog="R_PR_Vonly_06252015" if ($l[9]=~/prdvonly/i);

#mice lever / food
	$prog="miceFood_0929" if ($l[9]=~/miceFood/i);
	$prog="miceNicLever_0929" if ($l[9]=~/micelNic|micelsal/i);
	$prog="miceNicLeverto60_0929" if ($l[9]=~/micel.*fr5to60/i);
	$prog="miceNicLeverext_1019" if ($l[9]=~/micelext/i);


#forced inj
	$prog="R_ForceInjx_081612" if ($l[9]=~/forceinj/i);
	print "\t\t<<<< $prog >>>>\n";

	$R=10; #default
	$R=5 if ($l[8]=~/menthol/i); # menthol rats use FR5
	$o=1; #nic30 default
	$o=0.1 if ($l[9]=~/nic0|sal0|demoTraining/i);
	$o=0.5 if ($l[9]=~/nic15|sal15/i);
	$o=2 if ($l[9]=~/nic60|sal60/i);
	$o=3 if ($l[9]=~/nic90|sal90/i);
	$o=4 if ($l[9]=~/nic120|sal120/i);
	$R=$1 if ($l[9] =~/fr(\d+)/i);
	$C=$1 if ($l[9]=~/forceinj(\d+)/i);
	if ($l[9]=~/_(\d)h/i) {
		$T=60*$1;
	} elsif ($l[9]=~/_30min/i) {
		$T=30;
	} else{
		$T=150;
	}
	if (!$weight{$aid}){
		if ($l[9]=~/adul/i) {
			$weight{$aid}=250.001;
		} elsif ($l[3]=~/^m/) {
			$weight{$aid}=20.001;
		} else{
			$weight{$aid}=120.001 ;
		}
		$l[3]="noWght_".$l[3];
		$warning.="! default weight is used for $aid\n" if ($l[0] !~/\?/); 
	}

	if ($weight{$aid}>450 & $aid!~/^M/) {
		$l[3].="checkWeight";
		$warning.="$ary[1] >450g, check";
	}

	if (($weight{$aid} <90) && ($l[3]!~/^m/i)){
		$warning.= "! weight of $aid = $weight{$aid} is less than 90g\n"; 
	}

# detect if multiple animals have same weight,indicative of error when entering weights	

	$weightcnt{$weight{$aid}} ++;
	$weightgrp{$weight{$aid}}.="$aid\t";
	$cntbox{$l[1]}++;
	exit "box $l[1] ($aid) is listed twice\n" if ($cntbox{$l[1]}==2);
	next if ($aid=~/sess/i);
	$out1.= "\r\nLOAD BOX $l[1] SUBJ $aid EXPT $l[3] GROUP $l[8]$l[9] PROGRAM $prog\r\n";
	## hide the reinstatement in extinction sessions.
	if ($l[9]=~s/ext30min_AV/AV/i){
		$out1.= "\\LOAD BOX $l[1] SUBJ $aid EXPT $l[3] GROUP $l[9] PROGRAM U01_AV_reinstate\r\n"; 
	}
	if ($l[9]=~s/ext30min_MAV/MAV/i){
		$out1.= "\\LOAD BOX $l[1] SUBJ $aid EXPT $l[3] GROUP $l[9] PROGRAM R_FRx_IR_AV_120413\r\n";
		$o=0.1;
		$R=5;
		$T=30;
	}
	if ($l[9]=~s/ext30min_M//i){
		$out1.= "\\LOAD BOX $l[1] SUBJ $aid EXPT $l[3] GROUP $l[9] PROGRAM U01_menthol_reinstate\r\n";
	}


	$out1.= "SET W VALUE $weight{$aid} MAINBOX $l[1] BOXES $l[1]\r\n";
	$out1.= "SET O VALUE $o MAINBOX $l[1] BOXES $l[1]\r\n" if ($o);
	$out1.= "SET R VALUE $R MAINBOX $l[1] BOXES $l[1]\r\n" if ($R); 
	$out1.= "SET C VALUE $C MAINBOX $l[1] BOXES $l[1]\r\n" if ($C);
	$out1.= "SET T VALUE $T MAINBOX $l[1] BOXES $l[1]\r\n" if ($prog !~/PR|REINS/i);
	$out1.= "SET Z VALUE 20 MAINBOX $l[1] BOXES $l[1]\r\n" if ($l[9] =~/16h|16-h/i);
	$R=$C=$o="";
}


$out="/home/hao/macro/@abbrw[$wday]"."_$day\_". $ratID.".mac" ;

foreach $w (keys %weightcnt) {
	if ($weightcnt{$w} >= 3) {
		$warning .= "! weight for all the following rats is $w		[$weightgrp{$w}]\n";
	}
}

if ($warning) {
	open(W, ">>mpc.warning") || die "can't open warning file for writing\n"; 
	print W "\n\n!!! warning for $out\n$warning\n";
	close (W);
}

open(OUT, ">$out") || die "can't open $out for writing";
print OUT "$out1";

close (OUT);
$dropbox=$out;
$dropbox=~s/macro/Dropbox\/medpc\/macro/;



open(OUT, "$out") ||die;
while (<OUT>) {
	if($_=~/^\\x/) {
		$_=~s/"//g;
		@l=split(/,/,$_) ;
		$id=$l[2];
		open(IND, ">/home/hao/Dropbox/medpc/macro/singleAnimal/$id.mac") || die;
		next;
	}
	print IND $_;
	print  $_;
}

close(IND);

system("cp $out $dropbox");

