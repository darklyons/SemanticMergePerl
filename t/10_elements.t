#! /usr/bin/perl

use strict ;
use warnings ;
use Test::Script ;
use Test::More tests => 8 ;

my $script = 'parser.pl' ;

script_runs([$script, 'shell', 't/out/ff'],
	    { stdin => \"t/in/if.pl\nutf-8\nt/out/if.yaml\n\nend" },
	    'Elements - if statement') ;

script_runs([$script, 'shell', 't/out/ff'],
	    { stdin => \"t/in/if-else.pl\nutf-8\nt/out/if-else.yaml\n\nend" },
	    'Elements - if-else statement') ;

script_runs([$script, 'shell', 't/out/ff'],
	    { stdin => \"t/in/for.pl\nutf-8\nt/out/for.yaml\n\nend" },
	    'Elements - for statement') ;

script_runs([$script, 'shell', 't/out/ff'],
	    { stdin => \"t/in/for-compound.pl\nutf-8\nt/out/for-compound.yaml\n\nend" },
	    'Elements - for statement') ;

script_runs([$script, 'shell', 't/out/ff'],
	    { stdin => \"t/in/foreach.pl\nutf-8\nt/out/foreach.yaml\n\nend" },
	    'Elements - foreach statement') ;

script_runs([$script, 'shell', 't/out/ff'],
	    { stdin => \"t/in/foreach-compound.pl\nutf-8\nt/out/foreach-compound.yaml\n\nend" },
	    'Elements - foreach statement') ;

script_runs([$script, 'shell', 't/out/ff'],
	    { stdin => \"t/in/while.pl\nutf-8\nt/out/while.yaml\n\nend" },
	    'Elements - while statement') ;

script_runs([$script, 'shell', 't/out/ff'],
	    { stdin => \"t/in/while-compound.pl\nutf-8\nt/out/while-compound.yaml\n\nend" },
	    'Elements - while statement') ;

done_testing() ;
