external program : 
  flags: 'flags ->
  init: ('flags -> 'model * 'msg Cmd.t) ->
  update: ('msg -> 'model -> 'model * 'msg Cmd.t ) ->
  subscriptions: ('model -> 'msg Sub.t) ->
  stepper_builder: (('msg -> unit) -> 'model -> ('model -> unit)) ->
  unit = "initialize"
  [@@bs.module "@bs-oak/core/src/js/platform"]