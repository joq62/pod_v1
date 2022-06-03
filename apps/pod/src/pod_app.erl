%%%-------------------------------------------------------------------
%% @doc controller public API
%% @end
%%%-------------------------------------------------------------------

-module(pod_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    pod_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
