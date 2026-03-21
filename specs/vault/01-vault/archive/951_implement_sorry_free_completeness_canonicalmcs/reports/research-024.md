# Research Report #024: Team Analysis of Unravel-Then-Saturate vs Monotone Witness Tracking

## Task 951 -- Sorry-Free Completeness via CanonicalMCS Domain

**Date**: 2026-03-02
**Session**: sess_1740936000_951team
**Mode**: Team Research (2 teammates)
**Focus**: Deep analysis of user-proposed "unravel-then-saturate" approach vs "monotone witness tracking" for resolving F-persistence obstacle. CONSTRAINT: Parallel truth_at_fragment predicates are FORBIDDEN.

---

## Executive Summary

Two Lean research specialists investigated complementary angles on resolving the F-persistence obstacle:

- **Teammate A** analyzed the "Unravel-Then-Saturate" construction in depth
- **Teammate B** analyzed "Monotone Witness Tracking" and compared both approaches

### Key Findings

1. **Naive "Unravel-Then-Saturate" is a DEAD END** -- adding witnesses `phi` for every `F(phi)` collapses to the constant-family approach (documented dead end in ROAD_MAP.md).

2. **A variant exists that is NOT a dead end**: The **F-formula preserving chain** -- instead of adding witnesses, add the F-OBLIGATIONS `F(psi)` to the Lindenbaum seed. This preserves obligations without collapsing time.

3. **The F-preserving variant hinges on one unproven conjecture**: Whether `{phi} ∪ {F(psi) | F(psi) ∈ w.world} ∪ GContent(w.world)` is consistent. Strong informal arguments suggest YES, but no formal proof exists.

4. **Even IF the conjecture holds, a deeper obstacle remains**: Lindenbaum non-determinism via `Classical.choose` means we cannot control WHERE the resulting MCS falls in the fragment's total order. The chain may still "jump past" witnesses even with F-obligations preserved.

5. **Monotone Witness Tracking has the right intuition but faces the same irreducible obstacle** -- positive forcing (including F-formulas in seeds) preserves F-FORMULAS but not the ORDERING constraint needed for F-persistence.

6. **The fragment-level approach completely bypasses all chain obstacles** -- `fragmentFMCS` already has sorry-free `forward_F` and `backward_P`. The only remaining challenge is Fragment-to-Int embedding.

### Recommendations

| Priority | Approach | Effort | Risk |
|----------|----------|--------|------|
| **1 (PRIMARY)** | Attempt formal proof of F-preserving seed consistency | 8-15 hours | Medium |
| **2 (FALLBACK)** | Fragment-to-Int embedding via order-theoretic SuccOrder | 20-35 hours | Medium-High |
| **3 (LAST RESORT)** | Accept fragment-level completeness as milestone | 5-10 hours | Low |

---

## Part 1: Teammate Contributions Summary

### Teammate A: Unravel-Then-Saturate Analysis

**Focus**: Precise definitions and consistency analysis

**Key contributions**:
- Identified that "unravel" cannot mean a simple closure (collapses time)
- Showed multi-witness seed `{psi_1, ..., psi_k} ∪ GContent(M)` is NOT always consistent
- Proposed the **F-formula preserving variant**: preserve `F(psi)` in seed, not `psi`
- Detailed syntactic argument for why preserving seed is LIKELY consistent
- Proved this variant is genuinely different from constant-family dead end

**Confidence**: MEDIUM overall

### Teammate B: Monotone Witness Tracking Analysis

**Focus**: Mechanism analysis and sub-strategy evaluation

**Key contributions**:
- Formal definition of Monotone Witness Tracking (pending set, witness map, step function)
- Showed seed consistency alone is INSUFFICIENT -- need ordering constraint too
- Analyzed three sub-strategies (constrained Lindenbaum, closest-witness-first, finite batching) -- all fail
- Identified root cause: `lindenbaumMCS_set` uses `Classical.choose`, providing no control
- Confirmed fragment-level approach bypasses all obstacles

**Confidence**: LOW (20%) for monotone tracking, HIGH (85%) for fragment approach

---

## Part 2: Synthesis of Findings

### 2.1 Point of Agreement: Naive Unravel-Then-Saturate is Dead

Both teammates confirm: if unraveling produces `F(phi) ∈ S → phi ∈ S`, the result is a constant family where all future witnesses exist at every time. This is documented as a dead end.

### 2.2 Point of Agreement: F-Formula Preserving Variant is Genuinely New

Adding `F(psi)` (the obligation) instead of `psi` (the witness) to the Lindenbaum seed does NOT collapse time. The obligation says "there will be a witness eventually" without placing the witness now.

