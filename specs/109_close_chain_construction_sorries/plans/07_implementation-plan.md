# Implementation Plan: Close Chain Construction Sorries (v7)

- **Task**: 109 - Close chain construction sorries
- **Status**: [NOT STARTED]
- **Effort**: 14 hours
- **Dependencies**: Task 93 (irreflexive semantics switch, completed)
- **Research Inputs**: specs/109_close_chain_construction_sorries/reports/07_team-research.md
- **Artifacts**: plans/07_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the 5 critical-path sorry sites in `RootScopedChain.lean` blocking sorry-free `bx_completeness`. Plan v7 abandons the defect-directed `fwd_chain_of_sigma` / `dd_bfmcs` construction entirely (provably unfixable due to `Classical.choice` opacity in the BX11 fold, confirmed by 50+ rounds of research). Instead, rewire `dd_countermodel` to use the sorry-free `bx_fmcs` construction from `CanonicalModel.lean`, which uses a deterministic schedule + `fwd_succ` without BX11. Prove `restricted_tc` via schedule surjectivity + F-obligation monotonicity contrapositive. Archive dead code to avoid future distractions. Definition of done: `#print axioms bx_completeness` shows no `sorryAx`, or 3 of 5 critical-path sorries closed with backward Until/Since coherence documented for follow-up.

### Research Integration

Team research report (07_team-research.md, 4 teammates): Identified that the codebase has TWO canonical model constructions -- the sorry-free `bx_fmcs` (schedule-based, `CanonicalModel.lean`) and the sorry-laden `dd_bfmcs` (defect-directed, `RootScopedChain.lean`). All prior plans focused on fixing the wrong one. The schedule + F-obligation monotonicity contrapositive proof strategy for `fwd_chain_forward_F` uses only already-proved infrastructure and avoids the `Classical.choice` opacity wall entirely.

### Prior Plan Reference

Plan v6 estimated 18 hours across 5 phases. It pursued a hybrid chain construction replacing `preserving_fwd_step` with round-robin discharge steps. Key lessons: (1) the F-obligation destruction problem at non-target discharge steps was never resolved, (2) all strategies requiring control over `Classical.choice` in `set_lindenbaum` are fundamentally blocked (dead ends 13-36 in ROADMAP), (3) the existing `fwd_chain_of_sigma` infrastructure is a dead end. The critical insight from v7 research is that `bx_fmcs` avoids the problem entirely.

### Roadmap Alignment

- Advances ROADMAP item: "Task 109: Close 23 BXCanonical sorries (5 critical-path + 18 irreflexive-consequence)"
- Clears the `fwd_chain_forward_F -> restricted_tc -> restricted_buc -> restricted_fuc` dependency chain
- Prerequisite for Task 95: `#print axioms` audit on `bx_completeness`
- Updates ROADMAP to reflect the architectural pivot from defect-directed to schedule-based construction

## Goals & Non-Goals

**Goals**:
- Archive the unfixable `fwd_chain_of_sigma` / `dd_bfmcs` construction and related dead code
- Update ROADMAP.md to reflect the schedule-based construction pivot
- Rewire `dd_countermodel` to use `bx_fmcs` from `CanonicalModel.lean`
- Prove `restricted_tc` (F/P resolution) via schedule surjectivity + F-obligation monotonicity contrapositive
- Prove `restricted_fuc` (forward Until/Since coherence) using F-resolution + guard persistence
- Achieve `#print axioms bx_completeness` = `{propext, Classical.choice, Quot.sound, Lean.ofReduceBool, Lean.trustCompiler}` if backward Until/Since is not on the critical path

