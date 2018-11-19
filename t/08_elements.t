#! /usr/bin/perl

use strict ;
use warnings ;
use Test::Script ;
use Test::More tests => 9 ;

my $script = 'parser.pl' ;

script_runs([$script, 'parse', "t/in/if.pl", "t/out/if.yaml"],
	    'Elements - if statement') ;

script_runs([$script, 'parse', "t/in/if-else.pl", "t/out/if-else.yaml"],
	    'Elements - if-else statement') ;

script_runs([$script, 'parse', "t/in/for.pl", "t/out/for.yaml"],
	    'Elements - for statement') ;

script_runs([$script, 'parse', "t/in/for-compound.pl", "t/out/for-compound.yaml"],
	    'Elements - for compound statement') ;

script_runs([$script, 'parse', "t/in/foreach.pl", "t/out/foreach.yaml"],
	    'Elements - foreach statement') ;

script_runs([$script, 'parse', "t/in/foreach-compound.pl", "t/out/foreach-compound.yaml"],
	    'Elements - foreach compound statement') ;

script_runs([$script, 'parse', "t/in/while.pl", "t/out/while.yaml"],
	    'Elements - while statement') ;

script_runs([$script, 'parse', "t/in/while-compound.pl", "t/out/while-compound.yaml"],
	    'Elements - while compound statement') ;

script_runs([$script, 'parse', "t/in/sub.pl", "t/out/sub.yaml"],
	    'Elements - subroutine') ;

done_testing() ;
