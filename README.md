# dlc2txt
Decrypt `.dlc` files. Containers sucks. Really!

Visit [fox21.at](http://fox21.at).

## NOTE
There are no Keys in die source code.

## Requirements
- Webserver
- Perl
- Perlmodules:
	- FindBin
	- CGI
	- CGI::Carp
	- LWP::Simple
	- LWP::UserAgent
	- HTTP::Request
	- HTTP::Request::Common
	- HTTP::Response
	- MIME::Base64
	- Crypt::Rijndael
	- File::Basename

## Installation
You need to set up `$KEYA`, `$KEYB` and `$PROGNAME`.

## Special thanks to
eddy14 ([http://pyropeter.eu/41yd.de/blog/2008/11/15/dlc-geknackt/](http://pyropeter.eu/41yd.de/blog/2008/11/15/dlc-geknackt/))
