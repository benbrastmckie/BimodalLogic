# Phase 5 Blocker Resolution: Research Report

- **Task**: 98 - research_filtration_quasimodel_pivot
- **Artifact**: reports/09_phase5-blocker-resolution.md
- **Date**: 2026-04-10
- **Session**: sess_1712765200_res98d

## Executive Summary

Phase 5 of plan v4 is BLOCKED by two independent mathematical obstacles in the chain realization approach: (1) strict seed inconsistency when `G(chi) in v_i` with `G(chi) not in Sigma`, and (2) G-formula non-persistence through Hintikka chains. After analyzing all five candidate resolution paths from the handoff, the recommended approach is **Path 4 (modified): Direct proof of Frame.lean sorries via BX axioms, bypassing the chain realization entirely**. The chain-based approach (Paths 1, 2, 3, 5) adds unnecessary indirection; the four Frame.lean sorries can be attacked directly using BX7 (Until linearity) and the enriched seed construction already proven in Realization.lean.

## Obstacle Analysis

### Obstacle 1: Strict Seed Inconsistency

The plan's strict seed `h_{i+1}.formulas U g_content(v_i) U {neg f | f in Sigma \ h_{i+1}}` can be inconsistent. The core issue: for `G(chi) in v_i.formulas` with `G(chi) not in Sigma`, the Hintikka-level `hintikka_step` does not propagate `chi` into `h_{i+1}` (it only propagates G-formulas within Sigma). If `chi in Sigma` but `chi not in h_{i+1}`, the seed simultaneously requires `chi in v_{i+1}` (from `g_content(v_i)`) and `neg chi in v_{i+1}` (from sigma-negation). This is a genuine inconsistency, not an implementation bug.

### Obstacle 2: G Non-Persistence

`hintikka_step h1 h2` gives `G(chi) in h1 => chi in h2`, but does NOT guarantee `G(chi) in h2`. The backing witness `w_{i+1}` may have `neg G(chi) in w_{i+1}` (chi holds now but not always in the future). Without G-persistence, g_content cannot propagate across multiple chain steps, breaking the chain realization for chains of length > 2.

### Root Cause

Both obstacles stem from the same architectural mismatch: the Hintikka-point abstraction (which projects MCSs to a finite Sigma) loses information about formulas outside Sigma. The chain realization attempts to recover this information by threading `g_content(v_i)` through the seed, but g_content contains formulas whose G-wrappers may be outside Sigma, creating the inconsistency. The non-persistence issue amplifies this: even if one step works, multi-step propagation fails because G-formulas are existential commitments at the Hintikka level, not universal invariants.

## Candidate Path Analysis

### Path 1: Redefine bx_le

**Proposal**: Replace `bx_le w v := g_content(w) subseteq v.formulas` with an Until-witness-based ordering.

**Feasibility**: LOW

**Analysis**:
- Would require rewriting all of Frame.lean: `bx_le_refl` (currently from BX1), `bx_le_trans` (from temp_4), `bx_forward_witness`, `bx_backward_witness`, `bx_G_forward`, `bx_H_forward`.
- The existing g_content-based definition is deeply woven into the canonical model. At least 15 theorems in Frame.lean, Realization.lean, and CanonicalFrame.lean depend on `bx_le = g_content subseteq`.
- An Until-witness ordering would be linear (from BX7), but defining it formally is non-trivial: it would need to be a relation on BXPoints that captures "w's Until-witnesses are all <= v's Until-witnesses" in some appropriate sense.
- **Impact on completed phases**: Catastrophic. Phases 1-4b would all need rework since they build on the current `bx_le` definition.
- **Zero-debt risk**: HIGH. The new ordering would need its own reflexivity, transitivity, and witness properties, each of which could introduce new sorries.

**Verdict**: NOT RECOMMENDED. Cost far exceeds benefit.

### Path 2: Sigma-Restricted Chain Realization

**Proposal**: Only propagate the Sigma-portion of g_content through the chain, accepting that `bx_le` between realized points is only guaranteed for the Sigma-restricted portion.

**Feasibility**: MEDIUM-LOW

