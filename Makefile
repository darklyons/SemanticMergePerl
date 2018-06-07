test:
	perl -MTest::Harness -e '$$Test::Harness::verbose=0; runtests <t/*.t>'
