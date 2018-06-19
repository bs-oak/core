(* helpers *)

let (<<) f g x = f(g x)

(* task *)

type ('a, 'x) t = ('a, 'x) Fx.Scheduler.task

let succeed = Fx.Scheduler.succeed

let fail = Fx.Scheduler.fail

let and_then = Fx.Scheduler.and_then

let on_error = Fx.Scheduler.on_error

let map = Fx.Scheduler.map

let map2 = Fx.Scheduler.map2

let map3 = Fx.Scheduler.map3

let map4 = Fx.Scheduler.map4

let map5 = Fx.Scheduler.map5

let map6 = Fx.Scheduler.map6

let map7 = Fx.Scheduler.map7

let map8 = Fx.Scheduler.map8

let sequence = Fx.Scheduler.sequence

let map_error = Fx.Scheduler.map_error

(* Commands *)

let ctx = Fx.ctx ()

type 'a my_cmd =
  Perform of ('a, unit) t

let command value =
  Fx.command ctx value

let perform to_msg task =
  command (Perform (map to_msg task))

let attempt result_to_msg task =
  command (Perform (
    task
      |> and_then (succeed << result_to_msg << (fun a -> Belt.Result.Ok a))
      |> on_error (succeed << result_to_msg << (fun x -> Belt.Result.Error x))
  ))

let cmd_map tagger (Perform task) =
  Perform (map tagger task)

(* Manager *)

let init =
  succeed ()

let on_effects router cmds _state =
  let spawn_cmd (Perform task) =
      task
      |> and_then (Fx.send_to_app router)
      |> Fx.Scheduler.spawn
  in
  map (fun _ -> ()) (sequence (List.map spawn_cmd cmds))

let on_self_message _router _msg _state =
  succeed ()

let () = 
  Fx.cmd_manager
  ~ctx: ctx
  ~init: init
  ~on_effects: on_effects
  ~on_self_msg: on_self_message
  ~cmd_map: cmd_map