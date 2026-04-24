# Teammate B Findings: Alternative Approaches to Chronicle Construction

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-24
**Teammate Role**: Alternative Approaches (Teammate B)
**Focus**: Evaluate five alternative approaches against the current plan v5 (55 hours)

---

## Executive Summary

Five alternative approaches were evaluated against the current plan v5, which pursues a two-track strategy (Path B: Rat-based milestone, Path A: general completeness over sparse X). The analysis draws on the task 112 literature study, the existing sorry-free Int chain infrastructure, and the three-layer problem diagnosis from report 15.

**Bottom line**: Approach A (Hybrid Int-chain + Until/Since enrichment) is the most promising alternative, offering a potentially dramatic reduction in effort by reusing the sorry-free Int chain while solving Until/Since coherence through an enriched successor seed. The other approaches are either theoretically interesting but impractical for this codebase (B, C), or variations that still face the fundamental problems (D, E).

---

## Approach A: Hybrid Int-Chain + Until/Since Enrichment

### The Idea

The Int chain in `CanonicalModel.lean` already provides sorry-free:
- `forward_G` (lines 250-254): G(phi) in chain(t) and t < t' implies phi in chain(t')
- `backward_H` (lines 265-269): H(phi) in chain(t) and t' < t implies phi in chain(t')
- `box_stable_in_int_chain` (lines 310-368): Box(phi) in chain(t) iff Box(phi) in M0
- The parametric truth lemma handles G, H, Box, atom, bot, imp cases sorry-free

What it lacks: Until/Since coherence. The `UntilSinceCoherence.lean` module provides parameterized backward Until/Since (`backward_until_from_step`, `backward_since_from_step`) but requires a **step transfer property**:

```
h_step : forall r, (phi U psi) in fam.mcs(r+1) -> phi in fam.mcs(r) -> (phi U psi) in fam.mcs(r)
```

The question is whether the Int chain's successor construction can be enriched to provide this step transfer.

### Feasibility Analysis

**The step transfer is provable IF the successor seed is enriched.** Currently, `fwd_succ` builds the successor MCS from:
- Resolving case: `{psi} ∪ g_content(M)` when F(psi) in M
- Non-resolving case: `g_content(M)` otherwise

For Until step transfer, we need: if `(phi U psi) in fam.mcs(r+1)` and `phi in fam.mcs(r)`, then `(phi U psi) in fam.mcs(r)`. By BX axiom BX10 (Until induction / self-accumulation): `phi ∧ G(phi ∧ (phi U psi)) -> (phi U psi)`. This means if we know:
1. `phi in fam.mcs(r)` (given)
2. `G(phi ∧ (phi U psi)) in fam.mcs(r)` (need this)

Then `(phi U psi) in fam.mcs(r)`.

For (2), we need `phi ∧ (phi U psi) in fam.mcs(r+1)` (which gives G(...) in fam.mcs(r) by the g_content chain). We have `(phi U psi) in fam.mcs(r+1)` by hypothesis. We need `phi in fam.mcs(r+1)`.

**Problem**: We do NOT have `phi in fam.mcs(r+1)` in general. The Until formula `phi U psi` only guarantees phi holds at guard positions strictly before the witness. At position r+1, we may already be at or past the witness.

**Alternative via BX9**: BX9 gives `(phi U psi) -> phi ∨ psi`. So at r+1, either phi or psi holds. If phi holds, the BX10 argument works. If psi holds, then by BX8 (psi -> phi U psi), we get `(phi U psi) in fam.mcs(r+1)`, but we also need the step to fam.mcs(r). In this case: psi in fam.mcs(r+1), and phi in fam.mcs(r). By BX4 (connect_future): `phi ∧ F(psi) -> phi U psi`. We need F(psi) in fam.mcs(r). Do we have it?

