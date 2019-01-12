type ('a, 'x) task

type process_id

(* program *)

type 'flags config =
  { flags: 'flags } 
  [@@bs.deriving abstract]  

type ('flags, 'model, 'msg) program = ('flags config -> unit)

let worker ~init ~update ~subscriptions = fun cfg ->
  let stepper _model = () in
  let stepper_builder _send_to_app _model = stepper in
  Internal.program 
    ~flags: (flagsGet cfg)
    ~init: init
    ~update: update
    ~subscriptions: subscriptions
    ~stepper_builder: stepper_builder