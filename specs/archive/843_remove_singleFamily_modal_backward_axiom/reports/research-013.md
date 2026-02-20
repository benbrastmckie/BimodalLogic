# Research Report: Task #843

**Task**: Remove singleFamily_modal_backward_axiom
**Date**: 2026-02-05
**Focus**: Post-implementation review -- learnings from v005 implementation attempt, reusable components, and guidance for next approach

## Summary

This report consolidates learnings from the most recent implementation attempt (plan v005), inventories the current axiom and sorry landscape, identifies reusable components from TemporalChain.lean, analyzes the mathematical obstacles that blocked progress, and synthesizes recommendations for the next implementation approach. The core finding is that the two-chain Lindenbaum architecture has a fundamental limitation (no backward propagation through chains), but significant infrastructure was built that remains reusable. The most viable path forward is the EvalBMCS approach from CoherentConstruction.lean, which has already PROVEN `eval_saturated_bundle_exists` (eliminating `singleFamily_modal_backward_axiom` for modal concerns) and only needs temporal coherence to complete the picture.

## 1. Current Axiom and Sorry Landscape

### 1.1 Axioms on the Critical Path

| Axiom | File:Line | Mathematically Sound | Used By |
|-------|-----------|---------------------|---------|
| `singleFamily_modal_backward_axiom` | Construction.lean:210 | **FALSE** (phi in M does NOT imply Box phi in M) | `singleFamilyBMCS` -> `construct_temporal_bmcs` -> Completeness.lean |
| `temporal_coherent_family_exists` | TemporalCoherentConstruction.lean:578 | **TRUE** (correct replacement for old false axiom) | `construct_temporal_bmcs` -> Completeness.lean |

### 1.2 Axioms NOT on the Critical Path

| Axiom | File:Line | Status | Notes |
|-------|-----------|--------|-------|
| `saturated_extension_exists` | CoherentConstruction.lean:871 | Not used in completeness chain | Would be needed for full CoherentBundle saturation |
| `weak_saturated_extension_exists` | WeakCoherentBundle.lean:826 | Not used in completeness chain | Alternative to above |

### 1.3 Sorries in TemporalChain.lean (4 total)

| Sorry | Location | Root Cause |
|-------|----------|------------|
| `forward_G` when t < 0 | Line 492 | Cross-sign: G in backward chain, phi needed at future time |
| `backward_H` when t >= 0 | Line 507 | Cross-sign: H in forward chain, phi needed at past time |
| `forward_F` | Line 523 | F-witness placement requires dovetailing |
| `backward_P` | Line 530 | P-witness placement requires dovetailing |

### 1.4 Sorries in TemporalLindenbaum.lean (4 total)

| Sorry | Location | Root Cause |
|-------|----------|------------|
| Henkin base forward saturation | Line 444 | F(psi) in base set may not have witness in base |
| Henkin base backward saturation | Line 485 | P(psi) in base set may not have witness in base |
| Maximal TCS forward temporal formula | Line 655 | Inserting phi = F(psi) requires psi in extended set |
| Maximal TCS backward temporal formula | Line 662 | Symmetric to forward case |

### 1.5 Total Sorry Count in Bundle/ Directory

69 sorry occurrences across 11 files (many are in comments or documentation strings).

## 2. What v005 Accomplished

### 2.1 Phase 0: IndexedMCSFamily Simplification [COMPLETED]

Removed `forward_H` and `backward_G` fields from `IndexedMCSFamily`. These were never used by the TruthLemma and existed only because constant-family constructions provided them trivially. This simplification is permanent and beneficial regardless of which construction approach is taken.

### 2.2 Phase 3: Axiom Replacement [COMPLETED]

Replaced the mathematically FALSE axiom `temporally_saturated_mcs_exists` (which claimed a constant family could be temporally saturated -- counterexample: {F(psi), neg psi}) with the mathematically TRUE axiom `temporal_coherent_family_exists` (which asserts the existence of a non-constant family). This is strictly better: the axiom is now correct and will be easier to prove as a theorem.

### 2.3 Phase 1: Temporal Chain Construction [PARTIAL]

Built `TemporalChain.lean` with substantial infrastructure:
- Defined `TemporalContent = GContent union HContent` as chain seeds
- Built `forwardChainMCS` and `backwardChainMCS` (both Nat-indexed)
- Proved 14+ propagation lemmas for G/H formulas in both chains
- Proved same-sign G/H coherence (both positive or both negative indices)
- Proved `temporalChainSet_forward_G_nonneg` and `temporalChainSet_backward_H_nonpos`

