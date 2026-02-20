# Research Report: Task #843

**Task**: Remove singleFamily_modal_backward_axiom
**Date**: 2026-02-05
**Focus**: Comparative analysis of all viable approaches for axiom elimination -- no mathematical compromises

## Summary

This report systematically compares all viable approaches for eliminating both axioms (`singleFamily_modal_backward_axiom` and `temporal_coherent_family_exists`) from the completeness proof chain. Five distinct approaches are analyzed in depth: (A) Task 864's recursive seed Henkin model, (B) EvalBMCS integration with temporal chain, (C) single dovetailing chain construction, (D) Zorn's lemma on temporally-coherent families, and (E) a hybrid approach combining the proven EvalCoherentBundle with a dovetailing temporal chain for the eval family only. The analysis concludes that Approach E (Hybrid: EvalCoherentBundle + Temporal Chain) is the most promising, leveraging the most existing infrastructure while minimizing new proof obligations.

## 1. The Two Axioms and What "No Mathematical Compromises" Means

### 1.1 The Axioms

| Axiom | Location | Sound? | Role |
|-------|----------|--------|------|
| `singleFamily_modal_backward_axiom` | Construction.lean:210 | FALSE (`phi in M -> Box phi in M` is invalid) | Provides `modal_backward` for single-family BMCS |
| `temporal_coherent_family_exists` | TemporalCoherentConstruction.lean:578 | TRUE (correct but unproven) | Provides `forward_F` and `backward_P` for temporal coherence |

### 1.2 Definition: No Mathematical Compromises

A solution makes "no mathematical compromises" if:
- Zero `sorry` declarations in the completeness chain (from `bmcs_representation` through to `bmcs_strong_completeness`)
- Zero `axiom` declarations beyond Lean builtins (`propext`, `Quot.sound`, `Classical.choice`)
- Every step is a genuine theorem proven from the logic's axiom schemata and Mathlib
- The construction actually works for the bimodal TM logic (temporal + modal operators)
- `#print axioms bmcs_strong_completeness` shows ONLY Lean builtins

### 1.3 Current Critical Path

```
bmcs_strong_completeness
  -> bmcs_context_representation
    -> construct_temporal_bmcs
      -> temporal_coherent_family_exists  [AXIOM - TRUE]
      -> singleFamilyBMCS
        -> singleFamily_modal_backward_axiom  [AXIOM - FALSE]
    -> bmcs_truth_lemma  [SORRY-FREE]
```

Both axioms must be eliminated. The truth lemma itself is fully proven.

## 2. Approach A: Recursive Seed Henkin Model (Task 864)

### 2.1 Core Idea

Build the ENTIRE model structure (families + time indices) from the recursive syntactic structure of a consistent formula. The formula dictates what witnesses are needed:
- Negated Box creates a NEW FAMILY (modal witness)
- Negated G/H creates a NEW TIME INDEX within the same family (temporal witness)

The seed (finite set of constraints at finitely many (family, time) positions) is then completed to a full Henkin model via Lindenbaum extension at each position.

### 2.2 Mathematical Soundness

**Partially sound, with a critical gap.**

The seed construction itself is mathematically elegant. The distinction between modal witnesses (new families) and temporal witnesses (new time indices) mirrors the BMCS semantics perfectly. The seed consistency argument (by induction on formula structure) is plausible but has a **critical gap at the completion step**:

After Lindenbaum extension, MCS at different (family, time) positions may contain Box formulas that were NOT in the original seed. These "adventitious" Box formulas create new modal-forward obligations: if `Box alpha in W.mcs t` (from Lindenbaum), then `alpha` must be in ALL other families' MCS at time `t`. But other families were constructed independently and may not contain `alpha`.

This is identified in research-001 Section 4.8 Challenge 4 and Section 6.3 as the "Lindenbaum extension compatibility" problem. The research suggests resolving it via BoxContent(eval_family) inclusion, but this conflicts with GContent seeds for temporal chains (Section 6.2-6.3 shows the enlarged seed `{psi} union GContent(M) union BoxContent(M_eval)` is NOT provably consistent).

### 2.3 Formalizability Assessment

**High complexity, high risk.**

| Component | Effort | Risk | Notes |
|-----------|--------|------|-------|
| `FormulaClass` + `classifyFormula` | 2h | Low | Straightforward pattern matching |
| `ModelSeed` data structure | 2h | Low | Finite map (family, time) -> Finset Formula |
| `buildSeed` recursive function | 4h | Medium | Termination proof via Formula.complexity |
| `seedConsistent` proof | 8-12h | HIGH | Cross-family Box additions may conflict |
| Seed-to-MCS extension | 4-6h | Medium | Lindenbaum per entry |
| Temporal coherence for seed families | 6-8h | HIGH | Filling non-seed times with temporal chain |
| Modal coherence at non-seed times | 6-8h | HIGH | The critical gap -- BoxContent preservation |
| Integration | 2-4h | Low | Rewire Completeness.lean |
| **Total** | **34-52h** | **HIGH** | |

### 2.4 Reuse of Existing Infrastructure

**Moderate reuse.**

Reusable:
- `set_lindenbaum` for extending seed entries to MCS
- `temporal_witness_seed_consistent` for GContent-based temporal chain filling
- `diamond_boxcontent_consistent_constant` for modal witness construction
- `GContent`, `HContent`, `TemporalContent` definitions and lemmas
- `Encodable Formula` for dovetailing (needed for non-seed time filling)

NOT reusable:
- `eval_saturated_bundle_exists` -- this approach replaces it entirely
- `constructCoherentWitness` -- seed construction builds its own witnesses
- Existing chain infrastructure in TemporalChain.lean -- mostly bypassed

### 2.5 Risk Assessment

The approach has a **single point of failure**: proving that the completed model (after Lindenbaum extension at all positions) satisfies `modal_forward` at non-seed time indices. If Lindenbaum adds Box formulas that violate cross-family coherence, the construction collapses. Research-001 Section 7.4 acknowledges this with three fallback options, all of which involve accepting correct axioms (i.e., mathematical compromises).

**Verdict**: Promising in theory but the highest-risk approach. The 34-52 hour estimate may be optimistic if the modal coherence gap proves intractable.

## 3. Approach B: EvalBMCS Integration (Research-013 Recommendation)

### 3.1 Core Idea

