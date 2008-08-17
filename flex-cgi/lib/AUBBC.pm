package AUBBC;

use strict;
use warnings;

our ( $DEBUG_AUBBC, $BAD_MESSAGE, %SMILEYS ) = ( '', 'Error', () );

my ( $AUBBC_VERSION, $start_the_time, $end_the_time, %Build_AUBBC ) = ( '0.7', 0, 0, () );

my %AUBBC = (
aubbc => 1,
utf => 1,
smileys => 1,
highlight => 1,
no_bypass => 0,
for_links => 0,
aubbc_escape => 1,
icon_image => 1,
image_hight => 60,
image_width => 90,
image_border => 0,
image_wrap => 1,
href_target => 0,
images_url => '',
html_type => 'html',
code_class => '',
code_extra => '',
href_class => '',
quote_class => '',
quote_extra => '',
other_sites_pattern => 'a-zA-Z\d\:\-\s\_\/\.',
bad_pattern => 'view\-source:|script:|mocha:|mailto:|about:|shell:|\.js',
script_escape => 1,
protect_email => 1,
);

sub new {
$end_the_time = time + 30;

warn "ENTER new" if $DEBUG_AUBBC;

 settings_prep();

     my $self  = shift;
     my $class = ref($self) || $self;

    if ($DEBUG_AUBBC) {
         warn "CREATING $self";
         my $uabbc_settings = '';
         foreach my $set_key (keys %AUBBC) {
                 DOS_prevent();
                 $uabbc_settings .= $set_key . ' =>' . $AUBBC{$set_key} . ', ';
         }
         warn "AUBBC Settings: $uabbc_settings";
         warn "END new";
    }
    return $self;
}

sub DESTROY {
    if ($DEBUG_AUBBC) {
         my $self = shift;
         warn "DESTROY $self";
    }
}

sub settings_prep {
$AUBBC{href_target} = ($AUBBC{href_target}) ? ' target="_blank"' : '';
$AUBBC{image_wrap} = ($AUBBC{image_wrap}) ? ' ' : '';
$AUBBC{image_border} = ($AUBBC{image_border}) ? 1 : 0;
$AUBBC{html_type} = ($AUBBC{html_type} eq 'xhtml') ? ' /' : '';
}

sub settings {
my ($self,%s_hash) = @_;

     foreach my $key_name (keys %s_hash) {
             DOS_prevent();
             $AUBBC{$key_name} = $s_hash{$key_name} if exists $AUBBC{$key_name};
     }

     settings_prep();

 if ($DEBUG_AUBBC) {
 my $uabbc_settings = '';
         foreach my $set_key (keys %AUBBC) {
                 DOS_prevent();
                 $uabbc_settings .= $set_key . ' =>' . $AUBBC{$set_key} . ', ';
         }
         warn "AUBBC Settings Change: $uabbc_settings";
    }
}

sub get_setting {
my ($self,$name) = @_;
     return $AUBBC{$name} if exists $AUBBC{$name};
}