**Key insight**: F(psi) in fam.mcs(r) iff psi in some fam.mcs(s) with s > r. We know psi in fam.mcs(r+1), and the Int chain resolves F(psi) obligations: if F(psi) in fam.mcs(r), there exists s > r with psi in fam.mcs(s). But we need the CONVERSE: psi in fam.mcs(r+1) implies F(psi) in fam.mcs(r).

The converse direction is h_content: H(F(psi)) is not the right formula. Actually, `psi in fam.mcs(r+1)` does NOT give F(psi) in fam.mcs(r) through the Int chain structure. The g_content/h_content duality gives us: g_content(chain(r)) subset chain(r+1), so G(phi) in chain(r) implies phi in chain(r+1). The REVERSE is h_content(chain(r+1)) subset chain(r), so H(phi) in chain(r+1) implies phi in chain(r). But F(psi) = neg(G(neg(psi))), which is NOT an H-formula.

**Assessment**: The step transfer for Until cannot be proved from the existing Int chain structure alone. The problem is fundamental: the Int chain only tracks g_content (universals) forward and h_content (universals) backward. The existential witness `F(psi) in chain(r)` is not derivable from `psi in chain(r+1)` because the chain does not track existential backward propagation.

### What Would Be Needed

To make the hybrid work, the Int chain's successor construction would need to be modified to include Until/Since tracking. Specifically:

1. **Enriched forward seed**: Instead of `{psi} ∪ g_content(M)`, use `{psi} ∪ g_content(M) ∪ until_content(M)` where `until_content(M) = {phi U psi | phi U psi in M}`.

2. **Enriched backward seed**: Similarly for past/Since.

3. **Prove consistency**: Show that `{target} ∪ g_content(M) ∪ until_content(M)` is consistent when F(target) in M. This requires showing that carrying forward Until obligations does not create inconsistency.

4. **Prove step transfer**: From the enriched seed, derive: if `phi U psi in chain(r+1)` (because until_content propagated it), and phi in chain(r), then phi U psi in chain(r).

The enriched seed consistency is the critical step. The existing `forward_temporal_witness_seed_consistent` proves consistency of `{psi} ∪ g_content(M)`. Adding `until_content(M)` means we need to show that Until formulas from M are compatible with the target psi and g_content. This is plausible: if `phi U psi'` is in M, and `G(phi U psi')` is not necessarily in M, but `phi U psi'` ITSELF propagates forward via a different mechanism than g_content.

**Major concern**: Under irreflexive semantics, `phi U psi in M` does NOT mean `G(phi U psi) in M`. The BX axiom BX5 (self-accumulation) gives `phi U psi -> phi ∨ (phi ∧ G(phi U psi))`, which is a disjunction -- it does not guarantee G(phi U psi) in M. So until_content(M) is NOT a subset of g_content(M), and carrying it forward requires proving a separate consistency result.

### Effort Estimate

- Modify successor construction to use enriched seed: 4 hours
- Prove enriched seed consistency: 8 hours (hard, may discover it is false)
- Prove step transfer from enriched chain: 4 hours
- Wire to backward_until_from_step / backward_since_from_step: 2 hours
- Prove forward Until/Since coherence: 6 hours
- Total: ~24 hours (if enriched seed consistency holds)

### Reuse of Existing Code

- **100% reuse**: forward_G, backward_H, box_stable (all sorry-free in CanonicalModel.lean)
- **100% reuse**: parametric truth lemma for G/H/Box/atom/bot/imp cases
- **100% reuse**: backward_until_from_step, backward_since_from_step parameterized framework
- **Modification needed**: fwd_succ, bwd_pred (enriched seeds)
- **New proofs needed**: enriched seed consistency, step transfer, forward Until/Since coherence

### Avoidance of Three-Layer Problems

- **Layer 1 (g function trivial)**: AVOIDED. The Int chain never uses the chronicle's g function. forward_G is proved directly from the chain construction.
- **Layer 2 (guard convention)**: PARTIALLY AVOIDED. The step transfer argument via BX10/BX4/BX9 needs careful handling of the guard at the boundary, but it operates at the MCS level (not at the chronicle condition level).
- **Layer 3 (density)**: AVOIDED. D = Int, no density issue. GGp->Gp does not hold on Z.

