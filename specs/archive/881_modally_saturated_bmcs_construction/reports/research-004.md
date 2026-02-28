# Research Report: Task #881 (Team Research v3)

**Task**: Construct modally saturated BMCS to eliminate `fully_saturated_bmcs_exists` axiom
**Date**: 2026-02-13
**Mode**: Team Research (2 teammates)
**Session**: sess_1771022472_83be96

## Summary

Comprehensive team research analyzing what happened during task 882 and surveying 7+ past implementation attempts to identify the best path forward. **Key conclusion**: The TemporalLindenbaum approach has fundamental flaws (proven counterexample), but the overall goal remains achievable through alternative construction methods. The most promising path is either (1) an omega-step interleaving construction that avoids Lindenbaum extension issues, or (2) fixing DovetailingChain's 4 sorries which have the simplest structure.

## Key Findings

### Finding 1: Only ONE Axiom on Critical Path

The completeness proof chain (`Completeness.lean`) is sorry-free. All three theorems (`bmcs_representation`, `bmcs_weak_completeness`, `bmcs_strong_completeness`) compile without sorry. They depend on a single axiom: `fully_saturated_bmcs_exists` (line 773 of `TemporalCoherentConstruction.lean`).

Three other axioms exist in the codebase but are NOT on the critical path:
- `singleFamily_modal_backward_axiom` - Known FALSE, deprecated
- `saturated_extension_exists` - Superseded
- `weak_saturated_extension_exists` - Superseded

### Finding 2: Modal Saturation is SOLVED

`exists_fullySaturated_extension` in SaturatedConstruction.lean is **sorry-free** after Task 881 Phase 2. The S5 axiom 5 (negative introspection) breakthrough resolved all 3 modal saturation sorries by proving BoxContent is invariant under Lindenbaum extension for constant families.

### Finding 3: TemporalLindenbaum is a Dead End

Task 882 analysis proved fundamental problems:

**Counterexample (Henkin base case)**: `base = {F(p), ¬p}` is consistent, but the Henkin package `{F(p), p}` is inconsistent with base containing `¬p`. Therefore `henkinLimit` does NOT achieve forward saturation for formulas already in the base.

**Circularity (maximality)**: Proving `ψ ∈ insert φ M` when `φ = F(ψ)` requires M to already be in TCS, which requires temporal saturation, which is what we're trying to prove.

This means the Phase 4 handoff strategy (replace `set_lindenbaum` with `henkinLimit + temporalSetLindenbaum`) will NOT work.

### Finding 4: ZornFamily Has Structural Issues (3 FALSE Lemmas)

ZornFamily.lean contains lemmas that are mathematically FALSE:
- `multi_witness_seed_consistent_future/past` - Counterexample: F(p) and F(¬p) produce seed {p, ¬p}
- `non_total_has_boundary` - Counterexample: domain Z \ {0}

These are architectural red flags, not proof gaps. Zorn gives existence without construction trace, making F/P witness verification impossible.

### Finding 5: DovetailingChain is Most Promising Existing Approach

DovetailingChain has the simplest sorry structure:
| Sorry | Line | Nature |
|-------|------|--------|
| `forward_G` cross-sign | 606 | t < 0, chain built from 0 outward |
| `backward_H` cross-sign | 617 | Symmetric |
| `forward_F` witness | 633 | No witness enumeration |
| `backward_P` witness | 640 | No witness enumeration |

The cross-sign issue arises because forward and backward chains are built independently from 0. The existing `dovetailIndex` already interleaves (0, 1, -1, 2, -2, ...), so the fix is making `dovetailChainSet` include GContent from ALL previously assigned times.

### Finding 6: RecursiveSeed is Sorry-Free for Int

RecursiveSeed.lean demonstrates that unified modal+temporal witness placement works at the seed level with **0 sorries for Int**. Key patterns:
- `buildSeedAux` handles `boxNegative`, `futureNegative`, `pastNegative` uniformly
- `seedConsistent` proofs show how to maintain consistency through witness creation
- The pattern of `createNewFamily`/`createNewTime` before Lindenbaum could be adapted

### Finding 7: Historical Pattern Analysis

| Pattern | Success? | Examples |
|---------|----------|----------|
| Single-concern Zorn with tight invariants | YES | SaturatedConstruction.lean (0 sorries) |
| Formula-driven seed (no Lindenbaum) | YES | RecursiveSeed.lean (0 sorries) |
| S5-exploiting proofs | YES | BoxContent invariance via axiom 5 |
| Two-phase (temporal then modal) | NO | GContent+BoxContent incompatibility |
| Zorn for F/P witnesses | NO | Hides construction trace |
| Universal forward_F in Zorn | NO | Counterexample: F(p), F(¬p) |

