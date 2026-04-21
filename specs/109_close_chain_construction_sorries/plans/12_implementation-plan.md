# Implementation Plan: Close Chain Construction Sorries (v8)

- **Task**: 109 - Close chain construction sorries
- **Status**: [NOT STARTED]
- **Effort**: 55 hours
- **Dependencies**: Task 93 (irreflexive semantics switch, completed)
- **Research Inputs**: specs/109_close_chain_construction_sorries/reports/11_team-research.md, specs/109_close_chain_construction_sorries/reports/10_reflexive-until-evaluation.md
- **Artifacts**: plans/12_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Two-phase strategy to achieve sorry-free completeness. Phase 1 completes reflexive completeness on the `until` branch by closing the 5 remaining sorry sites in `RootScopedChain.lean` (the only file with sorries on the critical path -- all other BXCanonical files are sorry-free). Phase 2 derives irreflexive completeness separately, using the B1 convention (irreflexive G/H with reflexive U/S) and reusing the shared infrastructure. The `until` branch is the correct working branch; its semantics are fully reflexive (G: <=, H: <=, U: s >= t, S: s <= t) with 37 axioms including BX1 (G(phi) -> phi) and BX8 (psi -> phi U psi).

### Research Integration

Team research report (11_team-research.md, 4 teammates) confirmed:
- The `until` branch has exactly 5 sorry sites, all in `RootScopedChain.lean` lines 1111, 1138, 1145, 1153, 1160
- All other BXCanonical files are sorry-free: OrderedSeedConsistency, Frame, CanonicalModel, TruthLemma, Completeness, Soundness, TemporalDerived
- No conservative extension exists for the Until/Since language between reflexive and irreflexive temporal logic (Teammate B, literature survey)
- 130/166 files are identical between `until` and `irr_until` branches; merge is not recommended (Teammate C)
- Mathematical arguments for all 5 sorries are understood; the gap is formalization, not conceptual breakthrough

Report 10 (reflexive-until-evaluation.md) analyzed the B1 convention for Phase 2:
- B1 (reflexive U/S with irreflexive G/H) preserves BX8 and BX9, loses only BX10
- BX10' (`(phi U psi) -> psi v F(psi)`) is a sound replacement
- Enriched-seed chain with F-obligation carry provides F-resolution under irreflexive G

### Prior Plan Reference

