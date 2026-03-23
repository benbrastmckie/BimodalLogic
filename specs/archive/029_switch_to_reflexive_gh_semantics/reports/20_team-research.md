# Research Report: Task #29 — Removing IRR and All Irreflexive Artifacts

**Task**: 29 - switch_to_reflexive_gh_semantics
**Date**: 2026-03-22
**Mode**: Team Research (3 teammates)
**Focus**: Comprehensive analysis of removing Gabbay Irreflexivity Rule (IRR) and all irreflexive-semantics artifacts

## Summary

All three teammates converge on the same core conclusion: **IRR is unsound under reflexive semantics and must be removed from the proof system entirely**. The existing plan v4 was on the wrong track — it tried to build substitution infrastructure to *accommodate* the IRR case rather than recognizing that IRR itself is the artifact that needs to go.

The system is currently **actively inconsistent**: `canonicalR_reflexive` (proven theorem) and `canonicalR_irreflexive_axiom` (axiom) coexist, asserting both `CanonicalR M M` and `¬CanonicalR M M`. Removing the axiom and the IRR rule restores soundness and eliminates 3+ sorries.

The remaining work is replacing ~28-54 call sites that use `canonicalR_irreflexive` with per-witness strictness arguments, plus cleaning up ~15 files with IRR pattern match arms and ~20 files with outdated comments.

## Key Findings

### 1. IRR Is Unsound Under Reflexive Semantics (ALL TEAMMATES AGREE — HIGH CONFIDENCE)

The Gabbay Irreflexivity Rule states: from `⊢ (p ∧ H(¬p)) → φ` where `p ∉ atoms(φ)`, infer `⊢ φ`.

Under reflexive semantics (H uses ≤), the antecedent `p ∧ H(¬p)` is **unsatisfiable**: H(¬p) at time t requires ¬p at all s ≤ t, which includes t itself, contradicting p at t. This makes the premise `⊢ (p ∧ H(¬p)) → φ` vacuously true for any φ — including ⊥. So IRR would license deriving ⊥, making it unsound.

The existing codebase already acknowledges this: `IRRSoundness.lean:310-321` contains comments explaining the unsoundness, and the proof ends with `sorry`.

### 2. The System Is Currently Inconsistent (ALL TEAMMATES AGREE — HIGH CONFIDENCE)

Two contradictory assertions coexist:
- `canonicalR_reflexive` (proven theorem, `CanonicalIrreflexivity.lean:1206-1212`): `CanonicalR M M` for all MCS M
- `canonicalR_irreflexive_axiom` (axiom, `CanonicalIrreflexivity.lean:1492`): `¬CanonicalR M M` for all MCS M

This makes the entire proof system trivially unsound. **Removing the axiom is urgent.**

### 3. T-Axioms Already Present and Correct (ALL TEAMMATES AGREE — HIGH CONFIDENCE)

- `temp_t_future` (Gφ → φ): `Axioms.lean:290`
- `temp_t_past` (Hφ → φ): `Axioms.lean:304`
- Soundness proofs complete: `Soundness.lean:248-267`
- `canonicalR_reflexive` already proven from T-axiom

No new axioms needed. The T-axioms provide the replacement for everything IRR was intended to achieve.

### 4. Plan v4 Phase 5.0 (Substitution Lemma) Is Misdirected (TEAMMATES B+C AGREE — HIGH CONFIDENCE)

The substitution lemma was created to handle the IRR case in `derivation_subst`. If IRR is removed from `DerivationTree`, the IRR case in `Substitution.lean` disappears automatically — the `sorry` at line 386 ceases to exist.

**Substitution.lean assessment** (Teammate B): SIMPLIFY — remove the 20-line IRR case (lines 366-386), keep the rest (Formula.subst, Context.subst, non-IRR derivation_subst infrastructure). The non-IRR content is independently useful.

Teammate C notes the substitution lemma may still be useful for `fresh_Gp_seed_consistent` (Phase 5.1), but an alternative cardinality argument may also work. Either way, the IRR case is dead.

### 5. Complete Artifact Inventory (TEAMMATE B — HIGH CONFIDENCE)

#### Files to DELETE (3 files)

| File | Reason |
|------|--------|
| `Metalogic/IRRSoundness.lean` | Entire module proves soundness of unsound rule; has sorry |
| `Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` | Re-exports deprecated `canonicalR_irreflexive`; introduces inconsistency |
| `Metalogic/Bundle/DirectIrreflexivity.lean` | Entirely about proving irreflexivity directly; dead code |

