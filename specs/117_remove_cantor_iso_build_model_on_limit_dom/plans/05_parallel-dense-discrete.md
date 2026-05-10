# Implementation Plan: Parallel Dense/Discrete Completeness (v2)

- **Task**: 117 - Remove Cantor isomorphism and build countermodel on limit domain
- **Status**: [COMPLETED]
- **Effort**: 20 hours
- **Dependencies**: 107 (completed)
- **Research Inputs**: reports/04_extension-blocker-research.md, reports/05_dense-case-research.md, reports/05_discrete-case-research.md, reports/05_axiom-soundness-research.md, reports/05_critic-review.md, reports/07_succ-archimedean-research.md, reports/08_discrete-alternative-research.md, reports/10_z-shift-research.md, reports/11_gap-lemma-research.md, reports/12_wf-measure-research.md, reports/14_formula-counting-research.md
- **Artifacts**: plans/05_parallel-dense-discrete.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This plan supersedes plan 04 (case-split-completeness). Phases 1-3 of plan 04 are COMPLETED (uniformity axioms, soundness, dense FMCS). Phase 4 is PARTIAL (SuccOrder, PredOrder done; IsSuccArchimedean has sorry). The remaining work splits into two independent parallel tracks: Track A builds the dense completeness path to sorry-free countermodel (BFMCS, coherence, countermodel, case-split bx_completeness with dense branch working and discrete branch using sorry), while Track B attempts to prove IsSuccArchimedean via omega chain structural analysis to fill the discrete sorry. Track A is the priority: it delivers a working bx_completeness theorem. Track B is best-effort.

### Research Integration

Integrates findings from 14+ research reports across 4+ research rounds:
- **Report 04** (extension blocker): Natural inclusion impossible; strict G blocks forward_G at non-domain rationals.
- **Reports 05** (dense/discrete/axiom/critic): Dense case works via F'T + C4 density + Cantor iso; discrete case works via Z-iso if IsSuccArchimedean holds; four uniformity axioms are valid.
- **Reports 07-14** (IsSuccArchimedean research): All 6 WF measures fail. Twin accumulation scenario may be consistent with C0-C5. Formula-counting/pigeonhole does not help. The restricted coherence conditions genuinely require C4/C5 and cannot be shortcut. The proof, if possible, must exploit structural properties of the omega chain construction.

### Prior Plan Reference

Plan 04 had 8 phases. Phases 1-4 were attempted: Phase 1 (axioms) completed in 1.5h as estimated. Phase 2 (soundness) completed in 3h as estimated. Phase 3 (dense FMCS) completed in 3h as estimated. Phase 4 (discrete) partially completed: SuccOrder, PredOrder, succ_pred identity, Z-iso skeleton, discrete_fmcs all done; IsSuccArchimedean blocked with sorry after extensive research. Phases 5-8 (BFMCS, coherence, countermodel, verification) were never started. The key lesson: IsSuccArchimedean is a genuine mathematical difficulty, not an implementation gap. The revised plan decouples it from the dense completeness path.

### Roadmap Alignment

Advances the primary roadmap item: "1 sorry remains on critical path -- density g-value consistency, task 117 will fix". Track A delivers sorry-free dense completeness; Track B attempts sorry elimination for the discrete branch.

## Goals and Non-Goals

**Goals**:
- Build sorry-free `dd_countermodel_chronicle_dense` for the dense case (D = Rat via Cantor iso)
- Restructure `bx_completeness` with case split on F'T vs U(T,bot) in root MCS
- Dense branch of bx_completeness: sorry-free
- Discrete branch of bx_completeness: sorry (explicitly documented, filled if Track B succeeds)
- Attempt IsSuccArchimedean proof via omega chain structural analysis (Track B)
- If Track B succeeds: build sorry-free discrete BFMCS, coherence, and countermodel

