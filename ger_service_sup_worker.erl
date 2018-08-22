-module(ger_service_sup_worker).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================


add_logg(Buff) ->
      gen_server:cast(whereis(loger), Buff).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
      add_logg(<<"Start ger_service_sup_worker ">>),
    add_logg(erlang:list_to_binary(erlang:pid_to_list(self()))),

	SupSpec =  {          % Global supervisor options
      one_for_one,        % - use the one-for-one restart strategy
      1000,               % - and allow a maximum of 1000 restarts
      3600                % - per hour for each child process
    },

    ChildSpec = [ 
    ], 

   {ok,  {  SupSpec ,       ChildSpec}}.          