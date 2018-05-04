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
	my($row, $col) ;
	my $child = $tree ;
	my $node = $child ;
	foreach $element ( $dom->elements )
	{
	    print STDERR $element->class . "\t" .
			 $element->significant . "\t" .
			 "start: [" . $element->location->[0] . "," .
			 $element->location->[1] . "]\t" .
			 $element->content . "\n" ;
	# Extract element:
	    my $type = $element->class ;	$type =~ s/.*::// ;
	    my $name = $element->content ;	chomp($name) ;
	# Detect packages;
	    if ($type eq "Package") {
		$name = $element->namespace ;
		$node = $child = $tree->addChild( "type" => $type, "name" => $name ) ;
	    } elsif ($type eq "Include") {
		$name = $element->module ;
		$node = $child->addChild( "type" => $type, "name" => $name ) ;
	    } elsif ($type eq "Sub") {
		$name = $element->name ;
		$node = $child->addChild( "type" => $type, "name" => $name ) ;
	    } else {
		$node = $child->addChild( "type" => $type, "name" => $name ) ;
	    }
	# Calculate span:
	# TBD: Whitespace needs to be folded into appropriate element
	    my($lines) = $element->content ;	$lines =~ s/\n$// ;
	    my($nrows) = $lines =~ s/.*\n// ;
	    $node->addSpan($element->location->[0], $element->location->[1]-1) ;
	    $node->endSpan($element->location->[0] + $nrows, length($lines)) ;
	}

# YAML output:
	$tree->print($outfh) ;
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


sub print
{
	my $self	= shift ;
	my $fh		= shift ;

	print $fh "[" . $self->[0] . ", " . $self->[1] . "]" ;
}


package SemanticSpan ;

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
	return $pair ;
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
	print $fh "}\n" ;
}


package SemanticNode ;

sub new 	# %options
{
	my $class	= shift ;
	my %options	= @_ ;

	return bless { %options }, $class ;
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


sub addSpan
{
	my $self	= shift ;
	my @span	= @_ ;

# Add new span:
	my $span = SemanticSpan->new(@span) ;
	$self->{"locationSpan"} = $span ;

# And return it:
	return $span ;
}


sub endSpan
{
	my $self	= shift ;
	my @span	= @_ ;

# Set end of span:
	$self->{"locationSpan"}->addEnd(@span) ;

# And return it:
	return $span ;
}


sub hasSpan
{
	my $self	= shift ;

# Does it have a Location Span?
	return $self->{"locationSpan"} ;
}


sub print
{
	my $self	= shift ;
	my $fh		= shift ;
	my $indent	= shift ;
	my $start	= shift ;

# Template order:
	my @order = (	"type", "name",
			"locationSpan", "headerSpan", "footerSpan",
			"parsingeErrorsDetected",
			"children", "parsingError",
			"location", "message"
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
	    } else {
		print $fh " " x $indent . $start . $key . ": " . $value . "\n" ;
		$indent += length($start) ;
		$start	= "" ;
	    }
	}
}
