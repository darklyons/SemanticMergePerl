#! /usr/bin/perl

use strict ;
use warnings ;
use Test::Script ;
use Test::More tests => 9 ;

my $script = 'parser.pl' ;

script_runs([$script, 'shell', 't/out/ff'],
	    { stdin => \"t/in/test.pm\nutf-8\nt/out/test.yaml\nend" },
	    'Parse package test.pm') ;
script_stdout_is("OK\n", "Return success for test.pm") ;
SKIP: {
    eval { use Test::Files } ;
    skip "Test::Files not installed", 1		if ( $@ ) ;

    my $result = "test.yaml" ;
    compare_ok("t/in/$result", "t/out/$result", "Output '$result' is correct") ;
}

script_runs([$script, 'shell', 't/out/ff'],
	    { stdin => \"t/in/tryparse.pl\nutf-8\nt/out/tryparse.yaml\nend" },
	    'Parse package tryparse.pl') ;
script_stdout_is("OK\n", "Return success for tryparse.pl") ;
SKIP: {
    eval { use Test::Files } ;
    skip "Test::Files not installed", 1		if ( $@ ) ;

    my $result = "tryparse.yaml" ;
    compare_ok("t/in/$result", "t/out/$result", "Output '$result' is correct") ;
}

script_runs([$script, 'shell', 't/out/ff'],
	    { stdin => \"t/in/Point.pm\nutf-8\nt/out/Point.yaml\nend" },
	    'Parse package Point.pm') ;
script_stdout_is("OK\n", "Return success for Point.pm") ;
SKIP: {
    eval { use Test::Files } ;
    skip "Test::Files not installed", 1		if ( $@ ) ;

    my $result = "Point.yaml" ;
    compare_ok("t/in/$result", "t/out/$result", "Output '$result' is correct") ;
}

done_testing() ;