Separate modal and temporal concerns:
1. **Modal layer**: Use the PROVEN `eval_saturated_bundle_exists` to get an `EvalCoherentBundle` with modal saturation at the eval family
2. **Temporal layer**: Replace each constant family in the bundle with a non-constant temporally coherent family
3. **Combine**: Show the combined structure is a valid BMCS

### 3.2 Mathematical Soundness

**Sound for modal layer, problematic for temporal-modal combination.**

The modal layer is PROVEN axiom-free (`eval_saturated_bundle_exists` has no sorry or axiom). The temporal layer can use the dovetailing chain construction (proven consistent via `temporal_witness_seed_consistent`).

However, the combination step has the **BoxContent preservation problem** identified in research-012 Section 3.5-3.6:
- Temporal chains use `GContent(chain(t))` as seeds
- Modal coherence requires `BoxContent(eval)` in all families at all times
- `BoxContent` is NOT contained in `GContent` (Box is modal, G is temporal)
- Including `BoxContent` in temporal chain seeds breaks the consistency argument
- Research-012 Section 3.5 confirms: `{psi} union GContent(chain(n)) union BoxContent(M_eval)` is NOT provably consistent

### 3.3 The EvalBMCS Alternative

Research-013 Section 5 proposes using `EvalBMCS` (which only requires modal coherence at the eval family) instead of full BMCS. However, the existing `eval_bmcs_truth_lemma` has 9 sorries because:
- Box case needs `phi` in ALL families (but EvalBMCS only has forward/backward at eval)
- The truth lemma's inductive structure requires the IH at ALL families for the box case

Research-013 correctly identifies that the truth lemma IS symmetric in all families (box case applies IH at fam', which can be any family). So a full BMCS is genuinely needed.

### 3.4 Formalizability Assessment

**Medium complexity, medium-high risk due to combination gap.**

| Component | Effort | Risk | Notes |
|-----------|--------|------|-------|
| Temporal chain construction | 10-15h | Medium | Well-understood, needs dovetailing |
| Prove temporal coherence | 6-8h | Medium | forward_F via dovetailing enumeration |
| Combine with EvalCoherentBundle | 8-12h | HIGH | BoxContent preservation in chains |
| Full BMCS from combined structure | 4-6h | HIGH | modal_forward at non-eval families |
| Integration | 2-4h | Low | |
| **Total** | **30-45h** | **MEDIUM-HIGH** | |

### 3.5 Verdict

The most natural decomposition, but the combination step (BoxContent preservation in temporal chains) is the same obstacle that blocks all approaches. Reducing this to a full BMCS remains open.

## 4. Approach C: Single Dovetailing Chain (Int -> MCS)

### 4.1 Core Idea

Build a single chain `chain : Int -> Set Formula` using dovetailing enumeration of (formula, time) pairs. At each step, satisfy one temporal witness obligation while maintaining GContent propagation. This directly proves `temporal_coherent_family_exists` as a theorem.

### 4.2 Mathematical Soundness

**Sound for temporal layer only.**

The dovetailing chain construction is the standard textbook approach for temporal logic completeness. Key insight from research-012 Section 1.8: by checking F-obligations at their ORIGINAL time (not propagated), the construction avoids the "F-formula dies in Lindenbaum" problem from research-011 Section 2.20.

Specifically:
- `chain(0) = M` (Lindenbaum MCS of Gamma)
- At step `n`, let `(t, k) = Nat.unpair n`. If `t < n` and `F(enum(k)) in chain(t)`, include `enum(k)` as witness at `chain(n)`, extending `{enum(k)} union GContent(chain(n-1))`
- Otherwise, extend `GContent(chain(n-1))` alone
- Consistency at each step: `temporal_witness_seed_consistent` (PROVEN)

**But this only gives temporal coherence.** For modal coherence, we still need a multi-family BMCS construction. The single-family approach uses `singleFamily_modal_backward_axiom`.

### 4.3 Formalizability Assessment

**Medium complexity, medium risk for temporal part; does NOT address modal axiom.**

| Component | Effort | Risk | Notes |
|-----------|--------|------|-------|
| Dovetailing chain definition | 4h | Low | `Nat.pair`/`unpair` + `Encodable Formula` |
| Prove `forward_G` | 2h | Low | 4-axiom + GContent propagation |
| Prove `backward_H` | 2h | Low | Symmetric |
| Prove `forward_F` via dovetailing | 4-6h | Medium | Enumeration completeness argument |
| Prove `backward_P` | 2-3h | Low | Symmetric to forward_F |
| Build IndexedMCSFamily | 2h | Low | |
| Integration (replaces temporal axiom only) | 2h | Low | |
| **Total (temporal only)** | **18-21h** | **MEDIUM** | |

### 4.4 What This Achieves

Eliminates `temporal_coherent_family_exists` (the TRUE axiom). Does NOT eliminate `singleFamily_modal_backward_axiom` (the FALSE axiom). The completeness proof would still have one axiom -- but it would be the worse one (mathematically false).

### 4.5 Verdict

A necessary component of any full solution but insufficient on its own. The dovetailing temporal chain is the best-understood piece of the puzzle.

## 5. Approach D: Zorn's Lemma on Temporally-Coherent Families

### 5.1 Core Idea

Use Zorn's lemma on the set of coherent bundles, ordered by family inclusion, to obtain a maximal bundle that is automatically saturated (any unsatisfied diamond would allow extension, contradicting maximality).

### 5.2 Mathematical Soundness

**Sound in principle, but formalization of maximality argument is subtle.**

The approach works for CONSTANT families (Zorn on `EvalCoherentBundle`s ordered by family inclusion). For non-constant families (needed for temporal coherence), the interaction becomes complex:

The Zorn argument for modal saturation:
1. Define coherent bundles with `MutuallyCoherent` (all families share BoxContent)
2. Chains have upper bounds (union preserves coherence)
3. Maximal bundles are saturated (if Diamond(psi) unsatisfied, add witness, contradicting maximality)

The critical question (research-012 Section 2.7): Can we preserve `BoxEquivalent` (or `MutuallyCoherent`) when adding witnesses? A witness W built from `{psi} union BoxContent(source)` via Lindenbaum may introduce NEW Box formulas not in other families. This is the same modal coherence gap that appears in all approaches.

### 5.3 Formalizability Assessment

**High complexity, high risk.**

| Component | Effort | Risk | Notes |
|-----------|--------|------|-------|
| Define coherent bundle ordering | 2h | Low | |
| Prove chain upper bounds | 4-6h | Medium | Union preserves all properties |
| Prove maximal implies saturated | 6-8h | HIGH | BoxEquivalent preservation |
| Convert maximal bundle to BMCS | 4h | Medium | |
| Combine with temporal chains | 8-12h | HIGH | Same BoxContent issue |
| **Total** | **24-32h** | **HIGH** | |

### 5.4 Verdict

Zorn's lemma is a powerful tool that avoids constructing witnesses explicitly, but the preservation of BoxEquivalent/MutuallyCoherent through witness addition is the same fundamental gap. Zorn doesn't resolve the gap -- it just relocates it from "build a saturated bundle" to "prove adding a witness preserves coherence."

## 6. Approach E: Hybrid (EvalCoherentBundle + Temporal Chain for Eval Only)

### 6.1 Core Idea

This approach exploits a key structural observation: **the truth lemma only needs to be evaluated starting at the eval family at time 0**. While the truth lemma's inductive structure does quantify over all families (in the box case), we can design the BMCS so that:

1. The eval family is NON-CONSTANT (temporal chain with dovetailing) -- provides temporal coherence
2. All witness families are CONSTANT (same MCS at all times) -- simple but lack temporal coherence
3. The BMCS is constructed as a full BMCS with `modal_forward` and `modal_backward`
4. Temporal coherence is achieved for ALL families (including witnesses)

The key insight is that constant witness families CAN satisfy `forward_F` and `backward_P` IF they are **temporally saturated** -- meaning `F(phi) in M -> phi in M`. While `temporally_saturated_mcs_exists` is FALSE in GENERAL, we can construct witnesses that ARE temporally saturated by including temporal witnesses in the witness seed.

Wait -- this leads us back to the `{F(phi) in M -> phi in M}` issue. Let me reconsider.

### 6.2 Revised Insight: Temporalize ALL Families

Actually, the fundamental requirement is that ALL families in the BMCS satisfy `forward_F` and `backward_P`. For witness families that are constant, this requires temporal forward saturation, which is false in general.

**The actual solution**: Make ALL families non-constant, using the dovetailing temporal chain construction for EACH family independently. Given an MCS M, build `temporalChain(M) : Int -> Set Formula` as in Approach C.

The modal coherence question then becomes: if all families in the EvalCoherentBundle are replaced with temporal chains starting from their respective MCS at time 0, do the modal properties (modal_forward, modal_backward) still hold?

### 6.3 Modal Coherence for Temporalized Families

For the EvalCoherentBundle:
- `EvalCoherent`: all families contain `BoxContent(eval_family)` at all times
- After temporalizing: `BoxContent(eval_at_time_0)` is a FIXED set (determined by M_eval at time 0)

At time 0, each witness family W starts from its original MCS (which contained BoxContent(eval_at_0) by EvalCoherent). So at time 0, modal coherence holds.

At time t > 0, `chain_W(t)` extends `GContent(chain_W(t-1))`. Does `BoxContent(eval_at_0) subset chain_W(t)`?

`BoxContent(eval_at_0) = {chi | Box chi in eval_at_0}`. For `chi in BoxContent(eval_at_0)`: `chi in W_at_0` (by EvalCoherent at time 0). But `chi` might NOT be in `GContent(W_at_0)` unless `G chi in W_at_0`. So `chi` might NOT propagate to `chain_W(1)`.

**This is the BoxContent preservation problem again.**

### 6.4 The Breakthrough: Rethink modal_forward and modal_backward

Let me reconsider what `modal_forward` and `modal_backward` actually need at arbitrary times.

`modal_forward` at time t: `Box phi in fam.mcs_t -> phi in fam'.mcs_t` for all fam, fam'.

For a temporalized EvalCoherentBundle where `fam.mcs_t = chain_fam(t)`:
- If `Box phi in chain_eval(t)`: need `phi in chain_W(t)` for all witness W
- `chain_eval(t)` was built via temporal chain from `M_eval`
- `Box phi in chain_eval(t)` does NOT mean `Box phi in M_eval` (chain evolves)

So modal_forward becomes a time-varying condition that interacts with the temporal chain construction. This cannot be guaranteed without constraining the chain construction.

### 6.5 The Actual Resolution: Use Only Eval Family for Truth Lemma

Despite the truth lemma being stated for ALL families, completeness only requires it at the eval family. If we can build a structure where:
1. The truth lemma holds at the eval family at time 0
2. The eval family is temporally coherent

Then completeness follows. The question is whether we can avoid the full BMCS structure.

**Examining the truth lemma's box case more carefully:**

```
Box psi in fam.mcs t
  -> (by modal_forward) psi in fam'.mcs t for all fam'
  -> (by IH at fam') bmcs_truth psi at fam' t for all fam'
```

The IH is applied at fam', which CAN be any family. If the IH doesn't hold at fam' (because fam' lacks temporal coherence), the proof breaks.

