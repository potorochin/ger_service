-module(aceptor).
-behaviour(gen_server).
-define(SERVER, ?MODULE).
-define(REQUEST_HGROUPS, <<"GET /ru/bets HTTP/1.1\r\n",
"Host: www.favbet.com\r\n",
"User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; r61.0) Gecko/20100101 Firefox/61.0\r\n\r\n" >>).
%,
%"Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\n",
%"Accept-Language: en-GB,en;q=0.5\r\n",
%"Accept-Encoding: gzip, deflate, br\r\n",
%% "Proxy-Authorization: Basic ZG4yNTExOTZwYnY6MjUyNTExMzNwYXJvbA==\r\n",
%"Connection: keep-alive\r\n",
%"Upgrade-Insecure-Requests: 1\r\n",
%"Cache-Control: max-age=0\r\n\r\n">>).


-define(REQUEST_GOOGLE, <<"GET / HTTP/1.1\r\nHost 216.58.209.68\r\n\r\n">>).
-define(REQUEST_CONNECT, <<"CONNECT www.favbet.com:443 HTTP/1.1\r\nHost: 10.61.145.254\r\n\r\n">>).


%% 119  2.988775247 10.42.6.157 10.62.128.249   HTTP    340 CONNECT www.favbet.com:443 HTTP/1.1 

-record(state, {host = "", port = "", tcp_socket=""}).
%% ------------------------------------------------------------------
%% API Function Exports
%% ------------------------------------------------------------------

-export([start_link/0]).
-export([open_socket/1, get_inf/1, addChild/1, pars_exchange/1, state/0, head_groups/0]).

%% ------------------------------------------------------------------
%% gen_server Function Exports
%% ------------------------------------------------------------------

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

%% ------------------------------------------------------------------
%% API Function Definitions
%% ------------------------------------------------------------------
state() ->
    gen_server:call(?MODULE, state).

head_groups() ->
    ?MODULE ! {send, ?REQUEST_HGROUPS}.


start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).


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
	            
	            Rez = lists:reverse(lists:nthtail(2, lists:reverse(B))),
	            
	        	do_recv(Sock, [Rez | Bs])
        	end;
        {error, closed} ->
            {ok, Bs}
    end.

    add_logg(Buff) ->
    	gen_server:cast(whereis(loger), Buff).



addChild(Pid) ->
	gen_server:call(Pid, addwork).



pars_exchange(Pid) ->
	gen_server:cast(Pid, exchange).

findWorker([], _) -> [];

findWorker([Head | Tail], Counter) -> 

	W = <<"workerInf">>,
	Count = erlang:integer_to_binary(Counter),

	Name = erlang:binary_to_atom(<<W/binary, Count/binary>>, latin1),


    ChildSpec =         % The list of child processes you should supervise
        {   
            Name,     % - Register it under the name hello_server
            {                 % - Here's how to find and start this child's code 
                workerInf,   %   * the module is called hello_server
                start_link,     %   * the function to invoke is called start_link
                [Head]              %   * and here's the list of default parameters to use
            },                
                permanent,        % - child should run permantenly, restart on crash 
                2000,             % - give child 2 sec to clean up on system stop, then kill 
                worker,           % - FYI, this child is a worker, not a supervisor
                [workerInf]    % - these are the modules the process uses  
            }
        ,
    supervisor:start_child(ger_service_sup_worker,ChildSpec),
    findWorker(Tail, Counter + 1).



%% ------------------------------------------------------------------
%% gen_server Function Definitions
%% ------------------------------------------------------------------