**Non-Goals**:
- Fixing `fwd_chain_of_sigma` or `preserving_fwd_step` (provably unfixable)
- Closing non-critical-path sorries (Frame.lean `bx_le_refl`, TruthLemma reflexive cases, Realization.lean, SigmaOrdering reflexivity, Construction.lean `refl_intro_until/since_mcs`)
- Changing the BX axiom system
- Dense completeness (task 68) or FMP truth preservation (task 82)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `bx_fmcs` type does not match what `dd_countermodel` expects (BFMCS vs FMCS, sigma_list parameter) | H | M | Phase 2 inspects the exact type signatures before modifying. The `bx_fmcs` produces `FMCS Int`; `dd_countermodel` needs `BFMCS Int`. The existing BFMCS wrapper pattern (shifting + modal equivalence) applies identically. |
| F-obligation monotonicity needs to be reproved for the `bx_fmcs` chain (currently only exists for `fwd_chain_of_sigma`) | M | L | The same proof argument works: `F(chi) not in chain(n)` means `G(neg chi) in chain(n)`, and by `temp_4` + g_content propagation, `G(neg chi)` propagates forward. Straightforward proof. |
| `defect_one_step_preservation` (F(phi) drops implies phi appeared) may not hold for `fwd_succ` | H | M | Need to prove: if `F(phi) in fwd_chain(n)` and `F(phi) not in fwd_chain(n+1)`, then `phi in fwd_chain(n+1)`. Since `fwd_chain(n+1) = fwd_succ(chain(n), schedule(n))`, and `fwd_succ` produces an MCS extending `g_content(chain(n))`, if `F(phi) not in result`, then `G(neg phi) in result`. But `G(neg phi) in result` and `g_content(chain(n)) subset result` need not conflict with `F(phi) in chain(n)`. Alternative: the proof does NOT need `defect_one_step_preservation` -- it uses the dichotomy directly (F persists or drops, and if drops then F is gone forever by monotonicity, but we need phi appeared, not just F(phi) gone). If this step is blocked, fall back to the schedule surjectivity argument alone: F(phi) persists until schedule(m) = phi, at which point `fwd_succ_resolves` gives phi. |
| Backward Until/Since coherence (`restricted_buc`) is on the critical path and cannot be closed | H | H | Same risk as v6. If backward Until requires the step transfer `phi AND F(phi U psi) -> phi U psi` which is not derivable, mark task [PARTIAL] with 3-4 of 5 sorries closed and create follow-up task. |
| Large refactor scope causes regressions | M | M | Build incrementally: define new BFMCS wrapper alongside old one, prove properties, then swap `dd_countermodel` reference. Run `lake build` after each change. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2 |
| 4 | 5 | 3, 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Archive Dead Code and Update ROADMAP [NOT STARTED]

**Goal**: Remove the unfixable `fwd_chain_of_sigma` / `dd_bfmcs` construction and dead code from RootScopedChain.lean. Archive to Boneyard. Update ROADMAP.md to reflect the architectural pivot.

