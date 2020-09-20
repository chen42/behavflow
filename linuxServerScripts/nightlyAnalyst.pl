#!/usr/bin/perl 
# todo
# move data from sheet1 to sheet 2 after reinstatement.
# body weight updates based on calendar day, not session number.
# check extinction => reinstatement transition for visual cue
#
#
use lib "/home/hao/perl5/lib/perl5/";
use Spreadsheet::XLSX;
use Excel::Writer::XLSX;
use Spreadsheet::ParseExcel::Utility qw(ExcelFmt LocaltimeExcel ExcelLocaltime); 
use Data::Dumper qw(Dumper);
use Date::Calc qw(Delta_Days);

if ($ARGV[0] !~/.csv/ || $ARGV[1]!~/xlsx/) {
	print "first arg must be the csv file and 2nd the xlsx file\n";
	exit;
}

$proj=$ARGV[1];
$proj=~s/.xlsx//i;

$testmode=$ARGV[2]; # disables imgur and slack

my %month = ('Jan' => 1,
	'Feb' => 2,
	'Mar' => 3,
	'Apr' => 4,
	'May' => 5,
	'Jun' => 6,
	'Jul' => 7,
	'Aug' => 8,
	'Sep' => 9,
	'Oct' => 10,
	'Nov' => 11,
	'Dec' => 12
	);


my @date = split(" ", localtime(time));

$today[0]=$month{$date[1]};
$today[1]=$date[2];
$today[2]=$date[4];


my $weekday = $date[0];

$kotrt[10]="session10";
$kotrt[11]="nic15noavfr10";
$kotrt[12]="nic15_nochange";
$kotrt[13]="nic60noavfr10";
$kotrt[14]="nic60_nochange";
$kotrt[15]="nic90noavfr10";
$kotrt[16]="nic90_nochange";
$kotrt[17]="nic30noavfr10";
$kotrt[18]="nic30_nochange";
$kotrt[19]="nic30_nochagne";
$kotrt[20]="nic30noavPR_brevital_cut_stem";
$kotrt[21]="Extinction_RasPi";
$kotrt[22]="Finished";

$u01menthol[10]="session10";
$u01menthol[11]="nic30avPR";
$u01menthol[12]="nic15avFR5_2h";
$u01menthol[13]="nic30avFR5_2h";
$u01menthol[14]="nic60avFR5_2h";
$u01menthol[15]="Brevital_nic90avFR5_2h";
$u01menthol[16]="noNic,,,,cleanspout,ext_2h";
$u01menthol[17]="noNic,,,,cleanspout,ext_2h_nochange";
$u01menthol[18]="noNic,,,,cleanspout,ext_2h_nochange";
$u01menthol[19]="noNic,,,,cleanspout,ext_2h_nochange";
$u01menthol[20]="noNic,,,,cleanspout,ext30min_AV_reinstate_FR5"; # match the menthol reinstate line below
#$u01menthol[21]="ext30min_Mth_reinstate_FR5";# match the menthol reinstate line below
#$u01menthol[22]="Check_if_finished";
#$u01menthol[22]="Check_if_finished";
#$u01menthol[23]="SA_finished_nochange";
#$u01menthol[24]="SA_finished_nochange";
$u01menthol[25]="cleanspout_nic30_forceinj5_or_justTakeBrain";
$u01menthol[26]="PleaseMoveDataToDoneFile";

$hstrt[10]="session10";
$hstrt[11]="nic15noavPR_brevital_cut_stem";
$hstrt[12]="Extinction_RasPi";
$hstrt[13]="Extinction_RasPi";
$hstrt[14]="finished";

$u01trt[10]="session10";
$u01trt[11]="0.01pctmenthol_nic15avPR";
$u01trt[12]="cleanspoutMenthol_nic15avFR5";
$u01trt[13]="cleanspoutMenthol_nochange";
$u01trt[14]="cleanspoutMenthol_nochange";
$u01trt[15]="cleanspoutMenthol_nochange";
$u01trt[16]="cleanspoutMenthol_nochange";
$u01trt[17]="cleanspoutMenthol_nic15PR_brevital_cut_stem";
$u01trt[18]="cleanspoutMenthol_ext_1h";
$u01trt[19]="cleanspoutMenthol_ext_1h";
$u01trt[20]="cleanspoutMenthol_ext_1h_or_reinstatement?";
$u01trt[21]="cleanspoutMenthol_ext_1h_or_reinstatement?";
$u01trt[22]="cleanspoutMenthol_ext_1h_or_reinstatement?";
$u01trt[23]="cleanspoutMenthol_ext_1h_or_reinstatement?";
$u01trt[24]="cleanspoutMenthol_ext_1h_or_reinstatement?";


