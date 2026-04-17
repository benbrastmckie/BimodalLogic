# Implementation Plan: BX12 Reduction for Temporal Coherence (v35)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [NOT STARTED]
- **Effort**: 14 hours
- **Dependencies**: Task 92 (truth lemma sorry-free)
- **Research Inputs**: reports/35_team-research.md
- **Artifacts**: plans/35_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan closes the 8 remaining sorry sites in RootScopedChain.lean using the BX12 reduction discovered in Report 35. BX12 (`F_until_equiv`, Axioms.lean:258) states `F(phi) -> (top U phi)`, reducing F/P temporal coherence to Until/Since coherence. The plan proves Until/Since coherence for the chain using BX8/BX9 axioms and the chain's g_content/h_content propagation, then derives F/P coherence via BX12/BX12'. The plan builds on completed Phase 0-1 infrastructure from v33 (custom Lindenbaum extension, bx11_min selection, defect_fwd_chain, self_resolving_fwd_step). Definition of done: `lake build` succeeds with zero sorry reachable from `bx_completeness`, and `#print axioms` lists only `propext`, `Classical.choice`, `Quot.sound`.

### Research Integration

- **Report 35** (team research, 4 teammates): Discovered BX12 reduction -- `F(phi) -> (top U phi)` reduces all 8 sorry sites to Until/Since coherence. Identified closure alignment gap (`top U psi` not in subformulaClosure). Confirmed quasimodel infrastructure is sorry-free (2132 LOC) but targets Until/Since only. Validated round-robin single-defect approach fails for multi-defect due to missing f_carry.

### Prior Plan Reference

Plan v33 reached [IMPLEMENTING] with Phases 0-1 [COMPLETED], Phase 2 [PARTIAL]. Forward_F termination proved to be a fundamental open problem: no decreasing measure works because resolved formulas "fall out" of the chain (G(neg psi) entry problem). Key lesson: proving forward_F directly on the multi-defect chain is blocked. BX12 bypasses this by reducing F/P to Until/Since, which has finite-witness proofs via BX8/BX9 axiom unfolding.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Close all 8 sorry sites in RootScopedChain.lean (1413, 1457, 1464, 1517, 1522, 1527, 2196, 2289) or render them unreachable from bx_completeness
- Prove restricted forward/backward Until/Since coherence for dd_bfmcs
- Derive restricted temporal coherence (F/P) via BX12/BX12' bridge
- Achieve `lake build` with zero sorry reachable from bx_completeness

**Non-Goals**:
- Proving forward_F directly on the defect-driven chain (bypassed by BX12)
- Modifying quasimodel infrastructure (sorry-free, untouched)
- Building a HintikkaStepOracle
- Dense completeness (task 68)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Closure alignment: `top U psi` not in subformulaClosure(root) | H | M (40%) | Three options: (1) extend extendedDeferralClosure ~30 LOC; (2) prove unrestricted Until/Since coherence; (3) prove forward_F for deferralClosure formulas directly via self_resolving_fwd_step. Attempt option (2) first as cleanest. |
| Until coherence requires step transfer not provided by chain | H | M (35%) | Use BX8 + F-obligation backward constancy (already proved at line 1204 for rr_fwd_chain, needs analog for defect_fwd_chain). The backward step transfer `(phi U psi) in chain(r+1) AND phi in chain(r) -> (phi U psi) in chain(r)` follows from `F(phi U psi) in chain(r)` via F_obligation_backward. |
| Backward chain F-propagation blocks t < 0 case | H | M (30%) | BX12 reduces to Until/Since; backward chain needs Since coherence which uses P-obligations and h_content (both preserved). The P-analog applies symmetrically. |
| Some sorry sites remain reachable after indirect closure | M | L (20%) | Run lean_verify on dd_countermodel at each phase to track sorry-dependency. Close any remaining reachable sorries individually. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: BX Axiom MCS Helpers and Forward Until Coherence [NOT STARTED]

**Goal**: Prove forward Until/Since coherence for dd_bfmcs: if `(phi U psi) in fam.mcs(t)`, find witness `s >= t` with `psi in fam.mcs(s)` and `phi` guarding `[t, s)`. Close sorry 1527 (`dd_bfmcs_restricted_fuc`).

