# Research Report: Task #979 - Remove discrete_Icc_finite_axiom

**Task**: 979 - remove_discrete_icc_finite_axiom_prove_stage_bounding
**Date**: 2026-03-16
**Mode**: Team Research (3 teammates)
**Session**: sess_1773693314_41c75d

---

## Summary

Three teammates investigated how to eliminate `discrete_Icc_finite_axiom` from
`DiscreteTimeline.lean`. The research surfaces a **fundamental tension**: the
stage-bounding approach proposed in research-006.md has a significant gap, while
the mathematically correct approach (SuccOrder-first, deriving LocallyFiniteOrder
from a direct covering proof) is more tractable but requires extracting the DF
frame condition at the MCS level. This report recommends the SuccOrder-first path
as the most mathematically correct approach with no compromises.

---

## Key Findings

### Primary Approach Analysis (Teammate A: Stage-Bounding)

Teammate A (85% confidence) proposed the stage-bounding proof:

```lean
theorem discrete_Icc_stage_bounded (a b : DiscreteTimelineQuot) :
    Set.Icc a b ⊆
    (discreteStagedBuild (max (minStage a) (minStage b))).image
      (Quotient.mk (antisymmRel (· ≤ ·)) ∘ Subtype.val)
```

**Core argument**: The discrete construction (no density insertion) is "stage-complete"
— all CanonicalR-related points between two endpoints appear at the stage where the
endpoints appear.

**Required lemma**:
```lean
lemma canonicalR_chain_stage_bound
    (a b : StagedPoint) (ha : a ∈ discreteStagedBuild N) (hb : b ∈ discreteStagedBuild N)
    (c : StagedPoint) (hc_between : StagedPoint.le a c ∧ StagedPoint.le c b) :
    c ∈ discreteStagedBuild N
```

### Critical Gap (Teammate C: Stage Bounding May Be False)

Teammate C identified a **potentially fundamental gap**:

`CanonicalR M_a M_c` means `g_content(M_a) ⊆ M_c` (all G-formulas of M_a are in M_c).
`CanonicalR M_c M_b` means `g_content(M_c) ⊆ M_b`.

M_c is created as a witness for `F(phi_k) ∈ M_a` when formula `phi_k = decodeFormulaStaged k`
is processed. If `k >> max(minStage a, minStage b)`, then M_c appears at stage `k+1 >> N`.

**Scenario where stage-bounding fails**:
1. M_a at stage 5, M_b at stage 8 (N = 8)
2. M_c = witness for `F(phi_{100}) ∈ M_a`, created at stage 101
3. M_c satisfies `CanonicalR M_a M_c` (by construction) and `CanonicalR M_c M_b`
   (because `g_content(M_c) ⊆ M_b` — M_b contains all G-formulas of M_a via
   `g_content(M_a) ⊆ M_c ⊆ M_b` transitivity)
4. Then `[M_c] ∈ Set.Icc [M_a] [M_b]` but `minStage M_c = 101 > N = 8`

**Conclusion**: The stage-bounding claim as stated is likely **FALSE**.

### CanonicalR Definition (Critical Context)

```lean
def CanonicalR (M M' : Set Formula) : Prop :=
  g_content M ⊆ M'
```

