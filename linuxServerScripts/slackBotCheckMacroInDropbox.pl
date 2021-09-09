#!/usr/bin/perl
#
use Date::Calc qw(Day_of_Week);
my @abbrw= qw(Sun Mon Tue Wed Thu Fri Sat Sun);
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time); 
$year += 1900; 
$mon++; 
$mon="0".$mon if (length($mon) ==1);
$mday="0".$mday if (length($mday) ==1);

my $sysday="$year\-$mon\-$mday"; 
my $sysday2="$mon\-$mday\-$year"; 
my $sent;

my $message="\@hao, your Crab here. ";
my $schedulefile="/home/hao/Dropbox/medpc/schedule.$sysday.pdf";
my $macdir="/home/hao/Dropbox/medpc/macro/";
my $p50dir="/home/hao/Dropbox/ChenLab/P50Data/";

if (!-e $schedulefile) {
	$message.="Did you forget to update the schedule file AGAIN?! " ;
	$sent=1;
}

if (!-d $macdir) {
	$message.="Someone deleted the macro directory!\n";
	$sent=1;
}

# missing macro files;
opendir(my $mac, $macdir) ;
@out=grep { /$sysday2/ } readdir($mac);
if (!@out){
	$message.= "You also need to update the macro files. " ;
	$sent =1;
}

# conflicted copy of the database
opendir(my $sql, $p50dir) || die ;
@conflict=grep { /conflicted/ } readdir($sql);
@conflict=grep { /sqlite/ } @conflict;
if (@conflict){
	$message.= "Someone created a conflicted version of your precious sqlite database. Pin this message *NOW*\n " ;
	$sent =1;
}

my $kodir="/home/hao/Dropbox/ChenLab/knockoutrats";
opendir(my $sql2, $kodir) || die ;
@conflict=grep { /conflicted/ } readdir($sql2);
@conflict=grep { /sqlite/ } @conflict;
if (@conflict){
	$message.= "There is a conflicted version of the knockout sqlite database. Pin this message *NOW*\n " ;
	$sent =1;
}

if ($sent){
	print "sent $message\n";
	system("curl -X POST -H 'Content-type: application/json' --data '{\"text\": \"$message\", \"channel\": \"#general\", \"hao\": \"monkey-bot\", \"icon_emoji\": \":crab:\"}' https://hooks.slack.com/services/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");
} else {
	$message="Just checking... Everything looks great at the moment.";
	system("curl -X POST -H 'Content-type: application/json' --data '{\"text\": \"$message\", \"channel\": \"#general\", \"hao\": \"monkey-bot\", \"icon_emoji\": \":crab:\"}' https://hooks.slack.com/services/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");
}