**Analysis**:
- The infrastructure partially exists: `g_content_sigma` and `g_content_sigma_sub_g_content` are already proven in Realization.lean (lines 438-445).
- Resolves Obstacle 1: by only including `g_content_sigma(v_i, Sigma)` in the seed instead of full `g_content(v_i)`, the inconsistency disappears because `hintikka_step` does propagate G-formulas within Sigma.
- Does NOT resolve Obstacle 2: G non-persistence still prevents multi-step propagation even within Sigma. `G(chi) in h_i` (with `G(chi) in Sigma`) gives `chi in h_{i+1}` but not `G(chi) in h_{i+1}`.
- The realized chain would have `g_content_sigma(v_i, Sigma) subseteq v_{i+1}.formulas` but NOT `g_content(v_i) subseteq v_{i+1}.formulas`. This means `bx_le v_i v_{i+1}` is NOT established, making the guard proof fail.
- To make this work, one would need to prove that `bx_le` restricted to the Sigma-projection is sufficient for the truth lemma. This is dubious: the truth lemma universally quantifies over all BXPoints u with `bx_le w u`, not just those reachable through the Sigma-restricted chain.

**Verdict**: DOES NOT RESOLVE OBSTACLE 2. Not viable alone.

### Path 3: Quotient/Filtration Model

**Proposal**: Work in a finite quotient model where the ordering is total by construction (the "quasimodel filtration" approach).

**Feasibility**: MEDIUM

**Analysis**:
- This is the classical approach from the literature (Goldblatt 1992, Blackburn et al. 2001). Define an equivalence relation on BXPoints by `w ~ v iff forall f in Sigma, f in w.formulas <-> f in v.formulas`, then work with equivalence classes.
- In the quotient, the ordering IS total on the finite set of equivalence classes (from BX11/BX7).
- **Mathlib support**: `Quotient`, `Setoid`, `Fintype` are all available. `Finset.sort` provides finite linear orderings.
- **Challenge**: The filtration construction is substantial. Need to define: (a) the equivalence relation, (b) well-definedness of formula membership in equivalence classes (for Sigma-formulas), (c) the quotient ordering, (d) totality of the quotient ordering from BX11, (e) the truth lemma for the quotient model, (f) lifting back to the canonical model.
- **Impact on completed phases**: Would bypass Phases 5-8 entirely. Phases 1-4b (EnrichedClosure, HintikkaPoint, Construction, seed consistency) are not needed for the filtration approach -- but they are not wasted, as they provide useful infrastructure.
- **Zero-debt risk**: MEDIUM. The filtration is a well-understood construction, but formalizing it in Lean 4 from scratch is 40-60h of work.
- **Key advantage**: Avoids the g_content mismatch entirely by working in a finite model where all formulas are within Sigma by definition.

**Verdict**: VIABLE but heavy. Would abandon the quasimodel chain approach entirely.

### Path 4: Derive Until-Induction from BX1-12

**Proposal**: Prove that the Until-induction schema `(psi or (phi and G(theta)) -> theta) -> (phi U psi -> theta)` is derivable from BX1-BX12 (specifically BX5+BX6+BX7).

**Feasibility**: LOW for the full schema, but HIGH for the specific instances needed.

**Analysis of Full Schema**:
- Until-induction was previously an axiom but was removed during the BX refactoring (replaced by BX5 self-accumulation + BX6 absorption + BX7 linearity).
- The handoff notes state "currently believed to be non-derivable". After analysis, I concur for the GENERAL schema: BX5/BX6/BX7 do not straightforwardly derive the full induction principle because BX7 only relates pairs of Until formulas, while Until-induction needs arbitrary theta.
- However, the WitnessSeed.lean proof at line 342 (`until_witness_seed_consistent`) already uses the consequence `phi U psi in M => {psi} U g_content(M) is consistent` and proves it from BX axioms. This is the essential content of Until-induction with `chi = bot`.

