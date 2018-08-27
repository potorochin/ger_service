-module(workerInf).
-behaviour(gen_server).
-define(SERVER, ?MODULE).

%% ------------------------------------------------------------------
%% API Function Exports
%% ------------------------------------------------------------------

-export([start_link/1]).

%% ------------------------------------------------------------------
%% gen_server Function Exports
%% ------------------------------------------------------------------

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

%% ------------------------------------------------------------------
%% API Function Definitions
%% ------------------------------------------------------------------

add_logg(Buff) ->
    gen_server:cast(whereis(loger), Buff).


start_link(Text) ->
    gen_server:start_link(?MODULE, [Text], []).



%% ------------------------------------------------------------------
%% gen_server Function Definitions
%% ------------------------------------------------------------------

init(Args) ->
    
    add_logg(<<"Start Worker ">>),   
    add_logg(atom_to_binary(?SERVER, latin1)), 
        add_logg(erlang:list_to_binary(erlang:pid_to_list(self()))),
        io:format("~p~n", [Args]),


    {ok, Args}.


handle_call(_Request, _From, State) ->


    {reply, ok, State}.

handle_cast(_Msg, State) ->


    {noreply, State}.

handle_info(_Info, State) ->
	io:format("Handle_INFO\n"),
    {noreply, State}.

terminate(_Reason, _State) ->
    add_logg(<<"Closed Worker">>),
    add_logg(atom_to_binary(?SERVER, latin1)), 

        add_logg(erlang:list_to_binary(erlang:pid_to_list(self()))),

    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% ------------------------------------------------------------------
%% Internal Function Definitions
%% ------------------------------------------------------------------

