(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import ZArith.
Require Import Rbase.
Definition unit  := unit.

Parameter qtmark : Type.

Parameter at1: forall (a:Type), a -> qtmark -> a.

Implicit Arguments at1.

Parameter old: forall (a:Type), a -> a.

Implicit Arguments old.

Definition implb(x:bool) (y:bool): bool := match (x,
  y) with
  | (true, false) => false
  | (_, _) => true
  end.

Inductive ref (a:Type) :=
  | mk_ref : a -> ref a.
Implicit Arguments mk_ref.

Definition contents (a:Type)(u:(ref a)): a :=
  match u with
  | (mk_ref contents1) => contents1
  end.
Implicit Arguments contents.

Parameter map : forall (a:Type) (b:Type), Type.

Parameter get: forall (a:Type) (b:Type), (map a b) -> a -> b.

Implicit Arguments get.

Parameter set: forall (a:Type) (b:Type), (map a b) -> a -> b -> (map a b).

Implicit Arguments set.

Axiom Select_eq : forall (a:Type) (b:Type), forall (m:(map a b)),
  forall (a1:a) (a2:a), forall (b1:b), (a1 = a2) -> ((get (set m a1 b1)
  a2) = b1).

Axiom Select_neq : forall (a:Type) (b:Type), forall (m:(map a b)),
  forall (a1:a) (a2:a), forall (b1:b), (~ (a1 = a2)) -> ((get (set m a1 b1)
  a2) = (get m a2)).

Parameter const: forall (b:Type) (a:Type), b -> (map a b).

Set Contextual Implicit.
Implicit Arguments const.
Unset Contextual Implicit.

Axiom Const : forall (b:Type) (a:Type), forall (b1:b) (a1:a), ((get (const(
  b1):(map a b)) a1) = b1).

Inductive array (a:Type) :=
  | mk_array : Z -> (map Z a) -> array a.
Implicit Arguments mk_array.

Definition elts (a:Type)(u:(array a)): (map Z a) :=
  match u with
  | (mk_array _ elts1) => elts1
  end.
Implicit Arguments elts.

Definition length (a:Type)(u:(array a)): Z :=
  match u with
  | (mk_array length1 _) => length1
  end.
Implicit Arguments length.

Definition get1 (a:Type)(a1:(array a)) (i:Z): a := (get (elts a1) i).
Implicit Arguments get1.

Definition set1 (a:Type)(a1:(array a)) (i:Z) (v:a): (array a) :=
  match a1 with
  | (mk_array xcl0 _) => (mk_array xcl0 (set (elts a1) i v))
  end.
Implicit Arguments set1.

Definition map_eq_sub (a:Type)(a1:(map Z a)) (a2:(map Z a)) (l:Z)
  (u:Z): Prop := forall (i:Z), ((l <= i)%Z /\ (i <  u)%Z) -> ((get a1
  i) = (get a2 i)).
Implicit Arguments map_eq_sub.

Definition exchange (a:Type)(a1:(map Z a)) (a2:(map Z a)) (i:Z)
  (j:Z): Prop := ((get a1 i) = (get a2 j)) /\ (((get a2 i) = (get a1 j)) /\
  forall (k:Z), ((~ (k = i)) /\ ~ (k = j)) -> ((get a1 k) = (get a2 k))).
Implicit Arguments exchange.

Axiom exchange_set : forall (a:Type), forall (a1:(map Z a)), forall (i:Z)
  (j:Z), (exchange a1 (set (set a1 i (get a1 j)) j (get a1 i)) i j).

Inductive permut_sub{a:Type}  : (map Z a) -> (map Z a) -> Z -> Z -> Prop :=
  | permut_refl : forall (a1:(map Z a)) (a2:(map Z a)), forall (l:Z) (u:Z),
      (map_eq_sub a1 a2 l u) -> (permut_sub a1 a2 l u)
  | permut_sym : forall (a1:(map Z a)) (a2:(map Z a)), forall (l:Z) (u:Z),
      (permut_sub a1 a2 l u) -> (permut_sub a2 a1 l u)
  | permut_trans : forall (a1:(map Z a)) (a2:(map Z a)) (a3:(map Z a)),
      forall (l:Z) (u:Z), (permut_sub a1 a2 l u) -> ((permut_sub a2 a3 l
      u) -> (permut_sub a1 a3 l u))
  | permut_exchange : forall (a1:(map Z a)) (a2:(map Z a)), forall (l:Z)
      (u:Z) (i:Z) (j:Z), ((l <= i)%Z /\ (i <  u)%Z) -> (((l <= j)%Z /\
      (j <  u)%Z) -> ((exchange a1 a2 i j) -> (permut_sub a1 a2 l u))).
Implicit Arguments permut_sub.

Axiom permut_weakening : forall (a:Type), forall (a1:(map Z a)) (a2:(map Z
  a)), forall (l1:Z) (r1:Z) (l2:Z) (r2:Z), (((l1 <= l2)%Z /\ (l2 <= r2)%Z) /\
  (r2 <= r1)%Z) -> ((permut_sub a1 a2 l2 r2) -> (permut_sub a1 a2 l1 r1)).

Axiom permut_eq : forall (a:Type), forall (a1:(map Z a)) (a2:(map Z a)),
  forall (l:Z) (u:Z), (permut_sub a1 a2 l u) -> forall (i:Z), ((i <  l)%Z \/
  (u <= i)%Z) -> ((get a2 i) = (get a1 i)).

Axiom permut_exists : forall (a:Type), forall (a1:(map Z a)) (a2:(map Z a)),
  forall (l:Z) (u:Z), (permut_sub a1 a2 l u) -> forall (i:Z), ((l <= i)%Z /\
  (i <  u)%Z) -> exists j:Z, ((l <= j)%Z /\ (j <  u)%Z) /\ ((get a2
  i) = (get a1 j)).

Definition exchange1 (a:Type)(a1:(array a)) (a2:(array a)) (i:Z)
  (j:Z): Prop := (exchange (elts a1) (elts a2) i j).
Implicit Arguments exchange1.

Definition permut_sub1 (a:Type)(a1:(array a)) (a2:(array a)) (l:Z)
  (u:Z): Prop := (permut_sub (elts a1) (elts a2) l u).
Implicit Arguments permut_sub1.

Definition permut (a:Type)(a1:(array a)) (a2:(array a)): Prop :=
  ((length a1) = (length a2)) /\ (permut_sub (elts a1) (elts a2) 0%Z
  (length a1)).
Implicit Arguments permut.

Axiom exchange_permut : forall (a:Type), forall (a1:(array a)) (a2:(array a))
  (i:Z) (j:Z), (exchange1 a1 a2 i j) -> (((length a1) = (length a2)) ->
  (((0%Z <= i)%Z /\ (i <  (length a1))%Z) -> (((0%Z <= j)%Z /\
  (j <  (length a1))%Z) -> (permut a1 a2)))).

Axiom permut_sym1 : forall (a:Type), forall (a1:(array a)) (a2:(array a)),
  (permut a1 a2) -> (permut a2 a1).

Axiom permut_trans1 : forall (a:Type), forall (a1:(array a)) (a2:(array a))
  (a3:(array a)), (permut a1 a2) -> ((permut a2 a3) -> (permut a1 a3)).

Definition array_eq_sub (a:Type)(a1:(array a)) (a2:(array a)) (l:Z)
  (u:Z): Prop := (map_eq_sub (elts a1) (elts a2) l u).
Implicit Arguments array_eq_sub.

Definition array_eq (a:Type)(a1:(array a)) (a2:(array a)): Prop :=
  ((length a1) = (length a2)) /\ (array_eq_sub a1 a2 0%Z (length a1)).
Implicit Arguments array_eq.

Axiom array_eq_sub_permut : forall (a:Type), forall (a1:(array a)) (a2:(array
  a)) (l:Z) (u:Z), (array_eq_sub a1 a2 l u) -> (permut_sub1 a1 a2 l u).

Axiom array_eq_permut : forall (a:Type), forall (a1:(array a)) (a2:(array
  a)), (array_eq a1 a2) -> (permut a1 a2).

Definition le(x:bool) (y:bool): Prop := (x = false) \/ (y = true).

Definition sorted(a:(array bool)): Prop := forall (i1:Z) (i2:Z),
  (((0%Z <= i1)%Z /\ (i1 <= i2)%Z) /\ (i2 <  (length a))%Z) -> (le (get1 a
  i1) (get1 a i2)).

(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

Theorem WP_parameter_two_way_sort : forall (a:Z), forall (a1:(map Z bool)),
  let a2 := (mk_array a a1) in forall (j:Z), forall (i:Z), forall (a3:(map Z
  bool)), ((0%Z <= i)%Z /\ ((j <  a)%Z /\ ((permut a2 (mk_array a a3)) /\
  ((forall (k:Z), ((0%Z <= k)%Z /\ (k <  i)%Z) -> ~ ((get a3 k) = true)) /\
  forall (k:Z), ((j <  k)%Z /\ (k <  a)%Z) -> ((get a3 k) = true))))) ->
  ((i <  j)%Z -> (((0%Z <= i)%Z /\ (i <  a)%Z) -> (((get a3 i) = true) ->
  (((0%Z <= j)%Z /\ (j <  a)%Z) -> ((~ ((get a3 j) = true)) ->
  ((((0%Z <= i)%Z /\ (i <  a)%Z) /\ ((0%Z <= j)%Z /\ (j <  a)%Z)) ->
  forall (a4:(map Z bool)), (exchange a3 a4 i j) -> forall (i1:Z),
  (i1 = (i + 1%Z)%Z) -> forall (j1:Z), (j1 = (j - 1%Z)%Z) -> (permut a2
  (mk_array a a4)))))))).
(* YOU MAY EDIT THE PROOF BELOW *)
intuition.
intuition.
apply permut_trans1 with (mk_array a a3); auto.
apply exchange_permut with i j; auto.
Qed.
(* DO NOT EDIT BELOW *)

