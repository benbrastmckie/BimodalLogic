# Teammate D Findings: Strategic Horizons (Round 10)

**Task**: 93 - Close BXCanonical embedding sorry
**Angle**: Strategic horizons, roadmap alignment, creative approaches
**Date**: 2026-04-13

## Key Findings

### 1. The Sorry Landscape is Precisely Scoped

After reading the full ROAD_MAP and tracing every sorry in the active path, the situation is:

- **1 sorry-free theorem** (`bx_countermodel`) calls 3 restricted coherence lemmas
- **6 sorry sites** in `CanonicalModel.lean`: lines 497, 503, 586, 591, 621, 627
- **Only 3 are on the active path**: `bx_bfmcs_restricted_tc` (line 603), `bx_bfmcs_restricted_buc` (line 617), `bx_bfmcs_restricted_fuc` (line 623)
- The 3 unrestricted versions (lines 569, 583, 588) are dead code

The restricted versions all delegate to `bx_fmcs_forward_F` / `bx_fmcs_backward_P` (the unrestricted sorry at lines 497/503), throwing away the restriction. This is the core architectural blind spot identified in Round 9 and it remains unfixed.

### 2. The Exact Interface the Sorry Must Satisfy

From `RestrictedParametricTruthLemma.lean:471-476`, `bx_countermodel` needs exactly:

```
restricted_temporally_coherent root:
  for phi in deferralClosure(root):
    F(phi) in fam.mcs(t) -> exists s > t, phi in fam.mcs(s)
    P(phi) in fam.mcs(t) -> exists s < t, phi in fam.mcs(s)

restricted_forward_until_since_coherent root:
  for (phi U psi) in subformulaClosure(root):
    (phi U psi) in fam.mcs(t) -> exists s >= t, psi in fam.mcs(s) and guard
  for (phi S psi) in subformulaClosure(root):
    (phi S psi) in fam.mcs(t) -> exists s <= t, psi in fam.mcs(s) and guard

restricted_backward_until_since_coherent root:
  for (phi U psi) in subformulaClosure(root):
    witness exists -> (phi U psi) in fam.mcs(t)
  for (phi S psi) in subformulaClosure(root):
    witness exists -> (phi S psi) in fam.mcs(t)
```

These are properties of the Int-indexed chain `int_chain N h_N` for each family `shifted_bx_fmcs N h_N s`.

## End-to-End Completeness Flow Analysis

The completeness flow is:

```
bx_completeness (Completeness.lean:123)
  -> bx_countermodel (CanonicalModel.lean:635)  [sorry-free wiring]
       -> bx_bfmcs M h_mcs : BFMCS Int           [sorry-free construction]
       -> bx_bfmcs_restricted_tc M h_mcs phi      [SORRY -- delegates to forward_F]
       -> bx_bfmcs_restricted_buc M h_mcs phi     [SORRY -- Until/Since backward]
       -> bx_bfmcs_restricted_fuc M h_mcs phi     [SORRY -- Until/Since forward]
       -> fully_restricted_parametric_representation_from_neg_membership
            [sorry-free -- consumes the 3 above]
```

The `bx_bfmcs` construction (lines 507-566) is sorry-free. It builds:
- **Families**: shifted Int-chains from all modally-equivalent MCS to M0
- **Modal forward/backward**: sorry-free (uses box_stable_in_shifted_fmcs + S5)
- **eval_family**: shifted_bx_fmcs M0 h0 0

The ONLY gap is proving that the Int chain has the 3 restricted coherence properties.

### Chain Construction Analysis

The `int_chain` construction uses:
- Forward: `fwd_succ M h_mcs (schedule n)` -- at step n, targets formula `schedule(n)` for F-resolution
- Backward: `bwd_pred M h_mcs (schedule n)` -- symmetric for P-resolution

The schedule visits every formula infinitely often (via `schedule_surjective_above`). This ensures every F-formula is eventually resolved. The problem is the GAP BETWEEN "eventually targeted" and "still present when targeted":

- At step n, `fwd_succ` resolves `F(schedule(n))` IF `F(schedule(n)) in chain(n)`
- But F-formulas can be LOST at intervening resolving steps (because the seed `{psi} union g_content(M)` does not guarantee F-formula persistence)

This is the fundamental forward_F blocker. The scheduling chain was designed to resolve F-formulas one at a time, but the resolution of one formula can destroy another.

## Creative Approaches

### Approach 1: Root-Scoped Chain with Simultaneous Resolution (NOVEL)

Instead of targeting one formula per step, build a chain that resolves ALL pending F-formulas from `deferralClosure(root)` simultaneously at each step.

