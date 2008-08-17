package UBBC;

=head1 COPYLEFT

 $Id: UBBC.pm, v4.0 08/17/2008 11:57:28 N.K.A

 This file is part of Flex-WPS.
 Advanced Universal Bulletin Board Code Tags.

=cut

=head1 History

 v4.0 08/17/2008 11:57:28
 This file no longer holds the UBBC tag covertion and only has the HTML
 for the UBBC panel.
 UBBC tags are now handled by the AUBBC module located in /lib as AUBBC.pm

 v3.1 11/15/2007 12:28:23
 Added sub' do_all_ubbc to convert All UBBC Tags in the proper order.

 v3.0 11/14/2007 12:07:03
 Added Unicode Support, but may want to make a new sub' for it.
 Added href target="_blank" override to enable $cfg{hreftarget} = 1;

 v2.2 11/08/2007 12:11:59
 regex Speed Tweak for sub's code_highlight, do_ubbc & do_smileys
 Note: Needs more testing, some regex may need /s or/and /i added.

 v2.0 10/27/2007 05:07:49
 Advanced Universal Bulletin Board Code Tags.

=head1 TODO

 Testing

=head1 NAME

 Package UBBC

=head1 DESCRIPTION

 Advanced Universal Bulletin Board Code.

=head1 SYNOPSIS

 use UBBC;
 my $ubbc_panel = UBBC::print_ubbc_panel();
 my $ubbc_images = UBBC::print_ubbc_image();
 # est..


=head1 FUNCTIONS

 These functions are available from this package:

=cut

use strict;
use vars qw( %cfg %msg $vid );
use exporter;

=head2 print_ubbc_panel()

 # Return the UBBC panel to print in the html.
 my $ubbc_panel = print_ubbc_panel();
 # $ubbc_panel < is the value to print.

=cut

sub print_ubbc_panel {
my $option = shift;
if ($option) {
  $option = ';js=1';
}
 else {
   $option = '';
 }
 # onClick="window.open('$cfg{pageurl}/index.$cfg{ext}?op=print_smilies$option','_blank','scrollbars=yes,toolbar=no,height=270,width=270')"
        my $panel = qq(
<a href="javascript:addCode('[b][/b]')"><img src="$cfg{imagesurl}/forum/bold.gif" align="bottom" width="23" height="22" alt="$msg{bold}" border="0"></a>
<a href="javascript:addCode('[i][/i]')"><img src="$cfg{imagesurl}/forum/italicize.gif" align="bottom" width="23" height="22" alt="$msg{italic}" border="0"></a>
<a href="javascript:addCode('[u][/u]')"><img src="$cfg{imagesurl}/forum/underline.gif" align="bottom" width="23" height="22" alt="$msg{underline}" border="0"></a>
<a href="javascript:addCode('[strike][/strike]')"><img src="$cfg{imagesurl}/forum/strike.gif" align="bottom" width="23" height="22" alt="Strike" border="0"></a>
<a href="javascript:addCode('[left][/left]')"><img src="$cfg{imagesurl}/forum/left.gif" align="bottom" width="23" height="22" alt="Left" border="0"></a>
<a href="javascript:addCode('[center][/center]')"><img src="$cfg{imagesurl}/forum/center.gif" align="bottom" width="23" height="22" alt="$msg{center}" border="0"></a>
<a href="javascript:addCode('[right][/right]')"><img src="$cfg{imagesurl}/forum/right.gif" align="bottom" width="23" height="22" alt="Right" border="0"></a>
<a href="javascript:addCode('[sup][/sup]')"><img src="$cfg{imagesurl}/forum/sup.gif" align="bottom" width="23" height="22" alt="sup" border="0"></a>
<a href="javascript:addCode('[sub][/sub]')"><img src="$cfg{imagesurl}/forum/sub.gif" align="bottom" width="23" height="22" alt="sub" border="0"></a>
<a href="javascript:addCode('[pre][/pre]')"><img src="$cfg{imagesurl}/forum/pre.gif" align="bottom" width="23" height="22" alt="pre" border="0"></a>
<br>
<a href="javascript:addCode('[img][/img]')"><img src="$cfg{imagesurl}/forum/img.gif" align="bottom" width="23" height="22" alt="Image" border="0"></a>
<a href="javascript:addCode('[url][/url]')"><img src="$cfg{imagesurl}/forum/url.gif" align="bottom" width="23" height="22" alt="$msg{insert_link}" border="0"></a>
<a href="javascript:addCode('[email][/email]')"><img src="$cfg{imagesurl}/forum/email2.gif" align="bottom" width="23" height="22" alt="$msg{insert_email}" border="0"></a>
<a href="javascript:addCode('[code][/code]')"><img src="$cfg{imagesurl}/forum/code.gif" align="bottom" width="23" height="22" alt="$msg{insert_code}" border="0"></a>
<a href="javascript:addCode('[quote][/quote]')"><img src="$cfg{imagesurl}/forum/quote2.gif" align="bottom" width="23" height="22" alt="$msg{quote}" border="0"></a>
<a href="javascript:addCode('[ol]Title [li=1][/li] [li][/li] [li][/li][/ol]')"><img src="$cfg{imagesurl}/forum/list.gif" align="bottom" width="23" height="22" alt="$msg{insert_list}" border="0"></a>
<a href="javascript:void(0)" onClick="window.open('$cfg{pageurl}/index.$cfg{ext}?op=print_smilies$option','_blank','scrollbars=yes,toolbar=no,height=270,width=270')"><img src="$cfg{imagesurl}/forum/smilie.gif" align="bottom" width="23" height="22" alt="$msg{insert_smilie}" border="0"></a>
<a href="javascript:addCode('[wiki://]')"><img src="$cfg{imagesurl}/forum/wiki.gif" align="bottom" width="23" height="22" alt="wiki" border="0"></a>
<a href="javascript:addCode('[wkid://]')"><img src="$cfg{imagesurl}/forum/wkid.gif" align="bottom" width="23" height="22" alt="wkid" border="0"></a>
<a href="javascript:addCode('[id://]')"><img src="$cfg{imagesurl}/forum/forum.gif" align="bottom" width="23" height="22" alt="forum" border="0"></a>
<br>
<a href="javascript:addCode('[search://]')"><img src="$cfg{imagesurl}/forum/search.png" align="bottom" width="23" height="22" alt="search" border="0"></a>
<a href="javascript:addCode('[wikipedia://]')"><img src="$cfg{imagesurl}/forum/wikipedia.gif" align="bottom" width="23" height="22" alt="wikipedia" border="0"></a>
<a href="javascript:addCode('[wikiquote://]')"><img src="$cfg{imagesurl}/forum/wikiquote.gif" align="bottom" width="23" height="22" alt="wikiquote" border="0"></a>
<a href="javascript:addCode('[wikibooks://]')"><img src="$cfg{imagesurl}/forum/wikibooks.gif" align="bottom" width="23" height="22" alt="wikibooks" border="0"></a>
<a href="javascript:addCode('[wikisource://]')"><img src="$cfg{imagesurl}/forum/wikisource.gif" align="bottom" width="23" height="22" alt="wikisource" border="0"></a>
<a href="javascript:addCode('[cpan://]')"><img src="$cfg{imagesurl}/forum/cpan.gif" align="bottom" width="23" height="22" alt="cpan" border="0"></a>
<a href="javascript:addCode('[google://]')"><img src="$cfg{imagesurl}/forum/google.gif" align="bottom" width="23" height="22" alt="google" border="0"></a>
<br>
<b>Font Color:</b> <select name="color" onChange="showColor(this.options[this.selectedIndex].value)">
<option value="Black" selected>$msg{black}</option>
<option value="Red">$msg{red}</option>
<option value="Yellow">$msg{yellow}</option>
<option value="Pink">$msg{pink}</option>
<option value="Green">$msg{green}</option>
<option value="Orange">$msg{orange}</option>
<option value="Purple">$msg{purple}</option>
<option value="Blue">$msg{blue}</option>
<option value="Beige">$msg{beige}</option>
<option value="Brown">$msg{brown}</option>
<option value="Teal">$msg{teal}</option>
<option value="Navy">$msg{navy}</option>
<option value="Maroon">$msg{maroon}</option>
<option value="LimeGreen">$msg{lime}</option>
</select>);
        return $panel;
}

