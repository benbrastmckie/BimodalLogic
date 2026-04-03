# Teammate B: Dead Code Identification & Boneyard Cleanup

## Executive Summary

The codebase contains significant dead code from the reflexive-to-strict semantics transition. I identified **6 high-priority items**, **8 medium-priority items**, and **4 low-priority items** across the Lean source, documentation, and Typst manuscript. The estimated cleanup scope is **~350 lines of Lean code to archive/fix** plus **~200 lines of stale comments/docs to update**.

---

## Dead Code Inventory

### Priority 1: CRITICAL -- Direct T-Axiom Sorry Sites (Active Lean Code)

These are sorry statements that directly reference deleted `temp_t_future` / `temp_t_past` axioms and block correctness.

| # | File | Lines | Description | Action | Confidence |
|---|------|-------|-------------|--------|------------|
| 1 | `Metalogic/Bundle/TargetedChain.lean` | 255, 359, 491, 525 | 4 sorries with comment `/- was: temp_t_future/past phi -/`. These proofs relied on T-axiom to extract `phi` from `G(phi)`. | **Rework or archive to Boneyard** -- proofs need restructuring for strict semantics. If TargetedChain is not on the critical completeness path, archive the entire file. | High |
| 2 | `Metalogic/Bundle/SuccChainFMCS.lean` | 1244, 4009, 4276, 4419 | 4 sorries with comment `/- was: DerivationTree.axiom [] _ (Axiom.temp_t_future/past chi) -/`. T-axiom usage in chain construction. | **Rework or archive** -- the file documents that ~2055 lines of deprecated/FALSE theorems were already removed (line 3562). These 4 remaining sorry sites are in the deprecated code path. Check if they are on the restricted (sorry-free) path. | High |
| 3 | `Metalogic/Bundle/SuccExistence.lean` | 471-473 | `constrained_successor_seed_consistent` -- `g_content(u) subset u` uses sorry because T-axiom no longer available. 3 TODO comments at lines 471, 786, 871 say "Restructure for strict semantics." | **Rework** -- this is on the active completeness path. Need proof-theoretic argument without T-axiom. | High |
| 4 | `Metalogic/Bundle/CanonicalConstruction.lean` | 1015-1058 | `forward_G` and `backward_H` of `construct_fmcs_ext` use sorry. Extended comment explains T-axiom was needed. Lines 1015, 1042, 1056 reference temp_t_future/past. | **Archive to Boneyard** -- the file explicitly says (line 1060) "Alternative: Direct Completeness without Full FMCS" -- this code path was abandoned. | High |
| 5 | `Metalogic/Decidability/FMP/TruthPreservation.lean` | 250-281 | `mcs_all_future_closure` and `mcs_all_past_closure` explicitly marked **DEPRECATED** with docstrings explaining T-axiom invalidity. Both use sorry. | **Archive to Boneyard** -- explicitly marked deprecated, clearly dead. ~30 lines. | High |
| 6 | `Metalogic/Bundle/WitnessSeed.lean` | 468-469, 576 | 2 sorries with TODO: "Complete proof-theoretic derivation for new axiom shape." These are `until_witness_seed_consistent` and `since_witness_seed_consistent`. | **Rework** -- these need updating for X/Y-based until_unfold/since_unfold axiom shapes. Active code, not dead. | High |

### Priority 2: MEDIUM -- Stale Comments and Misleading Documentation