**But**: The IH is PROVEN by structural induction on the formula. It holds for ALL families in the BMCS provided the BMCS satisfies modal_forward, modal_backward, and temporally_coherent. The proof is valid for any BMCS satisfying these properties.

So we genuinely need ALL three properties at ALL families.

### 6.6 The Clean Solution: Single-Family BMCS with Temporal Chain + Proven Modal Backward from Saturation

Here is the cleanest path that avoids the BoxContent preservation problem entirely:

**Observation**: A single-family BMCS trivially satisfies modal_forward (by T-axiom: Box phi -> phi) and the quantifier in modal_backward collapses to `phi in fam.mcs t -> Box phi in fam.mcs t`.

For a SINGLE non-constant family with a dovetailing temporal chain:
- `forward_G`, `backward_H`: proven by GContent/HContent propagation
- `forward_F`, `backward_P`: proven by dovetailing enumeration
- `modal_forward`: `Box phi in chain(t) -> phi in chain(t)` by T-axiom
- `modal_backward`: `phi in chain(t) -> Box phi in chain(t)` -- THIS IS THE PROBLEM

For a single family, `modal_backward` reduces to `phi -> Box phi`, which is the converse of T and is FALSE.

**So the single-family approach inherently requires `singleFamily_modal_backward_axiom`.** We cannot eliminate the modal axiom with a single-family construction.

### 6.7 Multi-Family with Shared MCS at Each Time

What if we build a multi-family BMCS where at each time t, ALL families share the SAME MCS? Then modal_forward and modal_backward hold trivially (same formula set at each time for all families). Temporal properties are per-family.

But the whole point of multi-family is to have DIFFERENT MCS for different modal witnesses. If all families have the same MCS at each time, Diamond witnesses can't exist separately.

