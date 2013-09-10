#!/usr/bin/perl -w
# 0xFF21
# Created @ 01.04.2009 by TheFox@fox21.at
# Version: 1.0.0
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
# Decrypt your .dlc files

# THX to
# eddy14 (http://eddysblog.phpnet.us/blog/2008/11/15/dlc-geknackt/)


use strict;
use Cwd;
use CGI;
use LWP::Simple;
use MIME::Base64;
use Crypt::Rijndael;
use File::Basename;


$| = 1;

my $SOFTWARE_VERSION = '1.0.0';

my $KEYA = '';
my $KEYB = '';
my $PROGNAME = ''; # program identification like 'jdtc5', 'rsdc', 'load', ...

my $JLINK = 'http://service.jdownloader.org/dlcrypt/service.php?destType='.$PROGNAME.'&srcType=dlc&data=';
my $TAILLEN = 88;
my $IV = pack 'H*', '00000000000000000000000000000000';


sub xorcrypt{
	my($data, $key) = @_;
	my $encrypt = '';
	my $kc = 0;
	my $kl = length $key;
	for(my $i = 0; $i < length $data; $i++){
			my $c = substr $data, $i, 1;
			$kc = 0 if $kc > $kl - 1;
			my $k = substr $key, $kc, 1;
			$kc++;
			$encrypt .= chr(ord($c) ^ ord($k));
			#print "$i: >$c<\n"; sleep 1;
	}
	$encrypt;
}

sub returnHex{
	my($str) = @_;
	my $rv = '';
	for(my $i = 0; $i < length($str); $i++){
		my $c = ord(substr($str, $i, 1));
		$rv .= sprintf('%02x', $c);
	}
	$rv;
}


my $pwd = cwd();
# optional
if(-e "$pwd/keys"){
	open KEYS, "< $pwd/keys";
	my $keys = join '', <KEYS>;
	close KEYS;
	$keys = decode_base64($keys);
	if($keys =~ /^([^:]+)::([^:]+)::([^:]+)$/si){
		($PROGNAME, $KEYA, $KEYB) = ($1, $2, $3);
	}
}


my $cgi = new CGI();
my %input = ();

if(!defined @ARGV){
	for my $key ($cgi->param()){
		$input{$key} = $cgi->param($key);
	}
}
else{
	for my $row (@ARGV){
		if(defined $row){
			my @s = split '=', $row, 2;
			$input{$s[0]} = $s[1] if @s > 1;
		}
	}
}

$input{'a'} = 'default' unless defined $input{'a'};
$input{'sa'} = 'default' unless defined $input{'sa'};

my $action = $input{'a'} ;
my $subaction = $input{'sa'};
 
if($action eq 'default'){
	print "Content-type: text/html\n\n";
	my $error = '';
	$error = '<font color="#ff0000"><b>ERROR: You need to set $KEYA and $KEYB and $PROGNAME!!!</b></font><br />' if $KEYA eq '' || $KEYB eq '' || $PROGNAME eq '';
	print qq(
		<html>
			<head>
				<title>dlc Decrypter v. $SOFTWARE_VERSION from fox21.at</title>
			</head>
			<body>
				$error
				<form action="" method="post">
					<input type="hidden" name="a" value="exec" />
					<textarea name="content" rows="10" cols="60"></textarea><br /><br />
					<input type="submit" value="Get" />
				</form>
			</body>
		</html>
	);
}
elsif($action eq 'exec'){
	print "Content-type: text/html\n\n";
	
	my $error = '';
	$error = '<font color="#ff0000"><b>ERROR: You need to set $KEYA and $KEYB and $PROGNAME!!!</b></font><br />' if $KEYA eq '' || $KEYB eq '' || $PROGNAME eq '';
	if($error ne ''){
		print $error;
		exit 0;
	}
	
	my $out = '';
	my $dlc = $input{'content'};
	
	my $tail = substr $dlc, length($dlc) - $TAILLEN;
	$dlc = substr $dlc, 0, length($dlc) - length($tail);
	$dlc = decode_base64($dlc);
	
	my $response = '';
	$response = get($JLINK.$tail);
	
	$response =~ s/^<rc>//i;
	$response =~ s/<.rc>$//i;
	
	$response = decode_base64($response);
	if(length($response) * 8 != 128){
		print '<font color="#ff0000"><b>ERROR: Get wrong key from server. Maybe you are blocked by jd server</b></font><br />';
		exit 0;
	}
	
	
	my $cipher = Crypt::Rijndael->new($KEYA, Crypt::Rijndael::MODE_ECB());
	$cipher->set_iv($IV);
	$response = $cipher->decrypt($response);
	my $newkey = xorcrypt($response, $KEYB);
	my $newdlc = $newkey.$dlc;
	my $xml = '';
	
	$cipher = Crypt::Rijndael->new($newkey, Crypt::Rijndael::MODE_ECB());
	$cipher->set_iv($IV);
	
	while(length $dlc > 0){
		my $rest = length($dlc) >= 16 ? 16 : length $dlc;
		my $cutold = substr $dlc, 0, $rest;
		my $cutnew = substr $newdlc, 0, $rest;
		$dlc = substr $dlc, $rest;
		$newdlc = substr $newdlc, $rest;
		$cutold = $cipher->decrypt($cutold);
		$cutold = xorcrypt($cutold, $cutnew);
		$xml .= $cutold;
	}
	
	$xml = decode_base64($xml);
	
	my @strs = ();
	push @strs, $1 while $xml =~ />([a-z0-9\+\/_=-]+)</sig;
	push @strs, $1 while $xml =~ /"([a-z0-9\+\/_=-]+)"/sig;
	
	for my $search (@strs){
		while(length($search) % 4){
			$search .= '=';
		}
		my $db64 = decode_base64($search);
		$xml =~ s/\Q$search\E/$db64/s;
	}
	
	if($xml =~ /<content>(.*)<.content>/sig){
		my $xmlContent = $1;
		for my $xmlUrl (split '<url>', $xmlContent){
			if($xmlUrl =~ /^(.*)<.url>/si){
				$out .= "$1\n";
			}
		}
	}
	
	print qq(<textarea rows="20" cols="80">$out</textarea>);
}




1;