| # | File | Lines | Description | Action | Confidence |
|---|------|-------|-------------|--------|------------|
| 7 | `typst/chapters/06-notes.typ` | 104-340 | **Major issue**: Section "Strict vs Reflexive Temporal Semantics" (lines 104-340, ~236 lines) describes reflexive semantics as "Current" (line 118: `"Reflexive Temporal Semantics (Current)"`). The table at line 134 labels reflexive as "Current". Line 145 says "TM uses reflexive semantics." This is **factually wrong** after the strict semantics switch. The entire section needs rewriting. | **Rewrite** -- swap "Current" labels, update narrative to reflect strict semantics is now the implementation. | High |
| 8 | `Metalogic/Soundness/README.md` | 104-106 | "The temporal T axioms (`G phi -> phi` and `H phi -> phi`) hold because we use reflexive temporal semantics where `t <= t` always holds." | **Delete or rewrite** -- factually wrong. T-axioms are no longer in the system. | High |
| 9 | `Metalogic/Canonical/README.md` | 1-41 | Entire README describes reflexive semantics: "canonicalR_reflexive is PROVEN via T-axiom", "Axiom-Free Reflexive Semantics", "ConstructiveFragment.lean provides reflexive preorder over MCSs". References files that appear to no longer exist (CanonicalTimeline.lean, ConstructiveFragment.lean). | **Delete or rewrite** -- the directory contains only this README. If the `.lean` files are gone, delete the directory entirely. | High |
| 10 | `FrameConditions/FrameClass.lean` | 93-95 | "Under reflexive semantics, these axioms are trivially valid (witness t = current time)" | **Update comment** to reflect strict semantics. | Medium |
| 11 | `FrameConditions/Soundness.lean` | 176-178 | Same stale reflexive semantics comment. | **Update comment**. | Medium |
| 12 | `Metalogic/Bundle/TemporalCoherence.lean` | 217 | "Note: Uses weak inequality (s >= t, s <= t) to align with reflexive G/H semantics (Truth.lean)." But the actual definition at line 221-222 uses strict `<`. Comment is stale. | **Update comment** -- the code is correct (uses `<`), just the comment is wrong. | Medium |
| 13 | `Metalogic/Bundle/SuccChainFMCS.lean` | 1196-1203 | Docstring says "This uses the T-axiom (G(phi) -> phi)" for `g_content_subset_deferral_restricted_mcs`. The TODO at 1203 correctly notes it needs restructuring. | **Update docstring** to remove T-axiom reference, keep TODO. | Medium |
| 14 | `Metalogic/Bundle/CanonicalConstruction.lean` | 1012-1056 | Extended comment block discusses T-axiom approach that was abandoned. | **Archive with surrounding code** (covered by item 4). | Medium |

### Priority 3: LOW -- Deprecated Code and Organizational Issues

| # | File | Lines | Description | Action | Confidence |
|---|------|-------|-------------|--------|------------|
| 15 | `Metalogic/Bundle/CanonicalFrame.lean` | 73-74, 88-89 | `CanonicalR` and `CanonicalR_past` marked `@[deprecated]` with `(since := "2026-03-24")`. These are `abbrev` aliases. | **Remove after confirming no consumers** -- they've been deprecated for 10 days. | Medium |
| 16 | `Metalogic/Algebraic/UltrafilterChain.lean` | 84-87, 242 | Comments `R_G_refl: DELETED under strict semantics` and `R_H_refl: DELETED under strict semantics (T-axiom not valid)`. These are comment tombstones where code was already deleted. | **Clean up tombstone comments** -- they served their purpose, now just clutter. | Low |
| 17 | `Metalogic/Algebraic/InteriorOperators.lean` | 164-191 | Long comment block "Note on G and H Under Strict Semantics" explaining why G/H are not interior operators. The entire section after line 163 is a comment -- no code. The file has no `G_interior`/`H_interior` instances. | **Keep but trim** -- the note is informative for the reader; could be shortened. | Low |
| 18 | `Theorems/Propositional.lean` | 377 | `@[deprecated efq_neg (since := "2025-12-14")]` on old `efq` name. Over 3 months old. | **Remove after confirming no consumers**. | Low |

---

## Estimated Cleanup Scope

| Category | Lines to Remove/Archive | Lines to Update |
|----------|------------------------|-----------------|
| T-axiom sorry sites (items 1-6) | ~200 lines (archive) | ~50 lines (rework) |
| Stale comments/docs (items 7-14) | ~20 lines (delete) | ~180 lines (rewrite) |
| Deprecated aliases (items 15-18) | ~15 lines | ~10 lines |
| **Total** | **~235 lines** | **~240 lines** |

---

## Boneyard Archive Plan

### Proposed Directory Structure

```
Theories/Bimodal/Boneyard/
  BundleTemporalCoherence/     # (existing)
  UltrafilterDeadCode/          # (existing)
  TAxiomDependentCode/          # NEW
    TargetedChainTAxiom.lean    # Items from TargetedChain.lean (4 sorry functions)
    SuccChainFMCSTAxiom.lean    # Items from SuccChainFMCS.lean (4 sorry functions)
    FMCSExtTAxiom.lean          # forward_G/backward_H from CanonicalConstruction.lean
    FMPReflexive.lean           # mcs_all_future/past_closure from TruthPreservation.lean
    README.md                   # Explanation of why these were archived
  ReflexiveSemantics/           # NEW (if Canonical/ dir cleanup needed)
    README.md                   # Preserve the historical context
```

