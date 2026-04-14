# Implementation Plan: Close BXCanonical Embedding (v13 -- Ordered Defect-Discharge Chain)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [IN PROGRESS]
- **Effort**: 50 hours
- **Dependencies**: None (tasks 90, 92, 98, 101, 102 already completed)
- **Research Inputs**: reports/13_long-term-solution.md
- **Artifacts**: plans/13_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

After 12 rounds of research identifying dead ends (F-carry inconsistency, identity tail F-failure, quasimodel BXPoint-to-Int bridge impossibility), Round 13 identifies the mathematically correct solution: replace the scheduling chain `int_chain` with a finite ordered defect-discharge chain that resolves ALL temporal defects within `extendedDeferralClosure(root)`, one at a time, in witness-earliest-first order, while selectively protecting unresolved F-formulas in the seed. The key breakthrough is the **Ordered Seed Consistency Theorem**: if `F(psi_1 /\ F(psi_2)) in M`, then `{psi_1, F(psi_2)} union g_content(M)` is consistent. BX11 (temporal linearity) provides the witness ordering. This plan creates two new Lean modules (`OrderedSeedConsistency.lean`, `RootScopedChain.lean`) and modifies `CanonicalModel.lean` to close all 6 sorry sites at lines 518, 525, 614, 619, 649, 655. Definition of done: `lake build` succeeds with zero sorry on the active completeness path, and `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`.

### Research Integration

Report 13 provides the complete mathematical architecture:

1. **Ordered Seed Consistency Theorem** (Section 2.1): Proves `{psi_j} union g_content(M) union {F(psi_k) | k != j}` is consistent when psi_j has the earliest witness (via BX11). This is the novel mathematics that breaks the 12-round impasse.

2. **F-Defect Monotonicity** (Section 2.3): F-defects strictly decrease at each chain step. The resolved defect vanishes, protected F-formulas survive, and no new F-defects enter (because G(neg(alpha)) propagates through g_content).

3. **Until-Enriched Seed** (Section 2.4, revised): The seed must also carry defective Until formulas from Sigma for step transfer. The extended consistency argument (Section 2.5, lines 517-539) shows that BX11 iterated over all F-witnesses and Until-witnesses gives a conjunction in M from which the full seed consistency follows.

4. **Step Transfer for Backward Until** (Section 2.5): Required for `backward_until_from_step`. The chain carries Until formulas in the seed, so `(phi U psi) in chain(r+1)` and `phi in chain(r)` gives `(phi U psi) in chain(r)` because the Until formula propagates through the seed inclusion.

5. **How all 6 sorries close** (Section 2.5): forward_F by defect discharge + identity tail; backward_P symmetrically; backward Until/Since via step transfer; forward Until/Since via defect discharge witnessing the guard.

### Prior Plan Reference

Plan v11 (4 phases, 14 hours) attempted a QuasimodelChain-to-FMCS adapter leveraging Hintikka chain infrastructure. It was blocked during implementation by three obstacles: (a) the BXPoint-to-Int bridge is impossible for Hintikka points with no g_content relationship to the scheduling chain; (b) restricted G-persistence through quasimodel chains is more nuanced than anticipated; (c) the identity tail cannot witness F-eventualities because F is strict future. The new plan avoids all three by building MCS chains directly with ordered defect discharge, never routing through Hintikka/quasimodel infrastructure. Effort calibration from v11: 14 hours was optimistic for a fundamentally blocked approach. This plan estimates 50 hours for novel mathematics (OrderedSeedConsistency) plus careful chain engineering.

### Roadmap Alignment

- Closes the sole remaining active-path sorry blocking `bx_completeness` at Completeness.lean:154
- Advances roadmap item: "TaskModel embedding (final step)" from OPEN to DONE
- Once complete, `completeness_over_Int` becomes sorry-free via BXCanonical
- Unblocks task 95 (`#print axioms` audit on `bx_completeness`)

## Goals & Non-Goals

**Goals**:
- Prove the Ordered Seed Consistency Theorem (`ordered_seed_consistent`) using BX11 temporal linearity
- Prove F-Defect Monotonicity (`f_defect_monotonicity`) for chain termination
- Build a root-scoped forward defect-discharge chain that resolves all F-defects and Until-defects in `extendedDeferralClosure(root)`
- Build a symmetric backward chain for P-defects and Since-defects
- Assemble into an Int-indexed FMCS with identity tails
- Prove step transfer for backward Until/Since coherence
- Close all 6 sorry sites in CanonicalModel.lean (lines 518, 525, 614, 619, 649, 655)
- Achieve `lake build` with zero active-path sorry
- Verify `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`

