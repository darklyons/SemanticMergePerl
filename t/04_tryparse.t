#! /usr/bin/perl

use strict ;
use warnings ;
use Test::Script ;
use Test::More tests => 3 ;

my $script = 'parser.pl' ;

script_runs([$script, 'shell', 't/out/ff'],
	    { stdin => \"t/in/tryparse.pl\nutf-8\nt/out/tryparse.yaml\nend" },
	    'Parse package tryparse.pl') ;
script_stdout_is("OK\n", "Return success for tryparse.pl") ;
SKIP: {
    eval { require Test::Files } ;
    skip "Test::Files not installed", 1		if ( $@ ) ;

    my $result = "tryparse.yaml" ;
    Test::Files::compare_ok("t/in/$result", "t/out/$result", "Output '$result' is correct") ;
}

done_testing() ;
