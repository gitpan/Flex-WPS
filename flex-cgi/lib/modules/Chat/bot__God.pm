package bot__God;
use vars qw(%user_data);
use exporter;

sub speack {
my $stuff = shift;
my $talk = '';
my $dt = CGI::Util::expires('now','');

$talk = 'The server Time and Date is [b]' . $dt . '[/b]' if $stuff =~ /^(G|g)od (date(\?|)|time(\?|)|what\sis\sthe\s(time|date)(|\?|\.))$/;
$talk = 'Hello [b]' . $user_data{nick} . '[/b]' if $stuff =~ /^(hi|HI|Hi|hI|(h|H)ello)/;
$talk = 'If I knew that, I would be [url=http://www.google.com]Google[/url]... [deepthought]' if $stuff =~ /^(what is|what(\'s|s))/;
$talk = 'Try to kick me and I\'ll kick you back! [kickyourass]' if $stuff =~ /^\/kick ([^(G|g)od]|.+)\s.+/;
$talk = 'What? You dair to kick God! [b]' . $user_data{nick} . '[/b] I would let you taste my back hand, but I\'m to good for you. [kickyourass]' if $stuff =~ /^\/kick ((G|\@G|g)od)\s.+/;
$talk = 'Bye [b]' . $user_data{nick} . '[/b]' if $stuff =~ /^((B|b)ye (G|g)od|\.just logged off\.|\/logout|\/exit)$/;
$talk = 'Bless you my Child... [cool]' if $stuff =~ /^(thx (G|g)od|thank you(,| ,|) (G|g)od)/;
$talk = 'What?' if $stuff =~ /^hay (G|g)od$/;

$talk = 'I am the All Mighty God of this Chat. I do a lot more but here are some Commands >> god time , hi , what is , /kick , god help , bye god.' if $stuff =~ /^(\/help|god help)/;

return $talk;
}
1;