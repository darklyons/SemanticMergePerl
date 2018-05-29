#! /usr/bin/perl

use strict ;
use warnings ;
use Test::Script ;
use Test::More tests => 3 ;

my $script = 'parser.pl' ;

script_runs([$script, 'shell', 't/out/ff'],
	    { stdin => \"t/in/Point.pm\nutf-8\nt/out/Point.yaml\nend" },
	    'Parse package Point.pm') ;
script_stdout_is("OK\n", "Return success for Point.pm") ;
SKIP: {
    eval { require Test::Files } ;
    skip "Test::Files not installed", 1		if ( $@ ) ;

    my $result = "Point.yaml" ;
    Test::Files::compare_ok("t/in/$result", "t/out/$result", "Output '$result' is correct") ;
}

done_testing() ;
