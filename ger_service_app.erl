-module(ger_service_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_Type, _Args) ->
    ger_service_sup:start_link().

stop(_State) ->
	application:stop(ger_service_app),
    ok.