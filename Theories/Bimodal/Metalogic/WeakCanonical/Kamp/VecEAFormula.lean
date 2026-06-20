import Bimodal.Metalogic.WeakCanonical.Kamp.ExistsForallNF

/-!
# Vec-EA Formula Type (Rabinovich 2014, Definition 3.1)

Defines the vec-EA (exists-forall) formula type and bracket notation following
Rabinovich 2014. This extends the interval decomposition infrastructure in
`ExistsForallNF.lean` with:

1. **`VecEAFormula`**: An exists-forall formula with `n` existential witnesses
   and `m` free variables, encoding witness ordering constraints, point-type
   predicates at each witness, and interval-type predicates along sub-intervals.
   This corresponds to Rabinovich Def 3.1.

2. **`BracketFormula`**: The bracket notation `[alpha_0, beta_1, ..., beta_n,
   alpha_n](z_0, z_1)` from Notation 5.2 — an interval formula with `n`
   interior witnesses between two free-variable endpoints `z_0 < z_1`.

3. **Semantic evaluation** and correspondence with the existing `IntervalPattern`
   and `VEF` types.

## Design Decisions

- `VecEAFormula` is parameterized by the number of free variables `m` and
  witnesses `n`. It stores an ordering permutation that specifies where each
  free variable sits among the witnesses in the total order.

- `BracketFormula` specializes to `m = 2` free variables at the endpoints,
  matching the 2-free-variable case central to Prop 4.2.

- We reuse `TemporalPred` from `ExistsForallNF.lean` for point and interval
  types, maintaining consistency with the existing Translation.lean machinery.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Definition 3.1, Notation 5.2
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## Vec-EA Formula Type (Definition 3.1)

A vec-EA formula describes an interval decomposition of a linearly ordered
structure. It has:
- `m` free variables (the "z" variables from the paper)
- `n` existential witness variables (the "x" variables)
- A total ordering that interleaves all `m + n` variables
- Point-type predicates at each witness
- Interval-type predicates on each segment between consecutive elements

For the Kamp theorem proof, we primarily use the 2-free-variable case (m = 2)
where z_0 and z_1 are the interval endpoints. The general case is needed for
Lemma 3.2 (reduction to at most 2 free variables).

### Ordering Representation

The `m` free variables and `n` witnesses are arranged in a total order. We
represent this by specifying a function `free_pos : Fin m → Fin (m + n)` that
maps each free variable to its position in the combined sequence. The remaining
positions are filled by witnesses in order.

For the 2-free-variable bracket case, free_pos maps z_0 to position 0 and
z_1 to position m + n - 1 (the endpoints).
-/

/-- Position assignment for free variables among the combined sequence of
    `m` free variables and `n` witnesses. Specifies where each free variable
    sits in the total ordering. -/
structure FreeVarPositions (m n : Nat) where
  /-- Position of each free variable in the combined sequence of length m + n.
      Must be strictly monotone (preserves the ordering of free variables). -/
  pos : Fin m → Fin (m + n)
  /-- The position assignment is strictly monotone. -/
  pos_strictMono : StrictMono pos
  /-- Positions are pairwise distinct (implied by strict monotonicity, but
      convenient to have directly). -/
  pos_injective : Function.Injective pos := pos_strictMono.injective

/-- A vec-EA formula (Rabinovich Def 3.1) with `m` free variables and `n`
    existential witnesses. The combined sequence has `m + n` elements in
    total order. Point types are specified at each witness position, and
    interval types on each segment between consecutive elements.

    The `m + n` positions in the total order consist of `m` free-variable
    positions (given by `free_pos`) and `n` witness positions (the complement).
    There are `m + n - 1` segments between consecutive elements (or 0 if m + n = 0),
    plus the unbounded segments before the first and after the last element.

    For the bounded interval case (bracket notation), the first and last
    positions are free variables (z_0 and z_1), and the interval types on the
    "unbounded" segments are vacuous (replaced by the interval endpoints). -/
structure VecEAFormula (m n : Nat) where
  /-- Positions of free variables in the combined ordering -/
  freePos : FreeVarPositions m n
  /-- Point types at each of the `n` witness positions.
      Witness `i` (0-indexed) corresponds to the `i`-th non-free position
      in the combined ordering. -/
  witnessTypes : Fin n → TemporalPred
  /-- Interval types on segments. There are `m + n + 1` segments:
      segment 0 is before position 0, segment `i` (1 <= i <= m+n-1) is between
      positions `i-1` and `i`, and segment `m + n` is after the last position.
      Each segment has a type that must hold at all interior points. -/
  segmentTypes : Fin (m + n + 1) → TemporalPred

/-! ## Bracket Formula (Notation 5.2)

The bracket notation `[alpha_0, beta_1, alpha_1, ..., beta_n, alpha_n](z_0, z_1)`
represents a vec-EA formula with:
- `m = 2` free variables (z_0 at position 0, z_1 at position n + 1)
- `n` witnesses (x_0, ..., x_{n-1}) at positions 1, ..., n
- Point type alpha_i at witness x_i
- Interval type beta_0 on (z_0, x_0), beta_i on (x_{i-1}, x_i), beta_n on (x_{n-1}, z_1)

This is precisely `IntervalPattern n` from ExistsForallNF.lean, evaluated on
an interval (z_0, z_1). We define `BracketFormula` as a wrapper that makes
the connection to Notation 5.2 explicit, and prove it equivalent to
`IntervalPattern.holds`.
-/

/-- A bracket formula `[alpha_0, beta_1, alpha_1, ..., beta_n, alpha_n](z_0, z_1)`
    with `n` interior witness points. This is the 2-free-variable specialization
    of `VecEAFormula` where z_0 and z_1 are the endpoints.

    Equivalent to `IntervalPattern n` from ExistsForallNF.lean. -/
structure BracketFormula (n : Nat) where
  /-- Point types at each witness: alpha_0, ..., alpha_{n-1} -/
  pointTypes : Fin n → TemporalPred
  /-- Interval types on segments: beta_0 on (z_0, x_0), ..., beta_n on (x_{n-1}, z_1) -/
  segmentTypes : Fin (n + 1) → TemporalPred

/-- Convert a `BracketFormula` to an `IntervalPattern`. -/
def BracketFormula.toIntervalPattern {n : Nat} (bf : BracketFormula n) :
    IntervalPattern n :=
  { alpha := bf.pointTypes
    beta := bf.segmentTypes }

