# Implementation Plan: Option C -- Restricted Coherence on Z via Henkin BFMCS

- **Task**: 202 - Reynolds k-equivalence bypass for sorry-free completeness_discrete
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (bypasses tasks 155, 174, 199 entirely)
- **Research Inputs**: specs/202_reynolds_k_equivalence_bypass/reports/04_team-research.md
- **Artifacts**: plans/05_option-c-direct-z-v5.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v5 supersedes plan v4, which was blocked at Phase 2 by the recurrent F-persistence obstacle. The blocker: `F(phi)` is NOT a G-formula, does NOT propagate through `g_content`, and `F(phi) -> G(F(phi))` is semantically invalid under strict temporal ordering. This killed plans v2, v3, and v4 identically.

Plan v5 retains Phase 1 (completed: sorry-free `henkin_bfmcs` on Int, 426 lines) and replaces the blocked Phases 2-4 with a fundamentally different approach to proving the three restricted coherence conditions. Instead of proving F-resolution within the Henkin chain (which requires F-persistence through g_content, which is impossible), plan v5 proves restricted coherence by constructing the coherence proofs externally to the chain using MCS axiom closure and the BX5/BX5' Until decomposition property. The key insight from team research: on Z, IsSuccArchimedean is trivial, so all existing chronicle infrastructure for F-resolution and Until witnesses transfers without needing succ_embed_surjective.

### Research Integration

- `reports/04_team-research.md` (integrated in plan v4): Four teammates confirmed (1) succ_cofinal is genuinely unprovable, (2) all Henkin chain F-persistence approaches are dead, (3) task 129 is not viable (~18 sorries), (4) Option C (direct completeness on Z) has 85% confidence at 6-10 hours. The Critic identified the local vs global surjectivity distinction -- on Z, temporal witnesses are integers by construction, so no surjectivity argument is needed.
- `reports/01_reynolds-bypass-research.md` (integrated in plan v1): Initial infrastructure survey, identified no_gaps_discrete as the sole critical sorry.

### Prior Plan Reference

Plans v1-v4 attempted four approaches, all blocked by the same root cause:
- v1: Reynolds pipeline (Phase 3 completed, rest blocked on succ_cofinal)
- v2: Henkin chain FMCS on Z through chronicle (Phase 1 blocked after 6 approaches failed)
- v3: One-at-a-time F-resolution through Lindenbaum extensions (Phase 1 blocked -- F-persistence unfixable)
- v4: Direct Henkin BFMCS on Int (Phase 1 completed, Phase 2 blocked -- same F-persistence obstacle)

The lesson: ALL approaches that try to prove F-resolution within a schedule-based chain are dead. The schedule builds MCS via g_content + Lindenbaum, and Lindenbaum can introduce `G(neg(phi))`, permanently killing F(phi). Plan v5 takes a completely different approach: prove restricted coherence as a property of the BFMCS families (using MCS axiom closure), not as a property of the chain construction.

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

Plan v5 replaces `countermodel_discrete_enriched` with a new implementation using `henkin_bfmcs` (from Phase 1) and sorry-free restricted_tc/buc/fuc proofs that work directly on Z.

### Existing Sorry-Free Infrastructure (Reused)

| Component | File | Status |
|-----------|------|--------|
| `henkin_bfmcs` (fc-parametric) | CanonicalModel.lean | sorry-free (Phase 1 output) |
| `shifted_bx_fmcs_fc` / `int_chain_fc` | CanonicalModel.lean | sorry-free |
| `fwd_succ_fc_resolves` / `bwd_pred_fc_resolves` | CanonicalModel.lean | sorry-free |
| `int_chain_fc_g_content` (G-formula propagation) | CanonicalModel.lean | sorry-free |
| `schedule_surjective_above` | CanonicalModel.lean | sorry-free |
| `box_stable_in_shifted_fmcs_fc` | CanonicalModel.lean | sorry-free |
| `bx_modal_witness_fc` | ModalSaturation.lean | sorry-free |
| `forward_temporal_witness_seed_consistent` | WitnessSeed.lean | sorry-free |
| `fully_restricted_parametric_completeness_from_neg_membership` | RestrictedParametricTruthLemma.lean | sorry-free |

### Key Mathematical Insight (New in v5)

The chain's g_content propagation guarantees G-formulas persist forward. While `F(phi)` itself is NOT a G-formula, `neg(phi)` may or may not be. The key is that on Z, the successor function is exactly `(+1)`, so we can reason by Nat induction on chain indices.

