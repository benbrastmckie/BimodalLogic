# Risk Analysis: LocallyFiniteOrder Proof for Discrete Timeline

**Teammate C Analysis - Task 974**
**Date**: 2026-03-16

## Executive Summary

The LocallyFiniteOrder proof for `DiscreteTimelineQuot` faces **HIGH RISK** due to a fundamental gap: Mathlib has no `Antisymmetrization.locallyFiniteOrder` instance, and the discrete staged construction does not obviously bound elements between quotient classes.

**Confidence Level**: MEDIUM (60%) that the approach is mathematically sound, but LOW (30%) confidence in easy formalization.

---

## Key Risks

### 1. **CRITICAL: No Antisymmetrization.locallyFiniteOrder in Mathlib**

**Status**: BLOCKING

The quotient type is:
```lean
def DiscreteTimelineQuot :=
  Antisymmetrization (DiscreteTimelineElem root_mcs root_mcs_proof) (· ≤ ·)
```

Mathlib provides:
- `instPartialOrderAntisymmetrization` - partial order on quotient
- `LinearOrder` from `IsTotal` on preorder
- `instWellFoundedLTAntisymmetrization` - if base is well-founded

**Missing**: `LocallyFiniteOrder` instance for `Antisymmetrization`.

**Why this is critical**: LocallyFiniteOrder requires computing `Finset.Icc a b` - the finite set of elements between `a` and `b`. For a quotient, this requires:
1. Lifting the interval from the base type
2. Proving the quotient map preserves finiteness
3. Handling equivalence classes (multiple pre-images)

### 2. **SERIOUS: Quotient Elements May Have Unbounded Pre-images**

The quotient identifies `StagedPoint`s with equal underlying MCS:
```lean
-- Two StagedPoints are equivalent if:
a.mcs = b.mcs
```

A single MCS can appear at **arbitrarily many stages** in the construction (as the same MCS is re-used). While each stage is finite, a single equivalence class could theoretically correspond to infinitely many `StagedPoint`s.

**Mitigation needed**: Prove that each MCS appears at most once in the construction (uniqueness of introduced_at per MCS), OR prove that the quotient interval is still finite regardless.

### 3. **MODERATE: Stage-Bounded Finiteness Not Established**

The current approach assumes:
> "The discrete timeline has finitely many MCSs between any two comparable MCSs because each step in the staged construction adds only finitely many witnesses."

**Gap**: This reasoning is informal. The actual proof needs:

1. For quotient elements `[a], [b]` with `[a] < [b]`:
   - Find stage bounds `n_a, n_b` where representatives were introduced
   - Show all elements `[c]` with `[a] < [c] < [b]` have representatives in `discreteStagedBuild (max n_a n_b + k)` for some bounded `k`

