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

# Import modules:
	use PPI ;

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
	# Grab triplet:
	    $INPUT	= <> ;	chomp($INPUT) ;
	    last			if ($INPUT eq "end") ;
	    $ENCODING	= <> ;	chomp($ENCODING) ;
	    $OUTPUT	= <> ;	chomp($OUTPUT) ;

	# Setup for parsing:
	    -r $INPUT 
		|| die "$0: Cannot open input file '$INPUT' - $!\n" ;
	    open(my $outfh, ">", $OUTPUT) 
		|| die "$0: Cannot open output file '$OUTPUT' - $!\n" ;

	# Call the parser:
	    SemanticParse($INPUT, $outfh) ;
	    exit(0) ;
	}

# Finish:
	exit(0) ;

#
# SUBROUTINES
#

sub SemanticParse	# ($inputFile, $outfh)
{
    # Arguments:
	my $inputFile	= shift ;
	my $outfh	= shift ;

    # Init declarations tree:
	my $tree = SemanticNode->new( "type" => "file", "name" => $inputFile ) ;

    # Create the parse tree:
	my $dom	= PPI::Document->new($inputFile) ;

    # Process it:
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
		    $node = $child = $tree->addChild( "type" => $type, "name" => $name ) ;
		    $pair = $child->addSpan("headerSpan") ;
		    $child->addSpan("footerSpan", 0, -1) ;
	    # Include (a node):
		} elsif ($type eq "Include") {
		    $name = $element->module ;
		    $node = $child->addChild( "type" => $type, "name" => $name ) ;
		    $pair = $node->addSpan() ;
	    # Sub (a node):
		} elsif ($type eq "Sub") {
		    $name = $element->name ;
		    $node = $child->addChild( "type" => $type, "name" => $name ) ;
		    $pair = $node->addSpan() ;
	    # Other (nodes):
		} else {
		    $node = $child->addChild( "type" => $type ) ;
		    $pair = $node->addSpan() ;
		}

	    # Keep track of the content for debugging purposes:
		$debugmsg .= $content ;
		print(STDERR $debugmsg)		if ( $main::DEBUG ) ;
		$debugmsg = "" ;

	    # Calculate location span:
		$tree->addLocationSpan(@curPair)	unless ( $tree->hasLocationSpan ) ;
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
	if ( $dom->complete ) {
	    print STDOUT "OK\n" ;
	} else {
	    print STDOUT "KO\n" ;
	}
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
