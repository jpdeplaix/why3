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

module Make (X:Util.Sstruct) :
sig

  type 'a t

  val create : int -> 'a t
    (* create a hashtbl with weak key*)

  val find : 'a t -> X.t -> 'a
    (* find the value binded to a key.
       raise Not_found if there is no binding *)

  val add : 'a t -> X.t -> 'a -> unit
    (* bind the key with the value given.
       It replace previous binding *)
end