**Non-Goals**:
- Modifying the existing scheduling chain (`int_chain`, `fwd_succ`) -- the new chain is separate
- Closing dead-code sorry sites (unrestricted coherence at lines 597-619)
- Modifying quasimodel or Hintikka infrastructure
- Dense time completeness (separate task)
- Proving unrestricted G-persistence (not needed; restricted coherence suffices)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Ordered Seed Consistency proof is harder in Lean than on paper: the generalized temporal K step (from `L_g derives neg(F(psi_2))` to `G(neg(F(psi_2)))`) requires careful formalization of the finite conjunction argument | H | M (30%) | The existing `forward_temporal_witness_seed_consistent` in WitnessSeed.lean already does the generalized temporal K pattern. Reuse its proof structure. If stuck, decompose into intermediate lemma about finite g_content derivations. |
| Until-enriched seed consistency is not guaranteed: adding defective Until formulas and their F-carry to the resolving seed may introduce inconsistency in edge cases beyond the BX11 argument | H | M (35%) | Research report Section 2.5 (lines 517-539) provides the extended argument via iterated BX11. If the general case is too hard, restrict Until-carry to formulas whose witnesses come later than the resolving target (same ordered-consistency pattern). Fallback: separate Until-only chain phase that runs after F-defects are fully discharged. |
| Step transfer for backward Until requires chain(r+1) to contain Until formulas from chain(r), but the seed enrichment analysis (report lines 280-299) shows `{target} union chain(r)` is inconsistent | H | M (25%) | The seed includes Until formulas from Sigma intersected with chain(r), NOT all of chain(r). These specific Until formulas plus g_content(M) plus F-carry is a carefully controlled subset. The consistency proof extends ordered seed consistency to handle the Until formulas as "dominated" by their F(beta) witnesses (BX10). |
| BX11 iteration over m F-defects requires O(m^2) case splits, which may cause proof term blowup | M | L (15%) | Use well-founded recursion on defect count (already bounded by `Sigma.card` via `sigma_defect_count_bounded`). The BX11 iteration can use a `List`-based fold rather than nested case analysis. |
| Identity tail forward_F depends on complete defect discharge (all F-defects resolved), which requires proving a global invariant over the entire chain | M | M (20%) | The defect count is a natural number bounded by `Sigma.card` and strictly decreasing. Well-founded recursion on `Nat` gives termination. The "no defects" property at the final MCS follows directly from the recursion's base case. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

### Phase 1: Ordered Seed Consistency [COMPLETED]

**Goal**: Prove the Ordered Seed Consistency Theorem and F-Defect Monotonicity in a new module `OrderedSeedConsistency.lean`.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/BXCanonical/OrderedSeedConsistency.lean`
- [ ] Define `ordered_resolving_seed`: `{psi_j} union g_content(M) union {F(psi_k) | k in defects, k != j}`
- [ ] Prove `ordered_seed_consistent`: If M is MCS, F(psi_j) in M, and for all k != j either `F(psi_j /\ F(psi_k)) in M` (psi_j witness is earliest), then `ordered_resolving_seed` is consistent
  - Proof strategy: Assume for contradiction the seed derives bot. By deduction theorem, `{psi_j} union g_content(M) derives neg(F(psi_k))` for some k, i.e., `derives G(neg(psi_k))`. By generalized temporal K (reusing pattern from `forward_temporal_witness_seed_consistent`): `G(psi_j -> G(neg(psi_k))) in M`. Then `G(neg(psi_j /\ F(psi_k))) in M`. But `F(psi_j /\ F(psi_k)) in M`. Contradiction with MCS consistency.
- [ ] Prove `find_earliest_witness`: Given a finite set of F-defects in an MCS, use BX11 to find one whose witness comes earliest (or coincides)
  - BX11: `F(A) /\ F(B) -> F(A /\ B) \/ F(A /\ F(B)) \/ F(F(A) /\ B)`
  - Iterate over defect list pairwise, tracking the "earliest" candidate
  - Result: `F(psi_j /\ (/\_k F(psi_k))) in M` for some j
- [ ] Prove `f_defect_monotonicity`: If M' extends the ordered resolving seed for psi_j, then F-defects in Sigma at M' is a strict subset of F-defects at M
  - No new F-defects: if F(alpha) not in M, then G(neg(alpha)) in M, so by temp_4 G(G(neg(alpha))) in M, so G(neg(alpha)) in g_content(M) subset M', so neg(F(alpha)) in M'
  - Resolved defect gone: psi_j in M' from seed, so F(psi_j) defect is resolved
- [ ] Prove `extended_ordered_seed_consistent`: Version that also includes defective Until formulas `{(phi U psi) in Sigma | (phi U psi) in M, psi not in M}` in the seed, using BX10 (`(phi U psi) -> F(psi)`) to subsume Until-defect witnesses under the F-ordering argument
- [ ] Ensure `lake build` succeeds with the new module (no downstream changes yet)

**Timing**: 15 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/OrderedSeedConsistency.lean` -- new file (~200 lines)