**Non-Goals**:
- Guaranteeing IsSuccArchimedean is provable (best-effort)
- Modifying the chronicle construction or counterexample elimination
- Re-doing Phases 1-3 of plan 04 (already completed)
- Changing valid/TaskFrame/ShiftClosed parametric infrastructure

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| BFMCS construction from archived code is incomplete (archived file shows "..." for shifted/rooted/BFMCS) | H | M | Archived code is reference only; reconstruct from the FMCS pattern already proven in dense case + the BFMCS structure in Bundle/TemporalCoherence.lean |
| Restricted coherence proofs (tc/buc/fuc) require careful transport through Cantor iso | H | M | Transport pattern is mechanical: each uses limit_F_resolution/limit_satisfies_c4/c5 on domain, then maps through cantor_iso. Follow the RootScopedChain.lean pattern for structure |
| IsSuccArchimedean is genuinely unprovable (twin accumulation scenario) | M | H | Track A delivers dense completeness independently; the sorry in the discrete branch is explicitly documented and acceptable |
| Case-split consistency lemma might need care around F'T vs U(T,bot) negation | L | L | F'T = neg(U(T,bot)) is definitional; MCS excluded middle gives the disjunction directly |
| Completeness.lean references missing dd_countermodel_chronicle (build currently broken) | M | L | Phase 5 directly addresses this by providing the replacement |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 6 | -- |
| 2 | 2, 7 | 1, 6 |
| 3 | 3, 8 | 2, 7 |
| 4 | 4 | 3 |
| 5 | 5 | 4, 8 |
| 6 | 9 | 5 |

Phases within the same wave can execute in parallel. Track A = Phases 1-5, Track B = Phases 6-8. The two tracks merge at Phase 5 (case-split completeness).

---

### Phase 1: Dense BFMCS Construction [COMPLETED]

**Goal**: Build `cantor_bfmcs_dense : BFMCS Rat` with `modal_forward` and `modal_backward`, using shifted and rooted FMCS variants of `cantor_fmcs_dense`.

**Tasks**:
- [ ] Define `shifted_cantor_fmcs_dense (s : Rat)` -- shifts the MCS assignment by `s`: `mcs t := cantor_fmcs_dense.mcs (t + s)`, with `forward_G`/`backward_H` transported via `add_lt_add_right`
- [ ] Define `rooted_cantor_fmcs_dense (N : Set Formula) (h_N : BoxEquivalent N (cantor_fmcs_dense.mcs s)) (s : Rat)` -- box-restricted variant for modal coherence
- [ ] Prove `rooted_cantor_fmcs_dense_at_s`: the rooted FMCS at `t` equals `cantor_fmcs_dense.mcs (t + s)` (up to box equivalence)
- [ ] Prove `box_stable_in_rooted_cantor_fmcs_dense`: Box(phi) stability across box-equivalent roots
- [ ] Define `cantor_bfmcs_dense : BFMCS Rat` with `modal_forward`/`modal_backward` using the shifted/rooted family and box stability
- [ ] Run `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel`

**Timing**: 2 hours

**Depends on**: none (builds on completed Phase 3 code already in ChronicleToCountermodel.lean)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- add shifted/rooted FMCS, box stability, BFMCS (insert after `cantor_fmcs_dense`, before the Discrete Case section)

**Verification**:
- `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel` succeeds
- `cantor_bfmcs_dense` type-checks with `modal_forward`/`modal_backward` filled (no sorry)

---

### Phase 2: Dense Restricted Coherence [COMPLETED]

**Goal**: Prove the three restricted temporal coherence properties for `cantor_bfmcs_dense`: `restricted_tc`, `restricted_buc`, `restricted_fuc`.

**Tasks**:
- [ ] Prove `cantor_bfmcs_dense_restricted_tc`: F(phi) in `cantor_f_dense(t)` implies exists `s > t` with phi in `cantor_f_dense(s)`. Transport from `limit_F_resolution`: F(phi) in `limit_f(cantor_iso.symm(t))` gives `y` in `limit_dom`; set `s = cantor_iso(y)`. Mirror for P direction using `limit_P_resolution`.
- [ ] Prove `cantor_bfmcs_dense_restricted_buc`: Given phi in `cantor_f_dense(s)` and psi on guard `(t,s)`, prove `(phi U psi)` in `cantor_f_dense(t)`. Contrapositive via `limit_satisfies_c4`: if `neg(phi U psi)` in `limit_f(cantor_iso.symm(t))`, C4 produces `z` between `cantor_iso.symm(t)` and `cantor_iso.symm(s)` with `psi.neg` in `limit_f(z)`. Map `z` through `cantor_iso` to get a contradicting guard point. Mirror for Since direction.
- [ ] Prove `cantor_bfmcs_dense_restricted_fuc`: `(phi U psi)` in `cantor_f_dense(t)` implies exists `s > t` with phi in `cantor_f_dense(s)` and psi on guard. Transport from `limit_satisfies_c5_strong`: exists `y` in `limit_dom` with phi in `limit_f(y)` and psi on guard interval. Since `cantor_iso` is a bijection `limit_dom <-> Rat`, the guard over D = Rat covers ALL rationals between `t` and `cantor_iso(y)`. Mirror for Since.
- [ ] Run `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel`

