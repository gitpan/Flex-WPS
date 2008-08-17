package testzz;

sub crap {
 print "rrr";
}
 use test2;
 
package test2;

crap();
sub crapper {
print "rrr";
}
package test3;
crap();
crapper();
crapper2();
sub crapper2 {
print "rrr";
}
__END__

__END__


1;
