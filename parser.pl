#! /usr/bin/perl
# %W%	%E% (%D%)	%Y%
# NAME
#	parser	- Perl parser plugin for Semantic Merge
# SYNTAX
#	parser shell <flag-file>
#	parser parse <input-file> <output-file>
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
#
#	For testing purposes, there is an alternative calling method where
#	the command "parse" is given with input and output file names.
# ARGUMENTS
#	shell		always the word "shell"
#	<flag-file>	full pathname of a file to create once ready to parse
#	parse		always the word "parse"
#	<input-file>	filename of a perl file to be parsed
#	<output-file>	filename to write the yaml output to
# AUTHOR
#	Peter Lyons
# GLOBALS
# Arrays
#

# Import modules:
	use PPI ;

# Open a log file?
	open(STDERR, ">>", "semanticperl.log.txt")	if ( $DEBUG ) ;

# Process arguments:
	$COMMAND	= shift @ARGV
			|| die "$0: Insufficient arguments supplied\n" ;
	print(STDERR "COMMAND=$COMMAND\n")		if ( $DEBUG ) ;
    # - Switch on command type:
	if ($COMMAND eq "shell") {
	    $FLAGFILE	= shift @ARGV 
			|| die "$0: Insufficient arguments supplied\n" ;
	    print(STDERR "FLAGFILE=$FLAGFILE\n")	if ( $DEBUG ) ;
	} elsif ($COMMAND eq "parse") {
	    $INPUT	= shift @ARGV 
			|| die "$0: Insufficient arguments supplied\n" ;
	    print(STDERR "INPUT=$INPUT\n")		if ( $DEBUG ) ;
	    $OUTPUT	= shift @ARGV 
			|| die "$0: Insufficient arguments supplied\n" ;
	    print(STDERR "OUTPUT=$OUTPUT\n")		if ( $DEBUG ) ;
	} else {
	    die "$0: The first argument must be 'shell'\n" ;
	}
    # - all arguments must be consumed:
	die "$0: Too many arguments supplied\n"			if ( @ARGV ) ;

# Once off parse?
	if ($COMMAND eq "parse") {
	    my $outfh ;
	    open($outfh, ">", $OUTPUT) ||
		die "$0: Cannot open output file '$OUTPUT' - $!\n" ;
	    SemanticParse($INPUT, $outfh) ;
	    exit(0) ;
	}

# Create flag file:
	open(my $ffh, ">", $FLAGFILE) 
		|| warn "$0: Cannot create flag file '$FLAGFILE' - $!\n"
		&& exit(255) ;
	print($ffh "flag file\n")
		|| warn "$0: Cannot write to flag file '$FLAGFILE' - $!\n"
		&& exit(255) ;
	close($ffh) ;

# Main loop:
	$| = 1 ;
	while (! eof(STDIN))
	{
	# Grab triplet:
	    $INPUT	= <> ;	chomp($INPUT) ;
	    print(STDERR "INPUT=$INPUT\n")		if ( $DEBUG ) ;
	    last			if ($INPUT eq "end") ;
	    $ENCODING	= <> ;	chomp($ENCODING) ;
	    print(STDERR "ENCODING=$ENCODING\n")	if ( $DEBUG ) ;
	    $OUTPUT	= <> ;	chomp($OUTPUT) ;
	    print(STDERR "OUTPUT=$OUTPUT\n")		if ( $DEBUG ) ;

	# Setup for parsing:
	    my $result = 1 ;
	    my $outfh ;
	    if (! -r $INPUT) {
		print(STDERR "$0: Cannot open input file '$INPUT' - $!\n") ;
		$result = 0 ;
	    }
	    if (! open($outfh, ">:encoding($ENCODING)", $OUTPUT)) {
		print(STDERR "$0: Cannot open output file '$OUTPUT' - $!\n") ;
		$result = 0 ;
	    }

	# Call the parser:
	    $result = SemanticParse($INPUT, $outfh)	if ( $result ) ;
	    if ( $result ) {
		print STDOUT "OK\n" ;
		print(STDERR "OK\n")	if ( $DEBUG ) ;
	    } else {
		print STDOUT "KO\n" ;
		print(STDERR "KO\n")	if ( $DEBUG ) ;
	    }
	}

# Finish:
	unlink($FLAGFILE) ;
	exit(0) ;

#
# SUBROUTINES
#