**Analysis of Direct Frame.lean Approach**:
- The four Frame.lean sorries all have the same structure: prove `phi in u` for arbitrary `u` in a `bx_le` interval.
- The key unused axiom is **BX7 (linear_until)**: `(phi U psi) and (chi U theta) -> three-way disjunction`. This directly addresses the ordering of Until witnesses.
- **The direct proof strategy** (bypassing chains entirely):
  1. For `until_eventuality_resolution`: Have `phi U psi in w`. Get `v >= w` with `psi in v` from BX10 + `bx_forward_witness`. For the guard: take `u` with `bx_le w u` and `bx_le u v, not bx_le v u`. Use BX5 self-accumulation: `(phi and (phi U psi)) U psi in w`. By BX4 (connect_future): `G(P(phi U psi)) in w`, so `P(phi U psi) in u`. Get backward witness `u'` with `phi U psi in u'` and `bx_le u' u`. Apply BX9: `phi or psi in u'`. If `psi in u'`, use BX12 + BX7 to show `psi in u` or `phi in u`. If `phi in u'`, need `phi in u` -- this is the gap.
  2. **The gap is precisely**: `phi in u'` with `bx_le u' u` does not give `phi in u` because `bx_le` only propagates G-content.
  3. **BX7-based resolution**: Instead of propagating `phi` through `bx_le`, use BX7 to show that the Until-witness for `phi U psi` at `u'` must be ordered relative to `v`. Specifically: `phi U psi in u'` and `top U psi in w` (from BX12 + BX10). Apply BX7 at `u'` level: the three cases give overlapping witnesses. In each case, either `psi in u` (done) or `phi in u` (from the guard of the combined Until).

**Revised Assessment**: The BX7-based approach is promising but requires careful formalization. The key insight is that BX7 gives ordering of Until WITNESSES, not of the BXPoints themselves. At `u'` with `bx_le u' u`, if `phi U psi in u'`, then BX7 applied to `(phi U psi)` and `(top U psi)` (both in `u'`, via G-propagation from `w`) gives a three-way disjunction about the combined witnesses. In all three cases, the witness for psi that is >= u' but not yet at u must have phi as guard.

**Zero-debt risk**: LOW-MEDIUM. This uses only existing axioms and proven infrastructure.
**Impact on completed phases**: Minimal. Would bypass Phases 5-8 of the chain approach and prove Frame.lean sorries directly.

**Verdict**: MOST PROMISING. Requires ~20-30h of careful axiom-level reasoning.

### Path 5: Strengthen hintikka_step with G-Persistence

**Proposal**: Add a G-persistence clause to `hintikka_step` requiring `G(chi) in h1 -> G(chi) in h2` (for `G(chi) in Sigma`).

**Feasibility**: LOW

**Analysis**:
- Would require re-proving `hintikka_chain_exists` with a stronger oracle (the `HintikkaStepOracle` would need an additional output guarantee).
- The fundamental problem: the oracle constructs `h2` via Lindenbaum extension of a seed, and there is no way to force `G(chi) in h2` without putting `G(chi)` in the seed. But putting `G(chi)` in the seed for all `G(chi) in h1` makes the seed potentially inconsistent (same issue as Obstacle 1 but at the G-formula level rather than the chi level).
- Even if `G(chi) in Sigma` constrains which formulas to add, the locally_maximal property of Hintikka points means `G(chi) in h2 or neg G(chi) in h2`, but forcing the positive case is exactly what the Lindenbaum extension cannot guarantee.
- **Impact on completed phases**: Would invalidate Phase 3 (`hintikka_chain_exists`) entirely.

**Verdict**: NOT VIABLE. Same root cause as Obstacle 1.

## Recommendation

### Primary Recommendation: Path 4 Modified -- Direct BX7-Based Proof of Frame.lean Sorries

**Rationale**: The chain realization approach (Phases 5-8 of plan v4) is fundamentally blocked by the Hintikka/MCS abstraction gap. All chain-based paths (1, 2, 5) encounter the same issue: projecting MCSs to a finite Sigma loses G-content information that cannot be recovered. Rather than building more infrastructure around this gap, attack the four Frame.lean sorries directly using the BX axiom system.

**Why this works**: The four Frame.lean sorries (`bx_until_eventuality_resolution`, `bx_until_backward`, and their Since mirrors) operate at the MCS level, where all formulas are available. The guard proof for `until_eventuality_resolution` needs to show `phi in u` for `u` in a `bx_le` interval. At the MCS level, BX7 (Until linearity) can be applied directly to compare the Until witnesses at different MCSs, without needing to project through a finite Sigma.

### Proof Obligations for the Recommended Approach

#### 1. Forward Until (`bx_until_eventuality_resolution`)