/-- Convert an `IntervalPattern` to a `BracketFormula`. -/
def IntervalPattern.toBracketFormula {n : Nat} (ip : IntervalPattern n) :
    BracketFormula n :=
  { pointTypes := ip.alpha
    segmentTypes := ip.beta }

/-- The conversion between `BracketFormula` and `IntervalPattern` is an inverse. -/
theorem BracketFormula.toIntervalPattern_toBracketFormula {n : Nat}
    (bf : BracketFormula n) :
    bf.toIntervalPattern.toBracketFormula = bf := by
  simp [toIntervalPattern, IntervalPattern.toBracketFormula]

/-- The conversion between `IntervalPattern` and `BracketFormula` is an inverse. -/
theorem IntervalPattern.toBracketFormula_toIntervalPattern {n : Nat}
    (ip : IntervalPattern n) :
    ip.toBracketFormula.toIntervalPattern = ip := by
  simp [toBracketFormula, BracketFormula.toIntervalPattern]

/-! ## Semantic Evaluation -/

/-- Evaluate a bracket formula on an interval `(z_0, z_1)`. This holds iff
    there exist strictly increasing witnesses `x_0 < ... < x_{n-1}` in
    `(z_0, z_1)` such that point types hold at witnesses and interval types
    hold on all segments.

    Defined via the corresponding `IntervalPattern.holds`. -/
def BracketFormula.holds {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf : BracketFormula n) (z0 z1 : M.carrier) : Prop :=
  bf.toIntervalPattern.holds M atomMap z0 z1

/-- `BracketFormula.holds` is definitionally equal to `IntervalPattern.holds`
    via the conversion. -/
theorem BracketFormula.holds_eq_intervalPattern_holds {sig : MonadicSignature}
    {n : Nat} (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) (bf : BracketFormula n)
    (z0 z1 : M.carrier) :
    bf.holds M atomMap z0 z1 = bf.toIntervalPattern.holds M atomMap z0 z1 :=
  rfl

/-! ## V-EA Formulas (Disjunctions of Bracket Formulas)

A V-EA formula (Rabinovich Def 3.3) is a disjunction of exists-forall formulas.
For the 2-free-variable case, this is a disjunction of bracket formulas.
The existing `VEF` type already captures this; we provide the bracket-formula
view and verify equivalence. -/

/-- A V-bracket formula: a disjunction of bracket formulas, each potentially
    with a different number of witnesses. Equivalent to `VEF`. -/
structure VBracketFormula where
  /-- The list of bracket formula disjuncts -/
  disjuncts : List (Σ n, BracketFormula n)

/-- A V-bracket formula holds on `(z_0, z_1)` if some disjunct holds. -/
def VBracketFormula.holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v : VBracketFormula) (z0 z1 : M.carrier) : Prop :=
  ∃ bf ∈ v.disjuncts, bf.2.holds M atomMap z0 z1

/-- Convert a `VBracketFormula` to a `VEF`. -/
def VBracketFormula.toVEF (v : VBracketFormula) : VEF :=
  { patterns := v.disjuncts.map (fun ⟨n, bf⟩ => ⟨n, bf.toIntervalPattern⟩) }

/-- Convert a `VEF` to a `VBracketFormula`. -/
def VEF.toVBracketFormula (v : VEF) : VBracketFormula :=
  { disjuncts := v.patterns.map (fun ⟨n, ip⟩ => ⟨n, ip.toBracketFormula⟩) }

/-- The semantics of `VBracketFormula` agrees with `VEF` via conversion. -/
theorem VBracketFormula.holds_iff_vef_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v : VBracketFormula) (z0 z1 : M.carrier) :
    v.holds M atomMap z0 z1 ↔ v.toVEF.holds M atomMap z0 z1 := by
  simp only [holds, VEF.holds, toVEF]
  constructor
  · rintro ⟨⟨n, bf⟩, h_mem, h_holds⟩
    refine ⟨⟨n, bf.toIntervalPattern⟩, ?_, h_holds⟩
    exact List.mem_map.mpr ⟨⟨n, bf⟩, h_mem, rfl⟩
  · rintro ⟨pat, h_mem, h_holds⟩
    rw [List.mem_map] at h_mem
    obtain ⟨⟨n, bf⟩, h_mem', rfl⟩ := h_mem
    exact ⟨⟨n, bf⟩, h_mem', h_holds⟩

/-- V-bracket formulas are closed under disjunction. -/
def VBracketFormula.disj (v1 v2 : VBracketFormula) : VBracketFormula :=
  { disjuncts := v1.disjuncts ++ v2.disjuncts }

/-- Disjunction semantics for V-bracket formulas. -/
theorem VBracketFormula.disj_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v1 v2 : VBracketFormula) (z0 z1 : M.carrier) :
    (v1.disj v2).holds M atomMap z0 z1 ↔
    v1.holds M atomMap z0 z1 ∨ v2.holds M atomMap z0 z1 := by
  simp only [holds, disj, List.mem_append]
  constructor
  · rintro ⟨bf, h_mem, h_holds⟩
    rcases h_mem with h1 | h2
    · exact Or.inl ⟨bf, h1, h_holds⟩
    · exact Or.inr ⟨bf, h2, h_holds⟩
  · rintro (⟨bf, h_mem, h_holds⟩ | ⟨bf, h_mem, h_holds⟩)
    · exact ⟨bf, Or.inl h_mem, h_holds⟩
    · exact ⟨bf, Or.inr h_mem, h_holds⟩

/-! ## Endpoint Predicates for Vec-EA Formulas

A full vec-EA formula with 2 free variables decomposes as:
  `psi_0(z_0) AND psi_1(z_1) AND [alpha_0, ..., alpha_n](z_0, z_1)`
where `psi_0` and `psi_1` are point-type predicates at the endpoints.
This decomposition is needed for Prop 4.2 (negation closure). -/

/-- A vec-EA formula with 2 free variables, decomposed into endpoint predicates
    and an interval (bracket) formula. This is the canonical form for Prop 4.2:
    `psi_0(z_0) AND psi_1(z_1) AND bracket(z_0, z_1)`. -/
