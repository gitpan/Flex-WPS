package theme;

# version 0.95 11/09/2007 By: N.K.A.
# Added table for Ajax Methods to load in header when needed.
#
# 0.93 10/30/2007 By: me
# Cleaned up a lot of crap
# but changing of themes not made...
#
use strict;
use vars qw(
%sub_action
    $query %cfg $dbh %nav %msg
    %user_data %usr
    );
#use lib '.';
use exporter;

# Define possible sub actions.
%sub_action = (menu_print => 1, user_panel => 1);


# ---------------------------------------------------------------------
# Print the HTTP header.
# ---------------------------------------------------------------------
sub print_header {
my $cookie1 = shift;
my $cookie2 = shift;

if ($cookie2 && $cookie1) {
print $query->header(
-cookie  => [$cookie1, $cookie2],
-expires => 'now',
-charset => $cfg{codepage},
);
}
 elsif ($cookie1 && !$cookie2) {
print $query->header(
-cookie  => $cookie1,
-expires => 'now',
-charset => $cfg{codepage},
);
}
 else {
print $query->header(
-expires => 'now',
-charset => $cfg{codepage},
);
 }
}
# ---------------------------------------------------------------------
# Print meta tags to site HTML output.
# ---------------------------------------------------------------------
sub get_meta_tags {
my $data = '';

my($query1) = "SELECT * FROM meta_tags";
my $sth = $dbh->prepare($query1);
$sth->execute || return;
while(my @row = $sth->fetchrow)  {
if($row[0]){ $data .= qq(<meta name="description" content="$row[0]">); }
if ($row[1]) { $data .= qq(
<meta name="keywords" content="$row[1]">
); }
}
$sth->finish;

return unless $data;
return $data;
}
# ---------------------------------------------------------------------
# Evaluate tags for a theme
# ---------------------------------------------------------------------
sub eval_theme_tags {
my $string     = shift || '';
return unless $string;
$string =~ s|%cgi_bin_url%|$cfg{cgi_bin_url}|go;
$string =~ s|%non_cgi_url%|$cfg{non_cgi_url}|go;
# $string =~ s|%date%|$date|g;
$string =~ s|%pageurl%|$cfg{pageurl}|go; # Added
$string =~ s|%default_theme%|$cfg{default_theme}|go; # Added
$string =~ s|%themesurl%|$cfg{themesurl}|go; # Added
$string =~ s|%ext%|$cfg{ext}|go;
$string =~ s|%pagename%|$cfg{pagename}|go;
$string =~ s|%pagetitle%|$cfg{pagetitle}|go;
$string =~ s|%language%|$cfg{lang}|go;
$string =~ s|%codepage%|$cfg{codepage}|go;
$string =~ s|%imagesurl%|$cfg{imagesurl}|go;
# $string =~ s|%theme_name%|$theme_name|g;
return $string;
}
#
sub main_menu {
my @menu_content = @_;
my $main_menu    = box_header($nav{main_menu});
foreach (@menu_content) {
# Add special images to the main menu - By: S_Flex
my ($title, $link, $image1, $image2) = split (/\|/, $_);
if($image1 && $image2) { $main_menu .= menu_item($link, $title, $image1, $image2);
} elsif ($image1) { $main_menu .= menu_item($link, $title, $image1, '');
} elsif ($image2) { $main_menu .= menu_item($link, $title, '', $image2);
} else { $main_menu .= menu_item($link, $title, '', ''); }
}
$main_menu .= box_footer();

return $main_menu;
}
sub menu_print {
my @data = ();
my($query1) = "SELECT * FROM mainmenu WHERE active=1";
my $sth = $dbh->prepare($query1);
$sth->execute;
while(my @row = $sth->fetchrow) {

if (!$row[4]) { $row[4] = ''; }
if (!$row[3]) { $row[3] = ''; }

if ($row[2] && $row[1]) {
     $row[2] = eval_theme_tags($row[2]);
     if(@data) {
         @data = (@data,"$row[1]|$row[2]|$row[3]|$row[4]");
         }
          else {
                @data = ("$row[1]|$row[2]|$row[3]|$row[4]");
                }
     }

}
$sth->finish;
my $mainmenu = main_menu(@data);
print $mainmenu;
}
sub user_panel {
        # Get help topic.
#         my $script_name = $ENV{SCRIPT_NAME};
#         $script_name =~ s(^.*/)();
#         my ($topic, undef) = split (/\./, $script_name);

        my $user_panel = box_header("$msg{my} Account");

        # Print help link.
#         $user_panel .=
#             menu_item("$cfg{pageurl}/help.$cfg{ext}?topic=$topic", $nav{help});
        # Print register link for guests only.
my $sth = "SELECT * FROM usermenu";
$sth = $dbh->prepare($sth);
$sth->execute || return;
while(my @row = $sth->fetchrow) {
#my %cp=(row => $row[0],row1 => $row[1],row2 => $row[2],row3 => $row[3],row4 => $row[4],row5 => $row[5],row6 => $row[6]);
$row[2] = eval_theme_tags($row[2]);
# Print admin links if user is authorized.
if ($user_data{sec_level} eq $usr{admin} && ($usr{admin} eq $row[5] || $usr{mod} eq $row[5])) {
   $user_panel .= menu_item($row[2],$row[1],$row[3],$row[4]); }
# Print mod links if user is authorized.
elsif ($user_data{sec_level} eq $usr{mod} && $usr{mod} eq $row[5]) {
   $user_panel .= menu_item($row[2],$row[1],$row[3],$row[4]); }
# Print link if user is authorized.
elsif ($user_data{sec_level} eq $usr{anonuser} && $usr{anonuser} eq $row[5]) {
   # Link Print              Link      Title    image 1  image 2
   $user_panel .= menu_item($row[2],$row[1],$row[3],$row[4]); }
elsif ($usr{user} eq $row[5] &&
($user_data{sec_level} eq $usr{user} || $user_data{sec_level} eq $usr{admin} || $user_data{sec_level} eq $usr{mod})) {
   # Link Print              Link      Title    image 1  image 2
   $user_panel .= menu_item($row[2],$row[1],$row[3],$row[4]);
   }
}
$sth->finish;

$user_panel .= box_footer();

print $user_panel;
}
sub menu_item {
my ($page, $title, $image, $image1) = @_;
my $logout = '';
if ($title eq $nav{logout}) {
   $logout = ' onclick="javascript:return confirm(\'Are you sure you want to Logout?\')"';
}
# Default
my $menu = qq(<img src="$cfg{themesurl}/standard/images/dot.gif" alt="$title">&nbsp;<a href="$page" class="menu" alt="$title"$logout>$title</a>);
if ($image && $image1) { # Link & Dot image
$menu = qq(<img src="$cfg{imagesurl}/$image1" alt="$title">&nbsp;<a href="$page" alt="$title"$logout><img src="$cfg{imagesurl}/$image" border="0" alt="$title"></a>);
} elsif (!$image1 && $image) { # Link image
$menu = qq(<img src="$cfg{themesurl}/standard/images/dot.gif" alt="$title">&nbsp;<a href="$page" alt="$title"$logout><img src="$cfg{imagesurl}/$image" border="0" alt="$title"></a>);
} elsif (!$image && $image1) { # Dot image
$menu = qq(<img src="$cfg{imagesurl}/$image1" alt="$title">&nbsp;<a href="$page" class="menu" alt="$title"$logout>$title</a>);
}
$menu = <<HTML;
<tr>
<td class="cat">$menu</td>
</tr>
HTML
return $menu;
}
sub block {
my $position = shift || '';
my $block = '';
my($query1) = "SELECT * FROM blocks WHERE type='$position' AND active='1'";
my $sth = $dbh->prepare($query1);
$sth->execute;
while(my @row = $sth->fetchrow)  {
$block .= box_header($row[2]);
$row[3] = eval_theme_tags($row[3]);
$block .= '<tr><td>'. $row[3] . '</td></tr>';
$block .= box_footer();
}
$sth->finish;

print $block;
}
sub box_header {
my $title = shift;    # align="center"
my $box_header = <<HTML;
<table class="bg5" border="0" cellpadding="0" cellspacing="0" width="192" height="39">
<tr>
<td width="168" class="cathdl">$title</td>
<td class="cathdl" align="right"><img src="$cfg{themesurl}/standard/images/splat.gif" border="0" alt=""></td>
</tr>
</table>
<table class="menuback" border="0" cellpadding="0" cellspacing="0" width="192">
<tr>
<td><table border="0" cellpadding="1" cellspacing="0" width="180">
HTML
return $box_header;
}

