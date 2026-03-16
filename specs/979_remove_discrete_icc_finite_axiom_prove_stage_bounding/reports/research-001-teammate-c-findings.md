# Research Findings: Teammate C - Risk Analysis and Proof Obstacles

**Task**: 979 - Remove discrete_Icc_finite_axiom and prove stage-bounding lemma
**Date**: 2026-03-16
**Focus**: Identify proof obstacles, gaps, and potential blockers
**Session**: teammate_c_979_risk_analysis

---

## Quotient Structure Analysis

### How DiscreteTimelineQuot is Defined

```lean
def DiscreteTimelineQuot : Type :=
  Antisymmetrization (DiscreteTimelineElem root_mcs root_mcs_proof) (· ≤ ·)
```

Where `DiscreteTimelineElem` is:
```lean
def DiscreteTimelineElem : Type :=
  { p : StagedPoint // p ∈ (buildDiscreteStagedTimeline root_mcs root_mcs_proof).union }
```

### Preorder on DiscreteTimelineElem

The preorder comes from `StagedPoint.le`:
```lean
def StagedPoint.le (a b : StagedPoint) : Prop :=
  a.mcs = b.mcs ∨ CanonicalR a.mcs b.mcs
```

**Key insight**: Two `StagedPoint`s with the same MCS are equivalent in the quotient. This means the quotient collapses multiple stage-representatives of the same MCS into one equivalence class.

### Quotient Order Lemmas Available

From `Mathlib.Order.Antisymmetrization`:
- `toAntisymmetrization_le_toAntisymmetrization_iff`: `[a] ≤ [b] ↔ a ≤ b` (no content, just Iff.rfl)
- `toAntisymmetrization_lt_toAntisymmetrization_iff`: `[a] < [b] ↔ a < b`
- `Antisymmetrization.ind`: Induction principle for quotient elements

**Risk**: Working with representatives requires careful handling. The quotient map `toAntisymmetrization` is monotone, but lifting functions from the base type to the quotient requires respecting equivalence.

---

## Stage Completeness Analysis

### The Core Claim to Investigate

**Claim**: If `c ∈ Icc a b` in the quotient (i.e., `a ≤ c ≤ b`), then `c` has a representative in `discreteStagedBuild (max (minStage a) (minStage b))`.

### When Are Witnesses Added?

From `StagedExecution.lean`:

**Forward witness** (for `F(phi) ∈ p.mcs`):
```lean
noncomputable def witnessesForPoint
    (p : StagedPoint) (phi : Formula) (stage : Stage) : Finset StagedPoint :=
  let fwd : Finset StagedPoint :=
    if h : Formula.some_future phi ∈ p.mcs then
      {processForwardObligation p phi h stage}
    else ∅
  let bwd : Finset StagedPoint :=
    if h : Formula.some_past phi ∈ p.mcs then
      {processBackwardObligation p phi h stage}
    else ∅
  fwd ∪ bwd
```

**discreteStagedBuild**:
```lean
noncomputable def discreteStagedBuild : Nat → Finset StagedPoint
  | 0 => stage0 root_mcs root_mcs_proof
  | n + 1 =>
    let prev := discreteStagedBuild n
    -- Always apply evenStage for formula n (no density insertion)
    evenStage prev n (n + 1)
```

### Critical Gap: "Locally Complete" Property NOT Established

**The key question**: If `a' ≤ c' ≤ b'` in the preorder on DiscreteTimelineElem, and both `a'`, `b'` appear in `discreteStagedBuild N`, must `c'` also appear in `discreteStagedBuild N`?

**This is NOT obviously true.** Here's a potential counterexample scenario:

1. Stage N has points `a'` and `b'` with `a'.mcs = M_a`, `b'.mcs = M_b`, where `CanonicalR M_a M_b`.
2. Some MCS `M_c` exists with `CanonicalR M_a M_c` and `CanonicalR M_c M_b`.
3. This `M_c` might only be created as a witness at stage N+k for some formula phi_k.

**Why this could happen**: The witness construction is formula-driven. A formula `F(phi)` in some MCS triggers the creation of witnesses. But `M_c` might contain `phi` without being directly required as a witness for any point in stage N.

### Analysis of the Witness Structure

The witnesses created at each stage are:
1. **Forward**: For each `F(phi) ∈ p.mcs`, create a witness `W` with `CanonicalR p.mcs W` and `phi ∈ W`
2. **Backward**: For each `P(phi) ∈ p.mcs`, create a witness `W` with `CanonicalR W p.mcs` and `phi ∈ W`

**Key observation**: Witnesses are created to satisfy specific formula obligations. The construction does NOT create "all MCSs between two given MCSs."

### What the Discreteness Axiom DF Actually Guarantees

From `Soundness.lean`, the DF axiom semantically corresponds to:
```
(F⊤ ∧ φ ∧ Hφ) → F(Hφ)
```

Under reflexive semantics, this is trivially satisfied. The DF axiom says:
- If there is a future (F⊤)
- And φ holds now and at all past times (φ ∧ Hφ)
- Then there's a future time where Hφ holds

**This does NOT directly imply**: "All elements between a and b in the canonical model appear at the same stage."

The DF axiom guarantees that the order is "discrete" (non-dense), but this is about **gaps between points**, not about **when representatives appear in the construction**.

---

## Identified Risks

### RISK 1: Stage Bounding Lemma May Be False (Severity: HIGH)

**Statement being claimed**:
```lean
theorem discrete_Icc_stage_bounded (a b : DiscreteTimelineQuot) :
    Set.Icc a b ⊆
    (discreteStagedBuild (max (minStage a) (minStage b))).image (...)
```

**The issue**: This lemma claims that ALL elements between `a` and `b` in the quotient have representatives in stage `max(n_a, n_b)`. But:

1. The construction is formula-enumeration-driven
2. An MCS "between" `M_a` and `M_b` might only be created as a witness for a formula that is enumerated after stage N
3. The staged construction adds points incrementally; later-added points can be CanonicalR-between earlier points

**Evidence this might fail**: Consider three MCSs `M_a`, `M_c`, `M_b` where:
- `CanonicalR M_a M_c` and `CanonicalR M_c M_b`
- `M_a` has some F-formula `F(phi)` with witness `M_b` (added at stage K)
- `M_c` has some F-formula `F(psi)` where `psi` is enumerated at stage K' > K
- `M_c` is only created as a witness at stage K'

Then in the quotient, `[M_c] ∈ Icc [M_a] [M_b]`, but `M_c` only appears at stage K' > K.

### RISK 2: Multiple Representatives with Different minStages (Severity: MEDIUM)

Multiple `StagedPoint`s can have the same underlying MCS but different `introduced_at` stages. When computing `minStage`, we take the minimum. But:

- The "same" quotient element `[c]` has different representatives at different stages
- The proof needs to handle picking the RIGHT representative that is ≤-comparable with both a' and b'

**Mitigation**: Use `Nat.find` to get the minimal stage, then show any representative at stage N works.

### RISK 3: Quotient Lifting Complexity (Severity: MEDIUM)

The proof structure requires lifting from the base preorder to the quotient. Specifically:

- Given `[a] ≤ [c] ≤ [b]` in the quotient
- Need to find representatives `a', c', b'` in the BASE type such that `a' ≤ c' ≤ b'`

The quotient order is defined via `Quotient.lift₂`, and extracting witnesses requires working with `Quotient.inductionOn` and handling the equivalence relation.

**Key lemma needed**: Something like
```lean
lemma exists_rep_chain (a c b : DiscreteTimelineQuot)
    (hac : a ≤ c) (hcb : c ≤ b) :
    ∃ a' c' b' : DiscreteTimelineElem,
      ⟦a'⟧ = a ∧ ⟦c'⟧ = c ∧ ⟦b'⟧ = b ∧ a' ≤ c' ∧ c' ≤ b'
```

This is NOT directly available in Mathlib for `Antisymmetrization`.

### RISK 4: CanonicalR Transitivity Chain Preservation (Severity: LOW-MEDIUM)

The construction ensures `discreteStagedBuild_all_comparable_with_root`: all points are CanonicalR-comparable with the root. But this doesn't directly imply that all points between two given points are present.

The linearity property (`discreteStagedBuild_linear`) says any two points in the same stage are comparable. But it doesn't say all MCSs between them are present.

---

## What is NOT a Risk

### NOT A RISK: Quotient Collapse

The `canonicalR_irreflexive` axiom ensures the quotient doesn't collapse excessively. If `M_a < M_b` in the preorder, then `[M_a] < [M_b]` in the quotient.

### NOT A RISK: Non-terminating Construction

The construction is intentionally infinite (building a countably infinite timeline). This is expected and handled.

### NOT A RISK: Each Stage Finiteness

Each `discreteStagedBuild n` is a `Finset StagedPoint`, so it's finite by construction. The issue is whether intervals in the QUOTIENT are subsets of finite images.

---

## Confidence Level

| Aspect | Confidence | Notes |
|--------|------------|-------|
| Stage bounding lemma correctness | **LOW** | Potential fundamental gap |
| Quotient lifting tractability | Medium | Needs careful proof but doable |
| DF axiom relevance | Low | DF ensures non-density, not stage bounds |
| Alternative approaches needed | **HIGH** | May need different strategy |

---

## Alternative Approaches if Stage Bounding Fails

### Alternative A: Prove LocallyFiniteOrder Differently

Instead of stage bounding, prove interval finiteness via:
1. Show each equivalence class has only finitely many representatives
2. Show the quotient of a locally finite preorder is locally finite

**Challenge**: Mathlib doesn't have `Antisymmetrization.locallyFiniteOrder`.

### Alternative B: Direct IsSuccArchimedean Proof

Skip `LocallyFiniteOrder` entirely and prove `IsSuccArchimedean` directly:
1. Define `succ` explicitly using the successor witness from DF
2. Show `succ` is the covering relation
3. Prove any two elements are finitely many steps apart

**Challenge**: Requires extracting the DF frame condition at the MCS level, which is non-trivial.

### Alternative C: Axiomatize Interval Finiteness

If structural proof is intractable, axiomatize:
```lean
axiom discrete_Icc_finite_axiom :
    ∀ (a b : DiscreteTimelineQuot), (Set.Icc a b).Finite
```

**Current status**: This is exactly what exists now. Task 979 is about REMOVING this axiom.

---

## Recommendations

1. **Do not assume stage bounding is trivially true.** The claim requires careful analysis of the witness structure and may not hold as stated.

2. **Investigate the witness chain structure more deeply.** Specifically: is it true that if `CanonicalR M_a M_c` and `CanonicalR M_c M_b`, then the formulas that force `M_c` into existence are present in `M_a` or `M_b`?

3. **Consider Alternative B (direct IsSuccArchimedean)** if the stage bounding approach fails. The DF axiom directly gives covering relations, which might be more tractable.

4. **If all structural approaches fail**, document clearly why and leave the axiom as technical debt with a clear remediation path.

---

## Summary

The proposed stage-bounding proof has a potentially CRITICAL gap: the claim that all elements between `a` and `b` in the quotient have representatives at stage `max(minStage a, minStage b)` is not obviously true and may be false. The staged construction adds witnesses formula-by-formula, and an intermediate MCS might only be created at a later stage. This is the key obstacle to resolve before proceeding with the proof.