structure VecEA2 (n : Nat) where
  /-- Endpoint type at z_0 -/
  endpointLeft : TemporalPred
  /-- Endpoint type at z_1 -/
  endpointRight : TemporalPred
  /-- The interval bracket formula between z_0 and z_1 -/
  bracket : BracketFormula n

/-- Semantics of a 2-free-variable vec-EA formula:
    `endpointLeft(z_0) AND endpointRight(z_1) AND bracket(z_0, z_1)`. -/
def VecEA2.holds {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (vea : VecEA2 n) (z0 z1 : M.carrier) : Prop :=
  vea.endpointLeft.eval_at M atomMap z0 ∧
  vea.endpointRight.eval_at M atomMap z1 ∧
  vea.bracket.holds M atomMap z0 z1

/-- A V-vec-EA-2 formula: disjunction of `VecEA2` formulas with varying
    witness counts. -/
structure VVecEA2 where
  /-- The disjuncts -/
  disjuncts : List (Σ n, VecEA2 n)

/-- Semantics of a V-vec-EA-2 formula. -/
def VVecEA2.holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v : VVecEA2) (z0 z1 : M.carrier) : Prop :=
  ∃ vea ∈ v.disjuncts, vea.2.holds M atomMap z0 z1

/-- V-vec-EA-2 is closed under disjunction. -/
def VVecEA2.disj (v1 v2 : VVecEA2) : VVecEA2 :=
  { disjuncts := v1.disjuncts ++ v2.disjuncts }

/-- Disjunction semantics for V-vec-EA-2. -/
theorem VVecEA2.disj_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v1 v2 : VVecEA2) (z0 z1 : M.carrier) :
    (v1.disj v2).holds M atomMap z0 z1 ↔
    v1.holds M atomMap z0 z1 ∨ v2.holds M atomMap z0 z1 := by
  simp only [holds, disj, List.mem_append]
  constructor
  · rintro ⟨vea, h_mem, h_holds⟩
    rcases h_mem with h1 | h2
    · exact Or.inl ⟨vea, h1, h_holds⟩
    · exact Or.inr ⟨vea, h2, h_holds⟩
  · rintro (⟨vea, h_mem, h_holds⟩ | ⟨vea, h_mem, h_holds⟩)
    · exact ⟨vea, Or.inl h_mem, h_holds⟩
    · exact ⟨vea, Or.inr h_mem, h_holds⟩

/-! ## Constructors and Convenience Functions -/

/-- Construct a bracket formula with no witnesses (n = 0): just an interval
    type that must hold everywhere in (z_0, z_1). -/
def BracketFormula.trivial (segType : TemporalPred) : BracketFormula 0 :=
  { pointTypes := Fin.elim0
    segmentTypes := fun _ => segType }

/-- A bracket formula with no witnesses holds iff the segment type holds
    everywhere in the open interval. -/
theorem BracketFormula.trivial_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (segType : TemporalPred) (z0 z1 : M.carrier) :
    (BracketFormula.trivial segType).holds M atomMap z0 z1 ↔
    ∀ y : M.carrier, z0 < y → y < z1 → segType.eval_at M atomMap y := by
  simp only [holds, toIntervalPattern, IntervalPattern.holds, trivial]

/-- Construct a bracket formula with a single witness (n = 1):
    `[alpha_0, beta_0, beta_1](z_0, z_1)` meaning there exists x in (z_0, z_1)
    with alpha_0(x), beta_0 on (z_0, x), beta_1 on (x, z_1). -/
def BracketFormula.single (pointType : TemporalPred)
    (segLeft segRight : TemporalPred) : BracketFormula 1 :=
  { pointTypes := fun _ => pointType
    segmentTypes := fun i => if i.val = 0 then segLeft else segRight }

/-- A VecEA2 with no witnesses and trivial endpoint predicates is equivalent
    to a pure interval predicate. -/
def VecEA2.fromBracket {n : Nat} (bf : BracketFormula n) : VecEA2 n :=
  { endpointLeft := TemporalPred.top
    endpointRight := TemporalPred.top
    bracket := bf }

/-- When endpoints are `top`, VecEA2 semantics reduces to bracket semantics. -/
theorem VecEA2.fromBracket_holds {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf : BracketFormula n) (z0 z1 : M.carrier) :
    (VecEA2.fromBracket bf).holds M atomMap z0 z1 ↔
    bf.holds M atomMap z0 z1 := by
  simp only [fromBracket, holds, TemporalPred.eval_at, TemporalPred.top]
  simp only [Formula.top, temporal_truth]
  tauto

/-! ## Interval Splitting Infrastructure (Rabinovich p.10)

The A_i^- / A_i^+ decomposition: given a bracket formula with n+1 witnesses
and a split point at witness i, we extract:
- `leftPart`: the sub-bracket [alpha_0, beta_1, ..., beta_i](z_0, x_i) with i witnesses
- `rightPart`: the sub-bracket [beta_{i+1}, ..., beta_{n+1}, alpha_n](x_i, z_1) with n-i witnesses

These are the foundational operations needed by Lemma 5.1 (negation closure). -/

/-- A bracket formula with 0 witnesses (degenerate interval, no interior points).
    Equivalent to `BracketFormula.trivial` but named to match the Rabinovich convention. -/
def BracketFormula.empty (segType : TemporalPred) : BracketFormula 0 :=
  BracketFormula.trivial segType

/-- Extract the left sub-bracket A_i^-(z_0, z) from a bracket formula with n+1 witnesses,
    splitting at witness i. The left part has i witnesses (x_0, ..., x_{i-1}).
    Point types and segment types are the initial segments of the original. -/
def BracketFormula.leftPart {n : Nat} (bf : BracketFormula (n + 1))
    (i : Fin (n + 1)) : BracketFormula i.val :=
  { pointTypes := fun j => bf.pointTypes ⟨j.val, by omega⟩
    segmentTypes := fun j => bf.segmentTypes ⟨j.val, by omega⟩ }

/-- Extract the right sub-bracket A_i^+(z, z_1) from a bracket formula with n+1 witnesses,
    splitting at witness i. The right part has n-i witnesses (x_{i+1}, ..., x_n).
    Point types and segment types are shifted by i+1 from the original. -/