**Tasks**:
- [ ] Prove `until_elim_mcs`: `(phi U psi) in M -> psi in M OR (phi in M AND F(phi U psi) in M)` using BX9
- [ ] Prove `since_elim_mcs`: symmetric for Since using BX9'
- [ ] Prove `refl_intro_until_mcs`: `psi in M -> (phi U psi) in M` using BX8
- [ ] Prove `refl_intro_since_mcs`: symmetric for Since using BX8'
- [ ] Prove `inductive_until_intro_mcs`: `phi in M AND F(phi U psi) in M -> (phi U psi) in M` using BX8
- [ ] Prove forward Until coherence for a single FMCS chain. Given `(phi U psi) in chain(t)`, apply until_elim at each step. If psi in chain(t), done with s=t. Otherwise phi in chain(t) and F(phi U psi) in chain(t). By F-obligation constancy, F(phi U psi) persists. The chain eventually places (phi U psi) at some later step via the defect resolution mechanism (when phi U psi is in the defect list). At that step, apply until_elim again. Formalize via well-founded induction or direct construction using self_resolving_fwd_step on F(phi U psi).
- [ ] Alternative approach: prove forward Until by constructing a WITNESS sequence. Given (phi U psi) in M, either psi in M (done) or F(phi U psi) in M. Apply self_resolving_fwd_step with target = (phi U psi) to get M' with (phi U psi) in M', F(phi U psi) in M', g_content(M) subset M'. At M' apply until_elim again. This constructs a chain M, M', M'', ... where at each step either psi appears (done) or phi holds and (phi U psi) continues. The guard phi holds at every non-terminal step. The chain terminates because F(psi) in M (by BX10: until_F) and self_resolving_fwd_step puts both the target and its F-obligation in M'. The termination argument: at some point psi must appear because the chain is building MCS elements where (phi U psi) holds but with a strictly smaller `until_defect_count` at each step (from quasimodel Sigma-ordering). Alternatively, use the finite subformula property: the set of formulas in each MCS is determined by their position in the finite closure, and the chain visits new configurations.
- [ ] If the above termination argument is difficult, use the DIRECT approach: prove forward Until on the dd_chain by induction on the Until formula structure, using the existing g_content propagation and BX axioms to show the Until witness exists within finitely many chain steps.
- [ ] Wire the proof through dd_bfmcs families to close `dd_bfmcs_restricted_fuc`
- [ ] Verify `lake build` succeeds

**Timing**: 4 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- add BX axiom MCS helpers, forward Until/Since coherence proof, close sorry 1527

**Verification**:
- `dd_bfmcs_restricted_fuc` compiles without sorry
- `lake build` succeeds

---

### Phase 2: Backward Until/Since Coherence [NOT STARTED]

**Goal**: Prove backward Until/Since coherence: given semantic witnesses (psi at s, phi guarding [t, s)), derive `(phi U psi) in fam.mcs(t)`. Close sorry 1522 (`dd_bfmcs_restricted_buc`).

**Tasks**:
- [ ] Prove `defect_fwd_chain_F_obligation_backward`: F(psi) in chain(m) -> F(psi) in chain(n) for n <= m. Same contrapositive argument as rr_fwd_chain_F_obligation_backward (line 1204): if F(psi) not in chain(n), then G(neg psi) in chain(n) by MCS maximality, neg(psi) in g_content(chain(n)) subset chain(n+1), so G(neg psi) propagates forward, giving F(psi) not in chain(m).
- [ ] Prove backward Until step transfer: `(phi U psi) in chain(r+1) AND phi in chain(r) -> (phi U psi) in chain(r)`. Proof: (phi U psi) in chain(r+1) implies F(phi U psi) in chain(r+1) by phi_in_mcs_imp_F_phi. By F_obligation_backward: F(phi U psi) in chain(r). With phi in chain(r), apply inductive_until_intro_mcs to get (phi U psi) in chain(r).
- [ ] Prove backward Since step transfer: symmetric using BX8' (since introduction) and P-obligation backward constancy on the backward chain.
- [ ] Prove `dd_chain_backward_until`: Given s >= t with psi in chain(s) and phi in chain(r) for all r in [t, s), derive (phi U psi) in chain(t). By backward induction from s to t: at s, psi in chain(s) implies (phi U psi) in chain(s) by refl_intro_until_mcs. At each r in [s-1, ..., t], use the step transfer lemma.
- [ ] Prove `dd_chain_backward_since`: Symmetric for Since on the backward (negative index) portion.
- [ ] Wire through dd_bfmcs families to close `dd_bfmcs_restricted_buc` (sorry 1522)
- [ ] Verify `lake build` succeeds

**Timing**: 3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- add F_obligation_backward for defect chain, backward Until/Since step transfer, close sorry 1522

**Verification**:
- `dd_bfmcs_restricted_buc` compiles without sorry
- `lake build` succeeds

---

### Phase 3: Restricted Temporal Coherence via BX12 Bridge [NOT STARTED]

**Goal**: Derive restricted temporal coherence (forward_F and backward_P) from Until/Since coherence using the BX12/BX12' axioms. Close sorry 1517 (`dd_bfmcs_restricted_tc`). Also close the remaining F/P sorry sites (1413, 1457, 1464, 2196, 2289) either directly or by rendering them unreachable.

