#!/usr/local/bin/perl 
use strict;

use List::MoreUtils qw(uniq);

###  Ask user for file name.
my $fileName = "none";
do {
	print "Please enter name of Dictionary File: <empty to exit> ";
	$fileName = <STDIN>; # I moved chomp to a new line to make it more readable
	chomp $fileName; # Get rid of newline character at the end
	exit 0 if ($fileName eq ""); # If empty string, exit.
	unless (-e $fileName) {
		print "File does not exist!\n";
	}
} until (-e $fileName) ;

### Open the file and read in the words
my @words;
open DicFile, "<$fileName" or die $!;
while (<DicFile>) {
	my $line = $_;
	#print $line;
	chomp $line;
	my @array = split(/\W+/, $line);
	foreach (@array)  {
		### could restrict to length >= 4
		#print "!$_!\n";
		if ($_ ne "") {
			push (@words, $_);
		}
	}
}

### Get Unique word list
my @unique_words = uniq @words;
#print "@unique_words\n";


## Find the Sequences and write out to a file
open WordFile, ">words" || die $!;
open SequenceFile, ">sequences" || die $!;
foreach(@unique_words) {
	findSequences($_);
}

close WordFile;
close SequenceFile;

exit 0;

### The Sequencer 
sub findSequences($word) {
	my $word = shift;
	
	my @array = split (//,$word);
	my @used;
	my $initial = "";

	doSequences(\@array,$initial, \@used, 0);
}

# Recursive walk each character and designate them as used.
sub doSequences($array,$initial, $used, $level) {
	my ($array, $initial, $used, $level) = @_;
	
	my $array = shift;
	my $initial = shift;
	my $used = shift;
	my $level = shift;
	
	if ($level == 4 || $level == scalar @$array ) {
		print SequenceFile "$initial\n";
		my $word = join("",@$array);
		print WordFile "$word\n";

		return;
	}

	for my $i (0..scalar @$array - 1) {
		my $levelString = $initial;
		if (@$used[$i]) {
			next;
		}
	
		$levelString .= @$array[$i];
		@$used[$i] = 1;
		doSequences(\@$array, $levelString, \@$used, $level + 1);
		undef @$used[$i];
	}
	
}