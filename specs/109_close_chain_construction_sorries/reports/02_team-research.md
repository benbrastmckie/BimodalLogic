# Research Report: Task #109

**Task**: Close chain construction sorries for sorry-free completeness
**Date**: 2026-04-20
**Mode**: Team Research (4 teammates)

## Summary

This team research systematically investigated the 11 sorry sites blocking sorry-free `bx_completeness`. The central finding, confirmed independently by all 4 teammates, is that **only 7 of the 11 sorries are on the critical path**. Sorries #1-#4 are dead code from the superseded `bx_countermodel` approach and can be deleted immediately. The remaining 7 sorries (#5-#11) have a clear dependency structure with `fwd_chain_forward_F` (#7) as the keystone.

A critical architectural insight emerged: the FMCS definition uses `<=` (non-strict) ordering for `forward_G`/`backward_H`, but irreflexive semantics requires strict `<`. This mismatch is the root cause of the genuinely false `g_content_subset_self` (#5) and `h_content_subset_self` (#6). Fixing the FMCS definition eliminates these sorries without needing alternative proofs.

The enriched seed approach proposed in the original report (01) targets dead code (#1-#4) and should be deprioritized. The correct focus is: FMCS strict ordering fix (#5-#6), then keystone F-resolution (#7), then downstream temporal coherence (#8-#11).

## Key Findings

### 1. Critical Path Reduction: 11 → 7 Sorries

**Confirmed by**: Teammates A, B, C (independent verification)
**Confidence**: HIGH

Sorries #1-#4 (`enriched_seed_consistent`, `fwd_succ_f_carry`, `enriched_past_seed_consistent`, `bwd_pred_p_carry`) in CanonicalModel.lean have **zero callers** on the `bx_completeness → dd_countermodel` path. They are vestigial from the old `int_chain`/`bx_countermodel` approach. The active path uses `defect_resolving_seed_consistent` and `resolving_enriched_fwd_exists` instead.

**Action**: Delete #1-#4 as dead code. No redesign needed.

### 2. FMCS Ordering Mismatch Is Root Cause of #5/#6

**Confirmed by**: Teammates A, C (independent discovery)
**Confidence**: HIGH

The FMCS `forward_G` field requires `G(phi) ∈ chain(t) → phi ∈ chain(t')` for `t ≤ t'`. Under irreflexive semantics, G means "for all strictly future times", so the correct requirement is `t < t'`. The `t = t'` case is exactly `g_content_subset_self` — which is false because `G(phi) → phi` doesn't hold without the T-axiom.

**Fix**: Change `FMCS.forward_G` from `t ≤ t'` to `t < t'` (and symmetrically `backward_H` from `t' ≤ t` to `t' < t`). This eliminates the `m = n` base case in `sigma_fwd_g_content_trans`, making `g_content_subset_self` unnecessary.

**Cascade**: Requires updating FMCS, BFMCS, RestrictedParametricTruthLemma (G-case), and all consumers of `forward_G`/`backward_H`. The `g_content_subset_implies_h_content_reverse` duality may need adjustment.

**Risk**: Medium. The truth lemma's G-case evaluates `G(phi)` as "for all strictly future t'", which matches `t < t'`. The change should be semantically correct.

### 3. `fwd_chain_forward_F` (#7) Is the Keystone Sorry

**Confirmed by**: All 4 teammates
**Confidence**: HIGH (identification), MEDIUM (solution)

**Goal**: Given `F(phi) ∈ fwd_chain_of_sigma(n)` and `phi ∈ sigma_list`, prove `∃ m > n, phi ∈ chain(m)`.

**The termination gap** (identified by Teammates A, B, C): The current `defect_step_early` resolves at least one defect `w` per step (`w ∈ chain(n+1)`), but:
- We can't control WHICH defect is resolved (`.choose` non-determinism)
- Resolved defects can "un-resolve": `w ∈ chain(n+1)` doesn't mean `w ∈ chain(n+2)`, because `w` is not in `g_content` and doesn't propagate
- New F-obligations can appear through `g_content` propagation (if `G(F(chi)) ∈ chain(n)`)

**Two proposed solutions**:

**Solution A — Deterministic round-robin priority** (Teammate A):
- Modify `preserving_fwd_step` to use `target_stays_direct_in_fold` with a round-robin target: `sigma_list[n % |sigma_list|]`
- When the target has an active F-obligation, it gets priority resolution
- After at most `|sigma_list|` steps, each formula gets its turn
- Requires F-obligation persistence for `|sigma_list|` steps (provable via `preserving_fwd_step_defect_preserved`)

**Solution B — BX11-ordered resolution** (Teammate B):
- Use the existing `bx11_earlier` total ordering on F-defects
- The "earliest" defect is always resolved via `target_stays_direct_in_fold`
- Well-founded induction on the BX11 ordering position
- Less intrusive than Solution A (doesn't change the chain construction)

**Conflict resolution**: Solution A is more concrete and directly addresses the non-determinism, but requires modifying the chain construction. Solution B leverages existing infrastructure but the BX11 ordering is itself non-deterministic (depends on Classical.choice in the BX11 instance). **Recommended**: Solution A (deterministic round-robin), because it gives explicit control over which formula is resolved at each step.

### 4. Backward Chain Lacks P-Preservation (Structural Asymmetry)

**Identified by**: Teammates A, C
**Confidence**: HIGH

The forward chain uses `preserving_fwd_step` with full F-defect tracking. The backward chain uses plain `bwd_pred` with no P-preservation. This makes sorries #8 (F in backward region) and #9 (P resolution) structurally harder.

**Required**: Build a symmetric `preserving_bwd_step` for the backward chain, mirroring the forward chain's defect-discharge mechanism but for P-formulas using BX11' (past linearity).

### 5. Until/Since Coherence (#10, #11) May Reduce to F-Resolution

**Identified by**: Teammates A, B, C
**Confidence**: MEDIUM

- **#11 (forward Until coherence)**: `(phi U psi) ∈ chain(t) → ∃ s > t, psi ∈ chain(s) ∧ ∀ r ∈ [t,s), phi ∈ chain(r)`
  - By BX10: `F(psi) ∈ chain(t)`, so by #7, `psi ∈ chain(s)` for some `s > t`
  - Guard persistence via BX5 (self-accumulation) + BX9 (until_elim)
  - **Key difficulty**: Until formulas don't propagate through g_content, so `(phi U psi) ∈ chain(t)` doesn't guarantee `(phi U psi) ∈ chain(t+1)`

- **#10 (backward Until coherence)**: If the Until witness exists, then Until is in the MCS
  - Standard MCS maximality argument: if `¬(phi U psi) ∈ chain(t)`, derive contradiction from witness existence using BX axioms
  - Independent of #7

### 6. Broader Sorry Landscape

**Identified by**: Teammate D
**Confidence**: MEDIUM-HIGH

Beyond the 11 named sorries, there are **40 total sorries** across non-Boneyard code, including 15 in SuccRelation (3), SuccExistence (3), and TemporalDerived (9). These are transitive dependencies that may affect `bx_completeness` even after the 7 critical-path sorries are closed.

**Mitigation**: Add `#print axioms bx_completeness` immediately (even before closing sorries) to reveal the full dependency tree. No `#print axioms` checks currently exist anywhere in the codebase.

### 7. Alternative Approaches Assessed and Rejected

**Assessed by**: Teammate B
**Confidence**: HIGH

| Alternative | Verdict | Reason |
|-------------|---------|--------|
| Quasimodel path | **Dead** | Same BX1 root cause, MORE sorries |
| Deterministic chain | **Not worth it** | Massive rewrite, same blockers |
| Filtration-based | **Long-term only** | Needs full audit, likely has own sorries |
| HintikkaStepOracle | **Same problem** | Requires identical consistency fixes |

The current canonical model architecture is correct. The problem is formalization, not mathematics.

## Synthesis

### Conflicts Resolved

1. **Sorry count**: Report 01 says 11 sorries, all blocking. All teammates agree only 7 are on the critical path. The report's dependency diamond for #1-#4 is incorrect — those are dead code.

2. **Enriched seed approach**: Report 01's primary recommendation targets #1-#4 (dead code). This approach should be deprioritized. The correct focus is FMCS strict ordering (#5-#6) and F-resolution (#7).

3. **Termination argument for #7**: Teammates A and B propose different solutions (round-robin vs. BX11 ordering). Both are mathematically sound. Round-robin is recommended for its determinism and explicitness.

4. **Scope of work**: Teammate D identifies that closing the 7 critical-path sorries may not suffice for sorry-free `bx_completeness` due to transitive dependencies. A `#print axioms` check should precede implementation to establish the true scope.

### Gaps Identified

1. **No `#print axioms` infrastructure** — must be added before implementation
2. **Backward chain P-preservation** — substantial new code needed, no existing infrastructure
3. **Until propagation through chains** — fundamental difficulty for #11, may require Until-specific chain construction
4. **Transitive sorry dependencies** — 15 sorries in SuccRelation/SuccExistence/TemporalDerived not yet audited

### Revised Dependency Structure

```
Phase 0: Audit
├── Add #print axioms bx_completeness
└── Trace actual sorry dependencies

Phase 1: Dead Code Deletion [4 sorries eliminated]
└── Delete #1-#4 (enriched_seed_consistent, fwd_succ_f_carry, etc.)

Phase 2: FMCS Strict Ordering [2 sorries eliminated]
├── Change FMCS forward_G/backward_H to strict <
├── Update truth lemma G/H cases
├── Remove g_content_subset_self (#5) and h_content_subset_self (#6)
└── Audit g_content_subset_implies_h_content_reverse

Phase 3: F-Resolution Keystone [1 sorry eliminated]
├── Modify preserving_fwd_step for deterministic round-robin priority
├── Prove F-obligation persistence across |sigma_list| steps
├── Close fwd_chain_forward_F (#7) via pigeonhole termination
└── Use Mathlib Finset.strongInductionOn for well-founded argument

Phase 4: Backward P-Preservation [2 sorries eliminated]
├── Build preserving_bwd_step (symmetric to forward)
├── Close restricted_tc forward case (#8)
└── Close restricted_tc backward case (#9)

Phase 5: Until/Since Coherence [2 sorries eliminated]
├── Close restricted_buc (#10) via MCS maximality
└── Close restricted_fuc (#11) via BX10 + #7 + BX5 guard persistence
```

### Recommendations

1. **Start with Phase 0**: Add `#print axioms bx_completeness` to establish the true sorry dependency tree. This may reveal the work is larger than 7 sorries.

2. **Phase 1 is free**: Deleting dead code (#1-#4) removes 4 sorries with zero risk.

3. **Phase 2 is the highest-ROI change**: Fixing the FMCS ordering to match irreflexive semantics eliminates 2 sorries and is architecturally correct (the current `<=` is a leftover from reflexive semantics).

4. **Phase 3 is the crux**: `fwd_chain_forward_F` requires modifying the chain construction for deterministic priority resolution. This is the most technically challenging phase.

5. **Phases 4-5 depend on Phase 3**: The backward infrastructure and Until coherence build on F-resolution.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary approach: sorry inspection, proof states | completed | medium-high |
| B | Alternatives: quasimodels, textbooks, Mathlib | completed | medium-high |
| C | Critic: verify claims, find gaps | completed | high |
| D | Horizons: strategy, architecture, scope | completed | medium-high |

## References

- Existing report: `specs/109_close_chain_construction_sorries/reports/01_chain-construction-sorries.md`
- Teammate A findings: `specs/109_close_chain_construction_sorries/reports/02_teammate-a-findings.md`
- Teammate B findings: `specs/109_close_chain_construction_sorries/reports/02_teammate-b-findings.md`
- Teammate C findings: `specs/109_close_chain_construction_sorries/reports/02_teammate-c-findings.md`
- Teammate D findings: `specs/109_close_chain_construction_sorries/reports/02_teammate-d-findings.md`
- ROADMAP: `specs/ROADMAP.md`
- Key source files: `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean`, `RootScopedChain.lean`
- Mathlib: `Finset.strongInductionOn`, `zorn_subset`