The construction:
```
preservingForwardStep(w, phi_scheduled) :=
  let seed := {phi_scheduled} ∪ {F(psi) | F(psi) ∈ w.world} ∪ GContent(w.world)
  lindenbaumMCS_set seed (consistency_proof)
```

### 2.3 Key Difference: Sufficiency of Seed Consistency

**Teammate A**: If the preserving seed is consistent, and F-obligations are forced into every chain step, then at step `n = encode(psi)`, `F(psi)` is guaranteed to be present. Processing it places `psi`. This WOULD resolve `forward_F`.

**Teammate B**: Even if F-obligations persist, the Lindenbaum extension may "jump past" the witness `s_psi` in the fragment order. At that point, `F(psi) ∈ chain(k)` but `psi` cannot enter future chain elements because `G(¬psi)` may have entered when passing `s_psi`.

**Resolution**: Both are correct. The F-preserving approach ensures the OBLIGATION persists. But processing the obligation at step `n` requires `F(psi) ∈ chain(n).world`, which is guaranteed by preservation. So Teammate A's analysis IS correct: if the seed is consistent, forward_F is provable.

The ordering constraint that Teammate B identifies is about F-persistence BETWEEN steps, not AT the processing step. With F-formula forcing, `F(psi)` is in every chain element (forced into every seed), so it's present at step `n` regardless of jumps.

### 2.4 Critical Insight: The Order Doesn't Matter If Obligations Are Forced

**Key realization from synthesis**: If `{F(psi) | F(psi) ∈ w.world}` is forced into EVERY Lindenbaum seed, then `F(psi)` is in EVERY chain element after `w`. The obligation never disappears. At step `encode(psi)`, we process `F(psi)` and place `psi` -- done.

The "jumping past witnesses" problem only arises when F-obligations can be LOST. With forcing, they cannot be lost.

### 2.5 The Single Remaining Question

**Conjecture (Preserving Seed Consistency)**:
If `w` is a fragment element, `F(phi) ∈ w.world`, and `Σ = {F(psi) | F(psi) ∈ w.world}`, then `{phi} ∪ Σ ∪ GContent(w.world)` is consistent.

**Argument summary** (from Teammate A):
- `Σ ∪ GContent(w.world) ⊆ w.world` (all formulas are in the MCS)
- `{phi} ∪ GContent(w.world)` is consistent (by `enriched_seed_consistent_from_F`)
- The F-formulas in `Σ` carry "future existence" information that doesn't propositionally contradict `phi`
- TM axioms don't derive `¬phi` from F-formulas and G-formulas alone

**Status**: UNPROVEN but LIKELY TRUE.

---

## Part 3: Conflicts and Resolutions

### Conflict 1: Whether Multi-Witness Seeds Are Consistent

**Teammate A**: `{psi_1, ..., psi_k} ∪ GContent(w.world)` is NOT always consistent (counterexample exists)

**Teammate B**: The seed `{phi} ∪ {F(psi) | F(psi) ∈ w.world} ∪ GContent(w.world)` IS consistent

**Resolution**: These are DIFFERENT seeds. Teammate A discusses adding WITNESSES (psi_i). Teammate B discusses adding F-FORMULAS (F(psi_i)). The F-formula seed IS a subset of w.world, so it's trivially consistent on its own. Adding `phi` requires the full argument. Both are correct -- no conflict.

### Conflict 2: Whether Fragment Approach Is The Only Path

**Teammate A**: F-preserving chain COULD resolve forward_F if seed consistency holds

**Teammate B**: Recommends abandoning chain approaches for fragment-level

**Resolution**: Not a conflict. Teammate A identifies the minimal remaining conjecture. Teammate B provides the fallback if the conjecture fails or its proof is too complex. Both paths are valid; we should attempt the conjecture proof first.

---

## Part 4: Recommended Path Forward

### Priority 1: Prove the Preserving Seed Consistency Conjecture

**What**: Prove in Lean that `{phi} ∪ {F(psi) | F(psi) ∈ w.world} ∪ GContent(w.world)` is consistent when `F(phi) ∈ w.world`.

**How** (three approaches from Teammate A Section 10.1):
1. **Syntactic**: Show no TM derivation can produce `¬phi` from F-formulas and G-formulas
2. **Semantic**: Construct a model where all seed formulas hold simultaneously
3. **Reduction**: Show F-formulas add no derivational power beyond GContent

**If successful**: Modify `fragmentChainStepForward` to include F-formula forcing, prove forward_F sorry-free, eliminate both DovetailingChain sorries.

