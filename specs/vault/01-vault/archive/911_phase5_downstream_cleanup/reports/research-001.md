# Research Report: Task #911

**Task**: Phase 5 - Downstream Cleanup
**Date**: 2026-02-19
**Focus**: Identify and document all downstream compilation impacts from tasks 907-910 (Omega parameter changes to truth_at)

## Summary

After tasks 907-910 added the Omega parameter to `truth_at` and restructured Representation.lean, a comprehensive audit of all downstream files reveals that **no downstream files require changes for compilation**. The project builds successfully with 1000 jobs. However, there are **136 cosmetic linter warnings** in SoundnessLemmas.lean and Soundness.lean (unused `Set.mem_univ` and `true_implies` simp arguments), and the two expected Omega-mismatch sorries in Representation.lean. The FMP/SemanticCanonicalModel.lean file, initially flagged as the primary concern, compiles without errors because it uses its own `semantic_truth_at_v2` definition and only references the standard `truth_at` via `simp only [truth_at] at h_bot_true` for the Bot case, which works correctly regardless of the Omega parameter.

## Findings

### 1. Build Status: Full Compilation Succeeds

`lake build` completes successfully with 1000 jobs and zero errors. Direct compilation of all key files confirms:

| File | Status | Notes |
|------|--------|-------|
| Representation.lean | Compiles | 2 sorry warnings (Omega-mismatch), 2 unused-variable warnings |
| SemanticCanonicalModel.lean | Compiles | Zero warnings, zero errors |
| SoundnessLemmas.lean | Compiles | 64 unused simp arg warnings |
| Soundness.lean | Compiles | 72 unused simp arg warnings |
| Validity.lean | Compiles | Clean |
| Truth.lean | Compiles | Clean |
| Demo.lean | Pre-existing error (imports Boneyard v2) | Unrelated to Omega changes |
| Completeness.lean | Compiles | Clean (no truth_at usage) |

### 2. FMP/SemanticCanonicalModel.lean Analysis

The parent plan flagged this file as the primary downstream concern. Detailed analysis shows it does NOT need changes:

**Lines 302 and 328** have `simp only [truth_at] at h_bot_true`:
- These occur in `neg_set_consistent_of_not_provable` and `phi_consistent_of_not_refutable`
- Both follow the pattern: `soundness [] Formula.bot d` produces `semantic_consequence [] Formula.bot`
- When specialized to concrete arguments, `h_bot_true : truth_at M Set.univ tau t Formula.bot`
- `simp only [truth_at]` unfolds `truth_at ... Formula.bot` to `False` regardless of Omega
- The Omega parameter (`Set.univ`) passes through transparently

**The file uses its own truth definition** (`semantic_truth_at_v2`) based on `FiniteWorldState.models`, not the standard `truth_at`. The standard `truth_at` appears only in the two `simp` calls above, which work correctly.

### 3. Comprehensive truth_at Usage Audit

Non-Boneyard, non-documentation files using `truth_at`:

| File | Usage Type | Affected? | Reason |
|------|-----------|-----------|--------|
| Truth.lean | Definition | N/A | Already modified (task 907) |
| Validity.lean | References truth_at | N/A | Already modified (task 908) |
| SoundnessLemmas.lean | Proofs with truth_at | N/A | Already modified (task 909) |
| Soundness.lean | Proofs with truth_at | N/A | Already modified (task 909) |
| Representation.lean | Truth lemma with truth_at | N/A | Already modified (task 910) |
| SemanticCanonicalModel.lean | `simp only [truth_at]` on Bot | No | Works correctly (see Finding 2) |
| BMCSTruth.lean | Uses `bmcs_truth_at` (separate def) | No | Independent definition |
| TruthLemma.lean | Uses `bmcs_truth_at` and `eval_bmcs_truth_at` | No | Independent definitions |
| Completeness.lean (Bundle) | Uses `bmcs_truth_at` | No | Independent definition |
| Completeness.lean (Metalogic) | No truth_at usage | No | Only MCS infrastructure |
| Demo.lean | `#check` statements, uses `valid` | No | Pre-existing Boneyard import error |
| Semantics.lean | Documentation only | No | #check in code-block comment |
| Axioms.lean | Documentation only | No | Comment text |

### 4. Omega-Mismatch Sorries in Representation.lean

Task 910 introduced two sorries (lines 401 and 435) for the Omega-mismatch:
- `standard_weak_completeness` (line 401): `valid` provides `truth_at M Set.univ tau t phi` but contradiction needs `truth_at M canonicalOmega tau t phi`
- `standard_strong_completeness` (line 435): Same mismatch with `semantic_consequence`

**Resolution options** (from task 910 research):
1. Change `valid` to quantify over Omega (requires Validity.lean + Soundness.lean changes)
2. Prove truth monotonicity (fails for imp due to contravariance in box case)
3. Prove `truth_at_univ_iff_truth_at_omega` for the specific case where Omega is a subset of Set.univ (needs careful analysis of formula structure)