**Goal**: Given `phi U psi in w`, `psi not in w`, construct `v >= w` with `psi in v` and `forall u, bx_le w u -> bx_le u v and not bx_le v u -> phi in u`.

**Proof sketch**:
1. `F(psi) in w` from BX10. Get `v` with `bx_le w v` and `psi in v` from `bx_forward_witness`.
2. `(phi and (phi U psi)) U psi in w` from BX5 (self-accumulation).
3. For guard: take `u` with `bx_le w u`, `bx_le u v`, `not bx_le v u`.
4. From BX4 (connect_future): `G(P(phi U psi)) in w`. Since `bx_le w u`: `P(phi U psi) in u`.
5. From `bx_backward_witness`: get `u'` with `bx_le u' u` and `phi U psi in u'`.
6. **Key step**: Apply BX7 at `u'` to `(phi U psi)` and `(top U psi)`:
   - `top U psi in u'` because `F(psi) in u'` (from `bx_le u' u`, `bx_le u v`, `psi in v`, and F_from_above) plus BX12.
   - BX7 gives three cases. In each case, analyze whether the combined witness reaches `u` or lies between `u'` and `u`. The critical observation: if the psi-witness for `phi U psi` is at some `s >= u'`, and we know `bx_le u v` with `psi in v` but `not bx_le v u` (so `u` is strictly between `w` and `v`), then the guard of `phi U psi` at `u'` must include `u` in the half-open interval `[u', s)`, giving `phi in u`.
7. The difficulty is that `bx_le` is a preorder on BXPoints (not directly a linear order), so "half-open interval" is not literally available. But BX11 (temporal linearity) combined with BX7 constrains the possible configurations enough that `phi in u` follows in all cases.

**Estimated effort**: 15-20h. The core difficulty is translating the informal interval reasoning into formal BXPoint/MCS membership arguments.

#### 2. Backward Until (`bx_until_backward`)

**Goal**: Given `bx_le w v`, `psi in v`, guard on `[w,v)`, `psi not in w`, derive `phi U psi in w`.

**Proof sketch** (contradiction):
1. Assume `not (phi U psi) in w`, so `neg(phi U psi) in w`.
2. `enriched_seed_consistent_until` (already proven) gives consistent seed.
3. Lindenbaum extends to MCS `u` with `bx_le w u`, `bx_le u v`, `neg(phi U psi) in u`.
4. From `bx_le u v` and `psi in v`: `F(psi) in u` (by `F_from_above`, already proven).
5. From BX12: `top U psi in u`.
6. From `neg(phi U psi) in u` and `top U psi in u`: by BX7 applied to `(phi U psi)` (but we have its negation...) -- this needs a different argument.
7. **Alternative**: From `F(psi) in u`, get witness `u'` with `bx_le u u'` and `psi in u'`. Two sub-cases:
   - If `bx_le v u'` and `bx_le u' v` (equal in bx_le): can show `not bx_le v u` (otherwise `bx_le v u` contradicts hypothesis), so guard gives `phi in u`.
   - If not: use BX11 to establish ordering.
8. The key lemma needed: show `not bx_le v u`, i.e., there exists `G(chi) in v` with `chi not in u`. This would follow if we can find a formula distinguishing `v` from `u`. Since `psi in v` and `neg(phi U psi) in u`, and `phi U psi in v` (from BX8 + psi in v), we have `phi U psi in v` but `neg(phi U psi) in u`. So `G(phi U psi) in v` would give `phi U psi in u` via `bx_le u v`... wait, we have `bx_le u v` not `bx_le v u`. The seed gives `g_content(w) subseteq u` and `h_content(v) subseteq u`. We need to show `not bx_le v u`.
9. Actually, from `neg(phi U psi) in u` and `phi U psi in v` (from BX8), if `bx_le v u` then `g_content(v) subseteq u`. If `G(phi U psi) in v` then `phi U psi in u`, contradicting `neg(phi U psi) in u`. So we need `G(phi U psi) in v`. From `psi in v`, BX8 gives `phi U psi in v`. But `(phi U psi) in v` does NOT give `G(phi U psi) in v` in general.
10. **Better approach**: Use BX4 on psi: `psi in v => G(P(psi)) in v`. Then `P(psi) in u` (from `bx_le u v`... no, BX4 gives `G(P(psi)) in v`, `bx_le u v` means `g_content(u) subseteq v`, not `g_content(v) subseteq u`). Need `H(F(psi)) in v` from BX4'. Then `bx_le u v` means `g_content(u) subseteq v`... we actually have the reverse: `h_content(v) subseteq u` from the enriched seed.