sub SemanticParse	# ($inputFile, $outfh) -> $result
{
    # Arguments:
	my $inputFile	= shift ;
	my $outfh	= shift ;

    # Init declarations tree:
	my $tree = SemanticNode->new( "type" => "file", "name" => $inputFile ) ;

    # Slurp the input:
    # - without CRLF translation
    # - and mapping CR to LF (prevents Windows miscount issue)
        open(my $inpfh, "<:raw", $inputFile) ;
	local $/ = undef ;
	my $source = <$inpfh> ;
	close($inpfh) ;
	$source =~ s/\r/\n/g ;

    # Create the parse tree:
	my $dom	= PPI::Document->new(\$source) ;
	return $dom					unless ( $dom ) ;

    # Process it:
	$tree->addLocationSpan(1, 0) ;
    # - loop vars:
	my $child = $tree ;
	my $node = $child ;
	my @curPair, @endPair ;
	my $charCount = -1 ;
	my $lastCount = -1;
	my $pair ;
	my $debugmsg ;
    #- loop body:
	foreach $element ( $dom->elements )
	{
	# Extract element:
	    my $type = $element->class ;	$type =~ s/.*::// ;
	    my $content = $element->content ;
	    unless ( @curPair ) {
		@curPair = ($element->location->[0], $element->location->[1]-1) ;
	    }
	    $charCount += length($content) ;

	# Calculate extent of element:
	    my($lines) = $content ;
	    my($final) = $lines =~ s/(\n)$// ;
	    my($nrows) = $lines =~ s/.*\n//g ;
	# - start of span:
	    @endPair = ($element->location->[0], $element->location->[1]-1) ;
	# - handle single eol case:
	    $lines .= $final		if ( $final ) ;
	# - calc end of span:
	    if ($nrows == 0) {
	    # Same line: add to existing number of columns:
		@endPair = ($endPair[0], $endPair[1] + length($lines) - 1) ;
	    } else {
	    # New line: no existing number of columns:
		@endPair = ($endPair[0] + $nrows, length($lines) - 1) ;
	    }

	# Detect significant elements:
	    if ( $element->significant ) {
	    # Package (a container):
		if ($type eq "Package") {
		    $child->endLocationSpan(@endPair)	if ( $child->hasLocationSpan ) ;
		    $name = $element->namespace ;
		    $node = $child = $tree->addChild( "type" => "class", "name" => $name ) ;
		    $pair = $child->addSpan("headerSpan") ;
		    $child->addSpan("footerSpan", 0, -1) ;
	    # Include (a node):
		} elsif ($type eq "Include") {
		    $name = $element->module ;
		    $node = $child->addChild( "type" => "include", "name" => $name ) ;
		    $pair = $node->addSpan() ;
	    # Sub (a node):
		} elsif ($type eq "Sub") {
		    $name = $element->name ;
		    $node = $child->addChild( "type" => "method", "name" => $name ) ;
		    $pair = $node->addSpan() ;
	    # Other (nodes):
		} else {
		    $node = $child->addChild( "type" => "include", "name" => $type ) ;
		    $pair = $node->addSpan() ;
		}

	    # Keep track of the content for debugging purposes:
		$debugmsg .= $content ;
		print(STDERR $debugmsg)		if ( $main::DEBUG ) ;
		$debugmsg = "" ;

	    # Calculate location span:
		$node->addLocationSpan(@curPair) ;
		$node->endLocationSpan(@endPair) ;
		@curPair = () ;

	    # Calculate character span:
		$pair->setStart($lastCount+1) ;
		$pair->setEnd($charCount) ;
		$lastCount = $charCount ;
	    } else {
	    # Whitespace, comment or similar:
		my $nodePair ;
		$nodePair = $node->getLocationSpan->getEnd
						if ( $node->hasLocationSpan ) ;
		if ($nodePair && $nodePair->rowIs(@curPair)) {
		# On the same line - extend the span:
		    $node->endLocationSpan(@curPair) ;
		    $pair->setEnd($charCount) ;
		    $lastCount = $charCount ;
		    @curPair = () ;
		    $debugmsg = $content ;
		    print(STDERR $debugmsg)	if ( $main::DEBUG ) ;
		    $debugmsg = "" ;
		} else {
		    $debugmsg .= $content ;
		}
	    }
	}

# Close remaining open spans:
	$child->endLocationSpan(@endPair)	if ( @endPair ) ;
	$tree->endLocationSpan(@endPair)	if ( @endPair ) ;
	$tree->addSpan("footerSpan", 0, -1) ;
	if ( @curPair ) {
	# Put trailing non-significant tokens into a footer:
	    $child->addSpan("footerSpan", $lastCount+1, $charCount) ;
	}
	print(STDERR $debugmsg)		if ( $main::DEBUG ) ;

# Parsing error?
	if ( $dom->complete ) {
	    $tree->set("parsingErrorsDetected", "false") ;
	} else {
	    $tree->set("parsingErrorsDetected", "true") ;
	}

# YAML output:
	print $outfh "---\n" ;
	$tree->print($outfh) ;
	close($outfh) ;

# Report status:
	return $tree ;
}

