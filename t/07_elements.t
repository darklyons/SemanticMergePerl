#! /usr/bin/perl

use strict ;
use warnings ;
use Test::Script ;
use Test::More ;

my $script = 'parser.pl' ;
my $count = 0 ;

foreach my $result ( <t/in/07_*.pl> )
{
    $count++ ;
    $result =~ s#.*/## ;
    $result =~ s/\.pl$// ;
    script_runs([$script, 'parse', "t/in/$result.pl", "t/out/$result.yaml"],
	        "Elements - $result") ;
}

SKIP: {
    eval { require Test::Files } ;
    skip "Test::Files not installed", $count		if ( $@ ) ;

    foreach my $result ( <t/in/07_*.yaml> )
    {
        $result =~ s#.*/## ;
        Test::Files::compare_ok("t/in/$result", "t/out/$result", "Output '$result' is correct") ;
    }
}

done_testing($count*2) ;
