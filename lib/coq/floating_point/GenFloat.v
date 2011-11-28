(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import ZArith.
Require Import Rbase.
Require Import Rbasic_fun.
Require int.Int.
Require real.Real.
Require real.Abs.
Require real.FromInt.
Require floating_point.Rounding.

Require Import Fcore.
Require Import Fappli_IEEE.
Require Import int.Abs.

Section GenFloat.
Global Coercion B2R_coercion prec emax := @B2R prec emax.

Variable prec emax : Z.
Hypothesis Hprec : Zlt_bool 0 prec = true.
Hypothesis Hemax : Zlt_bool prec emax = true.
Let emin := (3 - emax - prec)%Z.
Let fexp := FLT_exp emin prec.
Lemma Hprec': (0 < prec)%Z. revert Hprec. now case Zlt_bool_spec. Qed.
Lemma Hemax': (prec < emax)%Z. revert Hemax. now case Zlt_bool_spec. Qed.
Let binary_round_correct := binary_round_sign_shl_correct prec emax Hprec' Hemax'.


Record t : Set := mk_fp {
  binary : binary_float prec emax;
  value := (binary : R);
  exact : R;
  model : R
}.


Record t_strict: Set := mk_fp_strict {
  datum :> t;
  finite : is_finite prec emax (binary datum) = true
}.

Import Rounding.
Definition rnd_of_mode (m:mode) :=
  match m with
  |  NearestTiesToEven => mode_NE
  |  ToZero            => mode_ZR
  |  Up                => mode_UP
  |  Down              => mode_DN
  |  NearestTiesToAway => mode_NA
  end.



Definition r_to_fp rnd x : binary_float prec emax :=
  let r := round radix2 fexp (round_mode rnd) x in
  let m := Ztrunc (scaled_mantissa radix2 fexp r) in
  let e := canonic_exponent radix2 fexp r in
  match m with
  | Z0 => B754_zero prec emax false
  | Zpos m => FF2B _ _ _ (proj1 (binary_round_correct rnd false m e))
  | Zneg m => FF2B _ _ _ (proj1 (binary_round_correct rnd true m e))
  end.

Lemma is_finite_FF2B :
  forall f H,
  is_finite prec emax (FF2B prec emax f H) =
    match f with
    | F754_finite _ _ _ => true
    | F754_zero _ => true
    | _ => false
    end.
Proof.
now intros [| | |].
Qed.

Theorem r_to_fp_correct :
  forall rnd x,
  let r := round radix2 fexp (round_mode rnd) x in
  (Rabs r < bpow radix2 emax)%R ->
  is_finite prec emax (r_to_fp rnd x) = true /\
  r_to_fp rnd x = r :>R.
Proof.
intros rnd x r Bx.
unfold r_to_fp. fold r.
assert (Gx: generic_format radix2 fexp r).
apply generic_format_round.
apply FLT_exp_correct.
exact Hprec'.
assert (Hr: Z2R (Ztrunc (scaled_mantissa radix2 fexp r)) = scaled_mantissa radix2 fexp r).
apply sym_eq.
now apply scaled_mantissa_generic.
revert Hr.
case_eq (Ztrunc (scaled_mantissa radix2 fexp r)).
(* *)
intros _ Hx.
repeat split.
apply Rmult_eq_reg_r with (bpow radix2 (- canonic_exponent radix2 fexp r)).
now rewrite Rmult_0_l.
apply Rgt_not_eq.
apply bpow_gt_0.
(* *)
intros p Hp Hx.
case binary_round_correct ; intros Hv.
unfold F2R, Fnum, Fexp, cond_Zopp.
rewrite Hx, scaled_mantissa_bpow.
rewrite round_generic with (1 := Gx).
rewrite Rlt_bool_true with (1 := Bx).
intros H.
split.
rewrite is_finite_FF2B.
revert H.
assert (0 <> r)%R.
intros H.
rewrite <- H, scaled_mantissa_0 in Hx.
now apply (Z2R_neq 0 (Zpos p)).
now case binary_round_sign_shl.
now rewrite B2R_FF2B.
(* *)
intros p Hp Hx.
case binary_round_correct ; intros Hv.
unfold F2R, Fnum, Fexp, cond_Zopp, Zopp.
rewrite Hx, scaled_mantissa_bpow.
rewrite round_generic with (1 := Gx).
rewrite Rlt_bool_true with (1 := Bx).
intros H.
split.
rewrite is_finite_FF2B.
revert H.
assert (0 <> r)%R.
intros H.
rewrite <- H, scaled_mantissa_0 in Hx.
now apply (Z2R_neq 0 (Zneg p)).
now case binary_round_sign_shl.
now rewrite B2R_FF2B.
Qed.

Theorem r_to_fp_format :
  forall rnd x,
  FLT_format radix2 emin prec x ->
  (Rabs x < bpow radix2 emax)%R ->
  r_to_fp rnd x = x :>R.
Proof.
intros rnd x Fx Bx.
assert (Gx: generic_format radix2 fexp x).
apply -> FLT_format_generic.
apply Fx.
exact Hprec'.
pattern x at 2 ; rewrite <- round_generic with (rnd := round_mode rnd) (1 := Gx).
refine (proj2 (r_to_fp_correct _ _ _)).
now rewrite round_generic with (1 := Gx).
Qed.



Definition r_to_fp_aux (m:mode) (r r1 r2:R) :=
  mk_fp (r_to_fp (rnd_of_mode m) r) r1 r2.


Definition round: floating_point.Rounding.mode -> R -> R :=
   (fun m => round radix2 fexp (round_mode (rnd_of_mode m))).

Definition round_logic: floating_point.Rounding.mode -> R -> t :=
   fun m r => r_to_fp_aux m r r r.


Definition round_error(x:t): R := (Rabs ((value x) - (exact x))%R).

Definition total_error(x:t): R := (Rabs ((value x) - (model x))%R).

Definition max: R := F2R (Float radix2 (Zpower 2 prec -1) (emax-prec)).


Definition no_overflow(m:floating_point.Rounding.mode) (x:R): Prop :=
  ((Rabs (round m x)) <= max)%R.

(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

Lemma Bounded_real_no_overflow : forall (m:floating_point.Rounding.mode)
  (x:R), ((Rabs x) <= max)%R -> (no_overflow m x).
(* YOU MAY EDIT THE PROOF BELOW *)
Proof.
intros m x Hx.
apply Rabs_le.
assert (generic_format radix2 fexp max).
apply generic_format_canonic_exponent.
unfold canonic_exponent.
rewrite ln_beta_F2R.
rewrite (ln_beta_unique _ _ prec).
ring_simplify (prec + (emax - prec))%Z.
unfold fexp, FLT_exp.
rewrite Zmax_l.
apply Zle_refl.
unfold emin.
generalize Hprec' Hemax' ; clear; omega.
rewrite <- Z2R_abs, Zabs_eq, <- 2!Z2R_Zpower.
split.
apply Z2R_le.
apply Zlt_succ_le.
change (2 ^ prec - 1)%Z with (Zpred (2^prec))%Z.
rewrite <- Zsucc_pred.
apply lt_Z2R.
change 2%Z with (radix_val radix2).
rewrite 2!Z2R_Zpower.
apply bpow_lt.
apply Zlt_pred.
apply Zlt_le_weak.
exact Hprec'.
generalize Hprec' ; clear ; omega.
apply Z2R_lt.
apply Zlt_pred.
apply Zlt_le_weak.
exact Hprec'.
generalize Hprec' ; clear ; omega.
apply Zlt_succ_le.
change (2 ^ prec - 1)%Z with (Zpred (2^prec))%Z.
rewrite <- Zsucc_pred.
change 2%Z with (radix_val radix2).
apply Zpower_gt_0.
apply Zlt_le_weak.
exact Hprec'.
apply Zgt_not_eq.
cut (2 <= 2^prec)%Z.
clear ; omega.
change (radix2 ^ 1 <= radix2 ^ prec)%Z.
apply le_Z2R.
rewrite 2!Z2R_Zpower.
apply bpow_le.
generalize Hprec' ; clear ; omega.
apply Zlt_le_weak.
exact Hprec'.
easy.
generalize (Rabs_le_inv _ _ Hx).
split.
erewrite <- round_generic with (x := Ropp max).
apply round_monotone with (2 := proj1 H0).
apply FLT_exp_correct; exact Hprec'.
now apply generic_format_opp.
rewrite <- round_generic with (rnd := round_mode (rnd_of_mode m)) (1 := H).
apply round_monotone with (2 := proj2 H0).
apply FLT_exp_correct; exact Hprec'.
Qed.

(* DO NOT EDIT BELOW *)

(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

Lemma Round_monotonic : forall (m:floating_point.Rounding.mode) (x:R) (y:R),
  (x <= y)%R -> ((round m x) <= (round m y))%R.
(* YOU MAY EDIT THE PROOF BELOW *)
intros m x y Hxy.
apply round_monotone with (2 := Hxy).
apply FLT_exp_correct; exact Hprec'.
Qed.
(* DO NOT EDIT BELOW *)

(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

Lemma Round_idempotent : forall (m1:floating_point.Rounding.mode)
  (m2:floating_point.Rounding.mode) (x:R), ((round m1 (round m2
  x)) = (round m2 x)).
(* YOU MAY EDIT THE PROOF BELOW *)
intros m1 m2 x.
apply round_generic.
apply generic_format_round.
apply FLT_exp_correct; exact Hprec'.
Qed.

(* DO NOT EDIT BELOW *)

(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

Lemma Round_value : forall (m:floating_point.Rounding.mode) (x:t), ((round m
  (value x)) = (value x)).
(* YOU MAY EDIT THE PROOF BELOW *)
Proof.
intros m x.
apply round_generic.
apply generic_format_B2R.
Qed.
(* DO NOT EDIT BELOW *)

(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

(* This is not an axiom: this is proved in flocq 2.0 *)
Axiom le_pred_lt_bis: forall (beta : radix) (fexp : Z -> Z),
       valid_exp fexp ->
       forall x y : R,
       F beta fexp x ->
       F beta fexp y -> (0 < y)%R -> (x < y)%R -> (x <= pred beta fexp y)%R.


Lemma Bounded_value : forall (x:t), ((Rabs (value x)) <= max)%R.
(* YOU MAY EDIT THE PROOF BELOW *)
intros x.
replace max with (pred radix2 fexp (bpow radix2 emax)).
apply le_pred_lt_bis.
apply FLT_exp_correct; exact Hprec'.
apply generic_format_abs.
apply generic_format_B2R.
apply generic_format_bpow.
unfold fexp, FLT_exp, emin.
clear ; zify ; generalize Hprec' Hemax' ; omega.
apply bpow_gt_0.
apply B2R_lt_emax.
unfold pred.
rewrite ln_beta_bpow.
ring_simplify (emax+1-1)%Z.
rewrite Req_bool_true.
2: easy.
unfold fexp, FLT_exp, emin.
rewrite Zmax_l.
unfold max, F2R; simpl.
pattern emax at 1; replace emax with (prec+(emax-prec))%Z by ring.
rewrite bpow_plus.
change 2%Z with (radix_val radix2).
rewrite Z2R_minus, Z2R_Zpower.
simpl; ring.
apply Zlt_le_weak.
exact Hprec'.
clear; generalize Hprec' Hemax' ; omega.
Qed.
(* DO NOT EDIT BELOW *)

Definition max_representable_integer: Z := Zpower 2 prec.


(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

Lemma Exact_rounding_for_integers : forall (m:floating_point.Rounding.mode)
  (i:Z), (((-max_representable_integer)%Z <= i)%Z /\
  (i <= max_representable_integer)%Z) -> ((round m (IZR i)) = (IZR i)).
(* YOU MAY EDIT THE PROOF BELOW *)
Proof.
intros m z Hz.
apply round_generic.
assert (Zabs z <= max_representable_integer)%Z.
apply Abs_le with (1:=Hz).
destruct (Zle_lt_or_eq _ _ H) as [Bz|Bz] ; clear H Hz.
apply FLT_format_generic.
exact Hprec'.
exists (Float radix2 z 0).
unfold F2R. simpl.
split.
rewrite Z2R_IZR.
now rewrite Rmult_1_r.
split. easy.
clear;unfold emin; generalize Hprec' Hemax'; omega.
unfold max_representable_integer in Bz.
change 2%Z with (radix_val radix2) in Bz.
destruct z as [|z|z] ; unfold Zabs in Bz.
apply generic_format_0.
rewrite Bz.
rewrite <- Z2R_IZR, Z2R_Zpower.
apply generic_format_bpow.
unfold fexp, FLT_exp, emin.
clear; generalize Hprec' Hemax'; zify.
omega.
apply Zlt_le_weak.
apply Hprec'.
change (Zneg z) with (Zopp (Zpos z)).
rewrite Bz, <- Z2R_IZR, Z2R_opp.
rewrite Z2R_Zpower.
apply generic_format_opp.
apply generic_format_bpow.
unfold fexp, FLT_exp, emin.
clear; generalize Hprec' Hemax'; zify.
omega.
apply Zlt_le_weak.
apply Hprec'.
Qed.
(* DO NOT EDIT BELOW *)

(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

Lemma Round_down_le : forall (x:R), ((round floating_point.Rounding.Down
  x) <= x)%R.
(* YOU MAY EDIT THE PROOF BELOW *)
intros x.
eapply round_DN_pt.
apply FLT_exp_correct; exact Hprec'.
Qed.
(* DO NOT EDIT BELOW *)

(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

Lemma Round_up_ge : forall (x:R), (x <= (round floating_point.Rounding.Up
  x))%R.
(* YOU MAY EDIT THE PROOF BELOW *)
intros x.
eapply round_UP_pt.
apply FLT_exp_correct; exact Hprec'.
Qed.
(* DO NOT EDIT BELOW *)

(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

Lemma Round_down_neg : forall (x:R), ((round floating_point.Rounding.Down
  (-x)%R) = (-(round floating_point.Rounding.Up x))%R).
(* YOU MAY EDIT THE PROOF BELOW *)
intros x.
apply round_opp.
Qed.
(* DO NOT EDIT BELOW *)

(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

Lemma Round_up_neg : forall (x:R), ((round floating_point.Rounding.Up
  (-x)%R) = (-(round floating_point.Rounding.Down x))%R).
(* YOU MAY EDIT THE PROOF BELOW *)
intros x.
pattern x at 2 ; rewrite <- Ropp_involutive.
rewrite Round_down_neg.
now rewrite Ropp_involutive.
Qed.

End GenFloat.
(* DO NOT EDIT BELOW *)