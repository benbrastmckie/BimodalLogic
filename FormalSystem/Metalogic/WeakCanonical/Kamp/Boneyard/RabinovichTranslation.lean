import FormalSystem.Metalogic.WeakCanonical.Kamp.Translation

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# Rabinovich Translation (Proposition 3.5)

User-facing wrapper around the translation machinery in `Translation.lean`.
Defines a self-contained `ExistsForallSpec` type capturing the data of an
exists-forall formula with one free variable, and provides `future_chain`,
`past_chain`, and `rabinovich_translate` as the Proposition 3.5 translation.

## Main Definitions

- `ExistsForallSpec`: Specification of an exists-forall formula with one free
  variable at position `k` among `n+1` witness points.
- `ExistsForallSpec.future_chain`: The right (future) part of the translation:
  `A_k AND (B_{k+1} U (A_{k+1} AND (B_{k+2} U ... (A_n AND G(B_{n+1}))...)))`
- `ExistsForallSpec.past_chain`: The left (past) part of the translation:
  `A_k AND (B_k S (A_{k-1} AND (B_{k-1} S ... (A_0 AND H(B_0))...)))`
- `ExistsForallSpec.translate`: The full Rabinovich translation (conjunction of
  future and past chains, with `A_k` factored out).
- `ExistsForallSpec.semantic_spec`: The exists-forall semantic condition.

## Main Results

- `ExistsForallSpec.translate_forward`: If the semantic condition holds, the
  translation is true (soundness).
- `ExistsForallSpec.translate_backward`: If the translation is true, the
  semantic condition holds (completeness).
- `ExistsForallSpec.translate_correct`: Biconditional combining both directions.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Proposition 3.5
-/

#exit

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## ExistsForallSpec: User-facing specification type -/

/-- Specification of an exists-forall formula with one free variable.

An exists-forall formula describes an interval decomposition of a linear order:
existentially chosen witness points `x_0 < x_1 < ... < x_n` partition the order,
with "point type" formulas `A_i` required at each witness and "interval type"
formulas `B_j` required throughout each interval between consecutive witnesses.

The free variable `z_k` (our evaluation point `t`) sits at position `k` among
the witnesses: `x_0 < ... < x_{k-1} < t < x_{k+1} < ... < x_n`.

Fields:
- `n`: number of witness points minus 1 (so there are `n+1` witnesses total)
- `k`: position of the free variable (0 <= k <= n)
- `point_types`: `A_i` for `i = 0, ..., n` (type at each witness position)
- `interval_types`: `B_j` for `j = 0, ..., n+1` where
  - `B_0` is the type required everywhere before `x_0`
  - `B_j` (1 <= j <= n) is the type required in the interval `(x_{j-1}, x_j)`
  - `B_{n+1}` is the type required everywhere after `x_n`
-/
structure ExistsForallSpec where
  /-- Number of witness points minus 1 -/
  n : Nat
  /-- Position of the free variable among witnesses (0 <= k <= n) -/
  k : Fin (n + 1)
  /-- Point type formulas: `A_i` at each witness position `i` -/
  point_types : Fin (n + 1) -> TemporalPred
  /-- Interval type formulas: `B_j` for each segment `j` -/
  interval_types : Fin (n + 2) -> TemporalPred

/-! ## Future and Past Chains -/

/-- The future (right) chain of the Rabinovich translation.

Builds the nested Until formula from position `k` going rightward:
```
B_{k+1} U (A_{k+1} AND (B_{k+2} U (... (A_n AND G(B_{n+1}))...)))
```

This asserts: there exist future witnesses `x_{k+1} < ... < x_n` with the
correct point types and interval types between them, and `B_{n+1}` holds
everywhere after `x_n`.
-/
def ExistsForallSpec.future_chain (spec : ExistsForallSpec) : Formula :=
  let rightPairs : List (TemporalPred × TemporalPred) :=
    (List.finRange (spec.n - spec.k.val)).map fun i =>
      let idx := spec.k.val + 1 + i.val
      (spec.point_types ⟨idx, by omega⟩, spec.interval_types ⟨idx, by omega⟩)
  let rightmost := spec.interval_types ⟨spec.n + 1, by omega⟩
  buildRight rightPairs rightmost

/-- The past (left) chain of the Rabinovich translation.

Builds the nested Since formula from position `k` going leftward:
```
B_k S (A_{k-1} AND (B_{k-1} S (... (A_0 AND H(B_0))...)))
```

