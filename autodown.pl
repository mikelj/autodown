#!/usr/bin/perl

use strict;
use warnings;

use File::Copy "cp";
use File::stat;
#use String::Util 'trim';

sub getLoggingTime;
sub copyFile;

my $sym_dir = "/home/media/jayne/rtorrent/completed/";
my $remote_dir = "/home/media/jayne/rtorrent/download/";
my $base_dir = "/home/media/video/television";
my $log_file = "/home/mikel/autodl.log";
my $timestamp;
open(my $lfh, '>>', $log_file) or die "Could not open log file $log_file $!";

my @daily = ("Jeopardy", "The Daily Show", "The Colbert Report");
my @weekly = ("How Its Made", "The First 48");

opendir(my $DIR, $sym_dir) || die "Error: Can't open $sym_dir: $!";
my @files = readdir($DIR);

closedir($DIR);

$timestamp = getLoggingTime();

print $lfh "$timestamp [beginning remote file sync]\n";

foreach my $f (@files) {
    #$f = trim($f);
    my $symsrc = "$sym_dir$f";
    if ($f =~ /^[Jj]eopardy/) {
	if (-f "$remote_dir$f") {
	    print("[jeopardy] $f\n");
	    copyFile($f, $daily[0]);
	} else {
	    $timestamp = getLoggingTime();
	    print $lfh "$timestamp [broken link] $symsrc\n";
	}
	unlink $symsrc or warn "Could not delete $symsrc: $!";
	$timestamp = getLoggingTime();
	print $lfh "$timestamp [link removed]: $symsrc\n";
    } elsif ($f =~ /^[Tt]he.[Dd]aily.[Ss]how/) {
	if (-f "$remote_dir$f") {
	    print("[the daily show] $f\n");
	    copyFile($f, $daily[1]);
	} else {
	    $timestamp = getLoggingTime();
	    print $lfh "$timestamp [broken link] $symsrc\n";
	}
	unlink $symsrc or warn "Could not delete $symsrc: $!";
	$timestamp = getLoggingTime();
	print $lfh "$timestamp [link removed]: $symsrc\n";
    } elsif ($f =~ /^[Tt]he.[Cc]olbert.[Rr]eport/) {
	if (-f "$remote_dir$f") {
	    print("[the colbert report] $f\n");
	    copyFile($f, $daily[2]); 
	} else {
	    $timestamp = getLoggingTime();
	    print $lfh "$timestamp [broken link] $symsrc\n";
	}	
	unlink $symsrc or warn "Could not delete $symsrc: $!";
	$timestamp = getLoggingTime();
	print $lfh "$timestamp [link removed]: $symsrc\n";
    } else {
	print "[no match] $f\n";
    }
}

sub getLoggingTime {
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
    my $nice_timestamp = sprintf ( "%04d%02d%02d %02d:%02d:%02d",
                                   $year+1900,$mon+1,$mday,$hour,$min,$sec);
    return $nice_timestamp;
}

sub copyFile {
    my($f, $show) = @_;
    my $src = "$remote_dir$f";
    my $dst = "$base_dir/$show/$f";
    my $timestamp = getLoggingTime();
    print $lfh "$timestamp [copy] $remote_dir$f -> $base_dir/$show/$f\n";
    my $start = time();
    cp("$src", "$dst") or die "Error: copy failed: $!";
    my $end = time();
    $timestamp = getLoggingTime();
    my $diff = $end - $start;
    my $sb = stat($dst);
    my $size = $sb->size;
    my $rate = (($size/1024)/$diff); 
    print "$timestamp [copy complete] $size transferred in ".$diff."s (".$rate."KB/s)\n";
    print $lfh "$timestamp [copy complete] $size transferred in ".$diff."s (".$rate."KB/s)\n";

}