#
# CLASSES
#

package SemanticPair ;

sub new		# ($one, $two)
{
	my $class	= shift ;
	my $one		= shift ;
	my $two		= shift ;

	my $pair = [$one, $two] ;
	return bless $pair, $class ;
}


sub rowIs	# ($row)
{
	my $self	= shift ;
	my $row	= shift ;

	return ($self->[0] == $row) ;
}



sub setStart	# ($start)
{
	my $self	= shift ;
	my $start	= shift ;

	$self->[0] = $start ;
	return $self ;
}


sub setEnd	# ($end)
{
	my $self	= shift ;
	my $end		= shift ;

	$self->[1] = $end ;
	return $self ;
}


sub print
{
	my $self	= shift ;
	my $fh		= shift ;

	print $fh "[" . $self->[0] . ", " . $self->[1] . "]" ;
	return $self ;
}


package SemanticLocationSpan ;

sub new		# ($row, $col)
{
	my $class	= shift ;
	my $row		= shift ;
	my $col		= shift ;

	my $pair = SemanticPair->new( $row, $col ) ;
	my $span = { "start" => $pair } ;
	return bless $span, $class ;
}


sub addEnd	# ($row, $col)
{
	my $self	= shift ;
	my $row		= shift ;
	my $col		= shift ;

	my $pair = SemanticPair->new( $row, $col ) ;
	$self->{"end"} = $pair ;
	return $self ;
}


sub getEnd
{
	my $self	= shift ;

	return $self->{"end"} ;
}


sub print
{
	my $self	= shift ;
	my $fh		= shift ;

	print $fh "{" ;
	if ( $self->{start} ) {
	    print $fh "start: " ;
	    $self->{start}->print($fh) ;
	}
	if ( $self->{end} ) {
	    print($fh ", ")	if ( $self->{start} ) ;
	    print $fh "end: " ;
	    $self->{end}->print($fh) ;
	}
	print $fh "}" ;
	return $self ;
}


package SemanticNode ;

sub new 	# %options
{
	my $class	= shift ;
	my %options	= @_ ;

	return bless { %options }, $class ;
}


sub get		# ($key)
{
	my $self	= shift ;
	my $key		= shift ;

	return $self->{$key} ;
}


sub set		# ($key, $value)
{
	my $self	= shift ;
	my $key		= shift ;
	my $value	= shift ;

	$self->{$key} = $value ;
	return $self ;
}


sub addChild
{
	my $self	= shift ;
	my %options	= @_ ;

# Add new node:
	$self->{"children"} = []	unless ( $self->{"children"} ) ;
	my $node = SemanticNode->new( %options ) ;
	push @{$self->{"children"}}, $node ;

# And return it:
	return $node ;
}


sub addLocationSpan
{
	my $self	= shift ;
	my @pair	= @_ ;

# Add new span:
	my $span = SemanticLocationSpan->new(@pair) ;
	$self->{"locationSpan"} = $span ;
	return $self ;

}


sub endLocationSpan
{
	my $self	= shift ;
	my @pair	= @_ ;

# Set end of span:
	$self->{"locationSpan"}->addEnd(@pair) ;
	return $self ;
}


sub getLocationSpan
{
	my $self	= shift ;

# Return span:
	return $self->{"locationSpan"} ;
}


sub hasLocationSpan
{
	my $self	= shift ;

# Does it have a Location Span?
	return $self->{"locationSpan"} ;
}


sub addSpan
{
	my $self	= shift ;
	my $type	= shift || "span" ;

# Add new span:
	my $pair = SemanticPair->new(@_) ;
	$self->{$type} = $pair ;

# And return it:
	return $pair ;
}


sub print
{
	my $self	= shift ;
	my $fh		= shift ;
	my $indent	= shift ;
	my $start	= shift ;

# Template order:
	my @order = (	"type", "name",
			"locationSpan", "headerSpan", "footerSpan", "span",
			"parsingErrorsDetected",
			"location", "message",
			"children", "parsingError"
		    ) ;

# Descend through our tree
KEY:	foreach $key (@order)
	{
	    my $value = $self->{$key} ;
	    next KEY				unless ( $value ) ;
	# Switch on type:
	    if ($key eq "children") {
		print $fh " " x $indent . $key . ":\n" ;
		foreach $child (@$value)
		{
		    $child->print($fh, $indent + 2, "- ") ;
		}
	    } elsif (ref $value) {
		print $fh " " x $indent . $start . $key . ": " ;
		$value->print($fh) ;
		print $fh "\n" ;
	    } else {
		print $fh " " x $indent . $start . $key . ": " . $value . "\n" ;
		$indent += length($start) ;
		$start	= "" ;
	    }
	}
	return $self ;
}
