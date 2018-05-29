#! /usr/bin/perl

use strict ;
use warnings ;
use Test::Script ;
use Test::More tests => 6 ;

my $script = 'parser.pl' ;

script_runs([$script, 'shell', 't/out/ff'],
	    { stdin => \"t/in/test.pm\nutf-8\nt/out/test.yaml\nend" },
	    'Parse package test.pm') ;
script_stdout_is("OK\n", "Return success for test.pm") ;

script_runs([$script, 'shell', 't/out/ff'],
	    { stdin => \"t/in/tryparse.pl\nutf-8\nt/out/tryparse.yaml\nend" },
	    'Parse package tryparse.pl') ;
script_stdout_is("OK\n", "Return success for tryparse.pl") ;

script_runs([$script, 'shell', 't/out/ff'],
	    { stdin => \"t/in/Point.pm\nutf-8\nt/out/Point.yaml\nend" },
	    'Parse package Point.pm') ;
script_stdout_is("OK\n", "Return success for Point.pm") ;

done_testing() ;
