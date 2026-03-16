# Research Report: Task #922

**Task**: Strategy study: Phase B blocker analysis (NoMaxOrder/NoMinOrder for canonical quotient)
**Date**: 2026-02-24
**Focus**: Investigate NoMaxOrder/NoMinOrder feasibility and alternative approaches
**Session**: sess_1771974465_d29254

## Summary

This research investigates the Phase B blocker where `orderIsoIntOfLinearSuccPredArch` requires `NoMaxOrder` and `NoMinOrder` instances for the canonical quotient, which are mathematically challenging. The analysis reveals four key findings:

1. **BREAKTHROUGH: forward_F/backward_P only need REFLEXIVE witnesses (s >= t, not s > t)** for the TruthLemma to work. This completely eliminates the strict-future-witness problem.
2. **NoMaxOrder is likely unprovable** for the canonical quotient in general (medium-high confidence)
3. **The representative-based quotient approach has a deeper structural flaw**: forward_F for non-G/non-F formulas (e.g., atoms) cannot be guaranteed via the representative function
4. **The AddCommGroup constraint on BFMCS is entirely vestigial**: no proof in the completeness chain uses additive operations, opening a clean "generalize D" refactoring path

**Critical finding #1 changes the entire calculus.** The TruthLemma's `temporal_backward_G` and `temporal_backward_H` proofs use forward_F/backward_P only in a contrapositive argument where the contradiction arises from having both phi and neg(phi) in the same MCS. This contradiction holds whether the witness is at the same time (s = t) or a strictly later time (s > t). Weakening to reflexive witnesses (s >= t) makes forward_F/backward_P trivially provable from the canonical frame.

## Findings

### 0. BREAKTHROUGH: TruthLemma Only Needs Reflexive Forward_F (s >= t)

**Result**: Confirmed by code audit (confidence: 98%)

The TruthLemma's backward direction for the G (all_future) case uses `temporal_backward_G`, which works by contraposition:

```
temporal_backward_G proof structure:
1. Assume G(phi) NOT in mcs(t)
2. Then neg(G(phi)) in mcs(t) [MCS negation completeness]
3. Then F(neg(phi)) in mcs(t) [temporal duality: neg(G(phi)) = F(neg(phi))]
4. By forward_F: exists s with t < s and neg(phi) in mcs(s)    <-- CURRENT
5. By hypothesis: phi in mcs(s) [since s >= t, from le_of_lt]
6. Contradiction: phi and neg(phi) in mcs(s)
```

**The key observation**: Step 5 uses `le_of_lt` to convert `t < s` to `t <= s`, then applies the hypothesis `h_all : forall s, t <= s -> phi in mcs(s)`. But if step 4 directly gave `t <= s` (instead of `t < s`), step 5 would still work -- we would have `phi in mcs(s)` from `h_all s (h_le)` directly.

The contradiction at step 6 holds regardless of whether s = t or s > t:
- If s > t: standard argument
- If s = t: neg(phi) in mcs(t) [from step 4] and phi in mcs(t) [from h_all t (le_refl t)] -- still a contradiction

**Identical analysis for temporal_backward_H**: The backward_P only needs `s <= t` instead of `s < t`, by the symmetric argument.

**Implication**: If we define `TemporalCoherentFamily` with REFLEXIVE forward_F/backward_P:
```lean
forward_F : forall t phi, F(phi) in mcs(t) -> exists s, t <= s and phi in mcs(s)
backward_P : forall t phi, P(phi) in mcs(t) -> exists s, s <= t and phi in mcs(s)
```

Then the entire TruthLemma and completeness chain works unchanged. And the canonical frame trivially satisfies these reflexive versions:
- canonical_forward_F gives W with phi in W and CanonicalR(M, W), which means [M] <= [W]
- canonical_backward_P gives W with phi in W and CanonicalR_past(M, W), which means [M] >= [W]

**This eliminates the strict-future-witness problem entirely.**

### 1. NoMaxOrder Feasibility Analysis

**Result**: Likely unprovable (confidence: 70%)

NoMaxOrder for the canonical quotient requires: for every equivalence class [M], there exists a strictly greater class [W] with GContent(M) != GContent(W).

**Why it is hard**: Given an arbitrary MCS M in the reachable fragment, we need to construct W such that:
- GContent(M) subset W (so [M] <= [W])
- GContent(W) NOT subset M (so [W] != [M], giving strict inequality)