**Restricted TC (F-resolution)**: For `F(phi) in chain(t)`, the schedule hits phi at some step n. At step n, `fwd_succ_fc` resolves: if `F(phi) in chain(n)`, then `phi in chain(n+1)`. The remaining question is whether `F(phi)` survives to step n. Rather than proving F-persistence through g_content (impossible), use the MCS contrapositive: if `F(phi)` is lost before step n, then `G(neg(phi)) in chain(k)` for some k between t and n. But `G(neg(phi)) in chain(k)` implies `neg(phi) in chain(m)` for all m > k (by g_content propagation of `neg(phi)` via temporal axiom temp_a: `phi -> G(P(phi))`... NO, this is the WRONG direction). Instead, use the eventuality lemma: construct a new chain from `chain(t)` that resolves F(phi) immediately. Since the chain point `chain(t)` IS an MCS containing `F(phi)`, build `fwd_succ_fc chain(t) h_mcs_t phi` which gives `phi in chain_new(1)`. Then show this new resolution point embeds into the BFMCS family structure. On Z, the chain IS the family, so the witness is `t + 1` in a new shifted chain rooted at `chain(t)`.

CORRECTION: The above is still within-chain reasoning. The actual approach for plan v5:

**Restricted TC via family proliferation**: For `F(phi) in fam.mcs(t)` where `fam = shifted_bx_fmcs_fc N h_N s`, we have `F(phi) in int_chain_fc N h_N (t - s)`. Build a NEW family: start a fresh chain from `int_chain_fc N h_N (t - s)` (which is an MCS containing `F(phi)`). The fwd_succ_fc of this MCS with target phi resolves `F(phi)` to `phi` in one step. This gives a new FMCS `shifted_bx_fmcs_fc (int_chain_fc N h_N (t-s)) h_mcs_t t` where `phi in mcs(t+1)`. The question: is this new family IN the BFMCS? Yes, if `int_chain_fc N h_N (t-s)` is box-equivalent to N (and hence to A). This follows from `box_stable_in_int_chain_fc`: box formulas are constant across the chain.

**Restricted BUC (backward Until coherence)**: Follows the same pattern as the chronicle's sorry-free `cantor_bfmcs_discrete_restricted_buc`. The proof uses contrapositive via MCS closure under Until axioms. On Z, this works identically because the argument only uses MCS properties, not chain structure.

**Restricted FUC (forward Until coherence)**: For `U(phi, psi) in fam.mcs(t)`, use BX5 step decomposition: `U(phi, psi) -> phi or (psi and G(U(phi, psi)))`. At each chain step, either phi appears (witness found) or psi appears AND U(phi, psi) defers. BX5 is an axiom in every MCS, so the decomposition applies at each integer. Termination: `U(phi, psi) -> F(phi)` by BX10, and F(phi) resolves by the restricted TC proof above. The guard is built from the deferral pattern: at each intermediate integer r, psi was placed by the BX5 deferral step. Again, use family proliferation: build a new family rooted at the deferral chain starting from `fam.mcs(t)`.

## Goals & Non-Goals

**Goals**:
- Prove sorry-free `henkin_bfmcs_restricted_tc`, `henkin_bfmcs_restricted_buc`, and `henkin_bfmcs_restricted_fuc` for the Phase 1 `henkin_bfmcs`
- Replace `countermodel_discrete_enriched` with a new version using `henkin_bfmcs` plus the sorry-free coherence proofs
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
| Family proliferation: new chain from `int_chain_fc N h_N k` may not have the right box-equivalence to be in henkin_bfmcs | H | L | `box_stable_in_int_chain_fc` already proves box formulas are constant across the chain, so any chain point is box-equivalent to the root N, hence to A. This is the core enabler. |
| BX5 deferral may not place `U(phi,psi)` in the next chain step (g_content only carries G-formulas, and U(phi,psi) is NOT a G-formula) | H | M | BX5 gives `phi or (psi and G(U(phi,psi)))`. If deferral: `G(U(phi,psi)) in mcs(t)`, so `U(phi,psi) in g_content(mcs(t))`, so it IS propagated. The key: `G(U(phi,psi))` IS a G-formula, and g_content propagates G-formulas. Use the BX5 deferral branch to obtain G(U(phi,psi)), then g_content carries it forward. |
| Restricted TC: fresh-chain approach requires showing the fresh family is in henkin_bfmcs.families | M | L | The fresh chain is `shifted_bx_fmcs_fc M' h_M' t` where M' is an intermediate chain point. M' is box-equivalent to N (by box_stable_in_int_chain_fc), and N is box-equivalent to A (by membership in henkin_bfmcs.families). Transitivity gives M' box-equivalent to A. |
| FUC termination: induction on what? Chain is infinite. | M | M | Induction on the distance to the F(phi) resolution point. U(phi,psi) -> F(phi) by BX10. The TC proof gives the resolution point. Induction counts down from resolution distance. |
| Integration with `countermodel_discrete_enriched` requires matching the existential signature | L | L | The parametric infrastructure is generic over any BFMCS on Int. `henkin_bfmcs` is a drop-in replacement -- same type `BFMCS Int`. |

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

