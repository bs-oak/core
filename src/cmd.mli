type 'a t

val batch : 'a t list -> 'a t

val none : 'a t

val map : ('a -> 'b) -> 'a t -> 'b t