-module(sphinx_bin_driver).

-include_lib("giza/src/giza.hrl").

-export([new/1, run/4]).

new(_Id) ->
    Host = basho_bench_config:get(host, "localhost"),
    Port = basho_bench_config:get(port, 9316),

    Q1 = giza_query:new("game_data_index", "Action"),
    Q2 = giza_query:host(Q1, Host),
    Q3 = giza_query:port(Q2, Port),
    Q4 = giza_query:limit(Q3, 10),
    Q5 = giza_query:sort_extended(Q4, "total_play_count desc"),
    {ok, Q5}.

run(get, _KeyGen, _ValueGen, Query) ->
    case giza_request:send(Query) of
        {ok, #giza_query_result{matches=M}} when length(M) =:= 10 ->
            {ok, Query};
        Res ->
            {stop, {wrong_result, Res}}
    end.
