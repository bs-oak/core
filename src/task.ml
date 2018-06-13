open Basics

type ('a, 'x) t = ('a, 'x) Platform.task

external succeed: 'a -> ('a, _) t = "succeed"
[@@bs.module "./js/scheduler"]

external fail: 'x -> (_, 'x) t = "fail"
[@@bs.module "./js/scheduler"]

external and_then: ('a -> ('b,'x) t) -> ('a,'x) t -> ('b,'x) t = "andThen"
[@@bs.module "./js/scheduler"]

external on_error: ('x -> ('a,'y) t) -> ('a,'x) t -> ('a,'y) t = "onError"
[@@bs.module "./js/scheduler"]


let map fn t1 =
  t1
  |> and_then (fun a -> succeed (fn a) )

let map2 fn t1 t2 =
  t1
  |> and_then (fun r1 -> t2
  |> and_then (fun r2 -> succeed (fn r1 r2)))

let map3 fn t1 t2 t3 =
  t1
  |> and_then (fun r1 -> t2
  |> and_then (fun r2 -> t3
  |> and_then (fun r3 -> succeed (fn r1 r2 r3))))

let map4 fn t1 t2 t3 t4 =
  t1
  |> and_then (fun r1 -> t2
  |> and_then (fun r2 -> t3
  |> and_then (fun r3 -> t4
  |> and_then (fun r4 -> succeed (fn r1 r2 r3 r4)))))

let map5 fn t1 t2 t3 t4 t5 =
  t1
  |> and_then (fun r1 -> t2
  |> and_then (fun r2 -> t3
  |> and_then (fun r3 -> t4
  |> and_then (fun r4 -> t5
  |> and_then (fun r5 -> succeed (fn r1 r2 r3 r4 r5))))))

let map6 fn t1 t2 t3 t4 t5 t6 =
  t1
  |> and_then (fun r1 -> t2
  |> and_then (fun r2 -> t3
  |> and_then (fun r3 -> t4
  |> and_then (fun r4 -> t5
  |> and_then (fun r5 -> t6
  |> and_then (fun r6 -> succeed (fn r1 r2 r3 r4 r5 r6)))))))

let map7 fn t1 t2 t3 t4 t5 t6 t7 =
  t1
  |> and_then (fun r1 -> t2
  |> and_then (fun r2 -> t3
  |> and_then (fun r3 -> t4
  |> and_then (fun r4 -> t5
  |> and_then (fun r5 -> t6
  |> and_then (fun r6 -> t7
  |> and_then (fun r7 -> succeed (fn r1 r2 r3 r4 r5 r6 r7))))))))

let map8 fn t1 t2 t3 t4 t5 t6 t7 t8 =
  t1
  |> and_then (fun r1 -> t2
  |> and_then (fun r2 -> t3
  |> and_then (fun r3 -> t4
  |> and_then (fun r4 -> t5
  |> and_then (fun r5 -> t6
  |> and_then (fun r6 -> t7
  |> and_then (fun r7 -> t8
  |> and_then (fun r8 -> succeed (fn r1 r2 r3 r4 r5 r6 r7 r8)))))))))

let sequence ts =
  let cons a b = a :: b in
  List.fold_right (map2 cons) ts (succeed [])

let map_error fn t =
  t |> on_error (fn >> fail)

(* Commands *)

let ctx = Ext_fx.ctx ()

type 'a my_cmd =
  Perform of ('a, unit) t

let command value =
  Ext_fx.command ctx value

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
      |> and_then (Ext_fx.send_to_app router)
      |> Process.spawn
  in
  map (fun _ -> ()) (sequence (List.map spawn_cmd cmds))

let on_self_message _router _msg _state =
  succeed ()

let () = 
  Ext_fx.cmd_manager
  ~ctx: ctx
  ~init: init
  ~on_effects: on_effects
  ~on_self_msg: on_self_message
  ~cmd_map: cmd_map