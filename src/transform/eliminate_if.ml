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

open Ident
open Term
open Decl

(** Eliminate if-then-else in terms *)

let rec has_if t = match t.t_node with
  | Tif _ -> true
  | _ -> TermTF.t_any has_if Util.ffalse t

let rec elim_t contT t =
  let contTl e = contT (t_label_copy t e) in
  match t.t_node with
  | Tlet (t1,tb) ->
      let u,t2,close = t_open_bound_cb tb in
      let cont_in t1 t2 = contTl (t_let t1 (close u t2)) in
      let cont_let_t t1 = elim_t (cont_in t1) t2 in
      let cont_let_f t1 = t_let_close u t1 (elim_t contT t2) in
      elim_t (if has_if t2 then cont_let_f else cont_let_t) t1
  | Tif (f,t1,t2) ->
      let f = elim_f (fun f -> f) f in
      t_if f (elim_t contT t1) (elim_t contT t2)
  | Tcase (t1, bl) ->
      let bl = List.rev_map t_open_branch_cb bl in
      let fi = List.exists (fun (_,t,_) -> has_if t) bl in
      let fnB ctB (p,t,cl) = elim_t (fun t -> ctB (cl p t)) t in
      let cont_with t1 bl = contTl (t_case t1 (List.rev bl)) in
      let cont_case_t t1 = list_map_cont fnB (cont_with t1) bl in
      let close (p,t,_) = t_close_branch p (elim_t contT t) in
      let cont_case_f t1 = t_case t1 (List.rev_map close bl) in
      elim_t (if fi then cont_case_f else cont_case_t) t1
  | _ ->
      TermTF.t_map_cont elim_t elim_f contT t

and elim_f contF f = match f.t_node with
  | Tapp _ | Tlet _ | Tcase _ ->
      contF (TermTF.t_map_cont elim_t elim_f (fun f -> f) f)
  | _ -> TermTF.t_map_cont elim_tr elim_f contF f

(* the only terms we still can meet are the terms in triggers *)
and elim_tr contT t = match t.t_node with
  | Tif _ ->
      Printer.unsupportedTerm t
        "cannot eliminate 'if-then-else' in trigger terms"
  | _ -> TermTF.t_map_cont elim_tr elim_f contT t

let elim_f f = elim_f (fun f -> f) f

let rec elim_t t = TermTF.t_map elim_t elim_f t

let add_ld (ls,ld) (abst,defn,axl) =
  let vl,e,close = open_ls_defn_cb ld in
  match e.t_ty with
    | Some _ when has_if e ->
        let nm = ls.ls_name.id_string ^ "_def" in
        let pr = create_prsymbol (id_derive nm ls.ls_name) in
        let hd = t_app ls (List.map t_var vl) e.t_ty in
        let ax = t_forall_close vl [] (elim_f (t_equ hd e)) in
        let ax = create_prop_decl Paxiom pr ax in
        let ld = create_param_decl ls in
        ld :: abst, defn, ax :: axl
    | _ ->
        let d = close ls vl (TermTF.t_select elim_t elim_f e) in
        abst, d :: defn, axl

let elim_d d = match d.d_node with
  | Dlogic l ->
      let abst,defn,axl = List.fold_right add_ld l ([],[],[]) in
      let defn = if defn = [] then [] else [create_logic_decl defn] in
      abst @ defn @ axl
  | _ ->
      [DeclTF.decl_map (fun _ -> assert false) elim_f d]

let eliminate_if_term = Trans.decl elim_d None

(** Eliminate if-then-else in formulas *)

let rec elim_t t = TermTF.t_map elim_t (elim_f true) t

and elim_f sign f = match f.t_node with
  | Tif (f1,f2,f3) ->
      let f1p = elim_f sign f1 in
      let f1n = elim_f (not sign) f1 in
      let f2 = elim_f sign f2 in
      let f3 = elim_f sign f3 in
      if sign then t_and (t_implies f1n f2) (t_implies (t_not f1p) f3)
              else t_or (t_and f1p f2) (t_and (t_not f1n) f3)
  | _ ->
      TermTF.t_map_sign (Util.const elim_t) elim_f sign f

let eliminate_if_fmla = Trans.rewriteTF elim_t (elim_f true) None

let eliminate_if = Trans.compose eliminate_if_term eliminate_if_fmla

let () =
  Trans.register_transform "eliminate_if_term" eliminate_if_term
    ~desc:"Replaces@ terms@ of@ the@ form@ [if f1 then t2 else t3]@ by@ \
           lifting@ them@ at@ the@ level@ of@ formulas.";
  Trans.register_transform "eliminate_if_fmla" eliminate_if_fmla
    ~desc:"Eliminate@ formulas@ of@ the@ form@ [if f1 then f2 else f3].";
  Trans.register_transform "eliminate_if" eliminate_if
    ~desc:"Eliminate@ all@ if-expressions."
