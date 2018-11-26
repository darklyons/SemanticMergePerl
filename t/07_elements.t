#! /usr/bin/perl

use strict ;
use warnings ;
use Test::Script ;
use Test::More tests => 11 ;

my $script = 'parser.pl' ;

script_runs([$script, 'parse', 't/in/07_comment.pl', 't/out/07_comment.yaml'],
	    'Elements - comment') ;
SKIP: {
    eval { require Test::Files } ;
    skip "Test::Files not installed", 1		if ( $@ ) ;

    my $result = "07_comment.yaml" ;
    Test::Files::compare_ok("t/in/$result", "t/out/$result", "Output '$result' is correct") ;
}

script_runs([$script, 'parse', "t/in/07_if.pl", "t/out/07_if.yaml"],
	    'Elements - if statement') ;

script_runs([$script, 'parse', "t/in/07_if-else.pl", "t/out/07_if-else.yaml"],
	    'Elements - if-else statement') ;

script_runs([$script, 'parse', "t/in/07_for.pl", "t/out/07_for.yaml"],
	    'Elements - for statement') ;

script_runs([$script, 'parse', "t/in/07_for-compound.pl", "t/out/07_for-compound.yaml"],
	    'Elements - for compound statement') ;

script_runs([$script, 'parse', "t/in/07_foreach.pl", "t/out/07_foreach.yaml"],
	    'Elements - foreach statement') ;

script_runs([$script, 'parse', "t/in/07_foreach-compound.pl", "t/out/07_foreach-compound.yaml"],
	    'Elements - foreach compound statement') ;

script_runs([$script, 'parse', "t/in/07_while.pl", "t/out/07_while.yaml"],
	    'Elements - while statement') ;

script_runs([$script, 'parse', "t/in/07_while-compound.pl", "t/out/07_while-compound.yaml"],
	    'Elements - while compound statement') ;

script_runs([$script, 'parse', "t/in/07_sub.pl", "t/out/07_sub.yaml"],
	    'Elements - subroutine') ;

done_testing() ;