**Tasks**:
- [ ] Create `Theories/Bimodal/Boneyard/DefectDirectedChain/` directory
- [ ] Move the following definitions and proofs from `RootScopedChain.lean` to `Boneyard/DefectDirectedChain/RootScopedChain.lean`: `fwd_chain_of_sigma`, `bwd_chain_of_sigma`, `dd_chain`, `dd_chain_zero`, `dd_chain_mcs`, `preserving_fwd_step`, `preserving_fwd_step_mcs`, `preserving_fwd_step_g_content`, `preserving_fwd_step_F_preserved`, all sigma_fwd/bwd content/h_content lemmas, `active_defects`, `defect_step_choice_early`, `defect_step_choice_early_spec`, `fwd_chain_F_obligation_monotone`, `fwd_chain_F_obligation_backward`, `singleton_defect_resolved`, `fwd_chain_forward_F` (the sorry), `dd_fmcs`, `shifted_dd_fmcs`, `shifted_dd_fmcs_at_s`, `dd_bfmcs`, the old `dd_countermodel`, and the BX11 fold infrastructure (`enriched_fwd_exists`, `resolving_enriched_fwd_exists`, `bx11_earlier`, `bx11_earlier_total`, `discharge_*` definitions, `target_stays_direct_in_fold`)
- [ ] Also archive the defect resolving seed infrastructure at the bottom of the file (`defect_resolving_seed`, `defect_fwd_step`, `defect_bwd_step`, and their lemmas) to `Boneyard/DefectDirectedChain/`
- [ ] Keep in `RootScopedChain.lean` only: `FF_imp_F`, `FF_imp_F_mcs`, `F_mono`, `F_conj_left_mcs`, `F_conj_right_mcs`, `conj_comm_imp`, `F_conj_comm_mcs` (these are general-purpose and may be reused), and add a comment explaining the architectural pivot
- [ ] Update ROADMAP.md: (a) update the "Current Strategy" section to describe the schedule-based approach using `bx_fmcs`, (b) add dead end #37 documenting the defect-directed chain failure, (c) update sorry inventory to reflect archival, (d) update module import graph
- [ ] Run `lake build` to verify the project still compiles (RootScopedChain.lean will have unresolved references -- fix import structure as needed, leaving the coherence theorems and `dd_countermodel` as stubs with `sorry` for now)

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- Remove dead code, keep general lemmas
- `Theories/Bimodal/Boneyard/DefectDirectedChain/RootScopedChain.lean` -- New archive file
- `specs/ROADMAP.md` -- Update strategy, add dead end, update sorry inventory

**Verification**:
- `lake build` succeeds
- Archived code compiles independently or is clearly marked as archived
- ROADMAP.md reflects the new direction

---

### Phase 2: Rewire dd_countermodel to bx_fmcs [NOT STARTED]

**Goal**: Replace `dd_countermodel` to use the sorry-free `bx_fmcs` / `shifted_bx_fmcs` from `CanonicalModel.lean` instead of the archived `dd_bfmcs`. Define a new `bx_bfmcs` (BFMCS wrapper) and new coherence theorem stubs.

**Tasks**:
- [ ] Inspect the `BFMCS` type definition to understand what fields are needed (families of FMCSs with modal equivalence)
- [ ] Define `bx_bfmcs : (M₀ : Set Formula) → SetMaximalConsistent M₀ → BFMCS Int` using the same pattern as the old `dd_bfmcs` but with `shifted_bx_fmcs` instead of `shifted_dd_fmcs`: families are `{ fam | exists N h_N s, box-equiv N M₀ and fam = shifted_bx_fmcs N h_N s }`
- [ ] Define `bx_bfmcs_restricted_tc`, `bx_bfmcs_restricted_buc`, `bx_bfmcs_restricted_fuc` as new theorem stubs (initially `sorry`)
- [ ] Rewrite `dd_countermodel` to use `bx_bfmcs` instead of `dd_bfmcs`. The proof structure is the same: build `sigma_list` from `extendedDeferralClosure`, instantiate `ParametricCanonicalTaskFrame`, call `fully_restricted_parametric_representation_from_neg_membership` with the new coherence proofs
- [ ] Verify the new `dd_countermodel` type-checks with `sorry` stubs for the 3 coherence properties
- [ ] Run `lake build` to verify

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- New BFMCS wrapper, rewritten `dd_countermodel`
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Possibly add helper lemmas

**Verification**:
- `dd_countermodel` type-checks with 3 sorry stubs
- `bx_completeness` compiles (still has `sorryAx` from the 3 stubs)
- `lake build` succeeds

---

### Phase 3: Prove restricted_tc (F/P resolution) [NOT STARTED]

**Goal**: Close the `bx_bfmcs_restricted_tc` sorry by proving temporal coherence for the schedule-based chain. This resolves 3 of the original 5 sorry sites (forward F-resolution, backward-region F-resolution, backward P-resolution).

