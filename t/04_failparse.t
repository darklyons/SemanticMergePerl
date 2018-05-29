#! /usr/bin/perl

use strict ;
use warnings ;
use Test::Script ;
use Test::More tests => 4 ;

my $script = 'parser.pl' ;

script_runs([$script, 'shell', 't/out/ff'],
	    { stdin => \"t/in/unparse.pm\nutf-8\nt/out/unparse.yaml\nend" },
	    'Parse package unparse.pm') ;

script_stdout_is("OK\n", "Return success for unparse.pm") ;

script_runs([$script, 'shell', 't/out/ff'],
	    { stdin => \"t/in/missing file\nutf-8\nt/out/missing.yaml\nend" },
	    'Parse missing file') ;

script_stdout_is("KO\n", "Return failure for missing file") ;

done_testing() ;