The natural approach is to find phi with G(phi) not in M, then seed Lindenbaum with {G(phi)} union GContent(M). For this to work:
- {G(phi)} union GContent(M) must be consistent
- The resulting W must have G(phi) in W (giving phi in GContent(W) but not in GContent(M))

The consistency requirement reduces to: G(phi) is not provably contradictory from GContent(M). This holds iff there is no derivation of neg(G(phi)) from GContent(M). Since GContent(M) = {psi : G(psi) in M}, this means neg(G(phi)) is not derivable from the G-formulas of M.

However, this consistency is NOT guaranteed for all M. Specifically, if M is a "maximally G-saturated" MCS where GContent(M) is logically maximal (every formula derivable from G-formulas of M is in M), then adding any new G(phi) to GContent(M) might be inconsistent.

**Counterexample sketch**: Consider an MCS M where GContent(M) = {psi : psi is a theorem}. Such an MCS exists (the "tautological" MCS). Then G(phi) for any non-theorem phi would make {G(phi)} union GContent(M) = {phi} union {theorems}, which is consistent iff phi is consistent. This would work for most phi, but the issue is more subtle in the quotient: the witness W could end up in the SAME equivalence class as M if GContent(W) = GContent(M) despite having more G-formulas.

**Approaches tried and failed** (from handoff document):
- Tautological witnesses (F(neg(bot))): witness lands in same equivalence class
- Atomic witnesses (F(neg(p))): MCSes in same class can disagree on atoms
- Temporally saturated MCS construction: proven impossible in research-010

### 2. Representative Function Structural Flaw

**Result**: The quotient-to-BFMCS approach via representatives has a fundamental limitation (confidence: 95%)

Even if NoMaxOrder were provable, the representative-based BFMCS construction cannot satisfy forward_F for arbitrary formulas.

**The problem**: `BFMCS.forward_F` requires: if F(phi) in mcs(t), then exists s > t with phi in mcs(s). When mcs(t) = repr(q_t) and mcs(s) = repr(q_s) for quotient elements q_t < q_s:

- F(phi) is shared across the equivalence class [q_t] (since F-formulas are determined by GContent)
- canonical_forward_F gives witness W with phi in W and CanonicalR(repr(q_t), W)
- W maps to some quotient element [W] with [q_t] <= [W]
- If [W] > [q_t], then [W] = q_s for some s > t. But phi in W does NOT imply phi in repr(q_s), because phi might not be a G/F formula and members of the same equivalence class can disagree on non-G/F formulas

**Concrete example**: Let phi = atom("p"). F(atom("p")) in repr(q_t). The witness W has atom("p") in W and [W] > [q_t]. But repr([W]) is chosen by Mathlib's ofAntisymmetrization, which picks an arbitrary representative. This representative may not contain atom("p"), even though W does.

**Implication**: A representative-based approach requires either:
- Choosing representatives that are F-consistent (a global choice problem as hard as building the BFMCS directly)
- Using the quotient as the time index with a DIFFERENT definition of BFMCS that uses the equivalence class properties instead of a single representative

### 3. Vestigial AddCommGroup Constraint

**Result**: Confirmed vestigial (confidence: 99%)

Systematic analysis of all files in the completeness proof chain shows that `AddCommGroup D` and `IsOrderedAddMonoid D` are declared in variable blocks but NEVER used in any proof:

| File | Has Constraint | Uses Additive Ops |
|------|---------------|-------------------|
| BFMCS.lean | Yes (variable) | No |
| BMCS.lean | Yes (variable) | No |
| BMCSTruth.lean | Yes (variable) | No |
| TruthLemma.lean | Yes (variable) | No |
| Completeness.lean | Yes (variable) | No |
| ModalSaturation.lean | Yes (variable) | No |
| CoherentConstruction.lean | Yes (variable) | No |
| Construction.lean | Yes (variable) | No |
| TemporalCoherentConstruction.lean | Yes (variable) | No |
| SoundnessLemmas.lean | Yes (variable) | No |
| Soundness.lean | Yes (variable) | No |

Every proof in the chain uses only `<` and `<=` from LinearOrder. The additive structure was likely inherited from an earlier design where time differences or shifts were used, but the current TM-logic proof framework operates purely on ordered positions.

