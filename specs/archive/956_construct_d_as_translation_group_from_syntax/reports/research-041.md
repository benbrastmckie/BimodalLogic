# Research Report: Task #956 - Mathematical Correctness Comparison of Iteration Patterns

**Task**: 956 - construct_d_as_translation_group_from_syntax
**Started**: 2026-03-12T16:00:00Z
**Completed**: 2026-03-12T17:30:00Z
**Effort**: Deep Mathlib search + theorem strength analysis
**Dependencies**: research-040 (iteration termination patterns)
**Sources/Inputs**: Mathlib (WellFounded, Finset.strongInduction), DensityFrameCondition.lean, Saturation.lean
**Artifacts**: This report
**Standards**: report-format.md, proof-debt-policy.md

## Project Context

- **Upstream Dependencies**: DensityFrameCondition.lean (non-strict), SeparationLemma.lean, CanonicalTimeline.lean
- **Downstream Dependents**: CantorApplication.lean (DenselyOrdered proof), DFromSyntax.lean, TaskFrame completeness
- **Alternative Paths**: Direct formula-based proof (attempted in research-039, inconclusive)
- **Potential Extensions**: Pattern C approach could upgrade all fuel-based patterns in codebase

## Executive Summary

- **Pattern B (well-founded on formula measure) gives the STRONGEST theorem** - proves termination always succeeds without Option return type
- **Pattern C (bounded iteration with fuel sufficiency) is equivalent in strength** to Pattern B but requires additional lemma
- **Pattern A (fuel-based with Option) is mathematically WEAKEST** - doesn't prove iteration always succeeds
- **Subformula ordering IS well-founded** via `Finset.lt_wf` and `InvImage.wf`
- **Recommended approach**: Pattern B using `Finset.strongInduction` on distinguishing formula set
- **Codebase upgrade opportunity**: 3 functions in Saturation.lean could be strengthened

## Context & Scope

### Research Questions from Delegation

1. Which pattern gives the strongest theorem statement?
2. Is well-founded recursion on formula complexity feasible?
3. Where in the codebase could fuel-based patterns be upgraded?
4. What is the uniform quality standard?

### Theorem Strength Hierarchy

Pattern A:
```lean
theorem density_strict_with_fuel (M M' : Set Formula) ... (fuel : Nat) :
  Option (Exists W, ...) := ...
-- Requires: exists fuel, (f fuel).isSome
-- WEAK: Existence of sufficient fuel is NOT proven
```

Pattern B:
```lean
theorem density_strict_wf (M M' : Set Formula) ... :
  Exists W, SetMaximalConsistent W AND CanonicalR M W AND CanonicalR W M' AND
       NOT CanonicalR W M AND NOT CanonicalR M' W := ...
-- STRONG: Termination proven via well-founded induction
-- No Option, no fuel - the theorem IS total
```

Pattern C:
```lean
theorem density_strict_bounded (M M' : Set Formula) (anchor : Formula) ... :
  (density_strict_with_fuel M M' ... (strictnessIterBound anchor)).isSome := ...
-- EQUIVALENT to B: Proves fuel suffices
-- Compositional: fuel function + sufficiency proof
```

**Mathematical Strength Ordering**: Pattern B = Pattern C > Pattern A

## Findings

### Finding 1: Well-Founded Ordering on Formulas EXISTS in Mathlib

**Key theorems discovered**:

| Theorem | Type | Use Case |
|---------|------|----------|
| `Finset.lt_wf` | `WellFounded (@LT.lt (Finset alpha) _)` | Well-foundedness of strict subset on finite sets |
| `Finset.strongInduction` | Strong induction on finite sets by cardinality | Iterate on shrinking set of candidates |
| `InvImage.wf` | `(f : alpha -> beta) -> WellFounded r -> WellFounded (InvImage r f)` | Lift well-foundedness via measure function |
| `WellFounded.fix` | `WellFounded r -> ((x : alpha) -> (forall y, r y x -> C y) -> C x) -> forall x, C x` | General well-founded recursion |

**Application to density iteration**:

The key insight is that each iteration uses a DIFFERENT distinguishing formula from GContent(M'). The set of "candidate distinguishing formulas" is:

```lean
def candidateFormulas (M M' : Set Formula) : Finset Formula :=
  { phi IN GContent(M') | phi NOT IN M }
```

This set is FINITE (bounded by subformulaCount of any anchor formula containing all relevant formulas).

Each iteration either:
1. Returns a strict witness (success), OR
2. Uses a formula phi from candidateFormulas and "eliminates" it for the next iteration

By `Finset.strongInduction`, iteration terminates because the candidate set shrinks.

### Finding 2: Formula Measure for Well-Founded Recursion

The codebase has:

```lean
def Formula.subformulaCount (phi : Formula) : Nat := (subformulas phi).eraseDups.length
```

Combined with `subformulas_trans`, we can define:

```lean
def distinguishingMeasure (M M' : Set Formula) (anchor : Formula) : Nat :=
  ({ phi IN anchor.subformulas | G(phi) IN M' AND phi NOT IN M }.card
```

**Termination argument**: Each iteration either succeeds OR reduces this measure by at least 1 (the current distinguishing formula is "consumed").

### Finding 3: Pattern Comparison - Mathematical Correctness

| Aspect | Pattern A (Fuel) | Pattern B (Well-Founded) | Pattern C (Bounded) |
|--------|-----------------|-------------------------|---------------------|
| **Theorem type** | `Option (Exists W, ...)` | `Exists W, ...` | `(f fuel).isSome` |
| **Proves termination** | NO (requires external fuel bound) | YES (intrinsic) | YES (via sufficiency lemma) |
| **Proof complexity** | Low | Medium | Medium-High |
| **Matches Saturation.lean** | YES | NO (different style) | Partially |
| **Publication quality** | Tolerable | High | High |
| **Codebase consistency** | Consistent | Would set new standard | Bridges old/new |

**Key Observation**: Pattern A is NOT mathematically weak in the sense of being incorrect - it just doesn't prove as much. The theorem `density_strict_with_fuel` is TRUE, but it doesn't prove that iteration always succeeds. For a publication-quality metalogic, Pattern B or C proves the STRONGER claim.

### Finding 4: Codebase Audit - Fuel-Based Patterns

**Saturation.lean** (could be upgraded):
1. `expandBranchWithFuel` - returns `Option (ClosedBranch + Branch)` - could be total via well-founded on branch complexity
2. `buildTableau` - returns `Option ExpandedTableau` - could prove fuel suffices
3. `expandBranchesWithFuel` - returns `BranchListResult` - already partially handles fuel issues

**Current Quality**: These are acceptable for decidability (timeout case is explicitly handled). For mathematical completeness theorems, Pattern B/C is preferred.

### Finding 5: Implementation Roadmap for Pattern B

```lean
-- Step 1: Define the candidate set
def candidateFormulas (M M' : Set Formula) (anchor : Formula) : Finset Formula :=
  (anchor.subformulas.toFinset).filter (fun phi => G(phi) IN M' AND phi NOT IN M)

-- Step 2: Use Finset.strongInduction
theorem density_frame_condition_strict_wf
    (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M')
    (h_not_R' : NOT CanonicalR M' M)
    (anchor : Formula)
    (h_anchor : forall phi, G(phi) IN M' -> phi IN anchor.subformulas) :
    Exists W, SetMaximalConsistent W AND CanonicalR M W AND CanonicalR W M' AND
         NOT CanonicalR W M AND NOT CanonicalR M' W := by
  -- Use Finset.strongInduction on candidateFormulas
  apply Finset.strongInduction (p := fun candidates => ...)
  -- ... rest of proof
```

**Technical Challenge**: The iteration doesn't directly shrink a Finset; it changes the target MCS. The measure is:
- `(anchor.subformulaCount, Prop.toNat (CanonicalR M' M'))` lexicographically
- OR: `candidateFormulas M M' anchor` with `M'` changing each iteration

### Finding 6: Case B1 Strictness - The Core Challenge

Research-040 noted that Case B1 (M' reflexive) returns W = M', which collapses in the quotient. The current sorries in `density_frame_condition_strict` are all related to this.

**Pattern B solution**: When Case B1 fires, apply seriality to M' to get a strict future M'', then recurse with density(M, M''). The recursion is well-founded because:
1. We're now looking for a distinguishing formula between M and M'' (a different set)
2. The depth of "Case B1 chaining" is bounded by the number of reflexive MCSs in the subformula closure

**Key insight**: Seriality guarantees F(T) IN M', so there exists M'' with CanonicalR(M', M'') and T IN M''. By linearity, either:
- CanonicalR(M'', M): Contradicts NOT CanonicalR(M', M) via transitivity (need to verify)
- CanonicalR(M, M''): Apply density recursively
- M'' = M: Would mean M reflexive, combined with M' reflexive and CanonicalR(M, M'), contradicts NOT CanonicalR(M', M)

## Recommendations

### Primary Recommendation: Pattern B via Lexicographic Measure

**Rationale**:
1. Proves the STRONGEST theorem (no Option return type)
2. Mathematically establishes iteration ALWAYS succeeds
3. Sets uniform quality standard for metalogic
4. Uses established Mathlib patterns (`Finset.strongInduction`, `InvImage.wf`)

**Implementation approach**:
```lean
-- Lexicographic measure: (reflexivity chain depth, candidate formula count)
-- Each iteration either:
--   (a) Decreases reflexivity chain depth (seriality application)
--   (b) Stays at same depth but decreases candidate count (formula consumed)
-- Both well-founded by Prod.lex_wf
```

**Estimated effort**: 4-6 hours (more complex than Pattern A, but mathematically superior)

### Alternative Recommendation: Pattern C (if time-constrained)

If Pattern B proves difficult, Pattern C bridges the gap:
1. Keep the fuel-based function from Pattern A
2. Add a separate lemma proving fuel sufficiency
3. Final theorem combines both: `Exists W, ... := (fuel_suffices ...).some`

**Estimated effort**: 3-4 hours

### NOT Recommended: Pattern A alone

Pattern A without fuel sufficiency proof is acceptable for decidability procedures but NOT for the core completeness theorems. The metalogic should establish that iteration ALWAYS succeeds, not just "succeeds if you give enough fuel."

## ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| N/A | Low | No relevant dead ends for iteration patterns |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| D Construction from Canonical Timeline | ACTIVE | Pattern B aligns with goal of high-quality metalogic |
| Representation-First Architecture | CONCLUDED | Pattern B supports representation theorem quality |

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Lexicographic measure difficult to establish | MEDIUM | MEDIUM | Fall back to Pattern C (compositional approach) |
| Case B1 seriality chaining complex | MEDIUM | MEDIUM | Detailed case analysis, may need auxiliary lemmas |
| Proof complexity higher than expected | LOW | MEDIUM | Pattern C as fallback preserves progress |

## Decisions

1. **Pattern B is mathematically strongest** - proves iteration always succeeds
2. **Finset.strongInduction provides the mechanism** - well-foundedness of subset ordering
3. **Current codebase has 3 upgrade opportunities** in Saturation.lean (non-blocking, different purpose)
4. **Case B1 requires seriality-based recursion** - bounded by reflexivity chain depth

## Appendix

### Search Queries Used

**Mathlib MCP**:
- `lean_loogle`: `WellFounded ?r -> (forall x, (forall y, ?r y x -> ?C y) -> ?C x) -> forall x, ?C x` - found `WellFounded.fix`
- `lean_leansearch`: "finite set iteration terminates because set decreases in cardinality" - found `Finset.card_erase_lt_of_mem`, `Finset.strongInduction`
- `lean_leanfinder`: "recursion on decreasing set cardinality well-founded induction on finite sets" - found `Finset.lt_wf`, `Finset.strongInduction`
- `lean_loogle`: `InvImage.wf` - found `InvImage.wf : (f : alpha -> beta) -> WellFounded r -> WellFounded (InvImage r f)`

**Local Search**:
- `lean_local_search`: "WellFounded" - found `WellFoundedLT`, `Set.WellFoundedOn`
- `lean_local_search`: "subformula" - found `Formula.subformulas`, `subformulaCount`
- `lean_local_search`: "strongInduction" - found `Finset.strongInduction`, `Finset.strongInductionOn`

### Key Mathlib References

1. **Well-founded recursion**: `Init/WF.lean` - `WellFounded.fix`, `WellFounded.induction`
2. **Finite set induction**: `Mathlib/Data/Finset/Card.lean` - `Finset.strongInduction`
3. **Measure-based well-foundedness**: `Init/WF.lean` - `InvImage.wf`
4. **Order well-foundedness**: `Mathlib/Order/RelClasses.lean` - `IsWellFounded.fix`

### Theorem Strength Example

Pattern A theorem (current):
```lean
-- Proves: There EXISTS some fuel value that works
-- Does NOT prove: What that fuel value is, or that it always works
theorem density_strict_fuel_exists :
  Exists fuel, (density_strict_with_fuel M M' h_mcs h_mcs' h_R h_not_R' fuel).isSome
```

Pattern B theorem (recommended):
```lean
-- Proves: The witness EXISTS (unconditionally)
-- Termination is INTRINSIC to the proof structure
theorem density_strict_wf :
  Exists W, SetMaximalConsistent W AND CanonicalR M W AND CanonicalR W M' AND
       NOT CanonicalR W M AND NOT CanonicalR M' W
```

The difference: Pattern B's theorem type is STRONGER. It doesn't require the caller to know or provide fuel.
