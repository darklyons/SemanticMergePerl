#! /usr/bin/perl

use strict ;
use warnings ;
use Test::Script ;
use Test::More tests => 9 ;

my $script = 'parser.pl' ;

script_compiles($script, 'Script compiles') ;

script_runs($script, { exit => 255 }, 'Die on zero arguments') ;
script_stderr_like( 'Insufficient arguments', 'Message for zero arguments') ;

script_runs([$script, 'one', 'two', 'three'], { exit => 255 }, 'Die on three arguments') ;
script_stderr_like( 'Too many arguments', 'Message for three arguments') ;

script_runs([$script, 'unknown', 'file.tmp'], { exit => 255 }, 'Die on bad command') ;
script_stderr_like( 'argument must be', 'Message for bad command') ;

script_runs([$script, 'shell', '.'], { exit => 21 }, 'Fail on bad flag file') ;

script_runs([$script, 'shell', 't/out/ff'], { stdin => \'end' }, 'Minimal invokation') ;

done_testing() ;
