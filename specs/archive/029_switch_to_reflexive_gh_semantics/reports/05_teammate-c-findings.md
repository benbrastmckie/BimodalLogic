# Teammate C Findings: Refactoring Strategy and Risk Analysis

**Date**: 2026-03-22
**Angle**: Plan validation, missing coverage, risk assessment, alternative strategies

## Executive Summary

The 7-phase plan is architecturally sound in its intent but was written before tasks 23, 28, 30, and 31 added substantial new infrastructure. Those tasks introduced **8 new axioms** across three files (`SuccChainFMCS.lean`, `SuccExistence.lean`, `DiscreteSuccSeed.lean`) that the plan does not address. The most critical gap is that `canonicalR_irreflexive` (the axiom being removed) is called in **~30 proof sites** across 10+ files, including files added by tasks 30 and 31 after the plan was written. Phase 5 is significantly underscoped: the plan treats the removal as a wrapper-update problem, but the axiom is used directly for strict-order proofs throughout `DovetailedTimelineQuot.lean`, `SaturatedChain.lean`, `CantorApplication.lean`, and the `FMCSTransfer.lean` module. Under reflexive semantics, those proof patterns must be replaced with an antisymmetry argument — a non-trivial transformation at each site.

The plan's Phase 6 optimism (proving `discreteImmediateSuccSeed_consistent` via T-axiom) is misplaced: two additional axioms (`discreteImmediateSucc_covers_axiom` in `DiscreteSuccSeed.lean` and `predecessor_f_step_axiom` in `SuccExistence.lean`) are also stuck for the same reason (strict-semantics incompatibility) and are not mentioned anywhere in the plan. There is also a pre-existing `sorry` in `DovetailedTimelineQuot.lean` (line 295) that is independent of the strict/reflexive switch and will remain after the refactor.

---

## Phase-by-Phase Plan Validation

### Phase 1: Core Semantic Change

**Plan assumptions correct?**: Partially

**Actual code state**:
- `Truth.lean` lines 121-122 still use `<` as the plan assumes — confirmed.
- The header at line 10-11 explicitly labels these as "STRICT Temporal Semantics (Task #991)".
- The plan says to add `temp_t_future` / `temp_t_past` constructors to `ProofSystem/Axioms.lean`. This is correct — no such constructors exist yet.

**Risk level**: Low (syntax change is small; Lean will flag downstream errors)

**Notes**: The two-line change to Truth.lean is safe. However, adding T-axiom constructors to `Axioms.lean` will immediately invalidate the T-axiom docstrings in `CanonicalIrreflexivityAxiom.lean` that say T-axiom is NOT valid (lines 17, 71-74). Those docstrings mislead about soundness. Plan does not flag this documentation landmine.

---

### Phase 2: FMCS Structure Update

**Plan assumptions correct?**: Yes

**Actual code state**:
- `FMCSDef.lean` lines 119 and 127 still use `t < t'` and `t' < t` as the plan assumes — confirmed.
- Docstrings explicitly say "With irreflexive semantics" and "NOT imply phi ∈ mcs t (no T-axiom)". These must be updated.
- `TemporalCoherence.lean` — plan says "update signatures if needed". The `temporal_backward_G/H` functions in `TemporalCoherence.lean` are used in `ParametricTruthLemma.lean` (lines 293, 312) and drive the backward direction of the truth lemma. These signatures depend on the `<` strict ordering in `FMCS.forward_G` / `FMCS.backward_H`.

**Risk level**: Low (mechanical change, but downstream cascades are large)

**Notes**: Changing FMCS coherence fields from `<` to `<=` changes what `temporal_backward_G/H` must prove. Currently ParametricTruthLemma's backward G-case (line 290-293) passes `∀ s, t < s → psi ∈ fam.mcs s` to `temporal_backward_G`. Under reflexive semantics, this must become `∀ s, t ≤ s → ...`, plus the new `s = t` case must be handled explicitly. The plan acknowledges this as Phase 4 work, which is correct.

---

### Phase 3: Soundness Proof Repairs

**Plan assumptions correct?**: Mostly yes