### 4. Mathlib Alternative: orderIsoRangeToZOfLinearSuccPredArch

**Result**: Exists but does not bypass NoMaxOrder

`orderIsoRangeToZOfLinearSuccPredArch` gives `ι ≃o (Set.range (toZ _))` -- an order isomorphism to a RANGE of integers, not all of Int. It requires:
- LinearOrder, SuccOrder, PredOrder, IsSuccArchimedean, Nonempty
- Does NOT require NoMaxOrder or NoMinOrder

However:
- The range `Set.range (toZ _)` is a subtype of Int, NOT Int itself
- BFMCS requires `D = Int` (or at least D with AddCommGroup)
- `Set.range (toZ _)` does NOT have AddCommGroup
- Even with the "generalize D" approach, a BFMCS over the range would need padding to extend to all of Int, which recreates the NoMaxOrder problem

### 5. Order.embedding_from_countable_to_dense

**Result**: Available but insufficient

`Order.embedding_from_countable_to_dense` gives an order embedding from any countable linear order into any nontrivial dense order (e.g., Q). This could embed the canonical quotient into Q, but:
- Q is not isomorphic to Int
- The image in Q might be dense, making transfer to Int impossible
- BFMCS requires discrete time steps with strict inequality semantics

### 6. Literature Survey

Standard completeness proofs for Prior's tense logic (Goldblatt 1992, Burgess 1984, Blackburn et al. 2001) use either:

A. **Tree unravelling**: Build a tree-like canonical model from MCSes, then show every branch satisfies the temporal properties. This avoids the linear ordering problem but requires a fundamentally different proof architecture.

B. **Step-by-step chain construction**: Build MCSes one at a time, interleaving future and past obligations. This IS the DovetailingChain approach and has the known F-persistence problem.

C. **Filtration/finite model property**: For decidability, not directly applicable to strong completeness.

D. **Bulldozing** (Blackburn et al., Lemma 4.71): Transform a tree-like model into a linear model by "bulldozing" -- flattening the tree while preserving truth. This is the technique most relevant to our setting but requires implementing tree-to-chain flattening.

## Alternative Approaches Ranked by Viability

### Rank 1: Generalize D (Drop AddCommGroup Constraint)

**Viability**: HIGH (confidence: 85%)
**Effort**: 8-14 hours
**Risk**: Low-Medium (mostly mechanical refactoring)

**Description**: Remove the vestigial `AddCommGroup D` and `IsOrderedAddMonoid D` constraints from the entire BFMCS/BMCS chain. Replace with just `[LinearOrder D]`. Then construct BFMCS over the canonical frame's native type (CanonicalReachable or a suitable subtype) where forward_F/backward_P follow trivially from canonical_forward_F/canonical_backward_P.

**Key advantage**: Completely sidesteps the NoMaxOrder problem and the quotient approach entirely. The canonical frame already has all temporal properties.

**Key challenge**: The forward_F/backward_P of the canonical frame give witnesses at the SAME level (CanonicalR is reflexive). For BFMCS, we need STRICT future witnesses (s > t). This requires either:
- Using the quotient as time domain (but has the representative problem)
- Using the raw CanonicalReachable type as time domain (but CanonicalR is reflexive, so a < b means NOT mutually CanonicalR, which corresponds to strict GContent inclusion)

**Wait -- critical re-analysis**: If D = CanonicalReachable (not the quotient), with the preorder from CanonicalR, then `a < b` means `CanonicalR(a, b) and NOT CanonicalR(b, a)`. Now:
- forward_G: if G(phi) in a and a < b, then CanonicalR(a, b), so phi in b. WORKS.
- backward_H: symmetric. WORKS.
- forward_F: if F(phi) in a, then canonical_forward_F gives b with phi in b and CanonicalR(a, b). If a < b (strict), done. If a = b, then phi in a -- we need a STRICT future witness. If NOT(CanonicalR(b, a)), then a < b, done. If CanonicalR(b, a), then a and b are mutually related (same equivalence class in the quotient sense), and we need strict.

So the strict-future-witness problem persists even with CanonicalReachable as time domain. The issue is: when canonical_forward_F gives a witness in the same "equivalence class", we have no strict future position.

**Revised assessment**: This approach ALSO needs to solve the strict-future-witness problem. However, using CanonicalReachable directly (not the quotient) means we can potentially find witnesses in a different member of the equivalence class, which is easier than finding witnesses in a different class.

