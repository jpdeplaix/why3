(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import ZArith.
Require Import Rbase.
Require Import Rbasic_fun.
Require Import R_sqrt.
Require Import Rtrigo.
Require Import AltSeries. (* for def of pi *)
Require real.Real.
Require real.RealInfix.
Require real.Abs.
Require real.FromInt.
Require int.Int.
Require real.Square.
Require floating_point.Rounding.
Require floating_point.Single.

(* Why3 assumption *)
Definition unit  := unit.

Parameter qtmark : Type.

Parameter at1: forall (a:Type), a -> qtmark -> a.
Implicit Arguments at1.

Parameter old: forall (a:Type), a -> a.
Implicit Arguments old.

(* Why3 assumption *)
Definition implb(x:bool) (y:bool): bool := match (x,
  y) with
  | (true, false) => false
  | (_, _) => true
  end.

Axiom Pi_interval : ((314159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808651328230664709384460955058223172535940812848111745028410270193852110555964462294895493038196 / 100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000)%R < PI)%R /\
  (PI < (314159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808651328230664709384460955058223172535940812848111745028410270193852110555964462294895493038197 / 100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000)%R)%R.

Axiom Cos_plus_pi : forall (x:R),
  ((Rtrigo_def.cos (x + PI)%R) = (-(Rtrigo_def.cos x))%R).

Axiom Sin_plus_pi : forall (x:R),
  ((Rtrigo_def.sin (x + PI)%R) = (-(Rtrigo_def.sin x))%R).

Axiom Cos_plus_pi2 : forall (x:R),
  ((Rtrigo_def.cos (x + ((05 / 10)%R * PI)%R)%R) = (-(Rtrigo_def.sin x))%R).

Axiom Sin_plus_pi2 : forall (x:R),
  ((Rtrigo_def.sin (x + ((05 / 10)%R * PI)%R)%R) = (Rtrigo_def.cos x)).

Axiom Cos_neg : forall (x:R), ((Rtrigo_def.cos (-x)%R) = (Rtrigo_def.cos x)).

Axiom Sin_neg : forall (x:R),
  ((Rtrigo_def.sin (-x)%R) = (-(Rtrigo_def.sin x))%R).

Axiom Cos_sum : forall (x:R) (y:R),
  ((Rtrigo_def.cos (x + y)%R) = (((Rtrigo_def.cos x) * (Rtrigo_def.cos y))%R - ((Rtrigo_def.sin x) * (Rtrigo_def.sin y))%R)%R).

Axiom Sin_sum : forall (x:R) (y:R),
  ((Rtrigo_def.sin (x + y)%R) = (((Rtrigo_def.sin x) * (Rtrigo_def.cos y))%R + ((Rtrigo_def.cos x) * (Rtrigo_def.sin y))%R)%R).

Parameter atan: R -> R.

Axiom Tan_atan : forall (x:R), ((Rtrigo.tan (atan x)) = x).

Require Import Interval_tactic.


(* Why3 goal *)
Theorem WP_parameter_my_cosine : forall (x:floating_point.Single.single),
  ((Rabs (floating_point.Single.value x)) <= (1 / 32)%R)%R ->
  ((Rabs ((1%R - (((floating_point.Single.value x) * (floating_point.Single.value x))%R * (05 / 10)%R)%R)%R - (Rtrigo_def.cos (floating_point.Single.value x)))%R) <= (1 / 16777216)%R)%R.
(* YOU MAY EDIT THE PROOF BELOW *)
intros x H.
interval with (i_bisect_diff (Single.value x)).
Qed.