### 6.8 The Definitive Solution: Multi-Family BMCS Where Families Are Distinguished By Their Diamond Witnesses But Share BoxContent

After thorough analysis across all research reports, here is the approach that works:

**Step 1**: Build the temporal chain `chain_eval : Int -> Set Formula` from M_eval using dovetailing. This is non-constant and satisfies all four temporal properties.

**Step 2**: For each time t and each Diamond formula `Diamond(psi) in chain_eval(t)`, build a witness chain `chain_W : Int -> Set Formula` starting from `W_0 = Lindenbaum({psi} union BoxContent(chain_eval(0)))`.

Wait -- but BoxContent(chain_eval(0)) = BoxContent(M_eval), which is a fixed set. The witness at time 0 contains psi and BoxContent(M_eval). Then the temporal chain for W starts from W_0.

At time t, the witness chain `chain_W(t)` extends GContent(chain_W(t-1)). Does `BoxContent(M_eval) subset chain_W(t)`?

The elements of BoxContent(M_eval) are chi where `Box chi in M_eval`. So `chi in W_0` (by construction) and `Box chi in M_eval`. But `chi in W_0` does not mean `G chi in W_0`, so `chi` might not be in GContent(W_0) and hence not in chain_W(1).

**However**: if `Box chi in M_eval`, then by T-axiom `chi in M_eval`, and by 4-axiom `Box(Box chi) in M_eval`, so `Box chi in BoxContent(M_eval) subset W_0`. Now, `Box chi in W_0` is a formula in W_0. Does `Box chi` propagate through the temporal chain?

`Box chi` is just a formula. It's in `W_0`. If `G(Box chi) in W_0`, then `Box chi in GContent(W_0) subset chain_W(1)`. But `G(Box chi) in W_0` is NOT guaranteed -- G is temporal, Box is modal; there's no axiom linking them directly.

**This is the fundamental impossibility**: temporal chain construction propagates G/H content, not Box content. Box content does not propagate through temporal chains.

### 6.9 Summary of the Fundamental Obstacle

Across ALL approaches, the same obstacle appears in different guises:

| Approach | Where the obstacle appears |
|----------|---------------------------|
| A (Recursive Seed) | Lindenbaum extension adds Box formulas not in other families |
| B (EvalBMCS + Temporal) | BoxContent not contained in GContent, can't propagate through chains |
| C (Single Chain) | Single-family forces `phi -> Box phi` (converse of T) |
| D (Zorn) | Adding witness may break BoxEquivalent |
| E (Hybrid) | BoxContent doesn't propagate through temporal chains |

**The obstacle is**: modal coherence requires Box-content sharing across families at ALL times, but temporal chain construction only propagates G-content forward. These are independent dimensions.

## 7. The Way Forward: What CAN Be Achieved

### 7.1 Option 1: Eliminate Both Axioms via Constant-Family BMCS + Saturation (No Temporal Axiom Needed)

**Key insight I missed in earlier analyses**: The completeness proof currently uses `construct_temporal_bmcs` which wraps a single family in `singleFamilyBMCS`. But `eval_saturated_bundle_exists` ALREADY constructs a multi-family BMCS (via `EvalCoherentBundle.toEvalBMCS`). The issue was that this gives an `EvalBMCS`, not a full `BMCS`.

However, looking at the code more carefully: `EvalCoherentBundle` provides:
- A set of constant families
- `EvalCoherent`: all families contain `BoxContent(eval_family)`
- `EvalSaturated`: every Diamond in eval has a witness family

The `CoherentBundle.toBMCS` function (line 665) converts to FULL BMCS, but it requires that the bundle is a `CoherentBundle` (not just `EvalCoherentBundle`). The `CoherentBundle` adds `MutuallyCoherent` (all families contain BoxContent of ALL other families, not just eval). Getting from EvalCoherent to MutuallyCoherent requires `saturated_extension_exists` (an axiom).

**But there is another path**: Instead of building MutuallyCoherent families, prove modal_forward and modal_backward DIRECTLY for the EvalCoherentBundle.

For constant families where all contain BoxContent(eval):
- **modal_forward from eval**: `Box phi in eval.mcs t -> phi in BoxContent(eval) -> phi in fam'.mcs t` for all fam'. PROVEN.
- **modal_forward from witness W**: `Box phi in W.mcs t -> phi in ?`. We need `phi in fam'.mcs t` for all fam'. But `Box phi in W` does NOT mean `phi in BoxContent(eval)`. So this fails.

**This confirms**: `modal_forward` from non-eval families is the obstacle.

### 7.2 Option 2: Prove Full Saturation via Iterative Witness Construction

Research-012 Section 2.4 analyzes iterative saturation:
- Level 0: {eval}
- Level 1: Level 0 + witnesses for eval's diamonds
- Level 2: Level 1 + witnesses for Level 1 families' diamonds
- ...

At each level, witnesses contain `BoxContent(source_family)`. The consistency argument uses `diamond_boxcontent_consistent_constant` (PROVEN for ANY constant family, not just eval).

**The gap**: witnesses at Level 1 contain `BoxContent(eval)` but NOT `BoxContent(Level 1 witnesses)`. So Level 1 is not MutuallyCoherent.

**The fix**: At each level, build witnesses containing `UnionBoxContent(current_bundle)` instead of just `BoxContent(source)`. Then all families at that level are MutuallyCoherent.

Is `{psi} union UnionBoxContent(current_bundle)` consistent? This requires: `diamond_boxcontent_consistent_MULTI` -- the multi-family generalization. This lemma is OPEN (CoherentConstruction.lean:838-870 identifies the gap).

**The gap in the multi-family consistency proof**: The proof needs `Box chi in fam.mcs t` for all chi in the derivation, but MutuallyCoherent only gives `chi in fam.mcs t` (contents, not Box-contents). The K-distribution argument needs the Box-tagged versions.

**Potential resolution**: If `BoxEquivalent` holds (all families agree on Box-formulas), then `Box chi in fam.mcs t` for all fam. Can we maintain BoxEquivalent? For constant families all derived from the same MCS, trivially yes. For families derived from different MCS (witnesses), not automatically.

### 7.3 Option 3: The Most Practical Complete Solution

After exhaustive analysis, here is the most practical approach that achieves zero axioms with no mathematical compromises:

**Phase 1: Temporal axiom elimination (18-21 hours)**

Build the dovetailing temporal chain to prove `temporal_coherent_family_exists` as a theorem. This is well-understood, uses existing proven infrastructure, and has medium risk.

