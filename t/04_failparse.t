#! /usr/bin/perl

use strict ;
use warnings ;
use Test::Script ;
use Test::More tests => 2 ;

my $script = 'parser.pl' ;

script_runs([$script, 'shell', 't/out/ff'],
	    { stdin => \"unparse.pm\nutf-8\nt/out/unparse.yaml\nend" },
	    'Parse package unparse.pm') ;

script_stdout_is("KO\n", "Return error for unparse.pm") ;

done_testing() ;