This asserts: there exist past witnesses `x_{k-1} > ... > x_0` with the
correct point types and interval types between them, and `B_0` holds
everywhere before `x_0`.
-/
def ExistsForallSpec.past_chain (spec : ExistsForallSpec) : Formula :=
  let leftPairs : List (TemporalPred × TemporalPred) :=
    (List.finRange spec.k.val).map fun i =>
      let idx := spec.k.val - 1 - i.val
      (spec.point_types ⟨idx, by omega⟩, spec.interval_types ⟨idx + 1, by omega⟩)
  let leftmost := spec.interval_types ⟨0, by omega⟩
  buildLeft leftPairs leftmost

/-- The full Rabinovich translation (Proposition 3.5).

Translates an exists-forall formula with one free variable to a
TL(Until, Since) formula:
```
A_k AND future_chain AND past_chain
```

where `A_k` is the point type at the free variable position, `future_chain`
handles witnesses to the right, and `past_chain` handles witnesses to the left.

This is exactly `translateEF1` from `Translation.lean`, wrapped in a
user-friendly interface.
-/
def ExistsForallSpec.translate (spec : ExistsForallSpec) : Formula :=
  Formula.and (spec.point_types spec.k).formula
    (Formula.and spec.future_chain spec.past_chain)

/-- The translation equals `translateEF1` applied to the spec's components. -/
theorem ExistsForallSpec.translate_eq_translateEF1 (spec : ExistsForallSpec) :
    spec.translate = translateEF1 spec.n spec.k spec.point_types spec.interval_types := by
  rfl

/-! ## Semantic Specification -/

/-- The semantic condition captured by the exists-forall formula.

At a point `t`, the exists-forall condition holds iff:
- `A_k` holds at `t` (the point type at the free variable position)
- There exist future witnesses `x_{k+1} < ... < x_n` (all > t) with correct types
- There exist past witnesses `x_{k-1} > ... > x_0` (all < t) with correct types
- Interval types hold throughout each segment

This decomposes into three parts matching the translation structure.
-/
def ExistsForallSpec.semantic_spec {sig : MonadicSignature}
    (spec : ExistsForallSpec)
    (M : OrderedMonadicStructure sig) (atomMap : Formula -> sig.preds)
    (t : M.carrier) : Prop :=
  (spec.point_types spec.k).eval_at M atomMap t ∧
  buildRight_spec M atomMap
    ((List.finRange (spec.n - spec.k.val)).map fun i =>
      let idx := spec.k.val + 1 + i.val
      (spec.point_types ⟨idx, by omega⟩, spec.interval_types ⟨idx, by omega⟩))
    (spec.interval_types ⟨spec.n + 1, by omega⟩) t ∧
  buildLeft_spec M atomMap
    ((List.finRange spec.k.val).map fun i =>
      let idx := spec.k.val - 1 - i.val
      (spec.point_types ⟨idx, by omega⟩, spec.interval_types ⟨idx + 1, by omega⟩))
    (spec.interval_types ⟨0, by omega⟩) t

/-! ## Correctness Theorems -/

/-- Forward direction (soundness): if the semantic condition holds,
then the Rabinovich translation is true at `t`.

This is the easy direction: the nested Until chain witnesses are exactly
the existential witnesses from the semantic condition. -/
theorem ExistsForallSpec.translate_forward {sig : MonadicSignature}
    (spec : ExistsForallSpec)
    (M : OrderedMonadicStructure sig) (atomMap : Formula -> sig.preds)
    (t : M.carrier)
    (h : spec.semantic_spec M atomMap t) :
    temporal_truth M atomMap t spec.translate := by
  rw [translate_eq_translateEF1]
  exact (translateEF1_correct M atomMap spec.n spec.k
    spec.point_types spec.interval_types t).mpr h

/-- Backward direction (completeness): if the Rabinovich translation is true
at `t`, then the semantic condition holds.

This uses the Until/Since semantics to extract the existential witnesses
from the nested temporal formula. -/
theorem ExistsForallSpec.translate_backward {sig : MonadicSignature}
    (spec : ExistsForallSpec)
    (M : OrderedMonadicStructure sig) (atomMap : Formula -> sig.preds)
    (t : M.carrier)
    (h : temporal_truth M atomMap t spec.translate) :
    spec.semantic_spec M atomMap t := by
  rw [translate_eq_translateEF1] at h
  exact (translateEF1_correct M atomMap spec.n spec.k
    spec.point_types spec.interval_types t).mp h

/-- Biconditional correctness: the Rabinovich translation is true at `t`
if and only if the semantic condition holds.

