type ('a, 'x) t = ('a, 'x) Platform.task

val succeed : 'a -> ('a, 'x) t

val fail : 'x -> ('a, 'x) t

val map : ('a -> 'b) -> ('a, 'x) t -> ('b, 'x) t

val map2 : 
  ('a -> 'b -> 'c) -> 
  ('a, 'x) t -> 
  ('b, 'x) t ->
  ('c, 'x) t

val map3 : 
  ('a -> 'b -> 'c -> 'd) -> 
  ('a, 'x) t -> 
  ('b, 'x) t ->
  ('c, 'x) t ->
  ('d, 'x) t

val map4 : 
  ('a -> 'b -> 'c -> 'd -> 'e) -> 
  ('a, 'x) t -> 
  ('b, 'x) t ->
  ('c, 'x) t ->
  ('d, 'x) t ->
  ('e, 'x) t

val map5 : 
  ('a -> 'b -> 'c -> 'd -> 'e -> 'f) -> 
  ('a, 'x) t -> 
  ('b, 'x) t ->
  ('c, 'x) t ->
  ('d, 'x) t ->
  ('e, 'x) t ->
  ('f, 'x) t

val map6 : 
  ('a -> 'b -> 'c -> 'd -> 'e -> 'f -> 'g) -> 
  ('a, 'x) t -> 
  ('b, 'x) t ->
  ('c, 'x) t ->
  ('d, 'x) t ->
  ('e, 'x) t ->
  ('f, 'x) t ->
  ('g, 'x) t

val map7 : 
  ('a -> 'b -> 'c -> 'd -> 'e -> 'f -> 'g -> 'h) -> 
  ('a, 'x) t -> 
  ('b, 'x) t ->
  ('c, 'x) t ->
  ('d, 'x) t ->
  ('e, 'x) t ->
  ('f, 'x) t ->
  ('g, 'x) t ->  
  ('h, 'x) t

val map8 : 
  ('a -> 'b -> 'c -> 'd -> 'e -> 'f -> 'g -> 'h -> 'i) -> 
  ('a, 'x) t -> 
  ('b, 'x) t ->
  ('c, 'x) t ->
  ('d, 'x) t ->
  ('e, 'x) t ->
  ('f, 'x) t ->
  ('g, 'x) t ->  
  ('h, 'x) t ->  
  ('i, 'x) t

val and_then : ('a -> ('b, 'x) t) -> ('a, 'x) t -> ('b, 'x) t

val sequence : ('a, 'x) t list -> ('a list, 'x) t

val on_error : ('x -> ('a, 'y) t) -> ('a, 'x) t -> ('a, 'y) t

val map_error : ('x -> 'y) -> ('a, 'x) t -> ('a, 'y) t

val perform : ('a -> 'msg) -> ('a, unit) t -> 'msg Cmd.t

val attempt : (('a, 'x) Belt.Result.t -> 'msg) -> ('a, 'x) t -> 'msg Cmd.t