**Tasks**:
- [ ] Prove `fwd_chain_F_obligation_monotone` for `bx_fmcs`'s `fwd_chain`: if `F(chi) not in fwd_chain(n)`, then `F(chi) not in fwd_chain(m)` for all `m >= n`. Proof: `F(chi) not in chain(n)` means `G(neg chi) in chain(n)` (MCS). By `temp_4`: `G(G(neg chi)) in chain(n)`. So `G(neg chi) in g_content(chain(n)) subset chain(n+1)`. Induct.
- [ ] Prove `fwd_chain_forward_F` for `bx_fmcs`'s `fwd_chain`: if `F(phi) in fwd_chain(n)`, then exists `m > n` with `phi in fwd_chain(m)`. Proof by schedule surjectivity + monotonicity contrapositive:
  1. By `schedule_surjective_above`: exists `m >= n` with `schedule(m) = phi`
  2. Case 1: `F(phi) in fwd_chain(m)`. Then `fwd_chain(m+1) = fwd_succ(chain(m), phi)`. Since `F(phi) in chain(m)`, by `fwd_succ_resolves`: `phi in fwd_chain(m+1)`. Done with witness `m+1`.
  3. Case 2: `F(phi) not in fwd_chain(m)`. By contrapositive of `fwd_chain_F_obligation_monotone`: since `F(phi) in chain(n)` and `F(phi) not in chain(m)`, there exists some step `k` in `(n, m]` where `F(phi)` first disappears. At step `k`, `fwd_chain(k) = fwd_succ(chain(k-1), schedule(k-1))`. Since `F(phi) in chain(k-1)` and `F(phi) not in chain(k)`, and `chain(k)` is an MCS extending `g_content(chain(k-1))`: we need `phi in chain(k)`. This follows because `fwd_succ` produces an MCS, and in that MCS either `F(phi)` or `neg F(phi) = G(neg phi)` holds. If `G(neg phi)` holds but `phi not in chain(k)`, then `neg phi in chain(k)` (MCS), and from `G(neg phi) in chain(k)` we get `neg phi` propagates forward. But we also need `phi` to have been resolved... **Alternative approach**: use only Case 1. Since `schedule_surjective_above` gives infinitely many indices `m` with `schedule(m) = phi`, and `F(phi)` can only be lost (never regained by monotonicity), either `F(phi)` persists forever (then Case 1 applies at the first such `m >= n`) or `F(phi)` is lost at some step (then it was never regained). If `F(phi)` persists forever, then at every `m` with `schedule(m) = phi`, `fwd_succ_resolves` gives `phi in chain(m+1)`.
- [ ] Prove the symmetric `bwd_chain_backward_P`: if `P(phi) in bwd_chain(n)`, exists `m > n` with `phi in bwd_chain(m)`. Same argument using `bwd_pred_resolves`, `schedule_surjective_above`, and backward H-obligation monotonicity.
- [ ] Prove `bx_bfmcs_restricted_tc`: for each family `fam` in `bx_bfmcs`, forward F-resolution and backward P-resolution hold. The family is `shifted_bx_fmcs N h_N s`. For `t - s >= 0`: use `fwd_chain_forward_F`. For `t - s < 0`: F(phi) in the backward region propagates to the origin via g_content reverse propagation (`bwd_chain_reverse_g`), then forward chain resolves it. For backward P-resolution: symmetric using `bwd_chain_backward_P`.
- [ ] Close the sorry in `bx_bfmcs_restricted_tc`
- [ ] Run `lake build` to verify

**Timing**: 4 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- New lemmas: `fwd_chain_F_obligation_monotone`, `fwd_chain_forward_F`, `bwd_chain_P_obligation_monotone`, `bwd_chain_backward_P`
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- Close `bx_bfmcs_restricted_tc`

**Verification**:
- `bx_bfmcs_restricted_tc` compiles without sorry
- `lean_verify` on `bx_bfmcs_restricted_tc` shows no `sorryAx`
- `lake build` succeeds