sub code_highlight {
    my $text_code = shift;
    warn "START code_highlight" if $DEBUG_AUBBC;
    $text_code =~ s~<br>~=br=~gso;
    $text_code =~ s!:!&#58;!go;
    $text_code =~ s!\[!&#91;!go;
    $text_code =~ s!\]!&#93;!go;
    $text_code =~ s!\{!&#123;!go;
    $text_code =~ s!\}!&#125;!go;
    $text_code =~ s!%!&#37;!go;
    $text_code =~ s!\s{1};!&#59;!go; # ;
    $text_code =~ s{&lt;}{&#60;}go;
    $text_code =~ s{&gt;}{&#62;}go;
    $text_code =~ s{&quot;}{&#34;}go;
if ($AUBBC{highlight}) {
    warn "START block highlight" if $DEBUG_AUBBC;
    $text_code =~ s{\z}{=br=}go if $text_code !~ m/=br=\z/io; # fix
    $text_code =~ s!(&#60;&#60;(\w+);.*?\b\2\b)!<font color=DarkRed>$1</font>!go;
    $text_code =~ s{(?<![\&\$])(\#.*?(?:=br=))}{<font color='#0000FF'><i>$1</i></font>}igo;
    $text_code =~ s{(&#39;.*?(?:&#39;|=br=))}{<font color='#8B0000'>$1</font>}go;
    $text_code =~ s{(&#34;.*?(?:&#34;|=br=))}{<font color='#8B0000'>$1</font>}go;
    $text_code =~ s{(?<![\#|\w|\d])(\d+)(?!\w)}{<font color='#008000'>$1</font>}go;
    $text_code =~ s!\b(strict|package|return|require|for|my|sub|if|eq|ne|lt|ge|le|gt|or|use|while|foreach|next|last|unless|elsif|else|not|and|until|continue|do|goto)\b!<b>$1</b>!go;
    warn "END block highlight" if $DEBUG_AUBBC;
    }
    $text_code =~ s~=br=~<br>~gso;
    warn "END code_highlight" if $DEBUG_AUBBC;
    return $text_code;
}

sub do_ubbc {
   my ($self,$message) = @_;
   warn "ENTER do_ubbc $self" if $DEBUG_AUBBC;

        # Code post support
        # [c]...[/c] or [code]...[/code]
        $message =~ s{\[(?:c|code)\](?s)(.+?)\[/(?:c|code)\]} {
          <div$AUBBC{code_class}><code>
          ${\code_highlight($1)}
          </code></div>$AUBBC{code_extra}
          }isgo;
        # [code=...]...[/code] or [c=...]...[/c]
        $message =~ s{\[(?:code|c)=(.+?)\](?s)(.+?)\[/(?:code|c)\]} {
         $1:<br>
          <div$AUBBC{code_class}><code>
          ${\code_highlight($2)}
          </code></div>$AUBBC{code_extra}
          }isgo;
        # This has no code_class or code_extra [cd]...[/cd]
        $message =~ s{\[cd\](?s)(.+?)\[/cd\]} {
          <code>
          ${\code_highlight($1)}
          </code>
          }isgo;

 # cpan modules
 # http://search.cpan.org/search?mode=module&query=Net%3A%3ASyslog
 $message =~ s{\[cpan://([$AUBBC{other_sites_pattern}]+)\]}{<a href="http://search.cpan.org/search?mode=module&query=$1" target="_blank">$1</a>}isgo;

 # wikipedia Wiki
 # http://wikipedia.org/wiki/Special:Search?search=search%20terms
 $message =~ s{\[(?:wikipedia|wp)://([$AUBBC{other_sites_pattern}]+)\]}{<a href="http://wikipedia.org/wiki/Special:Search?search=$1" target="_blank"$AUBBC{href_class}>$1</a>}isgo;

 # wikibooks Wiki Books
 # http://wikibooks.org/wiki/Special:Search?search=search%20terms
 $message =~ s{\[(?:wikibooks|wb)://([$AUBBC{other_sites_pattern}]+)\]}{<a href="http://wikibooks.org/wiki/Special:Search?search=$1" target="_blank"$AUBBC{href_class}>$1</a>}isgo;

 # wikiquote Wiki Quote
 # http://wikiquote.org/wiki/Special:Search?search=here&go=Go
 $message =~ s{\[(?:wikiquote|wq)://([$AUBBC{other_sites_pattern}]+)\]}{<a href="http://wikiquote.org/wiki/Special:Search?search=$1" target="_blank"$AUBBC{href_class}>$1</a>}isgo;

 # wikisource Wiki Source
 # http://wikisource.org/wiki/Special:Search?search=
 $message =~ s{\[(?:wikisource|ws)://([$AUBBC{other_sites_pattern}]+)\]}{<a href="http://wikisource.org/wiki/Special:Search?search=$1" target="_blank"$AUBBC{href_class}>$1</a>}isgo;

 # google search
 # http://www.google.com/search?q=search%20terms
 $message =~ s{\[google://([$AUBBC{other_sites_pattern}]+)\]}{<a href="http://www.google.com/search?q=$1" target="_blank"$AUBBC{href_class}>$1</a>}isgo;

 # localtime()
 my $time = scalar(localtime);
 $message =~ s{\[time\]}{<b>[$time]</b>}isgo;

        # Images
        while ($message =~ s{\[(img|aright_img|aleft_img)\](.+?)\[/img\]} {
                        DOS_prevent();
                        my $tmp = $2;
                        my $tmp2 = $1;
                          if ($tmp =~ m!($AUBBC{bad_pattern})!i || $tmp =~ m!#!i) {
                               $tmp = qq(\[<font color=red>$BAD_MESSAGE<\/font>\]$tmp2);
                          }
                          else {
                               if ($AUBBC{icon_image}) {
                                    if($tmp2 eq 'img') { $tmp = qq(<img src="$tmp" width="$AUBBC{image_width}" height="$AUBBC{image_hight}" alt="" border="$AUBBC{image_border}"$AUBBC{html_type}>$AUBBC{image_wrap}); }
                                    elsif($tmp2 eq 'aright_img') { $tmp = qq(<img align="right" hspace="5" src="$tmp" border="$AUBBC{image_border}" width="$AUBBC{image_width}" height="$AUBBC{image_hight}" alt=""$AUBBC{html_type}>$AUBBC{image_wrap}); }
                                    elsif($tmp2 eq 'aleft_img') { $tmp = qq(<img align="left" hspace="5" src="$tmp" border="$AUBBC{image_border}" width="$AUBBC{image_width}" height="$AUBBC{image_hight}" alt=""$AUBBC{html_type}>$AUBBC{image_wrap}); }
                                  }
                                   else {
                                    if($tmp2 eq 'img') { $tmp = qq(<img src="$tmp" alt="" border="0">); }
                                    elsif($tmp2 eq 'aright_img') { $tmp = qq(<img align="right" hspace="5" src="$tmp" border="$AUBBC{image_border}" alt=""$AUBBC{html_type}>$AUBBC{image_wrap}); }
                                    elsif($tmp2 eq 'aleft_img') { $tmp = qq(<img align="left" hspace="5" src="$tmp" border="$AUBBC{image_border}" alt=""$AUBBC{html_type}>$AUBBC{image_wrap}); }
                                   }
                          }
                }exisog) {}

        # Email
        $message =~ s~\[email\]($AUBBC{bad_pattern})\[/email\]~\[<font color=red>$BAD_MESSAGE<\/font>\]email~isgo;
        $message =~ s~\[email\](?!([a-z\d\.\-\_]+)\@([a-zA-Z\d\.\-\_]+)).+?\[/email\]~\[<font color=red>$BAD_MESSAGE<\/font>\]email~isgo;
        if ($AUBBC{protect_email} =~ /\A[1234]{1}\z/) {
        # Protect email address.
        $message =~ s/\[email\]([a-z\d\.\-\_]+\@[a-zA-Z\d\.\-\_]+)\[\/email\]/
        my $protect_email = protect_email($1, $AUBBC{protect_email});
        $protect_email
        /exig;
        }
         else {
         # Standard
                $message =~ s~\[email\]([a-z\d\.\-\_]+\@[a-zA-Z\d\.\-\_]+)\[/email\]~<A href="mailto:$1"$AUBBC{href_class}>$1</a>~isgo;
              }

        $message =~ s~\[color=([\w#]+)\](.*?)\[/color\]~<font color='$1'>$2</font>~isgo;
        $message =~ s~\[quote=([\w\s]+)\]~<span$AUBBC{quote_class}><small><b><u>$1:</u></b></small><br>~isgo;
        $message =~ s~\[/quote\]~</span>$AUBBC{quote_extra}~isgo;
        $message =~ s~\[quote\]~<span$AUBBC{quote_class}>~isgo;
        $message =~ s~\[right\]~<div align=\"right\">~isgo;
        $message =~ s~\[\/right\]~</div>~isgo;
        $message =~ s~\[left\]~<div align=\"left\">~isgo;
        $message =~ s~\[\/left\]~</div>~isgo;

        $message =~ s~\[li\]~<li>~isgo;
        $message =~ s~\[li=(\d+)\]~<li value="$1">~isgo;
        $message =~ s~\[/li\]~</li>~isgo;

        # 1 = <1>...</1>, 2 = <2>
        my %AUBBC_TAGS =('b' => 1,'br' => 2,'hr' => 2,'i' => 1,'sub' => 1,'sup' => 1,'pre' => 1,'u' => 1,'strike' => 1,'center' => 1,
        'ul' => 1, 'ol' => 1,);
        foreach my $a_key (keys %AUBBC_TAGS) {
                DOS_prevent();
                if ($AUBBC_TAGS{$a_key} eq 1) {
                     $message =~ s~\[$a_key\]~<$a_key>~isg;
                     $message =~ s~\[\/$a_key\]~<\/$a_key>~isg;
                }
                 elsif ($AUBBC_TAGS{$a_key} eq 2) {
                         $message =~ s~\[$a_key\]~<$a_key$AUBBC{html_type}>~isg;
                 }
        }

        $message =~
            s~\[url=(\w+\://.+?)\](.+?)\[/url\]~<a href="$1"$AUBBC{href_target}$AUBBC{href_class}>$2</a>~isgo;
        $message =~
            s~\[url\](\w+\://.+?)\[/url\]~<a href="$1"$AUBBC{href_target}$AUBBC{href_class}>$1</a>~isgo;
        $message =~
            s~(?:(?<![\w\"\=\{\[\]])|[\n\b]|\A)\\*(\w+://[\w\~\.\;\:\,\$\-\+\!\*\?/\=\&\@\#\%]+[\w\~\.\;\:\$\-\+\!\*\?/\=\&\@\#\%])~<a href="$1"$AUBBC{href_target}$AUBBC{href_class}>$1</a>~isgo;
        $message =~
            s~(?:(?<![\"\=\[\]/\:\.])|[\n\b]|\A)\\*(www\.[\w\~\.\;\:\,\$\-\+\!\*\?/\=\&\@\#\%]+[\w\~\.\;\:\$\-\+\!\*\?/\=\&\@\#\%])~<a href="http://$1"$AUBBC{href_target}$AUBBC{href_class}>$1</a>~isgo;
        warn "END do_ubbc $self" if $DEBUG_AUBBC;
        return $message;
}

sub protect_email {
my ($email, $option) = @_;
my $protect_email = '';
my @key64 = ('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/');
#my @base64 = ('A'..'Z','a'..'z','0'..'9','+','/');
if ($option eq 1) {
 # none Javascript
 my @letters = split (//, $email);
 foreach my $character (@letters) {
          DOS_prevent();
          $protect_email .= '&#' . ord($character) . ';';
 }
  $protect_email = '<A href="&#109;&#97;&#105;&#108;&#116;&#111;&#58;' . $protect_email . "\"$AUBBC{href_class}>" . $protect_email . '</a>';
}
 elsif ($option eq 2) {
 # Javascript
 my @letters = split (//, $email);
 foreach my $character (@letters) {
          DOS_prevent();
          $protect_email .= '&#' . ord($character) . ';';
 }
 my ($email1, $email2) = split ("&#64;", $protect_email);
        $protect_email = <<JS;
<script language="javascript"><!--
document.write("<a href=" + "&#109;&#97;" + "&#105;&#108;" + "&#116;&#111;&#58;" + "$email1" + "&#64;" + "$email2" + "$AUBBC{href_class}>" + "$email1" + "&#64;" + "$email2" + "</a>")
//--></script>
JS
 }
  elsif ($option eq 3) {
  # A Javascript, random function and var names
  my $random_id = random_39();
   my @letters = split (//, $email);
   $protect_email = 'var c' . $random_id . ' = String.fromCharCode(109,97,105,108,116,111,58';
   my $name_protect = 'var b' . $random_id . ' = String.fromCharCode(160';
 foreach my $character (@letters) {
          DOS_prevent();
          $protect_email .= ',' . ord($character);
          $name_protect .= ',' . ord($character);
 }
 $protect_email .= ');';
 $name_protect .= ',160);';
        $protect_email = <<JS;
<script language="javascript"><!--
function a$random_id () {
$protect_email
 window.location=c$random_id;
};
$name_protect
document.write("<a href=\\"javascript:a$random_id();\\"" + "$AUBBC{href_class}>" + b$random_id + "</a>")
//--></script>
JS
  }
   elsif ($option eq 4) {
   # A Javascript encryption with random function and var names
   my ($random_id, @letters)  = ( random_39(), split(//, "mailto:$email") );
   my $prote = 'var c' . $random_id . ' = new Array(';
   foreach my $charect (@letters) {
           DOS_prevent();
           my $ran_num = int(rand(64)) || 0;
           $prote .= '\'' . (ord($key64[$ran_num]) ^ ord($charect)) . '\',\'' . $key64[$ran_num] . '\',';
           }
   $prote =~ s/\,\z/);/g;
   $protect_email = <<JS;
<script type='text/javascript'>
$prote
var f$random_id= new Array('',c$random_id.length,1,'');
    for(f$random_id\[2];f$random_id\[2]<f$random_id\[1];f$random_id\[2]++) {
        f$random_id\[0]+=String.fromCharCode(c$random_id\[f$random_id\[2]].charCodeAt(0)^c$random_id\[f$random_id\[2]-1]);f$random_id\[2]++;
    };
f$random_id\[3]=f$random_id\[0].replace(/^\\w+\\W/g, "");
document.write("<a href=\\"" + f$random_id\[0] + "\\"$AUBBC{href_class}>" + f$random_id\[3] + "</a>");
</script>
JS
   }
return $protect_email;
}

sub random_39 {
  my (@seed, $random_id) = ( ('a'..'f','0'..'9'), '' );
  rand(time ^ $$);
  for (my $i = 0; $i < 39; $i++) {
       $random_id .= $seed[int(rand($#seed + 1))];
  }
  return $random_id;
}

sub do_build_tag {
my ($self,$message) = @_;

   if ($DEBUG_AUBBC) {
        warn "ENTER do_build_tag $self";
        my $uabbc_settings = '';
         foreach my $set_key (keys %Build_AUBBC) {
                 DOS_prevent();
                 $uabbc_settings .= $set_key . ' =>' . $Build_AUBBC{$set_key} . ', ';
         }
         warn "Build tags $uabbc_settings";
        }

    foreach my $b_key (keys %Build_AUBBC) {
             DOS_prevent();
             warn "ENTER foreach do_build_tag $self" if $DEBUG_AUBBC;
             my ($pattern, $type, $fn) = split (/\|\|/, $Build_AUBBC{$b_key});
             my $build_pat = '';
             if ($pattern eq 'all') {
                    $build_pat = 'a-z\d\:\-\s\_\/\.\;\&\=\?\-\+\#\%\~\,\|';
                    }
                     else {
                     my @pat_split = split (/\,/, $pattern);
                     my $p_ct = 0;
                         foreach my $pat_is (@pat_split) {
                                 last if $p_ct == 6;
                                 $p_ct++;
                                 $build_pat .= 'a-z' if $pat_is eq 'l';
                                 $build_pat .= '\d' if $pat_is eq 'n';
                                 $build_pat .= '\_' if $pat_is eq '_';
                                 $build_pat .= '\:' if $pat_is eq ':';
                                 $build_pat .= '\s' if $pat_is eq 's';
                                 $build_pat .= '\-' if $pat_is eq '-';
                         }
                     }
             $message =~ s/(\[$b_key\:\/\/([$build_pat]+)\])/
              my $ret = check_build_tag( $2 , $fn ) || '';
              $ret ? $ret : $1;
              /exig if ($type eq 1);

             $message =~ s/(\[$b_key\]([$build_pat]+)\[\/$b_key\])/
              my $ret = check_build_tag( $2 , $fn ) || '';
              $ret ? $ret : $1;
              /exig if ($type eq 2);

             $message =~ s/(\[$b_key\])/
              my $ret = check_build_tag( $b_key , $fn ) || '';
              $ret ? $ret : $1;
              /exig if ($type eq 3);
     }
    warn "END do_build_tag $self" if $DEBUG_AUBBC;
    return $message;
}

sub check_build_tag {
my ($term, $fun) = @_;
warn "ENTER check_build_tag" if $DEBUG_AUBBC;
return '' if !$term || !$fun;
no strict 'refs';
my $vid = $fun->($term) || '';
use strict 'refs';
warn "END check_build_tag" if $DEBUG_AUBBC;
(!$vid) ? return '' : return $vid;
}

sub add_build_tag {
my ($self,$name,$pattern,$type,$fn) = @_;
warn "ENTER add_build_tag $self" if $DEBUG_AUBBC;
   unless (defined(&$fn) && (ref $fn eq 'CODE' || ref $fn eq '')) {
    die "Usage: do_build_tag 'no function named' => $fn";
  }
  $pattern = 'l' if ($type eq 3);
  # all, l, n, \_, \:, \s, \- (delimiter \,)
  if ($name =~ m/\A[a-z0-9]+\z/i && ($pattern =~ m/\A[lns_:\-,]+\z/i || $pattern eq 'all')) {
         $Build_AUBBC{$name} = $pattern . '||' . $type . '||' . $fn if ($name && $pattern && $type);
       warn "Added Build_AUBBC Tag $Build_AUBBC{$name}" if $DEBUG_AUBBC && $Build_AUBBC{$name};

  }
   else {
         die "Pattern: do_build_tag 'Bad name or pattern format'";
       }
warn "ENTER add_build_tag $self" if $DEBUG_AUBBC;
}

sub remove_build_tag {
my ($self,$name,$type) = @_;
warn "ENTER remove_build_tag $self" if $DEBUG_AUBBC;
     delete $Build_AUBBC{$name} if exists $Build_AUBBC{$name} && !$type; # clear one
     %Build_AUBBC = () if $type && !$name; # clear all
warn "END remove_build_tag $self" if $DEBUG_AUBBC;
}

sub do_unicode {
    my ($self,$message) = @_;
    warn "ENTER do_unicode $self" if $DEBUG_AUBBC;
    # Unicode Support
    # [u://0931] or [utf://x23]
    $message =~ s{\[(?:u|utf)://(x?[0-9a-f]+)\]}{&#$1\;}igso;
    # [ux23]
    $message =~ s{\[u(x?[0-9a-f]+)\]}{&#$1\;}igso;
    # this added an XSS issue with some html elements - issue fixed
    $message =~ s{&amp\;#(x?[0-9a-f]+)\;}{&#$1\;}igso;
    # code names
    $message =~ s{&amp\;([a-fA-Z]+)\;}{&$1\;}igso;
    warn "END do_unicode $self" if $DEBUG_AUBBC;
    return $message;
}

sub do_smileys {
    my ($self,$message) = @_;
    warn "ENTER do_smileys $self" if $DEBUG_AUBBC;
       # Make the smilies.
       foreach my $smly (keys %SMILEYS) {
               DOS_prevent();
               $message =~ s~\[$smly\]~<img src="$AUBBC{images_url}/smilies/$SMILEYS{$smly}" alt="$smly" align="left" vspace="1" hspace="1" border="$AUBBC{image_border}"$AUBBC{html_type}>$AUBBC{image_wrap}~isg if $smly && exists $SMILEYS{$smly};
               #$message =~ s~\[$smly\]~<img src="$AUBBC{images_url}/smilies/$SMILEYS{$smly}" alt="$smly" border="$AUBBC{image_border}"$AUBBC{html_type}>$AUBBC{image_wrap}~isg if $smly && exists $SMILEYS{$smly};
       }
    warn "END do_smileys $self" if $DEBUG_AUBBC;
    return $message;
}

sub smiley_hash {
     my ($self,%s_hash) = @_;
     warn "ENTER smiley_hash $self" if $DEBUG_AUBBC;
     %SMILEYS = %s_hash;
     $AUBBC{smileys} = ($AUBBC{smileys} && %SMILEYS && $AUBBC{images_url} =~ m/\A\w+:\/\//) ? '1' : '';
     warn "END smiley_hash $self" if $DEBUG_AUBBC;
}

sub do_all_ubbc {
    my ($self,$message) = @_;
    warn "ENTER do_all_ubbc $self" if $DEBUG_AUBBC;
    if (!$AUBBC{no_bypass} && $message =~ s/^\#none//go) {
        warn "START&END no_bypass $self" if $DEBUG_AUBBC;
         return $message;
    }
     else {
    return $message unless $message =~ m{[\[\]\(\:]};
    $message = $self->script_escape($message) if $AUBBC{script_escape};
    $message = $self->escape_aubbc($message, 1) if $AUBBC{aubbc_escape};
    $message = (!$AUBBC{no_bypass} && $message =~ s/^\#noubbc//go)
        ? $message
        : $self->do_ubbc($message) if !$AUBBC{for_links} && $AUBBC{aubbc};

    $message = (!$AUBBC{no_bypass} && $message =~ s/^\#nobuild//go)
        ? $message
        : $self->do_build_tag($message) if !$AUBBC{for_links} && %Build_AUBBC;

    $message = (!$AUBBC{no_bypass} && $message =~ s/^\#noutf//go)
        ? $message
        : $self->do_unicode($message) if $AUBBC{utf};

    $message = (!$AUBBC{no_bypass} && $message =~ s/^\#nosmileys//go)
        ? $message
        : $self->do_smileys($message) if $AUBBC{smileys};

    $message = $self->escape_aubbc($message) if $AUBBC{aubbc_escape};
    }
    warn "END do_all_ubbc $self" if $DEBUG_AUBBC;
    return $message;
}

sub escape_aubbc {
    my ($self, $message, $escaper) = @_;
    warn "ENTER escape_aubbc $self" if $DEBUG_AUBBC;
    if ($escaper) {
         warn "block escape 1 $self" if $DEBUG_AUBBC;
         $message =~ s{\[\[}{\{\{}go;
         $message =~ s{\]\]}{\}\}}go;
    }
     else {
           warn "block escape 2 $self" if $DEBUG_AUBBC;
           $message =~ s{\{\{}{\[}go;
           $message =~ s{\}\}}{\]}go;
     }
     warn "END escape_aubbc $self" if $DEBUG_AUBBC;
     return $message;
}

sub script_escape {
my ($self, $text, $option) = @_;
warn "ENTER html_escape $self" if $DEBUG_AUBBC;
     return '' unless $text;
     if (!$option) {
        $text =~ s{&}{&amp;}gso;
        $text =~ s{\t}{ \&nbsp; \&nbsp; \&nbsp;}gso;
        $text =~ s{  }{ \&nbsp;}gso;
        }
     if ($option || !$option) {
        $text =~ s{"}{&#34;}gso;
        $text =~ s{<}{&#60;}gso;
        $text =~ s{>}{&#62;}gso;
        $text =~ s{'}{&#39;}gso;
        $text =~ s{\)}{&#41;}gso;
        $text =~ s{\(}{&#40;}gso;
        $text =~ s{\\}{&#92;}gso;
        $text =~ s{\|}{&#124;}gso;
        }
        $text =~ s{\n}{<br>}gso if (!$option);
        $text =~ s{\cM}{}gso if ($option || !$option);
warn "END html_escape $self" if $DEBUG_AUBBC;
        return $text;
}
sub html_to_text {
my ($self, $html, $option) = @_;
warn "ENTER html_to_text $self" if $DEBUG_AUBBC;
     return '' unless $html;
     if (!$option) {
        $html =~ s{&amp;}{&}gso;
        $html =~ s{ \&nbsp; \&nbsp; \&nbsp;}{\t}gso;
        $html =~ s{ \&nbsp;}{  }gso;
        }
     if ($option || !$option) {
        $html =~ s{&#34;}{"}gso;
        $html =~ s{&#60;}{<}gso;
        $html =~ s{&#62;}{>}gso;
        $html =~ s{&#39;}{'}gso;
        $html =~ s{&#41;}{\)}gso;
        $html =~ s{&#40;}{\(}gso;
        $html =~ s{&#92;}{\\}gso;
        $html =~ s{&#124;}{\|}gso;
        }
        $html =~ s{<br>}{\n}gso if (!$option);
warn "END html_to_text $self" if $DEBUG_AUBBC;
        return $html;
}
sub version {
my ($self) = @_;
     return $AUBBC_VERSION;
}

# 30 second time out for all while and foreach.
# This is to prevent/stop any DOS problems or if this module hangs,
# No I have not had this program hang to need to use this.
# But i feel the loops should never be runing longer then 30 seconds and
# to have the peace of mind to know i made it safer with it.
sub DOS_prevent {
my $start_the_time = time;
 if ($start_the_time eq $end_the_time) {
      warn ('AUBBC.pm is out of time for its loops');
      last;
 }
}

1;

__END__

=head1 Package Name

AUBBC

=head1 Description

 AUBBC - (Advanced Universal Bulletin Board Code)
 Tags used to create formatting effects in HTML & XHTML.

=head1 Abstract

 This module addresses many security issues the UBBC tags may have.
 Each message is sanitized/escaped and checked for many types of security problems befor that tag converts to HTML/XHTML.
 To some it may have very strict security methods, but it allows you to change some of the security patterns.

=head1 Settings

=head2 $aubbc->settings();

This is a list of Default settings and the method to change them when needed.

     $aubbc->settings(
      aubbc => 1,
      utf => 1,
      smileys => 1,
      highlight => 1,
      no_bypass => 0,
      for_links => 0,
      aubbc_escape => 1,
      icon_image => 1,
      image_hight => 60,
      image_width => 90,
      image_border => 0,
      image_wrap => 1,
      href_target => 0,
      images_url => '',
      html_type => 'html',
      code_class => '',
      code_extra => '',
      href_class => '',
      quote_class => '',
      quote_extra => '',
      other_sites_pattern => 'a-zA-Z\d\:\-\s\_\/\.',
      bad_pattern => 'view\-source:|script:|mocha:|mailto:|about:|shell:|\.js',
      protect_email => 1,
      );

=head2 aubbc

Enable or Disable Main AUBBC Tags Default 1 is Enabled, 0 is Disable.

=head2 utf

Enable or Disable UFT Tags Default 1 is Enabled, 0 is Disable.

=head2 smileys

Enable or Disable Smiley Tags Default 1 is Enabled, 0 is Disable.

=head2 highlight

Enable or Disable Code Highlight Default 1 is Enabled, 0 is Disable.

=head2 no_bypass

Enable or Disable User Tags for Bypassing Tags Default 0 is Disable, 1 is Enabled.

 Tags must at the very beginning of the message.
  Bypass Tags:
  #none
  #noaubbc
  #nobuild
  #noutf
  #nosmileys

=head2 for_links

 Enable or Disable Use Tags for Links Default 0 is Disable, 1 is Enabled.

 Some AUBBC Tags are not good to use in a link like other links.

 If Enabled will only use the UTF and Smiley tags.

=head2 aubbc_escape

Enable or Disable AUBBC Tag Escape Default 1 is Enabled, 0 is Disable.

 Escaping a Tag:
  [b]Stuff[/b] # Normal Tag Bold
  [b]]Stuff[/b]] # Escaped Tag Bold
  [[b]Stuff[[/b] # Escaped Tag Bold
  [[b]]Stuff[[/b]] # Escaped Tag Bold
  [b}}Stuff[/b}} # Escaped Tag Bold
  {{b]Stuff{{/b] # Escaped Tag Bold
  {{b}}Stuff{{/b}} # Escaped Tag Bold

 Bugs if Enabled:

 Any use of }} will equal ] and any {{ will equal [

 Any use of ]] will equal ] and any [[ will equal [

=head2 icon_image

 Enable or Disable Custom Image Size Default 1 is Enabled, 0 is Disable.

 If enabled will use the values from image_hight and image_width

 in all Image Tags [img]/images/large_pic.gif[/img]

=head2 image_hight

 The Default Image hight is 60px.

 Only used when icon_image is Enabled.

=head2 image_width

 The Default Image width is 90px.

 Only used when icon_image is Enabled.

=head2 image_border

Enable or Disable Image Border Default 0 is Disable, 1 is Enabled.

=head2 image_wrap

 Enable or Disable Image wrap Default 1 is Enabled, 0 is Disable.

 Enabled will add a space after each image & smileys.

=head2 href_target

 Enable or Disable href target Default 0 is Disable, 1 is Enabled.

 Enabled will add target="_blank" to all href's.

=head2 images_url

 Default is blank.

 This is the link to your images folder and is only used for Smileis.

 For the smileis to work you must provide a URL.

 example:

 smileis must be in /smileis folder

 the images_url link must have the /smileis folder in it and not point directly to /smileis.

=head2 html_type

Default is 'html' and the only other support is 'xhtml'

=head2 code_class

 Default is '' and this allows a custom class, style and/or javascript to be used in any of the [code] [c] tags.

 Tag [cd] is the only tag that does not support this feature.

 must have a space befor the text.

 example:

 code_class => ' class="quote"',

 code_class => ' class="quote" onclick="....."',

=head2 code_extra

Default is '' and this is for a custom message, code, image, est.. to be used after the [code] [c] tags.

 example:

 code_extra => 'Codes may not reflect what is in the current version.',

 code_extra => '<div style="clear: left"> </div>',

=head2 href_class

Default is '' and this allows a custom class, style and/or javascript to be used in the [url] tags.

 must have a space befor the text.

 example:

 href_class => ' class="url"',
 href_class => ' class="url" onclick="....."',

=head2 quote_class

Default is '' and this allows a custom class, style and/or javascript to be used in the [quote] tags.

 must have a space befor the text.

 example:

  quote_class => ' class="quote"',
  quote_class => ' class="quote" onclick="....."',

=head2 quote_extra

Default is '' and this is for a custom message, code, image, est.. to be used after a [quote] tags.

example:

  quote_extra => 'QUOTES AND SAYINGS DISPLAYED ON THIS BLOG ARE NOT WRITTEN BY THE AUTHOR OF THE BLOG.',
  quote_extra => '<div style="clear: left"> </div>',

=head2 other_sites_pattern

Default is 'a-zA-Z\d\:\-\s\_\/\.' and this resticts the use of characters used in tags to other sites, not used in [url] tags.

other site tags:

  [cpan://....]
  [google://....]
  [wikipedia://....]
  [wp://....]
  [wikibooks://....]
  [wb://....]
  [wikiquote://....]
  [wq://....]
  [wikisource://....]
  [ws://....]

=head2 bad_pattern

Default is 'view\-source:|script:|mocha:|mailto:|about:|shell:|\.js' and this resticts the use of characters used in [email] and all [img] tags.

=head2 script_escape

This will turn on or off the sanitizer/escape security for the hole message.

Default is 1 on and 0 for Disable.

Notes: 1)The code highlighter works best with an escaped character format like the
script_escape => 1 setting can provide.

2) If this setting is disabled and a character escaping method or security filter is not used
can result is a security compromise of the AUBBC tags.

3) if Disabled the method "$message = $aubbc->script_escape($message);" can be used on the message as needed befor do_all_ubbc() is called.


=head2 protect_email

  Default is 1 and other possible values are (0, 2, 3, 4).

  Can add a protection to hide emails in the [email] tag from email harvisters.


  Not 100% fool proof.

        0 - has no type of protection.


        1 - uses unicode type protection.


        2 - uses javascript and unicode type protection.


        3 - Javascript, random function and var names and unicode type protection.


        4 - Javascript encryption with random function and var names



=head1 Smileis Settings

These are the settings for using custom smileis.

Note: There are no Built-in smileis.

=head2 $aubbc->smiley_hash();

This is one of the two ways to import your custom smileis hash.

exampl:

  use AUBBC;
  my $aubbc = new AUBBC;
  my %smiley = (lol => 'lol.gif');
  $aubbc->smiley_hash(%smiley);

The way you use this smiley is [lol]

Must have the images_url set to the proper location.

images_url/smileis/lol.gif

=head2 %AUBBC::SMILEYS

This is one of the two ways to import your custom smiley hash.

exampl:

  my %smiley = (lol => 'lol.gif');
  use AUBBC;
  %AUBBC::SMILEYS = %smiley;
  my $aubbc = new AUBBC;

The way you use this smiley is [lol]

Must have the images_url set to the proper location.

images_url/smileis/lol.gif

=head1 Build your own tags

These are the settings and methods for using custom tags.

=head2 $aubbc->add_build_tag($name,$pattern,$type,$function);

name - will be the tags name

pattern - limited to 'all' or 'l,n,-,:,_,s'

    'all' = 'a-z\d\:\-\s\_\/\.\;\&\=\?\-\+\#\%\~\,\|'
    'l' = 'a-z'
    'n' = '0-9'
    's' = ' '
    '-' = '-'
    ':' = ':'
    '_' = '_'

type - 1 is style [name://pattern], 2 is style [name]pattern[/name] and 3 is style [name]

function - a pre-defined subroutine that recives the matched pattern and returns what you want,

   Note: if the function returns undefined, '' or 0 the tag will not be changed.

Usage:

  package My_Message;

  use AUBBC;
  my $aubbc = new AUBBC;

  $aubbc->add_build_tag('ok','l,s',1,'My_Message::check_ok_tag');
  $aubbc->add_build_tag('ip','',3,'My_Message::get_some_tag');
  $aubbc->add_build_tag('agent','',3,'My_Message::get_some_tag');

  my $message = '[ok://test me] [ok://test other] [ok://n0 w00rk] [ip] [agent]';

  $message = $aubbc->do_all_ubbc($message);

  print $message;

  sub check_ok_tag {
   my $text_from_AUBBC = shift;

   if ($text_from_AUBBC eq 'test me') {
        return 'Works Good 1';
        }
         else {
               return 'Works Good 2';
               }
  }

  sub get_some_tag {
  my $text_from_AUBBC = shift;
  lc($text_from_AUBBC);
  $text_from_AUBBC = $ENV{'REMOTE_ADDR'} if ($text_from_AUBBC eq 'ip');
  $text_from_AUBBC = $ENV{'HTTP_USER_AGENT'} if ($text_from_AUBBC eq 'agent');
  return $text_from_AUBBC;
  }

  1;

=head2 $aubbc->remove_build_tag($name, $option);

There are two ways to use this.

1) Remove a single built tag: $aubbc->remove_build_tag($name);

2) Remove all built tags: $aubbc->remove_build_tag('', 1);

=head1 Error Message

=head2 $AUBBC::BAD_MESSAGE

Default message is 'Error', this message is used when the code finds bad characters in [email] or [img] tags.

 Usage of this setting:

  use AUBBC;
  $AUBBC::BAD_MESSAGE = 'Unathorized use of characters or pattern in this tag.';
  # est...

=head1 Debug

The Debug setting will send a lot of messages to warn and is not recommened to leave on all the time.

=head2 $AUBBC::DEBUG_AUBBC

 Default is '' off, and Enabled is 1.

 Usage of this setting:

  use AUBBC;
  $AUBBC::DEBUG_AUBBC = 1;
  # est...

=head1 Version

Returns the current version of the module.

=head2 $aubbc->version();


 Usage:

  use AUBBC;
  my $aubbc = new AUBBC;

  my $Current_Version = $aubbc->version();

  print $Current_Version;

=head1 COPYLEFT

 AUBBC.pm, v1.0 01/20/2008 08:46:08 By: N.K.A

 Advanced Universal Bulletin Board Code Tags.

 Note: This code has a lot of settings and works good
 with most default settings.

=cut
