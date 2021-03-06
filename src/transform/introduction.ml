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

(*
  This module was poorly designed by Claude Marché, with the
  enormous help of Jean-Christophe Filliâtre and Andrei Paskevich
  for finding the right function in the Why3 API
*)

open Ident
open Ty
open Term
open Decl

let rec intros pr f = match f.t_node with
  | Tbinop (Timplies,f1,f2) ->
      (* split f1 *)
      let l = Split_goal.split_pos_intro f1 in
      List.fold_right
        (fun f acc ->
           let id = create_prsymbol (id_fresh "H") in
           let d = create_prop_decl Paxiom id f in
           d :: acc)
        l
        (intros pr f2)
  | Tquant (Tforall,fq) ->
      let vsl,_trl,f = t_open_quant fq in
      let intro_var subst vs =
        let ls = create_lsymbol (id_clone vs.vs_name) [] (Some vs.vs_ty) in
        Mvs.add vs (fs_app ls [] vs.vs_ty) subst,
        create_param_decl ls
      in
      let subst, dl = Lists.map_fold_left intro_var Mvs.empty vsl in
      let f = t_subst subst f in
      dl @ intros pr f
  | Tlet (t,fb) ->
      let vs,f = t_open_bound fb in
      let ls = create_lsymbol (id_clone vs.vs_name) [] (Some vs.vs_ty) in
      let f = t_subst_single vs (fs_app ls [] vs.vs_ty) f in
      let d = create_logic_decl [make_ls_defn ls [] t] in
      d :: intros pr f
  | _ -> [create_prop_decl Pgoal pr f]

let intros pr f =
  let tvs = t_ty_freevars Stv.empty f in
  let mk_ts tv () = create_tysymbol (id_clone tv.tv_name) [] None in
  let tvm = Mtv.mapi mk_ts tvs in
  let decls = Mtv.map create_ty_decl tvm in
  let subst = Mtv.map (fun ts -> ty_app ts []) tvm in
  Mtv.values decls @ intros pr (t_ty_subst subst Mvs.empty f)

let () = Trans.register_transform "introduce_premises" (Trans.goal intros)
  ~desc:"Introduce@ universal@ quantification@ and@ hypothesis@ in@ the@ \
         goal@ into@ constant@ symbol@ and@ axioms."

(*
Local Variables:
compile-command: "unset LANG; make -C ../.. byte"
End:
*)
