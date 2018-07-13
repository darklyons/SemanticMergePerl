#! /usr/bin/perl

use strict ;
use warnings ;
use Test::Script ;
use Test::More tests => 2 ;

my $script = 'parser.pl' ;

script_runs([$script, 'parse', 'parse.pl', 't/out/parset.yaml'],
	    'Self parse') ;

SKIP: {
    eval { require Test::Files } ;
    skip "Test::Files not installed", 1		if ( $@ ) ;

    my $result = "parser.yaml" ;
    Test::Files::compare_ok("t/in/$result", "t/out/$result", "Output '$result' is correct") ;
}

done_testing() ;