**Goal**: Build `henkin_bfmcs : BFMCS Int` from the existing `shifted_bx_fmcs_fc` infrastructure in CanonicalModel.lean. This is the Z-native BFMCS that replaces `cantor_bfmcs_discrete`.

**Tasks**:
- [x] Build fc-parametric chain infrastructure (`fwd_succ_fc`, `bwd_pred_fc`, `fwd_chain_fc`, `bwd_chain_fc`, `int_chain_fc`)
- [x] Build fc-parametric FMCS (`bx_fmcs_fc`, `shifted_bx_fmcs_fc`)
- [x] Define `henkin_bfmcs` with families parametrized by box-equivalent MCS
- [x] Prove `nonempty`, `modal_forward`, `modal_backward`, `eval_family_mem`

**Timing**: 2 hours

**Depends on**: none

**Completed**: 2026-05-29. All 426 lines sorry-free in CanonicalModel.lean.

**Verification**:
- `lake build Bimodal.Metalogic.BXCanonical.CanonicalModel` succeeds
- `#print axioms henkin_bfmcs` shows no `sorryAx`

---

### Phase 2: Restricted TC on Z via Family Proliferation [BLOCKED]

**BLOCKER** (Phase 2):
- **What failed**: The enriched chain construction proposed in this plan. Specifically, the enriched seed `{target} ∪ g_content(M) ∪ {F(χ) | F(χ) ∈ M, χ ≠ target}` can be INCONSISTENT.
- **What was tried**: (1) Enriched seed with F-formulas -- inconsistent when F(A) and F(neg A) coexist in M (documented in HenkinDiscreteChain.lean:27-28). (2) Enriched seed with deferral disjunctions (`ψ ∨ F(ψ)`) -- g_content(M) is NOT a subset of M under irreflexive semantics, so the union is not provably a subset of any consistent set. (3) Direct contradiction argument from L ⊢ ⊥ with L ⊆ enriched seed -- the temporal K distribution argument fails because G does not distribute over disjunction (case 2b analysis: from G(target → G(¬χ₁)) and F(target) and F(χ₁) in M, no contradiction derivable when F(χ₁) witness precedes F(target) witness). (4) Family proliferation -- restricted_tc requires witness in the SAME family, not a different one. (5) F-persistence through standard chain -- Lindenbaum is non-deterministic and can introduce G(¬φ), permanently killing F(φ) (documented in HenkinDiscreteChain.lean:42-49).
- **Why it's stuck**: Under irreflexive (strict) temporal semantics, g_content(M) ⊄ M (because G(φ) → φ is not valid), and F-formulas cannot be preserved through Lindenbaum extensions. The enriched seed approach (central to plan v5) is fundamentally unsound: `{target} ∪ g_content(M) ∪ {F(χ) | F(χ) ∈ M}` is NOT necessarily consistent even when each component is individually consistent with M. This makes it impossible to build a chain that both resolves F-formulas AND preserves unresolved ones.
- **What is needed**: A fundamentally different proof strategy for restricted_tc on Z. Possible directions: (a) Restricted MCS approach where Lindenbaum extensions are constrained to deferralClosure(root), providing negation completeness that guarantees F-persistence. (b) Proving `no_gaps_discrete` (Reynolds Theorem 14) to unblock the Reynolds pipeline path. (c) Proving `succ_cofinal` directly (but this was already shown to be blocked). (d) A truth lemma that does not require restricted_tc (e.g., a direct semantic evaluation that avoids the BFMCS infrastructure).
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.

**Goal**: Prove sorry-free `henkin_bfmcs_restricted_tc` for `henkin_bfmcs`. This is the F-resolution and P-resolution coherence condition. The approach abandons within-chain F-persistence (proved impossible) and instead uses family proliferation: given `F(phi) in fam.mcs(t)`, construct a NEW family in the BFMCS where phi appears at `t + 1`.

