package HTML_TEXT;
# not to sure if i fully removed the need for this file in other parts
# The AUBBC module has these functions and is what you want to use

sub html_escape {
my $text = shift;
my $option = shift;
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

        return $text;
}
# Working
sub html_to_text {
my $html = shift;
my $option = shift;
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

        return $html;
}
1;