**Timing**: 2.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- add three restricted coherence proofs after `cantor_bfmcs_dense`

**Verification**:
- All three coherence proofs compile without sorry
- `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel` succeeds

---

### Phase 3: Dense Countermodel [COMPLETED]

**Goal**: Define `dd_countermodel_chronicle_dense` using `cantor_bfmcs_dense` and the restricted parametric representation theorem.

**Tasks**:
- [ ] Define `dd_countermodel_chronicle_dense (A : Set Formula) (h_mcs : SetMaximalConsistent A) (phi : Formula) (h_neg : phi.neg in A) (h_dense : forall x in limit_dom, next_top.neg in limit_f x)`: uses `cantor_bfmcs_dense`, the three restricted coherence proofs, and `fully_restricted_parametric_representation_from_neg_membership` to produce the existential countermodel. The key: `cantor_f_dense_at_zero` ensures `phi.neg in cantor_f_dense(cantor_zero_dense)`, and the representation theorem gives a ShiftClosed TaskFrame on Rat where phi is false at some point.
- [ ] Verify the return type matches what Completeness.lean expects from `dd_countermodel_chronicle` (existential over D, F, TM, Omega, h_sc, tau, h_mem, t, h_not_true)
- [ ] Run `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel`

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- add countermodel construction after coherence proofs

**Verification**:
- `dd_countermodel_chronicle_dense` compiles without sorry
- `lake build` on the module succeeds

---

### Phase 4: Case-Split Completeness [COMPLETED]

**Goal**: Restructure `bx_completeness` in Completeness.lean with a case split on F'T vs U(T,bot), using the dense countermodel for the dense branch and sorry for the discrete branch.

