/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.MonadicFO
import FormalSystem.Metalogic.WeakCanonical.Table

/-!
# Exists-Forall Normal Form (Rabinovich 2014, Definition 3.1)

Defines the exists-forall normal form for monadic first-order formulas
over linearly ordered structures. An exists-forall formula describes
an interval decomposition: existentially chosen witness points partition
a segment of the linear order into intervals, each labeled by a type.

## Main Definitions

- `EFFormula`: Exists-forall formula (Rabinovich Def 3.1)
- `EFFormula.holds`: Semantic evaluation
- `VEF`: "V-exists-forall" -- a disjunction of exists-forall formulas

## Main Results

- `VEF.closed_disj`: V-exists-forall is closed under disjunction
- `VEF.closed_conj`: V-exists-forall is closed under conjunction (Lemma 3.2.1)
- `VEF.closed_ex`: V-exists-forall is closed under existential quantification (Lemma 3.4)

## Semantic Approach

Rather than defining EF formulas syntactically (as inductive data), we define
them semantically: an EFFormula is a predicate on models that has the exists-forall
shape. This avoids the complexity of a syntactic normal form while preserving the
key closure properties needed for the Kamp theorem proof.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Section 3
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

/-! ## Temporal Predicates

A `TemporalPred` is a predicate on points of an ordered monadic structure that
is definable by a temporal formula. This is the building block for exists-forall
formulas in the Prior setting: point types and interval types are temporal predicates.
-/

/-- A temporal predicate: a `Formula` together with its semantic interpretation. -/
structure TemporalPred where
  /-- The temporal formula that defines the predicate; see `TemporalPred.EvalAt`. -/
  formula : Formula

