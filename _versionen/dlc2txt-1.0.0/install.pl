#!/usr/bin/perl -X
# Created @ 30.01.2009 by TheFox@fox21.at
# Version: 1.0.2
# Copyright (c) 2009 TheFox

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Description:
# Install the required modules


use strict;
use CPAN;
use POSIX;

$| = 1;

my @MODULES = qw(
	Cwd
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