**Tasks**:
- [ ] **Helper lemma: `int_chain_fc_box_equiv`** -- prove that every chain point `int_chain_fc N h_N k` is box-equivalent to N: `forall psi, box(psi) in int_chain_fc N h_N k <-> box(psi) in N`. This follows from `box_stable_in_int_chain_fc` (already proved for the non-fc version; the fc version `box_stable_in_shifted_fmcs_fc` covers the shifted case).
- [ ] **Helper lemma: `chain_point_family_mem`** -- prove that for any family `shifted_bx_fmcs_fc N h_N s` in `henkin_bfmcs.families` and any integer k, the chain point `int_chain_fc N h_N (k - s)` generates a family `shifted_bx_fmcs_fc (int_chain_fc N h_N (k - s)) h_mcs_k k` that is also in `henkin_bfmcs.families`. Proof: the chain point is box-equivalent to N (by `int_chain_fc_box_equiv`), and N is box-equivalent to A (by henkin_bfmcs membership). Transitivity gives box-equivalence to A.
- [ ] **Helper lemma: `fresh_family_resolves_F`** -- given an MCS M containing `F(phi)` and M box-equivalent to A, the family `shifted_bx_fmcs_fc M h_M t` has `phi in mcs(t + 1)` (via `fwd_succ_fc_resolves` and the definition of `shifted_bx_fmcs_fc`).
- [ ] **Main theorem: `henkin_bfmcs_restricted_tc`** -- for each family and each `F(phi) in fam.mcs(t)`:
  1. Extract the chain point MCS: `M_t := int_chain_fc N h_N (t - s)` contains `F(phi)`
  2. M_t is box-equivalent to A (by `int_chain_fc_box_equiv` + transitivity)
  3. Build fresh family: `shifted_bx_fmcs_fc M_t h_mcs_t t` is in `henkin_bfmcs.families`
  4. By `fwd_succ_fc_resolves`: `phi in (shifted_bx_fmcs_fc M_t h_mcs_t t).mcs (t + 1)`
  5. BUT: we need `phi in fam.mcs(s')` for the SAME family fam, not a different family. The restricted TC definition says `exists s' > t, phi in fam.mcs s'`.

**CRITICAL CORRECTION**: The restricted_tc definition requires the witness in the SAME family. Family proliferation gives phi in a DIFFERENT family. This means the approach must resolve F(phi) WITHIN the given family `fam = shifted_bx_fmcs_fc N h_N s`.

**Revised approach**: For `F(phi) in fam.mcs(t)`, i.e., `F(phi) in int_chain_fc N h_N (t - s)`:
  1. The schedule `schedule n = phi` for some n (by `schedule_surjective_above`).
  2. At step n of the chain, `fwd_succ_fc` either resolves phi (if `F(phi)` is still present) or not.
  3. Key insight: `F(phi)` need not persist through g_content. Instead, use a Nat induction on the chain index. At each step k from `(t-s)` to n: either `phi in int_chain_fc N h_N (k+1)` (done), or `F(phi) in int_chain_fc N h_N (k+1)` (continue). The second case follows from: if `phi not in int_chain_fc N h_N (k+1)` then `neg(phi) in int_chain_fc N h_N (k+1)` (MCS), but `F(phi) in int_chain_fc N h_N k` means... we need `F(phi)` to survive to step k+1. Since g_content does NOT propagate `F(phi)`, this path is blocked.
  4. **Final revised approach**: Use the chain's own schedule-based resolution WITHOUT requiring F-persistence. The `fwd_succ_fc` at step n does: if `F(schedule n) in chain(n)`, resolve. But we need F(phi) to still be at chain(n). The REAL approach: since the chain builds successive MCS via Lindenbaum from `g_content(prev) union {phi}` (when resolving), and `g_content(prev)` contains all G-formulas from prev, and `G(F(phi))` is NOT in prev (since `F(phi) -> G(F(phi))` is not valid)... this is the same blocker.

**ACTUAL APPROACH (using subformula finiteness + chain restart)**: The restricted_tc definition only quantifies over `phi in deferralClosure(root)`, which is finite. For each such phi with `F(phi) in fam.mcs(t)`:
  1. Build a helper chain from `fam.mcs(t)` that immediately targets phi: `fwd_succ_fc (fam.mcs t) h_mcs_t phi` gives `phi in M_{t+1}` where `M_{t+1}` is an MCS.
  2. Show `M_{t+1} = int_chain_fc N' h_N' 1` for some N' box-equivalent to N.
  3. Since `int_chain_fc N' h_N' 1` at offset t corresponds to `shifted_bx_fmcs_fc N' h_N' t . mcs (t + 1)` and N' is box-equivalent to A, this family is in `henkin_bfmcs.families`.
  4. BUT AGAIN: the witness must be in the SAME family fam, not a new family.