def BracketFormula.rightPart {n : Nat} (bf : BracketFormula (n + 1))
    (i : Fin (n + 1)) : BracketFormula (n - i.val) :=
  { pointTypes := fun j => bf.pointTypes ⟨i.val + 1 + j.val, by omega⟩
    segmentTypes := fun j => bf.segmentTypes ⟨i.val + 1 + j.val, by omega⟩ }

/-- If a bracket formula holds on (z_0, z_1) with witnesses w, then the left part
    holds on (z_0, w i). This is the semantic correctness of A_i^-(z_0, z). -/
theorem BracketFormula.leftPart_holds {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf : BracketFormula (n + 1)) (z0 z1 : M.carrier)
    (i : Fin (n + 1))
    (witnesses : Fin (n + 1) → M.carrier)
    (hmono : ∀ a b : Fin (n + 1), a < b → witnesses a < witnesses b)
    (hrange : ∀ j : Fin (n + 1), z0 < witnesses j ∧ witnesses j < z1)
    (hpoint : ∀ j : Fin (n + 1), (bf.pointTypes j).eval_at M atomMap (witnesses j))
    (hseg0 : ∀ y, z0 < y → y < witnesses ⟨0, by omega⟩ →
      (bf.segmentTypes ⟨0, by omega⟩).eval_at M atomMap y)
    (hsegmid : ∀ (j : Fin n), ∀ y,
      witnesses ⟨j.val, by omega⟩ < y → y < witnesses ⟨j.val + 1, by omega⟩ →
      (bf.segmentTypes ⟨j.val + 1, by omega⟩).eval_at M atomMap y)
    (hsegn : ∀ y, witnesses ⟨n, by omega⟩ < y → y < z1 →
      (bf.segmentTypes ⟨n + 1, by omega⟩).eval_at M atomMap y) :
    (bf.leftPart i).holds M atomMap z0 (witnesses i) := by
  simp only [holds, toIntervalPattern, leftPart, IntervalPattern.holds]
  match i with
  | ⟨0, _⟩ =>
    -- Left part has 0 witnesses: need beta_0 on (z0, w 0)
    intro y hy0 hy1
    exact hseg0 y hy0 hy1
  | ⟨k + 1, hk⟩ =>
    -- Left part has k+1 witnesses: use w 0, ..., w k
    refine ⟨fun j => witnesses ⟨j.val, by omega⟩, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · intro a b hab
      exact hmono ⟨a.val, by omega⟩ ⟨b.val, by omega⟩ (by simpa using hab)
    · intro j
      exact ⟨(hrange ⟨j.val, by omega⟩).1,
        hmono ⟨j.val, by omega⟩ ⟨k + 1, by omega⟩ (by simp [Fin.lt_iff_val_lt_val])⟩
    · intro j; exact hpoint ⟨j.val, by omega⟩
    · intro y hy0 hy1; exact hseg0 y hy0 hy1
    · intro j y hlo hhi; exact hsegmid ⟨j.val, by omega⟩ y hlo hhi
    · intro y hlo hhi; exact hsegmid ⟨k, by omega⟩ y hlo hhi

/-- If a bracket formula holds on (z_0, z_1) with witnesses w, then the right part
    holds on (w i, z_1). This is the semantic correctness of A_i^+(z, z_1). -/
theorem BracketFormula.rightPart_holds {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf : BracketFormula (n + 1)) (z0 z1 : M.carrier)
    (i : Fin (n + 1))
    (witnesses : Fin (n + 1) → M.carrier)
    (hmono : ∀ a b : Fin (n + 1), a < b → witnesses a < witnesses b)
    (hrange : ∀ j : Fin (n + 1), z0 < witnesses j ∧ witnesses j < z1)
    (hpoint : ∀ j : Fin (n + 1), (bf.pointTypes j).eval_at M atomMap (witnesses j))
    (hseg0 : ∀ y, z0 < y → y < witnesses ⟨0, by omega⟩ →
      (bf.segmentTypes ⟨0, by omega⟩).eval_at M atomMap y)
    (hsegmid : ∀ (j : Fin n), ∀ y,
      witnesses ⟨j.val, by omega⟩ < y → y < witnesses ⟨j.val + 1, by omega⟩ →
      (bf.segmentTypes ⟨j.val + 1, by omega⟩).eval_at M atomMap y)
    (hsegn : ∀ y, witnesses ⟨n, by omega⟩ < y → y < z1 →
      (bf.segmentTypes ⟨n + 1, by omega⟩).eval_at M atomMap y) :
    (bf.rightPart i).holds M atomMap (witnesses i) z1 := by
  -- Rewrite as IntervalPattern.holds on the rightPart pattern
  simp only [holds, toIntervalPattern, rightPart]
  -- The witness count is n - i.val. We generalize it to allow the match to reduce.
  -- Key technique: revert hypotheses, generalize n - i.val, then intro back.
  have hle : i.val ≤ n := Nat.lt_succ_iff.mp i.isLt
  -- We use Nat.sub_eq_zero_iff_le and case analysis
  rcases eq_or_lt_of_le hle with hi_eq | hi_lt
  · -- i.val = n → n - i.val = 0
    have h0 : n - i.val = 0 := by omega
    rw [IntervalPattern.holds_eq_zero (h := h0)]
    intro y hy_lo hy_hi
    have hwi : witnesses i = witnesses ⟨n, by omega⟩ := by congr 1; ext; exact hi_eq
    rw [hwi] at hy_lo
    convert hsegn y hy_lo hy_hi using 3; simp [Fin.ext_iff]; omega
  · -- i.val < n → n - i.val ≥ 1
    have hni_pos : 0 < n - i.val := Nat.sub_pos_of_lt hi_lt
    obtain ⟨k, hk⟩ : ∃ k, n - i.val = k + 1 := ⟨n - i.val - 1, by omega⟩
    -- Now we need to show IntervalPattern.holds for an IntervalPattern (n - i.val)
    -- where n - i.val = k + 1. We use holds_eq_succ.
    rw [IntervalPattern.holds_eq_succ (h := hk)]
    refine ⟨fun j => witnesses ⟨i.val + 1 + j.val, by omega⟩, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · intro a b hab; dsimp only
      exact hmono ⟨i.val + 1 + a.val, by omega⟩ ⟨i.val + 1 + b.val, by omega⟩
        (Fin.mk_lt_mk.mpr (by omega))
    · intro j; dsimp only
      exact ⟨hmono ⟨i.val, by omega⟩ ⟨i.val + 1 + j.val, by omega⟩
        (Fin.mk_lt_mk.mpr (by omega)),
             (hrange ⟨i.val + 1 + j.val, by omega⟩).2⟩
    · intro j; dsimp only; exact hpoint ⟨i.val + 1 + j.val, by omega⟩
    · intro y hy_lo hy_hi; dsimp only at hy_hi ⊢
      exact hsegmid ⟨i.val, by omega⟩ y hy_lo hy_hi
    · intro j y hy_lo hy_hi; dsimp only at hy_lo hy_hi ⊢
      exact hsegmid ⟨i.val + 1 + j.val, by omega⟩ y hy_lo hy_hi
    · intro y hy_lo hy_hi; dsimp only at hy_lo ⊢
      have hiv : i.val + 1 + k = n := by omega
      have hfin : (⟨i.val + 1 + k, by omega⟩ : Fin (n + 1)) = ⟨n, by omega⟩ := by
        ext; exact hiv
      rw [hfin] at hy_lo
      have hsv : i.val + 1 + (k + 1) = n + 1 := by omega
      have hsf : (⟨i.val + 1 + (k + 1), by omega⟩ : Fin (n + 2)) = ⟨n + 1, by omega⟩ := by
        ext; exact hsv
      show TemporalPred.eval_at M atomMap (bf.segmentTypes ⟨i.val + 1 + (k + 1), _⟩) y
      rw [show bf.segmentTypes ⟨i.val + 1 + (k + 1), _⟩ =
              bf.segmentTypes ⟨n + 1, _⟩ from by rw [hsf]]
      exact hsegn y hy_lo hy_hi

