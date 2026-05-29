# Implementation Plan: Direct Completeness on Z via Henkin BFMCS

- **Task**: 202 - Reynolds k-equivalence bypass for sorry-free completeness_discrete
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (bypasses tasks 155, 174, 199 entirely)
- **Research Inputs**: specs/202_reynolds_k_equivalence_bypass/reports/04_team-research.md
- **Artifacts**: plans/04_option-c-direct-z.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v4 abandons all chronicle-based discrete approaches (plans v1-v3) and builds completeness_discrete directly on Z using the existing sorry-free Henkin chain infrastructure in CanonicalModel.lean. The `bx_fmcs`/`shifted_bx_fmcs` construction already produces FMCS families on Int with sorry-free G/H coherence, forward resolution (`fwd_succ_resolves`), backward resolution (`bwd_pred_resolves`), and box stability (`box_stable_in_int_chain`). The missing piece is assembling these into a BFMCS on Int and proving the three restricted coherence conditions (TC, BUC, FUC) directly on this Z-indexed structure. Since the domain IS Z from the start, there is no isomorphism step and no need for `succ_embed_surjective` or `succ_cofinal`. The definition of done is `#print axioms completeness_discrete` showing no `sorryAx` and `lake build` passing with zero errors.

### Research Integration

- `reports/04_team-research.md` (integrated): Four teammates confirmed (1) succ_cofinal is genuinely unprovable, (2) all Henkin chain F-persistence approaches are dead, (3) task 129 is not viable (~18 sorries), (4) Option C (direct completeness on Z) has 85% confidence at 6-10 hours. The Critic identified the local vs global surjectivity distinction -- on Z, temporal witnesses are integers by construction, so no surjectivity argument is needed.

### Prior Plan Reference

Plans v1-v3 attempted three approaches: Reynolds pipeline (v1, Phase 3 completed, rest blocked), Henkin chain FMCS on Z through chronicle (v2, Phase 1 blocked after 6 approaches failed), and one-at-a-time F-resolution through Lindenbaum extensions (v3, Phase 1 blocked -- F-persistence through Lindenbaum is unfixable). The key lesson: all chronicle-based discrete approaches fail because the chronicle's limit domain is NOT Z-isomorphic (succ_cofinal is unprovable). Plan v4 avoids the chronicle entirely for the discrete case and builds on Z from the start. Effort calibration from prior plans: the core construction is 2-3 hours; the restricted coherence proofs (especially FUC) are 3-4 hours; integration and verification is 1-2 hours.

### Roadmap Alignment

- Advances "Sorry-free `bx_completeness`" roadmap item (Phase 1 critical path)
- Unblocks task 95 (verification audit), task 176 (chronicle relocation)
- Eliminates the last `sorryAx` dependency in `completeness_discrete`

### Sorry Chain (Root Cause)

```
completeness_discrete (Completeness.lean:308)
  --> countermodel_discrete_enriched (Completeness.lean:222)
        |-- cantor_bfmcs_discrete                    [OK, sorry-free]
        |-- cantor_bfmcs_discrete_restricted_tc      [SORRY via succ_embed_surjective]
        |-- cantor_bfmcs_discrete_restricted_buc     [OK, sorry-free]
        |-- cantor_bfmcs_discrete_restricted_fuc     [SORRY via succ_embed_surjective]
        |-- fully_restricted_parametric_completeness_from_neg_membership [OK, sorry-free]
```

Plan v4 replaces `countermodel_discrete_enriched` with a new implementation that uses `henkin_bfmcs_discrete` (built from `shifted_bx_fmcs` in CanonicalModel.lean) and proves sorry-free restricted_tc/buc/fuc directly on Z.

### Existing Sorry-Free Infrastructure (Reused)