This is Rabinovich 2014 Proposition 3.5: every exists-forall formula with
one free variable is equivalent to a TL(Until, Since) formula. -/
theorem ExistsForallSpec.translate_correct {sig : MonadicSignature}
    (spec : ExistsForallSpec)
    (M : OrderedMonadicStructure sig) (atomMap : Formula -> sig.preds)
    (t : M.carrier) :
    temporal_truth M atomMap t spec.translate ↔
    spec.semantic_spec M atomMap t := by
  rw [translate_eq_translateEF1]
  exact translateEF1_correct M atomMap spec.n spec.k
    spec.point_types spec.interval_types t

/-! ## Convenience Constructors -/

/-- Create a spec where the free variable is at the leftmost position (k = 0).
In this case there is no past chain (no witnesses to the left), only a
future chain and the requirement that `B_0` held everywhere in the past. -/
def ExistsForallSpec.mk_leftmost (n : Nat)
    (point_types : Fin (n + 1) -> TemporalPred)
    (interval_types : Fin (n + 2) -> TemporalPred) :
    ExistsForallSpec :=
  { n := n
    k := ⟨0, by omega⟩
    point_types := point_types
    interval_types := interval_types }

/-- Create a spec where the free variable is at the rightmost position (k = n).
In this case there is no future chain (no witnesses to the right), only a
past chain and the requirement that `B_{n+1}` holds everywhere in the future. -/
def ExistsForallSpec.mk_rightmost (n : Nat)
    (point_types : Fin (n + 1) -> TemporalPred)
    (interval_types : Fin (n + 2) -> TemporalPred) :
    ExistsForallSpec :=
  { n := n
    k := ⟨n, by omega⟩
    point_types := point_types
    interval_types := interval_types }

/-! ## Simple Case: Single Witness

For the common case of a single existential witness (n = 0, the free variable
is the only point), the translation simplifies to:
```
A_0 AND G(B_1) AND H(B_0)
```
meaning: `A_0` holds at `t`, `B_1` holds at all future times, and `B_0` holds
at all past times. -/

/-- A single-point spec: just the free variable, no other witnesses.
The translation is `A_0 AND G(B_1) AND H(B_0)`. -/
def ExistsForallSpec.mk_single
    (point_type : TemporalPred)
    (past_interval : TemporalPred)
    (future_interval : TemporalPred) :
    ExistsForallSpec :=
  { n := 0
    k := ⟨0, by omega⟩
    point_types := fun _ => point_type
    interval_types := fun i =>
      if i.val = 0 then past_interval else future_interval }

/-- The future chain of a single-point spec is `G(B_1)` (all future B_1). -/
theorem ExistsForallSpec.future_chain_single
    (pt : TemporalPred) (past_int future_int : TemporalPred) :
    (mk_single pt past_int future_int).future_chain =
    buildRight [] future_int := by
  simp [future_chain, mk_single, List.finRange]

/-- The past chain of a single-point spec is `H(B_0)` (all past B_0). -/
theorem ExistsForallSpec.past_chain_single
    (pt : TemporalPred) (past_int future_int : TemporalPred) :
    (mk_single pt past_int future_int).past_chain =
    buildLeft [] past_int := by
  simp [past_chain, mk_single, List.finRange]

/-! ## Disjunction of Exists-Forall Formulas

A V-exists-forall formula (Rabinovich Def 3.3) is a disjunction of
exists-forall formulas. We provide a simple wrapper. -/

/-- Translate a list of ExistsForallSpecs to a single disjunctive formula. -/
noncomputable def translateSpecs (specs : List ExistsForallSpec) : Formula :=
  translateVEF1 (specs.map fun s => s.translate)

/-- Correctness of `translateSpecs`: the disjunction holds iff some spec's
semantic condition holds. -/
theorem translateSpecs_correct {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula -> sig.preds)
    (specs : List ExistsForallSpec)
    (t : M.carrier) :
    temporal_truth M atomMap t (translateSpecs specs) ↔
    ∃ spec ∈ specs, spec.semantic_spec M atomMap t := by
  simp only [translateSpecs]
  rw [translateVEF1_correct]
  constructor
  · rintro ⟨f, hf_mem, hf⟩
    rw [List.mem_map] at hf_mem
    obtain ⟨spec, h_spec_mem, rfl⟩ := hf_mem
    exact ⟨spec, h_spec_mem, spec.translate_backward M atomMap t hf⟩
  · rintro ⟨spec, h_spec_mem, h_sem⟩
    have hmem : spec.translate ∈ List.map (fun s => s.translate) specs :=
      List.mem_map_of_mem (f := fun s => s.translate) h_spec_mem
    exact ⟨spec.translate, hmem, spec.translate_forward M atomMap t h_sem⟩

end Bimodal.Metalogic.WeakCanonical.Kamp