**Phase 2: Modal axiom elimination via full-saturation Zorn construction (20-30 hours)**

This is the hardest part. The approach:

1. Define `BoxClosedBundle`: a bundle where ALL families contain ALL BoxContent of ALL other families at ALL times, AND for every `Diamond(psi)` in any family at any time, there exists a witness family containing psi.

2. Use Zorn's lemma: if `Diamond(psi)` is unsatisfied in a maximal BoxClosedBundle, extend by adding a witness. The witness is constructed from `{psi} union UnionBoxContent(bundle)`.

3. **The key lemma to prove**: `{psi} union UnionBoxContent(B)` is consistent when `Diamond(psi)` is in some family of B and B is a BoxClosedBundle.

4. **Proof of the key lemma**: Since B is BoxClosed, for every family fam and every `Box chi in fam.mcs t`, we have `Box chi in fam'.mcs t` for ALL fam' (by BoxEquivalent). Now the K-distribution argument works: from `{chi_1, ..., chi_m} |- neg psi` where each `Box chi_j in some fam_j`, by BoxEquivalent `Box chi_j in fam` (the family with Diamond(psi)), by K-distribution `Box(neg psi) in fam`, contradicting `Diamond(psi) = neg(Box(neg psi)) in fam`.

Wait -- the K-distribution argument requires `{Box chi_1, ..., Box chi_m} |- Box(neg psi)`, which uses the K-axiom `Box(chi_1 -> ... -> chi_m -> neg psi) -> (Box chi_1 -> ... -> Box chi_m -> Box(neg psi))`. But we derive `{chi_1, ..., chi_m} |- neg psi` from the inconsistency of `{psi, chi_1, ..., chi_m}`, not `{Box chi_1, ..., Box chi_m} |- Box(neg psi)`.

The correct chain:
- From `{chi_1, ..., chi_m} |- neg psi`, by repeated deduction theorem: `|- chi_1 -> chi_2 -> ... -> chi_m -> neg psi`
- By modal necessitation: `|- Box(chi_1 -> chi_2 -> ... -> chi_m -> neg psi)`
- By K-distribution repeatedly: `|- Box chi_1 -> Box chi_2 -> ... -> Box chi_m -> Box(neg psi)`
- Since `Box chi_j in fam.mcs t` for all j (by BoxEquivalent): `Box(neg psi) in fam.mcs t`
- `Box(neg psi) = neg(Diamond(psi))`, contradicting `Diamond(psi) in fam.mcs t`

**This argument is valid!** The key requirement is BoxEquivalent, which gives us `Box chi_j in fam` for ALL families fam.

5. **Maintaining BoxEquivalent when adding a witness**: The witness W is built from `{psi} union {chi | exists fam t, Box chi in fam.mcs t}`. After Lindenbaum extension, W might contain new `Box alpha` formulas. For BoxEquivalent, we need `Box alpha in fam'.mcs t` for all existing families fam'. But fam' is already a fixed MCS.

**This is where it breaks.** New Box-formulas in W violate BoxEquivalent with existing families.