Plan v7 (07_implementation-plan.md) estimated 14 hours across 5 phases using a schedule-based `bx_fmcs` construction to replace the defect-directed chain. Key lessons learned: (1) The schedule-based chain with `fwd_succ`/`bwd_pred` and `f_carry`/`p_carry` enrichment IS the correct architecture on the `until` branch -- it already exists in `CanonicalModel.lean` and is sorry-free. (2) The plan focused on rewiring `dd_countermodel` from the old `dd_bfmcs` to a new `bx_bfmcs` wrapper, which is the right approach. (3) Backward Until/Since coherence (sorry #4) was identified as the hardest subproblem even under reflexive semantics, with potential for [PARTIAL] outcome. (4) Phases 1-2 of plan v7 were partially implemented (dead code archival, rewiring begun) but the approach stalled on F-resolution specifics.

### Roadmap Alignment

- Advances ROADMAP item: "Task 109: Close 23 BXCanonical sorries (5 critical-path + 18 irreflexive-consequence)"
- Clears the `fwd_chain_forward_F -> restricted_tc -> restricted_buc -> restricted_fuc` dependency chain
- Prerequisite for Task 95: `#print axioms` audit on `bx_completeness`
- Phase 2 creates the irreflexive completeness infrastructure needed for the project's target semantics

## Goals & Non-Goals

**Goals**:
- Close all 5 sorry sites in `RootScopedChain.lean` on the `until` branch (reflexive completeness)
- Achieve `#print axioms bx_completeness` = `{propext, Classical.choice, Quot.sound}` (no `sorryAx`) on `until`
- Establish irreflexive completeness via B1 convention (irreflexive G/H, reflexive U/S) in a new branch
- Reuse CanonicalModel.lean's schedule-based chain infrastructure (`fwd_chain`, `bwd_chain`, `fwd_succ`, `bwd_pred`) as the foundation

**Non-Goals**:
- Fixing the archived defect-directed chain (`fwd_chain_of_sigma` / `dd_bfmcs` -- provably unfixable per ROADMAP dead ends 13-36)
- Merging `irr_until` branch into `until` (incompatible semantic changes, 36 files diverged)
- Dense completeness (task 68) or FMP truth preservation (task 82)
- Closing non-critical-path irreflexive-consequence sorries (Frame.lean `bx_le_refl`, etc.) during Phase 1 -- these are intentionally invalid under irreflexive semantics and will be addressed in Phase 2 or a follow-up

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| F-obligation monotonicity proof for `fwd_chain` blocked by Lindenbaum opacity | H | M | The `fwd_succ` construction includes `f_carry` enrichment at non-resolving steps. At resolving steps, `fwd_succ_resolves` gives the target. The monotonicity argument uses the MCS dichotomy: F(chi) or G(neg chi), plus temp_4 for forward propagation. |
| Pigeonhole/termination argument for `fwd_chain_forward_F` fails | H | M | Use schedule surjectivity instead of pigeonhole: F(phi) persists (monotonicity) until a schedule visit at index m with schedule(m)=phi, then `fwd_succ_resolves` places phi in chain(m+1). No counting argument needed. |
| Backward chain F-propagation (sorry #2) requires different argument than forward chain | M | L | F(phi) in backward chain means F(phi) in some bwd_chain(k). Propagate to origin via reverse g_content/h_content, then use forward chain F-resolution from sorry #1. |
| Backward Until/Since coherence (sorry #4) genuinely hard under reflexive semantics | H | M | Under reflexive semantics with BX8, ψ → φ U ψ is an axiom. The step transfer `(phi U psi) in chain(r+1) AND phi in chain(r) -> (phi U psi) in chain(r)` is semantically valid (report 10, Section 3.1). The key lemma `or_until_in_mcs` (if BX8 present) provides the introduction rule. If blocked, mark [PARTIAL] with 4/5 sorries closed. |
| B1 convention (Phase 2) requires axiom system changes that cascade through soundness | H | M | Changes are minimal: replace BX1 with seriality (already done on `irr_until`), keep BX8, replace BX10 with BX10'. Only Truth.lean G/H clauses change (≤ to <). Soundness re-proof is mechanical for the 2-3 changed axioms. |
| `until` branch Lean version is stale or `lake build` fails | M | L | Both branches use leanprover/lean4:v4.27.0-rc1. Run `lake build` as first verification step. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5, 6 | 4 |
| 6 | 7 | 5, 6 |
| 7 | 8 | 7 |
| 8 | 9 | 8 |
| 9 | 10 | 9 |
| 10 | 11 | 10 |

Phases within the same wave can execute in parallel. Phase 5 (forward Until/Since coherence) and Phase 6 (backward Until/Since coherence) are independent once Phase 4 (F/P resolution) is complete. Phases 1-4 are strictly sequential. Phases 8-11 form the irreflexive completeness track.

---

### Phase 1: Switch to `until` Branch and Verify Build [NOT STARTED]

**Goal**: Confirm the `until` branch compiles and establish the working environment for the 5 sorry closures.

**Tasks**:
- [ ] Switch to the `until` branch: `git checkout until`
- [ ] Run `lake build` to verify the branch compiles
- [ ] Locate the 5 sorry sites: `grep -n "sorry" Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean`
- [ ] Verify that all other BXCanonical files are sorry-free: `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/ --include="*.lean" | grep -v RootScopedChain | grep -v "^.*:.*--"` (exclude comments)
- [ ] Run `#print axioms bx_completeness` to establish baseline (should show `sorryAx`)
- [ ] Confirm BX8 is present: `grep -n "refl_intro_until\|until_step" Theories/Bimodal/ProofSystem/Axioms.lean`

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- None (verification only)

**Verification**:
- `lake build` succeeds on `until` branch
- 5 sorry sites confirmed in RootScopedChain.lean at expected lines
- `#print axioms bx_completeness` shows `sorryAx`

---

### Phase 2: Prove F-Obligation Monotonicity for Schedule Chain [NOT STARTED]

**Goal**: Prove that once `F(chi)` leaves the forward/backward chain, it never returns. This is the foundation for all F/P resolution arguments.

**Tasks**:
- [ ] Prove `fwd_chain_F_obligation_monotone`: if `F(chi) not in fwd_chain(n)`, then `F(chi) not in fwd_chain(m)` for all `m >= n`
  - Proof sketch: `F(chi) not in chain(n)` means `G(neg chi) in chain(n)` (MCS dichotomy). By `temp_4`: `G(G(neg chi)) in chain(n)`. So `G(neg chi) in g_content(chain(n))`. By `fwd_succ_g_content`: `g_content(chain(n)) subset chain(n+1)`. Therefore `G(neg chi) in chain(n+1)`, giving `F(chi) not in chain(n+1)` (MCS). Induct on `m - n`.
- [ ] Prove the contrapositive form: if `F(chi) in fwd_chain(n)` and `F(chi) not in fwd_chain(m)` for `m > n`, then there exists `k` in `(n, m]` where `F(chi)` first disappears
- [ ] Prove symmetric `bwd_chain_P_obligation_monotone`: if `P(chi) not in bwd_chain(n)`, then `P(chi) not in bwd_chain(m)` for all `m >= n`
  - Uses dual argument with `H(neg chi)` and `bwd_pred_h_content`
- [ ] Verify all new lemmas compile: `lake build`

**Timing**: 4 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Add F/P-obligation monotonicity lemmas after the chain definitions (around line 210)

**Verification**:
- `fwd_chain_F_obligation_monotone` compiles without sorry
- `bwd_chain_P_obligation_monotone` compiles without sorry
- `lake build` succeeds

---

### Phase 3: Close Sorry #1 -- fwd_chain_forward_F [NOT STARTED]

**Goal**: Prove that `F(phi) in fwd_chain(n)` implies `phi in fwd_chain(m)` for some `m > n`. This is the core F-resolution theorem that sorry #1 requires.

**Tasks**:
- [ ] Prove `fwd_chain_forward_F` using the schedule surjectivity argument:
  1. By `schedule_surjective_above`: exists `m >= n` with `schedule(m) = phi`
  2. By F-obligation monotonicity (Phase 2): `F(phi) in fwd_chain(k)` for all `k` in `[n, m]` (once present, it persists until resolved)
  3. In particular, `F(phi) in fwd_chain(m)` (if not already resolved at an earlier step)
  4. At step `m`: `fwd_chain(m+1) = fwd_succ(chain(m), schedule(m)) = fwd_succ(chain(m), phi)`
  5. Since `F(phi) in chain(m)`, by `fwd_succ_resolves`: `phi in fwd_chain(m+1)`
  6. Witness: `m + 1 > n`
- [ ] Handle the edge case: if `F(phi)` disappears before reaching schedule index `m`, then by F-obligation monotonicity contrapositive, `F(phi)` was lost at some step `k <= m`. At step `k`, `fwd_chain(k) = fwd_succ(chain(k-1), schedule(k-1))`. Since `F(phi) in chain(k-1)` and `F(phi) not in chain(k)`, the MCS `chain(k)` contains `G(neg phi)`. But we actually need `phi in chain(k)` in this case. Alternative: this case is impossible -- use the correct statement that F-obligation monotonicity means F(phi) PERSISTS (it never leaves once present under reflexive semantics), so F(phi) is guaranteed to be in chain(m).
- [ ] Verify whether F-obligation monotonicity holds in the FORWARD direction (F(chi) present implies F(chi) present at all future steps) under reflexive semantics. Under reflexive semantics, `G(phi) -> phi` (BX1), so `G(neg chi) in chain(n)` gives `neg chi in chain(n)`. Check: is `F(chi) in chain(n)` compatible with `neg chi in chain(n)`? Yes, `F(chi) = neg G(neg chi)` means there exists a future point with chi, while neg chi holds at the current point. So `F(chi) not in chain(n+1)` does NOT follow from `F(chi) not in chain(n)` under reflexive semantics. CAUTION: under reflexive semantics, the monotonicity argument from Phase 2 may need refinement.
- [ ] Alternative if monotonicity fails under reflexive semantics: use the direct argument. Since `schedule` hits every formula infinitely often (`schedule_surjective_above`), and at each visit `fwd_succ_resolves` gives `phi in chain(m+1)` when `F(phi) in chain(m)`, we just need ONE visit where `F(phi)` is still present. Use `Nat.find` on the predicate `F(phi) in fwd_chain(k) AND schedule(k) = phi` to get the earliest such step.
- [ ] Close the sorry on line 1111 of RootScopedChain.lean
- [ ] Prove symmetric `bwd_chain_backward_P`: if `P(phi) in bwd_chain(n)`, then `phi in bwd_chain(m)` for some `m > n`. Same argument using `bwd_pred_resolves` and schedule surjectivity.
- [ ] Run `lake build` to verify

**Timing**: 8 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- Close sorry #1 at line 1111
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Add `fwd_chain_forward_F` and `bwd_chain_backward_P` lemmas if they belong with the chain infrastructure

**Verification**:
- `fwd_chain_forward_F` compiles without sorry
- `bwd_chain_backward_P` compiles without sorry
- `lean_verify` on `fwd_chain_forward_F` shows no `sorryAx`
- `lake build` succeeds

---

### Phase 4: Close Sorries #2 and #3 -- restricted_tc (F/P Resolution) [NOT STARTED]

**Goal**: Close `dd_bfmcs_restricted_tc` by proving temporal coherence for the chain -- both forward F-resolution and backward P-resolution across the entire BFMCS family.

**Tasks**:
- [ ] Close sorry #2 (line 1138): backward chain case of `dd_bfmcs_restricted_tc`
  - F(phi) in backward region (t - s < 0) of the chain family. Propagate F(phi) to the origin via the backward chain's structure: `bwd_chain(k)` has `h_content(bwd_chain(k)) subset bwd_chain(k-1)`, so F(phi) (which is not an H-formula) cannot directly propagate backward. Instead, use the forward chain from the origin: show that F(phi) in the backward chain implies F(phi) at the origin (via `int_chain_zero`), then use `fwd_chain_forward_F` from Phase 3 to find a forward witness.
  - Alternative: show backward region F-resolution directly. If `F(phi) in bwd_chain(k)`, use schedule surjectivity to find `m >= k` with `schedule(m) = phi`. At step m of the backward chain, `bwd_pred` does NOT resolve F-obligations (it resolves P-obligations). So F in the backward chain requires a different approach: propagate to origin, then resolve in the forward chain.
- [ ] Close sorry #3 (line 1145): P-direction of `dd_bfmcs_restricted_tc`
  - Symmetric to the forward case using `bwd_chain_backward_P` from Phase 3
  - P(phi) in forward region: propagate to origin via g_content reverse, then use backward chain P-resolution
  - P(phi) in backward region: direct resolution via `bwd_chain_backward_P`
- [ ] Verify the Int-indexed chain dispatching: `dd_chain` splits on `t - s >= 0` (forward) vs `t - s < 0` (backward). Ensure the proofs correctly handle both regions and the origin (t = s).
- [ ] Run `lake build` to verify

**Timing**: 6 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- Close sorries at lines 1138 and 1145

**Verification**:
- `dd_bfmcs_restricted_tc` compiles without sorry
- `lean_verify` on `dd_bfmcs_restricted_tc` shows no `sorryAx`
- `lake build` succeeds

---

### Phase 5: Close Sorry #5 -- restricted_fuc (Forward Until/Since Coherence) [NOT STARTED]

**Goal**: Prove forward Until/Since coherence: if `(phi U psi) in chain(t)`, then there exists a future witness `s > t` with `psi in chain(s)` and guard `phi` on `(t, s)`.

**Tasks**:
- [ ] Prove forward Until coherence using BX10 + F-resolution + guard persistence:
  1. By BX10 (`until_F`): `(phi U psi) in chain(t)` implies `F(psi) in chain(t)` (sound under reflexive semantics where BX10 is valid)
  2. By Phase 3's `fwd_chain_forward_F`: exists `s > t` with `psi in chain(s)`
  3. Choose the minimal such `s` via `Nat.find` or well-ordering
  4. Guard persistence: for `r` in `(t, s)`, show `phi in chain(r)`:
     - By BX5 (`self_accum_until`): `(phi U psi) in chain(t)` implies `((phi AND (phi U psi)) U psi) in chain(t)`
     - By BX9 (`until_elim`): at any step where `phi U psi` holds and `psi` does not hold, `phi` must hold
     - Need `phi U psi in chain(r)` for all `r in (t, s)`. Under reflexive semantics, `G(P(phi U psi))` follows from BX4 (`connect_future`), and g_content propagation carries `P(phi U psi)` forward. Combined with `P(phi U psi)` giving `phi U psi` at the current step (via backward chain witness), this closes the guard.
     - Simpler path: use BX8 + BX1 + g_content propagation. Under reflexive semantics, `phi U psi in chain(t)` implies `G(P(phi U psi)) in chain(t)` by BX4. So `P(phi U psi) in g_content(chain(t)) subset chain(t+1)`. Then `phi U psi in chain(t+1)` (since P(phi U psi) means there was a past point with phi U psi, and the backward witness reconstruction gives it). Repeat by induction to step s-1.
- [ ] Build helper lemma `until_guard_persistence`: by induction on `s - r`, show `phi in chain(r)` for all `r` in `(t, s)`
- [ ] Close forward Since coherence symmetrically using BX5', BX9', BX10' and backward chain P-resolution
- [ ] Close the sorry at line 1160 of RootScopedChain.lean
- [ ] Run `lake build` to verify

**Timing**: 6 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- Close sorry at line 1160
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Add Until guard persistence helper lemma

**Verification**:
- `dd_bfmcs_restricted_fuc` compiles without sorry
- `lean_verify` on `dd_bfmcs_restricted_fuc` shows no `sorryAx`
- `lake build` succeeds

---

### Phase 6: Close Sorry #4 -- restricted_buc (Backward Until/Since Coherence) [NOT STARTED]

**Goal**: Prove backward Until/Since coherence: given semantic witnesses at future/past points, derive `phi U psi` syntactically at past points of the chain. This is the hardest of the 5 sorries.

**Tasks**:
- [ ] Analyze the precise requirement: if `(phi U psi) in chain(t)`, need witnesses BEFORE `t` in the backward direction. Under reflexive semantics, this is the semantic backward direction of Until coherence for the BFMCS family.
- [ ] Verify that the step transfer property holds under reflexive semantics:
  - Step transfer: `(phi U psi) in chain(r+1) AND phi in chain(r) -> (phi U psi) in chain(r)`
  - Under reflexive semantics with BX8: `psi -> phi U psi` is an axiom. So if `psi in chain(r)`, then `phi U psi in chain(r)` directly.
  - If `psi not in chain(r)`: we need `phi in chain(r)` and `phi U psi in chain(r+1)`. Under reflexive semantics, the witness for `phi U psi` at `r` can use the witness from `r+1` (since reflexive semantics allows witness s >= r, and if `phi U psi` at `r+1` has witness `s >= r+1`, then `s >= r` as well). The guard at `r` covers `[r, s)` which includes `r` (need `phi(r)`, given) and `[r+1, s)` (from the Until at `r+1`).
  - This step transfer IS derivable under reflexive Until: `or_until_in_mcs` should give `phi in M AND F(phi U psi) in M -> phi U psi in M` via BX axioms. Check: BX8 gives `phi U psi` from `psi` directly. For the case `psi not in M, (phi U psi) at successor`: use BX12 style reasoning or the `backward_until_from_step` lemma.
- [ ] Check if `backward_until_from_step` (mentioned in ROADMAP as sorry-free) exists on the `until` branch and can be used directly
- [ ] Prove `dd_bfmcs_restricted_buc` using the step transfer + strong induction on chain distance
- [ ] If backward Until/Since coherence is blocked (requires infrastructure not present on `until`):
  - Verify whether `restricted_buc` is on the critical path for `bx_completeness` (it IS -- `dd_countermodel` calls it directly)
  - Mark task [PARTIAL] with 4/5 sorries closed, create follow-up task
- [ ] Close the sorry at line 1153 of RootScopedChain.lean
- [ ] Run `lake build` to verify

**Timing**: 8 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- Close sorry at line 1153
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Add step transfer lemma if needed

**Verification**:
- `dd_bfmcs_restricted_buc` compiles without sorry
- `lean_verify` on `dd_bfmcs_restricted_buc` shows no `sorryAx`
- `lake build` succeeds

---

### Phase 7: Reflexive Completeness Audit and Commit [NOT STARTED]

**Goal**: Verify sorry-free reflexive completeness on the `until` branch. Run axiom audit. Commit the result.

**Tasks**:
- [ ] Run `#print axioms bx_completeness` and verify output is `{propext, Classical.choice, Quot.sound}` (no `sorryAx`)
- [ ] Run `#print axioms dd_countermodel` and verify no `sorryAx`
- [ ] Grep for any remaining `sorry` in the BXCanonical module: `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/ --include="*.lean" | grep -v "^.*:.*--"` (exclude comments)
- [ ] Run full `lake build` to confirm no regressions
- [ ] Update sorry counts in code comments if applicable
- [ ] If sorries #4 was not closed in Phase 6:
  - Document the precise obstruction
  - Update ROADMAP.md with the outcome
  - Mark task [PARTIAL]

**Timing**: 2 hours

**Depends on**: 5, 6

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- Update axiom audit comments
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- Update header documentation

**Verification**:
- `#print axioms bx_completeness` shows target axiom set (no `sorryAx`)
- `lake build` succeeds with no sorry on the critical path
- All 5 sorries closed, or clearly documented which remain

---

### Phase 8: Create Irreflexive Branch and Modify Axiom System [NOT STARTED]

**Goal**: Fork from the sorry-free `until` branch to begin irreflexive completeness using the B1 convention (irreflexive G/H, reflexive U/S).

**Tasks**:
- [ ] Create new branch: `git checkout -b irr_g_completeness` from `until` (after Phase 7 commit)
- [ ] Modify `Theories/Bimodal/Semantics/Truth.lean`:
  - Change G clause from `t <= s` to `t < s` (irreflexive)
  - Change H clause from `s <= t` to `s < t` (irreflexive)
  - Keep U clause as `t <= s` (reflexive -- B1 convention)
  - Keep S clause as `s <= t` (reflexive -- B1 convention)
- [ ] Modify `Theories/Bimodal/ProofSystem/Axioms.lean`:
  - Replace BX1 (`temp_t_future: G(phi) -> phi`) with seriality (`serial_future: T -> F(T)`)
  - Replace BX1' (`temp_t_past: H(phi) -> phi`) with seriality (`serial_past: T -> P(T)`)
  - Keep BX8/BX8' (ψ → φ U ψ / ψ → φ S ψ) -- still sound under B1
  - Replace BX10 with BX10': `(phi U psi) -> psi v F(psi)` (BX10 unsound when s = t under irr G)
  - Replace BX10' (since direction) symmetrically
- [ ] Fix compilation errors from the axiom changes: update all pattern matches on `Axiom` constructors
- [ ] Run `lake build` -- expect many type errors from the changes, fix iteratively

**Timing**: 4 hours

**Depends on**: 7

**Files to modify**:
- `Theories/Bimodal/Semantics/Truth.lean` -- G/H clauses from ≤ to <
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- Axiom replacements
- Various files with Axiom pattern matches -- Compilation fixes

**Verification**:
- `lake build` succeeds (or errors are limited to soundness/chain proofs)
- New axiom system is correctly defined

---

### Phase 9: Re-prove Soundness Under B1 Convention [NOT STARTED]

**Goal**: Verify and fix soundness proofs for the modified axiom system. Most axioms are unchanged; only BX1/BX1' replacement and BX10/BX10' replacement need attention.

**Tasks**:
- [ ] Re-prove soundness for `serial_future` (`T -> F(T)`): under irreflexive G, need to show every linear order has a strictly future point. Use the `until` branch's existing seriality proof if present, or prove from scratch using order properties.
- [ ] Re-prove soundness for `serial_past` symmetrically
- [ ] Re-prove soundness for BX10' (`(phi U psi) -> psi v F(psi)`): Under B1, `phi U psi` at `t` has witness `s >= t`. If `s = t`: `psi` holds. If `s > t`: `F(psi)` holds. Both cases give `psi v F(psi)`.
- [ ] Verify all other axiom soundness proofs still hold (they should -- only G/H changed, and the remaining axioms either don't involve G/H or are strengthened by irreflexive G)
- [ ] Fix `g_content_set_consistent` to use seriality instead of BX1 (already done on `irr_until`, can reference)
- [ ] Run `lake build` to verify soundness module compiles

**Timing**: 4 hours

**Depends on**: 8

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness/Soundness.lean` -- Fix axiom soundness cases
- `Theories/Bimodal/Metalogic/Soundness/SoundnessLemmas.lean` -- Fix helper lemmas
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` -- Fix `g_content_set_consistent` to use seriality

**Verification**:
- All soundness proofs compile without sorry
- `lake build` succeeds for soundness module

---

### Phase 10: Adapt Chain Construction for Irreflexive G [NOT STARTED]

**Goal**: Modify the chain construction in CanonicalModel.lean and RootScopedChain.lean to work under irreflexive G semantics. The key change is the enriched-seed chain for F-resolution.

**Tasks**:
- [ ] Verify `fwd_succ_g_content` still holds: `g_content(M) subset fwd_succ(M, psi)`. Under irreflexive G, g_content is not a subset of M itself (no BX1), but the Lindenbaum extension still includes g_content as part of the seed. This should be unchanged.
- [ ] Verify `enriched_seed_consistent` still holds: `g_content(M) union f_carry(M) subset M` requires BX1 for `g_content(M) subset M`. Under irreflexive G, `g_content(M) NOT subset M`. Fix: use `g_content(M) union f_carry(M) is consistent` (not necessarily a subset of M) via an independent consistency argument.
- [ ] Adapt `fwd_chain_F_obligation_monotone` for irreflexive G: The proof uses `G(neg chi) in chain(n)` implies `G(neg chi) in chain(n+1)` via temp_4 + g_content. Under irreflexive G, temp_4 still holds (it only uses the G operator). The argument should transfer directly.
- [ ] Re-check `fwd_chain_forward_F` under irreflexive G: schedule surjectivity argument is independent of reflexivity. The key question is whether `f_carry` preservation at non-resolving steps still works. Under irreflexive G, the seed `g_content(M) union f_carry(M)` may not be a subset of M. Need to prove consistency directly.
- [ ] The CRITICAL change: under irreflexive G, `g_content(M) subset M` fails. The seed `{target} union g_content(M)` used by `forward_temporal_witness_seed` is consistent because `F(target) in M` implies `{target} union g_content(M)` is consistent (by `forward_temporal_witness_seed_consistent`, which uses `g_content_closed_derivation` -- this does NOT require BX1). Verify this proof transfers.
- [ ] Adapt the restricted coherence proofs (tc, buc, fuc) for the new axiom system
- [ ] Run `lake build` to verify

**Timing**: 8 hours

**Depends on**: 9

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Adapt chain construction
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- Adapt coherence proofs

**Verification**:
- Chain construction compiles under B1 convention
- F-resolution and Until coherence proofs transfer
- `lake build` succeeds

---

### Phase 11: Irreflexive Completeness Audit [NOT STARTED]

**Goal**: Verify sorry-free irreflexive completeness under B1 convention. Run axiom audit.

**Tasks**:
- [ ] Run `#print axioms bx_completeness` and verify no `sorryAx`
- [ ] Run full `lake build`
- [ ] Grep for remaining sorries in the BXCanonical module
- [ ] Document any remaining sorries with clear obstruction descriptions
- [ ] Update ROADMAP.md with results

**Timing**: 2 hours

**Depends on**: 10

**Files to modify**:
- `specs/ROADMAP.md` -- Update with irreflexive completeness results
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- Update audit comments

**Verification**:
- `#print axioms bx_completeness` shows target axiom set
- `lake build` succeeds
- Clear documentation of completeness status

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] `lean_verify` on each closed sorry confirms no `sorryAx` leaks
- [ ] `#print axioms bx_completeness` checked at Phase 7 (reflexive) and Phase 11 (irreflexive)
- [ ] Grep for `sorry` in `RootScopedChain.lean` shows monotonic decrease across phases
- [ ] `dd_bfmcs_restricted_tc` is fully sorry-free after Phase 4
- [ ] `dd_bfmcs_restricted_fuc` is sorry-free after Phase 5
- [ ] `dd_bfmcs_restricted_buc` is sorry-free after Phase 6 (or documented as blocked)
- [ ] Soundness module compiles sorry-free under both conventions

## Artifacts & Outputs

- `specs/109_close_chain_construction_sorries/plans/12_implementation-plan.md` (this file)
- Modified source files (Phase 1, `until` branch):
  - `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- 5 sorries closed
  - `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- New helper lemmas
  - `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- Axiom audit update
- Modified source files (Phase 2, `irr_g_completeness` branch):
  - `Theories/Bimodal/Semantics/Truth.lean` -- G/H clauses
  - `Theories/Bimodal/ProofSystem/Axioms.lean` -- Axiom replacements
  - Soundness and chain construction files
- `specs/ROADMAP.md` -- Updated completeness status
- Implementation summary upon completion

## Rollback/Contingency

- Each phase is independently committable; rollback to previous phase's commit if a phase fails.
- **Phase 3 fallback**: If the schedule surjectivity + F-obligation argument has a gap under reflexive semantics (e.g., F-obligations are not monotone because BX1 allows re-entry), use the pigeonhole argument instead: the finite sigma_list has bounded defects, and each resolving step discharges at least one. Under reflexive semantics, resolved defects CAN re-enter (phi -> F(phi) via BX1), so the pigeonhole bound is sigma_list.length * some factor. If even this fails, the ROADMAP dead ends 33-34 analysis applies and the sorry is genuinely blocked.
- **Phase 6 fallback**: If backward Until/Since coherence is blocked under reflexive semantics, mark task [PARTIAL] with 4/5 sorries closed. The reflexive completeness theorem would then have 1 remaining sorry. Create a follow-up task targeting this specific sorry.
- **Phase 10 fallback**: If the irreflexive adaptation is harder than estimated (e.g., `enriched_seed_consistent` requires major rework), break Phase 10 into sub-phases and create a follow-up task for the remaining work.
- **Overall fallback**: If Phases 1-7 succeed but Phase 2 stalls, the reflexive completeness on `until` is still a valuable milestone and can be committed as-is. The irreflexive work becomes a separate task.
