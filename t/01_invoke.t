#! /usr/bin/perl

use strict ;
use warnings ;
use Test::Script ;
use Test::More tests => 13 ;

my $script = 'parser.pl' ;

script_compiles($script, 'Script compiles') ;

script_runs($script, { exit => 255 }, 'Die on zero arguments') ;
script_stderr_like( 'Insufficient arguments', 'Message for zero arguments') ;

script_runs([$script, 'shell', 'two', 'three'], { exit => 255 }, 'Die on three arguments') ;
script_stderr_like( 'Too many arguments', 'Message for three arguments') ;

script_runs([$script, 'unknown', 'file.tmp'], { exit => 255 }, 'Die on bad command') ;
script_stderr_like( 'argument must be', 'Message for bad command') ;

script_runs([$script, 'shell', '.'], { exit => 255 }, 'Fail on bad flag file') ;

script_runs([$script, 'shell', 't/out/ff'], { stdin => \'end' }, 'Minimal invokation') ;

script_runs([$script, 'shell', 't/out/ff'],
	    { stdin => \"t/in/missing file\nutf-8\nt/out/missing.yaml\nend" },
	    'Parse missing file') ;
script_stdout_is("KO\n", "Return failure for missing file") ;

script_runs([$script, 'shell', 't/out/ff'],
	    { stdin => \"t/in/test.pm\nutf-8\nt/out/test.yaml\nt/in/test.pm\nutf-8\nt/out/test.yaml\nend" },
	    'Parse test.pm twice') ;
script_stdout_is("OK\nOK\n", "Return success twice") ;

done_testing() ;