| Component | File | Status |
|-----------|------|--------|
| `bx_fmcs` / `shifted_bx_fmcs` | CanonicalModel.lean | sorry-free, FMCS on Int |
| `int_chain_forward_G` / `int_chain_backward_H` | CanonicalModel.lean | sorry-free |
| `fwd_succ_resolves` / `bwd_pred_resolves` | CanonicalModel.lean | sorry-free |
| `box_stable_in_int_chain` / `box_stable_in_shifted_fmcs` | CanonicalModel.lean | sorry-free |
| `forward_temporal_witness_seed_consistent` | WitnessSeed.lean | sorry-free |
| `past_temporal_witness_seed_consistent` | WitnessSeed.lean | sorry-free |
| `bx_modal_witness_fc` | ModalSaturation.lean | sorry-free |
| `fully_restricted_parametric_completeness_from_neg_membership` | RestrictedParametricTruthLemma.lean | sorry-free |
| `schedule_surjective_above` | CanonicalModel.lean | sorry-free |

## Goals & Non-Goals

**Goals**:
- Build `henkin_bfmcs_discrete : BFMCS Int` from `shifted_bx_fmcs` families
- Prove sorry-free `restricted_temporally_coherent`, `restricted_backward_until_since_coherent`, and `restricted_forward_until_since_coherent` for this BFMCS
- Replace `countermodel_discrete_enriched` with a new version using `henkin_bfmcs_discrete`
- Achieve `#print axioms completeness_discrete` with no `sorryAx`
- `lake build` passes with zero errors

**Non-Goals**:
- Proving `succ_cofinal` or `succ_embed_surjective` (bypassed entirely)
- Changing the dense case or the chronicle construction
- Completing the Reynolds pipeline (tasks 155, 174, 199)
- Archiving dead code (task 176 scope)
- Removing plan v1 Phase 3's completed work (independently useful)
- Optimizing proof term size or compilation time

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Restricted TC: F-witness resolution requires showing specific formula resolution within finite chain steps | H | L | `schedule_surjective_above` guarantees every formula gets targeted. `fwd_succ_resolves` proves the witness lands in the chain. Standard eventuality argument on Nat indices. |
| Restricted FUC: Until witness requires not just F-resolution but correct guard structure (all intermediate points satisfy guard) | H | M | On Z, intermediate points are consecutive integers. The Henkin chain builds successive MCS's with g_content inclusion, so the guard propagates through forward_G. If complex, fall back to BX5 self-accumulation on integers. |
| Restricted BUC: Backward Until coherence (contrapositive direction) requires C4-like counterexample elimination | M | L | The Henkin chain on Z has complete coverage -- every integer is a chain point. Contrapositive argument via MCS closure under Until axioms (BX5, until_induction). Pattern matches `cantor_bfmcs_discrete_restricted_buc` but without the succ_embed indirection. |
| Modal backward proof for the BFMCS requires S5 witness construction | M | L | Follow exact pattern of `cantor_bfmcs_dense` modal_backward proof: use `bx_modal_witness_fc` to get diamond witness MCS, build shifted chain for that MCS, show phi membership. All components are sorry-free. |
| Integration with `countermodel_discrete_enriched` requires matching the existential signature | L | L | The parametric infrastructure is generic over any BFMCS on Int. The new BFMCS is a drop-in replacement -- same type signature as `cantor_bfmcs_discrete`. |
| `bx_fmcs` uses `FrameClass.Base` while `completeness_discrete` needs `FrameClass.Discrete` | H | M | Generalize `bx_fmcs` / `int_chain` to be parametric over fc (like the chronicle approach). The core seed consistency theorems (`forward_temporal_witness_seed_consistent`, etc.) are already fc-parametric. If generalization is complex, build the chain at `FrameClass.Base` and lift via `FrameClass.base_le`. |

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

### Phase 1: Henkin BFMCS on Int [COMPLETED]

**Goal**: Build `henkin_bfmcs_discrete : BFMCS Int` from the existing `shifted_bx_fmcs` infrastructure in CanonicalModel.lean. This is the Z-native BFMCS that replaces `cantor_bfmcs_discrete` (which goes through the chronicle limit domain).