**Key insight**: `deferralClosure(root)` is FINITE (bounded by formula size). At any point in the chain, the set of "pending F-obligations" `{phi in deferralClosure(root) | F(phi) in chain(t)}` is a subset of a finite set.

**Construction**: Replace `fwd_succ` with `fwd_succ_all(M, root)` that builds a seed:
```
g_content(M) union {phi | F(phi) in M and phi in deferralClosure(root)}
```

This seed is a SUBSET of M (by BX1 for g_content, and F(phi) in M implies phi or something... wait, no. F(phi) in M does NOT imply phi in M. This is the whole problem).

**Problem**: The seed `{phi | F(phi) in M} union g_content(M)` is NOT necessarily consistent. Dead end 7 in the ROAD_MAP explicitly says: "the multi-target seed `{psi | F(psi) in w} union g_content(w)` is inconsistent in general."

**Verdict**: BLOCKED by ROAD_MAP dead end 7.

### Approach 2: BX12 Reduction -- Eliminate Forward_F Entirely (MOST PROMISING)

BX12 says `F(phi) -> (top U phi)`. This means:
- `restricted_temporally_coherent` requires: `F(phi) in fam.mcs(t) -> exists s > t, phi in fam.mcs(s)` for phi in `deferralClosure(root)`
- By BX12: if `F(phi) in fam.mcs(t)`, then `(top U phi) in fam.mcs(t)` (via MCS closure)
- By `restricted_forward_until_since_coherent`: if `(top U phi) in subformulaClosure(root)`, then we get `exists s >= t, phi in fam.mcs(s)` with guard `top in fam.mcs(r)` for all r in [t,s)

This REDUCES restricted_tc to restricted_fuc, eliminating forward_F as an independent obligation. The reduction requires:

**Critical question**: Does `F(phi) in deferralClosure(root)` imply `(top U phi) in subformulaClosure(root)`?

Almost certainly NOT for `subformulaClosure(root)` (which only contains literal subformulas). But `deferralClosure(root)` is an enriched closure. The BX12 reduction needs `(top U phi)` to be in the closure for this to work.

**Action needed**: Check whether `deferralClosure(root)` or an extension of it contains `(top U phi)` when it contains `F(phi)`. If the enriched closure from `EnrichedClosure.lean` already does this, then the BX12 reduction eliminates forward_F.

Even if not currently in the closure, ADDING `(top U phi)` for each `F(phi) in deferralClosure(root)` is a straightforward closure extension that preserves finiteness.

### Approach 3: Hybrid -- Quasimodel for Forward, Chain for Backward (NOVEL)

The existing quasimodel infrastructure (2,289 lines, sorry-free) already solves Until/Since eventualities at the Frame.lean level. The idea: use the SAME infrastructure to close the BFMCS coherence obligations.

**Observation**: `bx_until_eventuality_resolution` (Frame.lean, sorry-free) gives:
```
(phi U psi) in w.formulas and psi not in w.formulas ->
  exists v, bx_le w v and psi in v.formulas and phi in w.formulas
```

This is a BXPoint-level result. The BFMCS obligation is at the chain-MCS level:
```
(phi U psi) in chain(t) ->
  exists s >= t, psi in chain(s) and forall r in [t,s), phi in chain(r)
```

The gap: going from "exists some BXPoint v with bx_le w v and psi in v" to "exists s along THIS chain with psi in chain(s)". The chain is a specific sequence of MCS; the BXPoint v from Frame.lean may not lie on this chain.

**However**: For the RESTRICTED obligations, the chain only needs to satisfy coherence for formulas in `subformulaClosure(root)` / `deferralClosure(root)`. Could we build a DIFFERENT chain construction that leverages the quasimodel directly?

**Idea**: Instead of the scheduling chain, build the Int-indexed chain as a realization of a quasimodel chain. The quasimodel `Construction.lean` builds Hintikka chains with defect-discharge. `Realization.lean` lifts them to BXPoint chains. Could we index these BXPoint chains by Int directly?

This is essentially Architecture C from Round 9 (quasimodel replacement). Estimated at 500-800 lines but builds on 2,289 lines of existing infrastructure.

### Approach 4: Weaken to Density-Free Completeness (NOT VIABLE)

The ROAD_MAP mentions `completeness_over_Int` (Int is discrete, not dense). Dense completeness is task 68, an independent track.

The current statement `valid phi -> Nonempty (DerivationTree [] phi)` is about validity over ALL TaskModels (including dense ones). We cannot weaken to "valid over Int models" without changing the theorem statement, which would lose the main scientific contribution.

**Verdict**: Not viable without changing the goal.

### Approach 5: Direct BFMCS Construction from Quasimodel (NOVEL, HIGH POTENTIAL)