## 3. Analysis of Mathematical Obstacles

### 3.1 The Cross-Sign Problem (forward_G when t < 0, backward_H when t >= 0)

**Root cause**: Lindenbaum extension is a one-directional operation. When we build `chain(n+1)` from `TemporalContent(chain(n))`, formulas flow FROM the seed TO the extension (increasing Nat index). There is no mechanism for backward propagation.

**Concrete scenario**: G phi is in backward_chain(3) (time -4). We need phi in forward_chain(2) (time 2). The path is: backward_chain(3) -> backward_chain(2) -> backward_chain(1) -> backward_chain(0) -> forward_chain(0) -> forward_chain(1) -> forward_chain(2). Each step from chain(n) to chain(n-1) requires backward propagation through Lindenbaum, which is impossible.

**Why TemporalContent seeds do not help**: Using `TemporalContent = GContent union HContent` ensures G and H formulas propagate forward through BOTH chains, but backward propagation (from chain(n) to chain(n-1)) is still impossible because Lindenbaum only guarantees seed formulas appear in the extension, not the reverse.

**Key insight**: The two-chain architecture (forward Nat chain + backward Nat chain meeting at a base MCS) is fundamentally incapable of cross-sign propagation. Any resolution requires either:
1. A single-chain architecture (all integers mapped to a single Nat-indexed chain via a bijection)
2. A dovetailing construction that interleaves forward and backward steps
3. A global selection argument (Zorn's lemma) avoiding chain construction entirely

### 3.2 The F/P Witness Problem (forward_F, backward_P)

**Root cause**: When F(phi) is in chain(n), we need to ensure there exists some s > t with phi in chain(s). This requires choosing a future time where phi will appear, and then building the chain so that phi is in the seed at that step.

**Why this is hard**: The dovetailing approach (enumerating all (time, formula) pairs and processing them sequentially) is conceptually sound but requires careful control over the chain construction. At step k corresponding to the pair (t, F(phi)), we need to:
1. Check that F(phi) is in chain(t)
2. Prove that {phi} union GContent(chain(next_time)) is consistent
3. Include phi in the seed for chain(next_time+1)

The consistency argument (step 2) is exactly `temporal_witness_seed_consistent`, which IS proven. The difficulty is the engineering of the dovetailing enumeration in Lean.

### 3.3 The TemporalLindenbaum.lean Approach

TemporalLindenbaum.lean attempts a different approach: build a temporally saturated consistent set via Henkin enumeration, then maximize via Zorn. This produces a CONSTANT family (same MCS at all times). However, it has 4 sorries:

- The Henkin base case: F(psi) may be in the base set before being processed, so the base is not necessarily temporally saturated
- The maximality argument: inserting phi = F(psi) into a maximal set requires showing the extended set is still temporally saturated

These sorries exist because the constant-family approach to temporal saturation is inherently problematic (as the {F(psi), neg psi} counterexample shows for the old axiom). A temporally saturated MCS CAN exist, but the Henkin construction needs more care.

### 3.4 The Temporal-Modal Interaction Problem

This is the deepest obstacle. The BMCS needs:
- **Modal coherence**: Box phi in fam.mcs t implies phi in fam'.mcs t for ALL families fam'
- **Temporal coherence**: G phi in fam.mcs t implies phi in fam.mcs t' for t' > t (SAME family)

These interact when Box(G phi) appears: it requires G phi in all families at the current time, which in turn requires phi at all future times in all families. Building families independently (modal first, then temporal) breaks because temporal chain construction can introduce new Box formulas that violate modal coherence.

## 4. Reusable Components from TemporalChain.lean

### 4.1 Unconditionally Reusable (no dependency on two-chain architecture)

| Component | Lines | Description |
|-----------|-------|-------------|
| `GContent_subset_of_mcs` | 74-79 | G phi in M implies phi in M via T-axiom |
| `HContent_subset_of_mcs` | 82-87 | H phi in M implies phi in M via T-axiom |
| `GContent_consistent` | 90-95 | GContent of MCS is consistent |
| `HContent_consistent` | 98-103 | HContent of MCS is consistent |
| `TemporalContent` definition | 118-119 | GContent union HContent |
| `TemporalContent_subset_of_mcs` | 122-127 | TemporalContent subset of MCS |
| `TemporalContent_consistent` | 130-135 | TemporalContent of MCS is consistent |
| `GContent_subset_TemporalContent` | 138-140 | GContent is subset of TemporalContent |
| `HContent_subset_TemporalContent` | 143-145 | HContent is subset of TemporalContent |
| `G_implies_GG_in_mcs` | 152-157 | G phi in MCS implies GG phi via 4-axiom |
| `H_implies_HH_in_mcs` | 160-164 | H phi in MCS implies HH phi via 4-axiom |
| `G_in_GContent_of_G_in_mcs` | 167-170 | G phi in MCS implies G phi in GContent |
| `H_in_HContent_of_H_in_mcs` | 173-176 | H phi in MCS implies H phi in HContent |
| `G_in_TemporalContent_of_G_in_mcs` | 179-182 | G propagation into TemporalContent |
| `H_in_TemporalContent_of_H_in_mcs` | 185-188 | H propagation into TemporalContent |

### 4.2 Reusable with Any Chain Architecture

| Component | Lines | Description |
|-----------|-------|-------------|
| `forwardChainMCS` | 198-207 | Forward chain building (applicable for any Nat-indexed chain) |
| `forwardChainMCS_is_mcs` | 233-235 | Forward chain elements are MCS |
| `forwardChainMCS_zero_extends` | 248-251 | Base is included in chain(0) |
| `forwardChainMCS_TemporalContent_extends` | 258-264 | TemporalContent propagation along chain |
| `forwardChain_G_propagates` | 306-312 | G formulas propagate forward in chain |
| `forwardChain_G_propagates_le` | 314-320 | G formulas propagate transitively |
| `forwardChain_forward_G` | 322-329 | G phi at m, m < n implies phi at n |
| `forwardChain_H_propagates` | 337-343 | H formulas also propagate forward (via TemporalContent) |
| `forwardChain_backward_H` | 353-360 | H phi at m, m < n implies phi at n (forward chain) |

### 4.3 Two-Chain Specific (may need rework)

| Component | Lines | Description |
|-----------|-------|-------------|
| `backwardChainMCS` | 210-219 | Backward chain (mirrors forward, reusable if two-chain kept) |
| `temporalChainSet` | 222-227 | Int-to-Nat mapping via sign (two-chain specific) |
| `buildTemporalChainFamily` | 470-507 | The actual family construction with 4 sorries |

### 4.4 From TemporalCoherentConstruction.lean

| Component | Status | Description |
|-----------|--------|-------------|
| `TemporalCoherentFamily` structure | Reusable | Family with forward_F and backward_P |
| `temporal_backward_G` | Reusable | G backward from forward_F via contraposition |
| `temporal_backward_H` | Reusable | H backward from backward_P via contraposition |
| `temporal_witness_seed_consistent` | Reusable | {psi} union GContent(M) is consistent when F(psi) in M |
| `neg_all_future_to_some_future_neg` | Reusable | Temporal duality for MCS |
| `neg_all_past_to_some_past_neg` | Reusable | Temporal duality for MCS (past) |
| `G_dne_theorem` / `H_dne_theorem` | Reusable | G/H distribute over double negation elimination |
| `BMCS.temporally_coherent` | Reusable | Temporal coherence predicate for BMCS |

### 4.5 From CoherentConstruction.lean

| Component | Status | Description |
|-----------|--------|-------------|
| `EvalCoherentBundle` | Proven, reusable | Bundle with EvalCoherent property |
| `eval_saturated_bundle_exists` | **PROVEN (no sorry)** | Eval-saturated bundle construction |
| `EvalBMCS` structure | Proven, reusable | Weakened BMCS sufficient for completeness |
| `EvalCoherentBundle.toEvalBMCS` | Proven, reusable | Convert eval-coherent + eval-saturated to EvalBMCS |
| `constructCoherentWitness` | Proven, reusable | Build modal witness with BoxContent inclusion |
| `diamond_boxcontent_consistent_constant` | Proven, reusable | {psi} union BoxContent(fam) is consistent |

## 5. The EvalBMCS Path: Most Viable Strategy

### 5.1 Current Status of EvalBMCS

The `eval_saturated_bundle_exists` theorem in CoherentConstruction.lean is **fully proven** (no sorry, no axiom). It constructs:
- A set of constant IndexedMCSFamilies
- An eval_family among them
- EvalCoherent: all families contain BoxContent(eval_family) at all times
- EvalSaturated: every neg(Box phi) in eval_family has a witness family with neg(phi)

This **already eliminates** `singleFamily_modal_backward_axiom` for the modal layer. The remaining gap is temporal coherence.

### 5.2 What EvalBMCS Needs for Completeness

The completeness theorems in Completeness.lean currently use `construct_temporal_bmcs` which builds a full BMCS. To use EvalBMCS instead, the completeness proof needs:

1. An `EvalBMCS` with temporal coherence (forward_G, backward_H, forward_F, backward_P on eval_family)
2. A truth lemma for `EvalBMCS` (partially exists as `eval_bmcs_truth_lemma` with sorries)

The `eval_bmcs_truth_lemma` has 4 sorries in the box and temporal backward cases. These arise because:
- Box case: needs phi in ALL families (but EvalBMCS only has modal_forward_eval from eval_family)
- Temporal backward: needs TemporalCoherentFamily on eval_family

### 5.3 Strategy: Combine EvalBMCS (Modal) + TemporalCoherentFamily (Temporal)

The key insight is that the two concerns can be separated:

**Modal**: EvalBMCS provides modal_forward_eval and modal_backward_eval. These are sufficient if we can restrict the truth lemma to evaluate only at eval_family. Since completeness only needs the starting formula to be true at eval_family at time 0, this is sufficient.

**Temporal**: We need eval_family to be a TemporalCoherentFamily (with forward_F and backward_P). Currently, eval_family in the EvalBMCS construction is a constant family (same MCS at all times), which trivially satisfies forward_G and backward_H but does NOT satisfy forward_F and backward_P in general.

**Resolution**: Replace the constant eval_family with a non-constant temporally coherent family. This is exactly what `temporal_coherent_family_exists` provides (it is a TRUE axiom). The chain construction in TemporalChain.lean is the intended implementation of this axiom.

### 5.4 Concrete Plan Outline

1. **Prove `temporal_coherent_family_exists` as a theorem** (eliminate the axiom):
   - Option A: Fix the remaining 4 sorries in TemporalChain.lean
   - Option B: Use a different chain architecture (single chain with bijection Int <-> Nat)
   - Option C: Use the TemporalLindenbaum + Zorn approach (fix its 4 sorries)

2. **Build an EvalBMCS with temporal coherence**:
   - Use `temporal_coherent_family_exists` to get a non-constant eval_family
   - Build modal witnesses around it using `constructCoherentWitness`
   - The witnesses are constant families (BoxContent inclusion proven)
   - EvalCoherent holds because witnesses contain BoxContent(eval_family)

3. **Prove completeness using combined structure**:
   - Truth lemma evaluates at eval_family
   - Modal cases: use EvalBMCS properties
   - Temporal cases: use TemporalCoherentFamily properties on eval_family

## 6. Analysis of Alternative Approaches to temporal_coherent_family_exists

### 6.1 Option A: Fix TemporalChain.lean Sorries

**Cross-sign sorries (forward_G when t < 0, backward_H when t >= 0):**

The fundamental problem is that the two-chain architecture cannot propagate formulas backward through Lindenbaum extensions. One potential resolution is to abandon the two-chain approach and use a single chain:

- Define a bijection `f : Int -> Nat` (e.g., zigzag: 0,1,-1,2,-2,3,-3,...)
- Build a single Nat-indexed chain where chain(f(t+1)) extends `TemporalContent(chain(f(t)))` for the forward direction
- The backward direction uses `HContent` seeds similarly

This avoids the cross-sign problem because the chain is a single sequence. However, the ordering of integers in the Nat chain is non-standard (zigzag), so the propagation lemmas need to handle this mapping carefully.

**F/P witness sorries:**

These require a dovetailing construction. The key challenge is engineering the interleaved processing of (time, formula) pairs. The consistency argument (`temporal_witness_seed_consistent`) is already proven. What remains is:
- Defining the dovetailing enumeration (e.g., using `Nat.pair`/`Nat.unpair` from Mathlib)
- Proving that the chain at each step includes the required witnesses
- Proving that the resulting family satisfies forward_F and backward_P

Estimated effort: 10-15 hours, medium-high risk.

### 6.2 Option B: Single-Chain With Dovetailing

Instead of two separate chains, build a single chain indexed by integers using a more sophisticated construction:

1. Start with MCS M_0 extending the base context
2. At each step n of a Nat-indexed construction:
   - Unpack n into (time t, formula phi) via Nat.unpair
   - If F(phi) is in chain(t), extend the seed at time t+1 to include phi
   - If P(phi) is in chain(t), extend the seed at time t-1 to include phi
   - Always include GContent and HContent from the previous step

This is essentially the dovetailing construction described in task 864's research. The advantage is that it naturally handles all 4 sorries simultaneously.

Estimated effort: 15-20 hours, high risk (new construction from scratch).

### 6.3 Option C: TemporalLindenbaum + Zorn (Constant Family)

The TemporalLindenbaum.lean approach builds a temporally saturated MCS via Henkin enumeration + Zorn. This produces a CONSTANT family. The 4 remaining sorries are in the Henkin base case and the maximality argument.

The Henkin base case sorry (F(psi) in base) can potentially be resolved by:
- Starting the Henkin enumeration from the base set PLUS all temporal witnesses of formulas already in the base
- Or by requiring the base to already be temporally saturated for formulas in it

The maximality argument sorry (inserting F(psi) preserves temporal saturation) is a genuine mathematical difficulty: showing that the "right" psi can be found when F(psi) is newly inserted. This may require a more careful analysis of what formulas can be added to a maximal temporally saturated consistent set.

Estimated effort: 8-12 hours, medium risk.

**Important note**: Even if the constant-family TemporalLindenbaum approach succeeds, it only proves `temporally_saturated_mcs_exists` (the OLD false axiom name). For task 843, we need the non-constant `temporal_coherent_family_exists`. A constant family trivially satisfies forward_G, backward_H, forward_F, and backward_P (all by T-axiom + temporal saturation), so `temporal_coherent_family_exists` follows from `temporally_saturated_mcs_exists`. The TemporalLindenbaum approach could work, but it would prove a stronger result than needed.

### 6.4 Option D: Accept temporal_coherent_family_exists as Correct Technical Debt

Since `temporal_coherent_family_exists` is mathematically TRUE, it could remain as an axiom while we focus on eliminating `singleFamily_modal_backward_axiom` (which is FALSE). This is the minimum viable approach:

1. Integrate EvalBMCS with the completeness proof (eliminating the false modal axiom)
2. Keep the correct temporal axiom as acknowledged technical debt
3. Pursue the temporal chain construction as a separate task

This approach has the advantage of immediately removing the FALSE axiom from the critical path, which is the primary goal of task 843.

## 7. Recommendations

### 7.1 Recommended Strategy: Prioritize Eliminating the FALSE Axiom

The primary goal of task 843 is to remove `singleFamily_modal_backward_axiom`, which is **mathematically false**. The `temporal_coherent_family_exists` axiom is **mathematically true** and is therefore less urgent.

**Step 1**: Integrate EvalBMCS into the completeness proof. This requires:
- Adapting `bmcs_truth_lemma` to work with EvalBMCS (or proving a separate truth lemma)
- Updating `bmcs_representation` and `bmcs_context_representation` to use EvalBMCS
- Updating `bmcs_weak_completeness` and `bmcs_strong_completeness`

**Step 2**: Verify that `temporal_coherent_family_exists` works with the EvalBMCS construction. Currently, the EvalBMCS uses constant families. We need to show that replacing the eval_family with a non-constant temporally coherent family preserves EvalCoherent and EvalSaturated properties.

**Step 3**: (Separate task) Prove `temporal_coherent_family_exists` as a theorem using the chain construction.

### 7.2 Key Technical Insight: eval_bmcs_truth_lemma Completion

The `eval_bmcs_truth_lemma` in TruthLemma.lean has 9 sorry instances. However, the main `bmcs_truth_lemma` is fully proven. The gap is that `bmcs_truth_lemma` requires a full BMCS (modal_forward and modal_backward for ALL families), while the EvalBMCS only has these properties for the eval_family.

The resolution may be:
- **Option A**: Prove that EvalBMCS IS a full BMCS when all families have the same BoxContent (which they do, by EvalCoherent). This would make `bmcs_truth_lemma` directly applicable.
- **Option B**: Prove a separate truth lemma for EvalBMCS that only evaluates at eval_family. This is simpler because the modal_forward_eval and modal_backward_eval properties are exactly what the box case needs when evaluating at eval_family.

Option B is more direct. The truth lemma's box case at eval_family needs:
- Forward: Box phi in eval_family.mcs t implies phi in fam'.mcs t for all fam' (this is modal_forward_eval)
- Backward: phi in fam'.mcs t for all fam' implies Box phi in eval_family.mcs t (this is modal_backward_eval)

Both are provided by EvalBMCS. The temporal cases work because they only recurse within the same family.

### 7.3 Reuse Inventory for Next Implementation

| From | Component | Reuse Status |
|------|-----------|-------------|
| TemporalChain.lean | GContent/HContent/TemporalContent + all content lemmas | Direct reuse |
| TemporalChain.lean | 4-axiom propagation lemmas | Direct reuse |
| TemporalChain.lean | forwardChainMCS + propagation lemmas | Direct reuse (for any forward chain) |
| TemporalCoherentConstruction.lean | TemporalCoherentFamily structure | Direct reuse |
| TemporalCoherentConstruction.lean | temporal_backward_G/H | Direct reuse |
| TemporalCoherentConstruction.lean | temporal_witness_seed_consistent | Direct reuse |
| TemporalCoherentConstruction.lean | Temporal duality lemmas | Direct reuse |
| CoherentConstruction.lean | EvalBMCS + toEvalBMCS | Direct reuse |
| CoherentConstruction.lean | eval_saturated_bundle_exists | Direct reuse (PROVEN) |
| CoherentConstruction.lean | constructCoherentWitness | Direct reuse |
| CoherentConstruction.lean | diamond_boxcontent_consistent_constant | Direct reuse |
| Construction.lean | constantIndexedMCSFamily | Direct reuse |
| Construction.lean | singleFamilyBMCS | May be deprecated if EvalBMCS adopted |

### 7.4 What Should NOT Be Reused

| Component | Reason |
|-----------|--------|
| `temporalChainSet` (Int -> Set) | Two-chain architecture is fundamentally flawed for cross-sign |
| `buildTemporalChainFamily` | Has 4 sorries due to two-chain limitations |
| `backwardChainMCS` | Part of two-chain architecture; forward-only chain is sufficient |

## 8. Summary of Key Learnings

1. **The two-chain Lindenbaum architecture is fundamentally limited**: Lindenbaum extension is one-directional. No choice of seed (GContent, HContent, TemporalContent, or any combination) can enable backward propagation through a chain. The cross-sign sorries in TemporalChain.lean are not fixable within this architecture.

2. **TemporalContent seeds were a good idea**: Using GContent union HContent ensures both G and H formulas propagate forward in both chains. This eliminates half the propagation lemmas (same-sign cases are fully proven). The concept is reusable even if the two-chain architecture is replaced.

3. **The modal layer is effectively solved**: `eval_saturated_bundle_exists` is fully proven and eliminates `singleFamily_modal_backward_axiom` for practical purposes. The remaining work is integration with the completeness proof.

4. **The temporal layer remains the main challenge**: `temporal_coherent_family_exists` needs either a correct chain construction (dovetailing or single-chain) or the TemporalLindenbaum approach. This is mathematically achievable but technically demanding.

5. **Separating modal and temporal concerns is correct**: The EvalBMCS approach shows that modal coherence can be handled independently of temporal coherence. The eval_family can be replaced with a non-constant temporally coherent family without affecting the modal properties of the bundle.

6. **The truth lemma architecture is sound**: `bmcs_truth_lemma` is fully proven with no sorries. It requires a temporally coherent BMCS as input but makes no assumptions about how it was constructed. Any construction that produces a valid BMCS + temporal coherence proof will work.

7. **Phase 0 and Phase 3 of v005 are permanent improvements**: Removing forward_H/backward_G from IndexedMCSFamily and replacing the false axiom with a correct one are improvements that benefit any future approach.

## References

- Task 843 implementation plan v005: specs/843_remove_singleFamily_modal_backward_axiom/plans/implementation-005.md
- Task 864 research: specs/864_recursive_seed_henkin_model/reports/research-001.md
- TemporalChain.lean: Theories/Bimodal/Metalogic/Bundle/TemporalChain.lean
- CoherentConstruction.lean: Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean
- TemporalCoherentConstruction.lean: Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean
- Completeness.lean: Theories/Bimodal/Metalogic/Bundle/Completeness.lean

## Next Steps

1. **Immediate**: Integrate EvalBMCS with completeness proof to eliminate `singleFamily_modal_backward_axiom`
2. **Near-term**: Prove `temporal_coherent_family_exists` via dovetailing chain construction (new task or continuation of 843)
3. **Long-term**: Eliminate all axioms from the critical completeness path
