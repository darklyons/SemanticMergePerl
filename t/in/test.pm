package test ;

# Package test

use strict ;

our $VERSION = '1.0' ;

sub tester {
	my $class = ref $_[0] ? ref shift : shift ;

}

# Constructor and Accessors

=pod

=head2 new param => $value, ...

The C<new> constructor creates a new standalone test object.

=over

=item contents

The C<contents> sets the test objects contents.

=back

Returns a new C<Test> object.

=cut


sub new {
	my $class = shift ;
	my $contents = shift ;

	bless $contents ;

	$contents ;
}