### Verdict: PROMISING BUT RISKY

The approach could reduce effort from 55 hours to ~24 hours IF the enriched seed consistency holds. The critical unknown is whether `{target} ∪ g_content(M) ∪ until_content(M)` is consistent. If this fails, the entire approach collapses. Recommend: invest 4 hours in a paper proof of enriched seed consistency before committing.

---

## Approach B: Venema's "Completeness via Completeness"

### The Idea

Venema 1993 proves completeness for SU-logics without building a direct canonical model for Until/Since. The strategy:
1. Build any linear model M satisfying the formula (easy via Lindenbaum)
2. Show M is definably well-ordered (a consequence of the axioms)
3. Apply Doets' theorem to replace M with a model of the correct type

### Feasibility Analysis

**Step 1** is already done: the Int chain provides a linear model.

**Step 2** requires proving the BX Int chain model is "definably well-ordered" in Venema's sense. Definable well-ordering means that every non-empty definable subset has a least element. For the pure tense logic case, Venema shows this follows from the axioms (specifically, from the Until induction axiom BX10 and its Since mirror). However:

**Critical obstacle for BX**: Venema's approach works for PURE Until/Since logic over linear orders. BX adds the S5 Box operator. The Doets equivalence theorem (Theorem 3.8 in Venema) establishes n-equivalence for first-order structures. The S5 Box operator introduces SECOND-ORDER quantification over histories/worlds. Doets' theorem does not extend to second-order properties without additional work.

Specifically, the Box case of the truth lemma requires: for all sigma in Omega (set of histories), truth at sigma. If we replace the model M with an n-equivalent M', the Omega sets differ. The S5 properties (which depend on the entire family of histories) may not transfer.

**Step 3** requires formalizing Doets' theorem in Lean 4. This is a substantial model-theoretic result involving:
- Ehrenfeucht-Fraisse games or back-and-forth arguments
- Quantifier depth analysis
- Construction of the equivalent well-ordered model

Formalizing Doets' theorem alone would be 40+ hours of work, comparable to the entire plan v5.

### Effort Estimate

- Formalize definable well-ordering for BX: 8 hours
- Formalize Doets' theorem (Venema 3.8): 40+ hours
- Prove BX model is definably well-ordered: 8 hours
- Handle bimodal (Box) extension: Unknown (may be impossible without new theory)
- Total: 56+ hours (EXCEEDS plan v5)

### Reuse of Existing Code

- **Minimal reuse**: The entire approach requires a different proof architecture
- The existing parametric truth lemma, BFMCS infrastructure, and chronicle construction would NOT be used
- Only basic MCS properties and the axiom system would carry over

### Avoidance of Three-Layer Problems

- **Layer 1**: AVOIDED (no g function needed)
- **Layer 2**: AVOIDED (no guard convention needed -- Doets handles it)
- **Layer 3**: AVOIDED (Doets provides the right frame class automatically)

### Verdict: THEORETICALLY ELEGANT, PRACTICALLY INFEASIBLE

This approach is the "nuclear option" -- it replaces all three layers of infrastructure with a single deep model-theoretic result. But formalizing Doets' theorem is a project in itself, and the Box extension is an open research question. Not recommended for task 107.

---

## Approach C: Mosaic Method (Caleiro et al. 2013)

### The Idea

The mosaic method proves completeness by decomposing models into small "tiles" (mosaics) and showing that the axioms guarantee these tiles can be assembled into a full model. This was applied to S5 + linear tense by Caleiro, Viganò, and Volpe (2013).

### Feasibility Analysis

**Relevance check**: The mosaic method is designed for logics where the canonical model construction is difficult due to interaction between operators. S5 + linear tense is exactly the kind of logic where mosaics help.

