-module(sphinx_driver).

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
        latin1 % we just want to be compatible
    ),

    {ok, Id}.

run(get, _KeyGen, _ValueGen, Id) ->
    Query = <<"select * from game_data_index where MATCH('Action') ",
    "order by total_play_count desc limit 10;">>,
    #result_packet{rows=Rows} = emysql:execute(Id, Query),
    case length(Rows) of
        10 -> {ok, Id};
        _ -> {stop, {wrong_rows, length(Rows)}}
    end.