**DEFINITIVE APPROACH**: The restricted TC definition requires the witness in the same family. But `henkin_bfmcs` families are chains `shifted_bx_fmcs_fc N h_N s` where the chain is deterministic (the schedule determines fwd_succ at each step). F(phi) resolution within a single chain requires phi to appear at SOME future chain point. The schedule ensures every formula is targeted infinitely often. At the step where schedule targets phi AND F(phi) is still present, fwd_succ_fc resolves it. The issue is proving F(phi) survives until that step.

**THE SOLUTION**: Use a custom chain construction for the discrete case. Instead of fwd_succ_fc which uses a fixed schedule, build a chain where the FIRST step resolves F(phi) immediately. Define `henkin_bfmcs` with richer families: instead of families being shifted chains from a single MCS, make each family a chain that INTERLEAVES schedule-based steps with F-resolution steps. Alternatively: define families more broadly so that any "F-resolution extension" of a family point yields a point in the SAME family.

**PRACTICAL APPROACH (recommended)**: Redefine `henkin_bfmcs` families to use a resolution-aware chain construction. At each step, the chain first resolves all outstanding `F(phi)` for phi in `deferralClosure(root)` before proceeding with the schedule. Since `deferralClosure(root)` is finite, this adds at most `|deferralClosure(root)|` extra resolution steps per schedule step. The chain is still Z-indexed (these extra steps are interleaved into the integer sequence). This "eager resolution" chain guarantees F(phi) is resolved within a bounded number of steps.

