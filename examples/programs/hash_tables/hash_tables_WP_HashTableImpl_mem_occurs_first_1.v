(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import ZArith.
Require Import Rbase.
Require Import ZOdiv.
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

Inductive option (a:Type) :=
  | None : option a
  | Some : a -> option a.
Set Contextual Implicit.
Implicit Arguments None.
Unset Contextual Implicit.
Implicit Arguments Some.

Axiom Abs_le : forall (x:Z) (y:Z), ((Zabs x) <= y)%Z <-> (((-y)%Z <= x)%Z /\
  (x <= y)%Z).

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

Axiom Const : forall (b:Type) (a:Type), forall (b1:b) (a1:a),
  ((get (const b1:(map a b)) a1) = b1).

Inductive list (a:Type) :=
  | Nil : list a
  | Cons : a -> (list a) -> list a.
Set Contextual Implicit.
Implicit Arguments Nil.
Unset Contextual Implicit.
Implicit Arguments Cons.

Set Implicit Arguments.
Fixpoint mem (a:Type)(x:a) (l:(list a)) {struct l}: Prop :=
  match l with
  | Nil => False
  | (Cons y r) => (x = y) \/ (mem x r)
  end.
Unset Implicit Arguments.

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

Inductive t (a:Type)
  (b:Type) :=
  | mk_t : (map a (option b)) -> (array (list (a* b)%type)) -> t a b.
Implicit Arguments mk_t.

Definition contents (a:Type) (b:Type)(u:(t a b)): (map a (option b)) :=
  match u with
  | (mk_t contents1 _) => contents1
  end.
Implicit Arguments contents.

Definition data (a:Type) (b:Type)(u:(t a b)): (array (list (a* b)%type)) :=
  match u with
  | (mk_t _ data1) => data1
  end.
Implicit Arguments data.

Definition get2 (a:Type) (b:Type)(h:(t a b)) (k:a): (option b) :=
  (get (contents h) k).
Implicit Arguments get2.

Parameter hash: forall (a:Type), a -> Z.

Implicit Arguments hash.

Definition idx (a:Type) (b:Type)(h:(t a b)) (k:a): Z :=
  (ZOmod (Zabs (hash k)) (length (data h))).
Implicit Arguments idx.

Set Implicit Arguments.
Fixpoint occurs_first (a:Type) (b:Type)(k:a) (v:b) (l:(list (a*
  b)%type)) {struct l}: Prop :=
  match l with
  | Nil => False
  | (Cons (kqt, vqt) r) => ((k = kqt) /\ (v = vqt)) \/ ((~ (k = kqt)) /\
      (occurs_first k v r))
  end.
Unset Implicit Arguments.

(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

Theorem mem_occurs_first : forall (a:Type) (b:Type), forall (k:a) (v:b)
  (l:(list (a* b)%type)), (occurs_first k v l) -> (mem (k, v) l).
(* YOU MAY EDIT THE PROOF BELOW *)
induction l; simpl; intuition.
destruct a0; intuition.
subst; left; auto.
Qed.
(* DO NOT EDIT BELOW *)