#### Files Requiring Code Changes (~15 files)

**Proof System (remove IRR constructor + pattern match arms)**:
| File | Changes |
|------|---------|
| `ProofSystem/Derivation.lean` | Remove `irr` constructor, `height` arm, `isDenseCompatible` arm, `isDiscreteCompatible` arm |
| `ProofSystem/Substitution.lean` | Remove IRR case in `derivation_subst` (lines 366-386) |
| `Metalogic/Soundness.lean` | Remove IRR import, remove `.irr` cases (lines 604-606, 671-688, 796-801) |
| `Metalogic/SoundnessLemmas.lean` | Remove `.irr` case (lines 961-963) |
| `Metalogic/Core/DeductionTheorem.lean` | Remove `.irr` arm (lines 259-262) |
| `Metalogic/Core/MaximalConsistent.lean` | Remove `.irr` arms (lines 150, 186-190) |

**Conservative Extension (remove IRR from extended proof system)**:
| File | Changes |
|------|---------|
| `ConservativeExtension/ExtDerivation.lean` | Remove `irr` constructor + embedding (lines 100-105, 175-176) |
| `ConservativeExtension/Lifting.lean` | Remove IRR cases (~12 locations: lines 141-147, 341-382, 397-502, 563-580) |
| `ConservativeExtension/ExtFormula.lean` | Remove IRR embedding lemma (line 306) |

**Canonical Model (replace `canonicalR_irreflexive` call sites)**:
| File | Call Count | Purpose |
|------|------------|---------|
| `StagedConstruction/DovetailedTimelineQuot.lean` | ~12 | Quotient order strictness |
| `Algebraic/SaturatedChain.lean` | ~8 | Chain construction strictness |
| `StagedConstruction/CantorApplication.lean` | ~3 | NoMaxOrder, NoMinOrder, DenselyOrdered |
| `StagedConstruction/ClosureSaturation.lean` | ~2 | Saturation step strictness |
| `Bundle/FMCSTransfer.lean` | ~2 | Transfer lemma strictness |
| `Canonical/CanonicalSerialFrameInstance.lean` | ~2 | Serial frame strictness |
| `StagedConstruction/TimelineQuotCanonical.lean` | ~1 | Quotient canonical |
| `StagedConstruction/IncrementalTimeline.lean` | ~1 | Timeline construction |
| `Domain/DiscreteTimeline.lean` | ~2 | Discrete successor strictness |

**Canonical Model (heavy rework)**:
| File | Changes |
|------|---------|
| `Bundle/CanonicalIrreflexivity.lean` | Keep reflexive proof (line 1200+), naming set infrastructure, and per-witness strictness section (1226-1259). Remove deprecated axiom (1492) and all IRR-based proofs. Consider renaming file. |

#### Files Requiring Comment/Doc Updates (~20 files)

Teammate B identified ~20 files with outdated irreflexive-semantics comments/documentation, including:
- `Syntax/Atom.lean`, `Syntax/Formula.lean`
- `Metalogic/Bundle/WitnessSeed.lean`, `Construction.lean`, `TemporalCoherence.lean`
- `Metalogic/StagedConstruction/*.lean` (several)
- `Metalogic/Representation.lean`, `DenseSoundness.lean`, `DiscreteSoundness.lean`
- `ProofSystem/Axioms.lean`
- `typst/chapters/06-notes.typ`, `latex/subfiles/04-Metalogic.tex`

#### Boneyard Files (NO ACTION — ~6 files)

Already archived. Leave untouched.

#### Axiom to Remove (1)

| Axiom | File | Line | Status |
|-------|------|------|--------|
| `canonicalR_irreflexive_axiom` | `Bundle/CanonicalIrreflexivity.lean` | 1492 | DEPRECATED, introduces inconsistency |

#### Remaining Axioms (semantics-independent, KEEP)

10 axioms remain that are unrelated to IRR/irreflexivity (successor seed consistency, discrete timeline, etc.). Some reference `canonicalR_irreflexive_axiom` in comments but their mathematical content is valid under either semantics.

### 6. Sorries Eliminated by Removing IRR (ALL TEAMMATES AGREE)

| Sorry Location | Cause | Resolution |
|----------------|-------|------------|
| `IRRSoundness.lean:322` | IRR unsound under ≤ | File deleted |
| `Soundness.lean:604-606` | IRR case incomplete | Match arm removed |
| `Soundness.lean:688` | IRR case non-domain subcase | Match arm removed |
| `SoundnessLemmas.lean:963` | IRR case entirely sorry | Match arm removed |
| `Substitution.lean:386` | IRR case in derivation_subst | Match arm removed |