## Conflicts Resolved

### Conflict: Is TemporalLindenbaum fixable?

**Teammate A**: TemporalLindenbaum is a dead end (counterexample proven)
**Teammate B**: TemporalLindenbaum sorries are genuine proof gaps, not false lemmas

**Resolution**: Both are partially correct. The CURRENT henkinLimit approach has a proven counterexample and cannot work. However, Teammate B is correct that the GOAL (temporally saturated MCS) is mathematically achievable through different construction methods. The specific implementation in TemporalLindenbaum.lean is flawed, not the mathematical concept.

**Verdict**: Do NOT attempt to fix TemporalLindenbaum.lean as-is. Instead, use alternative constructions (omega-step interleaving or DovetailingChain fixes).

## Gaps Identified

1. **No unified construction exists**: RecursiveSeed handles seeds but not full MCS families; modal saturation handles families but not temporal coherence
2. **F/P witness placement lacks construction trace**: Zorn approaches hide this; need explicit placement
3. **Truth lemma scope unclear**: Does `bmcs_truth_lemma` actually need temporal coherence for ALL families, or only eval_family?

## Recommendations

### Priority 1: Int-Specialization (Immediate, Low Risk)

The axiom is polymorphic in D but only Int is used downstream. Specialize to Int to:
- Remove the generic D sorry immediately
- Simplify all downstream work
- Focus effort on the only case that matters

### Priority 2a: Omega-Step Interleaving Construction (Medium Risk, High Reward)

Build a new `InterleaveConstruction.lean` that:
1. Enumerates all obligations: (t, G φ), (t, H φ), (t, F φ), (t, P φ) pairs
2. At each step, extends the partial assignment to satisfy the next obligation
3. Takes limit and applies Lindenbaum to each time point
4. Uses countability of formulas and Int to ensure all obligations are met

**Why this avoids known problems**:
- No "forward chain" and "backward chain" - everything built uniformly
- G(φ) at time t ensures φ placed at ALL future times already assigned AND added to seed for future times
- F(φ) creates explicit witness at t+1 (construction trace preserved)

### Priority 2b (Fallback): Fix DovetailingChain

Modify `dovetailChainSet` to include GContent from ALL previously assigned times:
- Cross-sign G/H: At step k, include GContent from times -k/2 through k/2
- F/P witnesses: Add explicit dovetailing enumeration of (formula, time) witness pairs

### Priority 3: Truth Lemma Scope Narrowing (Fallback)

If construction approaches fail, audit whether `bmcs_truth_lemma` can be restructured to require temporal coherence only for eval_family. This would:
- Eliminate need for witness families to be temporally coherent
- Decompose axiom into: modal saturation (proven) + eval-family temporal coherence

## Sorry Inventory on Critical Path

| File | Sorries | Status | Nature |
|------|---------|--------|--------|
| DovetailingChain.lean | 4 | On path | 2 cross-sign, 2 F/P |
| SaturatedConstruction.lean | 1 | On path | Temporal coherence of witnesses |
| TemporalCoherentConstruction.lean | 1 | On path | Generic D (only Int needed) |
| ZornFamily.lean | 5+ | Alternative | 3 FALSE, not viable |
| TemporalLindenbaum.lean | 4+ | Dead end | Fundamental flaws |

**Total on critical path**: 6 sorries + 1 axiom
**Target**: Eliminate the 1 axiom

## Teammate Contributions

| Teammate | Angle | Key Contribution | Confidence |
|----------|-------|------------------|------------|
| A | Current State | Comprehensive sorry inventory, viable approach ranking, omega-step proposal | Medium-High |
| B | Historical | Pattern analysis from 7+ tasks, warning signs catalog, RecursiveSeed insight | High |

## Next Steps

1. **Revise task 881 plan** to use recommended approach (Priority 2a or 2b)
2. **Abandon task 882** (TemporalLindenbaum dead end confirmed)
3. **Focus on Int-only** case to simplify problem space
4. If time permits, audit truth lemma scope (Priority 3)

## References

### Teammate Reports
- `specs/881_modally_saturated_bmcs_construction/reports/teammate-a-v3-findings.md`
- `specs/881_modally_saturated_bmcs_construction/reports/teammate-b-v3-findings.md`

### Prior Research
- research-001.md through research-003.md (this task)
- specs/870_*/reports/* (ZornFamily attempts)
- specs/880_*/reports/* (RecursiveSeed success)
- specs/882_*/summaries/implementation-summary-20260213.md (TemporalLindenbaum failure)

### Key Code Files
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - Modal saturation (proven)
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` - 0 sorries (seed construction)
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - 4 sorries (most promising)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - Axiom target
