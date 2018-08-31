-module(loger).
-behaviour(gen_server).
-define(SERVER, ?MODULE).

%% ------------------------------------------------------------------
%% API Function Exports
%% ------------------------------------------------------------------

-export([start_link/0]).

%% ------------------------------------------------------------------
%% gen_server Function Exports
%% ------------------------------------------------------------------

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

%% ------------------------------------------------------------------
%% API Function Definitions
%% ------------------------------------------------------------------




start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).


    add_long_string([], Acc) -> Acc;

    add_long_string([Head | Tail], Acc) ->
        add_long_string(Tail,<<Acc/binary, Head/binary>>).

    get_time_to_string(Day, Time) ->

    {Y, M, D} = Day,
    {H, Min, Sec} =Time,

    add_long_string([
        erlang:integer_to_binary(Y), <<"_">>,
        erlang:integer_to_binary(M), <<"_">>,
        erlang:integer_to_binary(D), <<"_">>,
        erlang:integer_to_binary(H), <<"_">>,
        erlang:integer_to_binary(Min), <<"_">>,
        erlang:integer_to_binary(Sec)],  <<"">>).


%% ------------------------------------------------------------------
%% gen_server Function Definitions
%% ------------------------------------------------------------------

init([]) ->
    
    gen_server:cast(self(), <<"Start ger_service_sup ">>),
       gen_server:cast(self(), erlang:list_to_binary(erlang:pid_to_list(whereis(ger_service_sup)))),

    FileName = add_long_string([ <<"Logs/">>, get_time_to_string(erlang:date(), erlang:time()), <<".txt">>], <<"">>),
    %io:format("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~p!!!!!!!!!!!!!!!!!!!!!!!!!!~n", [FileName]),
    %{ok, S} = file:open(FileName, write),

    {ok, []}.


handle_call(_Request, _From, State) ->


    {reply, ok, State}.

handle_cast(_Msg, State) ->

    %io:format(State, "\~s\~n", [add_long_string([<<"\n">>,get_time_to_string(erlang:date(), erlang:time()), <<"\n">>, _Msg], <<"">>)]),
    %file:write_file(State,  add_long_string([<<"\n">>,get_time_to_string(erlang:date(), erlang:time()), <<"\n">>, _Msg], <<"">>),  [binary] ),

    {noreply, State}.

handle_info(_Info, State) ->
    io:format("Handle_INFO\n"),
    {noreply, State}.

terminate(_Reason, _State) ->

    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% ------------------------------------------------------------------
%% Internal Function Definitions
%% ------------------------------------------------------------------