%surgery={};
open (SUR, "/home/hao/Dropbox/Pies/surgeryratIDs") || die "surgeryRatID file missing";
while (<SUR>) {
	chomp();
	$surgery{$_}=1;
}
	
# read the  XLSX file, first two sheets 
my $excelin= Spreadsheet::XLSX -> new ("$ARGV[1]") || die;
my @row_min, @row_max, @col_min, @col_max, $row, $col, $cell, @dataIn0,  @dataIn1, $uniqid, %uniq;
my $sheetcnt=0;
for my $sheet ($excelin->worksheets()) {
	( $row_min[$sheetcnt], $row_max[$sheetcnt] ) = $sheet->row_range();
	( $col_min[$sheetcnt], $col_max[$sheetcnt] ) = $sheet->col_range();
	for $row ( $row_min[$sheetcnt] .. $row_max[$sheetcnt] ) {
		for $col ($col_min[$sheetcnt] .. $col_max[$sheetcnt]){
			$cell = $sheet->get_cell( $row, $col );
			if ($sheetcnt==0){   ## hard code sheet name because only two sheets will be used at max. this reduces the complexity in sorting. 
				$dataIn0[$row][$col]= $cell->{Val};
			} else{
				$dataIn1[$row][$col]= $cell->{Val};
			}
			if (($col==4) & ($sheetcnt==0)) {
				$uniqid=$dataIn0[$row][0].$dataIn0[$row][1].$dataIn0[4];
				$uniq{$uniqid}=1;
			}
		}
	}
	$sheetcnt++;
}

