# Research Report: Task #916 (Teammate B -- Alternative Approaches)

**Task**: Close forward_F and backward_P sorries in DovetailingChain.lean
**Date**: 2026-02-24
**Focus**: Alternative approaches NOT previously tried; restructuring strategies
**Role**: Teammate B -- fresh alternatives analysis

---

## Key Findings

### 1. The Root Cause Is Architectural, Not Technical

After analyzing 13 prior research reports, ~1800 lines of sorry-free infrastructure in DovetailingChain.lean, the ZornFamily.lean approach (moved to Boneyard), the TemporalCoherentConstruction.lean dual infrastructure, and the WitnessGraph.lean approach (Phases 1-2 complete, Phase 3 partially complete with 48 build errors in uncommitted working copy), the root cause is now well-characterized:

**The linear chain construction (one MCS per integer time point, each extending GContent of its predecessor via Lindenbaum) is structurally incompatible with existential witness guarantees for F/P formulas.** This is because:

1. **GContent propagation is for universal (G/H) formulas only.** G(phi) propagates via the 4-axiom G(phi) -> G(G(phi)), but F(phi) -> G(F(phi)) is NOT derivable. So F-formulas are invisible to the seed mechanism.

2. **Lindenbaum extensions are opaque.** The Zorn/Lindenbaum completion makes an arbitrary choice for every formula not determined by the seed. Since F(psi) is not in GContent, Lindenbaum can "kill" it (include G(neg psi) instead) at any intermediate step.

3. **The one-shot enumeration has a past-encoding gap.** Even with perfect persistence, if encodeFormula(psi) < t, the witness fires in the past relative to time t, and psi does not propagate forward to a time > t.

### 2. Assessment of the Two Active Approaches

#### 2A. WitnessGraph ("Deferred Concretization") -- Current Implementation Path

**Status**: Phases 1-2 complete (sorry-free), Phase 3 partial (5 sorries in committed version, 48 build errors in uncommitted working copy attempting to close those sorries). Phases 4-6 not started.

**Architecture**: Builds a directed graph where each F/P obligation gets its OWN Lindenbaum extension, avoiding the persistence problem. Then embeds into Int.

**Remaining work**:
- Phase 3: Close 5 sorries (build errors fixable per research-013)
- Phase 4: Embed witness graph into Int
- Phase 5: Prove global temporal coherence (forward_G, backward_H, forward_F, backward_P)
- Phase 6: Integration into DovetailingChain.lean