**Tasks**:
- [ ] Prove `forward_F_via_BX12`: Given F(psi) in fam.mcs(t) with psi in deferralClosure(root), derive exists s > t with psi in fam.mcs(s). Approach: By BX12, `(top U psi)` in fam.mcs(t). Apply forward Until coherence to get s >= t with psi in fam.mcs(s) and top guarding [t, s). Handle strict inequality: if s = t (psi already present), use self_resolving_fwd_step to construct a witness at t+1 on the underlying chain. Handle closure alignment: `(top U psi)` may not be in subformulaClosure(root). If Phase 1 proved UNRESTRICTED forward Until coherence, this is not an issue. If Phase 1 only proved RESTRICTED coherence, extend extendedDeferralClosure to include `{(top U chi) | F(chi) in deferralClosure(root)}` (approximately 30 LOC in SubformulaClosure.lean).
- [ ] Prove `backward_P_via_BX12prime`: Symmetric using BX12' (`P(phi) -> (top S phi)`) and backward Since coherence.
- [ ] Close `dd_bfmcs_restricted_tc` (sorry 1517): For each family fam in dd_bfmcs, for each psi in deferralClosure(root), forward_F(psi) by forward_F_via_BX12 and backward_P(psi) by backward_P_via_BX12prime.
- [ ] Audit sorry reachability: run `lean_verify` on `dd_countermodel` and `bx_completeness`. Determine which of the remaining sorry sites (1413, 1457, 1464, 2196, 2289) are reachable.
- [ ] For each reachable sorry: close it using the BX12 bridge (forward_F_via_BX12 or backward_P_via_BX12prime applied to the specific chain). For sorries that are unreachable from bx_completeness: add a comment noting they are superseded by the BX12 approach.
- [ ] Specifically for sorry 1413 (rr_fwd_chain_forward_F depth-0): if called by dd_fmcs_forward_F (line 1442) which is called by dd_bfmcs_restricted_tc, and dd_bfmcs_restricted_tc is now proved independently, then sorry 1413 is dead code. Verify and annotate.
- [ ] For sorry 2196 (defect_fwd_chain_forward_F): if not called by any non-sorry theorem, annotate as superseded. Otherwise close via BX12.
- [ ] For sorry 2289 (defect_bwd_chain_backward_P): same analysis.
- [ ] Verify `lake build` succeeds

**Timing**: 3 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- BX12 bridge lemmas, close sorry 1517, audit and close/annotate remaining sorries
- `Theories/Bimodal/Syntax/SubformulaClosure.lean` -- extend extendedDeferralClosure if needed for closure alignment

**Verification**:
- `dd_bfmcs_restricted_tc` compiles without sorry
- `lean_verify` on `dd_countermodel` shows no sorry-dependent axioms
- `lake build` succeeds

---

### Phase 4: Integration and Final Verification [NOT STARTED]

**Goal**: Verify bx_completeness is sorry-free end-to-end. Clean up docstrings and confirm axiom audit.

**Tasks**:
- [ ] Run `lake build` for full compilation
- [ ] Run `lean_verify` on `bx_completeness` to verify axioms are exactly `{propext, Classical.choice, Quot.sound}`
- [ ] Run `lean_verify` on `dd_countermodel` to confirm no sorry-dependency
- [ ] Grep for remaining sorry in all BXCanonical files; ensure none are reachable from bx_completeness
- [ ] If any sorry is reachable, return to Phase 3 and close it
- [ ] Add docstrings to all new theorems explaining the BX12 reduction strategy
- [ ] Verify no new sorry introduced in any other BXCanonical file

**Timing**: 2 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- docstrings, cleanup
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- verify sorry-free path

**Verification**:
- `lake build` succeeds
- `lean_verify` on `bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- `grep -rn sorry Theories/Bimodal/Metalogic/BXCanonical/` shows zero executable sorry in active path
- No sorry-dependent axioms in dd_countermodel or bx_completeness

---

## Testing & Validation

- [ ] `lake build` succeeds at each phase boundary
- [ ] `lean_verify` on `dd_bfmcs_restricted_fuc` after Phase 1 -- no sorry-dependency
- [ ] `lean_verify` on `dd_bfmcs_restricted_buc` after Phase 2 -- no sorry-dependency
- [ ] `lean_verify` on `dd_bfmcs_restricted_tc` after Phase 3 -- no sorry-dependency
- [ ] `lean_verify` on `dd_countermodel` after Phase 3 -- no sorry-dependency
- [ ] `lean_verify` on `bx_completeness` after Phase 4 -- only propext, Classical.choice, Quot.sound
- [ ] All new theorems have docstrings

## Artifacts & Outputs

- `specs/093_complete_bxcanonical_embedding/plans/35_bxcanonical-embedding.md` -- this plan
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- sorry sites closed via BX12 reduction
- `Theories/Bimodal/Syntax/SubformulaClosure.lean` -- potentially extended deferralClosure

## Rollback/Contingency

1. **Full success**: Target outcome. bx_completeness sorry-free. No rollback needed.

2. **Forward Until coherence proved but closure alignment blocks BX12 bridge (~30%)**: Extend extendedDeferralClosure to include BX12-derived formulas, or prove unrestricted forward Until coherence. Estimated additional 2 hours.

3. **Backward Until coherence blocked by F_obligation_backward (~20%)**: Forward direction still succeeds. Sorry count reduced from 8 to 4-5. Spawn focused task for backward coherence.

4. **Forward Until proof blocked by termination (~15%)**: Fall back to quasimodel approach (build HintikkaStepOracle for Until/Since defects). Estimated 4-8 additional hours. The quasimodel infrastructure (2132 LOC) is sorry-free and designed for this.

5. **Full rollback**: `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` restores current state. All Phase 0-1 infrastructure from v33 is preserved.