init(Args) ->


        inets:start(),
   	add_logg(<<"Start aceptor ">>),
		add_logg(erlang:list_to_binary(erlang:pid_to_list(self()))),

        {ok, Host} = application:get_env(ger_service, host),
        {ok, Port} = application:get_env(ger_service, port),

        %timer:send_after(1000, ?MODULE, connect),

    {ok, #state{host = Host, port = Port}}.


handle_call(state, _, State) ->
    {reply, State, State};


handle_call(_Request, _From, State) ->
	
	case _Request of 
		addwork -> 
		[_ |  BuffWorker] = lists:reverse(State),
		[Worker] = BuffWorker,
		findWorker(Worker,0);
		show -> io:format("~p~n", [State]);

		_ -> io:format("Unknown Command\n")
    end,


    {reply, ok, State}.

handle_cast(_Msg, State) ->

	case _Msg of


		socket -> 
		Port = 5678,
		add_logg(<<"Open From port: ">>),
		add_logg(erlang:integer_to_binary(Port)),
	
  	case gen_tcp:listen(Port, [{packet, raw}, {active, false},{reuseaddr, true}]) of
        {ok,LSock}  ->
	        {ok, Sock} = gen_tcp:accept(LSock),
		    {ok, Bin} = do_recv(Sock, []),

			ok = gen_tcp:close(Sock),
		    ok = gen_tcp:close(LSock),

			add_logg(erlang:list_to_binary(Bin)),

			add_logg(<<"Closed  port: ">>),
			add_logg(erlang:integer_to_binary(Port)),

		    {noreply, [Bin | State]};

        {error,eaddrinuse} -> io:format("error eaddrinuse in listen ~n"),
    	{noreply, State}
    end;
    	exchange ->
    		{noreply, State};
 	
    	_ -> io:format("Unknown Command\n"),
    	{noreply, State}
    end.




handle_info({send, Msg}, #state{host = Host, port = Port} = State) ->
   
    {ok, Socket} = gen_tcp:connect(Host, Port, [binary, {active, true}, {packet, raw}]),

    io:format("HELL\n"),

    ssl:start(),    

    %inet:setopts(Socket, [{active, false}]),
    {ok, SSlSocket, _} = ssl:connect(Socket, [{handshake, hello}], infinity),
    ssl:handshake_continue(SSlSocket, []),
    io:format("~p\n", [SSlSocket]),
    io:format("HELLSS\n"),


    Rez = ssl:send(SSlSocket, Msg),


    receive_data(SSlSocket, []),


    io:format("HELLSSSSSSSS\n"),

   %Rez = ssl:connect(Socket, [{handshake, hello}]),

    %ssl:handshake_continue(SSlSocket, []),

    %Rez = ssl:send(SSlSocket, Msg),


    io:format("Sending ~p~n", [Rez]),


    {noreply, State#state{tcp_socket = []}};



handle_info({tcp,Socket,Msg}, #state{tcp_socket = Socket} = State) ->

    io:format("Packets ~p~n", [Msg]),


    {noreply, State};

handle_info({tcp_closed, Socket}, #state{tcp_socket = Socket} = State) ->


    
    io:format("Closed ~p~n", [Socket]),
    %%timer:send_after(5000, ?MODULE, connect),

    {noreply, State#state{tcp_socket = ""}};

handle_info(_Info, State) ->

    io:format("This info - ~p~n", [_Info]),

    {noreply, State}.



terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% ------------------------------------------------------------------
%% Internal Function Definitions
%% ------------------------------------------------------------------

%   <<"HTTP/1.1 503 Service Temporarily Unavailable\r\nDate: 
%Fri, 31 Aug 2018 09:23:53 GMT\r\nContent-Type: 
%text/html; charset=UTF-8\r\nTransfer-Encoding: 
%chunked\r\nConnection: close\r\nX-Frame-Options: SAMEORIGIN\r\n
%et-Cookie: __cfduid=d0f1f090891c39b3e6bafd789b7cd842e1535707433; expires=
%Sat, 31-Aug-19 09:23:53 GMT; path=/; domain=.favbet.com; HttpOnly\r\n
%Cache-Control: no-cache\r\nStrict-Transport-Security: max-age=15552000; includeSubDomains; preload\r\
%nX-Content-Type-Options: nosniff\r\nExpect-CT: max-age=604800,
% report-uri=\"https://report-uri.cloudflare.com/cdn-cgi/beacon/expect-ct\"\r\n
%Vary: Accept-Encoding\r\nServer: cloudflare\r\nCF-RAY: 452e70e329b48ac8-KBP\r\n
% \r\n1b08\r\n<!DOCTYPE HTML>\n<html lang=\"en-US\">\n<head>\n  <meta charset=\"UTF-8\" />\n  
%<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />\n 
%  <meta http-equiv=\"X-UA-Compatible\" content=\"IE=Edge,chrome=1\" />\n  
% <meta name=\"robots\" content=\"noindex, nofollow\" />\n  
%  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1, maximum-scale=1\" />\n  
%  <title>Just a moment...</title>\n  <style type=\"text/css\">\n  
%    html, body {width: 100%; height: 100%; margin: 0; padding: 0;}\n   
%     body {background-color: #ffffff; font-family: Helvetica, Arial, sans-serif; font-size: 100%;}\n   
%      h1 {font-size: 1.5em; color: #404040; text-align: center;}\n    
%p {font-size: 1em; color: #404040; text-align: center; margin: 10px 0 0 0">>


receive_data(Socket, SoFar) ->
io:format("Wait Recive\n"),
    receive
    {tcp,Socket,Bin} ->    %% (3)
      io:format("~p~n", [Bin]);
      {tcp_closed,Socket} -> %% (4)
        list_to_binary(lists:reverse(SoFar));
       Total -> io:format("~p~n", [Total])   %% (5)
    end.