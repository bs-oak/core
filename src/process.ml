type id = Platform.process_id

external spawn: ('a,'x) Platform.task -> (id,'x) Platform.task = "spawn"
[@@bs.module "./js/scheduler"]

external kill: id -> (unit,'x) Platform.task = "kill" 
[@@bs.module "./js/scheduler"]