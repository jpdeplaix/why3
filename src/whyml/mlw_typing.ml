(**************************************************************************)
(*                                                                        *)
(*  Copyright (C) 2010-2011                                               *)
(*    François Bobot                                                      *)
(*    Jean-Christophe Filliâtre                                           *)
(*    Claude Marché                                                       *)
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

open Why3
open Util
open Ident
open Theory
open Env
open Ptree
open Mlw_module

type mlw_contents = modul Mstr.t
type mlw_library = mlw_contents library
type mlw_file = mlw_contents * Theory.theory Mstr.t

(* TODO: let type_only = Debug.test_flag Typing.debug_type_only in *)

let find_theory loc lib path s =
  (* search first in .mlw files (using lib) *)
  let thm =
    try Some (Env.read_lib_theory lib path s)
    with LibFileNotFound _ | TheoryNotFound _ -> None
  in
  (* search also in .why files *)
  let th =
    try Some (Env.find_theory (Env.env_of_library lib) path s)
    with LibFileNotFound _ | TheoryNotFound _ -> None
  in
  match thm, th with
    | Some _, Some _ ->
        Loc.errorm ~loc
          "a module/theory %s is defined both in Why and WhyML libraries" s
    | None, None -> Loc.error ~loc (Env.TheoryNotFound (path, s))
    | None, Some t | Some t, None -> t

let find_theory loc lib mt path s = match path with
  | [] -> (* local theory *)
      begin try Mstr.find s mt with Not_found -> find_theory loc lib [] s end
  | _ :: _ -> (* theory in file path *)
      find_theory loc lib path s

type theory_or_module = Theory of Theory.theory | Module of modul

let print_path fmt sl =
  Pp.print_list (Pp.constant_string ".") Format.pp_print_string fmt sl

let find_module loc lib path s =
  (* search first in .mlw files *)
  let m, thm =
    try
      let mm, mt = Env.read_lib_file lib path in
      Mstr.find_opt s mm, Mstr.find_opt s mt
    with
      | LibFileNotFound _ -> None, None
  in
  (* search also in .why files *)
  let th =
    try Some (Env.find_theory (Env.env_of_library lib) path s)
    with LibFileNotFound _ | TheoryNotFound _ -> None
  in
  match m, thm, th with
    | Some _, None, _ -> assert false
    | _, Some _, Some _ ->
        Loc.errorm ~loc
          "a module/theory %s is defined both in Why and WhyML libraries" s
    | None, None, None ->
        Loc.errorm ~loc "Theory/module not found: %a" print_path (path @ [s])
    | Some m, Some _, None -> Module m
    | None, Some t, None | None, None, Some t -> Theory t

let find_module loc lib mm mt path s = match path with
  | [] -> (* local module/theory *)
      begin try Module (Mstr.find s mm)
        with Not_found -> begin try Theory (Mstr.find s mt)
          with Not_found -> find_module loc lib [] s end end
  | _ :: _ -> (* module/theory in file path *)
      find_module loc lib path s

let add_theory lib path mt m =
  let { id = id; id_loc = loc } = m.pth_name in
  if Mstr.mem id mt then Loc.errorm ~loc "clash with previous theory %s" id;
  let uc = Theory.create_theory ~path (Denv.create_user_id m.pth_name) in
  let rec add_decl uc = function
    | Duseclone (loc, use, inst) ->
        let path, s = Typing.split_qualid use.use_theory in
        let th = find_theory loc lib mt path s in
        (* open namespace, if any *)
        let uc =
          if use.use_imp_exp <> None then Theory.open_namespace uc else uc in
        (* use or clone *)
        let uc = match inst with
          | None -> Theory.use_export uc th
          | Some inst ->
              let inst = Typing.type_inst uc th inst in
              Theory.clone_export uc th inst
        in
        (* close namespace, if any *)
        begin match use.use_imp_exp with
          | None -> uc
          | Some imp -> Theory.close_namespace uc imp use.use_as
        end
    | Dlogic d ->
        Typing.add_decl uc d
    | Dnamespace (loc, name, import, dl) ->
        let uc = Theory.open_namespace uc in
        let uc = List.fold_left add_decl uc dl in
        Loc.try3 loc Theory.close_namespace uc import name
    | Dlet _ | Dletrec _ | Dparam _ | Dexn _ | Duse _ ->
        assert false
  in
  let uc = List.fold_left add_decl uc m.pth_decl in
  let th = Theory.close_theory uc in
  Mstr.add id th mt

let add_module lib path mm mt m =
  let { id = id; id_loc = loc } = m.mod_name in
  if Mstr.mem id mm then Loc.errorm ~loc "clash with previous module %s" id;
  if Mstr.mem id mt then Loc.errorm ~loc "clash with previous theory %s" id;
  let uc = create_module ~path (Denv.create_user_id m.mod_name) in
  let rec add_decl uc = function
    | Duseclone (loc, use, inst) ->
        let path, s = Typing.split_qualid use.use_theory in
        let mth = find_module loc lib mm mt path s in
        (* open namespace, if any *)
        let uc = if use.use_imp_exp <> None then open_namespace uc else uc in
        (* use or clone *)
        let uc = match mth, inst with
          | Theory th, None -> use_export_theory uc th
          | Theory th, Some inst ->
              let inst = Typing.type_inst (get_theory uc) th inst in
              clone_export_theory uc th inst
          | Module m, None -> use_export uc m
          | Module m, Some inst ->
              let inst = Typing.type_inst (get_theory uc) m.mod_theory inst in
              clone_export uc m inst
        in
        (* close namespace, if any *)
        begin match use.use_imp_exp with
          | None -> uc
          | Some imp -> close_namespace uc imp use.use_as
        end
    (* TODO: handle types differently *)
    | Dlogic d ->
        add_to_theory Typing.add_decl uc d
    | Dnamespace (loc, name, import, dl) ->
        let uc = open_namespace uc in
        let uc = List.fold_left add_decl uc dl in
        Loc.try3 loc close_namespace uc import name
    | Dlet _ | Dletrec _ | Dparam _ | Dexn _ | Duse _ ->
        assert false
  in
  let uc = List.fold_left add_decl uc m.mod_decl in
  let m = close_module uc in
  Mstr.add id m mm, Mstr.add id m.mod_theory mt

let add_theory_module lib path (mm, mt) = function
  | Ptheory th -> mm, add_theory lib path mt th
  | Pmodule m -> add_module lib path mm mt m