**Actual code state**:
- `Soundness.lean` at lines 186-201 confirms `temp_4_valid` uses `lt_trans` and `temp_a_valid` uses strict `<`. Both need updating as described.
- `temp_l_valid` (line 208-229) already handles the `r = t` case via `rcases lt_trichotomy` — so the fix may be simpler than assumed.
- The plan lists `density_valid`, `seriality_future_valid`, `seriality_past_valid`. These exist in the file and will need updating.
- Adding `temp_t_valid_future` and `temp_t_valid_past` (new validity proofs) is correctly identified — these are genuinely new and require showing `truth_at M Omega τ t (G φ) → truth_at M Omega τ t φ` using `le_refl`.
- `axiom_base_valid` must include the new T-axiom constructors.

**Risk level**: Medium (several proof fixes, each mechanically clear but tedious)

**Notes**: The plan's estimate of 2 hours is plausible. The biggest risk is that `density_valid` and `discreteness_*_valid` proofs may require non-obvious adaptations under reflexive semantics (strict witnesses for "intermediate" points become non-strict, so those proofs need antisymmetry, not just reflexivity).

---

### Phase 4: Truth Lemma Adjustment

**Plan assumptions correct?**: Partially — plan scope is too narrow

**Actual code state**:
- `ParametricTruthLemma.lean` line 274: the `all_future` backward case (line 282-293) calls `fam.forward_G t s psi hts h_G` with `hts : t < s`. Under reflexive semantics `hts : t ≤ s`. This cascades into `FMCS.forward_G` signature.
- The plan says "add s = t case using T-axiom" — correct conceptually. The new case (`s = t`) will use T-axiom: if `G φ ∈ mcs t` then `φ ∈ mcs t` (via T-axiom membership closure).
- The backward direction (getting G φ in MCS from all-future truth) passes through `temporal_backward_G` in `TemporalCoherence.lean`. Under reflexive semantics, the `∀ s ≤ t` version of this theorem may be slightly harder to prove.

**Risk level**: Medium

**Notes**: The plan only mentions `ParametricTruthLemma.lean`. However, there is also `DenseInstantiation.lean` (imported by `TimelineQuotCompleteness.lean`) which contains instantiation-specific truth lemma wiring. If it duplicates any strict-`<` logic, it needs updating too.

---

### Phase 5: Remove canonicalR_irreflexive_axiom

**Plan assumptions correct?**: SIGNIFICANTLY UNDERSCOPED

**Actual code state**:

`canonicalR_irreflexive_axiom` is declared at `CanonicalIrreflexivity.lean` line 1212. The theorem `canonicalR_irreflexive` wraps it at line 1228. But the REAL scope of Phase 5 is much larger than the plan implies:

**Direct call sites of `canonicalR_irreflexive` (the theorem):**

| File | Call count | Pattern |
|------|------------|---------|
| `StagedConstruction/DovetailedTimelineQuot.lean` | ~12 | Strict order in antisymmetrization quotient |
| `Algebraic/SaturatedChain.lean` | ~6 | Strict order in chain arguments |
| `StagedConstruction/CantorApplication.lean` | ~4 | NoMaxOrder/NoMinOrder/DenselyOrdered |
| `StagedConstruction/ClosureSaturation.lean` | 2 | Strict order |
| `StagedConstruction/IncrementalTimeline.lean` | 1 | Strict order |
| `StagedConstruction/TimelineQuotCanonical.lean` | 1 | Antisymmetry quotient |
| `Bundle/FMCSTransfer.lean` | 2 | `lt_of_canonicalR` theorem |
| `Domain/DiscreteTimeline.lean` | 2 | NoMaxOrder/NoMinOrder |
| `Canonical/CanonicalSerialFrameInstance.lean` | 2 | Serial frame instance |

**The proof pattern at each site is:**
```
canonicalR_irreflexive M hM (canonicalR_transitive M N M hM h_MN h_NM)
```
This shows two-way CanonicalR is impossible (strict antisymmetry). Under reflexive semantics, `canonicalR_reflexive` holds (CanonicalR M M is TRUE), so the proof structure must change fundamentally. The plan says "update downstream uses to use antisymmetry" but antisymmetry alone does NOT give what these proofs need — they need `CanonicalR M N → M ≠ N` (strict antisymmetry), which requires a different argument.

