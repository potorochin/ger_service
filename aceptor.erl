-module(aceptor).
-behaviour(gen_server).
-define(SERVER, ?MODULE).

%% ------------------------------------------------------------------
%% API Function Exports
%% ------------------------------------------------------------------

-export([start_link/1]).
-export([open_socket/1, get_inf/1, addChild/1, pars_exchange/1]).

%% ------------------------------------------------------------------
%% gen_server Function Exports
%% ------------------------------------------------------------------

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

%% ------------------------------------------------------------------
%% API Function Definitions
%% ------------------------------------------------------------------

start_link(Port) ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [Port], []).


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

   	add_logg(<<"Start aceptor ">>),
		add_logg(erlang:list_to_binary(erlang:pid_to_list(self()))),

    {ok, Args}.



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
		[Port |  _] = lists:reverse(State),
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

    	%% 497c25ee-f785-4cd5-a5e4-ab9e470b2760
    	%% /v1/cryptocurrency/info
    	%% https://pro-api.coinmarketcap.com


    	%% Get Request To Server
    		inets:start(),
    		ssl:start(),
    		Rez = httpc:request(get, {"https://pro-api.coinmarketcap.com/v1/cryptocurrency/info", []}, 
    	[{timeout, timer:seconds(5)}], []),


    		io:format("~p~n", [Rez]),
    		
    		inets:stop(),
    		ssl:stop(),
    		{noreply, State};
 	
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

