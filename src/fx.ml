type ('a, 'b) router

external send_to_app: ('a, 'b) router -> 'a -> (unit, 'x) Platform.task = "sendToApp"
[@@bs.module "./js/platform"]  

external send_to_self: ('a, 'b) router -> 'b -> (unit, 'x) Platform.task = "sendToSelf"
[@@bs.module "./js/platform"]

type ctx

external ctx: unit -> ctx = "newEffectManagerCtx"
[@@bs.module "./js/platform"]

external command: ctx -> 'a -> 'b Cmd.t = "leaf"
[@@bs.module "./js/platform"]

external subscription: ctx -> 'a -> 'b Sub.t = "leaf"
[@@bs.module "./js/platform"]

external manager:
  ctx: ctx -> 
  init: ('state, unit) Platform.task ->
  on_effects: (('app_msg, 'self_msg) router -> 'cmd_msg list -> 'sub_msg list -> 'state -> ('state, unit) Platform.task) ->
  on_self_msg: (('app_msg, 'self_msg) router -> 'self_msg -> 'state -> ('state, unit) Platform.task) ->
  cmd_map: (('a -> 'b) -> 'cmd_msg -> 'cmd_msg) ->
  sub_map: (('a -> 'b) -> 'sub_msg -> 'sub_msg) ->
  unit = "registerEffectManager"
[@@bs.module "./js/platform"]  

external cmd_manager:
  ctx: ctx -> 
  init: ('state, unit) Platform.task ->
  on_effects: (('app_msg, 'self_msg) router -> 'cmd_msg list -> 'state -> ('state, unit) Platform.task) ->
  on_self_msg: (('app_msg, 'self_msg) router -> 'self_msg -> 'state -> ('state, unit) Platform.task) ->
  cmd_map: (('a -> 'b) -> 'cmd_msg -> 'cmd_msg) ->
  unit = "registerCommandManager"
[@@bs.module "./js/platform"]  

external sub_manager:
  ctx: ctx -> 
  init: ('state, unit) Platform.task ->
  on_effects: (('app_msg, 'self_msg) router -> 'sub_msg list -> 'state -> ('state, unit) Platform.task) ->
  on_self_msg: (('app_msg, 'self_msg) router -> 'self_msg -> 'state -> ('state, unit) Platform.task) ->
  sub_map: (('a -> 'b) -> 'sub_msg -> 'sub_msg) ->
  unit = "registerSubscriptionManager"
[@@bs.module "./js/platform"]

module Scheduler = Fx_scheduler