### Archive Strategy

For each piece of dead code:
1. Copy the relevant functions/theorems to Boneyard with a header comment explaining:
   - Original file and line range
   - Why it was archived (T-axiom dependency / strict semantics switch)
   - Date of archival
2. Replace in-place with a `-- Archived to Boneyard/TAxiomDependentCode/` comment
3. If the entire function is dead, delete the definition and leave only the archive pointer

### Items NOT to Archive (Active Sorry Sites)

The following have sorries but are on the **active completeness path** and need rework, not archival:
- `SuccExistence.lean:471-473` -- `g_content(u) subset u` needs proof-theoretic fix
- `WitnessSeed.lean:468, 576` -- needs X/Y-based axiom shape update
- `SuccRelation.lean:550` -- `until_persists_through_succ` needs X-based rewrite
- `TemporalDerived.lean:240, 247, 263, 271` -- `X_bot_absurd`, `Y_bot_absurd`, etc. need full derivation

---

## Import Optimization Recommendations

| Priority | File | Issue | Recommendation | Confidence |
|----------|------|-------|----------------|------------|
| Medium | `Metalogic/Canonical/` dir | Contains only README.md -- no `.lean` files | Delete directory or add `.gitkeep` note | High |
| Low | `Automation/AesopRules.lean` | Header says "DEPRECATED: tm_auto no longer uses Aesop" | Verify if AesopRules is imported anywhere; if not, archive | Medium |
| Low | General | No specific unused import issues found via grep | Run `lake build` with `-DautoImplicit=false` for deeper analysis | Low |

---

## Structure Assessment

### Files That May Be Too Large

| File | Lines | Recommendation |
|------|-------|----------------|
| `Bundle/SuccChainFMCS.lean` | 6345 | **Split candidate**: Forward chain (lines 1-3500) vs backward chain (lines 3500-6345). Already has natural section boundaries. |
| `Algebraic/UltrafilterChain.lean` | 3970 | **Split candidate**: R_G/R_H properties vs chain construction vs STSA algebra. |

### Directory-Level Issues

1. **`Metalogic/Canonical/`** -- Ghost directory with only a stale README. Either delete or repurpose.
2. **`Metalogic/Soundness/`** -- Contains only README.md; actual soundness files are at `Metalogic/Soundness.lean` and `Metalogic/SoundnessLemmas.lean`. The README itself says "This directory exists for organizational documentation only." Consider deleting.

---

## Downstream Impact Assessment

### Safe to Archive (No Downstream Consumers)

- `TargetedChain.lean` sorry functions: Called nowhere outside the file (verified by grep for function names)
- `CanonicalConstruction.lean` forward_G/backward_H sorry: The file provides alternative path at line 1060
- `TruthPreservation.lean` deprecated theorems: Marked deprecated, not on FMP critical path

### Requires Careful Checking Before Removal

- `CanonicalR` / `CanonicalR_past` deprecated aliases: Need grep for all consumers
- `SuccChainFMCS.lean` sorry sites: May be referenced by downstream chain assembly

### Must NOT Remove (Active Path)

- `SuccExistence.lean` functions with sorry -- on active completeness path
- `WitnessSeed.lean` functions with sorry -- on active completeness path
- All soundness theorem sorry sites in `Soundness.lean:977-994` -- these are frame-class restricted, intentional, documented

---

## Summary of Findings

1. **8 T-axiom sorry sites** in 4 files need archival (TargetedChain, SuccChainFMCS, CanonicalConstruction, TruthPreservation)
2. **4 active sorry sites** need rework, not archival (SuccExistence, WitnessSeed, SuccRelation)
3. **1 major documentation rewrite** needed (typst/06-notes.typ labels reflexive as "Current")
4. **2 stale README files** reference deleted code (Canonical/README.md, Soundness/README.md)
5. **~10 stale comments** reference reflexive semantics or T-axiom across the codebase
6. **2 deprecated aliases** ready for removal (CanonicalR, CanonicalR_past)
7. **2 files** are candidates for splitting due to size (SuccChainFMCS at 6345 lines, UltrafilterChain at 3970 lines)