**Verification**:
- `lake build Bimodal.Metalogic.BXCanonical.OrderedSeedConsistency` succeeds
- All theorem signatures match what RootScopedChain.lean will need
- The `ordered_seed_consistent` proof has no sorry

---

### Phase 2: Root-Scoped Defect-Discharge Chain (Forward) [IN PROGRESS]

**Goal**: Build the forward defect-discharge chain: a finite sequence of MCS that resolves all F-defects and Until-defects in `extendedDeferralClosure(root)`, plus an identity tail.

**Blocker**: Round-robin enriched chain cannot prove `forward_F` — see `summaries/13_bxcanonical-embedding-summary.md` for full analysis. Required restructuring: replace `rr_fwd_chain` with finite ordered defect-discharge chain + identity tail.

**RootScopedChain.lean file map** (879 lines):
- Lines 1-448: Library lemmas (FF_imp_F, F_mono, BX11 fold, enriched step) — **PROVED**, keep
- Lines 449-652: Round-robin chain + Int assembly + g_content/box_stable — **PROVED**, but forward_F unprovable
- Lines 654-684: FMCS/BFMCS structure defs — **PROVED**
- Lines 686-770: `rr_fwd_chain_forward_F` — **SORRY, KEY BLOCKER**
- Lines 772-847: Downstream sorries (forward_F, backward_P, restricted coherence) — **SORRY**
- Lines 849-879: `dd_countermodel` — uses sorry-dependent theorems

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean`
- [ ] Define `fwd_defect_count`: count of combined F-defects and Until-defects at an MCS relative to `extendedDeferralClosure(root)` (reuse/extend `sigma_defect_count` from DefectChain.lean)
- [ ] Define `fwd_discharge_step`: given MCS w with defects, find earliest F-witness via `find_earliest_witness`, build ordered resolving seed (including g_content, F-carry protection, Until-carry), Lindenbaum-extend to MCS w'
- [ ] Prove `fwd_discharge_step_defects_decrease`: `fwd_defect_count w' < fwd_defect_count w` (from `f_defect_monotonicity`)
- [ ] Define `fwd_discharge_chain`: well-founded recursion on defect count producing a `List BXPoint` (or `Fin n -> Set Formula` with MCS proofs)
- [ ] Prove `fwd_chain_terminal_defect_free`: the last MCS in the chain has zero F-defects and zero Until-defects in `extendedDeferralClosure(root)`
- [ ] Prove `fwd_chain_g_content`: `g_content(chain[i]) subset chain[i+1]` for all i in the chain (from seed construction)
- [ ] Prove `fwd_chain_until_carry`: defective Until formulas from chain[i] are in chain[i+1] (from seed enrichment)
- [ ] Define `fwd_identity_tail`: extend the finite chain to `Nat -> Set Formula` by repeating the terminal MCS for all indices beyond the chain length
- [ ] Prove `fwd_identity_tail_g_content`: g_content propagation holds at the tail boundary and within the tail (trivial: MCS is constant, G(phi) -> phi by temp_t)

**Timing**: 12 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- extend (~300 lines added)

**Verification**:
- `lake build Bimodal.Metalogic.BXCanonical.RootScopedChain` succeeds
- Chain has no sorry
- The chain length is bounded by `(extendedDeferralClosure root).card`

**Implementation strategy (updated 2026-04-14)**:

Two possible approaches for the defect-discharge chain:

**Approach A (Preferred): Modify enriched_fwd_step to guarantee target resolution**.
Change the step to pick the BX11-earliest defect as target and use `enriched_resolving_seed_consistent` so that the target is DIRECTLY in the Lindenbaum seed (not via .choose disjunction). Keep the existing round-robin scheduling but at each resolving step, always resolve the BX11-earliest. The key change: instead of `enriched_fwd_exists` (which gives `target ∈ M' ∨ F(target) ∈ M'`), use `enriched_resolving_seed_consistent` (which gives `target ∈ M'` guaranteed via seed inclusion).

**Approach B (Fallback): Build a separate finite chain**.
Define `fwd_discharge_chain` independently via well-founded recursion on `|{φ ∈ sigma_list | F(φ) ∈ M, φ ∉ M}|`. After all defects resolved, extend with identity tail. Replace `rr_fwd_chain` in `dd_chain`.

