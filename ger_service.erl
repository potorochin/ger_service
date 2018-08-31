-module(ger_service).
-export([start/0]).

start() ->
	application:start(ger_service).