---

### Phase 4: Prove restricted_fuc (forward Until/Since coherence) [NOT STARTED]

**Goal**: Close `bx_bfmcs_restricted_fuc` by proving forward Until/Since coherence using F-resolution from Phase 3 + guard persistence via BX5/BX9.

**Tasks**:
- [ ] Prove forward Until coherence: if `(phi U psi) in chain(t)`, then exists `s > t` with `psi in chain(s)` and for all `r` in `(t, s)`, `phi in chain(r)`:
  1. By BX10 (`until_F`): `F(psi) in chain(t)`. By Phase 3's `fwd_chain_forward_F`: exists `s > t` with `psi in chain(s)`.
  2. Choose the minimal such `s` via `Nat.find` or well-ordering.
  3. Guard persistence: for `r` in `(t, s)`, show `phi in chain(r)`:
     - By BX5 (`self_accum_until`): `(phi U psi) in chain(t)` implies `((phi and (phi U psi)) U psi) in chain(t)`.
     - By BX9 (`until_elim`): `(phi U psi) -> phi v psi`. At any point where `psi not in chain(r)`, `phi U psi in chain(r)` forces `phi in chain(r)`.
     - Need to show `phi U psi` persists from `t` to `s-1`. Use g_content propagation: if `G(phi U psi) in chain(t)`, it propagates. If not, use BX10 to get `F(psi)` and the schedule argument. The key insight: at each step `r < s` where `psi not in chain(r)`, by minimality of `s`, and since `phi U psi in chain(r)` implies `phi v psi in chain(r)` (BX9), if `psi not in chain(r)` then `phi in chain(r)`.
     - The remaining piece: show `phi U psi in chain(r)` for all `r` in `(t, s)`. This requires Until propagation through the chain. Use strong induction: at step `r`, if `phi U psi in chain(r)` and `psi not in chain(r+1)`, then we need `phi U psi in chain(r+1)`. Since `g_content(chain(r)) subset chain(r+1)`, if `G(phi U psi) in chain(r)`, done. Use BX4: `phi U psi -> G(P(phi U psi))` and the chain connectivity.
- [ ] Build helper lemma `until_guard_persistence`: by strong induction on `s - r`, show `phi in chain(r)` for all `r` in `(t, s)`.
- [ ] Close forward Since coherence symmetrically using BX5', BX9', BX10' and backward chain P-resolution.
- [ ] Close the sorry in `bx_bfmcs_restricted_fuc`
- [ ] Run `lake build` to verify

**Timing**: 3 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Until guard persistence lemma
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- Close `bx_bfmcs_restricted_fuc`

**Verification**:
- `bx_bfmcs_restricted_fuc` compiles without sorry
- `lean_verify` on `bx_bfmcs_restricted_fuc` shows no `sorryAx`
- `lake build` succeeds

---

### Phase 5: Backward Until/Since Coherence and Final Audit [NOT STARTED]

**Goal**: Attempt to close `bx_bfmcs_restricted_buc` (backward Until/Since coherence). Run `#print axioms` audit. Document results.

**Tasks**:
- [ ] Analyze backward Until coherence: if `(phi U psi) in chain(t)`, need witnesses BEFORE `t`. This is the backward direction -- given semantic witnesses at past points, derive `phi U psi` syntactically.
- [ ] Investigate whether BX12 (`F(phi) -> top U phi`) combined with the quasimodel infrastructure can provide backward Until introduction. BX12 gives `top U psi` from `F(psi)`, which is a forward Until formula. Backward Until requires `exists s < t, psi in chain(s) and guard phi on (s, t)`.
- [ ] If backward Until/Since coherence is provable within time budget: close the sorry.
- [ ] If backward Until/Since coherence is blocked (requires step transfer `phi AND F(phi U psi) -> phi U psi` which is not derivable from BX):
  - Document the precise obstruction
  - Verify whether `restricted_buc` is actually on the critical path for `bx_completeness` (check if `fully_restricted_parametric_representation_from_neg_membership` requires all 3 coherence properties)
  - If on critical path: mark task [PARTIAL], create follow-up task
  - If NOT on critical path: close without `restricted_buc`
