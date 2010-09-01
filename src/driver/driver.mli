(**************************************************************************)
(*                                                                        *)
(*  Copyright (C) 2010-                                                   *)
(*    Francois Bobot                                                      *)
(*    Jean-Christophe Filliatre                                           *)
(*    Johannes Kanig                                                      *)
(*    Andrei Paskevich                                                    *)
(*                                                                        *)
(*  This software is free software; you can redistribute it and/or        *)
(*  modify it under the terms of the GNU Library General Public           *)
(*  License version 2.1, with the special exception on linking            *)
(*  described in file LICENSE.                                            *)
(*                                                                        *)
(*  This software is distributed in the hope that it will be useful,      *)
(*  but WITHOUT ANY WARRANTY; without even the implied warranty of        *)
(*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                  *)
(*                                                                        *)
(**************************************************************************)

(** Manage Why drivers *)

(** {2 create a driver} *)

type driver

val load_driver : Env.env -> string -> driver
(** loads a driver from a file
    @param env TODO
    @param string driver file name
*)

(** {2 use a driver} *)

val file_of_task : driver -> string -> string -> Task.task -> string
(** [file_of_task d f th t] produces a filename
    for the prover of driver [d], for a task [t] generated from
    a goal in theory [th] of filename [f]
*)

val call_on_buffer :
  command    : string ->
  ?timelimit : int ->
  ?memlimit  : int ->
  driver -> Buffer.t -> unit -> Call_provers.prover_result

val print_task :
  ?old       : in_channel ->
  driver -> Format.formatter -> Task.task -> unit

val prove_task :
  command    : string ->
  ?timelimit : int ->
  ?memlimit  : int ->
  ?old       : in_channel ->
  driver -> Task.task -> (unit -> Call_provers.prover_result)

