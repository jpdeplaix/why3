(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import ZArith.
Require Import Rbase.
(*Add Rec LoadPath "/home/guillaume/bin/why3/share/why3/theories".*)
(*Add Rec LoadPath "/home/guillaume/bin/why3/share/why3/modules".*)
Require int.Int.
Require int.Abs.

Definition div : Z -> Z -> Z.
(* YOU MAY EDIT THE CONTEXT BELOW *)
intros x y.
case (Z_le_dec 0 (Zmod x y)) ; intros H.
exact (Zdiv x y).
exact (Zdiv x y + 1)%Z.
Defined.
(* DO NOT EDIT BELOW *)

Definition mod1 : Z -> Z -> Z.
(* YOU MAY EDIT THE CONTEXT BELOW *)
intros x y.
exact (x - y * div x y)%Z.
Defined.
(* DO NOT EDIT BELOW *)

(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

Lemma Div_mod : forall (x:Z) (y:Z), (~ (y = 0%Z)) -> (x = ((y * (div x
  y))%Z + (mod1 x y))%Z).
(* YOU MAY EDIT THE PROOF BELOW *)
intros x y Zy.
unfold mod1, div.
case Z_le_dec ; intros H ; ring.
Qed.
(* DO NOT EDIT BELOW *)

(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

Lemma Div_bound : forall (x:Z) (y:Z), ((0%Z <= x)%Z /\ (0%Z <  y)%Z) ->
  ((0%Z <= (div x y))%Z /\ ((div x y) <= x)%Z).
(* YOU MAY EDIT THE PROOF BELOW *)
intros x y (Hx,Hy).
unfold div.
case Z_le_dec ; intros H.
split.
apply Z_div_pos with (2 := Hx).
now apply Zlt_gt.
destruct (Z_eq_dec y 1) as [H'|H'].
rewrite H', Zdiv_1_r.
apply Zle_refl.
rewrite <- (Zdiv_1_r x) at 2.
apply Zdiv_le_compat_l with (1 := Hx).
omega.
elim H.
apply Z_mod_lt.
now apply Zlt_gt.
Qed.
(* DO NOT EDIT BELOW *)

(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

Lemma Mod_bound : forall (x:Z) (y:Z), (~ (y = 0%Z)) -> ((0%Z <= (mod1 x
  y))%Z /\ ((mod1 x y) <  (Zabs y))%Z).
(* YOU MAY EDIT THE PROOF BELOW *)
intros x y Zy.
zify.
assert (H1 := Z_mod_neg x y).
assert (H2 := Z_mod_lt x y).
unfold mod1, div.
case Z_le_dec ; intros H0.
rewrite Zmult_comm, <- Zmod_eq_full with (1 := Zy).
omega.
replace (x - y * (x / y + 1))%Z with (x - x / y * y - y)%Z by ring.
rewrite <- Zmod_eq_full with (1 := Zy).
omega.
Qed.
(* DO NOT EDIT BELOW *)

(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

Lemma Mod_1 : forall (x:Z), ((mod1 x 1%Z) = 0%Z).
(* YOU MAY EDIT THE PROOF BELOW *)
intros x.
unfold mod1, div.
rewrite Zmod_1_r, Zdiv_1_r, Zmult_1_l.
apply Zminus_diag.
Qed.
(* DO NOT EDIT BELOW *)

(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

Lemma Div_1 : forall (x:Z), ((div x 1%Z) = x).
(* YOU MAY EDIT THE PROOF BELOW *)
intros x.
unfold div.
now rewrite Zmod_1_r, Zdiv_1_r.
Qed.
(* DO NOT EDIT BELOW *)