**SIMPLEST APPROACH**: Rather than redefining the chain, prove restricted TC by showing that the schedule resolves F(phi) eventually within the same chain. The key missing piece: prove that if `F(phi) in int_chain_fc N h_N k` and `schedule m = phi` and `F(phi) in int_chain_fc N h_N m` (i.e., F(phi) survived to step m), then `phi in int_chain_fc N h_N (m + 1)` by `fwd_succ_fc_resolves`. The question reduces to: does F(phi) survive from step k to step m? Prove by contradiction: suppose F(phi) disappears at some step j (i.e., `F(phi) not in int_chain_fc N h_N (j + 1)` but `F(phi) in int_chain_fc N h_N j`). Then `neg(F(phi)) = G(neg(phi)) in int_chain_fc N h_N (j + 1)`. Since G(neg(phi)) is a G-formula, `G(neg(phi)) in int_chain_fc N h_N j'` for all j' > j (by g_content propagation). So `neg(phi) in int_chain_fc N h_N j'` for all j' > j + 1 (by axiom temp_a: G applied to MCS membership). But `F(phi) in int_chain_fc N h_N k` means there should exist a future point with phi. From `G(neg(phi)) in int_chain_fc N h_N (j + 1)`, the MCS contains both F(phi) (from k, propagated? NO -- F(phi) was LOST at j + 1). Actually, `F(phi) not in int_chain_fc N h_N (j + 1)` by assumption (it disappeared). So there is no contradiction yet.

The issue is subtle: F(phi) CAN disappear, and when it does, G(neg(phi)) enters the chain, meaning phi will never appear again. This is exactly the blocker that killed plans v2-v4. The schedule would target phi at some step m > j, but since `G(neg(phi)) in int_chain_fc N h_N m` (propagated via g_content), the resolution step cannot place phi (it would be inconsistent with neg(phi) which follows from G(neg(phi))).

**RESOLUTION -- THE ACTUAL PATH FORWARD**: The chain construction MUST be modified to prevent F(phi) from being lost. The standard technique (Goldblatt, Gabbay-Hodkinson) is to use an "unravelling" or "step-by-step" construction where at each step, the Lindenbaum extension is constrained to preserve all outstanding F-obligations. Specifically, instead of extending from `g_content(M)` alone, extend from `g_content(M) union {F(phi) | F(phi) in M}`. This forces all F-formulas to persist.

Prove: `g_content(M) union {F(phi) | F(phi) in M}` is consistent. This follows from seriality + consistency of M. The g_content ensures all G-formulas persist, and the F-formula set is finitely satisfiable (each F(phi) is individually consistent with g_content(M) -- that's what fwd_succ_fc_resolves shows). The UNION of all F-formulas with g_content needs a compactness-like argument. Since M is an MCS and {F(phi) | F(phi) in M} is a subset of M, and g_content(M) is a subset of M, their union is a subset of M and hence consistent.

WAIT: `g_content(M) = {phi | G(phi) in M}`. So g_content(M) subset M by temp_a. And `{F(phi) | F(phi) in M}` is literally a subset of M. So `g_content(M) union {F(phi) | F(phi) in M}` is a subset of M, hence consistent.

The Lindenbaum extension of this set to an MCS will contain both g_content(M) and all F(phi) from M. Now define `fwd_succ_enriched M h_mcs phi_target`: extend from `g_content(M) union {F(psi) | F(psi) in M, psi != phi_target} union {phi_target}` when `F(phi_target)` in M (resolve phi_target while preserving all other F-obligations).

**CLEANER FORMULATION**: Define a new chain construction `enriched_fwd_succ_fc` that extends from `g_content(M) union {F(psi) | F(psi) in M and psi != schedule(n)} union {schedule(n) if F(schedule(n)) in M}`. This resolves schedule(n) while preserving all other F-formulas. Consistency: the resolving set is a subset of `fwd_succ_fc`'s resolving set (which is consistent) intersected with F-preservation (which is a subset of M, hence consistent with anything consistent with g_content(M)).

Actually, the simplest formulation: extend from `g_content(M) union {schedule(n)} union {F(psi) | F(psi) in M, psi != schedule(n)}` when `F(schedule(n)) in M`. The set is consistent because it is a subset of any MCS extending `g_content(M) union {schedule(n)}` (which `fwd_succ_fc` already shows is consistent when `F(schedule(n)) in M`). The F-preservation subset `{F(psi) | F(psi) in M, psi != schedule(n)}` is a subset of M, and g_content(M) subset M, and schedule(n) is placed by fwd_succ_fc, so the union is contained in `fwd_succ_fc M h_mcs (schedule n)` union {F(psi) | ...}. NO -- `fwd_succ_fc` does a Lindenbaum extension from `g_content(M) union {schedule(n)}`, and the result MAY OR MAY NOT contain the F-formulas.

**CORRECT APPROACH**: Extend from `g_content(M) union {schedule(n) if F(schedule(n)) in M} union {F(psi) | F(psi) in M, psi != schedule(n)}`. This is a subset of M (since g_content(M) subset M, F-formulas subset M, and schedule(n) is justified by F(schedule(n)) in M plus MCS consistency). Wait, schedule(n) itself may not be in M. We know F(schedule(n)) in M, which means "exists future point with schedule(n)", not "schedule(n) in M". But `g_content(M) union {schedule(n)}` IS consistent when `F(schedule(n)) in M` -- that's what fwd_succ_fc_resolves proves. The question is whether `g_content(M) union {schedule(n)} union {F(psi) | F(psi) in M, psi != schedule(n)}` is consistent. Since `{F(psi) | F(psi) in M} subset M` and `g_content(M) subset M` and M is consistent, the set `g_content(M) union {F(psi) | F(psi) in M}` is a subset of M and hence consistent. Adding schedule(n): need `g_content(M) union {F(psi) | F(psi) in M} union {schedule(n)}` consistent. This is `g_content(M) union {F(psi) | F(psi) in M, psi != schedule(n)} union {F(schedule(n))} union {schedule(n)}`. Since F(schedule(n)) implies the possibility of schedule(n), and the base set is consistent... this needs a proper semantic argument. In MCS terms: suppose the set is inconsistent. Then from `g_content(M) union {F(psi) | F(psi) in M}` (which is consistent, being a subset of M) we can derive `neg(schedule(n))`. But then `G(neg(schedule(n)))` follows from the derivation (since all premises are G-modalized or F-formulas, which are "future-persistent" in a semantic sense). With `G(neg(schedule(n)))` and `F(schedule(n))` both in M, M would be inconsistent. So the set is consistent.

This is the standard "enriched seed" construction from completeness proofs for temporal logics with Until (see Gabbay, Pnueli, Shelah, Stavi 1980; or Goldblatt 1992). The proof that the enriched seed is consistent is a standard compactness/MCS argument.

- [ ] **Define `enriched_fwd_succ_fc`** *(deviation: blocked -- enriched seed is inconsistent; see BLOCKER above)*
- [ ] **Prove enriched seed consistency** *(deviation: blocked -- the seed `{target} ∪ g_content(M) ∪ {F(ψ) | F(ψ) ∈ M, ψ ≠ target}` is NOT necessarily consistent; counterexample: when F(A) and F(¬A) both in M, the seed contains both the resolution target and conflicting F-formulas)*
- [ ] **Define `enriched_int_chain_fc`** *(deviation: blocked -- depends on enriched_fwd_succ_fc)*
- [ ] **Prove F-persistence in enriched chain** *(deviation: blocked -- depends on enriched chain)*
- [ ] **Prove F-resolution in enriched chain** *(deviation: blocked -- depends on enriched chain)*
- [ ] **Redefine `henkin_bfmcs` using enriched chains** *(deviation: blocked -- depends on enriched chain)*
- [ ] **Prove `henkin_bfmcs_restricted_tc`** *(deviation: blocked -- no viable proof strategy available; all known approaches are dead)*

**Timing**: 3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- add enriched chain construction and restricted_tc proof

**Verification**:
- `#print axioms henkin_bfmcs_restricted_tc` shows no `sorryAx`

