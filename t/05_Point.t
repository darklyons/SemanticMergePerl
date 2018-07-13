#! /usr/bin/perl

use strict ;
use warnings ;
use Test::Script ;
use Test::More tests => 2 ;

my $script = 'parser.pl' ;

script_runs([$script, 'parse', 't/in/Point.pm', 't/out/Point.yaml'],
	    'Parse package Point.pm') ;
SKIP: {
    eval { require Test::Files } ;
    skip "Test::Files not installed", 1		if ( $@ ) ;

    my $result = "Point.yaml" ;
    Test::Files::compare_ok("t/in/$result", "t/out/$result", "Output '$result' is correct") ;
}

done_testing() ;
