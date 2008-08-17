package vehicle_data;

use strict; # Please use this
# Assign global variables.
use vars qw(
 %user_action %sub_action
%user_data
 );
use exporter;

# Define possible user actions.
%user_action = (
files => 1,
hello_home => 1
 );

# Define possible subload actions.
%sub_action = ( hello_home => 1 );

# The URL will be
# http://72.184.31.215/cgi-bin/001/index.tgi?op=hello;module=My_Module
sub files {
     require theme;
     theme::print_header();
     theme::print_html($user_data{theme}, 'Vehicle Computer Data');
     print <<HTML;
<table align="center" border="0" cellspacing="0" cellpadding="3" width="100%">
<tr>
<td valign="top">
<table class="bg5" border="0" cellpadding="0" cellspacing="0" width="100%" height="39">
 <tr>
 <td class="cathdl">Current Vehicles</td>
 </tr>
</table>
<table class="menuback" border="0" cellpadding="0" cellspacing="0">
 <tr>
 <td>
 <table border="0" cellpadding="1" cellspacing="0">
  <tr>
  <td class="cat"><img src="http://72.184.31.215/001/images/home1.png" alt="Home">&nbsp;<a href="http://72.184.31.215/cgi-bin/001/index.tgi" class="menu" alt="Home">Home</a></td>
  </tr>
 </table>
 </td>
 </tr>
</table>
</td>
</tr>
</table>
HTML
theme::print_html($user_data{theme}, 'Vehicle Computer Data', 1);
}

# In the Site Admin area >> Sub's Load
# Add New lib/module = 0 & 1, PM = My_Module,
# Sub = hello_home, Location = home
sub hello_home {
require theme;
     theme::print_header();
     theme::print_html($user_data{theme}, 'Hello');
     
print 'Hello Home Page';

theme::print_html($user_data{theme}, 'Hello', 1);
}