Instead of building the BFMCS via scheduling chains and then proving coherence, build it directly from the quasimodel infrastructure:

1. Given MCS M0 with neg(phi) in M0
2. Build a quasimodel chain for `subformulaClosure(phi)` starting from M0's Hintikka restriction
3. Realize the chain as BXPoints via `Realization.lean`
4. Index the BXPoint chain by Int (finite chain extended with identity)
5. The FMCS is the Int-indexed chain of MCS from the BXPoints
6. Forward/backward coherence follows from the quasimodel's defect-discharge

**Key advantage**: The quasimodel construction ALREADY handles Until eventualities (that is its purpose). The scheduling chain tries to re-solve the same problem from scratch.

**Key challenge**: The quasimodel chain is finite (bounded by defect count). Extending it to an infinite Int-indexed chain requires either:
- (a) Repeating the construction infinitely (dovetailing), or
- (b) Extending the finite chain with an "identity tail" where chain(n) = chain(last) for n > last

Option (b) works for Until/Since coherence (eventualities resolved in the finite portion persist). For forward_F, the identity tail trivially satisfies it if all F-obligations in deferralClosure(root) are already resolved in the finite portion.

**This is viable because**: The quasimodel discharges ALL Until-defects within subformulaClosure(root). After discharge, no pending Until formulas remain. And BX12 reduces F to Until, so no pending F-obligations remain either.

## Infrastructure Reuse Assessment

### What Already Exists and Is Sorry-Free

| Module | Lines | Reuse Potential |
|--------|-------|-----------------|
| `Frame.lean` | 673 | HIGH -- all BXPoint lemmas, including eventuality resolution |
| `TruthLemma.lean` | 320 | HIGH -- formula-by-formula truth bridge |
| `Quasimodel/Construction.lean` | 887 | HIGH -- defect-discharge chains |
| `Quasimodel/Realization.lean` | 444 | MEDIUM -- lifting infrastructure, but current interface targets Frame.lean not BFMCS |
| `Filtration/DefectChain.lean` | 137 | MEDIUM -- well-founded recursion on defects |
| `Filtration/SigmaOrdering.lean` | 179 | LOW -- sigma-restricted ordering, consumed by Frame.lean |
| `CanonicalModel.lean` (existing) | 660 | HIGH -- scheduling chain, BFMCS construction, modal coherence all reusable |
| `CanonicalChain.lean` | 157 | MEDIUM -- MCS-level BX lemmas |

### Minimal Delta Assessment

**If Approach 2 (BX12 reduction) works**:
- Modify `deferralClosure` to include `(top U phi)` for each `F(phi)`: ~20 lines
- Prove restricted_tc from restricted_fuc: ~30 lines
- Close restricted_fuc directly: THIS IS THE HARD PART -- need Until formula persistence through chain

**If Approach 5 (direct quasimodel BFMCS) works**:
- New file `QuasimodelBFMCS.lean`: ~300-500 lines
- Builds BFMCS from quasimodel chain realization instead of scheduling chain
- Reuses 95% of existing CanonicalModel.lean (BFMCS structure, modal coherence, shifted families)
- The quasimodel's defect-discharge provides Until/Since coherence inherently
- Forward_F reduced to forward Until via BX12

## Roadmap Alignment

### Post-Task-93 Landscape

Once task 93 is closed:
1. **Task 95** (`#print axioms` audit) becomes immediately unblocked -- quick verification
2. **Task 103** (ROAD_MAP rewrite) can mark the completeness theorem as fully proved
3. **Task 94** (archive legacy) is independent, already in progress
4. **Task 68** (dense completeness) remains independent -- the BX completeness proves over ALL ordered abelian groups, which includes dense ones. However, task 68 appears to be about a DIFFERENT completeness statement (specifically over rationals)

### Technical Debt Analysis

| Approach | New Technical Debt | Future Blocking |
|----------|-------------------|-----------------|
| Fix scheduling chain (Plan 08) | Resolving seed consistency is fragile; untilCarry refuted by counterexample | Would need rework for any axiom system changes |
| BX12 reduction (Approach 2) | Minimal -- leverages existing closure infrastructure | Clean, no debt |
| Quasimodel BFMCS (Approach 5) | ~300-500 new lines, but well-structured | Reusable for dense completeness (task 68) |

**Approach 5 has the best roadmap alignment**: the quasimodel infrastructure is already the project's most sophisticated and well-tested component. Building the BFMCS on top of it (rather than on a parallel scheduling chain) eliminates architectural duplication and provides a template for task 68.

### Does This Advance Other Roadmap Items?