**Key difference from BX**: The Caleiro et al. result is for S5 + {G, H, F, P} WITHOUT Until/Since. Adding Until/Since significantly complicates the mosaic structure because:
- Mosaics for Until require encoding not just the formulas at a point but the INTERVAL witness pattern
- The mosaic compatibility conditions must enforce that Until witnesses are present in the assembled model
- Guard conditions (phi holds at intermediate points) translate to constraints on mosaic sequences

**Assessment**: No published mosaic completeness result for S5 + Until/Since exists. Developing one would be original research, not formalization of existing theory.

**Lean formalization effort**: Even for the Until-free case, formalizing the mosaic method requires:
- Defining mosaic types and compatibility relations
- Proving the mosaic assembly theorem (every consistent set of mosaics can be assembled)
- Proving that the axioms guarantee mosaic existence
- This is roughly the complexity of the entire chronicle construction

### Effort Estimate

- Literature study of Caleiro et al.: 4 hours
- Extend mosaic theory to include Until/Since: Unknown (original research)
- Formalize mosaic definitions: 10 hours
- Prove assembly theorem: 20+ hours
- Total: 34+ hours (WITHOUT Until/Since extension, which is unknown)

### Reuse of Existing Code

- **Very little reuse**: MCS properties and axiom system only
- The entire BFMCS/FMCS infrastructure, chronicle construction, and parametric truth lemma would be unused

### Verdict: UNSUITABLE

The mosaic method does not currently handle Until/Since. Extending it is an open research problem. Even the Until-free version would be as much work as the current plan. Not recommended.

---

## Approach D: Modified Int Chain with Rational Witnesses

### The Idea

Keep D = Int (which has AddCommGroup, solving the Box case), but insert rational-indexed witnesses at specific positions for Until/Since obligations. The idea is to "densify" the Int chain locally at points where Until/Since witnesses are needed, while keeping the chain discrete elsewhere.

### Feasibility Analysis

**Fundamental type mismatch**: The FMCS, BFMCS, parametric truth lemma, and the entire semantic framework are parameterized by a single domain type D. If D = Int, the domain is discrete and quantifiers range over integers. Inserting "rational witnesses" means changing D to Rat (or a subtype), which brings back the AddCommGroup/density issues.

One could try: D = Int, but redefine the chain to have "virtual" intermediate positions by using a custom ordering where each integer n has finitely many sub-positions n.0, n.1, ..., n.k. This is equivalent to using D = Int × Nat with lexicographic order, or D = Rat with only specific rationals inhabited.

**Problem with D = Int x Nat**: This type does NOT have AddCommGroup. Addition on Int x Nat with lexicographic order is not well-defined (what is (3, 2) + (1, 1)?). The Box case of the truth lemma requires AddCommGroup.

**Problem with "locally dense Int chain"**: If we insert a rational r between integers n and n+1 to serve as an Until witness, the domain is no longer isomorphic to Int. The FMCS type signature `FMCS D` requires D to be uniform. A "locally dense" structure would need a different domain type.

**Alternative formulation**: Use D = Rat and embed the Int chain at integer positions, with Until/Since witness positions at specific rationals. This is exactly what `ChronicleToCountermodel.lean` already does via `extended_limit_f` -- the chronicle assigns MCS to rational positions via `limit_f` at domain points and a fallback at non-domain rationals.

### Assessment

This approach collapses to the existing Path B (Rat-based) from plan v5. The "modified Int chain with rational witnesses" is precisely the chronicle construction over Rat with the Int chain values embedded at integer positions. The three-layer problems (g function, guard convention, density) remain.

### Effort Estimate

Same as plan v5 Phase 4: ~16 hours for the Rat-based pathway.

### Reuse of Existing Code

- Same as plan v5 -- this IS plan v5's Path B under a different description.

### Verdict: NOT A GENUINE ALTERNATIVE

This collapses to the existing plan. No advantage over plan v5.