/-- Evaluate a temporal predicate at a point. -/
def TemporalPred.EvalAt {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (tp : TemporalPred) (t : M.carrier) : Prop :=
  TemporalTruth M atomMap t tp.formula

/-- The "true" temporal predicate (always holds). -/
def TemporalPred.top : TemporalPred := ⟨Formula.top⟩

/-- The "false" temporal predicate (never holds). -/
def TemporalPred.bot : TemporalPred := ⟨Formula.bot⟩

/-- Negation of a temporal predicate. -/
def TemporalPred.neg (tp : TemporalPred) : TemporalPred := ⟨tp.formula.neg⟩

/-- Conjunction of temporal predicates. -/
def TemporalPred.conj (tp1 tp2 : TemporalPred) : TemporalPred :=
  ⟨Formula.and tp1.formula tp2.formula⟩

/-- Disjunction of temporal predicates.

    Source correspondence: Rabinovich 2014, PDF p.8, eq (5.2). The `INF(z₀,r₀,z₁,P₁)` formula
    ends in the disjunctive point condition `(P₁(r₀) ∨ K⁺(P₁)(r₀))` — the first occurrence is
    either *attained* at `r₀` or approached from above at `r₀`. That disjunction is the one
    place in Section 5 where a point type is genuinely a disjunction rather than a conjunction,
    and it is why this primitive is needed alongside `conj`. See `TemporalPred.eval_at_disj`
    (`VecEAClosure.lean`) for the semantic correctness statement, and `HasDedekindINF`
    (`Kamp/DedekindINF.lean`) for the carrier that consumes it. -/
def TemporalPred.disj (tp1 tp2 : TemporalPred) : TemporalPred :=
  ⟨Formula.or tp1.formula tp2.formula⟩

/-! ## Interval Decomposition Semantics

An interval decomposition describes the pattern of point types at
existentially chosen witnesses and interval types between them.
We define this purely semantically: a decomposition "holds" on a
structure if witnesses with the right properties exist.

The key data for an interval decomposition on (z_0, z_1) with n witnesses:
- `point_types : Fin (n + 1) → TemporalPred`  (alpha_0, ..., alpha_n at z_0=x_0, x_1, ..., x_n)
- `IntervalTypes : Fin (n + 2) → TemporalPred`  (beta_0 below x_0, beta_1 on (x_0, x_1), ...,
beta_{n+1} above x_n)

But for the Prior formalization, we simplify: we work with interval
decompositions on bounded intervals (z_0, z_1) where z_0 and z_1 are
the free variables. The point types are at the witness points, and
the interval types describe what holds between consecutive witnesses.
-/

/-- An interval decomposition pattern with `n` witness points in an interval.
    `alpha i` is the point type at witness `i`, and `beta i` is the interval
    type on the segment between witness `i-1` and witness `i` (with beta 0
    being the segment before the first witness and beta n being the segment
    after the last witness). -/
structure IntervalPattern (n : Nat) where
  /-- Point types at each witness point (alpha_0, ..., alpha_{n-1}) -/
  alpha : Fin n → TemporalPred
  /-- Interval types on each segment (beta_0, ..., beta_n) where beta_i
      is the type on the segment (x_{i-1}, x_i) with x_{-1} = z_0, x_n = z_1 -/
  beta : Fin (n + 1) → TemporalPred

/-- An interval pattern holds on (z_0, z_1) in a structure M if there exist
    strictly increasing witness points x_0 < ... < x_{n-1} in (z_0, z_1) such that:
    - alpha_i holds at x_i for each i
    - beta_0 holds everywhere in (z_0, x_0)
    - beta_i holds everywhere in (x_{i-1}, x_i) for 1 <= i < n
    - beta_n holds everywhere in (x_{n-1}, z_1) -/
def IntervalPattern.holds {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (pat : IntervalPattern n) (z0 z1 : M.carrier) : Prop :=
  match n, pat with
  | 0, pat =>
    -- No witnesses: beta_0 holds everywhere in (z_0, z_1)
    ∀ y : M.carrier, z0 < y → y < z1 → (pat.beta ⟨0, by omega⟩).EvalAt M atomMap y
  | n + 1, pat =>
    -- n+1 witnesses
    ∃ (witnesses : Fin (n + 1) → M.carrier),
      -- Witnesses are strictly increasing
      (∀ i j : Fin (n + 1), i < j → witnesses i < witnesses j) ∧
      -- All witnesses are in (z_0, z_1)
      (∀ i : Fin (n + 1), z0 < witnesses i ∧ witnesses i < z1) ∧
      -- Point types hold at witnesses
      (∀ i : Fin (n + 1), (pat.alpha i).EvalAt M atomMap (witnesses i)) ∧
      -- Interval types hold on segments
      -- beta_0: on (z_0, x_0)
      (∀ y : M.carrier, z0 < y → y < witnesses ⟨0, by omega⟩ →
        (pat.beta ⟨0, by omega⟩).EvalAt M atomMap y) ∧
      -- beta_i (1 <= i <= n-1): on (x_{i-1}, x_i)
      (∀ (i : Fin n), ∀ y : M.carrier,
        witnesses ⟨i.val, by omega⟩ < y → y < witnesses ⟨i.val + 1, by omega⟩ →
        (pat.beta ⟨i.val + 1, by omega⟩).EvalAt M atomMap y) ∧
      -- beta_{n}: on (x_{n-1}, z_1)
      (∀ y : M.carrier, witnesses ⟨n, by omega⟩ < y → y < z1 →
        (pat.beta ⟨n + 1, by omega⟩).EvalAt M atomMap y)

/-! ### IntervalPattern.holds helper lemmas

These provide non-matching characterizations of `holds` for use when the
witness count `n` is not syntactically `0` or `k + 1` (e.g., `n - i.val`). -/

/-- Transport `IntervalPattern.holds` along an equality of witness counts. -/
theorem IntervalPattern.holds_of_eq {sig : MonadicSignature} {m n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (pat : IntervalPattern m) (z0 z1 : M.carrier) (h : m = n) :
    pat.holds M atomMap z0 z1 =
    (h ▸ pat : IntervalPattern n).holds M atomMap z0 z1 := by
  subst h; rfl

/-- `IntervalPattern.holds` for 0 witnesses unfolds to the forall form. -/
theorem IntervalPattern.holds_zero {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (pat : IntervalPattern 0) (z0 z1 : M.carrier) :
    pat.holds M atomMap z0 z1 ↔
    ∀ y : M.carrier, z0 < y → y < z1 → (pat.beta ⟨0, by omega⟩).EvalAt M atomMap y := by
  simp only [IntervalPattern.holds]

/-- `IntervalPattern.holds` for `n+1` witnesses unfolds to the existential form. -/
theorem IntervalPattern.holds_succ {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (pat : IntervalPattern (n + 1)) (z0 z1 : M.carrier) :
    pat.holds M atomMap z0 z1 ↔
    ∃ (witnesses : Fin (n + 1) → M.carrier),
      (∀ i j : Fin (n + 1), i < j → witnesses i < witnesses j) ∧
      (∀ i : Fin (n + 1), z0 < witnesses i ∧ witnesses i < z1) ∧
      (∀ i : Fin (n + 1), (pat.alpha i).EvalAt M atomMap (witnesses i)) ∧
      (∀ y : M.carrier, z0 < y → y < witnesses ⟨0, by omega⟩ →
        (pat.beta ⟨0, by omega⟩).EvalAt M atomMap y) ∧
      (∀ (i : Fin n), ∀ y : M.carrier,
        witnesses ⟨i.val, by omega⟩ < y → y < witnesses ⟨i.val + 1, by omega⟩ →
        (pat.beta ⟨i.val + 1, by omega⟩).EvalAt M atomMap y) ∧
      (∀ y : M.carrier, witnesses ⟨n, by omega⟩ < y → y < z1 →
        (pat.beta ⟨n + 1, by omega⟩).EvalAt M atomMap y) := by
  simp only [IntervalPattern.holds]

/-- Convert `IntervalPattern.holds` at witness count `m` to the zero-witness form
    when `m = 0`. This handles the case where `m` is a computed expression
    (like `n - i.val`) that equals 0 but is not syntactically 0. -/
theorem IntervalPattern.holds_eq_zero {sig : MonadicSignature} {m : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (alpha : Fin m → TemporalPred) (beta : Fin (m + 1) → TemporalPred)
    (z0 z1 : M.carrier) (h : m = 0) :
    (IntervalPattern.mk alpha beta).holds M atomMap z0 z1 ↔
    ∀ y : M.carrier, z0 < y → y < z1 →
      (beta ⟨0, by omega⟩).EvalAt M atomMap y := by
  subst h; simp only [IntervalPattern.holds]

/-- Convert `IntervalPattern.holds` at witness count `m` to the successor form
    when `m = k + 1`. This handles the case where `m` is a computed expression
    (like `n - i.val`) that equals `k + 1` but is not syntactically a successor. -/
theorem IntervalPattern.holds_eq_succ {sig : MonadicSignature} {m k : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (alpha : Fin m → TemporalPred) (beta : Fin (m + 1) → TemporalPred)
    (z0 z1 : M.carrier) (h : m = k + 1) :
    (IntervalPattern.mk alpha beta).holds M atomMap z0 z1 ↔
    ∃ (witnesses : Fin (k + 1) → M.carrier),
      (∀ i j : Fin (k + 1), i < j → witnesses i < witnesses j) ∧
      (∀ i : Fin (k + 1), z0 < witnesses i ∧ witnesses i < z1) ∧
      (∀ i : Fin (k + 1), (alpha ⟨i.val, by omega⟩).EvalAt M atomMap (witnesses i)) ∧
      (∀ y : M.carrier, z0 < y → y < witnesses ⟨0, by omega⟩ →
        (beta ⟨0, by omega⟩).EvalAt M atomMap y) ∧
      (∀ (i : Fin k), ∀ y : M.carrier,
        witnesses ⟨i.val, by omega⟩ < y → y < witnesses ⟨i.val + 1, by omega⟩ →
        (beta ⟨i.val + 1, by omega⟩).EvalAt M atomMap y) ∧
      (∀ y : M.carrier, witnesses ⟨k, by omega⟩ < y → y < z1 →
        (beta ⟨k + 1, by omega⟩).EvalAt M atomMap y) := by
  subst h; simp only [IntervalPattern.holds]

/-! ## V-Exists-Forall Formulas

A V-exists-forall formula (Rabinovich Def 3.3) is a formula equivalent to
a disjunction of exists-forall formulas. We represent this as a semantic
predicate: a V-EF property holds at a point if SOME interval pattern holds. -/

/-- A V-exists-forall (VEF) predicate on bounded intervals (z_0, z_1).
    It holds if some interval pattern from a list holds on (z_0, z_1). -/
structure VEF where
  /-- The list of interval patterns (disjuncts) -/
  patterns : List (Σ n, IntervalPattern n)

/-- A VEF holds on (z_0, z_1) if some pattern in the list holds. -/
def VEF.holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v : VEF) (z0 z1 : M.carrier) : Prop :=
  ∃ pat ∈ v.patterns, pat.2.holds M atomMap z0 z1

/-- A VEF predicate on single points (1 free variable).
    This is a VEF where we encode the free variable as z_0 with z_1 free. -/
structure VEF1 where
  /-- A property on ordered monadic structures that is VEF-definable. -/
  property : {sig : MonadicSignature} →
    (M : OrderedMonadicStructure sig) →
    (atomMap : Formula → sig.preds) →
    M.carrier → Prop
  /-- The property is realized by a temporal formula. -/
  formula : Formula
  /-- The formula is correct. -/
  correct : ∀ {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (t : M.carrier),
    property M atomMap t ↔ TemporalTruth M atomMap t formula

/-! ## Key Closure Properties

These are the central results enabling the inductive proof:
- VEF is closed under disjunction (trivial: concatenate pattern lists)
- VEF is closed under conjunction (Lemma 3.2.1: merge witness sequences)
- VEF is closed under existential quantification (Lemma 3.2.3/3.4)
-/

/-- VEF is closed under disjunction: the disjunction of two VEF predicates
    is VEF (just concatenate the pattern lists). -/
def VEF.disj (v1 v2 : VEF) : VEF :=
  ⟨v1.patterns ++ v2.patterns⟩

theorem VEF.disj_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v1 v2 : VEF) (z0 z1 : M.carrier) :
    (VEF.disj v1 v2).holds M atomMap z0 z1 ↔
    v1.holds M atomMap z0 z1 ∨ v2.holds M atomMap z0 z1 := by
  simp only [VEF.holds, VEF.disj, List.mem_append]
  constructor
  · rintro ⟨pat, h_mem, h_holds⟩
    rcases h_mem with h1 | h2
    · exact Or.inl ⟨pat, h1, h_holds⟩
    · exact Or.inr ⟨pat, h2, h_holds⟩
  · rintro (⟨pat, h_mem, h_holds⟩ | ⟨pat, h_mem, h_holds⟩)
    · exact ⟨pat, Or.inl h_mem, h_holds⟩
    · exact ⟨pat, Or.inr h_mem, h_holds⟩

/-! ## Translation: VEF1 to TL(U,S) (Proposition 3.5 Preview)

The key translation theorem (proved in Translation.lean): every VEF with
one free variable is equivalent to a TL(Until, Since) formula.

For an interval pattern with the free variable at position k among
witnesses x_0 < ... < x_n:
- Right: A_k AND (B_{k+1} Until (A_{k+1} AND (B_{k+2} Until ... (A_n AND Box B_{n+1})...)))
- Left: A_k AND (B_k Since (A_{k-1} AND (B_{k-1} Since ... (A_0 AND Henceforth-past B_0)...)))

This section provides the key translation function and its correctness proof.
-/

/-- Build the "right part" of the translation: from position k to the right end.
    Given witnesses at positions k, k+1, ..., n with interval types between them,
    builds: alpha_k AND (beta_{k+1} Until (alpha_{k+1} AND (beta_{k+2} Until ... ))) -/
def buildRight : List (TemporalPred × TemporalPred) → TemporalPred → Formula
  | [], rightmost_interval =>
    -- No more points to the right: G(beta_right) = not(F(not beta_right))
    -- G F = not(not_F Until True) = (not_F Until True) -> bot
    Formula.imp (Formula.untlQ Formula.top rightmost_interval.formula.neg) Formula.bot
  | (alpha, beta_before) :: rest, rightmost_interval =>
    -- beta_before Until (alpha AND buildRight rest rightmost_interval)
    -- "beta_before holds until we find a witness where alpha holds and the rest continues"
    Formula.untlQ beta_before.formula
        (Formula.and alpha.formula (buildRight rest rightmost_interval))

/-- Build the "left part" of the translation: from position k to the left end.
    Given witnesses at positions k, k-1, ..., 0 with interval types between them,
    builds: alpha_k AND (beta_k Since (alpha_{k-1} AND (beta_{k-1} Since ... ))) -/
def buildLeft : List (TemporalPred × TemporalPred) → TemporalPred → Formula
  | [], leftmost_interval =>
    -- No more points to the left: H(beta_left) = not(P(not beta_left))
    -- H F = not(not_F Since True) = (not_F Since True) -> bot
    Formula.imp (Formula.snceQ Formula.top leftmost_interval.formula.neg) Formula.bot
  | (alpha, beta_after) :: rest, leftmost_interval =>
    -- beta_after Since (alpha AND buildLeft rest leftmost_interval)
    -- "beta_after holds since we find a witness where alpha holds and the rest continues"
    Formula.snceQ beta_after.formula (Formula.and alpha.formula (buildLeft rest leftmost_interval))

/-- Translate a 1-variable exists-forall formula to a temporal formula.
    The free variable is at position `k` among `n+1` witness points.
    Returns a Formula that is equivalent to the EF formula on any structure. -/
noncomputable def translateEF1
    (n : Nat) (k : Fin (n + 1))
    (alpha : Fin (n + 1) → TemporalPred)
    (beta : Fin (n + 2) → TemporalPred) : Formula :=
  -- Build right list: (alpha_{k+1}, beta_{k+1}), ..., (alpha_n, beta_n)
  let rightPairs : List (TemporalPred × TemporalPred) :=
    (List.finRange (n - k.val)).map fun i =>
      let idx := k.val + 1 + i.val
      (alpha ⟨idx, by omega⟩, beta ⟨idx, by omega⟩)
  let rightmost := beta ⟨n + 1, by omega⟩
  -- Build left list: (alpha_{k-1}, beta_k), ..., (alpha_0, beta_1)
  let leftPairs : List (TemporalPred × TemporalPred) :=
    (List.finRange k.val).map fun i =>
      let idx := k.val - 1 - i.val
      (alpha ⟨idx, by omega⟩, beta ⟨idx + 1, by omega⟩)
  let leftmost := beta ⟨0, by omega⟩
  -- The translation is: alpha_k AND rightPart AND leftPart
  let rightPart := buildRight rightPairs rightmost
  let leftPart := buildLeft leftPairs leftmost
  Formula.and (alpha k).formula (Formula.and rightPart leftPart)

/-- Translate a disjunction of EF1 formulas to a temporal formula. -/
noncomputable def translateVEF1 (disjuncts : List Formula) : Formula :=
  match disjuncts with
  | [] => Formula.bot
  | [f] => f
  | f :: rest => Formula.or f (translateVEF1 rest)

end FormalSystem.Metalogic.WeakCanonical.Kamp
