This program if free for none commercial use.
Keep in mind this script does not have many hours of testing so there many be bugs.

Please disregard the comment below witch is located in some of the file.

# This program is NOT free software; you can NOT redistribute it and/or
# modify it!

And keep in mind that the main comment should be

# This program if free for none commercial use.

Flex-WPS alpha 

Requirements:
Perl 5.8.8 or 5.10
CGI
CGI::Carp
Digest::SHA1
DBI
Memoize
GD::SecurityImage - For Captcha.cgi and GD for Clock.pm located in /lib/module
Image::ExifTool - For upload.cgi only

This script can run under Mod Perl, but does not have many hours of testing.
Suggested OS is *nix or a supportable OS with case sensitivity.
Can work in a Windows OS but it does not have a case sensitive enviroment and also lacks some security. 

Only tested on Apache servers.
MySQL version 5.0.45 more or less....

Install:
The sql.txt file has all the tables for the back-end.
befor inserting table portalconfigs at about the top of the sql.txt file, please set the propper directory and URL path along with other prefferd settings.

cgi_bin_dir - the dir that has the index.cgi
cgi_bin_url - The URL path to the above location
non_cgi_dir - The dir to the none cgi folder
non_cgi_url - The URL path to the above loaction

config.pl - This file holds the info to connect to the SQL server like name, password and back-end name.
Does not support remote SQL servers, but can be edited to do so in /lib/SQLsubs.pm sub SQLConnect.

Check the path to perl in index.cgi, Captcha.cgi and upload.cgi
Upload all files for cgi-bin(flex-cgi) in ASCII mode, CHMOD all *.cgi to 755 and the rest of the files to 644.
make sure files like config.pl are not publicly accessible in HTTP.

Upload all files in the non_cgi folder in Binary mode.

The main page is index.cgi
This web portal uses JAVA script and has Ajax functions.

File serverinfo.pm located in /lib/module will only work for *nix OS (Do Not Run this file in a Windows OS).
This module can only be accessed by Admins.
URL = http://host/path/index.cgi?op=info;module=serverinfo

Login: 
Name - admin
Password - flex

Hopefully at this point everything is working.

Some things are not completed.
More documentation is need to further explain the opertaion of the system and propper usage.

sflex@cpan.org