**Estimated effort**: 8-15 hours

### Priority 2: Fragment-to-Int Embedding (Fallback)

If the conjecture proof fails or stalls:

**What**: Prove `BidirectionalQuotient` is order-isomorphic to `Int` using Mathlib infrastructure.

**How**:
1. Define order-theoretic `SuccOrder` on quotient (not `fragmentGSucc`)
2. Prove `PredOrder`, `NoMaxOrder`, `NoMinOrder`, `IsSuccArchimedean`
3. Apply `orderIsoIntOfLinearSuccPredArch`
4. Transfer fragmentFMCS through the isomorphism

**Key prerequisite**: Prove quotient is discrete (no intermediate elements between adjacent positions).

**Estimated effort**: 20-35 hours

### Priority 3: Fragment-Level Completeness (Milestone)

If embedding stalls:

**What**: Accept completeness over `BidirectionalFragment` as an intermediate result.

**Trade-off**: The theorem statement is non-standard (uses fragment as time domain instead of Int).

**Value**: Still a valid mathematical result; can be extended to Int later.

**Estimated effort**: 5-10 hours

---

## Part 5: Gaps Identified

### Gap 1: Formal Proof of Preserving Seed Consistency

No Lean proof exists. The informal argument is strong but needs formalization. This is the HIGHEST PRIORITY gap.

### Gap 2: Quotient Discreteness

The quotient is believed discrete (no intermediate elements), but no formal proof exists. Required for Priority 2 path.

### Gap 3: Quotient Countability

The fragment/quotient is believed countable (finite paths from countable language), but no formal proof exists. Required for Priority 2 path.

---

## Part 6: Evidence Summary

### Sorry-Free Lemmas Supporting the Construction

| Lemma | File | Supports |
|-------|------|----------|
| `enriched_seed_consistent_from_F` | CanonicalCompleteness.lean:198 | Single-witness seed consistency |
| `F_persistence_in_fragment` | FragmentCompleteness.lean:67 | F-formula persistence under ordering |
| `forward_F_stays_in_fragment` | BidirectionalReachable.lean:195 | Fragment witness existence |
| `fragmentFMCS_forward_F` | CanonicalCompleteness.lean:91 | Sorry-free forward_F at fragment level |
| `fragmentFMCS_backward_P` | CanonicalCompleteness.lean:105 | Sorry-free backward_P at fragment level |
| `bidirectional_totally_ordered` | BidirectionalReachable.lean:728 | Linear order on fragment |
| `buildFragmentChain_monotone` | FragmentCompleteness.lean:362 | Chain is order-preserving |

### Remaining Sorries

| Sorry | File | Root Cause | Resolution Path |
|-------|------|-----------|-----------------|
| `fragmentChainFMCS_forward_F` | FragmentCompleteness.lean:460 | F-persistence through chain | F-preserving seed OR embedding |
| `fragmentChainFMCS_backward_P` | FragmentCompleteness.lean:471 | P-persistence through chain | P-preserving seed (symmetric) |
| `fully_saturated_bfmcs_exists_int` | TemporalCoherentConstruction.lean:600 | Combines temporal + modal | Depends on above two |

---

## Part 7: Final Verdict

**The user's "unravel-then-saturate" intuition IS correct in spirit.** The key insight is that F-obligations should be preserved through the chain, not lost to non-deterministic Lindenbaum extensions.

**The implementation is NOT adding witnesses (constant family dead end) but adding F-FORMULAS to the Lindenbaum seed.** This preserves obligations without collapsing time.

**The single remaining mathematical question is whether the F-preserving seed is consistent.** All evidence suggests YES, but formal proof is needed.

**If proof succeeds**: The two DovetailingChain sorries are directly resolved, and `fully_saturated_bfmcs_exists_int` follows.

**If proof fails**: The fragment-to-Int embedding path remains viable (higher effort but well-understood).

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Unravel-Then-Saturate | Completed | Medium |
| B | Monotone Witness Tracking | Completed | Low (tracking), High (fragment) |

---

## References

### Codebase
- `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean` -- fragmentFMCS, enriched seeds
- `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean` -- fragment infrastructure
- `Theories/Bimodal/Metalogic/Bundle/FragmentCompleteness.lean` -- current chain with 2 sorries
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` -- lindenbaumMCS_set

### Prior Research
- research-023: Strategy analysis (confirms multi-witness inconsistency for WITNESSES, not F-formulas)
- research-022: Histories-first analysis
- research-021: Synthesis of 20 reports

### Mathlib
- `orderIsoIntOfLinearSuccPredArch` -- target for embedding path