2. This requires proving:
   - New witnesses are "local" (don't create unbounded chains)
   - The discreteness axiom DF prevents infinitely many intermediates

### 4. **MODERATE: DF Frame Condition Extraction Incomplete**

The discreteness axiom DF = `(F T and phi and H phi) -> F(H phi)` corresponds to immediate successors. But the proof that this **prevents infinite intermediates** in the quotient is not formalized.

Current state (from DiscreteTimeline.lean:237):
```lean
theorem discrete_timeline_lt_succFn (a : DiscreteTimelineQuot ...) :
    a < LinearLocallyFiniteOrder.succFn a := by
  -- ... requires showing discrete timeline is not densely ordered
  sorry
```

---

## Missing Lemmas

### Must Prove (No Mathlib Support)

| Lemma | Description | Difficulty |
|-------|-------------|------------|
| `Antisymmetrization.locallyFiniteOrder` | LFO on quotient from LFO on base | HIGH - may not exist in general |
| `discreteStagedBuild_stage_bounded_Icc` | Elements in [a,b] come from bounded stages | MEDIUM |
| `discrete_mcs_unique_introduced_at` | Each MCS appears at one stage | LOW-MEDIUM |

### May Need to Prove

| Lemma | Description | Status |
|-------|-------------|--------|
| `DF_prevents_density` | DF axiom excludes dense intermediates | Needs formalization |
| `quotient_interval_finite_of_preorder_stage_bounded` | Custom LFO from stage bounds | Alternative approach |

---

## Edge Cases

### 1. **Infinite Encoding Values**

Formulas are enumerated via `Encodable.ofCountable`. The encoding function maps formulas to `Nat`, but:
- Some natural numbers may not correspond to valid formulas (`decodeFormulaStaged k = none`)
- Infinitely many stages process infinitely many formulas

**Risk**: Construction never "terminates" - the union is infinite. However, this is **expected** (countable, not finite timeline).

**Actual concern**: For a fixed interval `[a, b]`, are there finitely many formulas whose witnesses could fall in that interval?

### 2. **Non-Terminating Construction**

The staged construction runs forever (`omega` stages). This is intentional for building a countable dense order.

**Not a risk** for LocallyFiniteOrder - we need finiteness of intervals, not of the whole type.

### 3. **Collapse to Single Equivalence Class**

Could the quotient collapse to a single point if all MCSs are mutually CanonicalR-related?

**Analysis**: The `canonicalR_irreflexive` axiom prevents this. Two distinct MCSs M, N with mutual CanonicalR would violate irreflexivity (since CanonicalR M M would hold via M R N R M chain, but CanonicalR is irreflexive).

**Status**: Handled by existing `canonicalR_strict` lemma.

### 4. **Encoding-Dependent Order Artifacts**

The construction order depends on formula encoding. Different encodings could produce different quotient structures.

**Assessment**: LOW RISK. The quotient should be isomorphic regardless of encoding (up to the axioms determining structure). But this is not formally verified.

---

## Alternative Approaches

### Approach A: Direct LocallyFiniteOrder (Current)

Prove `LocallyFiniteOrder` directly by showing intervals are finite.

**Pros**: Matches Mathlib patterns
**Cons**: Requires custom `Antisymmetrization.locallyFiniteOrder`

### Approach B: Via IsSuccArchimedean

If we prove:
1. `SuccOrder` (current approach via `discrete_timeline_lt_succFn`)
2. `PredOrder` (current approach via `discrete_timeline_predFn_lt`)
3. `IsSuccArchimedean` (exists n, succ^n a = b)

Then Mathlib gives `LocallyFiniteOrder` automatically.

**Critical dependency**: `LinearLocallyFiniteOrder.instIsSuccArchimedean` requires proving the succ function is well-defined, which circles back to discreteness/coverness.

### Approach C: Stage-Bounded Finset Construction

Skip `LocallyFiniteOrder` typeclass. Instead, directly construct:
```lean
def quotient_Icc (a b : DiscreteTimelineQuot) : Finset DiscreteTimelineQuot :=
  -- Use stage bounds to find finite covering set
  -- Then quotient and filter to [a, b]
```

**Pros**: More direct control
**Cons**: Doesn't integrate with Mathlib's interval lemmas

---

## Recommendations

1. **Priority 1**: Establish uniqueness of MCS introduction stage
   - Prove `forall p q, p.mcs = q.mcs -> p.introduced_at = q.introduced_at`
   - This simplifies quotient analysis

2. **Priority 2**: Prove stage-bounded interval lemma
   - For `[a], [b]` with representative stages `n_a, n_b`
   - All `[c]` in `([a], [b])` have representatives by stage `max n_a n_b + 1`

3. **Priority 3**: Formalize DF coverness extraction
   - Complete `discrete_timeline_lt_succFn` sorry
   - This unlocks the SuccOrder approach

4. **Fallback**: If `Antisymmetrization.locallyFiniteOrder` proves intractable:
   - Use `OrderIso.locallyFiniteOrder` via explicit isomorphism to Int
   - This requires proving the iso first (but iso depends on IsSuccArchimedean)

---

## Summary Table

| Component | Status | Risk | Blocking? |
|-----------|--------|------|-----------|
| Antisymmetrization.locallyFiniteOrder | Missing | HIGH | YES |
| Stage-bounded interval | Unproven | MEDIUM | YES |
| MCS uniqueness | Unproven | LOW | Helpful |
| DF coverness | Sorry | MEDIUM | YES |
| Encoding issues | Analyzed | LOW | No |
| Quotient collapse | Handled | LOW | No |

---

## Files Examined

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` (lines 237-351)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/StagedConstruction/StagedExecution.lean` (lines 976-1146)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/StagedConstruction/StagedTimeline.lean` (lines 81-193)
- Mathlib: `Order.Antisymmetrization`, `Order.Interval.Finset.Defs`, `Order.SuccPred.LinearLocallyFinite`
