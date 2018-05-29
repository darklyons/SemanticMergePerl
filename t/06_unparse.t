#! /usr/bin/perl

use strict ;
use warnings ;
use Test::Script ;
use Test::More tests => 3 ;

my $script = 'parser.pl' ;

script_runs([$script, 'shell', 't/out/ff'],
	    { stdin => \"t/in/unparse.pm\nutf-8\nt/out/unparse.yaml\nend" },
	    'Parse package unparse.pm') ;
script_stdout_is("OK\n", "Return success for unparse.pm") ;
SKIP: {
    eval { require Test::Files } ;
    skip "Test::Files not installed", 1		if ( $@ ) ;

    my $result = "unparse.yaml" ;
    Test::Files::compare_ok("t/in/$result", "t/out/$result", "Output '$result' is correct") ;
}

done_testing() ;