**Actually**: If D = CanonicalReachable with the preorder, then `a < b` is strict CanonicalR. The canonical_forward_F witness W satisfies CanonicalR(a, W). We need either W > a (i.e., CanonicalR(a, W) and NOT CanonicalR(W, a)) or W = a (reflexive case).

If W = a, then phi in a. We need s > a with phi in s. This means we need a STRICT future of a that also contains phi. This is exactly the F-persistence problem.

**Conclusion**: Generalizing D does NOT avoid the strict-future-witness problem. It avoids NoMaxOrder and the Int isomorphism, but the core difficulty remains.

### Rank 2: Bulldozing Construction

**Viability**: MEDIUM (confidence: 60%)
**Effort**: 15-25 hours
**Risk**: Medium-High (novel construction, complex proofs)

**Description**: Implement the "bulldozing" technique from modal logic (Blackburn, de Rijke, Venema 2001, Lemma 4.71). Build a tree-like canonical model first, then flatten it into a linear chain while preserving truth.

**How it works**:
1. Start with a tree of MCSes rooted at M_0
2. At each node, branch for each F-obligation (future) and P-obligation (past)
3. The tree naturally satisfies forward_F and backward_P
4. "Bulldoze" the tree into a linear order by choosing a traversal that respects the temporal ordering
5. The linear order gives the BFMCS

**Key advantage**: The tree naturally solves forward_F because each F-obligation gets its own branch. The challenge is purely in the bulldozing step.

**Key challenge**: Bulldozing requires showing that the traversal preserves temporal properties. In particular, if F(phi) in M and the witness W is on a different branch, the linearization must place W after M.

### Rank 3: Prove NoMaxOrder via Axiom-Forced Infinitely Many Classes

**Viability**: LOW-MEDIUM (confidence: 40%)
**Effort**: 5-10 hours
**Risk**: High (may be unprovable)

**Description**: Show that the axiom system (particularly temp_linearity and temp_4) forces infinitely many distinct equivalence classes in the canonical quotient.

**Argument sketch**: If there were only finitely many classes, then the quotient would be a finite linear order, say {c_1 < c_2 < ... < c_n}. For any MCS M in c_n (the max class), consider F(phi) for some phi with G(phi) not in M. The canonical_forward_F witness W must satisfy CanonicalR(M, W), so [W] >= [M] = c_n. Since c_n is max, [W] = c_n. This means W and M are in the same class, so GContent(W) = GContent(M). But phi in W and phi may or may not be in M...

The argument doesn't obviously lead to a contradiction. The finite quotient is NOT clearly impossible.

### Rank 4: Direct DovetailingChain Fix

**Viability**: LOW (confidence: 25%)
**Effort**: 10-20 hours
**Risk**: Very High (12+ prior approaches failed)

**Description**: Fix the existing DovetailingChain.lean forward_F/backward_P sorries directly.

**Why this is low-ranked**: 12 prior research iterations have failed to find a viable approach. The fundamental F-persistence problem (formulas not persisting through GContent seeds) remains unsolved.

### Rank 5: Modify BFMCS Semantics

**Viability**: LOW (confidence: 30%)
**Effort**: 8-15 hours
**Risk**: High (cascading changes to TruthLemma)

**Description**: Change the BFMCS forward_F property to use CanonicalR-based witnesses instead of strict time ordering. Specifically: `forward_F : forall t phi, F(phi) in mcs(t) -> exists s, CanonicalR(mcs(t), mcs(s)) and phi in mcs(s)`.

This avoids the strict inequality requirement but changes the semantics and requires re-proving the TruthLemma.

## Concrete Next Steps

### Recommended Path: Weaken forward_F + Generalize D + Direct Canonical Frame BFMCS

The breakthrough finding (Section 0) fundamentally changes the approach. Instead of solving the strict-future-witness problem, we ELIMINATE it by weakening forward_F to use reflexive witnesses.

**Phase 1: Weaken forward_F/backward_P to reflexive** (2-3 hours)
- Change `TemporalCoherentFamily.forward_F` from `t < s` to `t <= s`
- Change `TemporalCoherentFamily.backward_P` from `s < t` to `s <= t`
- Change `BMCS.temporally_coherent` to match
- Update `temporal_backward_G` proof: replace `le_of_lt h_lt` with `h_le` (trivial)
- Update `temporal_backward_H` proof: same pattern
- Verify `lake build` passes (expected: all proofs still valid since the weakened version still provides the contradiction)
- Also update `temporal_coherent_family_exists_Int` and related signatures in DovetailingChain.lean
- This is a LOW-RISK change with HIGH payoff

