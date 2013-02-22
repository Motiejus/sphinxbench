-module(sphinxbench).

-export([main/1]).

main(Args) ->
    basho_bench:main(Args).
