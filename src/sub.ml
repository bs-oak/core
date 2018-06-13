type 'a t

external batch: 'a t list -> 'a t = "batch" 
[@@bs.module "./js/platform"]

external none: 'a t = "none" 
[@@bs.module "./js/platform"]

external map: ('a -> 'b) -> 'a t -> 'b t = "map"
[@@bs.module "./js/platform"]