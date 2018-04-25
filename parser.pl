#! /usr/bin/perl
# %W%	%E% (%D%)	%Y%
# NAME
#	parser	- Perl parser plugin for Semantic Merge
# SYNTAX
#	parser shell <flag-file>
# DESCRIPTION
#	Creates the <flag-file> on startup, then reads triplets of lines
#	specifying an input Perl file, encoding, and output yaml file,
#	until the first line contains only the word "end".
#
#	For each triplet, it parses the Perl file and writes the output
#	to the yaml file as required by the Semantic Merge program. It
#	also writes the word "OK" if parsing worked, or "KO" if it did not.
#
#	See https://users.semanticmerge.com/documentation/external-parsers/external-parsers-guide.shtml
#	for details on the External Parser API and requirements.
# ARGUMENTS
#	shell		always the word "shell"
#	<flag-file>	full pathname of a file to create once ready to parse
# AUTHOR
#	Peter Lyons
# GLOBALS
# Arrays
#

# Process arguments:
	$COMMAND	= shift @ARGV
			|| die "$0: Insufficient arguments supplied\n" ;
	$FLAGFILE	= shift @ARGV 
			|| die "$0: Insufficient arguments supplied\n" ;
	die "$0: Too many arguments supplied\n"			if ( @ARGV ) ;
	if ($COMMAND ne "shell") {
	    die "$0: The first argument must be 'shell'\n" ;
	}

# Create flag file:
	open(my $ffh, ">", $FLAGFILE) 
		|| die "$0: Cannot create flag file '$FLAGFILE' - $!\n" ;
	print($ffh "flag file\n")
		|| die "$0: Cannot write to flag file '$FLAGFILE' - $!\n" ;
	close($ffh) ;

# Main loop:
	for(;;)
	{
	    $INPUT	= <> ;	chomp($INPUT) ;
	    last			if ($INPUT eq "end") ;
	    $ENCODING	= <> ;	chomp($ENCODING) ;
	    $OUTPUT	= <> ;	chomp($OUTPUT) ;
	}

# Finish:
	exit(0) ;

