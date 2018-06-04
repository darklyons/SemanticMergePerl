# Perl plugin for Semantic Merge

This plugin is designed to be used with Plastic SCM's Semantic Merge product.
It allows Semantic Merge to work with Perl code by providing the necessary
parsing support.

Guidance in its writing came from the documentation on the writing of [external parsers](https://users.semanticmerge.com/documentation/external-parsers/external-parsers-guide.shtml).

Requirements
============

The program requires that the [PPI](http://search.cpan.org/~mithaldu/PPI-1.236/lib/PPI.pm)
module is installed on the system.  This should be available in most Perl installations; otherwise it can be installed using CPAN.

Tests
-----

Additionally, for running the tests, the [Test::Script](http://search.cpan.org/dist/Test-Script/lib/Test/Script.pm) module is required.

The [Test::Files](http://search.cpan.org/perldoc/Test::Files) module is optional.  (If it is not installed, its tests are skipped.)
