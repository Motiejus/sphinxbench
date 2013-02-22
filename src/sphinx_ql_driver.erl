-module(sphinx_ql_driver).

-include_lib("emysql/include/emysql.hrl").

-export([new/1, run/4]).

new(Id) ->
    Host = basho_bench_config:get(host, "localhost"),
    Port = basho_bench_config:get(port, 9306),
    Type = basho_bench_config:get(type),

    application:start(crypto),
    application:start(emysql),

    ok = emysql:add_pool(Id, 1, "u", undefined, Host, Port, undefined, latin1),

    Query = case Type of
        light ->
            <<"select * from game_data_index where siteid=0;">>;
        heavy ->
            <<"select * from game_data_index where MATCH('Action') ",
            "order by total_play_count desc limit 10;">>
    end,
    {ok, {Type, Id, Query}}.

run(get, _KeyGen, _ValueGen, {Type, Id, Query}=State) ->
    case {Type, emysql:execute(Id, Query)} of
        {light, #result_packet{rows=[]}} ->
            {ok, State};
        {heavy, #result_packet{rows=Rows}} when length(Rows) =:= 10 ->
            {ok, State};
        Res ->
            {stop, {wrong_result, Res}}
    end.
