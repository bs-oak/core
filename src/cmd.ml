type 'a t

external batch: 'a t list -> 'a t = "batch" 
[@@bs.module "@bs-oak/core/src/js/platform"]

external none: 'a t = "none" 
[@@bs.module "@bs-oak/core/src/js/platform"]

external map: ('a -> 'b) -> 'a t -> 'b t = "map"
[@@bs.module "@bs-oak/core/src/js/platform"]