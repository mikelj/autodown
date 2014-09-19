#!/usr/bin/perl

use strict;
use warnings;

use File::Copy "cp";
use File::stat;
use Fcntl qw(:flock);
use Switch;
#use String::Util 'trim';

sub getLoggingTime;
sub unLink;
sub copyFile;

my $sym_dir = "/home/media/jayne/rtorrent/completed/";
my $remote_dir = "/home/media/jayne/rtorrent/download/";
my $base_dir = "/home/media/video/television";
my $log_file = "/var/log/autodown.log";
my $timestamp;
open(my $lfh, '>>', $log_file) or die "Could not open log file $log_file $!";
*STDERR = $lfh;

unless (flock(DATA, LOCK_EX|LOCK_NB)) {
    $timestamp = getLoggingTime();
    print $lfh "$timestamp $0 is already running. Exiting..\n";
    exit(1);
}

my @daily = ("Jeopardy", "The Daily Show", "The Colbert Report");
my @weekly = ("Last Week Tonight With John Oliver","How Its Made", "The First 48");

opendir(my $DIR, $sym_dir) || die "Error: Can't open $sym_dir: $!";
my @files = readdir($DIR);
my $i = 0;
my $j = 0;

closedir($DIR);

$timestamp = getLoggingTime();

print("$timestamp [beginning remote file sync]\n");

foreach my $f (@files) {
    #$f = trim($f);
    $i++;
    my $symsrc = "$sym_dir$f";
    switch ($f) {
        
    case /^[Jj]eopardy/ {
	    if (-f "$remote_dir$f") {
	        print("[jeopardy] $f\n");
	        copyFile($f, $daily[0]);
	    } else {
	        $timestamp = getLoggingTime();
	        print $lfh "$timestamp [broken link] $symsrc\n";
	    }
	    unLink($symsrc, $lfh);
    } 
    case /^[Tt]he.[Dd]aily.[Ss]how/ {
	    if (-f "$remote_dir$f") {
	        print("[the daily show] $f\n");
	        copyFile($f, $daily[1]);
	    } else {
	        $timestamp = getLoggingTime();
	        print $lfh "$timestamp [broken link] $symsrc\n";
	    }
	    unLink($symsrc, $lfh);
    } 
    case /^[Tt]he.[Cc]olbert.[Rr]eport/ {
	    if (-f "$remote_dir$f") {
	        print("[the colbert report] $f\n");
	        copyFile($f, $daily[2]); 
	    } else {
	        $timestamp = getLoggingTime();
	        print $lfh "$timestamp [broken link] $symsrc\n";
	    }	
	    unLink($symsrc, $lfh);
    }
    case /^[Ll]ast.[Ww]eek.[Tt]onight/ {
        if (-f "$remote_dir$f") {
            print("[last week tonight] $f\n");
            copyFile($f, $weekly[0]);
        } else {
            $timestamp = getLoggingTime();
            print $lfh "$timestamp [broken link] $symsrc\n";
        }
        unLink($symsrc, $lfh);
    } 
    else {
	    print "[no match] $f\n";
    }
    }
}
$timestamp = getLoggingTime();
print $lfh "$timestamp [sync finished] files scanned: $i files copied: $j\n";
close $lfh;

sub unLink {
    my($symsrc, $lfh) = @_;
    unlink $symsrc or warn "Could not delete $symsrc\n";
    $timestamp = getLoggingTime();
    print $lfh "$timestamp [link removed]: $symsrc\n";
}

# getLoggingTime from stackoverflow user Shizon
# http://stackoverflow.com/questions/12644322/
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
    print $lfh "$timestamp [copy complete] $size transferred in ".$diff."s (";
    printf $lfh,"%.2fKB/s\n", $rate;
    $j++;
}

__DATA__
This exists so flock() code above works
DO NOT REMOVE THIS DATA SECTION.