---

## Approach E: Two-Sorted Approach

### The Idea

Keep the temporal model over Z for G/H/Box (which is sorry-free). Add a SEPARATE structure for Until/Since witnesses that does not need to be a full FMCS. The completeness theorem would combine: (a) the Int chain validates G/H/Box formulas, and (b) a separate Until/Since witness structure validates Until/Since formulas.

### Feasibility Analysis

**The truth lemma is inherently monolithic.** The `restricted_parametric_shifted_truth_lemma` proves phi in MCS iff truth(phi) by SIMULTANEOUS induction on formula complexity. The imp case's forward direction uses the BACKWARD induction hypothesis:

```
Forward imp: (psi -> chi) in MCS, truth(psi) entails truth(chi)
  Step 1: truth(psi) -> psi in MCS   [BACKWARD IH for psi]
  Step 2: (psi -> chi) in MCS, psi in MCS -> chi in MCS  [MCS modus ponens]
  Step 3: chi in MCS -> truth(chi)  [FORWARD IH for chi]
```

This means the truth evaluation function must be UNIFORM across all formula types. We cannot evaluate G at time t using one structure (Int chain) and Until at time t using a different structure (separate witness system), because the truth function must produce consistent results for the imp case.

**Specifically**: Consider the formula `G(phi U psi)`. The G case says: for all t' > t, truth(phi U psi, t'). The Until case at t' says: exists s > t', psi at s, with guard phi on [t', s). The guard evaluation "phi at r" for t' <= r < s must use the SAME truth function that handles G, Box, etc. So the Until witness structure must be the same structure as the G/H/Box structure.

**Could we use a "wrapper" truth function?** Define truth_combined(phi, t) that dispatches to the Int chain for G/H/Box atoms and to the witness structure for Until/Since. The problem: when evaluating `phi U psi` at t, the guard `phi at r` must call truth_combined recursively. If phi contains G subformulas, those are evaluated on the Int chain. If psi contains Until subformulas, those are evaluated on the witness structure. The INTERACTION between the two structures at r must be coherent.

**Coherence requirement**: At every time point t, the Int chain's MCS assignment chain(t) must be consistent with the witness structure's MCS assignment witness(t). If they are the SAME MCS, we are back to a single structure. If they are different, the truth function becomes non-well-founded or incoherent.

### Assessment

The two-sorted approach fails because the truth lemma requires a SINGLE coherent truth evaluation. Splitting G/H/Box from Until/Since creates an incoherence at the imp case. The only way to make it work is to ensure both structures agree at every time point, which means they must be the same structure.

### Effort Estimate

N/A -- approach is fundamentally blocked.

### Reuse of Existing Code

N/A.

### Verdict: INFEASIBLE

The monolithic nature of the truth lemma (documented extensively in ParametricTruthLemma.lean lines 22-52) prevents splitting the model into two independent structures.

---

## Comparative Summary

| Approach | Feasibility | Effort | Reuse | Avoids 3-Layer | Verdict |
|----------|-------------|--------|-------|----------------|---------|
| **A. Hybrid Int-chain + enriched seed** | Medium-High | ~24h | High | Yes (1,3) Partial (2) | BEST ALTERNATIVE |
| **B. Venema completeness via completeness** | Low | 56h+ | Minimal | Yes (all) | Too expensive |
| **C. Mosaic method** | Very Low | 34h+ (unknown) | Minimal | Unknown | Open research needed |
| **D. Modified Int chain + rationals** | N/A | Same as v5 | Same as v5 | No | Not an alternative |
| **E. Two-sorted approach** | None | N/A | N/A | N/A | Blocked by truth lemma |

---

## Recommendation

### Primary Recommendation: Pursue Approach A as a Preliminary Investigation

Before committing to plan v5's 55-hour chronicle-focused pathway, invest 4 hours in a paper-proof feasibility study of the enriched seed approach:

1. **Define until_content(M)**: The set of formulas `{phi U psi | phi U psi in M}` that should be carried forward.

2. **Attempt to prove**: `{target} ∪ g_content(M) ∪ until_content(M)` is consistent when `F(target) in M`.

3. **Key question**: Does carrying Until obligations forward via until_content create inconsistency? The worry is: if `phi U psi in M` and `neg(phi U psi) in g_content(M)` (i.e., G(neg(phi U psi)) in M), then the seed is inconsistent. But `phi U psi in M` and `G(neg(phi U psi)) in M` would mean M is inconsistent (by BX1... wait, BX1 is the T-axiom G(phi)->phi which does NOT hold under irreflexive semantics).

4. **Under irreflexive semantics**: It IS possible for `phi U psi in M` and `G(neg(phi U psi)) in M` simultaneously, because G quantifies over STRICTLY future times. So the enriched seed may indeed be inconsistent.

**This is a potential showstopper for Approach A.** If `phi U psi` and `G(neg(phi U psi))` can coexist in an MCS under irreflexive semantics, then `until_content(M) ∪ g_content(M)` is NOT guaranteed consistent.

**Mitigation**: Rather than carrying ALL Until formulas forward, carry only those that are not negated by g_content. Define `safe_until_content(M) = {phi U psi in M | neg(phi U psi) not in g_content(M)}`. But this makes the seed formula-dependent and complicates the consistency proof.

### Secondary Recommendation: Proceed with Plan v5

If the 4-hour feasibility study for Approach A reveals the enriched seed is inconsistent (likely due to the irreflexive semantics issue above), proceed with plan v5. The chronicle pathway, despite its three-layer problems, is the established mathematical approach and has 15 rounds of research behind it.

### Longer-Term Consideration

The Venema "completeness via completeness" approach (Approach B) is the mathematically correct way to avoid the chronicle entirely. If BX completeness becomes a long-term research goal (beyond task 107), formalizing Doets' theorem and extending it to bimodal logics would be a valuable contribution. This would be a separate multi-month task.

---

## Appendix: Key Codebase References

### Sorry-Free Infrastructure (DO NOT modify)

| File | Key Results |
|------|------------|
| `CanonicalModel.lean` | `int_chain_forward_G`, `int_chain_backward_H`, `box_stable_in_int_chain` |
| `ParametricTruthLemma.lean` | `parametric_canonical_truth_lemma` (G/H/Box/atom/bot/imp) |
| `RestrictedParametricTruthLemma.lean` | `restricted_parametric_shifted_truth_lemma` |
| `UntilSinceCoherence.lean` | `backward_until_from_step`, `backward_since_from_step` |
| `WitnessSeed.lean` | `forward_temporal_witness_seed_consistent`, g/h content duality |

### Sorry Sites in Chronicle Pathway (15 total)

| File | Count | Nature |
|------|-------|--------|
| `ChronicleToCountermodel.lean` | 15 | forward_G, backward_H, box_stable, temporal/Until/Since coherence |
| `CounterexampleElimination.lean` | 3 | C4 sub-cases |
| `ChronicleConstruction.lean` | 4 | Limit construction properties |
| `PointInsertion.lean` | 2 | Insertion lemmas |

### BX Axioms Relevant to Until Step Transfer

| Axiom | Statement | Role |
|-------|-----------|------|
| BX4 (connect_future) | `phi ∧ F(psi) -> phi U psi` | Links existential witness to Until |
| BX5 (self_accum_until) | `phi U psi -> phi ∨ (phi ∧ G(phi U psi))` | Disjunctive decomposition |
| BX8 (psi_imp_until) | `psi -> phi U psi` | Reflexive base case |
| BX9 (until_elim) | `phi U psi -> phi ∨ psi` | At-point disjunction |
| BX10 (until_induction) | `G((phi ∧ phi U psi) -> phi U psi) ∧ ... -> (phi U psi -> chi)` | Induction principle |