## work on the first sheet, containing unfinishd data
@sorted= sort{$a->[2] cmp $b->[2] || $a->[4] cmp $b->[4] || $a->[0] cmp $b->[0] } @dataIn0;
my %weights, $session, $id, $uid, %lastSession, %lastSessionDate, %weightUpdate, %weightLoss, %eid;
for my $r ( $row_min[0]  .. $row_max[0] ) {
	$id=$sorted[$r][4];
	$session=$sorted[$r][17];
	$weights{$id}{$session}=$sorted[$r][5];
	$chamber{$id}=$sorted[$r][3]; # chamber is from existing data
	$eid{$id}=$sorted[$r][2];
	$cue{$id}=$sorted[$r][15];
	if (($mm, $dd, $yy) = split(/\//, $sorted[$r][0])) { #convert to Excel time
 		$yy=$yy-2000 if ($yy>2000); # four digit year
		$dt=LocaltimeExcel(0,0,0,$dd,$mm-1,$yy+100); 
	} else {
		$dt=$sorted[$r][0];
	}
	#print "dateJ from sheet1 $dt\n";
	$uid=$id.$dt.$sorted[$r][1]; #for each row.
	$uniq{$uid}=1;
	# find out the last session in old data sheet
	if ($session > $lastSession{$id}){
		$lastSession{$id} = $session;
		$lastSessionDate{$id}=$dt;
	}
	## for menthol u01 force injection
	if ($session == 15) {
		$yy=$yy+2000;
		print "$yy, $mm, $dd, $today[2], $today[1], $today[0]\n";
		$diff_days=Delta_Days($yy, $mm, $dd, $today[2], $today[0], $today[1]) ;
		if ($diff_days>=10){;
			$lastSession{$id}=24;
		}
	}

	#print "dfal row = $r id $id last date, $lastSessionDate{$id} lastsession $lastSession{$id}\n";
}


# reading in new data
my $newDataFile=$ARGV[0];
my %dayLapse, @e, $dataLineCnt, %zeroAct, %zeroInact, %actTooHigh, $multiRuns, $shortRatId, $weightLossInfo;
open(ND, "<", $newDataFile) || die ("new data file $newDataFile missing");
my $addrow=$row_max[0];
while (my $dataLine = <ND>) {
	chomp($dataLine);
	$dataLineCnt++;
	#print "dataline $dataLineCnt\n";
	$addrow=$addrow+1;
	my @e=split(/,|\t/, $dataLine);
	next if $e[6]==0; ## skip data with 0 second, i.e. empty runs
	$uniqid=$e[0].$e[1].$e[4];
	next if ($uniqid==''); # emtpy line
	next if ($uniq{$uniqid});
	$runId=$e[0] . " " . $e[4];
	# extinction for menthol can have multiple 30 min runs (i.e. reinstatement within session)
	if ($hasRun{$runId} & $e[15] !~ /ext|reinst/i ) {
		$multiRuns.=$runId." ". $e[15]."\n";
	}
	$hasRun{$runId}=1;
	$id=$e[4];
	next if ( length($id) <1);
	if (length $id <6){
		$shortRatId.=$id . " ";
	}
	$e[17]=$lastSession{$id}+1; # session number
	$e[17]=0 if ($e[15] eq "320um_mentholfr5_noav_1h");
	$weight=$e[5];	
	$e[2]=~s/noWght_//;
	$eid{$id}=$e[2];
	$noav{$id}=1 if ($e[2]=~/u01m_/); # menthol only, no AV
	$zeroAct{$id}=1 if ($e[8]==0);
	$actTooHigh{$id}=1 if ($e[8]>2000);
	$zeroInact{$id}=1 if ($e[9]==0);
	$chamber{$id}=$e[3]; # update chamber is from new data
	#print ("chamber, $id, $chamber{$id}\n");
	#print "xdex id weight $id, $weight\n";
	if (!$weight) {; #missing weight
		$weightUpdate{$id} = 1;
		$weightUpdateGrp{$e[2]}=1;
	}
	# convert to excel time using the function
	if (($mm, $dd, $yy) = split(/\//, $e[0])) {
		$yy=$yy-2000 if ($yy>2000); # four digit year
		#print "l68, $mm, $dd, $yy\n";
		$e[0]=LocaltimeExcel(0,0,0,$dd,$mm-1,$yy+100); 
	}
	
	#check if data from the previous day were missing.
	$dayLapse{$id}=$e[0]-$lastSessionDate{$id};
	#print "cads $id $dayLapse{$id}, $e[0] $lastSessionDate{$id}\n";

	# check if body weight need to be updated (every three days)
	if ($lastSession{$id} >=3){
		#print "weights $weight, $weights{$id}{$lastSession{$id}}, $weights{$id}{$lastSession{$id}-1}\n";
		if ( $weight==$weights{$id}{$lastSession{$id}} & $weights{$id}{$lastSession{$id}}==$weights{$id}{$lastSession{$id}-1}) {
			$weightUpdate{$id}= 1; 
		}
		# check if there is body weight loss of more than 3g
		if ( $weights{$id}{$lastSession{$id}} -  $weight  > 3) {
			#print "$id current weight $weight; prev weight $weights{$id}{$lastSession{$id}}\n";
			#$weightLoss{$id}= 1; 
			$weightLossInfo.= "$eid{$id} *$id* before: $weights{$id}{$lastSession{$id}}g  now: $weight\g\n"; 
		}
	}
	$uid=$e[4].$e[0].$e[1];  #for each row.
	if (!$uniq{$uid}){ # skip if data already there .
		# add the new data to the exiting ones, one col at a time
		for my $addcol (0 .. $#e+1) {
			$sorted[$addrow][$addcol] = $e[$addcol];
		}
		#	print "$e[$addcol], ";		
		$lastSession{$id}++;
	}
	#print "dda \n";
}

@sorted1= grep { grep {/\w/} @$_} @sorted; #remove empty row  
#@sorted1=@sorted; #remove empty row  
@sorted1= sort{$a->[2] cmp $b->[2] || $a->[4] cmp $b->[4] || $a->[0] cmp $b->[0] } @sorted1;

# export data to new Excel file
system("mv backup/$ARGV[1].1.bak backup/$ARGV[1].2.bak");
system("mv $ARGV[1] backup/$ARGV[1].1.bak");
open (CSV, ">$proj.csv") || die; 
my $outfile=Excel::Writer::XLSX->new("$ARGV[1]");
my $date_format=$outfile->add_format(num_format=>'mm/dd/yyyy');
my $day1_format=$outfile->add_format(color=>'red');
my $day12_format=$outfile->add_format(color=>'blue');
my $day0_format=$outfile->add_format(color=>'grey');
my $bold_format=$outfile->add_format();
   $bold_format->set_bold();
my $day1_date_format = $outfile->add_format(num_format=>'mm/dd/yyyy', color=>'red'); 
my $day12_date_format = $outfile->add_format(num_format=>'mm/dd/yyyy', color=>'blue'); 
my $day0_date_format = $outfile->add_format(num_format=>'mm/dd/yyyy', color=>'grey'); 
my $outsheet, $dt, $cell, $col, $row;
$outsheet=$outfile->add_worksheet();
for $row ( 0 .. $addrow) {
	$session=$sorted1[$row][17];
	$session=20 if (($proj=~/p50/) & ($sorted1[$row][18]=~/reinst/)); 
	for $col (0 .. $col_max[0]){
		print CSV "$sorted1[$row][$col],";
		if ($col==0){
			$dt=ExcelFmt('mm/dd/yyyy', $sorted1[$row][0]); 
			if ($session == 1){
				$outsheet->write($row, $col, $dt, $day1_date_format );		
			} elsif ($session==0){
				$outsheet->write($row, $col, $dt, $day0_date_format );		
			} elsif ($session==12){
				$outsheet->write($row, $col, $dt, $day12_date_format );		
			} else {
				$outsheet->write($row, $col, $dt, $date_format );		
			}
		} elsif ($session == 1){
			$outsheet->write($row, $col, $sorted1[$row][$col], $day1_format);		
		} elsif ($session==12){
			$outsheet->write($row, $col, $sorted1[$row][$col], $day12_format);		
		} elsif ($session == 0){
			$outsheet->write($row, $col, $sorted1[$row][$col], $day0_format);		
		} elsif ($col==8 || $col==10){
			$outsheet->write($row, $col, $sorted1[$row][$col], $bold_format);		
		} else{
			$outsheet->write($row, $col, $sorted1[$row][$col]);		
		}
	}
	print CSV "\n";
}

# export the second sheet 
@sorted2= sort{$a->[2] cmp $b->[2] || $a->[4] cmp $b->[4] || $a->[0] cmp $b->[0] } @dataIn1;
@sorted2= grep { grep {/\w/} @$_} @sorted2; #remove empty row  
$outsheet2=$outfile->add_worksheet('done');
for $row ( 0 .. $row_max[1]) {
	for $col (0 .. $col_max[1]){
		$session=$sorted2[$row][17];
		if ($col==0){
			$dt=ExcelFmt('mm/dd/yyyy', $sorted2[$row][0]); 
			if ($session == 1){
				$outsheet2->write($row, $col, $dt, $day1_date_format );		
			} elsif  ($session == 12){
				$outsheet2->write($row, $col, $dt, $day12_date_format );		
			} else {
				$outsheet2->write($row, $col, $dt, $date_format );		
			}
		} elsif ($session == 1){
			$outsheet2->write($row, $col, $sorted2[$row][$col], $day1_format);		
		} elsif ($session == 12){
			$outsheet2->write($row, $col, $sorted2[$row][$col], $day12_format);		
		} elsif ($col==8 || $col==10){
			$outsheet2->write($row, $col, $sorted2[$row][$col], $bold_format);		
		} else{
			$outsheet2->write($row, $col, $sorted2[$row][$col]);		
		}
	}
}



### generate message for body weight update.
#
my $message;

if (!$dataLineCnt){
	$message.="\@hao :cry: I did not find any new data. \n";
}

my $daySkipped, $daySkipped;
foreach $key (keys %dayLapse) {
	#print "dafda $key $dayLapse{$key}\n";
	if ($dayLapse{$key} > 40000) {
		$starting{$eid{$key}}=1;
	} elsif ($dayLapse{$key} > 1) {
		$daySkipped.=$key . " ";	
		$daySkippedGrp{$eid{$key}} =1;
	}
}
#if ($daySkipped){
#	@tmp= keys(%daySkippedGrp);
#	$message.=":frowning: Just so that you know, I do have data from today for *[@tmp]* but not from yesterday ($daySkipped). \n"; 
#}

### counting the sessions. 
#my %ratSession;
#foreach $key (keys %lastSession) { #key is aid
#	$grpSession{$eid{$key}} = $lastSession{$key}+1;
#	# rat's current session 
#	$ratSession{$key} = $lastSession{$key}+1;
#	print "ls3x $key grp $eid{$key}, current session num $grpSession{$eid{$key}}\n";
#}


my %nextRatSession, $brevital;
foreach $key (keys %lastSession) { # key is aid
	# need to run first three sessions during the weekend
	if ( $lastSession{$key}>0 & $lastSession{$key}<3) {# & ($weekday eq "Fri" || $weekday eq "Sat" || $weekday eq "Sun") ){
		$donotskip=$lastSession{$key} +1;
		$nextRatSession{$key}= "*doNotSkipToday*" . $donotskip ;
	}
	if (($lastSession{$key} > 9) & ($ARGV[1] =~/p50/i)) {
		$nextRatSession{$key}=$hstrt[$lastSession{$key}+1];
		#print "working on $key currentsession $lastSession{$key}, next up $nextRatSession{$key}\n";
	} elsif (($lastSession{$key} > 9) & ($ARGV[1] =~/chrn/i)) { 
		$nextRatSession{$key}=$kotrt[$lastSession{$key}+1];
		#print "working on $key currentsession $lastSession{$key}, next up $nextRatSession{$key}\n";
		#	} elsif (($lastSession{$key} > 9) & ($ARGV[1] =~/u01/i) & ($eid{$key} =~/^B\d/)) { 
		#$nextRatSession{$key}=$u01trt[$lastSession{$key}+1];
		#print "working on $key currentsession $lastSession{$key}, next up $nextRatSession{$key}\n";
	} elsif (($lastSession{$key} > 9) & ($ARGV[1] =~/u01/i) & ($eid{$key} =~/u01m|u01a/i)) { 
		$nextRatSession{$key}=$u01menthol[$lastSession{$key}+1];
		$nextRatSession{$key} =~ s/av/noav/ if ($noav{$key}==1);
		$nextRatSession{$key} =~ s/ext30min_AV_reinstate/ext30min_Mth_reinstate/ if ($eid{$key}=~/u01m_/);
		print "working on $key currentsession $lastSession{$key}, next up $nextRatSession{$key}\n";
	} elsif (($nextRatSession{$key} =~/ext/i) & ($surgery{$key})) {
		$brevital .= $key . " ";
	} elsif (($lastSession{$key} ==15) & ($ARGV[1] =~/u01/i) & ($eid{$key} =~/u01m|u01a/i)) { 

	}
}

#reinstatement info left in slash_rats
my %reinst;
@reinst= `tail -n 30 ~/Dropbox/Pies/slash_rats.tab |grep -i rein|cut -f 4`;
foreach(@reinst){
	chomp();
	$reinst{$_}=1;
	print "reinstID, $_\n";
}

my @nextSessionMessage, $cntnext;
foreach $key (keys %nextRatSession) { # key is aid
	next if ($nextRatSession{$key}=~/nochange/);
	#print "nextSession $key\n";
	$cntnext++;
	$demo="";
	$nic="adolnic";
	#$cue="sacGrape";
	$bottle="";
	#$syringe10ml="sacGrape";
	$note="";
	$lastfour=substr $key, -4;
	if (($nextRatSession{$key}=~/Extin/i) & ($reinst{$key})) {
		$nextRatSession{$key}="Reinstate_1h_noav" ;
		$note="*WeightDemo*";
		$demo=$1 if ($eid{$key}=~/_(.)$/); 
		$bottle="sacGluGrape";
		$nic="x";
		$syringe10ml="cleanspout";
		$nextSessionMessage[$cntnext] = "$lastfour,$eid{$key},x,$demo,$bottle,,cleanspout,$nextRatSession{$key},$key,$note\n";
		#} #elsif  ($nextRatSession{$key}=~/noavPR/i){
	#	$Cue=$1 if $cue{$key}=~/(.+cs2)/;
	#	$nextSessionMessage[$cntnext] = "$lastfour,$eid{$key},adolnic,,,,$Cue,$nextRatSession{$key},$key,$note\n";
	} else {
		$nextSessionMessage[$cntnext] = "$eid{$key},$chamber{$key},$nextRatSession{$key},$key\n";
	}  
}
$message.=":raising_hand: Here are the schedule changes for today:\n" if @nextSessionMessage;
foreach(sort(@nextSessionMessage)) {
	$message.=$_ ;
}


@strGrp=keys %starting;
if (@strGrp) {
	$message.=":one: *[@strGrp]* started yesterday\n";
}

# body weight 
my $rat; #, $UpdGrp; 
for my $rat (keys %weightUpdate) {
	#	if ($ext !~/$eid{$rat}/) { # no need for weight update if starting extinction
	$weightUpdateRat.="[$eid{$rat}] *" .  $rat . "* \n" ;
		#		$weightUpdateGrp{$eid{$rat}}=1;
		#}
}

#@UpdGrp=keys %weightUpdateGrp;
#if (@UpdGrp) {
#	$grps="";
#	for $grp (keys @UpdGrp ){
#		$grps.="*[$UpdGrp[$grp]]*"."\n"
#	}
if (scalar $weightUpdateRat){
	$message.=":arrows_counterclockwise: Please update the body weight for the following rats:\n$weightUpdateRat\n"; 
}

### generate warning on weight loss.
#for $rat (keys %weightLoss) {
#	$weightLossRat.=$rat . " ". $eid{$rat} . "\n";
#}
if (scalar $weightLossInfo) {
	$message.=":sos: The following rats *lost more than 5g of weight*: Please check if they are healthy and leave a note in slack.\n $weightLossInfo"; 
}

if ($shortRatId) {
	$message.=":sos: The following rat did not have full RFID: $shortRatId\n";
}


if ($brevital) {
	$message.=":syringe: The following rats did not have *brevital* test: $brevital\n";
}

if ($multiRuns) {
	$message.=":sos: The following rat has several runs today:\n$multiRuns\n";
}


# generate images
#open(R, ">rcode.r");
#$code=<<"CODE";
#library(lattice)
#dat<-read.table(file="$proj.csv", header=T, sep=",", comment="@")
#names(dat)[5]<-"AID"
#lat0<- function (df, ti, ...){ 
# xyplot(InactiveLick+ActiveLick+Infusion~Day|AID,data=df,type="b",pch=c(19, 1, 15),scales=list(y=list(log=T)), #auto.key=FALSE) 
#}
#png(file="$proj.png", width=800, height=600)
#lat0(dat, "$proj")
##dev.off()
#CODE
#print R $code;
#system("R CMD BATCH rcode.r");

#@zA=keys(%zeroAct);
#if (@zA) {
#	foreach(@zA){
#		$boxA .= " Box $chamber{$_} ($_) " 
#	}
#	$message.= " $boxA had zero active licks. Please check the spout.\n";
#}

#@zI=keys(%zeroInact);
#if (@zI) {
#	foreach(@zI){
#		$boxI .= " Box $chamber{$_} ($_) " 
#	}
#	$message.= " $boxI had zero inactive licks. Please check the spout.\n";
#}

#@aH=keys(%actTooHigh);
#if (@aH){
#	$message.= "@aH had more than 2000 active licks. Brevital test?\n";
#}

if (!$message) {
	print $message=":hammer_and_wrench: I don't have any message to show you. You better check my code.\n";
}

#print Dumper \%dataIn1 ;

print "$message \n\n";

if (!$testmode) {
	$smile="";
	if ($proj =~/p50/i) {
		$smile=":couple: :smoking: :chart_with_upwards_trend:";
	} elsif ($proj=~/u01/i){
		$smile=":snow_capped_mountain: :snow_capped_mountain: :chart_with_upwards_trend:"
	}
	$message="$smile *IVSA data for  $proj* \n". $message; 
	$url="https://hooks.slack.com/services/T04SKCPBV/B0QNRN0LW/xxxx"; # labnotes;
	system("curl -X POST -H 'Content-type: application/json' --data '{\"text\": \"$message\", \"channel\": \"#labnotes\", \"hao\": \"Analyst Jr.\", \"icon_emoji\": \":chart_with_upwards_trend:\"}' $url"); 
}