**Tasks**:
- [ ] Add `dd_countermodel_chronicle_dense` to Chronicle namespace exports (if needed for Completeness.lean access)
- [ ] Prove `F'T_propagates_to_all_domain_points`: Given MCS A0 with F'T in A0, derive G(F'T) and H(F'T) from the propagation axioms (neg(U(T,bot)) + discrete_propagate_fwd contrapositive gives G(F'T); similarly for H). Then for all x in limit_dom: x > 0 uses limit_forward_G on G(F'T) from A0; x < 0 uses limit_backward_H on H(F'T) from A0; x = 0 is direct.
- [ ] Prove `next_top_propagates_to_all_domain_points`: Given MCS A0 with U(T,bot) in A0, derive G(U(T,bot)) and H(U(T,bot)) from discrete_propagate_fwd/bwd axioms. Transport via limit_forward_G/backward_H to all domain points.
- [ ] Prove `dense_or_discrete_in_mcs`: For any MCS M, either `next_top.neg in M` (F'T) or `next_top in M` (U(T,bot)). This is just excluded middle on next_top applied via MCS completeness (`SetMaximalConsistent.or_neg_mem`).
- [ ] Define `dd_countermodel_chronicle_discrete_sorry`: a sorry-backed stub with the same type signature as the dense countermodel but for the discrete case. This is the explicit sorry that Track B aims to fill.
- [ ] Restructure `bx_completeness`:
  1. Assume not derivable, get consistency of `{neg(phi)}`
  2. Extend to MCS A0 via Lindenbaum
  3. Case split on `dense_or_discrete_in_mcs A0`
  4. Dense case: apply `F'T_propagates_to_all_domain_points`, invoke `dd_countermodel_chronicle_dense`
  5. Discrete case: apply `next_top_propagates_to_all_domain_points`, invoke `dd_countermodel_chronicle_discrete_sorry`
- [ ] Update module docstrings and axiom audit section to reflect the case-split architecture
- [ ] Run `lake build Bimodal.Metalogic.BXCanonical.Completeness`

**Timing**: 2.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- restructure bx_completeness with case split, add propagation lemmas, add consistency lemma
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- add `dd_countermodel_chronicle_discrete_sorry` stub, update docstrings

**Verification**:
- `lake build Bimodal.Metalogic.BXCanonical.Completeness` succeeds
- `bx_completeness` compiles (with 1 sorry in discrete branch)
- `#print axioms bx_completeness` shows `sorryAx` (from discrete sorry only)

---

### Phase 5: Dense Verification and Documentation [COMPLETED]

**Goal**: Full project build, verify sorry isolation, and update documentation. If Track B (Phases 6-8) has produced a sorry-free IsSuccArchimedean, integrate the discrete countermodel to replace the sorry. Otherwise, document the sorry.

**Tasks**:
- [ ] Run `lake build` (full project rebuild)
- [ ] Run `#print axioms bx_completeness` -- if Track B succeeded, must show NO `sorryAx`; otherwise, document the sole sorry
- [ ] If Track B succeeded: replace `dd_countermodel_chronicle_discrete_sorry` with the real `dd_countermodel_chronicle_discrete` in `bx_completeness`
- [ ] Update axiom audit section in Completeness.lean
- [ ] Update ChronicleToCountermodel.lean module docstring (describe case-split architecture, sorry status)
- [ ] Verify Boneyard files are NOT imported by active modules
- [ ] Run `lake build` after documentation updates

**Timing**: 1.5 hours

**Depends on**: 4, 8 (waits for Track B to complete or give up)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- update axiom audit, possibly integrate discrete countermodel
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- update docstrings

**Verification**:
- Full `lake build` succeeds
- Sorry isolation confirmed: if sorry remains, it traces ONLY to `limitDomSubtype_isSuccArchimedean`
- Documentation accurately reflects sorry status

---

### Phase 6: Omega Chain Structural Analysis [COMPLETED]

**Goal**: Trace through the chronicle construction to understand how counterexamples in a bounded interval between consecutive dom_N elements are enumerated and resolved. Determine whether C4 bridging prevents twin accumulation.

**Tasks**:
- [ ] Read `ChronicleConstruction.lean` omega chain construction: trace how `PointInsertion` works within a bounded interval `(q, r)` where `q, r` are consecutive dom_N elements
- [ ] Analyze the counterexample enumeration: how are counterexamples in `(q, r)` discovered and ordered? Is there a bound on how many get inserted?
- [ ] Examine C4 bridging: when a new point `z` is inserted between `q` and `r`, what constraints does C4 impose on subsequent insertions? Does C4 prevent accumulation from both sides toward an irrational limit?
- [ ] Examine the interplay between succ chain steps and the omega chain: if `succ^[k](q)` inserts points `z1, z2, ...` in `(q, r)`, does the construction guarantee they form a finite chain?
- [ ] Write findings to a handoff file at `specs/117_remove_cantor_iso_build_model_on_limit_dom/handoffs/06_omega-chain-analysis.md`
- [ ] Determine GO/NO-GO for Phase 7: if a proof strategy for IsSuccArchimedean is found, proceed; if the analysis confirms twin accumulation is possible, document the impossibility

**Timing**: 2 hours

**Depends on**: none

**Files to read**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- omega chain, PointInsertion
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- counterexample resolution

**Verification**:
- Handoff file written with clear GO/NO-GO recommendation
- If GO: proof strategy identified with specific lemma sequence

---

### Phase 7: IsSuccArchimedean Implementation (Conditional) [NOT STARTED]

**Goal**: If Phase 6 produced a GO recommendation, implement the proof of `limitDomSubtype_isSuccArchimedean`, replacing the sorry at ChronicleToCountermodel.lean:554.

**Tasks**:
- [ ] Implement the proof strategy identified in Phase 6
- [ ] Replace the `sorry` at line 554 of ChronicleToCountermodel.lean with the actual proof
- [ ] Run `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel`
- [ ] If the proof strategy fails during implementation: write a handoff documenting the failure, mark Phase 7 as BLOCKED, and skip Phase 8

**Timing**: 2.5 hours (if GO), 0 hours (if NO-GO)

**Depends on**: 6

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- replace sorry with proof

**Verification**:
- `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel` succeeds
- `#check @limitDomSubtype_isSuccArchimedean` has no sorryAx dependency

---

### Phase 8: Discrete BFMCS and Countermodel (Conditional) [NOT STARTED]

**Goal**: If Phase 7 succeeded (IsSuccArchimedean proved), build the discrete BFMCS, coherence proofs, and countermodel. This fills the sorry left by Track A's Phase 4.

**Tasks**:
- [ ] Define `shifted_discrete_fmcs`, `rooted_discrete_fmcs` (mirror Phase 1 structure for Int)
- [ ] Prove `box_stable_in_rooted_discrete_fmcs`
- [ ] Define `discrete_bfmcs : BFMCS Int` with `modal_forward`/`modal_backward`
- [ ] Prove `discrete_bfmcs_restricted_tc`: transport from `limit_F_resolution` via `discrete_iso`. Since `discrete_iso` bijects `limit_dom <-> Int`, F-resolution domain witness maps directly to an Int witness.
- [ ] Prove `discrete_bfmcs_restricted_buc`: contrapositive via `limit_satisfies_c4` transported through `discrete_iso`. Key: domain = all of Int via iso, so the guard over D = Int equals the domain-point guard.
- [ ] Prove `discrete_bfmcs_restricted_fuc`: transport from `limit_satisfies_c5_strong` via `discrete_iso`. Key: since domain IS all of Int, `limit_g(x,y)` covers all integers between the two points.
- [ ] Define `dd_countermodel_chronicle_discrete`: uses `discrete_bfmcs`, `fully_restricted_parametric_representation_from_neg_membership`, and `discrete_f_at_zero = A`.
- [ ] Run `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel`

**Timing**: 2.5 hours (if Phase 7 succeeded), 0 hours (if skipped)

**Depends on**: 7

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- add discrete BFMCS, coherence proofs, countermodel

**Verification**:
- `dd_countermodel_chronicle_discrete` compiles without sorry
- `lake build` succeeds

---

### Phase 9: Final Integration and Verification [COMPLETED]

**Goal**: Final integration pass. If Track B completed, replace the discrete sorry in bx_completeness. Run full verification.

**Tasks**:
- [ ] If Phases 7-8 completed: replace `dd_countermodel_chronicle_discrete_sorry` with `dd_countermodel_chronicle_discrete` in `bx_completeness`
- [ ] Run `lake build` (full project rebuild)
- [ ] Run `#print axioms bx_completeness`:
  - If Track B completed: must show NO `sorryAx`
  - If Track B skipped: documents exactly 1 `sorryAx` tracing to `limitDomSubtype_isSuccArchimedean`
- [ ] Run `lean_verify` MCP tool on `Bimodal.Metalogic.BXCanonical.bx_completeness`
- [ ] Update Completeness.lean axiom audit with final state
- [ ] Update ROADMAP.md: mark sorry reduction progress, document IsSuccArchimedean status
- [ ] Clean up any remaining handoff files

**Timing**: 1.5 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- final integration, axiom audit
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- final docstring updates

**Verification**:
- Full `lake build` succeeds
- `#print axioms bx_completeness` matches expected state
- `lean_verify` confirms no unexpected sorry dependencies

---

## Testing and Validation

- [ ] `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel` after Phases 1, 2, 3 (Track A) and 7, 8 (Track B)
- [ ] `lake build Bimodal.Metalogic.BXCanonical.Completeness` after Phase 4
- [ ] `lake build` (full) after Phase 5 and Phase 9
- [ ] `#print axioms bx_completeness` at Phase 5 (with sorry) and Phase 9 (final)
- [ ] `lean_verify` on `Bimodal.Metalogic.BXCanonical.bx_completeness` at Phase 9
- [ ] Verify Boneyard files are NOT imported by active modules

## Artifacts and Outputs

- `plans/05_parallel-dense-discrete.md` (this plan)
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (BFMCS, coherence, countermodels for dense + potentially discrete)
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (case-split restructuring)
- Created: `specs/117_remove_cantor_iso_build_model_on_limit_dom/handoffs/06_omega-chain-analysis.md` (Phase 6 analysis)

## Rollback/Contingency

- Git commits at each phase boundary. Rollback any phase via `git revert`.
- Phases 1-3 (Track A: dense BFMCS, coherence, countermodel) are purely additive -- zero risk to existing code.
- Phase 4 (case-split) modifies Completeness.lean but preserves the existing bx_completeness theorem structure (just wires to the new countermodel).
- Track B (Phases 6-8) is entirely optional. If it fails at any point:
  - Phase 6 NO-GO: Phases 7-8 are skipped entirely. Track A proceeds independently.
  - Phase 7 fails: Phase 8 is skipped. The discrete sorry remains, documented in Phase 5.
  - Phase 8 fails: The discrete sorry remains. Track A's result is still valid.
- Archived code in `Boneyard/DenseChronicle/` preserves the old pathway for reference.
- The `limitDomSubtype_isSuccArchimedean` sorry is safe: it only affects the discrete branch, and `bx_completeness` works for the dense branch regardless.