- [ ] Run `#print axioms Bimodal.Metalogic.BXCanonical.bx_completeness` via `lean_run_code`
- [ ] Run `#print axioms Bimodal.Metalogic.BXCanonical.dd_countermodel` via `lean_run_code`
- [ ] Verify output matches target: `{propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound}` (no `sorryAx`)
- [ ] Run full `lake build` to confirm no regressions
- [ ] Update sorry counts in ROADMAP.md and code comments

**Timing**: 3 hours

**Depends on**: 3, 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- Possibly close `bx_bfmcs_restricted_buc`
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- Update axiom audit comments
- `specs/ROADMAP.md` -- Update sorry inventory with final counts

**Verification**:
- `#print axioms bx_completeness` shows target axiom set (no `sorryAx`)
- `lake build` succeeds with no sorry on the critical path
- All phase outcomes documented

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] `lean_verify` on each closed sorry confirms no `sorryAx` leaks
- [ ] `#print axioms bx_completeness` checked at Phase 5
- [ ] Grep for `sorry` in `RootScopedChain.lean` shows monotonic decrease across phases
- [ ] `bx_bfmcs_restricted_tc` is fully sorry-free after Phase 3
- [ ] `bx_bfmcs_restricted_fuc` is sorry-free after Phase 4
- [ ] Archived code in `Boneyard/DefectDirectedChain/` does not break active imports

## Artifacts & Outputs

- `specs/109_close_chain_construction_sorries/plans/07_implementation-plan.md` (this file)
- Modified source files:
  - `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` (primary -- rewritten)
  - `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` (new lemmas)
  - `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (axiom audit update)
  - `specs/ROADMAP.md` (strategy and sorry inventory update)
- New archived file:
  - `Theories/Bimodal/Boneyard/DefectDirectedChain/RootScopedChain.lean`
- Potentially new follow-up task for backward Until/Since coherence if not closed
- Implementation summary upon completion

## Rollback/Contingency

- Each phase is independently committable; rollback to previous phase's commit if a phase fails.
- **Phase 1 fallback**: If archival causes import chain issues, keep dead code in-place but clearly marked with `-- ARCHIVED: do not use` comments rather than moving files.
- **Phase 2 fallback**: If `bx_bfmcs` type does not match what `fully_restricted_parametric_representation_from_neg_membership` expects, inspect the exact signature and adapt. The BFMCS wrapper pattern is mechanical.
- **Phase 3 fallback**: If the simple "F persists until schedule visit, then fwd_succ_resolves" argument has a gap (e.g., Case 2 requires `defect_one_step_preservation` which may not hold), try: (a) prove the weaker statement that F(phi) persists to the next schedule visit (only needs monotonicity + surjectivity), then `fwd_succ_resolves` handles it directly in Case 1 -- Case 2 is impossible because monotonicity means F never re-enters; (b) if that also fails, use `discharge_single_step` as a side-argument (not in the chain, but as proof that phi must appear).
- **Phase 4 fallback**: If Until guard persistence is blocked by `phi U psi` not propagating through Lindenbaum steps, try: (a) use BX4 + BX5 combined to show `G(P(phi U psi))` persists and pulls `phi U psi` forward, (b) use a direct counting argument on steps where `psi not in chain(r)`.
- **Phase 5 fallback**: If backward Until/Since remains open, mark task [PARTIAL] with 4 of 5 sorries closed, create a follow-up task targeting semantic completeness (Goldblatt/GHR style) for the backward Until case specifically.
- If any phase stalls beyond 1.5x estimated time, create a handoff document and mark [PARTIAL] for next session.
