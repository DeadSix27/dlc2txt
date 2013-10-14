# dlc2txt
Decrypt `.dlc` files. Containers sucks. Really!

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
eddy14 - <http://pyropeter.eu/41yd.de/blog/2008/11/15/dlc-geknackt/>

## License
Copyright (C) 2013 Christian Mayer (<thefox21at@gmail.com> - <http://fox21.at>)

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