=head2 print_ubbc_image_selector()

 # Print the UBBC image selector.
 my $image_select = print_ubbc_image_selector($select_icon);
 #  $image_select < print this value.

=cut

sub print_ubbc_image_selector {
        my $selected_icon = shift || 'xx';

        # Display the pre selected icon?
        my $pre_selected_icon = '';
        if ($selected_icon) {
        my $thumb = '';
        if($selected_icon eq 'thumbup') { $thumb = $msg{thumb_up}; }
        elsif($selected_icon eq 'thumbdown') { $thumb = $msg{thumb_down}; }
        elsif($selected_icon eq 'exclamation') { $thumb = $msg{excl_marl}; }
        elsif($selected_icon eq 'question') { $thumb = $msg{question_mark}; }
        elsif($selected_icon eq 'xx') { $thumb = $msg{standard}; }
        elsif($selected_icon eq 'lamp') { $thumb = $msg{lamp}; }
                $pre_selected_icon = qq(<option value="$selected_icon" selected>$thumb</option>\n);
        }

        my $selector = <<HTML;
<script language="javascript" type="text/javascript"><!--
function showImage() {
document.images.icons.src="$cfg{imagesurl}/forum/"+
document.creator.icon.options[document.creator.icon.selectedIndex].value+
".gif";
}
// --></script>
<select name="icon" onChange="showImage()">
$pre_selected_icon
<option value="xx">$msg{standard}</option>
<option value="thumbup">$msg{thumb_up}</option>
<option value="thumbdown">$msg{thumb_down}</option>
<option value="exclamation">$msg{excl_marl}</option>
<option value="question">$msg{question_mark}</option>
<option value="lamp">$msg{lamp}</option>
</select>
<img src="$cfg{imagesurl}/forum/$selected_icon.gif" name="icons" width="16"
height="16" border="0" hspace="15" alt=""></td>
</tr>
<tr>
<td valign=top><b>$msg{textC}</b></td>
<td>
<script type="text/javascript" src="$cfg{non_cgi_url}/themes/ubbc.js"></script>
<script language="javascript" type="text/javascript">
<!--
function addCode(anystr) {
insertAtCursor(document.creator.message, anystr);
}
function showColor(color) {
var colortag = "[color="+color+"][/color]";
insertAtCursor(document.creator.message, colortag);
}
// -->
</script>
HTML
        return $selector;
}

1;
