-module(sphinx_bin_driver).

-include_lib("giza/src/giza.hrl").

-export([new/1, run/4]).

new(_Id) ->
    Host = basho_bench_config:get(host, "localhost"),
    Port = basho_bench_config:get(port, 9312),
    Type = basho_bench_config:get(type),

    Query = case Type of
        light ->
            Q1 = giza_query:new("game_data_index", ""),
            Q2 = giza_query:host(Q1, Host),
            Q3 = giza_query:port(Q2, Port),
            giza_query:add_filter(Q3, "siteid", [0]);
        heavy ->
            Q1 = giza_query:new("game_data_index", "Action"),
            Q2 = giza_query:host(Q1, Host),
            Q3 = giza_query:port(Q2, Port),
            Q4 = giza_query:limit(Q3, 10),
            Q5 = giza_query:add_filter(Q4, "siteid", [12]),
            giza_query:sort_extended(Q5, "total_play_count desc")
    end,
    {ok, {Type, Query}}.

run(get, _KeyGen, _ValueGen, {Type, Query}=State) ->
    case {Type, giza_request:send(Query)} of
        {light, {ok, #giza_query_result{matches=[]}}} ->
            {ok, State};
        {heavy, {ok, #giza_query_result{matches=M}}} when length(M) =:= 10 ->
            {ok, State};
        Res ->
            {stop, {wrong_result, Res}}
    end.
