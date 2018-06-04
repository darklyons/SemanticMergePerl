#! /usr/bin/perl

use strict ;
use warnings ;
use Test::Script ;
use Test::More tests => 2 ;

my $script = 'parser.pl' ;

script_runs([$script, 'shell', 't/out/ff'],
	    { stdin => \"t/in/test.pm\nutf-8\nt/out/test.yaml\nt/in/test.pm\nutf-8\nt/out/test.yaml\nend" },
	    'Parse test.pm twice') ;
script_stdout_is("OK\nOK\n", "Return success twice") ;

done_testing() ;
