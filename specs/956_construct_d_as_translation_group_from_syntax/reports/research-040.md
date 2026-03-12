# Research Report: Task #956 - Iteration Termination for density_frame_condition_strict

**Task**: 956 - construct_d_as_translation_group_from_syntax
**Started**: 2026-03-12T14:00:00Z
**Completed**: 2026-03-12T15:30:00Z
**Effort**: Mathlib/codebase search + pattern analysis
**Dependencies**: research-039 (backward strictness analysis)
**Sources/Inputs**: DensityFrameCondition.lean, Saturation.lean, DecisionProcedure.lean, Subformulas.lean, Mathlib
**Artifacts**: This report
**Standards**: report-format.md, return-metadata-file.md

## Executive Summary

- **Three viable approaches** for iteration termination: fuel-based, well-founded on formulas, or direct non-iteration proof
- **Recommended approach**: Fuel-based iteration using existing `expandBranchWithFuel` pattern from Saturation.lean
- **Termination bound**: Formula complexity provides natural upper bound - each iteration uses a distinct distinguishing formula from finite subformula closure
- **Alternative**: Well-founded recursion on `Formula.subformulaCount` via `Nat.lt_wfRel`

## Context & Scope

### The Exact Problem

The `density_frame_condition_strict` theorem needs to guarantee a STRICT intermediate witness between two MCSs M and M'. The non-strict `density_frame_condition` sometimes returns W = M' (Case B1 when M' is reflexive), which collapses in the quotient.

### Research-039 Recommendation (recap)

Research-039 concluded:
1. Direct formula-based proof of backward strictness is difficult under irreflexive semantics
2. Mutual accessibility doesn't lead to formula contradiction
3. **Iteration approach recommended**: Apply density repeatedly until Case A fires

### Research Questions Addressed

1. How to implement iteration without `partial`?
2. What termination measure could work?
3. What relevant Mathlib patterns exist?
4. Is there a direct (non-iteration) alternative?

## Findings

### Finding 1: Fuel-Based Pattern in Codebase

The codebase already uses fuel-based iteration in `Saturation.lean`:

```lean
def expandBranchWithFuel (b : Branch) (fuel : Nat) : Option (ClosedBranch + Branch) :=
  match fuel with
  | 0 => none  -- Out of fuel
  | fuel + 1 =>
      match findClosure b with
      | some reason => some (.inl ⟨b, reason⟩)
      | none =>
          match expandOnce b with
          | .saturated => some (.inr b)
          | .extended newBranch => expandBranchWithFuel newBranch fuel
          | .split branches => ...
termination_by fuel
```

**Key pattern elements**:
- `fuel : Nat` parameter decrements on recursion
- `Option` return type handles fuel exhaustion gracefully
- `termination_by fuel` annotation satisfies Lean's termination checker
- No `partial` keyword needed

### Finding 2: Mathlib Iteration Primitives

Mathlib provides relevant iteration tools:

| Name | Type | Use Case |
|------|------|----------|
| `Nat.iterate` | `(α → α) → Nat → α → α` | Apply function n times |
| `iterateAtMost` | `Nat → m Unit → m Unit` | Tactic iteration with bound |
| `WellFounded.fix` | `{C : α → Sort} → ((x : α) → (∀ y, r y x → C y) → C x) → (x : α) → C x` | Well-founded recursion |

**Most applicable**: `WellFounded.fix` or fuel-based pattern, not `Nat.iterate` (doesn't handle early termination).

### Finding 3: Termination Measure via Formula Complexity

The codebase has `Formula.subformulaCount`:

```lean
def subformulaCount (φ : Formula) : Nat := (subformulas φ).eraseDups.length
```

**Key observation**: Each iteration uses a DIFFERENT distinguishing formula:
- Iteration 1: Uses delta from `distinguishing_formula_exists` applied to M, M'
- Iteration 2: Uses gamma from Case B2 reduction (when M' not reflexive) OR uses new distinguishing formula from seriality future
- Each formula comes from `GContent(M')` or `GContent` of the new target

**Termination argument**: The set of formulas in `GContent(M')` is bounded by `subformulaCount` of some anchor formula. Each iteration either:
1. Returns a strict witness (Case A or Case B2), OR
2. Uses a "fresh" distinguishing formula from a shrinking set

### Finding 4: Seriality Provides Iteration Fuel

The codebase has seriality theorems:

```lean
theorem mcs_contains_seriality_future (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    Formula.some_future (Formula.neg Formula.bot) ∈ M
```

**How this enables iteration**:
1. Case B1 fires when M' is reflexive
2. Apply seriality to M' to get a strict future M'' of M'
3. Apply density between M and M''
4. This uses a different distinguishing formula (from M'') than the original

### Finding 5: Direct Non-Iteration Alternative

Research-039's analysis suggests a potential non-iteration approach:

**Key insight from research-039**: If mutual accessibility (M ~ V) is assumed:
- G(phi) in M iff G(phi) in V (by temp_4 propagation)
- The Lindenbaum process for V is seeded with `{neg(delta)} U GContent(W_1)`
- `F(neg(delta))` propagates from W_1 to V via temp_5 (F(phi) -> G(F(phi)))
- Therefore `G(delta)` is NOT in V (contradicts F(neg(delta)))

**The missing link**: Proving that G(delta) NOT in V combined with assumed CanonicalR(V, M) leads to contradiction requires showing some formula in GContent(V) is NOT in M.

**Candidate**: `P(neg(delta)) = neg(H(delta))` via temp_a

This approach avoids iteration but requires careful formula tracking through the Lindenbaum construction.

## Implementation Patterns

### Pattern A: Fuel-Based Strictness Iteration

```lean
/-- Find strict intermediate with fuel-bounded iteration. -/
def density_strict_with_fuel (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M') (h_not_R' : ¬CanonicalR M' M)
    (fuel : Nat) : Option (∃ W, SetMaximalConsistent W ∧
                           CanonicalR M W ∧ CanonicalR W M' ∧
                           ¬CanonicalR W M ∧ ¬CanonicalR M' W) :=
  match fuel with
  | 0 => none
  | fuel + 1 =>
      -- Get non-strict witness
      let ⟨W, h_W_mcs, h_MW, h_WM'⟩ := density_frame_condition M M' h_mcs h_mcs' h_R h_not_R'
      -- Check strictness
      if h_strict : ¬CanonicalR W M ∧ ¬CanonicalR M' W then
        some ⟨W, h_W_mcs, h_MW, h_WM', h_strict.1, h_strict.2⟩
      else
        -- Case B1: W = M' and M' reflexive
        -- Apply seriality to get strict future of M'
        let M'' := seriality_future_witness M' h_mcs'
        -- Recurse with M'' as new target
        density_strict_with_fuel M M'' h_mcs (seriality_mcs h_mcs')
          (CanonicalR_trans h_R h_WM') (not_R_of_strict_future h_not_R') fuel
termination_by fuel
```

**Advantages**:
- Termination is trivial (`termination_by fuel`)
- Matches existing codebase pattern
- Option return handles edge cases gracefully

**Disadvantages**:
- Requires sufficient fuel bound
- Doesn't prove iteration always succeeds

### Pattern B: Well-Founded Recursion on Formula Measure

```lean
/-- Measure for well-founded recursion: (anchor formula complexity, distinguishing formula complexity) -/
def iterMeasure (M M' : Set Formula) (anchor : Formula) : Nat × Nat :=
  let delta := distinguishing_formula M M' -- conceptual
  (anchor.subformulaCount, delta.complexity)

/-- Strict density via well-founded recursion. -/
def density_strict_wf (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M') (h_not_R' : ¬CanonicalR M' M) :
    ∃ W, SetMaximalConsistent W ∧ CanonicalR M W ∧ CanonicalR W M' ∧
         ¬CanonicalR W M ∧ ¬CanonicalR M' W := by
  -- Use well-founded induction on formula complexity
  obtain ⟨delta, h_G_delta_M', h_delta_not_M⟩ := distinguishing_formula_exists h_mcs h_mcs' h_not_R'
  induction delta using Formula.recOnFormula generalizing M M' with
  | ... =>
    -- Case analysis as in current proof
    -- Recursive calls use simpler distinguishing formula
```

**Advantages**:
- Proves iteration always succeeds
- No Option return type

**Disadvantages**:
- More complex termination proof
- Requires showing measure decreases

### Pattern C: Bounded Iteration via Subformula Property

```lean
/-- Iteration bound from subformula closure. -/
def strictnessIterBound (M M' : Set Formula) (anchor : Formula) : Nat :=
  (anchor.subformulas.eraseDups.length) + 1

theorem density_strict_bounded (M M' : Set Formula) (anchor : Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M') (h_not_R' : ¬CanonicalR M' M)
    (h_anchor : ∀ φ ∈ GContent M', φ ∈ anchor.subformulas) :
    (density_strict_with_fuel M M' h_mcs h_mcs' h_R h_not_R'
      (strictnessIterBound M M' anchor)).isSome := by
  -- Prove fuel suffices
  sorry
```

**Advantages**:
- Connects fuel to formula complexity
- Proves fuel always suffices

**Disadvantages**:
- Requires anchor formula
- More complex setup

## Recommendations

### Primary Recommendation: Fuel-Based Pattern (Pattern A)

**Rationale**:
1. Matches existing codebase style (Saturation.lean)
2. Trivial termination proof
3. Option return is acceptable for this use case
4. Implementation is straightforward

**Implementation Steps**:
1. Add `seriality_future_witness` helper to get strict future of reflexive MCS
2. Implement `density_strict_with_fuel` following Pattern A
3. Use reasonable fuel bound (e.g., 100) for initial implementation
4. Optionally prove fuel sufficiency later

**Estimated effort**: 2-3 hours

### Alternative Recommendation: Direct Proof via P(neg(delta))

If avoiding iteration is preferred:

1. Prove that temp_a gives `P(neg(delta)) = neg(H(delta))` in `GContent(V)`
2. Use HContent duality to derive contradiction from assumed `CanonicalR(V, M)`
3. The key is showing `H(delta) NOT in M` from the distinguishing formula properties

**Risk**: This approach has already been attempted in research-039 without clear success. The iteration approach is more robust.

### NOT Recommended

1. **Well-founded recursion on formulas**: More complex than fuel-based, unclear measure
2. **Assuming strictness always holds**: Mathematically incorrect (Case B1 exists)
3. **Using `partial`**: Violates Lean 4 verification principles

## Mathlib Relevance

### Useful Theorems

| Theorem | Use |
|---------|-----|
| `WellFounded.fix` | Alternative to fuel-based if measure is found |
| `Nat.lt_wfRel` | Well-foundedness of Nat < |
| `List.length_eraseDups_le` | Bound subformula count |

### Not Directly Applicable

| Pattern | Why Not |
|---------|---------|
| `Nat.iterate` | Doesn't handle early termination |
| `Computation.Terminates` | Over-engineered for this use case |

## Risk Assessment

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Fuel insufficient | MEDIUM | LOW | Use generous bound; prove sufficiency later |
| Seriality witness not strict | LOW | LOW | Seriality axiom guarantees F(T), which gives fresh MCS |
| Iteration doesn't converge | LOW | VERY LOW | Each iteration uses distinct formula from finite set |

## Context Extension Recommendations

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| Fuel-based iteration pattern | Finding 1 | Yes (Saturation.lean) | No gap |
| Seriality-based iteration | Finding 4 | Partial | extension |

## Decisions

1. **Fuel-based approach is recommended** - simplest termination, matches codebase style
2. **Seriality enables iteration progress** - each iteration gets fresh target
3. **Subformula bound is theoretical fuel limit** - finite formula space guarantees termination

## Appendix

### Search Queries Used

**Mathlib MCP**:
- `lean_leansearch`: "iteration with fuel parameter nat recursive termination" - found Nat.iterate, iterateAtMost
- `lean_leansearch`: "well-founded recursion custom measure termination" - found IsWellFounded.fix
- `lean_leanfinder`: "function that tries operation repeatedly until success with bounded fuel" - found iterateAtMost, Estimator.improveUntilAux
- `lean_leanfinder`: "subformula ordering well-founded" - found WellFounded.rank, Formula induction

**Local Search**:
- `lean_local_search`: "WellFounded" - found WellFoundedLT, Set.WellFoundedOn
- `lean_local_search`: "Nat.iterate" - confirmed availability
- `lean_local_search`: "subformula" - found Formula.subformulas, subformulaCount
- `lean_local_search`: "seriality" - found mcs_contains_seriality_future

**Codebase Grep**:
- `fuel` patterns - found expandBranchWithFuel in Saturation.lean
- `termination_by` - confirmed usage pattern

### Key Code References

1. **Fuel pattern**: `Theories/Bimodal/Metalogic/Decidability/Saturation.lean:92` - `expandBranchWithFuel`
2. **Subformula count**: `Theories/Bimodal/Syntax/Subformulas.lean:47` - `subformulaCount`
3. **Seriality**: `Theories/Bimodal/Metalogic/Canonical/CanonicalTimeline.lean:84` - `mcs_contains_seriality_future`
4. **Density non-strict**: `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean:169` - `density_frame_condition`
