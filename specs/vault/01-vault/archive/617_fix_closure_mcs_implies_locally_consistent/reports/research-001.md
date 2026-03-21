# Research Report: Task #617

**Task**: Fix the sorry in `closure_mcs_implies_locally_consistent`
**Date**: 2026-01-19
**Focus**: Temporal reflexivity axioms issue in finite world state construction

## Summary

The `closure_mcs_implies_locally_consistent` theorem at `FiniteWorldState.lean:338-343` cannot be proven because `IsLocallyConsistent` requires temporal reflexivity axioms (H phi -> phi, G phi -> phi) which are NOT valid in TM logic's strict temporal semantics. The semantic approach via `SemanticCanonicalModel` already bypasses this issue entirely. The recommended fix is to remove the temporal reflexivity conditions from `IsLocallyConsistent` since they are architecturally unsound.

## Problem Analysis

### The IsLocallyConsistent Definition (lines 114-142)

The `IsLocallyConsistent` predicate requires 5 conditions:
1. Bot is false
2. Implications are respected (modus ponens closed)
3. Modal T axiom: box(psi) -> psi
4. **Temporal past reflexivity**: all_past(psi) -> psi
5. **Temporal future reflexivity**: all_future(psi) -> psi

### TM Logic's Strict Temporal Semantics

Looking at `Theories/Bimodal/Semantics/Truth.lean:109-110`:
```lean
| Formula.all_past φ => ∀ (s : D), s < t → truth_at M τ s φ
| Formula.all_future φ => ∀ (s : D), t < s → truth_at M τ s φ
```

The temporal operators use **strict inequality**:
- `all_past φ` quantifies over s **strictly less than** t
- `all_future φ` quantifies over s **strictly greater than** t

This means **the current time t is excluded** from the quantification. As a result:
- `H φ → φ` (past reflexivity) is NOT a valid axiom
- `G φ → φ` (future reflexivity) is NOT a valid axiom

### Why the Theorem Cannot Be Proven

The `closure_mcs_implies_locally_consistent` theorem tries to prove:
- If S is a `ClosureMaximalConsistent` set, then `assignmentFromClosureMCS` produces an `IsLocallyConsistent` assignment

For conditions 1-3, this works:
- Bot consistency: MCS sets cannot contain bot (set consistency)
- Implication: MCS are closed under modus ponens
- Modal T: The T axiom (box φ → φ) IS a valid axiom in TM logic

For conditions 4-5, this fails:
- The MCS S inherits from the TM proof system
- The TM proof system has NO axioms like `H φ → φ` or `G φ → φ`
- Therefore, we cannot prove that `all_past(psi) ∈ S` implies `psi ∈ S`

This is documented in both locations:
- `FiniteWorldState.lean:334-336`
- `FiniteCanonicalModel.lean:1291-1298`

## Current Architecture Status

### Files with Related Sorries

1. **FiniteWorldState.lean:343** - The sorry under investigation
2. **FiniteCanonicalModel.lean:1302** - Same sorry in old Metalogic
3. **Closure.lean:484** - Double negation escape in `closure_mcs_neg_complete`
4. **SemanticCanonicalModel.lean:236** - Compositionality in finite model
5. **SemanticCanonicalModel.lean:523** - Bridge lemma (`semantic_truth_implies_truth_at`)
6. **SemanticCanonicalModel.lean:768** - Main completeness theorem

### How SemanticCanonicalModel Bypasses This Issue

The `SemanticCanonicalModel` approach (lines 8-36 of SemanticCanonicalModel.lean) takes a different strategy:
- World states are equivalence classes of (history, time) pairs
- Truth is evaluated via `toFiniteWorldState.models`, NOT by proving IsLocallyConsistent
- The `worldStateFromClosureMCS` function is used BUT its consistency proof `closure_mcs_implies_locally_consistent` is left as sorry

The semantic approach works because:
1. It proves `semantic_truth_lemma` (line 450) using `worldStateFromClosureMCS_models_iff`
2. This lemma only requires membership correspondence, NOT local consistency
3. The sorry flows through to the final completeness proof but doesn't block the logical structure

### Downstream Usage Analysis

Files that use `worldStateFromClosureMCS`:
- `SemanticCanonicalModel.lean:453, 655, 735` - Creates world states for truth lemma
- `FiniteModelProperty.lean:441, 445` - Finite model property proof

All these usages ONLY rely on `worldStateFromClosureMCS_models_iff`, which states:
```lean
psi ∈ S ↔ (worldStateFromClosureMCS phi S h_mcs).models psi h_mem
```

This theorem is proven WITHOUT needing local consistency - it's just a definition unfolding.

The `IsLocallyConsistent` constraint is ONLY enforced at construction time (as a proof obligation). The usage sites don't actually call `w.consistent` to prove anything.

## Fix Options Analysis

### Option 1: Remove Temporal Reflexivity from IsLocallyConsistent [RECOMMENDED]

**Approach**: Remove conditions 4 and 5 from `IsLocallyConsistent`.

**Justification**:
- The conditions are architecturally unsound for TM logic
- They are never actually used by downstream code
- The only place that checks `IsLocallyConsistent` is the constructor of `FiniteWorldState`