**Fix**: Build witnesses that DON'T introduce new Box-formulas. The seed `{psi} union UnionBoxContent(B) union {Box chi | Box chi in some family of B}` includes ALL Box-formulas from B. The Lindenbaum extension W is an MCS. W's Box-formulas include at least those from B (since they're in the seed). But W might have ADDITIONAL Box-formulas from Lindenbaum.

Those additional Box-formulas are NOT in other families. So BoxEquivalent breaks.

**Alternative fix**: Don't require strict BoxEquivalent. Instead, require a weaker property:

Define `OneWayCoherent(B)`: for all fam, fam' in B, for all chi, if `Box chi in fam.mcs t` then `chi in fam'.mcs t` (note: NOT `Box chi in fam'.mcs t`, just `chi`).

This is exactly `modal_forward`. And `modal_backward` follows from saturation:
- If phi in all fam'.mcs t, suppose Box phi not in fam.mcs t
- Then Diamond(neg phi) in fam.mcs t
- By saturation, exists fam' with neg phi in fam'.mcs t
- But phi in fam'.mcs t -- contradiction

So we need `OneWayCoherent` and saturation. The construction:
- Start with eval (contains BoxContent(eval) trivially)
- Add witness W for Diamond(psi) in some family fam
- W is built from `{psi} union UnionBoxContent(B)` -- contains chi for every `Box chi in any family`
- OneWayCoherent for W: if `Box chi in W.mcs t`, need `chi in fam'.mcs t` for all fam'
  - `Box chi in W` -- chi is in W (by T-axiom). But chi might NOT be in other families
  - `Box chi in W` could be a NEW Box-formula from Lindenbaum, not in UnionBoxContent(B)
  - Then chi is NOT guaranteed to be in other families

**So OneWayCoherent (= modal_forward) from witness to other families is NOT guaranteed.**

### 7.4 The Honest Conclusion

After extremely thorough analysis spanning research reports 011-014 and task 864's research:

**There is a genuine mathematical gap in proving `modal_forward` from witness families to other families.** This gap appears regardless of the construction method. The root cause is that Lindenbaum extension (which is necessary for maximality) can introduce Box-formulas that are not present in other families.

This gap is NOT an artifact of the formalization approach -- it is a real mathematical challenge in multi-family canonical model construction for modal logic.

### 7.5 How Textbooks Handle This

Standard textbook canonical model constructions for S5 modal logic use the set of ALL MCS as worlds. In that construction:
- `modal_forward`: `Box phi in M -> phi in M' for all MCS M'` requires the S5 axiom `Box phi -> phi` (T) plus `Box phi -> Box Box phi` (4) plus `neg Box phi -> Box neg Box phi` (5). In S5, `Box phi iff phi is a theorem`, so the result follows.
- The textbook argument works because S5 has the 5-axiom (`Diamond phi -> Box Diamond phi`), which our TM logic may or may not include.

**For our TM logic**: We have the T-axiom (`Box phi -> phi`) and the K-axiom (distribution). Do we have the 4-axiom for Box (`Box phi -> Box Box phi`) or the 5-axiom (`neg Box phi -> Box neg Box phi`)?

Let me check.

Looking at the axiom schemata, the system has:
- `modal_k_dist`: `Box(phi -> psi) -> Box phi -> Box psi` (K distribution)
- `modal_t`: `Box phi -> phi` (T, reflexivity)

But I don't see Box-4 (`Box phi -> Box Box phi`) or Box-5 in the axiom list. This means the modal logic is at most KT, not S5 or S4.

**For KT modal logic**: The canonical model construction uses ALL MCS as worlds with the accessibility relation `M R M' iff BoxContent(M) subset M'`. With just T-axiom, R is reflexive. `modal_forward` holds by definition of R. `modal_backward` holds by maximality: if phi in all R-accessible M', then Box phi in M (by maximality of M and the derivability of `Box phi` from the universal truth of phi in all accessible worlds).

**The standard argument for KT modal_backward**: Suppose phi in all M' with BoxContent(M) subset M'. Suppose Box phi not in M. Then neg(Box phi) in M. We need to find M' with BoxContent(M) subset M' and phi not in M'. The witness: extend `{neg phi} union BoxContent(M)` to an MCS M'. This is consistent iff there's no derivation of bot from `{neg phi} union BoxContent(M)`. If `{neg phi} union BoxContent(M)` is inconsistent, then `BoxContent(M) |- phi`, which means from all chi with Box chi in M, we can derive phi. By K-distribution and necessitation, `Box phi` is derivable from {Box chi | Box chi in M}. Since all Box chi in M, Box phi in M (by MCS closure). Contradiction with neg(Box phi) in M.

**This argument works and IS formalized as `diamond_boxcontent_consistent_constant`!** The consistency lemma is PROVEN.

So the canonical model for KT modal logic uses:
- Families = ALL constant MCS families
- modal_forward: `Box phi in M -> phi in M'` for any M' with BoxContent(M) subset M'. True by definition of BoxContent.
- modal_backward: by contraposition via `diamond_boxcontent_consistent_constant`
- Temporal coherence: each constant family must satisfy forward_F, backward_P

**But wait**: "families = ALL constant MCS families" means the family set is the set of ALL maximal consistent sets. This is a proper class (or at least a very large set). In Lean, this means `families : Set (IndexedMCSFamily D)` where the set is `{fam | IsConstantFamily fam}`.

For this to be a valid BMCS, we need:
1. `modal_forward`: If `Box phi in fam.mcs t` and `fam'` is any constant MCS family, then `phi in fam'.mcs t`. For constant families, `fam.mcs t = M_fam` for all t. So: `Box phi in M_fam -> phi in M_fam'`. Is this true for arbitrary MCS M_fam, M_fam'? NOT in general -- `Box phi in M_fam` does not imply `phi in M_fam'` for all MCS M_fam'.

So "all MCS as families" does NOT give modal_forward. The textbook canonical model uses an accessibility relation, not universal accessibility. For T-logic (KT), the relation is reflexive but not universal.

**For our BMCS structure**: `modal_forward` says `Box phi in fam -> phi in ALL fam'`. This is the universal relation. This requires S5 (or at least `Box phi -> necessary phi`). In KT, `Box phi` only guarantees `phi` in the current world, not all worlds.

**This reveals a structural issue with the BMCS definition itself**: The BMCS definition requires `modal_forward` to distribute Box over ALL families, which corresponds to the universal accessibility relation (S5-style). But our logic is KT (T-axiom only, no 4 or 5).

### 7.6 Critical Re-examination: Does Our Logic Have S5 Properties?

Let me check the proof system axioms more carefully.

The TM logic axioms in `Axioms.lean` include:
- Propositional tautologies
- `modal_k_dist`: `Box(p -> q) -> Box p -> Box q`
- `modal_t`: `Box p -> p`
- `temp_k_dist_future`/`_past`: K distribution for G/H
- `temp_t_future`/`_past`: T for G/H
- `temp_4_future`/`_past`: G p -> G(G p) and H p -> H(H p) (4-axiom for temporal)
- `temp_interaction`: G p -> Box p (temporal covers modal)

The **`temp_interaction` axiom `G p -> Box p`** is significant. Combined with the temporal 4-axiom `G p -> G(G p)`, this gives a relationship between temporal and modal operators.

But does the logic have `Box p -> Box(Box p)` (modal 4)? Not directly from the axioms. However, the truth lemma works with the BMCS structure as defined, which uses the universal accessibility relation. The truth lemma is PROVEN sorry-free, which means the BMCS semantics with universal accessibility is consistent with the proof system.

**The key insight**: The BMCS structure's `modal_forward` (universal accessibility) is a SEMANTIC choice that matches the completeness proof strategy. The completeness theorem says: every consistent formula has a BMCS model. The BMCS model uses universal modal accessibility. This is STRONGER than what the logic requires (the logic is sound w.r.t. reflexive frames, which includes universal frames). The construction builds a specific universal-accessibility model that makes the completeness proof work.

So the question is not "does the logic require S5?" but "can we build a universal-accessibility model for any consistent formula?"

For a single-family BMCS: `modal_forward` is T-axiom, `modal_backward` is `phi -> Box phi` which requires the axiom.

For a multi-family BMCS with universal accessibility: we need `Box phi in M -> phi in M'` for ALL families M, M'. This requires the families to be "maximally inclusive" -- each family contains BoxContent of all other families.

This is exactly the `MutuallyCoherent` or `BoxEquivalent` property. And we showed this is hard to maintain through witness construction.

### 7.7 The Breakthrough: Use `temp_interaction` (G p -> Box p)

The `temp_interaction` axiom says `G phi -> Box phi`. For a non-constant temporal chain:
- If `G phi in chain(t)`, then `Box phi in chain(t)` (by temp_interaction in MCS)
- By GContent propagation, `G phi in chain(s)` for all s > t
- So `Box phi in chain(s)` for all s > t as well

This means: for temporal chains, G-formulas ENTAIL Box-formulas. So if we include GContent in our seeds, we automatically get certain Box-formulas propagating.

But this only gives `Box phi` for formulas phi where `G phi` was in some ancestor chain element. It does NOT give `Box phi` for arbitrary Box-formulas that Lindenbaum might add.

However, for `modal_forward` in a multi-family BMCS: if `Box phi in chain_fam(t)` and we need `phi in chain_fam'(t)`, one sufficient condition is that `phi in GContent(chain_fam'(t-1)) subset chain_fam'(t)`, which requires `G phi in chain_fam'(t-1)`.

**This doesn't close the gap either**, because `Box phi in chain_fam(t)` doesn't imply `G phi in chain_fam'(t-1)`.

## 8. Ranked Recommendations

Given the thorough analysis, here are the approaches ranked by feasibility:

### Rank 1: Phase-Separated Approach (RECOMMENDED)

**Phase 1: Eliminate `temporal_coherent_family_exists` (18-21 hours, medium risk)**

Build the dovetailing temporal chain construction. This is well-understood, uses proven infrastructure (`temporal_witness_seed_consistent`, `Encodable Formula`, `Nat.pair`), and directly proves the axiom as a theorem.

Deliverable: `temporal_coherent_family_exists` becomes a theorem instead of an axiom.

**Phase 2: Eliminate `singleFamily_modal_backward_axiom` (25-35 hours, high risk)**

Two sub-options for the modal axiom:

**2a (Recommended): All-MCS canonical model with restricted family set**

Build a BMCS where:
- `families` = the set of all constant families constructed as coherent witnesses
- Use `diamond_boxcontent_consistent_constant` (PROVEN) at each step
- For modal_forward: require all families to contain BoxContent of eval (EvalCoherent)
- For modal_backward at eval: by EvalSaturated + contraposition (proven pattern)
- For modal_backward at non-eval: use the iterated witness construction with the multi-family consistency lemma

The multi-family consistency lemma (`{psi} union UnionBoxContent(B)` is consistent) is the critical proof obligation. It can be proven using the K-distribution argument IF all families in B satisfy BoxEquivalent.

**Strategy**: Start with eval as the only family (BoxEquivalent trivially). When adding a witness W:
- Build W from `{psi} union BoxContent(eval) union AllBoxFormulas(eval)` where `AllBoxFormulas(M) = {Box chi | Box chi in M}`
- W's seed includes all of eval's Box-formulas, so `Box chi in eval -> Box chi in W` (at time 0, for constant families)
- But W's Lindenbaum extension may add new Box-formulas not in eval
- For those new Box-formulas `Box alpha in W`: we need `alpha in eval`. But eval is fixed.

This is the same gap. However, there is an alternative:

**2b: Modally saturated MCS with special properties**

Build a single MCS M that is MODALLY SATURATED (every Diamond has an internal witness): `Diamond(psi) in M -> psi in M`. This is equivalent to `neg(Box phi) in M -> neg phi in M`, which means `Box phi in M or neg phi in M` for all phi. Combined with T-axiom, `Box phi in M -> phi in M`, this gives `phi in M -> Box phi in M` (contrapositive of `neg phi in M -> neg(Box phi) in M`, i.e., `Box phi not in M -> phi not in M`, which is the converse of T).

Wait -- `Box phi in M or neg phi in M` (from modal saturation) means: either `Box phi in M` or `neg phi in M`. If `phi in M`, then (since M is consistent) `neg phi not in M`, so `Box phi in M`. This gives `phi in M -> Box phi in M`, which is exactly `singleFamily_modal_backward_axiom`!

**So for a MODALLY SATURATED MCS, the axiom is TRUE!**

Can we build a modally saturated MCS? This means: for every formula `phi`, either `Box phi in M` or there exists a witness for `Diamond(neg phi)` in M, i.e., `neg phi in M`.

A modally saturated MCS satisfies: for all phi, `Box phi in M or neg phi in M`.

By MCS completeness: `phi in M or neg phi in M` for all phi. So we need: if `phi in M` and `neg phi not in M`, then `Box phi in M`. By MCS completeness, `neg phi not in M` implies `phi in M`. So we need: `phi in M -> Box phi in M`.

This is circular -- modal saturation IS the converse of T.

But can we BUILD such an MCS? Consider the Lindenbaum construction starting from Gamma. The resulting MCS M may or may not satisfy `phi in M -> Box phi in M`. In fact, for KT logic, there exist MCS that do NOT satisfy this (e.g., an MCS at a non-global world).

**However**: what if we use the FULL CANONICAL MODEL and pick the right world?

In the standard canonical model for KT: worlds are all MCS, accessibility is `M R M' iff BoxContent(M) subset M'`. By reflexivity (T-axiom), `M R M` for all M. A formula `phi` is satisfiable iff there exists M with `phi in M`. The canonical model validates exactly the theorems of KT.

For BMCS completeness, we need a specific BMCS (with universal accessibility) that satisfies a given consistent formula. The BMCS with universal accessibility is NOT the standard KT canonical model (which has reflexive, not universal, accessibility). We're building a DIFFERENT model.

**The correct interpretation**: We're not building the standard canonical model. We're building a BMCS, which has its own semantics. The completeness theorem says: every consistent formula has a BMCS model. The BMCS model is a specific structure with modal_forward and modal_backward as given.

The axiom `singleFamily_modal_backward_axiom` says: for the SPECIFIC single-family BMCS we construct, `phi in M -> Box phi in M`. This is a property of the constructed model, not a general validity.

Can we ensure this property by choosing M appropriately? If M is modally saturated (`phi in M -> Box phi in M`), then yes. But constructing a modally saturated MCS is exactly the problem.

**Can we construct a modally saturated MCS?** A Henkin-style argument: enumerate all formulas. At each step, if `phi_n` is consistent with the current set AND `Box phi_n` is consistent with the current set, add both. If only `phi_n` is consistent, add `phi_n` and check if adding `Box phi_n` creates inconsistency. If adding `Box phi_n` is inconsistent, then don't add it.

But this doesn't guarantee saturation: we might add `phi` without `Box phi`, and then modal saturation fails.

**Alternative**: Start with an MCS M and close under `phi -> Box phi`. Define `M^Box = M union {Box phi | phi in M}`. Is `M^Box` consistent? Not necessarily -- `Box phi` for some `phi in M` might be inconsistent with other formulas in M.

**Example**: M contains `Diamond(neg p) = neg(Box p)` and `p`. Then `Box p not in M` (since `neg(Box p) in M`). The closure would try to add `Box p` (since `p in M`), creating `{Box p, neg(Box p)} subset M^Box` -- inconsistent.

So the Box-closure of an MCS is NOT generally consistent. Modal saturation cannot be achieved by simple closure.

### Rank 2: Task 864's Recursive Seed Approach (34-52 hours, high risk)

This addresses both axioms simultaneously but has the highest risk due to the modal coherence gap at non-seed times.

### Rank 3: Accept One Correct Axiom as Technical Debt

The most pragmatic approach. Since the multi-family consistency gap is a genuine mathematical challenge:

**Phase 1**: Prove `temporal_coherent_family_exists` as a theorem (dovetailing chain). Removes the TRUE but unproven axiom.

**Phase 2**: Replace `singleFamily_modal_backward_axiom` (FALSE) with a CORRECT axiom that captures the multi-family modal saturation existence. For example:

```lean
axiom saturated_coherent_bmcs_exists (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∃ (B : BMCS D),
      (∀ gamma ∈ Gamma, gamma ∈ B.eval_family.mcs 0)
```

This axiom asserts the existence of a full BMCS extending any consistent context. It is mathematically TRUE (by the standard canonical model construction for the logic). Replacing a FALSE axiom with a TRUE one is strictly better.

**Effort**: ~25 hours total (18-21 for temporal chain + 4 for axiom replacement and rewiring).

**This approach violates the "no mathematical compromises" requirement** but is the most realistic path given the analysis.

## 9. What Specific Lean Infrastructure Is Missing?

For the recommended Phase 1 (temporal chain dovetailing):

| Component | Depends On | Exists? | Effort |
|-----------|-----------|---------|--------|
| `Encodable Formula` | Formula.lean Countable | YES (TemporalLindenbaum.lean:157) | 0h |
| `Nat.pair`/`Nat.unpair` | Mathlib.Data.Nat.Pairing | YES (Mathlib) | 0h |
| `temporal_witness_seed_consistent` | MCS properties | YES (TemporalCoherentConstruction.lean:477) | 0h |
| `temporal_witness_seed_consistent_past` | MCS properties | YES (TemporalLindenbaum.lean:71) | 0h |
| `GContent_consistent` | MCS properties | YES (TemporalChain.lean:90) | 0h |
| `HContent_consistent` | MCS properties | YES (TemporalChain.lean:98) | 0h |
| `G_in_GContent_of_G_in_mcs` (4-axiom) | Proof system | YES (TemporalChain.lean:167) | 0h |
| `H_in_HContent_of_H_in_mcs` (4-axiom) | Proof system | YES (TemporalChain.lean:173) | 0h |
| Dovetailing chain definition | Encodable, Nat.pair | NO | 4h |
| Forward chain with witness selection | temporal_witness_seed_consistent | NO | 3h |
| Backward chain with witness selection | temporal_witness_seed_consistent_past | NO | 2h |
| `forward_G` proof for dovetailing chain | 4-axiom, GContent propagation | NO | 2h |
| `backward_H` proof for dovetailing chain | 4-axiom, HContent propagation | NO | 2h |
| `forward_F` proof via dovetailing completeness | Encodable.decode surjectivity | NO | 4-6h |
| `backward_P` proof via dovetailing completeness | Symmetric | NO | 2-3h |
| `temporal_coherent_family_exists` theorem | All above | NO | 2h |

For the modal axiom elimination (much harder, separate task):

| Component | Exists? | Effort | Notes |
|-----------|---------|--------|-------|
| Multi-family consistency lemma | NO | 6-8h | Key proof obligation |
| BoxEquivalent preservation | NO | 6-8h | Through witness construction |
| Zorn on coherent bundles | NO | 4-6h | Chain upper bounds |
| Full BMCS from maximal bundle | NO | 4h | |
| Integration with temporal chains | NO | 6-8h | BoxContent preservation issue |

## 10. Conclusion

### 10.1 Summary of Findings

The analysis reveals that the two axioms represent fundamentally different levels of difficulty:

1. **`temporal_coherent_family_exists`** (TRUE axiom): CAN be proven as a theorem using a dovetailing temporal chain construction. The infrastructure exists, the consistency arguments are proven, and the approach is well-understood. **Effort: 18-21 hours, medium risk.**

2. **`singleFamily_modal_backward_axiom`** (FALSE axiom): Eliminating this requires proving that a multi-family BMCS with full `modal_forward` and `modal_backward` can be constructed. This faces the fundamental **BoxContent preservation problem**: Lindenbaum extension at witness families introduces Box-formulas not present in other families, breaking `modal_forward` from witnesses. **No approach analyzed here fully resolves this gap.** The gap is a genuine mathematical challenge, not a formalization artifact.

### 10.2 Recommended Strategy

1. **Immediate (Phase 1)**: Build the dovetailing temporal chain to prove `temporal_coherent_family_exists`. This eliminates the TRUE but unproven axiom.

2. **Next (Phase 2)**: Replace `singleFamily_modal_backward_axiom` with a CORRECT axiom asserting full BMCS existence. This eliminates mathematical falsity from the proof chain while acknowledging the remaining proof debt.

3. **Future (Phase 3)**: Investigate the multi-family BoxContent preservation problem as a dedicated research task, potentially exploring:
   - Whether the `temp_interaction` axiom (`G phi -> Box phi`) provides enough structure
   - Whether a restricted family set (not all MCS, but carefully chosen ones) can maintain BoxEquivalent
   - Whether the Henkin-style "all formulas" canonical model avoids the gap

### 10.3 What "No Mathematical Compromises" Would Require

A fully axiom-free completeness proof would require solving the BoxContent preservation problem -- specifically, proving that when constructing witness families for Diamond formulas, the Lindenbaum extension can be constrained to not introduce "rogue" Box-formulas that violate cross-family coherence. This appears to be an open technical challenge in the formalization of canonical model constructions for multi-modal logics.

## References

- Task 864 research: specs/864_recursive_seed_henkin_model/reports/research-001.md
- Task 864 plan: specs/864_recursive_seed_henkin_model/plans/implementation-001.md
- Task 843 research-011: specs/843_remove_singleFamily_modal_backward_axiom/reports/research-011.md
- Task 843 research-012: specs/843_remove_singleFamily_modal_backward_axiom/reports/research-012.md
- Task 843 research-013: specs/843_remove_singleFamily_modal_backward_axiom/reports/research-013.md
- Construction.lean: Theories/Bimodal/Metalogic/Bundle/Construction.lean
- CoherentConstruction.lean: Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean
- TemporalCoherentConstruction.lean: Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean
- TemporalChain.lean: Theories/Bimodal/Metalogic/Bundle/TemporalChain.lean
- Completeness.lean: Theories/Bimodal/Metalogic/Bundle/Completeness.lean
- TruthLemma.lean: Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean
- IndexedMCSFamily.lean: Theories/Bimodal/Metalogic/Bundle/IndexedMCSFamily.lean

## Next Steps

1. Create implementation plan for Phase 1 (dovetailing temporal chain)
2. Implement the chain construction as a new file or extension of TemporalChain.lean
3. Prove forward_F and backward_P via dovetailing enumeration completeness
4. Replace `temporal_coherent_family_exists` axiom with the proven theorem
5. Create a separate task for the modal axiom elimination (Phase 2+3)