**The key issue**: Under reflexive semantics, `CanonicalR M M` must be provable (it's the whole point — T-axiom says g_content(M) ⊆ M). But nearly every existing use of `canonicalR_irreflexive` is proving `CanonicalR M M → False` or `CanonicalR M N ∧ CanonicalR N M → M = N`. These are logically INVERTED by the switch.

The plan's proposed `canonicalR_antisymmetric` theorem (`CanonicalR M N ∧ CanonicalR N M → M = N`) does NOT replace these uses. The sites prove things like "NoMaxOrder" — that seriality gives a STRICTLY greater successor. Under reflexive semantics, the seriality witness can have `CanonicalR M M` (reflexive), so we can no longer conclude the witness is strictly greater without additional work.

**Risk level**: HIGH — this is the most dangerous phase. The blast radius is ~30 call sites across 10 files, several of which are in files added by tasks 30 and 31.

---

### Phase 6: Prove discreteImmediateSuccSeed_consistent

**Plan assumptions correct?**: Partially correct premise, missing scope

**Actual code state**:
- `discreteImmediateSuccSeed_consistent_axiom` is at `DiscreteSuccSeed.lean` line 284 — confirmed.
- `discreteImmediateSucc_covers_axiom` is at `DiscreteSuccSeed.lean` line 414 — **NOT MENTIONED IN PLAN**.
- In `SuccExistence.lean`: `successor_deferral_seed_consistent_axiom` (line 266), `predecessor_deferral_seed_consistent_axiom` (line 311), and `predecessor_f_step_axiom` (line 516) — **NONE MENTIONED IN PLAN**.
- In `SuccChainFMCS.lean`: `succ_chain_fam_p_step` (line 335), `f_nesting_boundary` (line 583), `p_nesting_boundary` (line 695) — **NONE MENTIONED IN PLAN**.

The plan's argument that `discreteImmediateSuccSeed_consistent` becomes provable via T-axiom is correct in principle: with T-axiom, g_content(M) ⊆ M, so blocking formulas `¬ψ ∨ ¬G(ψ)` can be derived from inconsistency of `{ψ, G(ψ)} ∩ M` using MCS properties. However, this proof approach does NOT automatically resolve the other 7 axioms.

**Risk level**: Medium-High (correctly identified one axiom to convert; misses 7 others)

---

### Phase 7: Documentation and Final Verification

**Plan assumptions correct?**: Yes, but premature

**Risk level**: Low (this phase is fine as described, but will only be reached if Phases 5-6 succeed)

---

## Missing Coverage

### Files Added Since Plan Creation

The plan was written before tasks 23, 28, 30, and 31 completed. The following files were added or significantly modified and are not covered:

| File | Task | Content not in plan |
|------|------|---------------------|
| `Bundle/SuccExistence.lean` | Task 23 | 3 new axioms (successor/predecessor seed consistency, predecessor_f_step) |
| `Bundle/SuccChainFMCS.lean` | Task 23 | 3 new axioms (succ_chain_fam_p_step, f_nesting_boundary, p_nesting_boundary) |
| `Bundle/SuccChainTaskFrame.lean` | Task 23 | Uses SuccChainFMCS; depends on strict order from forward_G/backward_H |
| `Bundle/SuccChainWorldHistory.lean` | Task 23 | Uses temporal coherence |
| `StagedConstruction/DovetailedTimelineQuotBFMCS.lean` | Task 30 | Uses DovetailedTimelineQuot antisymmetry via canonicalR_irreflexive indirectly |
| `StagedConstruction/TimelineQuotCompleteness.lean` | Task 31 | Final wiring; depends on all upstream correctness |
| `StagedConstruction/DiscreteSuccSeed.lean` | Task 28 | `discreteImmediateSucc_covers_axiom` not mentioned |

### Axioms Not Addressed by Plan

The plan promises to eliminate `canonicalR_irreflexive_axiom` and `discreteImmediateSuccSeed_consistent_axiom`. It does not address:

1. `discreteImmediateSucc_covers_axiom` (`DiscreteSuccSeed.lean:414`) — covering property for discrete timeline
2. `successor_deferral_seed_consistent_axiom` (`SuccExistence.lean:266`) — deferral seed consistency
3. `predecessor_deferral_seed_consistent_axiom` (`SuccExistence.lean:311`) — predecessor seed consistency
4. `predecessor_f_step_axiom` (`SuccExistence.lean:516`) — F-step for predecessor construction
5. `succ_chain_fam_p_step` (`SuccChainFMCS.lean:335`) — P-step for succ chain
6. `f_nesting_boundary` (`SuccChainFMCS.lean:583`) — F-nesting depth bound
7. `p_nesting_boundary` (`SuccChainFMCS.lean:695`) — P-nesting depth bound

Whether reflexive semantics enables proving any of axioms 2-7 would require additional research. The plan assumes the axiom count after Phase 6 is just `discrete_Icc_finite_axiom`, but the actual residual count will be 7+ (or more if new axioms are needed to compensate for the changed semantics).

---

## Blast Radius Analysis

### Direct Impact (files changed in Phases 1-4)

| File | Phase | Change type |
|------|-------|-------------|
| `Semantics/Truth.lean` | 1 | 2-line change |
| `ProofSystem/Axioms.lean` | 1 | New constructors |
| `Metalogic/Bundle/FMCSDef.lean` | 2 | 2-line change + docstring |
| `Metalogic/Bundle/TemporalCoherence.lean` | 2 | Signature update |
| `Metalogic/Soundness.lean` | 3 | Multiple proof fixes |
| `Metalogic/Algebraic/ParametricTruthLemma.lean` | 4 | Reflexive case addition |

### Cascade Impact (Phase 5 blast radius)

Files that directly call `canonicalR_irreflexive` (call chain will break):
- `Metalogic/Bundle/CanonicalIrreflexivity.lean` (source — axiom removed)
- `Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` (wrapper — fundamental change)
- `Metalogic/Canonical/CanonicalSerialFrameInstance.lean` (2 sites)
- `Metalogic/Bundle/FMCSTransfer.lean` (2 sites + `lt_of_canonicalR` theorem)
- `Metalogic/Algebraic/SaturatedChain.lean` (~6 sites)
- `Metalogic/StagedConstruction/DovetailedTimelineQuot.lean` (~12 sites)
- `Metalogic/StagedConstruction/CantorApplication.lean` (~4 sites)
- `Metalogic/StagedConstruction/ClosureSaturation.lean` (2 sites)
- `Metalogic/StagedConstruction/IncrementalTimeline.lean` (1 site)
- `Metalogic/StagedConstruction/TimelineQuotCanonical.lean` (1 site)
- `Metalogic/Domain/DiscreteTimeline.lean` (2 sites)

**Total: ~35 call sites across ~11 files** for Phase 5 alone.

### Import Chain Cascade

Files that import from affected modules (will need rebuild/check):
- `Domain/CanonicalDomain.lean` (depends on DiscreteTimeline + canonicalR_irreflexive)
- `StagedConstruction/DovetailedTimelineQuotBFMCS.lean` (imports DovetailedTimelineQuot)
- `StagedConstruction/TimelineQuotCompleteness.lean` (imports DovetailedTimelineQuotBFMCS)
- Any file importing `FMCSTransfer.lean` (uses `lt_of_canonicalR`)

This is the entire completeness pipeline — effectively the entire `Metalogic/` tree needs rebuilding after Phase 5.

### Pre-existing Sorries

`DovetailedTimelineQuot.lean` has 4 `sorry` instances (lines 295, 788, 879, ~1148) that are independent of the strict/reflexive switch. These will persist after the refactor.

---

## Alternative Strategy Assessment

### Option A: 7-Phase Sequential Plan (as written)
**Pros**: Logically sequenced, complete build verification after each phase.
**Cons**: Phase 5 blast radius is severely underestimated; attempting Phase 5 without a complete enumeration of all call sites will lead to a multi-hour "whack-a-mole" build-fix loop. Build failures in Phase 5 could propagate ambiguously across 11 files simultaneously.

### Option B: Feature Branch with Incremental Fix
**Pros**: Same as Option A but isolates the work. Can use `lake build` continuously.
**Cons**: Same scope issues. Git history is cleaner but doesn't fix the core problem.

### Option C: Blast-Radius-First Approach (Recommended Modification to Plan)
Insert a **Phase 0** before the plan starts:
1. Enumerate ALL ~35 call sites of `canonicalR_irreflexive`.
2. Categorize each site: does it prove `¬CanonicalR M M` directly, or does it use the strict antisymmetry corollary?
3. For each category, write the reflexive-semantics replacement argument.
4. Only then execute Phases 1-7.

**Pros**: Prevents the Phase 5 surprise; the work is enumerable upfront.
**Cons**: Adds 1-2 hours of prep.

### Option D: Two-Pass Approach
**Pass 1**: Change semantics only (Truth.lean + FMCSDef.lean), without removing the axiom. Use `#check` annotations to verify what breaks semantically. Leave `canonicalR_irreflexive_axiom` in place temporarily (it becomes a false axiom, but Lean doesn't check axiom truth, only proof type-checking). This lets you verify Phase 1-4 independently.

**Pass 2**: Remove the axiom and fix all downstream uses.

**Pros**: Cleanly separates "semantic change" from "axiom removal" concerns. Phase 1-4 can be completed and verified before tackling Phase 5's complexity.
**Cons**: Temporarily introduces a false axiom (though it was already morally false under the old semantics). Risk of forgetting Pass 2.

### Option E: Flag-Based Transition
Add a Lean `section variable` or `class` to parameterize strict vs. reflexive semantics.
**Pros**: Allows both semantics to coexist for comparison.
**Cons**: Massive architectural overhead; unsuitable for this project's structure.

---

## Recommended Strategy

**Modified 8-Phase Plan (Option A + Option C):**

**Phase 0 (New)**: Complete enumeration. Before any code changes:
1. List all 35 call sites of `canonicalR_irreflexive` with their proof patterns.
2. For each `DovetailedTimelineQuot.lean` NoMaxOrder/NoMinOrder/DenselyOrdered proof, draft the replacement argument under reflexive semantics (seriality still gives a CanonicalR witness; the question is how to get strict inequality from it without irreflexivity).
3. List all 7 unaddressed axioms and assess which might become provable under T-axiom.

**Phases 1-4**: As planned (mechanical, low-risk).

**Phase 5 (Expanded)**: Remove axiom AND fix all 35 sites. Budget 4+ hours, not 2.5.

**Phase 6 (Expanded)**: Address all 8 axioms (not just `discreteImmediateSuccSeed_consistent`). Some may require new proofs; others may require new axioms. Be explicit about which.

**Phase 7**: As planned.

---

## Top 5 Risks

1. **NoMaxOrder/NoMinOrder proof collapse** (Phase 5): Under reflexive semantics, the canonical relation has `CanonicalR M M`. The existing proofs that seriality gives a *strictly* greater witness use `canonicalR_strict` (which uses `canonicalR_irreflexive`). Without irreflexivity, these proofs need a fundamentally different approach — likely using the blocking formula or naming set construction to show the seriality witness is distinct from M. This is non-trivial and could require 3-5 hours of Lean proof work across multiple files.

2. **Unaddressed axioms** (Phase 6): The plan promises to convert 2 axioms to theorems. The actual count of unaddressed axioms is 9 (1 removed + 7 not mentioned + 1 for `discrete_Icc_finite_axiom` planned to stay). Some of these (e.g., `f_nesting_boundary`, `p_nesting_boundary`) are unlikely to become provable under reflexive semantics — they are about F/P nesting depth bounds, independent of the strict/reflexive distinction.

3. **DovetailedTimelineQuot.lean sorry instances**: This file has 4 pre-existing sorries (lines 295, 788, 879, ~1148) that are independent of the semantic switch. Phase 5 must touch this file heavily (~12 call sites), increasing risk of accidentally breaking the surrounding infrastructure around the sorries.

4. **lt_of_canonicalR invalidation** (Phase 5): `FMCSTransfer.lean` contains `CanonicalMCS.lt_of_canonicalR` (line 214), which derives `a < b` from `CanonicalR a.world b.world` using irreflexivity. This function is used in `transfer_forward_F` (line 255) and `transfer_backward_P` (line 306) — core to the completeness pipeline. Under reflexive semantics, `CanonicalR a.world b.world` does NOT imply `a < b` (it could be `a = b`). The entire transfer mechanism may need redesign.

5. **ParametricTruthLemma backward G/H direction** (Phase 4): The backward direction currently assumes strict `<`. Under reflexive `<=`, the backward-G proof must handle the `s = t` case by showing `G φ ∈ mcs t → φ ∈ mcs t` (T-axiom). This is provable but requires MCS closure machinery. If T-axiom constructors are not properly added to `Axioms.lean` in Phase 1, Phase 4 will fail with an opaque error.

---

## Confidence Level

**Medium** — The direction is correct and the plan is architecturally sound, but the Phase 5 scope and the unaddressed axioms create substantial uncertainty. The critical open question is whether NoMaxOrder/NoMinOrder/DenselyOrdered can be re-proven under reflexive semantics without `canonicalR_irreflexive`. If these proofs require a materially different approach (rather than just swapping one lemma), the effort estimate of 12 hours could easily double. A Phase 0 enumeration exercise would raise confidence to High within 2 hours.
