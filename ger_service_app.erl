-module(ger_service_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_Type, Port) ->
    ger_service_sup:start_link(Port).

stop(_State) ->
    ok.