**Tasks**:
- [x] Audit fc-parametricity of `bx_fmcs`/`shifted_bx_fmcs`/`int_chain` -- determine whether they need generalization from `FrameClass.Base` to arbitrary fc, or if `FrameClass.base_le` lifting suffices *(completed — generalization needed; built fc-parametric `fwd_succ_fc`, `bwd_pred_fc`, `int_chain_fc`, `shifted_bx_fmcs_fc` using fc-parametric seed consistency and `mcs_to_base` for reverse propagation)*
- [x] If needed, generalize `fwd_succ`, `bwd_pred`, `fwd_chain`, `bwd_chain`, `int_chain` to be parametric over fc (following pattern of chronicle code which takes `fc : FrameClass` parameter) *(completed)*
- [x] Define `henkin_bfmcs_discrete (fc : FrameClass) (A : Set Formula) (h_mcs : SetMaximalConsistent A) (h_box_discrete : Formula.box next_top in A) : BFMCS Int` with families := `{ fam | exists N h_N h_box_N s, box_equiv(A,N) and fam = shifted_bx_fmcs N h_N s }` *(deviation: altered — named `henkin_bfmcs` without `h_box_discrete` param, since the Z-chain doesn't need discreteness; `h_box_discrete` requirement stays at the Completeness.lean call site)*
- [x] Prove `nonempty` (eval family is `shifted_bx_fmcs A h_mcs 0` or equivalently `bx_fmcs A h_mcs`) *(completed)*
- [x] Prove `modal_forward` using `box_stable_in_shifted_fmcs` and Modal T *(completed)*
- [x] Prove `modal_backward` using contrapositive + `bx_modal_witness_fc` (S5 diamond witness) + shifted chain construction *(completed)*
- [x] Prove `eval_family_mem` *(completed)*

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- generalize fc if needed, add `henkin_bfmcs_discrete`

**Verification**:
- `lake build Bimodal.Metalogic.BXCanonical.CanonicalModel` succeeds
- `#print axioms henkin_bfmcs_discrete` shows no `sorryAx`
- `#check henkin_bfmcs_discrete` confirms the type `BFMCS Int`

---

### Phase 2: Restricted TC and BUC on Z [NOT STARTED]

**Goal**: Prove sorry-free `restricted_temporally_coherent` and `restricted_backward_until_since_coherent` for `henkin_bfmcs_discrete`. These are the two "easier" coherence conditions.

**Tasks**:
- [ ] Prove `henkin_bfmcs_discrete_restricted_tc`: For each family `shifted_bx_fmcs N h_N s`:
  - Forward F direction: If `F(phi) in fam.mcs(t)`, need `exists s' > t, phi in fam.mcs(s')`. Since `fam.mcs(t) = int_chain N h_N (t - s)`, we have `F(phi) in int_chain(t-s)`. The schedule `schedule n` hits phi at some n >= |t-s|. At step n+1, `fwd_succ_resolves` places phi in the chain if `F(phi)` is still present. Use g_content propagation: `F(phi) in int_chain(k)` for all k >= t-s (since G(F(phi)) in int_chain(t-s) from the temp_future_derived axiom applied to F(phi)). At schedule hit n, `fwd_succ_resolves` gives `phi in int_chain(n+1)`. Convert back to fam coordinates: `s' = n+1+s`.
  - Backward P direction: Symmetric using `bwd_pred_resolves` and `schedule_surjective_above`
- [ ] Prove `henkin_bfmcs_discrete_restricted_buc`: Backward Until/Since coherence. Contrapositive: if `not(U(phi,psi) in fam.mcs(t))` then `neg(U(phi,psi)) in fam.mcs(t)` (MCS). Given the witness pattern `(exists u > t, phi in fam.mcs(u) and guard)`, derive contradiction using the Until axioms:
  - Use `until_induction` (BX axiom): `G(psi -> chi) and G((phi and chi) -> G(chi)) -> (U(phi,psi) -> chi)`. Set chi = bot. From guard pattern, derive G(psi -> bot) on interval. Combined with MCS closure, derive contradiction with `U(phi,psi)` witness. On Z, the guard covers all integers between t and u -- these are exactly the chain points, so no gaps.
  - Since backward direction: symmetric using `since_induction`

**Timing**: 2.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- add restricted_tc and restricted_buc proofs

**Verification**:
- `#print axioms henkin_bfmcs_discrete_restricted_tc` shows no `sorryAx`
- `#print axioms henkin_bfmcs_discrete_restricted_buc` shows no `sorryAx`

---

### Phase 3: Restricted FUC on Z [NOT STARTED]

**Goal**: Prove sorry-free `restricted_forward_until_since_coherent` for `henkin_bfmcs_discrete`. This is the hardest coherence condition -- it requires constructing Until/Since witnesses with guard coverage on all intermediate integers.

**Tasks**:
- [ ] Prove `henkin_bfmcs_discrete_restricted_fuc` -- Until forward direction: If `U(phi,psi) in fam.mcs(t)`, need `exists u > t, phi in fam.mcs(u) and forall r in (t,u), psi in fam.mcs(r)`.
  - Strategy A (BX5 self-accumulation): From `U(phi,psi) in mcs(t)`, derive using BX5: either `phi in mcs(t+1)` (done, u=t+1, vacuous guard) or `psi in mcs(t+1) and U(phi,psi) in mcs(t+1)` (deferred). Since the chain is on Z, step from t to t+1 is exactly `fwd_succ`. On each step, either the Until resolves (phi appears) or it defers (psi at current + Until at next). Since the schedule ensures F(phi) gets resolved eventually (and U(phi,psi) -> F(phi) by BX10), the deferral terminates.
  - The guard follows from the deferral pattern: at each intermediate integer r in (t,u), psi was placed by the deferral step.
  - Key lemma needed: `until_step_decomposition` -- if `U(phi,psi) in MCS M and fwd_succ(M) is next`, then either `phi in fwd_succ(M)` or `(psi in fwd_succ(M) and U(phi,psi) in fwd_succ(M))`. This follows from BX5 (U(phi,psi) -> psi or (phi and U(phi,psi))) being a theorem, combined with g_content propagation.
  - Termination: U(phi,psi) -> F(phi) by BX10. F(phi) in the chain means phi appears at some future point. BX5 deferral produces psi at each intermediate step.
- [ ] Prove `henkin_bfmcs_discrete_restricted_fuc` -- Since forward direction: Symmetric using BX5' and past chain
- [ ] Handle the interaction between the schedule-based chain and BX5 deferral: the chain resolves F-formulas by schedule priority, but Until deferral requires resolving the specific Until formula. Need to show that between t and the F(phi) resolution point, every step defers U(phi,psi) and places psi.
  - Key insight: g_content propagation ensures U(phi,psi) stays in the chain as long as it is unresolved (since G(U(phi,psi)) follows from temp_a: phi -> G(P(phi))... actually, need to verify that Until formulas propagate through g_content). If U(phi,psi) in mcs(n), then by BX5, either phi or (psi and U(phi,psi)) at n+1. The g_content step ensures all G-formulas propagate. U(phi,psi) itself is NOT a G-formula. But the deferral via BX5 explicitly places U(phi,psi) at n+1 when it defers.
  - Alternative strategy: Use the MCS truth lemma directly. Since mcs(t) is an MCS containing U(phi,psi), and the chain has forward resolution for F(phi), and BX5 is an axiom in every MCS, the structural argument goes through by induction on the distance to the F(phi) resolution point.

**Timing**: 2.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- add restricted_fuc proof and helper lemmas (until_step_decomposition, until_deferral_chain)

**Verification**:
- `#print axioms henkin_bfmcs_discrete_restricted_fuc` shows no `sorryAx`
- All three restricted coherence conditions verified sorry-free

---

### Phase 4: Integration and Verification [NOT STARTED]

**Goal**: Wire `henkin_bfmcs_discrete` with its sorry-free coherence proofs into `countermodel_discrete_enriched` in Completeness.lean, replacing the chronicle-based discrete path. Verify `completeness_discrete` is sorry-free.

**Tasks**:
- [ ] Define `henkin_countermodel_discrete_enriched` in CanonicalModel.lean (or a new file) mirroring the signature of `countermodel_discrete_enriched` but using `henkin_bfmcs_discrete`:
  ```
  theorem henkin_countermodel_discrete_enriched (fc : FrameClass) (A : Set Formula) 
    (h_mcs : SetMaximalConsistent A) (phi : Formula) (h_neg_in : phi.neg in A)
    (h_box_discrete : Formula.box next_top in A) :
    exists (F : TaskFrame Int) (TM : TaskModel F) (Omega : Set (WorldHistory F)) 
      (_ : ShiftClosed Omega) (tau : WorldHistory F) (_ : tau in Omega) (t : Int),
      not (truth_at TM Omega tau t phi)
  ```
- [ ] Wire into Completeness.lean: replace the call to `countermodel_discrete_enriched` in `completeness_discrete` with `henkin_countermodel_discrete_enriched`
- [ ] Update `WeakCanonical.countermodel_discrete` to delegate to the new sorry-free implementation instead of `dd_countermodel_chronicle_discrete`
- [ ] Run `#print axioms completeness_discrete` -- verify no `sorryAx`
- [ ] Run `#print axioms completeness` -- verify the general completeness theorem also benefits
- [ ] Run `lake build` -- verify zero errors project-wide
- [ ] Update docstrings in Completeness.lean to reflect the new discrete path

**Timing**: 1 hour

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- update `countermodel_discrete_enriched` and `completeness_discrete`
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- update `countermodel_discrete` delegation
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- add `henkin_countermodel_discrete_enriched`

**Verification**:
- `#print axioms completeness_discrete` shows `{propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound}` -- no `sorryAx`
- `#print axioms completeness` still works (may retain `sorryAx` from mixed case sorry, which is separate)
- `lake build` passes with zero errors

## Testing & Validation

- [ ] `#print axioms completeness_discrete` shows no `sorryAx`
- [ ] `#print axioms henkin_bfmcs_discrete` shows no `sorryAx`
- [ ] `#print axioms henkin_bfmcs_discrete_restricted_tc` shows no `sorryAx`
- [ ] `#print axioms henkin_bfmcs_discrete_restricted_buc` shows no `sorryAx`
- [ ] `#print axioms henkin_bfmcs_discrete_restricted_fuc` shows no `sorryAx`
- [ ] `lake build` passes with zero errors
- [ ] No new sorry sites introduced (grep for `sorry` in modified files)
- [ ] Existing dense completeness path unaffected (`#print axioms completeness_dense` unchanged)

## Artifacts & Outputs

- `specs/202_reynolds_k_equivalence_bypass/plans/04_option-c-direct-z.md` (this plan)
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- extended with BFMCS + coherence proofs
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- updated discrete path
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- updated delegation

## Rollback/Contingency

If the FUC proof (Phase 3) is blocked:
1. Check whether the BX5 self-accumulation argument works for the specific Until formulas in `subformulaClosure(root)` -- the finiteness of this set bounds the deferral chain
2. Fall back to a direct Doets-style argument: build explicit witnesses using `limit_satisfies_c5_strong` from the chronicle and map back via the chain (this requires showing the chronicle C5 witnesses land on chain-reachable points -- essentially a local surjectivity argument)
3. If both fail, the Phase 1-2 work (BFMCS + TC + BUC) is still valuable and the FUC sorry can be isolated to a single lemma smaller than `succ_cofinal`

If fc-parametricity (Phase 1 audit) reveals deep issues:
1. Build the chain at `FrameClass.Discrete` directly (using `FrameClass.base_le` to lift Base axioms)
2. Or build at `FrameClass.Base` and note that `completeness_discrete` only needs `FrameClass.Discrete`-MCS, which are also `FrameClass.Base`-MCS

Git safety: all work in new definitions/theorems; existing code is only modified in Phase 4 (integration). Reverting Phase 4 restores the previous state completely.
