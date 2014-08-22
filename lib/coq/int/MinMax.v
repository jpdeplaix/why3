(* This file is generated by Why3's Coq-realize driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require BuiltIn.
Require int.Int.

(* Why3 comment *)
(* max is replaced with (ZArith.BinInt.Z.max x x1) by the coq driver *)

(* Why3 goal *)
Lemma max_def : forall (x:Z) (y:Z), ((y <= x)%Z ->
  ((ZArith.BinInt.Z.max x y) = x)) /\ ((~ (y <= x)%Z) ->
  ((ZArith.BinInt.Z.max x y) = y)).
Proof.
intros x y.
split ; intros H.
now apply Zmax_l.
apply Zmax_r.
omega.
Qed.

(* Why3 comment *)
(* min is replaced with (ZArith.BinInt.Z.min x x1) by the coq driver *)

(* Why3 goal *)
Lemma min_def : forall (x:Z) (y:Z), ((y <= x)%Z ->
  ((ZArith.BinInt.Z.min x y) = y)) /\ ((~ (y <= x)%Z) ->
  ((ZArith.BinInt.Z.min x y) = x)).
Proof.
intros x y.
split ; intros H.
now apply Zmin_r.
apply Zmin_l.
omega.
Qed.

(* Why3 goal *)
Lemma Max_r : forall (x:Z) (y:Z), (x <= y)%Z ->
  ((ZArith.BinInt.Z.max x y) = y).
exact Zmax_r.
Qed.

(* Why3 goal *)
Lemma Min_l : forall (x:Z) (y:Z), (x <= y)%Z ->
  ((ZArith.BinInt.Z.min x y) = x).
exact Zmin_l.
Qed.

(* Why3 goal *)
Lemma Max_comm : forall (x:Z) (y:Z),
  ((ZArith.BinInt.Z.max x y) = (ZArith.BinInt.Z.max y x)).
exact Zmax_comm.
Qed.

(* Why3 goal *)
Lemma Min_comm : forall (x:Z) (y:Z),
  ((ZArith.BinInt.Z.min x y) = (ZArith.BinInt.Z.min y x)).
exact Zmin_comm.
Qed.

(* Why3 goal *)
Lemma Max_assoc : forall (x:Z) (y:Z) (z:Z),
  ((ZArith.BinInt.Z.max (ZArith.BinInt.Z.max x y) z) = (ZArith.BinInt.Z.max x (ZArith.BinInt.Z.max y z))).
Proof.
intros x y z.
apply eq_sym, Zmax_assoc.
Qed.

(* Why3 goal *)
Lemma Min_assoc : forall (x:Z) (y:Z) (z:Z),
  ((ZArith.BinInt.Z.min (ZArith.BinInt.Z.min x y) z) = (ZArith.BinInt.Z.min x (ZArith.BinInt.Z.min y z))).
Proof.
intros x y z.
apply eq_sym, Zmin_assoc.
Qed.

