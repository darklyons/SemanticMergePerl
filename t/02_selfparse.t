#! /usr/bin/perl

use strict ;
use warnings ;
use Test::Script ;
use Test::More tests => 3 ;

my $script = 'parser.pl' ;

script_runs([$script, 'shell', 't/out/ff'],
	    { stdin => \"parser.pl\nutf-8\nt/out/parser.yaml\nend" },
	    'Self parse') ;
script_stdout_is("OK\n", "Return success on self parse") ;

SKIP: {
    eval { use Test::Files } ;
    skip "Test::Files not installed", 1		if ( $@ ) ;

    my $result = "parser.yaml" ;
    compare_ok("t/in/$result", "t/out/$result", "Output '$result' is correct") ;
}

done_testing() ;
