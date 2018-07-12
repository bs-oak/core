type 'a t

external batch': 'a t array -> 'a t = "batch" 
[@@bs.module "@bs-oak/core/src/js/platform"]

let batch list =
  batch' (Array.of_list list)

external none: 'a t = "none" 
[@@bs.module "@bs-oak/core/src/js/platform"]

external map: ('a -> 'b) -> 'a t -> 'b t = "map"
[@@bs.module "@bs-oak/core/src/js/platform"]