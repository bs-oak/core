(* tasks *)

type ('a, 'x) task = ('a, 'x) Platform.task

external succeed: 'a -> ('a, _) task = "succeed"
[@@bs.module "./js/scheduler"]

external fail: 'x -> (_, 'x) task = "fail"
[@@bs.module "./js/scheduler"]

external binding: ((('a,'x) task -> unit) -> (unit -> unit)) -> ('a, 'x) task = "bind"
[@@bs.module "./js/scheduler"]

external and_then: ('a -> ('b,'x) task) -> ('a,'x) task -> ('b,'x) task = "andThen"
[@@bs.module "./js/scheduler"]

external on_error: ('x -> ('a,'y) task) -> ('a,'x) task -> ('a,'y) task = "onError"
[@@bs.module "./js/scheduler"]

external receive: ('a -> ('b, 'x) task) -> ('b, 'x) task = "receive"
[@@bs.module "./js/scheduler"]

(* processes *)

type process_id = Platform.process_id

external raw_spawn:  ('a, 'x) task -> process_id = "rawSpawn"
[@@bs.module "./js/scheduler"]

external spawn: ('a,'x) task -> (process_id,'x) task = "spawn"
[@@bs.module "./js/scheduler"]

external raw_send: process_id -> 'msg -> unit = "rawSend"
[@@bs.module "./js/scheduler"]

external send: process_id -> 'msg -> (unit,'x) task = "send"
[@@bs.module "./js/scheduler"]

external kill: process_id -> (unit,'x) task = "kill" 
[@@bs.module "./js/scheduler"]