**Total: 5 sorries eliminated** by removing IRR from DerivationTree.

### 7. What Actually Remains After IRR Removal (TEAMMATE C, SUPPORTED BY A)

After removing IRR and its artifacts, the remaining work for reflexive semantics is:

**Per-Witness Strictness (replacing universal irreflexivity)**:
1. Prove `exists_strict_fresh_atom` — for any MCS M, ∃ atom q fresh for M such that the extension by G(q) gives a strict successor
2. Prove `fresh_Gp_seed_consistent` — the seed g_content(M) ∪ {G(q)} is consistent
3. Prove `canonicalR_strict_successor` and `canonicalR_strict_predecessor`
4. Replace ~28-54 call sites using per-witness strictness instead of universal irreflexivity
5. Delete `canonicalR_irreflexive_axiom`

**Independent**:
6. Phase 6: `discreteImmediateSuccSeed_consistent_axiom` via T-axiom

## Synthesis

### Conflicts Resolved

| Topic | Teammate A | Teammate B | Teammate C | Resolution |
|-------|------------|------------|------------|------------|
| Call site count | ~40 | ~28 code + comments | ~54+ | ~28 actual code sites, ~20 comment-only. A and C included comments. **Use B's breakdown.** |
| Substitution.lean fate | Not addressed | SIMPLIFY (remove IRR case) | May be unnecessary entirely | **SIMPLIFY**: remove IRR case, keep rest. Whether remaining infrastructure is used depends on approach for Phase 5.1. |
| Fresh atom approach | Substitution lemma | Not addressed | Cardinality argument alternative | **Both viable**. With IRR case gone, substitution lemma is simpler. Cardinality argument is an alternative. Leave to plan v5 to decide. |

### Gaps Identified

1. **Exact refactoring pattern for call sites**: All teammates identify the need to replace `canonicalR_irreflexive` usage, but the specific refactoring pattern for each of the ~28 code call sites needs per-site analysis. Some may be simple (use constructed witness's non-equality), others may need structural changes.

2. **CanonicalIrreflexivity.lean naming**: File should be renamed after rework (it no longer proves irreflexivity). Suggestion: `CanonicalReflexivity.lean` or `CanonicalStrictness.lean`.

3. **Conservative extension module depth**: Teammate A and B both identify significant IRR presence in `ConservativeExtension/Lifting.lean` (~12 locations, including a large section at lines 397-502). This may be the most complex single file to modify.

### Recommendations

**Plan v5 should be restructured as follows:**

1. **Phase A (Quick Win — Low Risk)**: Remove IRR from DerivationTree + delete IRRSoundness.lean + remove IRR match arms from all files. This is mechanical, eliminates 5 sorries, and can be done in 2-3 hours.

2. **Phase B (Critical Fix — Medium Risk)**: Complete per-witness strictness proofs (exists_strict_fresh_atom, fresh_Gp_seed_consistent, canonicalR_strict_successor/predecessor). This is the mathematical core. 3-4 hours.

3. **Phase C (Bulk Refactoring — Medium Effort)**: Replace all ~28 `canonicalR_irreflexive` code call sites with per-witness strictness arguments. 4-6 hours.

4. **Phase D (Cleanup)**: Delete axiom, rename files, update comments/documentation. 1-2 hours.

5. **Phase E (Independent)**: Phase 6 from plan v4 (discreteImmediateSuccSeed). 2-3 hours.

**Total estimated effort**: 12-18 hours (comparable to plan v4, but now correctly directed)

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Proof system impact | Completed | High | Detailed IRR reference inventory with line numbers; soundness sorry tracing |
| B | Codebase archaeology | Completed | High (95%) | Complete file-level action plan; Substitution.lean assessment; axiom inventory |
| C | Theoretical foundations | Completed | High (theory), Medium (implementation) | IRR unsoundness proof; correct axiomatization; plan v4 reassessment |

## References

- Teammate A report: `specs/029_switch_to_reflexive_gh_semantics/reports/20_teammate-a-findings.md`
- Teammate B report: `specs/029_switch_to_reflexive_gh_semantics/reports/20_teammate-b-findings.md`
- Teammate C report: `specs/029_switch_to_reflexive_gh_semantics/reports/20_teammate-c-findings.md`
- Prior research: reports 01-09 (waves 1-5)
- Plan v4: `specs/029_switch_to_reflexive_gh_semantics/plans/04_substitution-lemma-approach.md`