/-- If the left part holds on (z_0, z), the right part holds on (z, z_1), and the
    point type at index i holds at z, then the original bracket formula holds on
    (z_0, z_1) with z inserted as witness i. This is the combination direction
    of the interval splitting decomposition. -/
theorem BracketFormula.splitAt_combine {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf : BracketFormula (n + 1)) (z0 z1 z : M.carrier)
    (i : Fin (n + 1))
    (hz0z : z0 < z) (hzz1 : z < z1)
    (hpt : (bf.pointTypes i).eval_at M atomMap z)
    (hleft : (bf.leftPart i).holds M atomMap z0 z)
    (hright : (bf.rightPart i).holds M atomMap z z1) :
    bf.holds M atomMap z0 z1 := by
  simp only [holds, toIntervalPattern]
  simp only [holds, toIntervalPattern, leftPart] at hleft
  simp only [holds, toIntervalPattern, rightPart] at hright
  have hi_le : i.val ≤ n := Nat.lt_succ_iff.mp i.isLt
  rcases Nat.eq_or_lt_of_le (Nat.zero_le i.val) with hi0 | hi_pos
  · rw [IntervalPattern.holds_eq_zero (h := hi0.symm)] at hleft
    rcases Nat.eq_or_lt_of_le (Nat.zero_le n) with hn0 | hn_pos
    · rw [IntervalPattern.holds_eq_zero (h := by omega)] at hright
      refine ⟨fun _ => z, ?_, ?_, ?_, ?_, ?_, ?_⟩
      · intro a b hab; exact absurd hab (by omega)
      · intro _; exact ⟨hz0z, hzz1⟩
      · intro j
        have hji : j = i := by simp only [Fin.ext_iff]; omega
        rw [hji]; exact hpt
      · intro y hy0 hy1; exact hleft y hy0 hy1
      · intro j; exact absurd j.isLt (by omega)
      · intro y hy0 hy1
        convert hright y hy0 hy1 using 1
        show bf.segmentTypes ⟨n + 1, _⟩ = bf.segmentTypes ⟨i.val + 1 + 0, _⟩
        congr 1; simp only [Fin.ext_iff]; omega
    · obtain ⟨np, rfl⟩ : ∃ k, n = k + 1 := ⟨n - 1, by omega⟩
      rw [IntervalPattern.holds_eq_succ (h := by show np + 1 - i.val = np + 1; omega)] at hright
      obtain ⟨wR, hmR, hrR, hpR, hs0R, hsmR, hslR⟩ := hright
      let w : Fin (np + 2) → M.carrier := fun j =>
        if hj : j.val = 0 then z else wR ⟨j.val - 1, by omega⟩
      refine ⟨w, ?_, ?_, ?_, ?_, ?_, ?_⟩
      · intro a b hab; show w a < w b; simp only [w]
        by_cases ha0 : a.val = 0
        · have hb0 : b.val ≠ 0 := by omega
          simp only [ha0, dite_true, hb0, dite_false]
          calc z < wR ⟨0, by omega⟩ := (hrR ⟨0, by omega⟩).1
               _ ≤ wR ⟨b.val - 1, by omega⟩ := by
                  rcases Nat.eq_or_lt_of_le (Nat.zero_le (b.val - 1)) with h | h
                  · simp [← h]
                  · exact le_of_lt (hmR ⟨0, by omega⟩ ⟨b.val - 1, by omega⟩ (Fin.mk_lt_mk.mpr (by omega)))
        · have hb0 : b.val ≠ 0 := by omega
          simp only [ha0, dite_false, hb0, dite_false]
          exact hmR ⟨a.val - 1, by omega⟩ ⟨b.val - 1, by omega⟩ (Fin.mk_lt_mk.mpr (by omega))
      · intro j; show z0 < w j ∧ w j < z1; simp only [w]
        by_cases hj0 : j.val = 0
        · simp only [hj0, dite_true]; exact ⟨hz0z, hzz1⟩
        · simp only [hj0, dite_false]
          exact ⟨lt_trans hz0z (calc
            z < wR ⟨0, by omega⟩ := (hrR ⟨0, by omega⟩).1
            _ ≤ wR ⟨j.val - 1, by omega⟩ := by
                rcases Nat.eq_or_lt_of_le (Nat.zero_le (j.val - 1)) with h | h
                · simp [← h]
                · exact le_of_lt (hmR ⟨0, by omega⟩ ⟨j.val - 1, by omega⟩ (Fin.mk_lt_mk.mpr (by omega)))),
            (hrR ⟨j.val - 1, by omega⟩).2⟩
      · intro j; show (bf.pointTypes j).eval_at M atomMap (w j); simp only [w]
        by_cases hj0 : j.val = 0
        · simp only [hj0, dite_true]
          have : j = i := by simp only [Fin.ext_iff]; omega
          rw [this]; exact hpt
        · simp only [hj0, dite_false]
          have h : bf.pointTypes j = bf.pointTypes ⟨i.val + 1 + (j.val - 1), by omega⟩ := by
            congr 1; simp only [Fin.ext_iff]; omega
          rw [h]; exact hpR ⟨j.val - 1, by omega⟩
      · intro y hy0 hy1
        have : w ⟨0, by omega⟩ = z := by simp [w]
        rw [this] at hy1; exact hleft y hy0 hy1
      · intro j y hy_lo hy_hi
        have hw_lo : w ⟨j.val, by omega⟩ =
            if hj : j.val = 0 then z else wR ⟨j.val - 1, by omega⟩ := by simp [w]
        have hw_hi' : w ⟨j.val + 1, by omega⟩ = wR ⟨j.val, by omega⟩ := by
          simp [w, show j.val + 1 ≠ 0 from by omega]
        rw [hw_lo] at hy_lo; rw [hw_hi'] at hy_hi
        by_cases hj0 : j.val = 0
        · simp only [hj0, dite_true] at hy_lo
          have hhi : y < wR ⟨0, by omega⟩ := by
            convert hy_hi using 2; simp only [Fin.ext_iff]; omega
          convert hs0R y hy_lo hhi using 1
          show bf.segmentTypes ⟨j.val + 1, _⟩ = bf.segmentTypes ⟨i.val + 1 + 0, _⟩
          congr 1; simp only [Fin.ext_iff]; omega
        · simp only [hj0, dite_false] at hy_lo
          have hlo : wR ⟨j.val - 1, by omega⟩ < y := hy_lo
          have hhi : y < wR ⟨(j.val - 1) + 1, by omega⟩ := by
            convert hy_hi using 2; simp only [Fin.ext_iff]; omega
          convert hsmR ⟨j.val - 1, by omega⟩ y hlo hhi using 1
          show bf.segmentTypes ⟨j.val + 1, _⟩ = bf.segmentTypes ⟨i.val + 1 + (j.val - 1 + 1), _⟩
          congr 1; simp only [Fin.ext_iff]; omega
      · intro y hy_lo hy_hi
        have hw_last : w ⟨np + 1, by omega⟩ = wR ⟨np, by omega⟩ := by
          simp [w, show np + 1 ≠ 0 from by omega]
        rw [hw_last] at hy_lo
        convert hslR y hy_lo hy_hi using 1
        show bf.segmentTypes ⟨np + 1 + 1, _⟩ = bf.segmentTypes ⟨i.val + 1 + (np + 1), _⟩
        congr 1; simp only [Fin.ext_iff]; omega
  · obtain ⟨k, hk⟩ : ∃ k, i.val = k + 1 := ⟨i.val - 1, by omega⟩
    have hi_fin : i = ⟨k + 1, hk ▸ i.isLt⟩ := by ext; exact hk
    rw [hi_fin] at hleft hright hpt
    rw [IntervalPattern.holds_eq_succ (h := rfl)] at hleft
    obtain ⟨wL, hmL, hrL, hpL, hs0L, hsmL, hslL⟩ := hleft
    have hi_le' : k + 1 ≤ n := hk ▸ hi_le
    rcases Nat.eq_or_lt_of_le hi_le' with hi_eq | hi_lt
    · rw [IntervalPattern.holds_eq_zero (h := by omega)] at hright
      let w : Fin (n + 1) → M.carrier := fun j =>
        if hle : j.val ≤ k then wL ⟨j.val, by omega⟩ else z
      refine ⟨w, ?_, ?_, ?_, ?_, ?_, ?_⟩
      · intro a b hab; show w a < w b; simp only [w]
        by_cases ha : a.val ≤ k
        · by_cases hb : b.val ≤ k
          · simp only [ha, dite_true, hb, dite_true]
            exact hmL ⟨a.val, by omega⟩ ⟨b.val, by omega⟩ (Fin.mk_lt_mk.mpr (by omega))
          · simp only [ha, dite_true, hb, dite_false]
            calc wL ⟨a.val, by omega⟩ ≤ wL ⟨k, by omega⟩ := by
                    rcases Nat.eq_or_lt_of_le ha with h | h
                    · subst h; exact le_rfl
                    · exact le_of_lt (hmL ⟨a.val, by omega⟩ ⟨k, by omega⟩ (Fin.mk_lt_mk.mpr (by omega)))
                 _ < z := (hrL ⟨k, by omega⟩).2
        · simp only [ha, dite_false]; omega
      · intro j; show z0 < w j ∧ w j < z1; simp only [w]
        by_cases hj : j.val ≤ k
        · simp only [hj, dite_true]
          exact ⟨(hrL ⟨j.val, by omega⟩).1, lt_trans (hrL ⟨j.val, by omega⟩).2 hzz1⟩
        · simp only [hj, dite_false]; exact ⟨hz0z, hzz1⟩
      · intro j; show (bf.pointTypes j).eval_at M atomMap (w j); simp only [w]
        by_cases hj : j.val ≤ k
        · simp only [hj, dite_true]; exact hpL ⟨j.val, by omega⟩
        · simp only [hj, dite_false]
          have h : bf.pointTypes j = bf.pointTypes ⟨k + 1, hk ▸ i.isLt⟩ := by
            congr 1; simp only [Fin.ext_iff]; omega
          rw [h]; exact hpt
      · intro y hy0 hy1
        have : w ⟨0, by omega⟩ = wL ⟨0, by omega⟩ := by simp [w, show (0 : Nat) ≤ k from by omega]
        rw [this] at hy1; exact hs0L y hy0 hy1
      · intro j y hy_lo hy_hi
        have hw_lo : w ⟨j.val, by omega⟩ =
            if hle : j.val ≤ k then wL ⟨j.val, by omega⟩ else z := by simp [w]
        have hw_hi_eq : w ⟨j.val + 1, by omega⟩ =
            if hle : j.val + 1 ≤ k then wL ⟨j.val + 1, by omega⟩ else z := by simp [w]
        rw [hw_lo] at hy_lo; rw [hw_hi_eq] at hy_hi
        by_cases hj : j.val ≤ k
        · by_cases hj1 : j.val + 1 ≤ k
          · simp only [hj, dite_true] at hy_lo; simp only [hj1, dite_true] at hy_hi
            exact hsmL ⟨j.val, by omega⟩ y hy_lo hy_hi
          · simp only [hj, dite_true] at hy_lo; simp only [hj1, dite_false] at hy_hi
            have hlo : wL ⟨k, by omega⟩ < y := by
              convert hy_lo using 2; simp only [Fin.ext_iff]; omega
            convert hslL y hlo hy_hi using 1
            show bf.segmentTypes ⟨j.val + 1, _⟩ = bf.segmentTypes ⟨k + 1, _⟩
            congr 1; simp only [Fin.ext_iff]; omega
        · simp only [hj, dite_false] at hy_lo
          simp only [show ¬(j.val + 1 ≤ k) from by omega, dite_false] at hy_hi
          exact absurd (lt_trans hy_lo hy_hi) (lt_irrefl _)
      · intro y hy_lo hy_hi
        have : w ⟨n, by omega⟩ = z := by simp [w, show ¬(n ≤ k) from by omega]
        rw [this] at hy_lo
        convert hright y hy_lo hy_hi using 1
        show bf.segmentTypes ⟨n + 1, _⟩ = bf.segmentTypes ⟨(k + 1) + 1, _⟩
        congr 1; simp only [Fin.ext_iff]; omega
    · obtain ⟨m, hm_eq⟩ : ∃ m, n - (k + 1) = m + 1 := ⟨n - (k + 1) - 1, by omega⟩
      rw [IntervalPattern.holds_eq_succ (h := hm_eq)] at hright
      obtain ⟨wR, hmR, hrR, hpR, hs0R, hsmR, hslR⟩ := hright
      let w : Fin (n + 1) → M.carrier := fun j =>
        if h1 : j.val ≤ k then wL ⟨j.val, by omega⟩
        else if h2 : j.val = k + 1 then z
        else wR ⟨j.val - (k + 2), by omega⟩
      refine ⟨w, ?_, ?_, ?_, ?_, ?_, ?_⟩
      · intro a b hab; show w a < w b; simp only [w]
        by_cases ha1 : a.val ≤ k
        · by_cases hb1 : b.val ≤ k
          · simp only [dif_pos ha1, dif_pos hb1]
            exact hmL ⟨a.val, by omega⟩ ⟨b.val, by omega⟩ (Fin.mk_lt_mk.mpr (by omega))
          · simp only [dif_pos ha1, dif_neg hb1]
            by_cases hb2 : b.val = k + 1
            · simp only [dif_pos hb2]
              calc wL ⟨a.val, by omega⟩ ≤ wL ⟨k, by omega⟩ := by
                      rcases Nat.eq_or_lt_of_le ha1 with h | h
                      · exact le_of_eq (congrArg wL (by ext; exact h))
                      · exact le_of_lt (hmL ⟨a.val, by omega⟩ ⟨k, by omega⟩ (Fin.mk_lt_mk.mpr (by omega)))
                   _ < z := (hrL ⟨k, by omega⟩).2
            · simp only [dif_neg hb2]
              calc wL ⟨a.val, by omega⟩ ≤ wL ⟨k, by omega⟩ := by
                      rcases Nat.eq_or_lt_of_le ha1 with h | h
                      · exact le_of_eq (congrArg wL (by ext; exact h))
                      · exact le_of_lt (hmL ⟨a.val, by omega⟩ ⟨k, by omega⟩ (Fin.mk_lt_mk.mpr (by omega)))
                   _ < z := (hrL ⟨k, by omega⟩).2
                   _ < wR ⟨0, by omega⟩ := (hrR ⟨0, by omega⟩).1
                   _ ≤ wR ⟨b.val - (k + 2), by omega⟩ := by
                      rcases Nat.eq_or_lt_of_le (Nat.zero_le (b.val - (k + 2))) with h | h
                      · simp [← h]
                      · exact le_of_lt (hmR ⟨0, by omega⟩ ⟨b.val - (k + 2), by omega⟩ (Fin.mk_lt_mk.mpr (by omega)))
        · by_cases ha2 : a.val = k + 1
          · have hb1 : ¬(b.val ≤ k) := by omega
            have hb2 : b.val ≠ k + 1 := by omega
            simp only [dif_neg ha1, dif_pos ha2, dif_neg hb1, dif_neg hb2]
            calc z < wR ⟨0, by omega⟩ := (hrR ⟨0, by omega⟩).1
                 _ ≤ wR ⟨b.val - (k + 2), by omega⟩ := by
                    rcases Nat.eq_or_lt_of_le (Nat.zero_le (b.val - (k + 2))) with h | h
                    · simp [← h]
                    · exact le_of_lt (hmR ⟨0, by omega⟩ ⟨b.val - (k + 2), by omega⟩ (Fin.mk_lt_mk.mpr (by omega)))
          · have hb1 : ¬(b.val ≤ k) := by omega
            have hb2 : b.val ≠ k + 1 := by omega
            simp only [dif_neg ha1, dif_neg ha2, dif_neg hb1, dif_neg hb2]
            exact hmR ⟨a.val - (k + 2), by omega⟩ ⟨b.val - (k + 2), by omega⟩ (Fin.mk_lt_mk.mpr (by omega))
      · intro j; show z0 < w j ∧ w j < z1; simp only [w]
        by_cases hj1 : j.val ≤ k
        · simp only [hj1, dite_true]
          exact ⟨(hrL ⟨j.val, by omega⟩).1, lt_trans (hrL ⟨j.val, by omega⟩).2 hzz1⟩
        · by_cases hj2 : j.val = k + 1
          · simp only [dif_neg hj1, dif_pos hj2]; exact ⟨hz0z, hzz1⟩
          · simp only [dif_neg hj1, dif_neg hj2]
            exact ⟨lt_trans hz0z (lt_of_lt_of_le (hrR ⟨0, by omega⟩).1
              (by rcases Nat.eq_or_lt_of_le (Nat.zero_le (j.val - (k + 2))) with h | h
                  · simp [← h]
                  · exact le_of_lt (hmR ⟨0, by omega⟩ ⟨j.val - (k + 2), by omega⟩ (Fin.mk_lt_mk.mpr (by omega))))),
              (hrR ⟨j.val - (k + 2), by omega⟩).2⟩
      · intro j; show (bf.pointTypes j).eval_at M atomMap (w j); simp only [w]
        by_cases hj1 : j.val ≤ k
        · simp only [hj1, dite_true]; exact hpL ⟨j.val, by omega⟩
        · by_cases hj2 : j.val = k + 1
          · simp only [dif_neg hj1, dif_pos hj2]
            have h : bf.pointTypes j = bf.pointTypes ⟨k + 1, hk ▸ i.isLt⟩ := by
              congr 1; simp only [Fin.ext_iff]; omega
            rw [h]; exact hpt
          · simp only [dif_neg hj1, dif_neg hj2]
            have h : bf.pointTypes j = bf.pointTypes ⟨(k + 1) + 1 + (j.val - (k + 2)), by omega⟩ := by
              congr 1; simp only [Fin.ext_iff]; omega
            rw [h]; exact hpR ⟨j.val - (k + 2), by omega⟩
      · intro y hy0 hy1
        have : w ⟨0, by omega⟩ = wL ⟨0, by omega⟩ := by simp [w, show (0 : Nat) ≤ k from by omega]
        rw [this] at hy1; exact hs0L y hy0 hy1
      · intro j y hy_lo hy_hi
        have hw_lo : w ⟨j.val, by omega⟩ =
            if h1 : j.val ≤ k then wL ⟨j.val, by omega⟩
            else if h2 : j.val = k + 1 then z
            else wR ⟨j.val - (k + 2), by omega⟩ := by simp [w]
        have hw_hi_eq : w ⟨j.val + 1, by omega⟩ =
            if h1 : j.val + 1 ≤ k then wL ⟨j.val + 1, by omega⟩
            else if h2 : j.val + 1 = k + 1 then z
            else wR ⟨j.val + 1 - (k + 2), by omega⟩ := by simp [w]
        rw [hw_lo] at hy_lo; rw [hw_hi_eq] at hy_hi
        by_cases hj1 : j.val ≤ k
        · by_cases hj1' : j.val + 1 ≤ k
          · simp only [dif_pos hj1] at hy_lo; simp only [dif_pos hj1'] at hy_hi
            exact hsmL ⟨j.val, by omega⟩ y hy_lo hy_hi
          · simp only [dif_pos hj1] at hy_lo
            simp only [dif_neg hj1', dif_pos (show j.val + 1 = k + 1 from by omega)] at hy_hi
            have hlo' : wL ⟨k, by omega⟩ < y := by
              convert hy_lo using 2; simp only [Fin.ext_iff]; omega
            have hseg : ({ alpha := bf.pointTypes, beta := bf.segmentTypes } : IntervalPattern (n + 1)).beta ⟨j.val + 1, by omega⟩ =
                bf.segmentTypes ⟨k + 1, by omega⟩ := by
              show bf.segmentTypes ⟨j.val + 1, _⟩ = bf.segmentTypes ⟨k + 1, _⟩
              congr 1; simp only [Fin.ext_iff]; omega
            rw [hseg]; exact hslL y hlo' hy_hi
        · by_cases hj2 : j.val = k + 1
          · simp only [dif_neg hj1, dif_pos hj2] at hy_lo
            have hj1' : ¬(j.val + 1 ≤ k) := by omega
            have hj2' : j.val + 1 ≠ k + 1 := by omega
            simp only [dif_neg hj1', dif_neg hj2'] at hy_hi
            have hhi : y < wR ⟨0, by omega⟩ := by
              convert hy_hi using 2; simp only [Fin.ext_iff]; omega
            have hseg : ({ alpha := bf.pointTypes, beta := bf.segmentTypes } : IntervalPattern (n + 1)).beta ⟨j.val + 1, by omega⟩ =
                bf.segmentTypes ⟨(k + 1) + 1 + 0, by omega⟩ := by
              show bf.segmentTypes ⟨j.val + 1, _⟩ = bf.segmentTypes ⟨(k + 1) + 1 + 0, _⟩
              congr 1; simp only [Fin.ext_iff]; omega
            rw [hseg]; exact hs0R y hy_lo hhi
          · simp only [dif_neg hj1, dif_neg hj2] at hy_lo
            have hj1' : ¬(j.val + 1 ≤ k) := by omega
            have hj2' : j.val + 1 ≠ k + 1 := by omega
            simp only [dif_neg hj1', dif_neg hj2'] at hy_hi
            have hlo : wR ⟨j.val - (k + 2), by omega⟩ < y := hy_lo
            have hhi : y < wR ⟨(j.val - (k + 2)) + 1, by omega⟩ := by
              convert hy_hi using 2; simp only [Fin.ext_iff]; omega
            have hseg : ({ alpha := bf.pointTypes, beta := bf.segmentTypes } : IntervalPattern (n + 1)).beta ⟨j.val + 1, by omega⟩ =
                bf.segmentTypes ⟨(k + 1) + 1 + (j.val - (k + 2) + 1), by omega⟩ := by
              show bf.segmentTypes ⟨j.val + 1, _⟩ = bf.segmentTypes ⟨(k + 1) + 1 + (j.val - (k + 2) + 1), _⟩
              congr 1; simp only [Fin.ext_iff]; omega
            rw [hseg]; exact hsmR ⟨j.val - (k + 2), by omega⟩ y hlo hhi
      · intro y hy_lo hy_hi
        have hw_n : w ⟨n, by omega⟩ = wR ⟨n - (k + 2), by omega⟩ := by
          simp [w, show ¬(n ≤ k) from by omega, show n ≠ k + 1 from by omega]
        rw [hw_n] at hy_lo
        have hlo : wR ⟨m, by omega⟩ < y := by
          convert hy_lo using 2; simp only [Fin.ext_iff]; omega
        have hseg : ({ alpha := bf.pointTypes, beta := bf.segmentTypes } : IntervalPattern (n + 1)).beta ⟨n + 1, by omega⟩ =
            bf.segmentTypes ⟨(k + 1) + 1 + (m + 1), by omega⟩ := by
          show bf.segmentTypes ⟨n + 1, _⟩ = bf.segmentTypes ⟨(k + 1) + 1 + (m + 1), _⟩
          congr 1; simp only [Fin.ext_iff]; omega
        rw [hseg]; exact hslR y hlo hy_hi

end Bimodal.Metalogic.WeakCanonical.Kamp