**If returning from interruption**: Read RootScopedChain.lean lines 686-770 to see if `rr_fwd_chain_forward_F` is still sorry. If so, the restructuring has not yet been completed. The agent launched in session sess_1776180711_c675a9 may have made partial progress — check git log for commits after `ad0aed4f8`.

---

### Phase 3: Backward Chain + Int-Indexed Assembly + FMCS Properties [NOT STARTED]

**Goal**: Build the backward chain (symmetric to forward), assemble both into an Int-indexed FMCS, and prove all FMCS coherence properties (forward_G, forward_F, backward_H, backward_P, step transfer).

**Tasks**:
- [ ] Define `bwd_discharge_step`: symmetric to forward using h_content, P-formulas, Since-defects, BX11' (past linearity)
- [ ] Define `bwd_discharge_chain`: well-founded recursion on past defect count
- [ ] Prove backward chain properties (h_content propagation, P-carry, Since-carry) -- symmetric to Phase 2 forward proofs
- [ ] Define `root_scoped_int_chain`: Int-indexed function assembling backward chain (negative indices), M_0 (index 0), forward chain (positive indices), identity tails
  ```
  chain(t) = bwd_chain(-t)   for t < 0
  chain(0) = M_0
  chain(t) = fwd_chain(t)    for 0 < t <= N_fwd
  chain(t) = fwd_terminal     for t > N_fwd
  ```
  (symmetric for negative direction)
- [ ] Define `root_scoped_fmcs`: FMCS structure from `root_scoped_int_chain` with MCS proof at each index
- [ ] Prove `root_scoped_fmcs_forward_G`: from g_content propagation at each chain step + identity tail
- [ ] Prove `root_scoped_fmcs_backward_H`: symmetric from h_content propagation
- [ ] Prove `root_scoped_fmcs_forward_F`: from defect discharge (F(psi) in chain(t) implies either psi resolved at some step s > t in the discharge chain, or t is in identity tail where defect-free means psi in chain(t+1))
- [ ] Prove `root_scoped_fmcs_backward_P`: symmetric
- [ ] Prove `root_scoped_fmcs_step_transfer_until`: `(phi U psi) in chain(r+1)` and `phi in chain(r)` implies `(phi U psi) in chain(r)` -- from Until-carry in seed (within finite chain) and trivial for identity tail
- [ ] Prove `root_scoped_fmcs_step_transfer_since`: symmetric for backward direction

**Timing**: 12 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- extend with backward chain, assembly, FMCS proofs (~200 additional lines)

**Verification**:
- `lake build` succeeds
- `root_scoped_fmcs_forward_F` and `root_scoped_fmcs_backward_P` have no sorry
- Step transfer properties have no sorry
- All FMCS coherence lemmas are stated and proved

---

### Phase 4: Wire into BFMCS and Close Sorry Sites [NOT STARTED]

**Goal**: Construct a new BFMCS using root-scoped FMCS families (one per modal class), and close all 6 sorry sites in CanonicalModel.lean.

**Tasks**:
- [ ] Define `root_scoped_bfmcs` (or modify `bx_bfmcs`): for each MCS N modal-accessible from M_0, use `root_scoped_fmcs N h_N root` as the family (shifted by parameter s for alignment at evaluation time)
- [ ] Prove `bx_fmcs_forward_F` (line 518): delegate to `root_scoped_fmcs_forward_F` via the new chain construction
  - The existing `bx_fmcs` uses `int_chain` which cannot prove this. Two options:
    (a) Replace `bx_fmcs` with `root_scoped_fmcs` (breaking change, may affect other consumers)
    (b) Add a separate `bx_fmcs_v2` using root-scoped chain and prove `bx_fmcs_forward_F` for it, then update `bx_bfmcs` to use `bx_fmcs_v2`
  - Option (b) is safer; existing `int_chain` infrastructure stays intact
- [ ] Prove `bx_fmcs_backward_P` (line 525): symmetric delegation
- [ ] Prove `bx_bfmcs_buc` / `bx_bfmcs_restricted_buc` (lines 614, 649): use `backward_until_from_step` with `root_scoped_fmcs_step_transfer_until`
- [ ] Prove `bx_bfmcs_fuc` / `bx_bfmcs_restricted_fuc` (lines 619, 655): use forward defect discharge -- for (phi U psi) in chain(t), BX9 gives phi or psi; if psi, done; if phi (defect), the chain discharges it within bounded steps
- [ ] Update `bx_bfmcs_restricted_tc` to use the new forward_F/backward_P proofs
- [ ] Verify modal coherence (modal_forward, modal_backward) still holds with root-scoped families

