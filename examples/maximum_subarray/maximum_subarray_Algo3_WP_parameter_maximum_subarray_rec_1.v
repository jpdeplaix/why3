(* This file is generated by Why3's Coq 8.4 driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require Import ZOdiv.
Require BuiltIn.
Require int.Int.
Require int.Abs.
Require int.ComputerDivision.
Require map.Map.

(* Why3 assumption *)
Definition unit := unit.

(* Why3 assumption *)
Inductive ref (a:Type) {a_WT:WhyType a} :=
  | mk_ref : a -> ref a.
Axiom ref_WhyType : forall (a:Type) {a_WT:WhyType a}, WhyType (ref a).
Existing Instance ref_WhyType.
Implicit Arguments mk_ref [[a] [a_WT]].

(* Why3 assumption *)
Definition contents {a:Type} {a_WT:WhyType a} (v:(@ref a a_WT)): a :=
  match v with
  | (mk_ref x) => x
  end.

(* Why3 assumption *)
Inductive array
  (a:Type) {a_WT:WhyType a} :=
  | mk_array : Z -> (@map.Map.map Z _ a a_WT) -> array a.
Axiom array_WhyType : forall (a:Type) {a_WT:WhyType a}, WhyType (array a).
Existing Instance array_WhyType.
Implicit Arguments mk_array [[a] [a_WT]].

(* Why3 assumption *)
Definition elts {a:Type} {a_WT:WhyType a} (v:(@array a a_WT)): (@map.Map.map
  Z _ a a_WT) := match v with
  | (mk_array x x1) => x1
  end.

(* Why3 assumption *)
Definition length {a:Type} {a_WT:WhyType a} (v:(@array a a_WT)): Z :=
  match v with
  | (mk_array x x1) => x
  end.

(* Why3 assumption *)
Definition get {a:Type} {a_WT:WhyType a} (a1:(@array a a_WT)) (i:Z): a :=
  (map.Map.get (elts a1) i).

(* Why3 assumption *)
Definition set {a:Type} {a_WT:WhyType a} (a1:(@array a a_WT)) (i:Z)
  (v:a): (@array a a_WT) := (mk_array (length a1) (map.Map.set (elts a1) i
  v)).

(* Why3 assumption *)
Definition make {a:Type} {a_WT:WhyType a} (n:Z) (v:a): (@array a a_WT) :=
  (mk_array n (map.Map.const v:(@map.Map.map Z _ a a_WT))).

(* Why3 assumption *)
Definition container := (@map.Map.map Z _ Z _).

Parameter sum: (@map.Map.map Z _ Z _) -> Z -> Z -> Z.

Axiom Sum_def_empty : forall (c:(@map.Map.map Z _ Z _)) (i:Z) (j:Z),
  (j <= i)%Z -> ((sum c i j) = 0%Z).

Axiom Sum_def_non_empty : forall (c:(@map.Map.map Z _ Z _)) (i:Z) (j:Z),
  (i < j)%Z -> ((sum c i j) = ((map.Map.get c i) + (sum c (i + 1%Z)%Z j))%Z).

Axiom Sum_right_extension : forall (c:(@map.Map.map Z _ Z _)) (i:Z) (j:Z),
  (i < j)%Z -> ((sum c i j) = ((sum c i (j - 1%Z)%Z) + (map.Map.get c
  (j - 1%Z)%Z))%Z).

Axiom Sum_transitivity : forall (c:(@map.Map.map Z _ Z _)) (i:Z) (k:Z) (j:Z),
  ((i <= k)%Z /\ (k <= j)%Z) -> ((sum c i j) = ((sum c i k) + (sum c k
  j))%Z).

Axiom Sum_eq : forall (c1:(@map.Map.map Z _ Z _)) (c2:(@map.Map.map Z _ Z _))
  (i:Z) (j:Z), (forall (k:Z), ((i <= k)%Z /\ (k < j)%Z) -> ((map.Map.get c1
  k) = (map.Map.get c2 k))) -> ((sum c1 i j) = (sum c2 i j)).

(* Why3 assumption *)
Definition sum1 (a:(@array Z _)) (l:Z) (h:Z): Z := (sum (elts a) l h).

(* Why3 assumption *)
Definition maxsublo (a:(@array Z _)) (maxlo:Z) (s:Z): Prop := forall (l:Z)
  (h:Z), ((0%Z <= l)%Z /\ (l < maxlo)%Z) -> (((l <= h)%Z /\
  (h <= (length a))%Z) -> ((sum1 a l h) <= s)%Z).

(* Why3 assumption *)
Definition maxsub (a:(@array Z _)) (s:Z): Prop := forall (l:Z) (h:Z),
  ((0%Z <= l)%Z /\ ((l <= h)%Z /\ (h <= (length a))%Z)) -> ((sum1 a l
  h) <= s)%Z.

(* Why3 goal *)
Theorem WP_parameter_maximum_subarray_rec : forall (a:Z) (a1:(@map.Map.map
  Z _ Z _)) (l:Z) (h:Z), ((0%Z <= a)%Z /\ ((0%Z <= l)%Z /\ ((l <= h)%Z /\
  (h <= a)%Z))) -> ((~ (h = l)) -> let mid :=
  (l + (ZOdiv (h - l)%Z 2%Z))%Z in forall (lo:Z), (lo = mid) ->
  forall (hi:Z), (hi = mid) -> ((l <= (mid - 1%Z)%Z)%Z -> forall (s:Z) (ms:Z)
  (lo1:Z), ((((l <= lo1)%Z /\ ((lo1 <= mid)%Z /\ (mid = hi))) /\
  (ms = (sum a1 lo1 hi))) /\ ((forall (l':Z), (((l - 1%Z)%Z < l')%Z /\
  (l' <= mid)%Z) -> ((sum a1 l' mid) <= ms)%Z) /\ (s = (sum a1
  ((l - 1%Z)%Z + 1%Z)%Z mid)))) -> ((forall (l':Z), ((l <= l')%Z /\
  (l' <= mid)%Z) -> ((sum a1 l' mid) <= (sum a1 lo1 mid))%Z) ->
  forall (s1:Z), (s1 = ms) -> let o := (h - 1%Z)%Z in ((mid <= o)%Z ->
  forall (s2:Z) (ms1:Z) (hi1:Z), forall (i:Z), ((mid <= i)%Z /\
  (i <= o)%Z) -> (((((l <= lo1)%Z /\ ((lo1 <= mid)%Z /\ ((mid <= hi1)%Z /\
  (hi1 <= h)%Z))) /\ (ms1 = (sum a1 lo1 hi1))) /\ ((forall (l':Z) (h':Z),
  ((l <= l')%Z /\ ((l' <= mid)%Z /\ ((mid <= h')%Z /\ (h' <= i)%Z))) ->
  ((sum a1 l' h') <= ms1)%Z) /\ (s2 = (sum a1 lo1 i)))) -> (((0%Z <= i)%Z /\
  (i < a)%Z) -> forall (s3:Z), (s3 = (s2 + (map.Map.get a1 i))%Z) ->
  ((s3 = (sum a1 lo1 (i + 1%Z)%Z)) -> ((s3 = ((sum a1 lo1 mid) + (sum a1 mid
  (i + 1%Z)%Z))%Z) -> ((ms1 < s3)%Z -> forall (ms2:Z), (ms2 = s3) ->
  forall (hi2:Z), (hi2 = (i + 1%Z)%Z) -> forall (l':Z) (h':Z),
  ((l <= l')%Z /\ ((l' <= mid)%Z /\ ((mid <= h')%Z /\
  (h' <= (i + 1%Z)%Z)%Z))) -> ((sum a1 l' h') <= ms2)%Z))))))))).
intros a a1 l h (h1,(h2,(h3,h4))) h5 mid lo h6 hi h7 h8 s ms lo1
        (((h9,(h10,h11)),h12),(h13,h14)) h15 s1 h16 o h17 s2 ms1 hi1 i
        (h18,h19) (((h20,(h21,(h22,h23))),h24),(h25,h26)) (h27,h28) s3 h29
        h30 h31 h32 ms2 h33 hi2 h34 l' h' (h35,(h36,(h37,h38))).
destruct (Z_le_dec h' i).
apply Zle_trans with ms1.
apply h25.
omega.
omega.
assert (h' = i + 1)%Z by omega.
rewrite H.
rewrite Sum_right_extension by omega.
rewrite h33, h29.
replace (i + 1 - 1)%Z with i by ring.
apply Zplus_le_compat_r.
rewrite h26.
rewrite Sum_transitivity with (k := mid).
rewrite Sum_transitivity with (i := lo1) (k := mid).
apply Zplus_le_compat_r.
apply h15.
omega.
omega.
omega.
Qed.