These are NOT in scope for task 911 (downstream cleanup). They require a dedicated follow-up task.

### 5. Cosmetic Linter Warnings

SoundnessLemmas.lean and Soundness.lean have a combined 136 linter warnings about unused simp arguments. These warnings occur because task 909 added `Set.mem_univ` and `true_implies` to simp calls as a pattern, but some of those simp calls don't actually need these lemmas (e.g., when the box case isn't present in the formula being simplified).

**Affected lines in SoundnessLemmas.lean** (64 warnings): Lines 315, 491, 500, 527 (each has 2 warnings for both `Set.mem_univ` and `true_implies`), plus many more throughout the file.

**Affected lines in Soundness.lean** (72 warnings): Similar pattern throughout.

These warnings are cosmetic -- they don't prevent compilation and don't affect correctness. Cleanup would involve removing `Set.mem_univ, true_implies` from simp calls that don't need them.

### 6. Files That Import Modified Modules But Are Unaffected

The following non-Boneyard files import modules that were changed in tasks 907-910 but are themselves unaffected:

- `Bimodal/Bimodal.lean` - Umbrella import file only
- `Bimodal/Metalogic.lean` - Umbrella import file only
- `Bimodal/Metalogic/Metalogic.lean` - Umbrella import file only
- `Bimodal/Metalogic/Bundle/SeedCompletion.lean` - Imports Soundness but uses bmcs_truth_at
- `Bimodal/Metalogic/Decidability/Correctness.lean` - Imports Soundness but no truth_at usage
- `Bimodal/Metalogic/Decidability/CountermodelExtraction.lean` - Imports Semantics but no truth_at
- `Bimodal/Metalogic/FMP/Closure.lean` - Imports Semantics but no truth_at
- `Bimodal/Metalogic/FMP/BoundedTime.lean` - No truth_at usage
- `Bimodal/Metalogic/FMP/FiniteWorldState.lean` - Imports Semantics but no truth_at
- `Bimodal/Automation/ProofSearch.lean` - Imports Semantics but no truth_at
- `Bimodal/Examples/TemporalStructures.lean` - Imports TaskFrame/WorldHistory only

## Recommendations

### For Task 911 Implementation

1. **No file modifications needed for compilation**. The build succeeds as-is.

2. **Optional: Clean up unused simp arguments** in SoundnessLemmas.lean and Soundness.lean (136 warnings). This is cosmetic and could be deferred, but is recommended for code hygiene. The cleanup pattern is:
   - Where `Set.mem_univ` and `true_implies` are flagged as unused, remove them from the simp call
   - Some calls may only need one of the two removed (the box-related ones need `Set.mem_univ, true_implies`, others do not)
   - Use `lake env lean <file> 2>&1 | grep "unused"` to identify exactly which lines

3. **Optional: Fix unused variable warnings** in Representation.lean:
   - Line 89: `CanonicalWorldState` has unused `B` parameter (structural, harmless)
   - Line 109: `canonicalHistory` has unused `hfam` parameter (used in proof, may be Lean linter false positive)

4. **Verify no new sorries introduced**: Confirmed -- the two Omega-mismatch sorries are expected from task 910, not new.

5. **Create follow-up task** for Omega-mismatch resolution (weak/strong completeness sorries).

### Concrete Cleanup Checklist

| Priority | Action | File | Impact |
|----------|--------|------|--------|
| Required | Run `lake build` to verify full compilation | All | Verification |
| Required | Verify no new sorries introduced | All active files | Verification |
| Optional | Remove unused `Set.mem_univ, true_implies` from simp calls | SoundnessLemmas.lean | 64 fewer warnings |
| Optional | Remove unused `Set.mem_univ, true_implies` from simp calls | Soundness.lean | 72 fewer warnings |
| Optional | Suppress or fix unused variable warnings | Representation.lean | 2 fewer warnings |
| Out of scope | Resolve Omega-mismatch sorries | Representation.lean | Follow-up task |
| Out of scope | Fix Demo.lean Boneyard import | Demo.lean | Pre-existing issue |

## References

- Task 907: Phase 1 - Added Omega parameter to truth_at
- Task 908: Phase 2 - Updated Validity.lean with Set.univ
- Task 909: Phase 3 - Threaded Omega through soundness proofs
- Task 910: Phase 4 - Reconstructed Representation.lean with canonicalOmega
- Parent plan: specs/906_box_admissible_histories_omega_closure/plans/implementation-002.md

## Next Steps

1. Implementation can proceed immediately with minimal work (verification + optional cleanup)
2. The primary implementation effort is the optional simp argument cleanup (136 warnings)
3. Omega-mismatch resolution requires a separate follow-up task modifying Validity.lean