---

### Phase 3: Restricted BUC and FUC on Z [NOT STARTED]

**Goal**: Prove sorry-free `henkin_bfmcs_restricted_buc` and `henkin_bfmcs_restricted_fuc` for `henkin_bfmcs` using the enriched chain construction from Phase 2.

**Tasks**:
- [ ] **Prove `henkin_bfmcs_restricted_buc`**: Backward Until/Since coherence (contrapositive direction). If `exists u > t, phi in fam.mcs(u) and guard(t,u)`, then `U(phi,psi) in fam.mcs(t)`. Proof by contrapositive: assume `neg(U(phi,psi)) in fam.mcs(t)`. From `until_induction` axiom (BX axiom): `G(psi -> chi) and G((phi and chi) -> G(chi)) -> (U(phi,psi) -> chi)`. Set chi = bot. Derive contradiction from the witness. This argument uses only MCS axiom closure and works on any linearly ordered domain -- Z needs no special treatment. Follow the pattern of `cantor_bfmcs_discrete_restricted_buc` in ChronicleToCountermodel.lean.
- [ ] **Prove BX5 deferral lemma for enriched chain**: `bx5_deferral_in_enriched_chain` -- If `U(phi, psi) in enriched_chain(k)` then either `phi in enriched_chain(k + 1)` or `(psi in enriched_chain(k + 1) and U(phi, psi) in enriched_chain(k + 1))`. Proof: BX5 is `U(phi, psi) -> phi or (psi and G(U(phi, psi)))`. Apply to MCS at step k. If first disjunct: phi at next step via g_content (actually phi may not be a G-formula... use Lindenbaum). If second disjunct: `psi in enriched_chain(k)` and `G(U(phi,psi)) in enriched_chain(k)`. The G-formula propagates through g_content: `U(phi,psi) in g_content(enriched_chain(k))`, hence `U(phi,psi) in enriched_chain(k+1)` (g_content propagation). And `psi in enriched_chain(k)` gives `G(psi) ...` NO, psi need not propagate. Actually: BX5 gives `psi in enriched_chain(k)` (not k+1). We need psi at intermediate points. The BX5 deferral gives: at step k, either phi (done) or (psi at k AND U(phi,psi) defers to k+1). So psi at k is the guard point, and U(phi,psi) at k+1 means the deferral continues. By induction: the guard covers k, k+1, ..., u-1 where phi appears at u.
- [ ] **Prove `henkin_bfmcs_restricted_fuc`**: Forward Until coherence. For `U(phi, psi) in fam.mcs(t)`:
  1. U(phi, psi) -> F(phi) by BX10. So `F(phi) in fam.mcs(t)`.
  2. By restricted TC (Phase 2): `exists u > t, phi in fam.mcs(u)`.
  3. By BX5 deferral lemma: at each step k from t to u-1, either phi appears (giving an earlier witness) or psi appears at k and U(phi,psi) defers to k+1.
  4. Take the FIRST k where phi appears. All earlier intermediate steps have psi (from the deferral). This gives the Until witness with guard.
  5. Nat induction on (u - t) handles termination.
- [ ] **Prove the Since direction**: Symmetric using BX5' (since axiom) and the backward enriched chain. Same structure.

**Timing**: 2.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- add restricted_buc and restricted_fuc proofs

**Verification**:
- `#print axioms henkin_bfmcs_restricted_buc` shows no `sorryAx`
- `#print axioms henkin_bfmcs_restricted_fuc` shows no `sorryAx`
- All three restricted coherence conditions verified sorry-free

---

### Phase 4: Integration and Verification [NOT STARTED]