**Changes Required**:
1. Edit `IsLocallyConsistent` (lines 114-142) to remove past/future reflexivity
2. Remove `all_past_refl` and `all_future_refl` helper theorems (if they exist in Metalogic_v2)
3. The `closure_mcs_implies_locally_consistent` proof will become straightforward
4. Update docstrings explaining the design

**Estimated Effort**: 1-2 hours

**Risk**: Low - no code actually depends on temporal reflexivity of IsLocallyConsistent

### Option 2: Change Temporal Semantics to Reflexive

**Approach**: Modify the semantics so `all_past` and `all_future` include the current time.

**Changes Required**:
- Edit `Truth.lean` to use `s <= t` and `t <= s` instead of strict inequalities
- This changes the meaning of the entire logic system
- Soundness proofs would need revision

**Estimated Effort**: 10+ hours

**Risk**: Very high - fundamentally changes the logic being formalized. The strict semantics is standard for tense logic.

### Option 3: Add Explicit Reflexivity Conditions to Theorem Preconditions

**Approach**: Add hypotheses to `closure_mcs_implies_locally_consistent` requiring that S satisfies temporal reflexivity.

**Problem**: This is impossible - no MCS from TM logic will ever satisfy these conditions since they're not axioms.

**Verdict**: Not viable.

### Option 4: Document as Architectural Limitation

**Approach**: Leave the sorry and document it as a known limitation.

**Status**: This is the current state. The comments already document the issue.

**Problem**: Sorries are generally undesirable and may mask other issues.

### Option 5: Remove worldStateFromClosureMCS Entirely

**Approach**: Since the semantic approach bypasses this, delete the syntactic approach code.

**Changes Required**:
- Remove `assignmentFromClosureMCS`, `closure_mcs_implies_locally_consistent`, `worldStateFromClosureMCS`
- Verify no downstream code breaks

**Estimated Effort**: 2-3 hours

**Risk**: Medium - may break code that relies on these definitions even if via sorry

## Findings Summary

### Key Finding 1: Architectural Mismatch

The `IsLocallyConsistent` definition was designed with reflexive temporal semantics in mind, but TM logic uses strict temporal semantics. This is a fundamental mismatch that cannot be resolved within the current axiom system.

### Key Finding 2: Unused Constraints

The temporal reflexivity conditions in `IsLocallyConsistent` are never actually used by downstream proofs. They are "dead code" in the sense that no theorem relies on them.

### Key Finding 3: Semantic Approach Succeeds

The `SemanticCanonicalModel` achieves completeness (modulo other sorries) without needing temporal reflexivity, proving it's not essential to the proof strategy.

### Key Finding 4: Same Issue in Old Metalogic

The old `FiniteCanonicalModel.lean` has the exact same sorry at line 1302, with identical documentation. This is a known, long-standing issue.

## Recommendations

1. **Implement Option 1**: Remove temporal reflexivity from `IsLocallyConsistent`. This is the cleanest fix that aligns the definition with the actual logic semantics.

2. **Update Documentation**: Add a comment explaining why temporal reflexivity is NOT included, referencing the strict semantics.

3. **Consider Option 5 for Cleanup**: If the syntactic approach (worldStateFromClosureMCS) is truly superseded by the semantic approach, consider removing it to eliminate dead code and its associated sorry.

## Implementation Guidance

For Option 1, the specific changes:

**In FiniteWorldState.lean (lines 114-142)**:
```lean
def IsLocallyConsistent (phi : Formula) (v : FiniteTruthAssignment phi) : Prop :=
  -- Bot is false
  (∀ h : Formula.bot ∈ closure phi, v ⟨Formula.bot, h⟩ = false) ∧
  -- Implications are respected
  (∀ psi chi : Formula,
    ∀ h_imp : Formula.imp psi chi ∈ closure phi,
    ∀ h_psi : psi ∈ closure phi,
    ∀ h_chi : chi ∈ closure phi,
    v ⟨Formula.imp psi chi, h_imp⟩ = true →
    v ⟨psi, h_psi⟩ = true →
    v ⟨chi, h_chi⟩ = true) ∧
  -- Modal T axiom: box(psi) -> psi
  (∀ psi : Formula,
    ∀ h_box : Formula.box psi ∈ closure phi,
    ∀ h_psi : psi ∈ closure phi,
    v ⟨Formula.box psi, h_box⟩ = true →
    v ⟨psi, h_psi⟩ = true)
  -- NOTE: Temporal reflexivity (H phi -> phi, G phi -> phi) is intentionally
  -- NOT included because TM logic uses strict temporal semantics where these
  -- axioms are not valid. See Semantics/Truth.lean:109-110.
```

**In closure_mcs_implies_locally_consistent**:
The proof will need to show only the 3 remaining conditions, all of which are provable from MCS properties.

## References

- `Theories/Bimodal/Metalogic_v2/Representation/FiniteWorldState.lean` - Main file with sorry
- `Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean` - Semantic approach
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean:1284-1302` - Old Metalogic same issue
- `Theories/Bimodal/Semantics/Truth.lean:109-110` - Strict temporal semantics definition

## Next Steps

1. Decide between Option 1 (fix IsLocallyConsistent) and Option 5 (remove syntactic approach)
2. If Option 1: Create implementation plan with specific code changes
3. Verify lake build succeeds after changes
4. Update old Metalogic for consistency (optional, lower priority)
