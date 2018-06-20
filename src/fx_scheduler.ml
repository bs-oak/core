(* tasks *)

type ('a, 'x) task = ('a, 'x) Platform.task

external succeed: 'a -> ('a, _) task = "succeed"
[@@bs.module "@bs-oak/core/src/js/scheduler"]

external fail: 'x -> (_, 'x) task = "fail"
[@@bs.module "@bs-oak/core/src/js/scheduler"]

external binding: ((('a,'x) task -> unit) -> (unit -> unit)) -> ('a, 'x) task = "bind"
[@@bs.module "@bs-oak/core/src/js/scheduler"]

external and_then: ('a -> ('b,'x) task) -> ('a,'x) task -> ('b,'x) task = "andThen"
[@@bs.module "@bs-oak/core/src/js/scheduler"]

external on_error: ('x -> ('a,'y) task) -> ('a,'x) task -> ('a,'y) task = "onError"
[@@bs.module "@bs-oak/core/src/js/scheduler"]

external receive: ('a -> ('b, 'x) task) -> ('b, 'x) task = "receive"
[@@bs.module "@bs-oak/core/src/js/scheduler"]

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
  t |> on_error (fun x -> fail (fn x))

(* processes *)

type process_id = Platform.process_id

external raw_spawn:  ('a, 'x) task -> process_id = "rawSpawn"
[@@bs.module "@bs-oak/core/src/js/scheduler"]

external spawn: ('a,'x) task -> (process_id,'x) task = "spawn"
[@@bs.module "@bs-oak/core/src/js/scheduler"]

external raw_send: process_id -> 'msg -> unit = "rawSend"
[@@bs.module "@bs-oak/core/src/js/scheduler"]

external send: process_id -> 'msg -> (unit,'x) task = "send"
[@@bs.module "@bs-oak/core/src/js/scheduler"]

external kill: process_id -> (unit,'x) task = "kill" 
[@@bs.module "@bs-oak/core/src/js/scheduler"]