- **Task 68 (dense completeness)**: A quasimodel-based BFMCS construction would generalize more easily to dense time (the quasimodel is time-index-agnostic)
- **Task 82 (FMP)**: No interaction (decidability track is independent)
- **Task 95 (#print axioms)**: Direct unblock

## Textbook Reference Analysis

### Burgess 1982/1984 Technique

The Burgess-Xu axiomatization for Since/Until over reflexive linear orders uses BX1-BX12 (matching the codebase). The completeness proof (Burgess 1982, simplified by Xu 1988) uses a canonical model where:

1. Points are MCS of the logic
2. Temporal ordering is g_content inclusion (w <= v iff G(phi) in w implies phi in v)
3. Until/Since eventualities are resolved via a step lemma: if phi U psi holds at w and psi does not hold at w, then there exists a successor v > w where the defect count decreases
4. The model is built as a chain by iterating the step lemma, discharging defects one at a time
5. Termination follows from finiteness of the subformula closure

This is EXACTLY the approach already implemented in `Construction.lean` and `Realization.lean`. The codebase faithfully implements the Burgess technique at the Frame.lean level. The remaining gap is lifting this from BXPoint chains to Int-indexed BFMCS chains.

### Verbrugge 2007 ("Completeness by Construction")

The de Jongh-Veltman-Verbrugge construction builds the model stage by stage, maintaining a linearly ordered set with MCS at each point. Each stage extends the chain to resolve pending eventualities. The key feature: the construction is CONSTRUCTIVE (avoids Zorn's lemma for the chain itself, though Lindenbaum still uses it for individual MCS).

This approach is closer to what the codebase does: build a chain step by step, resolving defects. The codebase uses well-founded recursion on `sigma_defect_count` rather than fuel, which is cleaner.

### Reynolds 1996/2003

Reynolds' key insight for Until completeness: define an enriched closure that includes `(top U phi)` for every `F(phi)`. This eliminates F as an independent operator -- every F-obligation becomes an Until obligation, and Until obligations are handled by the defect-discharge mechanism.

This is the BX12 reduction approach (Approach 2 above). The codebase already has BX12 (`F_until_equiv: F(phi) -> (top U phi)`) as an axiom. The question is whether the closure definitions include `(top U phi)` for `F(phi)` targets.

### Modern Treatment (Demri, Goranko, Kupferman 2016)

The textbook "Temporal Logics in Computer Science" covers canonical model constructions for temporal logics with Until. The approach is standard: MCS as worlds, g_content ordering, defect-discharge for eventualities. The formalization challenge is lifting from the abstract chain construction to a concrete indexed model -- exactly the gap this task faces.

## Confidence Level

**MEDIUM-HIGH**

I am confident that:
1. The BX12 reduction (Approach 2) eliminates forward_F as an independent obligation -- this is a mathematical fact from the axiom system (HIGH)
2. The quasimodel-based BFMCS (Approach 5) is architecturally sound and leverages existing infrastructure (MEDIUM-HIGH)
3. Plan 08's approach (untilCarry in resolving seed) is definitively refuted by Round 9's counterexample (HIGH)
4. The scheduling chain architecture fundamentally cannot prove unrestricted forward_F (HIGH, confirmed across 9 rounds)

I am less confident about:
- Whether `deferralClosure` already includes `(top U phi)` for `F(phi)` targets (needs verification)
- The exact line count for Approach 5 (could be 300 or 800 depending on interface mismatches)
- Whether the finite quasimodel chain extends cleanly to an infinite Int-indexed chain

## Recommended Priority

1. **Immediate**: Verify whether `deferralClosure(root)` or `enrichedClosure` includes `(top U phi)` for `F(phi)`. This is a 10-minute code inspection that determines whether Approach 2 is viable.

2. **If yes**: Implement BX12 reduction to eliminate forward_F, then close restricted_fuc/restricted_buc using the quasimodel's defect-discharge. Estimated 200-400 lines.

3. **If no**: Extend the closure (trivial, ~20 lines), then proceed as above.

4. **Fallback**: Full quasimodel BFMCS construction (Approach 5), estimated 400-600 lines.

## References

- [Burgess-Xu Axiomatic System (SEP)](https://plato.stanford.edu/entries/logic-temporal/burgess-xu.html)
- [Temporal Logic (SEP)](https://plato.stanford.edu/entries/logic-temporal/)
- [Verbrugge 2007 - Completeness by Construction (PDF)](https://festschriften.illc.uva.nl/D65/verbrugge.pdf)
- [Demri, Goranko, Kupferman - Temporal Logics in Computer Science (Cambridge)](https://www.cambridge.org/core/books/temporal-logics-in-computer-science/1EEDB306B4B0047568D8C91DFFC321D8)
