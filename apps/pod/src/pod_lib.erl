%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(pod_lib).  
    
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
%-include("log.hrl").
%%---------------------------------------------------------------------
%% Records for test
%%

%% --------------------------------------------------------------------
%-compile(export_all).
-export([
	 load_start/3,
	 stop_unload/2
	]).
	 

%% ====================================================================
%% External functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
load_start(ApplId,ApplVsn,PodDir)->
    Reply=case [{Application, Description, Vsn}||{Application, Description, Vsn}<-application:which_applications(),
						 Application=:=list_to_atom(ApplId)] of
	      [{_Application, _Description, _Vsn}]->	      
		  nodelog_server:log(warning,?MODULE_STRING,?LINE,{"Application already  started/running ",{error,[already_running,ApplId]}}),
		  {error,[already_running,ApplId]};
	      []->
		  case config:application_gitpath(ApplId) of
		      {error,Err}->
			  nodelog_server:log(warning,?MODULE_STRING,?LINE,{"Error when geting gitpath to application ",ApplId,' ', {error,Err}}),
			  {error,Err};
		      {ok,GitPath}->
			  case rpc:call(node(),infra_lib,git_load,[ApplId,ApplVsn,GitPath,PodDir],20*5000) of
			      {error,Reason}->
				  nodelog_server:log(warning,?MODULE_STRING,?LINE,{"Error when loading service ",ApplId,' ', {error,Reason}}),
				  {error,Reason};
			      {ok,ApplDir} ->
				  ApplEbin=filename:join(ApplDir,"ebin"),
				  case code:add_patha(ApplEbin) of
				      {error,Reason}->
					  {error,Reason};
				      true->
					  nodelog_server:log(notice,?MODULE_STRING,?LINE,{"Application  succesfully loaded ",ApplId,' ',ApplVsn}),
					  case rpc:call(node(),application,start,[list_to_atom(ApplId)],20*5000) of
					      ok->
						  nodelog_server:log(notice,?MODULE_STRING,?LINE,{"Application  succesfully started ",ApplId,' ',ApplVsn}),
						  {ok,ApplDir};
					      Error ->
						  nodelog_server:log(notice,?MODULE_STRING,?LINE,{"Error when starting application ",ApplId,' ',Error}),
						  Error					      
					  end
				  end	
			  end	  
		  end
	  end,
    Reply.





%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------	       

stop_unload(ApplId,ApplDir)->
    Appl=list_to_atom(ApplId),
    rpc:call(node(),application,stop,[Appl]),
    rpc:call(node(),application,unload,[Appl]),
    os:cmd("rm -rf "++ApplDir),
    timer:sleep(500),
    ok.

