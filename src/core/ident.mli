(********************************************************************)
(*                                                                  *)
(*  The Why3 Verification Platform   /   The Why3 Development Team  *)
(*  Copyright 2010-2014   --   INRIA - CNRS - Paris-Sud University  *)
(*                                                                  *)
(*  This software is distributed under the terms of the GNU Lesser  *)
(*  General Public License version 2.1, with the special exception  *)
(*  on linking described in file LICENSE.                           *)
(*                                                                  *)
(********************************************************************)

(** Identifiers *)

(** {2 Labels} *)

type label = private {
  lab_string : string;
  lab_tag    : int;
}

module Mlab : Extmap.S with type key = label
module Slab : Extset.S with module M = Mlab

val lab_compare : label -> label -> int
val lab_equal : label -> label -> bool
val lab_hash : label -> int

val create_label : string -> label

(** {2 Identifiers} *)

type ident = private {
  id_string : string;               (* non-unique name *)
  id_label  : Slab.t;               (* identifier labels *)
  id_loc    : Loc.position option;  (* optional location *)
  id_tag    : Weakhtbl.tag;         (* unique magical tag *)
}

module Mid : Extmap.S with type key = ident
module Sid : Extset.S with module M = Mid
module Hid : Exthtbl.S with type key = ident
module Wid : Weakhtbl.S with type key = ident

val id_compare : ident -> ident -> int
val id_equal : ident -> ident -> bool
val id_hash : ident -> int

(* a user-created type of unregistered identifiers *)
type preid = {
  pre_name  : string;
  pre_label : Slab.t;
  pre_loc   : Loc.position option;
}

(* register a pre-ident (you should never use this function) *)
val id_register : preid -> ident

(* create a fresh pre-ident *)
val id_fresh : ?label:Slab.t -> ?loc:Loc.position -> string -> preid

(* create a localized pre-ident *)
val id_user : ?label:Slab.t -> string -> Loc.position -> preid

(* create a duplicate pre-ident *)
val id_clone : ?label:Slab.t -> ident -> preid

(* create a derived pre-ident (inherit labels and location) *)
val id_derive : ?label:Slab.t -> string -> ident -> preid

(* DEPRECATED : retrieve preid name without registering *)
val preid_name : preid -> string

(** Unique persistent names for pretty printing *)

type ident_printer

val create_ident_printer :
  ?sanitizer : (string -> string) -> string list -> ident_printer
(** start a new printer with a sanitizing function and a blacklist *)

val id_unique :
  ident_printer -> ?sanitizer : (string -> string) -> ident -> string
(** use ident_printer to generate a unique name for ident
    an optional sanitizer is applied over the printer's sanitizer *)

val string_unique : ident_printer -> string -> string
(** Uniquify string *)

val forget_id : ident_printer -> ident -> unit
(** forget an ident *)

val forget_all : ident_printer -> unit
(** forget all idents *)

val sanitizer : (char -> string) -> (char -> string) -> string -> string
(** generic sanitizer taking a separate encoder for the first letter *)

(** various character encoders *)

val char_to_alpha : char -> string
val char_to_lalpha : char -> string
val char_to_ualpha : char -> string
val char_to_alnum : char -> string
val char_to_lalnum : char -> string
val char_to_alnumus : char -> string
val char_to_lalnumus : char -> string

