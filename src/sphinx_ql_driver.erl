-module(sphinx_ql_driver).

-include_lib("emysql/include/emysql.hrl").

-export([new/1, run/4]).

new(Id) ->
    Host = basho_bench_config:get(host, "localhost"),
    Port = basho_bench_config:get(port, 9306),

    application:start(crypto),
    application:start(emysql),

    ok = emysql:add_pool(
        Id,
        1, % connection count
        "username", % doesn't matter for Sphinx
        undefined,
        Host,
        Port,
        undefined, % no database
        latin1 % whatever really
    ),
    {ok, Id}.

run(get, _KeyGen, _ValueGen, Id) ->
    %Query = <<"show tables">>,
    Query = <<"select * from game_data_index where MATCH('Action') ",
    "order by total_play_count desc limit 10;">>,
    case emysql:execute(Id, Query) of
        #result_packet{rows=Rows} when length(Rows) =:= 10 ->
            {ok, Id};
        Res ->
            {stop, {wrong_result, Res}}
    end.
