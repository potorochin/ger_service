-module(ger_service_sup).

-behaviour(supervisor).

%% API
-export([start_link/1]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================


start_link(Port) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, [Port]).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([Port]) ->

	SupSpec =  {          % Global supervisor options
      one_for_one,        % - use the one-for-one restart strategy
      1000,               % - and allow a maximum of 1000 restarts
      3600                % - per hour for each child process
    },

    ChildSpec = [         % The list of child processes you should supervise
        {   
        	loger,     % - Register it under the name hello_server
	        {                 % - Here's how to find and start this child's code 
		        loger,   %   * the module is called hello_server
		        start_link,     %   * the function to invoke is called start_link
		        []              %   * and here's the list of default parameters to use
	        },                
		        permanent,        % - child should run permantenly, restart on crash 
		        2000,             % - give child 2 sec to clean up on system stop, then kill 
		        worker,           % - FYI, this child is a worker, not a supervisor
		        [loger]    % - these are the modules the process uses  
	      	},

	    {

	        ger_service_sup_worker,     % - Register it under the name hello_server
	        {                 % - Here's how to find and start this child's code 
		        ger_service_sup_worker,   %   * the module is called hello_server
		        start_link,     %   * the function to invoke is called start_link
		        []              %   * and here's the list of default parameters to use
	        },                
		        permanent,        % - child should run permantenly, restart on crash 
		        2000,             % - give child 2 sec to clean up on system stop, then kill 
		        supervisor,           % - FYI, this child is a worker, not a supervisor
		        [ger_service_sup_worker]    % - these are the modules the process uses  
	      	},

      	{                 % We only have one
	        aceptor,     % - Register it under the name hello_server
	        {                 % - Here's how to find and start this child's code 
		        aceptor,   %   * the module is called hello_server
		        start_link,     %   * the function to invoke is called start_link
		        [Port]              %   * and here's the list of default parameters to use
		    },                
	        permanent,        % - child should run permantenly, restart on crash 
	        2000,             % - give child 2 sec to clean up on system stop, then kill 
	        worker,           % - FYI, this child is a worker, not a supervisor
	        [aceptor]    % - these are the modules the process uses  
     	}
    ], 

   {ok,  {  SupSpec ,       ChildSpec}}.          