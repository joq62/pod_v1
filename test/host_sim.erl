%%% -------------------------------------------------------------------
%%% @author  : Joq Erlang
%%% @doc: : 
%%% Created :
%%% Node end point  
%%% Creates and deletes Pods
%%% 
%%% API-kube: Interface 
%%% Pod consits beams from all services, app and app and sup erl.
%%% The setup of envs is
%%% -------------------------------------------------------------------
-module(host_sim).   
 
-export([start/0]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").
-include_lib("kernel/include/logger.hrl").
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start()->
    os:cmd("rm -rf *.pod_dir"),
    UniqueNodeName=integer_to_list(erlang:system_time(microsecond),36),
    PodDir=UniqueNodeName++".pod_dir",
    ok=file:make_dir(PodDir),
    {ok,Vm}=lib_vm:create(UniqueNodeName),
    true=rpc:call(Vm,code,add_patha,["ebin"],5000),
    ok=rpc:call(Vm,application,set_env,[[{pod,[{pod_dir,PodDir}]}]],5000),
    ok=rpc:call(Vm,application,start,[pod],5000),
    pong=rpc:call(Vm,pod_server,ping,[],5000),
    
    {ok,Vm,PodDir}.


