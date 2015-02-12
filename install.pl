#!/usr/bin/perl -X

use strict;
use CPAN;
use POSIX;

$| = 1;

my @MODULES = qw(
	Cwd
	CGI
	LWP::Simple
	MIME::Base64
	Crypt::Rijndael
	File::Basename
);
my @WIN32MODULES = qw(
	
);

my @FAILED = ();
push @MODULES, @WIN32MODULES if $^O =~ /win/i;

my $failt = '';
for my $module (@MODULES){
	print "check for $module";
	print ' ' x (30 - length $module);
	print '... ';
	my $eval = "use $module;";
	eval $eval;
	if($@){
		print 'FAILT';
		$failt .= "$module\n";
		push @FAILED, $module;
	}
	else{
		print 'OK';
	}
	print "\n";
}
if($failt ne ''){
	print "\n\nthe following modules has been failed:\n$failt\n\ninstall? [y] ";
	chomp(my $c = getchar());
	$c = 'y' if $c eq '';
	if($c =~ /^[yj]/i){
		print "yes\n";
		for my $modul (@FAILED){
			print "install $modul\n"; sleep 1;
			install $modul;
		}
		print "\nnow rerun the install.pl\n";
	}
	elsif($c =~ /^[n]/i){
		print "no\n";
	}
}
else{
	print "\nall OK\n";
}


1;
