type ('a, 'x) task

type process_id

type ('flags, 'model, 'msg) program

val worker : 
  init: ('flags -> 'model * 'msg Cmd.t) ->
  update: ('msg -> 'model -> 'model * 'msg Cmd.t ) ->
  subscriptions: ('model -> 'msg Sub.t) ->
  ('flags, 'model, 'msg) program