**Timing**: 8 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- replace sorry sites with proofs, possibly add `bx_fmcs_v2` (~150 lines modified/added)

**Verification**:
- All 6 sorry sites are closed
- `lake build` succeeds with no sorry on active path
- `bx_countermodel` still compiles and works
- `bx_completeness` is sorry-free

---

### Phase 5: Verification and Cleanup [NOT STARTED]

**Goal**: Full verification that the completeness theorem is sorry-free, axiom audit, and code cleanup.

**Tasks**:
- [ ] Run `lake build` from clean state
- [ ] Run `#print axioms bx_completeness` and verify only `propext`, `Classical.choice`, `Quot.sound`
- [ ] Run `#print axioms completeness_over_Int` to verify it is also sorry-free
- [ ] Add module documentation to `OrderedSeedConsistency.lean` and `RootScopedChain.lean` (docstrings, section headers, references to Burgess 1984 and Goldblatt 1992)
- [ ] Clean up any dead code in `CanonicalModel.lean` (mark dead-code sorry sites clearly, or remove if truly unreachable)
- [ ] Update `CanonicalChain.lean` imports if new modules are added
- [ ] Verify no regressions in test suite

**Timing**: 3 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/OrderedSeedConsistency.lean` -- docstrings
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- docstrings
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- dead code cleanup

**Verification**:
- `lake build` succeeds
- `#print axioms bx_completeness` clean
- All modules have proper documentation headers

## Testing & Validation

- [ ] `lake build` succeeds with zero errors
- [ ] `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- [ ] `#print axioms completeness_over_Int` is sorry-free
- [ ] All 6 sorry lines (518, 525, 614, 619, 649, 655) in CanonicalModel.lean are replaced with proofs
- [ ] No new sorry introduced in any file
- [ ] `OrderedSeedConsistency.lean` and `RootScopedChain.lean` compile independently
- [ ] `bx_countermodel` theorem still works end-to-end

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/OrderedSeedConsistency.lean` -- new module (~200 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- new module (~500 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- modified (~150 lines changed)
- `specs/093_complete_bxcanonical_embedding/plans/13_bxcanonical-embedding.md` -- this plan

## Rollback/Contingency

The new modules (`OrderedSeedConsistency.lean`, `RootScopedChain.lean`) are additive -- they do not modify existing infrastructure. If the approach fails:

1. **Partial failure (one sorry remains)**: Keep proven lemmas, mark the remaining sorry with a detailed obstacle analysis for the next research round.

2. **Ordered Seed Consistency fails**: The theorem is the foundation. If the Lean proof diverges from the paper proof (e.g., the generalized temporal K step requires infrastructure not yet available), create a focused sub-task for the specific missing lemma.

3. **Step transfer fails**: If Until-enriched seed consistency cannot be proved, fall back to a two-phase chain: first discharge all F-defects (Phase A), then in a second pass discharge all Until-defects with the step-transfer property guaranteed by the defect-free F state.

4. **Full rollback**: Delete `OrderedSeedConsistency.lean` and `RootScopedChain.lean`, revert CanonicalModel.lean to HEAD. The existing sorry sites remain as they were.

## Implementation Log

### 2026-04-14 (sess_1776132289_bbf044): Phase 1 + partial Phase 2
- OrderedSeedConsistency.lean: all theorems proved, no sorry
- RootScopedChain.lean: library + round-robin chain + BFMCS proved; 6 sorries remain
- Commit: `ad0aed4f8`

### 2026-04-14 (sess_1776180711_c675a9): Analysis + Phase 2 restructuring
- Established that round-robin chain CANNOT prove forward_F (see summary for proof)
- Launched agent to restructure as ordered defect-discharge chain

## How to Resume

1. Check `git log --oneline -5` for commits after `ad0aed4f8`
2. `grep -n sorry RootScopedChain.lean` — if `rr_fwd_chain_forward_F` still sorry, restructuring incomplete
3. Read `summaries/13_bxcanonical-embedding-summary.md` for full analysis of the blocker
4. **What to keep**: BX11 fold library (lines 1-448), BFMCS structure (dd_bfmcs, modal_forward/backward)
5. **What to replace**: forward chain (`rr_fwd_chain`) and backward chain (`rr_bwd_chain`)
6. **How**: Define `discharge_fwd_step` using `enriched_resolving_seed_consistent` (target directly in seed, not via disjunction). Well-founded recursion on defect count. Identity tail after all defects resolved.
7. **Key theorems**: `enriched_resolving_seed_consistent`, `temp_linearity_mcs`, `no_new_f_defects`, `forward_temporal_witness_seed_consistent`