**Phase 2: Drop AddCommGroup constraint** (3-5 hours)
- Change all variable declarations from `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` to `[LinearOrder D]`
- Verify `lake build` passes (expected: no proof breaks since no additive ops used)
- This enables constructing BFMCS over ANY linear order, including CanonicalReachable
- About 15 active files need updating (plus inactive Boneyard files that can be left or updated mechanically)

**Phase 3: Build BFMCS on canonical frame** (3-5 hours)
- Define BFMCS over CanonicalReachable (the reachable fragment of the canonical frame)
- forward_G: trivial from canonical_forward_G (CanonicalR already proven for t <= t')
- backward_H: trivial from canonical_backward_H
- forward_F (reflexive): trivial from canonical_forward_F (gives CanonicalR(M, W), so [M] <= [W])
- backward_P (reflexive): trivial from canonical_backward_P
- Context preservation: M_0 contains Gamma by construction

**Phase 4: Wire into completeness chain** (2-4 hours)
- Define `fully_saturated_bmcs_exists` using the canonical frame BFMCS
- Combine with modal saturation (existing infrastructure)
- Replace sorry in `fully_saturated_bmcs_exists_int` (or generalize away from Int)
- Verify completeness theorem compiles
- Run `lake build` to confirm zero errors

**Total estimated effort: 10-17 hours**
**Risk: LOW-MEDIUM** (each phase is independently verifiable and reversible)

## Confidence Levels

| Finding | Confidence |
|---------|------------|
| Reflexive forward_F suffices for TruthLemma (BREAKTHROUGH) | 98% |
| NoMaxOrder likely unprovable for general canonical quotient | 70% |
| Representative-based approach cannot satisfy strict forward_F | 95% |
| AddCommGroup constraint is vestigial | 99% |
| "Generalize D" refactor is safe (no proofs break) | 90% |
| Phase 1 (weaken forward_F) succeeds | 95% |
| Phase 2 (drop AddCommGroup) succeeds | 90% |
| Phase 3 (canonical frame BFMCS) succeeds after Phases 1-2 | 85% |
| Full completeness proof sorry elimination | 75% |

## References

- Phase B handoff: `specs/922_strategy_study_fp_witness_completeness_blockers/handoffs/phase-B-handoff-20260224.md`
- Research-004 (team research): `specs/922_strategy_study_fp_witness_completeness_blockers/reports/research-004.md`
- Research-003: `specs/922_strategy_study_fp_witness_completeness_blockers/reports/research-003.md`
- Plan v3: `specs/922_strategy_study_fp_witness_completeness_blockers/plans/implementation-003.md`
- CanonicalQuotient.lean: `Theories/Bimodal/Metalogic/Bundle/CanonicalQuotient.lean`
- Mathlib `orderIsoRangeToZOfLinearSuccPredArch`: `Mathlib.Order.SuccPred.LinearLocallyFinite`
- Mathlib `Order.embedding_from_countable_to_dense`: `Mathlib.Order.CountableDenseLinearOrder`
- Blackburn, de Rijke, Venema 2001, *Modal Logic*, Chapter 4 (bulldozing)
- [Goldblatt 1992, *Logics of Time and Computation*](https://web.stanford.edu/group/cslipublications/cslipublications/site/0937073946.shtml)
- [Stanford Encyclopedia - Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/)

## Next Steps

1. **Immediate (DONE in this research)**: TruthLemma audit confirms s >= t suffices. The `temporal_backward_G` proof's contradiction holds for both s > t and s = t cases.
2. **Next implementation**: Revise plan (v4) to implement Phases 1-4 as described in "Concrete Next Steps" above.
3. **Highest priority action**: Phase 1 (weaken forward_F) is the single change that unblocks everything. It should be done first and tested in isolation.
4. **Phase 2 (drop AddCommGroup)** has value independent of the forward_F change and could be a separate task if the refactor scope is large.
5. **After Phase 4**: Run `lean_verify` on the completeness theorem to confirm axiom cleanliness.