**Goal**: Wire `henkin_bfmcs` with its sorry-free coherence proofs into `countermodel_discrete_enriched` in Completeness.lean, replacing the chronicle-based discrete path. Verify `completeness_discrete` is sorry-free.

**Tasks**:
- [ ] Define `henkin_countermodel_discrete_enriched` in CanonicalModel.lean (or a new file `HenkinCompleteness.lean`) mirroring the signature of `countermodel_discrete_enriched` but using `henkin_bfmcs`:
  ```
  theorem henkin_countermodel_discrete_enriched (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) (phi : Formula) (h_neg_in : phi.neg in A)
    (h_box_discrete : Formula.box next_top in A) :
    exists (F : TaskFrame Int) (TM : TaskModel F) (Omega : Set (WorldHistory F))
      (_ : ShiftClosed Omega) (tau : WorldHistory F) (_ : tau in Omega) (t : Int),
      not (truth_at TM Omega tau t phi)
  ```
- [ ] Wire into Completeness.lean: replace the call to `countermodel_discrete_enriched` in `completeness_discrete` with `henkin_countermodel_discrete_enriched`
- [ ] Run `#print axioms completeness_discrete` -- verify no `sorryAx`
- [ ] Run `#print axioms completeness` -- verify the general completeness theorem also benefits (if it uses completeness_discrete)
- [ ] Run `lake build` -- verify zero errors project-wide
- [ ] Update docstrings in Completeness.lean to reflect the new discrete path

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- update `countermodel_discrete_enriched` and `completeness_discrete`
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- add `henkin_countermodel_discrete_enriched`

**Verification**:
- `#print axioms completeness_discrete` shows `{propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound}` -- no `sorryAx`
- `lake build` passes with zero errors

## Testing & Validation

- [ ] `#print axioms completeness_discrete` shows no `sorryAx`
- [ ] `#print axioms henkin_bfmcs` shows no `sorryAx`
- [ ] `#print axioms henkin_bfmcs_restricted_tc` shows no `sorryAx`
- [ ] `#print axioms henkin_bfmcs_restricted_buc` shows no `sorryAx`
- [ ] `#print axioms henkin_bfmcs_restricted_fuc` shows no `sorryAx`
- [ ] `lake build` passes with zero errors
- [ ] No new sorry sites introduced (grep for `sorry` in modified files)
- [ ] Existing dense completeness path unaffected (`#print axioms completeness_dense` unchanged)

## Artifacts & Outputs

- `specs/202_reynolds_k_equivalence_bypass/plans/05_option-c-direct-z-v5.md` (this plan)
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- extended with enriched chain, BFMCS + coherence proofs
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- updated discrete path

## Rollback/Contingency

If the enriched seed consistency proof (Phase 2) is blocked:
1. Try the simpler argument: `g_content(M) union {F(psi) | F(psi) in M}` is a subset of M, hence consistent, hence extendable. The Lindenbaum extension preserves all F-formulas with probability proportional to... NO, Lindenbaum is non-deterministic. Use: extend from `g_content(M) union {F(psi) | F(psi) in M} union {target}` -- all elements are in M except possibly target, and target is consistent with g_content(M) (by fwd_succ_fc consistency). The full set is a subset of `M union {target}` which is consistent when `F(target) in M` (semantic argument: any model of M has a future point satisfying target, which also satisfies all F-formulas from M since they are future-directed).
2. If the enriched chain approach fails entirely, fall back to the chronicle's existing sorry-free `limit_F_resolution` / `limit_satisfies_c5_strong` proofs and prove local surjectivity: show that the specific C5 witnesses always land on embedded integer points (Critic's insight from team research).
3. If both fail, the Phase 1 BFMCS is still valuable infrastructure, and the sorry can be isolated to the enriched seed consistency lemma (smaller than succ_cofinal).

If Phase 3 (FUC) is blocked on the BX5 deferral:
1. Check whether the BX5 branch `psi and G(U(phi,psi))` correctly propagates through the enriched chain's g_content step (G(U(phi,psi)) IS a G-formula, so it should propagate)
2. Fall back to a direct construction: build an explicit Until witness by iterating fwd_succ_fc steps, placing psi at each intermediate integer via the BX5 deferral pattern
3. If both fail, isolate the sorry to `henkin_bfmcs_restricted_fuc` (smaller target than succ_cofinal)

Git safety: all work in new definitions/theorems; existing code is only modified in Phase 4 (integration). Reverting Phase 4 restores the previous state completely.