This analysis reveals that `until_backward` is more subtle than `until_eventuality_resolution`. The contradiction approach needs either `not bx_le v u` (hard to establish constructively) or a direct path to `phi U psi in u` that contradicts `neg(phi U psi) in u`.

**Estimated effort**: 10-15h, dependent on resolution of the forward direction first.

#### 3. Since mirrors

Symmetric to Until cases, using BX5'/BX6'/BX7'/BX8'/BX9'/BX10'/BX11'/BX12' and h_content instead of g_content.

**Estimated effort**: 8-12h (mostly mechanical once Until is done).

### Secondary Recommendation: Path 3 (Quotient/Filtration) as Fallback

If the direct BX7-based approach stalls after 25h, pivot to the quotient/filtration model construction. This is a well-understood approach from the literature and avoids the bx_le non-totality issue entirely by constructing a finite model where the ordering is total by definition.

**Estimated effort for fallback**: 40-60h.

## Impact on Existing Phases

### If Path 4 (Direct BX7) succeeds:
- **Phases 1-4b**: No changes needed. The infrastructure remains useful for understanding but is not consumed.
- **Phase 5**: OBSOLETED. Chain realization is bypassed.
- **Phase 6**: OBSOLETED. Locus control is bypassed.
- **Phase 7**: SIMPLIFIED. The Frame.lean sorries are proven directly; LocusControl.lean becomes trivial delegation.
- **Phase 8**: SIMPLIFIED. Realization.lean sorries are proven through the Frame.lean infrastructure.

### If Path 3 (Filtration) is needed:
- **Phases 1-4b**: No changes but not consumed.
- **Phases 5-8**: All replaced by filtration construction.
- New phases would be: quotient definition, quotient ordering, totality proof, quotient truth lemma, lifting.

## Sorry Inventory

Current sorry count in the relevant files:

| File | Sorries | Nature |
|------|---------|--------|
| Frame.lean | 4 | `bx_until_eventuality_resolution`, `bx_until_backward`, `bx_since_eventuality_resolution`, `bx_since_backward` |
| Realization.lean | 6 | `until_eventuality_resolution` (2), `until_backward` (1), `since_eventuality_resolution` (2), `since_backward` (1) |
| Completeness.lean | 1 | TaskModel embedding (depends on Frame.lean sorries) |
| **Total** | **11** | All share the same root cause |

The Realization.lean sorries delegate to the same Frame.lean infrastructure (via LocusControl.lean), so closing the 4 Frame.lean sorries would close all 10 Until/Since sorries (the Completeness.lean sorry is separate but downstream).

## Effort Estimate

| Approach | Estimated Hours | Confidence |
|----------|----------------|------------|
| Path 4: Direct BX7 proof | 25-40h | 60% success |
| Path 3: Filtration fallback | 40-60h | 85% success |
| Combined (try 4, fall back to 3) | 35-70h | 90% success |

## Key Open Question

The critical unknown for Path 4 is whether BX7 (Until linearity) combined with BX11 (temporal linearity) is sufficient to establish the guard property at the MCS level without needing explicit interval linearity of `bx_le`. The semantic validity of the guard property is clear (it holds in all linear temporal frames), but extracting it from the axiom system at the MCS level requires careful case analysis on the BX7 three-way disjunction. A proof-of-concept attempt on `bx_until_eventuality_resolution` (the simplest of the four sorries) should take 5-8h and would definitively answer this question.

## Conclusion

The chain realization approach (Phases 5-8) should be abandoned. The Hintikka/MCS abstraction gap (Obstacles 1 and 2) is structural and cannot be patched by incremental changes. Instead, the Frame.lean sorries should be attacked directly using BX7/BX11 at the MCS level, with a quotient/filtration fallback if the direct approach stalls. This recommendation preserves all completed work (Phases 1-4b) and reduces the remaining proof effort from 70-135h (plan v4 estimate for Phases 5-8) to 25-40h (direct approach) or 35-70h (with fallback).
