-module(aceptor).
-behaviour(gen_server).
-define(SERVER, ?MODULE).

%% ------------------------------------------------------------------
%% API Function Exports
%% ------------------------------------------------------------------

-export([start_link/1]).

%% ------------------------------------------------------------------
%% gen_server Function Exports
%% ------------------------------------------------------------------

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, open_socket/1, get_inf/1,
         terminate/2, code_change/3]).

%% ------------------------------------------------------------------
%% API Function Definitions
%% ------------------------------------------------------------------

start_link(Port) ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [Port], []).

%% ------------------------------------------------------------------
%% gen_server Function Definitions
%% ------------------------------------------------------------------

init(Args) ->
	%%io:format("~p Work Sup ~n", [whereis(ger_service_sup_worker)]),
    {ok, Args}.



    open_socket(Pid) ->
    	gen_server:cast(Pid, socket).

    get_inf(Pid) ->
    	gen_server:call(Pid, show).

   	do_recv(Sock, Bs) ->
    	case gen_tcp:recv(Sock, 0) of
        	{ok, B} -> 
	        	case B of
	        		"Stop\r\n" -> 
	            {ok, Bs};
	             _ ->
	             io:format("~p~n",[B]),
	        	do_recv(Sock, [lists:reverse(lists:nthtail(2, lists:reverse(B))) | Bs])
        	end;
        {error, closed} ->
            {ok, Bs}
    end.



handle_call(_Request, _From, State) ->
	
	case _Request of 
		show -> io:format("~p~n", [State]);
		_ -> io:format("Unknown Command\n")
    end,


    {reply, ok, State}.

handle_cast(_Msg, State) ->

	case _Msg of
		socket -> 
		io:format("~p~n", [State]),
		[Port |  _] = lists:reverse(State),
		io:format("Open From p ~p~n", [Port]),
	
  	case gen_tcp:listen(Port, [{packet, raw}, {active, false},{reuseaddr, true}]) of
        {ok,LSock}  ->
	        {ok, Sock} = gen_tcp:accept(LSock),
		    {ok, Bin} = do_recv(Sock, []),

			ok = gen_tcp:close(Sock),
		    ok = gen_tcp:close(LSock),
		    io:format("~p~n", [Bin]),
		    {noreply, [Bin | State]};

        {error,eaddrinuse} -> io:format("error eaddrinuse in listen ~n"),
    	{noreply, State}
    end;
 
    	_ -> io:format("Unknown Command\n"),
    	{noreply, State}
    end.



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