# ---------------------------------------------------------------------
# Print the footer of a menu box.
# ---------------------------------------------------------------------
sub box_footer {
my $box_footer = <<HTML;
</table></td>
</tr>
</table><br>
HTML
return $box_footer;
}
# ---------------------------------------------------------------------
# Print the HTML template.
# ---------------------------------------------------------------------
sub print_html {
# Theme is not used yet
my ($theme, $page_name, $type, $ajax_name) = @_;
# my ($theme, $page_name, $type) = ('', '', '');
# $theme = shift;
# $page_name = shift;
# $type = shift;
#my $user_panel = user_panel();
my $meta_tags = get_meta_tags() || '';
#use lib '.';
my %cp = ();
# Default Them is loaded here So edit/check the portal config and delete me
my($query1) = "SELECT `themename`, `theme_top`, `theme_1`, `theme_2` FROM `themes` WHERE `active` = '1'";
 $query1 = "SELECT `themename`, `theme_3`, `theme_4`  FROM `themes` WHERE `active` = '1'" if $type;
my $sth = $dbh->prepare($query1);
$sth->execute;
while(my @row = $sth->fetchrow) {
$cfg{default_theme} = $row[0];

$row[1] = eval_theme_tags($row[1]) if !$type;
$row[2] = eval_theme_tags($row[2]) if !$type;
$row[3] = eval_theme_tags($row[3]) if !$type;

$row[1] = eval_theme_tags($row[1]) if $type;
$row[2] = eval_theme_tags($row[2]) if $type;

%cp=(row => $row[1],row1 => $row[2],row2 => $row[3]) if !$type;
%cp=(row3 => $row[1],row4 => $row[2]) if $type;
}
$sth->finish;
# Ajax scripts
my $ajax_code = '';
if (!$type && $ajax_name) {
$query1 = "SELECT `script` FROM `ajax_scripts` WHERE `name` = '$ajax_name'";
$sth = $dbh->prepare($query1);
$sth->execute;
while(my @row = $sth->fetchrow) {
      if ($row[0]) {
      $row[0] = eval_theme_tags($row[0]);
             $ajax_code = $row[0];
      }
}
$sth->finish;
}

# //  parameters fix for POST
# // var poststr = "mytextarea1=" + escape(encodeURI(document.getElementById("mytextarea1").value ))
# // +"&mytextarea2=" + escape(encodeURI( document.getElementById("mytextarea2").value ));

# Print the header.
if (!$type) {
# Top of Theme was printed
$cfg{theme_printed} = 1;
$page_name = " - $page_name" if $page_name ne '';
print <<HTML;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
<title>$cfg{pagetitle}$page_name</title>
<meta http-equiv="Content-Type" content="text/html; charset=$cfg{codepage}">
$meta_tags
<link rel="stylesheet" href="$cfg{themesurl}/$cfg{default_theme}/style.css" type="text/css">
<script type="text/javascript" language="JavaScript">
// Start built-in Ajax
var req;
var ReqOp1 = '';
var ReqOp2 = '';
// POST Method
function doPOSTRequest(url, processNewReq, parameters, NewReqOp1, NewReqOp2) {
    if (NewReqOp1 != '') { ReqOp1 = NewReqOp1 };
    if (NewReqOp2 != '') { ReqOp2 = NewReqOp2 };
    if (window.XMLHttpRequest) { // branch for native XMLHttpRequest object
        req = new XMLHttpRequest();
    } else if (window.ActiveXObject) { // branch for IE/Windows ActiveX version
        req = new ActiveXObject("Microsoft.XMLHTTP");
    }
        if (req) {
            req.onreadystatechange = processNewReq;
            req.open('POST', url, true);
            req.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
            req.setRequestHeader("Content-length", parameters.length);
            req.setRequestHeader("Connection", "close");
            req.send(parameters);
        }
}
// GET Method
function doGETRequest(url, processNewReq, NewReqOp1, NewReqOp2)
{
    if (NewReqOp1 != '') { ReqOp1 = NewReqOp1 };
    if (NewReqOp2 != '') { ReqOp2 = NewReqOp2 };
    var myLoaded = '';
    if (window.XMLHttpRequest) { // branch for native XMLHttpRequest object
        req = new XMLHttpRequest();
        myLoaded = 1;
    } else if (window.ActiveXObject) { // branch for IE/Windows ActiveX version
        req = new ActiveXObject("Microsoft.XMLHTTP");
        myLoaded = 2;
    }
            if (req) {
            req.onreadystatechange = processNewReq;
            req.open("GET", url, true);
            if (myLoaded == 2) { req.send(); }
            if (myLoaded == 1) { req.send(null); }
            }
}
// Insert Text and can goto another function
function processReqChangeMany()
{
    // only if req shows "complete"
    if (req.readyState == 4) {
        // only if "OK"
        if (req.status == 200) {
            // ...processing statements go here...
            result    = req.responseText;
            document.getElementById(ReqOp1).innerHTML=result;
            ReqOp1 = '';
            if ( ReqOp2 != '' ) { ReqOp2(); ReqOp2 = ''; }
        } else {
            alert("There was a problem retrieving the XML data:\\n" + req.statusText);
        }
    }
}
// End built-in Ajax
$ajax_code
</script>
</head>
<body>
$cp{row}
HTML
# Subs Load - Location 2
SQLSubLoad::SQLSubLoad('2');
# Theme html theme_1
print $cp{row1};
# Subs Load - Location 3
SQLSubLoad::SQLSubLoad('3');
# Left Block
block('left');
# Theme html theme_2
print $cp{row2};
# Subs Load - Location 4
SQLSubLoad::SQLSubLoad('4');
}
# Print the footer. theme_bottom($location);
if ($type) {
# Theme html theme_3
print $cp{row3};
# Subs Load - Location 5
SQLSubLoad::SQLSubLoad('5');
# Right Block
block('right');
# Theme html theme_4
print $cp{row4};
# Subs Load - Location 6
SQLSubLoad::SQLSubLoad('6');
# End of HTML
print <<HTML;
</body>
</html>
HTML
# Disconnect SQL
$dbh->disconnect() unless (!$cfg{db_fault_error});
exit;
 }
}
1;
