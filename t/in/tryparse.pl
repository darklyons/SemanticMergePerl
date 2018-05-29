#! /usr/bin/perl
# %W%	%E% (%D%)	%Y%
# NAME
#	tryparse	- run the parser program on the arguments
# SYNTAX
#	tryparse <input-file> <output-file> <flag-file>
# DESCRIPTION
#	Invokes parser.pl with the correct arguments and it feeds
#	it the correct arguments.
# ARGUMENTS
#	<input-file>	full pathname of the file to parse
#	<output-file>	full pathname of the yaml file to produce
#	<flag-file>	full pathname of a file to create once ready to parse
# AUTHOR
#	Peter Lyons
# GLOBALS
# Arrays
#

# Process arguments:
	$INPUTFILE	= shift @ARGV
			|| die "$0: Insufficient arguments supplied\n" ;
	$OUTPUTFILE	= shift @ARGV
			|| die "$0: Insufficient arguments supplied\n" ;
	$FLAGFILE	= shift @ARGV 
			|| die "$0: Insufficient arguments supplied\n" ;

# Invoke command:
	my $cmdfh ;
	if ( $DEBUG ) {
	    open($cmdfh, "| perl -s parser.pl -DEBUG=$DEBUG shell $FLAGFILE") ;
	} else {
	    open($cmdfh, "| perl parser.pl shell $FLAGFILE") ;
	}

# Give it the parameters:
	print $cmdfh "$INPUTFILE\n" ;
	print $cmdfh "\n" ;
	print $cmdfh "$OUTPUTFILE\n" ;

# And finish it off:
	print $cmdfh "end\n" ;
	exit(0) ;


