#! /usr/bin/perl

use strict ;
use warnings ;
use Test::Script ;
use Test::More tests => 2 ;

my $script = 'parser.pl' ;

script_runs([$script, 'shell', 'file.tmp~'],
	    { stdin => \"test.pm\nutf-8\n/dev/tty\nend" },
	    'Parse package test.pm') ;

script_runs([$script, 'shell', 'file.tmp~'],
	    { stdin => \"Point.pm\nutf-8\n/dev/tty\nend" },
	    'Parse package test.pm') ;

done_testing() ;
