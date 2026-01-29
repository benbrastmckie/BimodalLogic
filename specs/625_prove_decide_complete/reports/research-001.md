# Research Report: Task #625

**Task**: Prove the `decide_complete` theorem
**Date**: 2026-01-29
**Focus**: Decision procedure completeness from tableau completeness

## Summary

The `decide_complete` theorem at line 154 of `Correctness.lean` requires proving that for a valid formula, the decision procedure eventually returns `.valid proof` with sufficient fuel. This builds on `tableau_complete` (Task 624) but needs additional work to bridge the gap between tableau validity and proof extraction.

## Findings

### 1. Current Theorem Statement

```lean
theorem decide_complete (φ : Formula) (hvalid : ⊨ φ) :
    ∃ (fuel : Nat), ∃ proof, decide φ 10 fuel = .valid proof := by
  sorry  -- Requires tableau completeness; fuel bound from Representation.FiniteModelProperty
```

The theorem states: for a semantically valid formula, there exists sufficient fuel such that `decide` returns `.valid` with a proof term.

### 2. Available Dependencies

**From Task 624 (`tableau_complete`)**:
```lean
theorem tableau_complete (φ : Formula) :
    (⊨ φ) → ∃ (fuel : Nat), (buildTableau φ fuel).isSome ∧
             ∀ t, buildTableau φ fuel = some t → t.isValid
```

This guarantees that for valid formulas, `buildTableau` terminates and returns `.allClosed`.

**From Saturation module**:
- `buildTableau_terminates`: Termination with sufficient fuel (currently `sorry`)
- `recommendedFuel φ`: Automatic fuel calculation

**From FMP module (Metalogic_v2)**:
- `semanticWorldState_card_bound`: Bound on model size ≤ 2^closureSize
- `validity_decidable_via_fmp`: Validity is decidable

### 3. Gap Analysis: `decide` vs `buildTableau`

The key complexity is that `decide` has multiple code paths:

```lean
def decide (φ : Formula) (searchDepth : Nat := 10) (tableauFuel : Nat := 1000)
    : DecisionResult φ :=
  -- Fast path 1: direct axiom proof
  match tryAxiomProof φ with
  | some proof => .valid proof
  | none =>
    -- Fast path 2: proof search
    match bounded_search_with_proof [] φ searchDepth with
    | (some proof, _, _) => .valid proof
    | (none, _, _) =>
      -- Fall back to tableau method
      match buildTableau φ tableauFuel with
      | none => .timeout
      | some (.allClosed closedBranches) =>
          -- Extract proof from closed branches
          let axiomProofs := closedBranches.filterMap ...
          match axiomProofs.head? with
          | some proof => .valid proof
          | none =>
              -- Try deeper proof search
              match bounded_search_with_proof [] φ (searchDepth * 2) with
              | (some proof, _, _) => .valid proof
              | (none, _, _) => .timeout  -- Valid but no proof extracted!
      | some (.hasOpen ...) => .invalid (...)
```

**Critical Issue**: Even when `buildTableau` returns `.allClosed` (tableau proves validity), `decide` may still return `.timeout` if proof extraction fails.

### 4. Proof Extraction Gap

The core challenge is that `tableau_complete` guarantees `.allClosed` but `decide_complete` requires extracting a `DerivationTree [] φ` proof term. The current implementation:

1. Tries to extract axiom proofs from closed branches
2. Falls back to proof search with doubled depth
3. Returns `.timeout` if both fail

For completeness, we need to ensure at least one path succeeds. Options:

**Option A**: Strengthen proof extraction from closed branches
- Requires implementing systematic proof reconstruction from tableau closure reasons
- Non-trivial but theoretically sound

**Option B**: Prove proof search is complete (with sufficient depth)
- Requires proving that `bounded_search_with_proof` finds all provable formulas
- Depends on proof search completeness (potentially complex)

**Option C**: Use FMP-based decidability directly
- The Metalogic_v2 version uses `validity_decidable_via_fmp` which provides a `Decidable` instance
- Could bypass the operational `decide` function

### 5. Recommended Approach

The cleanest approach combines:

1. **Use `tableau_complete`** to establish that for valid φ, `buildTableau` returns `.allClosed`
2. **Add a stronger proof extraction lemma** showing that `.allClosed` implies proof construction is possible
3. **Or**: Modify the theorem statement to use `decideAuto` with FMP-based fuel bounds

### 6. Blockers and Dependencies

**Hard Dependencies**:
- `buildTableau_terminates` (currently `sorry`) - needed for fuel existence
- `open_branch_implies_not_valid` (axiom) - used by `tableau_complete`

**Soft Dependencies**:
- Proof extraction from closed branches - needed for `.valid` return
- Proof search completeness - alternative path for proof extraction

### 7. Comparison with Metalogic_v2

Metalogic_v2 takes a different approach by using FMP-based decidability:
```lean
noncomputable instance validity_decidable_via_sat (φ : Formula) :
    Decidable (⊨ φ) :=
  validity_decidable_via_fmp φ
```

This sidesteps the proof extraction problem by using `Classical.dec` to establish decidability without constructing explicit proof terms.

## Recommendations

### Recommended Implementation Strategy

1. **Short-term (complete the theorem)**: Prove `decide_complete` using the following structure:
   ```lean
   theorem decide_complete (φ : Formula) (hvalid : ⊨ φ) :
       ∃ (fuel : Nat), ∃ proof, decide φ 10 fuel = .valid proof := by
     -- From tableau_complete, we get fuel where buildTableau terminates and isValid
     obtain ⟨fuel, h_terminates, h_valid⟩ := tableau_complete φ hvalid
     -- Need to show decide with this fuel returns .valid
     -- This requires bridging proof extraction
     sorry
   ```

2. **Medium-term (strengthen extraction)**: Add lemma:
   ```lean
   theorem allClosed_implies_provable (φ : Formula) (closedBranches : List ClosedBranch)
       (h : buildTableau φ fuel = some (.allClosed closedBranches)) :
       ∃ proof : DerivationTree [] φ, True := by
     -- Reconstruct proof from closure reasons
     sorry
   ```

3. **Alternative (use classical)**: Accept a weaker statement:
   ```lean
   theorem decide_complete_classical (φ : Formula) (hvalid : ⊨ φ) :
       ∃ (fuel : Nat), (decide φ 10 fuel).isValid = true := by
     -- Uses tableau validity without explicit proof term
   ```

### Estimated Effort

| Approach | Effort | Completeness |
|----------|--------|--------------|
| Bridge with sorry | 1-2 hours | Partial |
| Strengthen proof extraction | 4-8 hours | Full |
| Classical weakening | 1 hour | Weaker statement |

## References

- `Theories/Bimodal/Boneyard/Metalogic/Decidability/Correctness.lean` - Main theorem location
- `Theories/Bimodal/Boneyard/Metalogic/Decidability/DecisionProcedure.lean` - `decide` function
- `Theories/Bimodal/Boneyard/Metalogic/Decidability/Saturation.lean` - `buildTableau`
- `specs/624_prove_tableau_complete/summaries/implementation-summary-20260129.md` - Task 624 summary

## Next Steps

1. Implement the proof using `tableau_complete` dependency
2. Identify whether proof extraction strengthening is needed or if a `sorry` is acceptable
3. Consider whether the theorem statement should be weakened to match what can be proved cleanly