**Key risk**: Phase 5 requires proving that the Int embedding preserves GContent/HContent propagation for ALL pairs (t, t'), not just edges in the graph. This is the "transitivity of GContent propagation" challenge. The witness graph has edges encoding direct witnesses, but forward_G requires phi to propagate from t to t' whenever t < t', even if no direct edge connects them. This may require showing that the embedding creates a path of GContent propagation through intermediate nodes.

**Estimated remaining effort**: 30-50 hours (per research-013 estimates for Phase 3 alone: 2.5-3.5 hours for 8 errors; Phases 4-6 significantly more).

#### 2B. AliveF Seed + Fair Scheduling -- Proposed but Never Implemented

**Status**: Identified in research-009 Section 6.3 as "most promising" but never implemented. The analysis identifies it as resolving Sub-problem A (persistence at non-witness steps) and Sub-problem B (past-encoding), with a residual gap at witness steps where F-obligations can be killed due to incompatibility with the witness formula.

### 3. Three Fresh Alternative Approaches (Not Previously Explored)

#### Alternative A: The "Infinitely Many Witnesses" Argument (RECOMMENDED)

**Key insight that ALL prior research missed**: The forward_F proof does NOT need to find a witness at a SPECIFIC time. It only needs to show EXISTENCE of some s > t with psi in mcs(s). The prior approaches fixated on controlling WHERE the witness appears, but in fact:

**Claim**: In the current dovetailing chain construction, for any psi with F(psi) in chainMCS(t), EITHER:
- (a) psi is in chainMCS(s) for some s > t (we are done), OR
- (b) neg(psi) is in chainMCS(s) for ALL s > t

Case (b) is impossible BY THE EXISTING CHAIN PROPERTIES if we can show that "neg(psi) at all future times" implies G(neg psi) at time t, contradicting F(psi) = neg(G(neg psi)).

**The circularity concern (raised in research-009 Section 4.3)**: temporal_backward_G requires forward_F, creating apparent circularity. BUT this circularity can be broken. The key observation:

**The chain-specific backward_G does NOT need forward_F.** The general `temporal_backward_G` in TemporalCoherentConstruction.lean uses forward_F to create a TemporalCoherentFamily, but we can prove a WEAKER, CONSTRUCTION-SPECIFIC version that avoids this dependency:

**Theorem (chain_specific_backward_G)**: If neg(psi) is in chainMCS(s) for ALL s > t (where t >= 0), then G(neg psi) is in chainMCS(t).

**Proof sketch**:
1. For the forward chain, chainMCS(n+1) extends GContent(chainMCS(n)) or a witness seed.
2. The seed at step n+1 is a SUBSET of chainMCS(n+1) (by Lindenbaum extension).
3. If neg(psi) is in chainMCS(s) for all s > t, consider step n = t.toNat:
   - chainMCS(n+1) is an MCS extending either GContent(chainMCS(n)) or {phi} union GContent(chainMCS(n)).
   - neg(psi) is in chainMCS(n+1), so neg(psi) is consistent with the seed.
   - Continuing: neg(psi) is in chainMCS(m) for all m > n.

4. Now consider G(neg psi). By MCS completeness at time t, either G(neg psi) in chainMCS(t) or neg(G(neg psi)) = F(psi) in chainMCS(t).

5. Suppose F(psi) in chainMCS(t). We assumed neg(psi) at ALL future times. But the question is: does "neg(psi) at all future Nat-indexed chain steps" imply G(neg psi) at step t?

**THIS IS THE CRITICAL GAP.** The general backward_G theorem proves: if phi at all s >= t, then G(phi) at t. It does so via CONTRAPOSITION using forward_F. Without forward_F, we cannot use contraposition.

**However, there is a DIRECT proof that avoids forward_F**: Instead of using contraposition (if not G(phi) then F(neg phi) then exists witness), we need to prove the CONVERSE direction: "phi at all future times implies G(phi)". This is essentially an omega-rule, which is NOT derivable in finitary logic.

**CONCLUSION ON ALTERNATIVE A**: The circularity IS real and CANNOT be trivially broken for the general case. The omega-rule is not available. Research-009's concern was correct. However, see Alternative C below for a way to sidestep this issue entirely.

#### Alternative B: Restructure BFMCS to Store Witnesses Explicitly

**Idea**: Instead of proving forward_F as a derived property, make the BFMCS construction CARRY witness information explicitly.

Define a new structure:

```lean
structure WitnessBFMCS where
  mcs : Int -> Set Formula
  is_mcs : forall t, SetMaximalConsistent (mcs t)
  forward_G : ... -- as before
  backward_H : ... -- as before
  -- NEW: explicit witness function
  F_witness : Int -> Formula -> Int  -- for each (t, psi), the witness time
  F_witness_correct : forall t psi,
    Formula.some_future psi in mcs t ->
    t < F_witness t psi /\ psi in mcs (F_witness t psi)
  P_witness : Int -> Formula -> Int
  P_witness_correct : forall t psi,
    Formula.some_past psi in mcs t ->
    P_witness t psi < t /\ psi in mcs (P_witness t psi)
```

The construction would build mcs AND the witness functions simultaneously, using the WitnessGraph approach (each F/P obligation gets a dedicated witness node).

**Problem**: This just MOVES the difficulty. The witness function must be defined simultaneously with the MCS assignment, creating the same circular dependency. If the witness for F(psi) at time t is at time s, then mcs(s) must contain psi AND GContent(mcs(t)). But mcs(s) might also need witnesses for its own F-obligations, which might reference times beyond s. This is exactly the WitnessGraph approach in disguise.

**Assessment**: Not fundamentally new. Collapses back to WitnessGraph.

#### Alternative C: The "Step-by-Step Obligation Resolution" Construction (MOST PROMISING)

**Core idea**: Instead of building a chain indexed by Int where each step extends the previous one, build the family using a DIFFERENT inductive structure that resolves obligations one at a time. This is the Gabbay-Hodkinson-Reynolds "step-by-step" approach, adapted for the BFMCS setting.

**Construction** (sketch):

1. **Start**: Begin with a single MCS M_0 (Lindenbaum extension of Gamma) at time 0.

2. **Obligation queue**: Collect all F/P obligations from M_0:
   - For each F(psi) in M_0, queue obligation (0, psi, future)
   - For each P(psi) in M_0, queue obligation (0, psi, past)

3. **Process obligations**: For each obligation in the queue:
   - For (t, psi, future): Create a NEW MCS at time t+1 (if not already assigned) by Lindenbaum extension of {psi} union GContent(M_t). This is consistent by `forward_temporal_witness_seed_consistent`.
   - For (t, psi, past): Symmetrically at t-1.
   - When a new MCS is created, add its F/P obligations to the queue.

4. **Key invariant**: The domain grows monotonically. At each step, a new time gets an MCS, or an existing time's MCS already satisfies the obligation.

5. **Termination**: The queue is countable (since Formula is countable and the time domain is Int). Process obligations using a fair enumeration over Nat.

6. **After omega steps**: The domain is a subset of Int (potentially all of Int, potentially a subset). For times NOT in the domain, use Zorn's lemma (as in ZornFamily.lean) to extend the partial family to a total one.

**Why this resolves the root cause**:
- Each F/P obligation gets its own FRESH Lindenbaum extension (no persistence issue).
- The witness is placed at a SPECIFIC time relative to the source (no past-encoding gap).
- GContent propagation is guaranteed by construction (the seed includes GContent).

**Critical challenge -- GContent coherence for NON-ADJACENT times**:
If M_0 is at time 0 and M_1 is at time 1 (extending GContent(M_0)), and then M_3 is at time 3 (extending {psi} union GContent(M_1) for some F-obligation), we need:
- G(phi) in M_0 implies phi in M_3 (forward_G with gap)

This follows from: GContent(M_0) subset M_1 (by construction), GContent(M_1) subset M_3 (because GContent(M_1) includes G-formulas from M_1, and GContent(M_0) subset M_1 implies G(phi) in M_0 is in M_1, and by the 4-axiom G(G(phi)) in M_1, so G(phi) in GContent(M_1) subset M_3). Wait -- GContent(M_1) is {chi | G(chi) in M_1}, and G(G(phi)) in M_1 means G(phi) in GContent(M_1). Since GContent(M_1) subset seed for M_3, G(phi) is in the seed for M_3, so phi is in M_3 via T-axiom... No, G(phi) in the seed means G(phi) in M_3, not phi. We need phi in M_3, which requires either:
- phi in the seed for M_3 (not guaranteed unless G(phi) is in M_2 where 2 = 3-1, but M_2 might not exist)
- phi follows from the MCS properties of M_3

Actually, the issue is that GContent propagation in the chain works because there is an MCS at EVERY integer. In the step-by-step construction, there may be gaps.

**Solution to the gap problem**: After processing all obligations, extend the partial family to a total family using Zorn's lemma (the ZornFamily approach). The key insight from ZornFamily.lean: for a GH-coherent partial family, Zorn produces a maximal GH-coherent family, and if it has domain = Set.univ, forward_G holds for all pairs.

BUT the critical question is: does the MAXIMAL family satisfy forward_F? ZornFamily.lean Task 880 notes that F/P coherence was REMOVED from the GHCoherentPartialFamily structure because it was unsatisfiable for partial families. The idea was to prove F/P as a derived property for total families, but this was never completed.

**The key insight for Alternative C**: The step-by-step construction produces a partial family that ALREADY satisfies forward_F and backward_P (by construction -- each obligation has its witness). The Zorn extension only needs to preserve this property. Can it?

When extending a partial family to include a new time point t', the new MCS is a Lindenbaum extension of the extensionSeed (GContent from past times, HContent from future times). This new MCS might contain new F-obligations without witnesses. So the Zorn extension does NOT automatically preserve forward_F.

**Resolution**: Use a MODIFIED Zorn approach where the partial family structure INCLUDES forward_F and backward_P requirements. But as noted in ZornFamily.lean, this makes the structure unsatisfiable for finite domains.

**Alternative resolution**: Do NOT use Zorn at all. Instead, ensure the step-by-step process assigns MCSs to ALL integer times. This can be achieved by adding "fill-in" obligations: after processing all F/P obligations, for each integer time without an MCS, add an obligation to create one (extending GContent from the nearest lower time and HContent from the nearest upper time). Since Formula is countable and Int is countable, this is a countable process that can be enumerated.

**Estimated effort**: 40-60 hours (new construction, but reuses many proven lemmas from DovetailingChain.lean).

### 4. The WitnessGraph IS Alternative C

Upon deeper reflection, the WitnessGraph approach (already partially implemented) IS essentially Alternative C. The WitnessGraph:
- Creates a fresh MCS for each F/P obligation (step-by-step obligation resolution)
- Uses a directed graph instead of a linear chain
- Needs to embed into Int (Phase 4)
- Needs to prove global coherence after embedding (Phase 5)

The only difference is that Alternative C as described above works directly with Int times during construction (allocating specific integers), while WitnessGraph uses abstract node indices and defers the Int assignment.

**THIS IS THE SAME APPROACH**, just with different bookkeeping. WitnessGraph is more general (accommodates arbitrary graph shapes) but also more complex to formalize.

### 5. A Truly Different Alternative: Two-Level Construction

**Idea**: Separate the G/H construction from the F/P construction.

**Level 1 (G/H)**: Build the dovetailing chain exactly as currently done. This gives forward_G and backward_H. Mark this as the "base" family.

**Level 2 (F/P witnesses)**: For each obligation F(psi) at time t in the base family:
- Create a SIDE MCS M'_{t,psi} = Lindenbaum({psi} union GContent(base.mcs(t)))
- This is consistent by `forward_temporal_witness_seed_consistent`
- Assign M'_{t,psi} to time t+1... but this conflicts with base.mcs(t+1)!

**Resolution**: Do NOT assign the side MCS to an integer time. Instead, prove that base.mcs(t+1) ALREADY contains psi (or find a time that does).

**Can we prove base.mcs(t+1) contains psi?** No -- this is exactly the persistence problem. The base chain at t+1 might not contain psi because the Lindenbaum extension at t+1 was free to exclude it.

**Can we prove SOME base.mcs(s) with s > t contains psi?** This is forward_F itself -- circular.

**Can we MODIFY base.mcs(s) for some s > t to include psi?** This would require re-running Lindenbaum with a different seed, which changes ALL subsequent MCSs in the chain. This is a global modification, not a local one.

**Assessment**: The two-level approach fails because modifying any single MCS in the chain cascades to all subsequent MCSs.

### 6. The Truly Novel Insight: Use GContent(M'_{t,psi}) Instead

Here is a genuinely novel idea that I have not seen in any of the 13 prior reports:

**Observation**: The side MCS M'_{t,psi} = Lindenbaum({psi} union GContent(base.mcs(t))) satisfies:
- psi in M'_{t,psi}
- GContent(base.mcs(t)) subset M'_{t,psi}
- M'_{t,psi} is an MCS

But we do NOT need M'_{t,psi} to be equal to base.mcs(t+1). We just need psi to be in SOME MCS on the chain at a time > t.

**What if we build a NEW chain that is G/H coherent and AGREES with the base chain at most times, but DIFFERS at certain times to include witnesses?**

This is EXACTLY what the WitnessGraph approach does -- but through a graph embedding into Int.

### 7. Final Assessment: The WitnessGraph Approach Is The Right Strategy

After exhaustive analysis, the WitnessGraph ("Deferred Concretization") approach is confirmed as the correct strategy. It is the formalization of the standard step-by-step construction from the temporal logic literature. All alternative approaches either:
- Reduce to the WitnessGraph approach in disguise (Alternatives B, C, two-level)
- Fail due to the fundamental persistence/circularity issue (Alternative A, direct proof, AliveF seed)
- Require changing the logic or type structure (canonical time domain, non-linear witnesses)

**The path forward is to complete WitnessGraph.lean Phases 3-6.**

---

## Recommended Approach

### Primary Recommendation: Complete WitnessGraph.lean (Phases 3-6)

**Rationale**: This is the only approach that addresses both sub-problems (persistence and past-encoding) without changing the logic or BFMCS structure. It is the Lean formalization of the standard step-by-step construction.

**Concrete next steps**:

1. **Phase 3 completion** (2-4 hours): Fix the 8 build errors in uncommitted WitnessGraph.lean using the `congrArg` patterns identified in research-013. The 5 sorries in the committed version are addressed by the uncommitted changes; the errors are mechanical (syntax, ordering, projection).

2. **Phase 4: Int Embedding** (10-15 hours): Embed the witness graph into Int.
   - The graph is a DAG (proven: `witnessGraph_edges_acyclic`)
   - It is finite at each step but potentially infinite in total (countable)
   - Use topological sort + gap-filling to assign integer times
   - Key lemma needed: a countable DAG with a unique root can be embedded order-preservingly into Int

3. **Phase 5: Global Coherence** (15-20 hours):
   - forward_G: follows from GContent propagation along all forward paths
   - backward_H: follows from HContent propagation along all backward paths
   - forward_F: follows from the witness graph's witness edges
   - backward_P: follows from the witness graph's witness edges

   The main challenge is proving forward_G for non-adjacent times (where there is no direct edge). This requires showing that GContent propagation is transitive through the graph.

4. **Phase 6: Integration** (5-10 hours): Replace the sorry in DovetailingChain.lean with the WitnessGraph-based construction.

**Total estimated effort**: 32-49 hours.

### Secondary Recommendation: Simplify Phase 4 Using Direct Int Construction

Instead of building an abstract graph and then embedding, modify the construction to assign Int times DIRECTLY during the obligation resolution process:

1. Start with M_0 at time 0.
2. Maintain "next_positive" and "next_negative" counters (starting at 1 and -1).
3. For each F-obligation at time t: assign the witness to next_positive, increment next_positive.
4. For each P-obligation at time t: assign the witness to next_negative, decrement next_negative.
5. After processing all obligations: fill in remaining integer times using GContent/HContent seeds.

This eliminates the need for an abstract graph embedding step entirely. The trade-off is that the resulting family may not have optimal time assignments (witnesses might be far from their sources), but the Int times are immediate.

**Effort saving**: ~10-15 hours (eliminates Phase 4's embedding complexity).

**Risk**: The "fill in remaining times" step (5) still requires Zorn or similar machinery, and the filled-in times might not satisfy forward_F. However, the filled-in times only need forward_G and backward_H (which follow from GContent/HContent seeds), while forward_F/backward_P only need to hold for the original obligations (which have explicit witnesses from steps 3-4).

Wait -- forward_F must hold at ALL times, including filled-in times. A filled-in MCS might contain F-obligations without witnesses. So the direct Int construction still has the same Phase 5 challenge.

**Resolution**: Do not fill in times. Instead, prove that the step-by-step process eventually assigns MCSs to ALL integers. This requires:
- For each integer n not yet assigned: check if it is between two assigned times (say a < n < b). If so, create an MCS extending GContent(mcs(a)) intersect HContent(mcs(b)). This is consistent because both are subsets of any MCS between a and b in the G/H-coherent chain.

**Assessment of simplification**: Promising but requires careful formalization. The WitnessGraph approach is more general and better tested.

---

## Evidence

### Literature Support

The step-by-step construction is well-established:
- **Burgess (1982)**: Completeness for Kt (tense logic of linear time) via canonical model with explicit witness insertion
- **Reynolds (2003)**: "Completeness by construction" for tense logics -- builds frame incrementally, resolving obligations one at a time
- **Gabbay, Hodkinson, Reynolds (2000)**: "Temporal Logic: Mathematical Foundations and Computational Aspects" -- chapter on canonical model constructions for temporal logics
- **Marx, Mikulas, Reynolds (2000)**: Mosaic method for temporal logics -- decomposes models into locally consistent fragments

All of these use the same fundamental technique: create a separate MCS for each obligation, then assemble them into a globally coherent structure.

### Codebase Evidence

- `forward_temporal_witness_seed_consistent` (DovetailingChain.lean, proven): {psi} union GContent(M) is consistent when F(psi) in M
- `past_temporal_witness_seed_consistent` (DovetailingChain.lean, proven): {psi} union HContent(M) is consistent when P(psi) in M
- `GContent_subset_implies_HContent_reverse` (DovetailingChain.lean, proven): GContent/HContent duality enables cross-direction propagation
- `witnessGraph_edges_acyclic` (WitnessGraph.lean, proven): witness graph is a DAG
- `coverage_step_exists` (WitnessGraph.lean, proven): every obligation is eventually processed
- All Phase 1-2 infrastructure in WitnessGraph.lean is sorry-free

### What Has NOT Worked (From Prior Reports)

| Approach | Reports | Failure Reason |
|----------|---------|----------------|
| Omega^2 directed limit | v004 | Generalized seed consistency is FALSE |
| FPreservingSeed | v005 | Combined seed is inconsistent (counterexample) |
| Derivation surgery | v005, v007 | Counterexample refutes the conjecture |
| Semantic model | v007 | Circular (needs completeness to prove completeness) |
| G-lifting for F-formulas | v007 | F -> GF not derivable |
| Direct proof via axioms | v008, v009 | Circular dependency with temporal_backward_G |
| Canonical time domain | v009 | Type mismatch (AddCommGroup, IsOrderedAddMonoid) |
| Ordinal-indexed iteration | v009 | Infeasible (MCS intersection not MCS) |
| Fair + AliveF seed | v009 | Resolves persistence but witness steps kill F-obligations |
| Normal form reduction | v010 | Does not address fundamental problem |

---

## Confidence Level

**High confidence (85%)** that the WitnessGraph approach will work if Phases 3-6 are completed. The mathematical correctness is supported by extensive literature precedent, and Phases 1-2 are already sorry-free.

**Medium confidence (60%)** that the remaining work can be completed in the estimated 32-49 hours. The main uncertainty is in Phase 5 (global coherence), particularly the transitivity of GContent propagation.

**Low confidence (20%)** that any approach NOT based on the step-by-step/WitnessGraph pattern will succeed. All pure-chain-based approaches have been thoroughly explored and blocked by the persistence/past-encoding issues.

---

## References

- DovetailingChain.lean: Lines 1749-1761 (the 2 sorries)
- WitnessGraph.lean: Phase 3 partial (committed: 5 sorries, uncommitted: 48 build errors)
- ZornFamily.lean: In Boneyard (partial order + Zorn approach, F/P removed per Task 880)
- TemporalCoherentConstruction.lean: Contains temporal_backward_G/H (requires forward_F/backward_P)
- research-008.md: Root cause analysis (persistence + past-encoding)
- research-009.md: Canonical model feasibility, AliveF seed analysis
- research-010.md: Constraint-based and normal form approaches
- research-011.md: WitnessGraph implementation progress
- research-012.md: Progress review (48 build errors analysis)
- research-013.md: Fix patterns for 8 remaining build errors