This means `CanonicalR M M'` iff `g_content M ⊆ M'` (all G-formulas of M hold in M').
The preorder on DiscreteTimelineElem:
```lean
def StagedPoint.le (a b : StagedPoint) : Prop :=
  a.mcs = b.mcs ∨ CanonicalR a.mcs b.mcs
```

**Crucial implication**: Between M_a and M_b, the set of intermediate MCSs is:
```
{ M_c | g_content(M_a) ⊆ M_c  AND  g_content(M_c) ⊆ M_b }
```
In general, this set can be **infinite** (uncountably many consistent extensions
of g_content(M_a) fitting inside M_b). The finiteness relies on the **DF axiom**
providing the covering/discreteness property.

### Existing Infrastructure (Teammate B)

| Item | Location | Relevance |
|------|----------|-----------|
| `discreteStagedBuild_monotone_le` | StagedExecution.lean:1023 | Stage ordering |
| `discreteStagedBuild_linear` | StagedExecution.lean:1093 | Linearity at each stage |
| `minStage`, `minStage_spec` | DiscreteTimeline.lean:200-208 | Already defined |
| `evenStage` (no oddStage) | StagedExecution.lean:678 | No density witnesses |
| `LocallyFiniteOrder.ofFiniteIcc` | Mathlib | Existing constructor |
| No `Antisymmetrization.locallyFiniteOrder` | Mathlib | Must construct directly |

**Confirmed non-viable approaches**:
- Countable + linear does NOT imply LocallyFiniteOrder (ℚ is a counterexample)
- Order embedding to ℤ via `orderIsoIntOfLinearSuccPredArch` is **circular**
  (requires IsSuccArchimedean, which currently derives from LocallyFiniteOrder)

---

## Synthesis

### Conflict Resolution: Stage-Bounding vs Direct Approach

| Perspective | Claim | Assessment |
|-------------|-------|------------|
| Teammate A | Stage-bounding works (85% confidence) | Likely flawed — stage of M_c not bounded by N |
| Teammate C | Stage-bounding may be FALSE | Legitimate critical gap identified |
| Teammate B | Recommended stage-bounding as primary | Needs revised based on C's analysis |

**Resolution**: The stage-bounding approach has a fundamental gap. The gap is not
about formalization difficulty but about mathematical correctness. We need a
different proof structure.

### The Root Cause: Circular Dependency

The current code has a circular structure introduced by the axiom:

```
discrete_Icc_finite_axiom
    → LocallyFiniteOrder (via ofFiniteIcc)
        → LinearLocallyFiniteOrder
            → succFn (GLB of Ioi)
                → SuccOrder, PredOrder, IsSuccArchimedean
```

Breaking this cycle requires proving `SuccOrder` **independently** of
`LocallyFiniteOrder`, then deriving `LocallyFiniteOrder` from `SuccOrder`.

### The Mathematically Correct Approach: SuccOrder-First

The code's own comment (DiscreteTimeline.lean:262-288) already identifies the
right path but left it unformalized:

> "DF corresponds to the frame condition that every non-maximal element has an
> immediate successor (coverness). This gives SuccOrder on the quotient."

**Implementation Plan**:

#### Step 1: Define `discreteSuccFn` Independently

Define a direct successor function without `LocallyFiniteOrder`:

```lean
-- The immediate successor of [M] uses the forward witness construction
noncomputable def discreteSuccFn (a : DiscreteTimelineQuot root_mcs root_mcs_proof) :
    DiscreteTimelineQuot root_mcs root_mcs_proof :=
  -- Pick representative a', use its forward witness W = forwardWitnessPoint a'.mcs a'.is_mcs ⊤ ...
  -- The immediate successor is the equivalence class of this witness
  Quotient.liftOn a (fun a' => ⟦discreteImmediateSucc a'⟧) (well_definedness_proof)
```

The key subgoal: show the immediate successor is **well-defined** on the quotient
(representatives in the same equivalence class have the same successor equivalence class).

#### Step 2: Prove Covering (DF Frame Condition at MCS Level)

The crucial lemma:
```lean
theorem discreteSuccFn_is_covering (a : DiscreteTimelineQuot root_mcs root_mcs_proof) :
    ¬ ∃ c, a < c ∧ c < discreteSuccFn a
```

**Proof strategy**: This follows from the DF axiom. In TM+DF:
- DF = `(F⊤ ∧ φ ∧ Hφ) → F(Hφ)` ensures covering in the semantic frame
- The canonical model satisfies covering (by soundness of DF)
- In the canonical model, if `CanonicalR M N`, then either N is the immediate
  successor of M, or there's a witness W with M < W < N
- DF rules out indefinite intermediate witnesses

**Technical path**: Extract the DF frame condition from the soundness proof
in `Soundness.lean` and instantiate it for the canonical model in
`DiscreteTimeline.lean`.

#### Step 3: Instantiate SuccOrder from discreteSuccFn

```lean
noncomputable instance : SuccOrder (DiscreteTimelineQuot root_mcs root_mcs_proof) where
  succ := discreteSuccFn root_mcs root_mcs_proof
  le_succ := le_discreteSuccFn             -- a ≤ succ a (from construction)
  max_of_succ_le := max_of_discreteSuccFn_le  -- succ a ≤ a → IsMax a
  succ_le_of_lt := discreteSuccFn_le_of_lt  -- a < b → succ a ≤ b (from covering)
```

#### Step 4: Derive LocallyFiniteOrder from SuccOrder

With `SuccOrder`, `PredOrder`, `NoMaxOrder`, `NoMinOrder`, and the linear order:

```lean
-- Via Mathlib: isSuccArchimedean_iff_forall_exists_between, or directly:
theorem discrete_Icc_finite_from_SuccOrder
    (a b : DiscreteTimelineQuot) (h : a ≤ b) :
    (Set.Icc a b).Finite := by
  -- Induct on the covering chain from a to b
  -- a ≤ succ a ≤ succ (succ a) ≤ ... ≤ b
  -- Chain is finite by IsSuccArchimedean (or proved directly)
  sorry
```

Then instantiate `LocallyFiniteOrder.ofFiniteIcc discrete_Icc_finite`.

---

## Key Technical Challenges

### Challenge 1: Defining discreteSuccFn Well-Definedly (MEDIUM)

The successor function must be defined on equivalence classes. Two representatives
of the same class (same MCS, different stages) must have equivalent successors.

**Key insight**: StagedPoint.le is by MCS equality or CanonicalR. Points with the
same MCS are in the same equivalence class. The forward witness depends only on
the MCS (not the stage). So `forwardWitnessPoint M_a.mcs ... ` is the same MCS
for any representative of [M_a]. The successor is well-defined.

### Challenge 2: Extracting DF Frame Condition at MCS Level (HARD)

The DF axiom's frame condition needs to be stated and proved for the canonical
model at the MCS level. This requires:

1. **Formal statement**: If `CanonicalR M_a M_b` in the canonical model, then either
   M_b is the immediate successor of M_a (no M_c with `CanonicalR M_a M_c` and
   `CanonicalR M_c M_b` and `g_content(M_a) ≠ g_content(M_c)` and
   `g_content(M_c) ≠ g_content(M_b)`), OR there exists such an intermediate.

2. **The DF axiom rules out the case where M_a is non-maximal and M_b is not the
   immediate successor**: DF says F⊤ ∧ φ ∧ Hφ → F(Hφ), which semantically corresponds
   to: if t has a future, then t's immediate successor exists.

**Source**: The DF soundness proof in `Soundness.lean` proves:
```
valid_on_df_frame ↔ ∀ t, ¬IsMax t → ∃ s, Covers t s
```
This can be instantiated for the canonical model.

### Challenge 3: IsSuccArchimedean Without Circular Dependency (MEDIUM)

To prove `Icc a b` is finite from SuccOrder, we need `IsSuccArchimedean` (∀ a b, a ≤ b → ∃ n, succ^n a = b). Without LocallyFiniteOrder, this requires:

- Showing the SuccOrder iterations are strict (`a < succ a` always)
- Well-foundedness or Noetherianness of the "Icc a b with succ" structure

**Approach**: Prove `IsSuccArchimedean` by showing each MCS has a unique immediate
successor that strictly increases toward b. The finiteness follows from the
well-foundedness of the CanonicalR-encoded chain.

---

## Recommended Implementation Plan

### Phase A: DF Frame Condition Extraction (New Infrastructure)

**Goal**: Prove the covering lemma at the MCS level using soundness of DF.

```lean
-- New lemma in DiscreteTimeline.lean or a new helper file
theorem df_frame_condition_canonical
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (h_serial : ∃ N, CanonicalR M N) :
    ∃ N, CanonicalR M N ∧ ∀ K, CanonicalR M K → CanonicalR N K ∨ N = K
```

This says: the canonical model of TM+DF has an immediate successor for every
non-maximal element. Requires extracting the DF semantic from Soundness.lean.

### Phase B: Direct SuccOrder Instantiation

**Goal**: Define `discreteSuccFn` and prove it satisfies SuccOrder without
`LocallyFiniteOrder`.

Key lemmas:
- `discreteSuccFn_well_defined`: respects quotient equivalence
- `le_discreteSuccFn`: `a ≤ discreteSuccFn a`
- `discreteSuccFn_lt`: `a < discreteSuccFn a` (from NoMaxOrder + covering)
- `discreteSuccFn_le_of_lt`: `a < b → discreteSuccFn a ≤ b` (the hard one)

### Phase C: LocallyFiniteOrder from SuccOrder

**Goal**: Derive interval finiteness from the covering structure.

```lean
-- Induction on the covering chain
theorem icc_finite_from_succ
    (a b : DiscreteTimelineQuot) :
    (Set.Icc a b).Finite := by
  -- If a > b, empty and trivially finite
  -- If a = b, singleton
  -- If a < b, Icc a b = {a} ∪ Icc (succ a) b, induct
  -- Termination: chain a < succ a < ... must reach b (IsSuccArchimedean)
```

### Alternative: Fix the Stage-Bounding

If Phase A proves too hard, an alternative is to use a LOOSER but VALID stage bound:

Instead of `max(minStage a, minStage b)`, use a bound based on formula encoding:

```lean
-- The stage bound is the maximum formula index needed for all obligations
-- of the MCS representatives of a and b
noncomputable def intervalStageBound
    (a b : DiscreteTimelineQuot root_mcs root_mcs_proof) : ℕ :=
  -- max over all F(phi) ∈ M_a or M_b of (decodeFormulaStaged^{-1}(phi) + 1)
  ...
```

**Challenge**: This requires defining a function from formulas to their encoding
index, which requires the surjectivity of `decodeFormulaStaged` and may be complex.

---

## Effort Estimates

| Phase | Description | Estimated Effort |
|-------|-------------|-----------------|
| A | DF frame condition extraction | 2-3 hours |
| B | Direct SuccOrder instantiation | 1-2 hours |
| C | LocallyFiniteOrder from SuccOrder | 1-2 hours |
| **Total** | | **4-7 hours** |

---

## Confidence Assessment

| Approach | Confidence | Blockers |
|----------|------------|---------|
| Stage-bounding as stated | LOW (30%) | Fundamental gap: stage bounds don't hold |
| SuccOrder-first (Phases A-C) | MEDIUM-HIGH (70%) | DF frame condition extraction needed |
| Looser stage bound | MEDIUM (50%) | Formula encoding inversion needed |
| Leave as axiom with documentation | N/A | Not a zero-debt approach |

---

## Recommendations

**Primary recommendation**: Implement the SuccOrder-first approach (Phases A-C).
This is the most mathematically correct path that avoids the circular dependency
and connects the proof to the actual mathematical content (DF frame condition).

**Key first step**: Examine `Soundness.lean` to find the formal statement of the
DF frame condition and determine how to instantiate it for `DiscreteTimelineQuot`.
If the formal DF frame condition is extractable in < 30 minutes of searching, the
SuccOrder-first path is likely tractable.

**If Phase A proves intractable**: The looser stage-bound approach (using formula
encoding index as the bound, rather than `minStage`) may work with more careful
analysis of the witness creation ordering.

---

## Teammate Contributions

| Teammate | Angle | Status | Key Finding |
|----------|-------|--------|-------------|
| A | Primary proof strategy | Completed | Stage-bounding infrastructure; 85% confidence |
| B | Alternative approaches | Completed | Confirmed circular dependency; Approach 5 as backup |
| C | Risk analysis | Completed | **Critical**: stage-bounding may be false; covering approach needed |

## Key Conflict Resolved

**Conflict**: Teammate A (85% confidence) vs Teammate C (critical gap identified).

**Resolution**: Teammate C's analysis is correct. The claim that all elements in
`Icc [a][b]` have representatives at stage ≤ N = max(minStage a, minStage b) is
not supported by the construction. Witnesses for F(phi_k) with k >> N are created
at stage k+1 >> N, yet these witnesses can be between M_a and M_b in the CanonicalR
order. The correct proof must instead use the DF covering property.

---

## References

- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean:63` - CanonicalR = g_content subset
- `Theories/Bimodal/Metalogic/StagedConstruction/StagedExecution.lean:1005` - discreteStagedBuild
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean:244` - The axiom to remove
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean:262-319` - SuccOrder from DF (TODO note)
- `specs/974_prove_discrete_timeline_succorder_predorder/reports/research-006.md` - Prior research
- `Soundness.lean` - DF frame condition source
