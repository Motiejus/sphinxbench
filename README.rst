Highly specialized Sphinx search engine benchmark
=================================================

Performance benchmark of our quite specific Sphinx index. Briefly:

1. # of documents: ~300K
2. Index size: 2MB

Will test serial and parallel hits to sphinx. Mainly interested in qps per
node.

Two protocols are tested: SphinxQL (MySQL style) and SphinxBin ("old" binary
protocol).

How to run benchmarks
---------------------

There are 2 testing modes: ``light``, where query is as lightweight as possible
(empty query with a filter ``siteid = 0``). ``heavy`` is the "heaviest" query I
could construct. In QL::

    select *
        from game_data_index
        where MATCH('Action')
        order by total_play_count desc
        limit 10;

In order to execute the tests, run ``$ make``, and for SphinxQL benchmark::

    $ ./sphinxbench ./sphinx_ql.conf

or for binary protocol benchmark::

    $ ./sphinxsearch ./sphinx_bin.conf

These are interesting configuration parameters in ``sphinx_ql.conf`` and
``sphinx_bin.conf``::

    {duration, 1}. % How long to run tests, in minutes

    {concurrent, 1}. % How many concurrent workers

    {host, "127.0.0.1"}. % Where to find sphinx server

    {port, 9306}. % Port to SphinxQL service

    {type, heavy}. % 'heavy' or 'light'


To get the graphs, run this after the tests::

    $ make results

And have a look at ``tests`` directory.

Plotting data
-------------

This gives a nice plot where you can see results of multiple benchmarks::

    $ ./bench_plot.py tests/*

This command will plot all executed benchmarks. You can do something more
sensible instead. For example, you have two benchmarks: ``light_ql_1``,
``light_ql_2`` and ``light_ql_3`` (one, two and three parallel workers).
Then you would plot them like this::

    $ ./bench_plot.py tests/light_*

For more information check `basho_bench`_ documentation.

.. _basho_bench: http://docs.basho.com/riak/latest/cookbooks/Benchmarking/
