package anti_spam;
# Total Guard Technology(TG)
# TG: Stove Top cooking with spam
# A journey to hell and back.
# v0.9 beta - 9/13/2007 - Walter & Dave
#
# Possable Problems: - Flex
# Not all the filters have been tested
# With no user agent the IP will be band and
# by doing that the system can ban a legitimate user
# Becase of there software firewall.
#
# Work around to Possable Problems(to get this out of beta version): - Dave
# Add a timed ban that logs these IP's & agens and will need to be viewed by the admin later.
# This code needs a larg testing ground of browser types and software firewalls
# that is why i think if you ban the IP for 5 minutes or less can give that user
# time to turn off there security and later the script gets fixed

use strict;
use vars qw( %sub_action );
use exporter;

%sub_action = ( Stove_Top => 1 );

# Since this is one way to stop spam it will be part of TG's security. - Dave
# Mother Fucking spamming bitches - Walter
# I cant wait till i can cook spam in a microwave... - Flex
sub Stove_Top {
#--Check ban
require ban;
ban::check_ban(); # added here to replace ban in subload
     my $agent = $ENV{'HTTP_USER_AGENT'} || '';
     # This list took use 2 years to collect. - Walter, Dave & Flex
     #--The List
     if ($agent =~ /atSpider/i || $agent =~ /autoemailspider/i
                || $agent =~ /(C|c)ombine/i || $agent =~ /DBrowse/i
                || $agent =~ /Demo\sBot/i || $agent =~ /(A-Z*)Surf15a/i
                || $agent =~ /EBrowse/i || $agent =~ /Educate\sSearch/i
                || $agent =~ /\AEmailSiphon\z/i || $agent =~ /EmailWolf/i
                || $agent =~ /ExtractorPro/i || $agent =~ /Full\sWeb\sBot/i
                || $agent =~ /Industry\sProgram/i || $agent =~ /infoConveraCrawler/i
                || $agent =~ /IUPUI\sResearch\sBot/i || $agent =~ /LARBIN\-EXPERIMENTAL/i
                || $agent =~ /Lincoln\sState\sWeb\sBrowser/i || $agent =~ /Mac\sFinder/i
                || $agent =~ /MFC\sFoundation\sClass\sLibrary/i || $agent =~ /Microsoft\sURL\sControl/i
                || $agent =~ /Missauga\sLocate/i || $agent =~ /Missouri\sCollege\sBrowse/i
                || $agent =~ /PEval/i || $agent =~ /Port\sHuron\sLabs/i
                || $agent =~ /Production Bot/i || $agent =~ /Program\sShareware/i
                || $agent =~ /Under\sthe\sRainbow/i || $agent =~ /Wells\sSearch(\sII|)/i # end of set 1
                || $agent =~ /e.?mail/i || $agent =~ /extract/i
                || $agent =~ /collector/i || $agent =~ /^Mozilla\/\d\.\d\s\(compatible;\sAdvanced\sEmail\sExtractor\sv\d\.\d+\)$/i
                || $agent =~ /CherryPicker/i || $agent =~ /Crescent/i
                || $agent =~ /e-collector/i || $agent =~ /^Mozilla\/\d\.\d\s\(compatible;\sMSIE\s\d\.\d;\sWindows\sNT;\sDigExt;\sDTS\sAgent$/i
                || $agent =~ /EmailCollector/i || $agent =~ /NEWT\sActiveX/i
                || $agent =~ /Teleport/i || $agent =~ /Telesoft/i
                || $agent =~ /UtilMind\sHTTPGet/i || $agent =~ /WebBandit/i
                || $agent =~ /WebEMailExtrac/i || $agent =~ /WinHttp\.WinHttpRequest\.\d+/i
                || $agent =~ /Zeus\s*Webster/i || $agent =~ /^Mozilla\/3\.Mozilla\/2\.01\s\(Win95;\sI\)$/i
                || $agent =~ /^Internet\sExplore\s{0,1}\d{0,1}\.{0,1}[a-z0-9]+$/i || $agent =~ /^Internet\sExplorer\s{0,1}\d{0,1}\.{0,1}\d{0,1}$/i
                || $agent =~ /^IE\s\d\.\d\sCompatible.*Browser$/i || $agent =~ /^Microsoft\sInternet\sExplorer\/4\.40\.426\s\(Windows\s95\)$/i
                || $agent =~ /^MSIE(\s\d\.\d|)$/i || $agent =~ /^Mozilla$/i
                || $agent =~ /^Mozilla(\\|\/)\?\?$/i || $agent =~ /^Production\sBot\s\d{4}B$/i
                || $agent =~ /WEP\sSearch/i || $agent =~ /^Harvest/i  # end set 2
                || $agent =~ /^Java/i || $agent =~ /^Jakarta/i
                || $agent =~ /User-Agent/i || $agent =~ /libwww/i
                || $agent =~ /lwp-trivial/i || $agent =~ /cure/i
                || $agent =~ /PHP\//i || $agent =~ /urllib/i
                || $agent =~ /GT::WWW/i || $agent =~ /Snoopy/i
                || $agent =~ /MFC_Tear_Sample/i || $agent =~ /HTTP::Lite/i
                || $agent =~ /PHPCrawl/i || $agent =~ /URI::Fetch/i
                || $agent =~ /Zend_Http_Client/i || $agent =~ /panscient.com/i
                || $agent =~ /IBM EVV/i || $agent =~ /Bork-edition/i
                || $agent =~ /Fetch API Request/i || $agent =~ /URI::Fetch/i
                || $agent =~ /ConveraCrawler/i || $agent =~ /PleaseCrawl/i
                || $agent =~ /[A-Z][a-z]{3,} [a-z]{4,} [a-z]{4,}/i || $agent =~ /PleaseCrawl/i
                || $agent =~ /ISC Systems/i || $agent =~ /Indy Library/i # end set 3
                || $agent =~ /AuditBot/i || $agent =~ /Boston Project/i
                || $agent =~ /Botswana/i || $agent =~ /Brick House Browse/i
                || $agent =~ /Cam Finder/i || $agent =~ /Advanced Email Extractor/i
                || $agent =~ /ContentSmartz/i || $agent =~ /Dolly Productions/i
                || $agent =~ /EmailSmartz/i || $agent =~ /Franklin Box Company/i
                || $agent =~ /Franklin Locator/i || $agent =~ /Green Research/i
                || $agent =~ /Holiday Shopping/i || $agent =~ /Joyful Systems/i
                || $agent =~ /Just a Browser/i || $agent =~ /LinkExplore.com/i
                || $agent =~ /Mail Sweeper/i || $agent =~ /Microcomputers Etc/i
                || $agent =~ /Missigua Locator/i || $agent =~ /Mizzu Labs/i
                || $agent =~ /MVAClient/i || $agent =~ /NASA Search/i
                || $agent =~ /River Valley Inc/i || $agent =~ /smartwit/i
                || $agent =~ /W3C-WebCon/i || $agent =~ /WebVulnCrawl/i || $agent =~ /compatible ;/i # end set 4
                ||!$agent) {
                # What a list of Mother Fuckers XD
                #--Ban the IP
                require SQLEdit;
                my $host = $ENV{REMOTE_ADDR} || $ENV{REMOTE_HOST} || '';
                my $DATE = time || 'DATE';
                my $string = qq(INSERT INTO `ban` VALUES ( '$host' , '$DATE' , '1', '$DATE' ););
                SQLEdit::SQLAddEditDelete($string);
                $dbh->disconnect();
                #--Error
                require error;
                error::ban_error();
                }
}
1;
# Some not added yet.... mother fuckers =P
# SetEnvIfNoCase User-Agent "Download Ninja 2.0" bad_bot
# SetEnvIfNoCase User-Agent "Fetch API Request" bad_bot
# SetEnvIfNoCase User-Agent "HTTrack" bad_bot
# SetEnvIfNoCase User-Agent "ia_archiver" bad_bot
# SetEnvIfNoCase User-Agent "JBH Agent 2.0" bad_bot
# SetEnvIfNoCase User-Agent "QuepasaCreep" bad_bot
# SetEnvIfNoCase User-Agent "Program Shareware 1.0.0" bad_bot
# SetEnvIfNoCase User-Agent "TestBED.6.3" bad_bot
# SetEnvIfNoCase User-Agent "WebAuto" bad_bot
# SetEnvIfNoCase User-Agent "WebCopier" bad_bot
# SetEnvIfNoCase User-Agent "Wget/1.8.2" bad_bot
# SetEnvIfNoCase User-Agent "Offline Explorer" bad_bot
# SetEnvIfNoCase User-Agent "Franklin Locator" bad_bot
# SetEnvIfNoCase User-Agent "LWP::Simple" bad_bot
# SetEnvIfNoCase User-Agent "Larbin" bad_bot
# SetEnvIfNoCase User-Agent "AA" bad_bot
# SetEnvIfNoCase User-Agent "Rufus Web Miner" bad_bot
# SetEnvIfNoCase User-Agent "Port Huron Labs" bad_bot
# SetEnvIfNoCase User-Agent "Sphider" bad_bot
# SetEnvIfNoCase User-Agent "voyager/1.0" bad_bot
# SetEnvIfNoCase User-Agent "DynaWeb" bad_bot
#
# SetEnvIfNoCase User-Agent "EmailCollector/1.0" spam_bot
# SetEnvIfNoCase User-Agent "EmailSiphon" spam_bot
# SetEnvIfNoCase User-Agent "EmailWolf 1.00" spam_bot
# SetEnvIfNoCase User-Agent "ExtractorPro" spam_bot
# SetEnvIfNoCase User-Agent "Crescent Internet ToolPak" spam_bot
# SetEnvIfNoCase User-Agent "CherryPicker/1.0" spam_bot
# SetEnvIfNoCase User-Agent "CherryPickerSE/1.0" spam_bot
# SetEnvIfNoCase User-Agent "CherryPickerElite/1.0" spam_bot
# SetEnvIfNoCase User-Agent "NICErsPRO" spam_bot
# SetEnvIfNoCase User-Agent "WebBandit/2.1" spam_bot
# SetEnvIfNoCase User-Agent "WebBandit/3.50" spam_bot
# SetEnvIfNoCase User-Agent "webbandit/4.00.0" spam_bot
# SetEnvIfNoCase User-Agent "WebEMailExtractor/1.0B" spam_bot
# SetEnvIfNoCase User-Agent "autoemailspider" spam_bot
#
# <Limit GET POST HEAD>
# Order Allow,Deny
# Allow from all
# Deny from env=bad_bot
# Deny from env=spam_bot
# deny from 111.11.11.11
# deny from 111.11.11.12
# </Limit>