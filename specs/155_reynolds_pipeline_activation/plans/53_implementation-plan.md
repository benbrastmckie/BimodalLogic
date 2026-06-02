# Implementation Plan: Task #155 (v53 -- Henkin BFMCS)

- **Task**: 155 - Close countermodel_discrete_reynolds sorry and rewire completeness_discrete
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (henkin_bfmcs already exists sorry-free in CanonicalModel.lean)
- **Research Inputs**: Team research rounds 1-12 (Z+Z counterexample, Box handling analysis, dense completeness proof study), plan v52 implementation experience (parametric canonical model works but depends on succ_embed_surjective through cantor_bfmcs_discrete)
- **Artifacts**: plans/53_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Replace the `cantor_bfmcs_discrete` BFMCS (which routes through the chronicle's limit domain and `succ_embed_surjective`) with `henkin_bfmcs` (which constructs FMCS families directly on Z via Henkin chains) in the `countermodel_discrete_reynolds` proof. The `henkin_bfmcs` bundle already has sorry-free `modal_forward`/`modal_backward` proofs. The missing pieces are three restricted coherence conditions (`restricted_tc`, `restricted_buc`, `restricted_fuc`) that the `fully_restricted_parametric_completeness_from_neg_membership` truth lemma requires. Once these are proved for `henkin_bfmcs`, the entire discrete completeness theorem becomes sorry-free with respect to the succ_embed/chronicle chain.

### Research Integration

Three rounds of team research (12 agents) established:

1. **Box handling is domain-generic.** The parametric canonical model (`ParametricCanonicalTaskFrame`, `ParametricCanonicalTaskModel`) and truth lemma work identically for D=Rat and D=Int. Only the BFMCS construction and its restricted coherence proofs are domain-specific.

2. **The Henkin chain resolves formulas by construction.** `fwd_succ_fc_resolves` ensures that if `F(psi) in M` then `psi in fwd_succ_fc(M, psi)`. Combined with `schedule_surjective_above` (every formula is scheduled infinitely often), this gives restricted_tc: `F(phi) in chain(t)` implies phi appears at some future step.

3. **Until/Since coherence follows from MCS properties.** The backward direction (restricted_buc) uses the contrapositive: if the Until witness pattern holds but `U(phi,psi) not in fam.mcs(t)`, then `neg(U(phi,psi)) in fam.mcs(t)` by MCS completeness, and from `neg(U(phi,psi))` plus the witness we derive contradiction via the Until axioms. The forward direction (restricted_fuc) uses the Henkin chain's resolution of Until formulas.

4. **The Z+Z counterexample kills all succ_embed approaches.** `IsSuccArchimedean` is unprovable for abstract discrete orders with one modal class. `succ_embed_surjective` depends on it. The Henkin construction bypasses this entirely by working on Z from the start.

### Prior Plan Reference

Plan v52 successfully rewired `completeness_discrete` to use `countermodel_discrete_reynolds`, but the proof still routes through `cantor_bfmcs_discrete` which depends on `succ_embed_surjective` (sorry). The parametric canonical model approach (Phase 2 of v52) works -- the deviation was that Phases 1-2 were bypassed by using the parametric canonical model directly. However, the sorry from `succ_embed_surjective` persists in `cantor_bfmcs_discrete_restricted_tc` and `cantor_bfmcs_discrete_restricted_fuc`. This plan v53 replaces the BFMCS source (`cantor_bfmcs_discrete` -> `henkin_bfmcs`) to eliminate that sorry chain entirely.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Prove `henkin_bfmcs_restricted_tc` (restricted temporal coherence for the Henkin BFMCS)
- Prove `henkin_bfmcs_restricted_buc` (restricted backward Until/Since coherence)
- Prove `henkin_bfmcs_restricted_fuc` (restricted forward Until/Since coherence)
- Rewire `countermodel_discrete_reynolds` to use `henkin_bfmcs` instead of `cantor_bfmcs_discrete`
- `#print axioms completeness_discrete` shows no `sorryAx` from the succ_embed chain
- `lake build` passes with zero errors

**Non-Goals**:
- Proving `IsSuccArchimedean` (abandoned; Z+Z counterexample)
- Closing sorries in `succ_cofinal`, `succ_embed_surjective`, or `limitDomSubtype_isSuccArchimedean` (dead code)
- Modifying the dense case (`cantor_bfmcs_dense` is already sorry-free)
- Archiving dead BX/chronicle code (separate task 255)
- Modifying `henkin_bfmcs` itself (already sorry-free)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Until/Since forward coherence (restricted_fuc) may not follow directly from Henkin chain properties; Until formulas might not be scheduled/resolved by the chain | H | M | The chain resolves F/P formulas via `schedule_surjective_above`. Until formulas are handled differently: `U(phi,psi) in MCS(t)` means the witness exists in the MCS's deductive closure. Use `until_forward_witness_exists` (or derive it from MCS properties + Until axioms) to find the actual integer witness. Fallback: prove full `forward_until_since_coherent` for the Henkin chain using `until_unfold` axiom induction. |
| The backward Until/Since coherence proof (restricted_buc) requires the contrapositive argument to work for the Henkin chain, which means `neg(U(phi,psi)) in chain(t)` plus a witness pattern must yield contradiction | M | L | The dense case template uses `limit_satisfies_c4`/`c4'` (chronicle C4 condition). For the Henkin chain, the equivalent is: `neg(U(phi,psi)) in MCS(t)` and `phi in MCS(u)` with guard gives `neg(psi) in MCS(r)` for some `t < r < u`. This follows from Until axioms in the MCS (deductive closure). The proof pattern mirrors `cantor_bfmcs_dense_restricted_buc` but operating directly on integers instead of through an isomorphism. |
| Henkin chain may not satisfy Until/Since resolution because the schedule only targets F/P formulas, not Until/Since | H | M | Re-examine `fwd_succ_fc`: it uses `forward_temporal_witness_seed` which includes the Until witness in the seed set. Verify that `forward_temporal_witness_seed` resolves Until formulas. If not, the forward coherence proof must use MCS deductive properties (Until axioms) rather than chain resolution. |
| The `rooted_henkin_fmcs` analog (shifted version for the BFMCS root family) needs to be defined and its `at_s` lemma proved | L | L | `shifted_bx_fmcs_fc` already exists and `shifted_bx_fmcs_fc_at_s` is proved. The Henkin BFMCS uses exactly these shifted families, so no new definitions are needed -- just use the existing `henkin_bfmcs.eval_family`. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Prove Restricted Coherence for henkin_bfmcs [BLOCKED]

**Goal**: Prove the three restricted coherence conditions (`restricted_tc`, `restricted_buc`, `restricted_fuc`) for `henkin_bfmcs`. These are the only missing pieces for plugging `henkin_bfmcs` into the parametric truth lemma.

**Strategy**:

Each coherence proof is a theorem about the Henkin BFMCS bundle. The families in `henkin_bfmcs` are `shifted_bx_fmcs_fc N h_N s` for box-equivalent MCS N. Each family's `mcs(t) = int_chain_fc N h_N (t - s)`.

**1a. restricted_tc (temporal coherence)**:

Goal: `F(phi) in fam.mcs(t) -> exists s > t, phi in fam.mcs(s)` (and P symmetrically).

Proof sketch for forward F direction:
- `fam = shifted_bx_fmcs_fc N h_N s`, so `fam.mcs(t) = int_chain_fc N h_N (t - s)`
- `F(phi) in int_chain_fc N h_N (t - s)` means `F(phi) in MCS_{t-s}`
- By `schedule_surjective_above`: there exists `k >= max(0, t-s)` with `schedule(k) = phi`
- The forward chain at step `k+1` resolves phi: `fwd_succ_fc(chain(k), schedule(k)) = fwd_succ_fc(chain(k), phi)`
- By `fwd_chain_fc_g_content_trans` from step `t-s` to step `k`: `g_content(chain(t-s)) subset chain(k)`, so `G(phi) in chain(k)`, hence `F(phi) in chain(k)` (from G subset)
- Wait -- we need `F(phi)` to propagate forward. The key: `F(phi) in chain(t-s)` means `G(phi) in chain(t-s)` (since F(phi) = neg(G(neg(phi)))... no, F is some_future, not all_future).
- Better approach: Use the chain's g_content propagation. If `F(phi) in MCS_n` and `n < k`, then by the chain construction, `G(F(phi)) in MCS_n` (by `all_future_of_some_future`), so `F(phi) in MCS_k` (by g_content propagation). Then at step `k+1`, `fwd_succ_fc_resolves` gives `phi in MCS_{k+1}`.
- Set `s_witness = (k+1) + s` to get `phi in fam.mcs(s_witness)` with `s_witness > t`.

The backward P direction is symmetric using `bwd_pred_fc_resolves` and `schedule_surjective_above`.

**1b. restricted_buc (backward Until/Since coherence)**:

Goal (Until backward, contrapositive): If `exists u > t, phi in fam.mcs(u)` and `forall r in (t,u), psi in fam.mcs(r)`, then `U(phi,psi) in fam.mcs(t)`.

Proof sketch (contrapositive -- assume `U(phi,psi) not in fam.mcs(t)`):
- `neg(U(phi,psi)) in fam.mcs(t)` by MCS completeness
- We have a witness `u > t` with `phi in fam.mcs(u)` and guard `psi in fam.mcs(r)` for `t < r < u`
- Need: contradiction
- By the Until induction axiom: `neg(U(phi,psi))` propagates forward through the chain (via `induction_until` axiom or equivalent). Specifically, `neg(U(A,B)) -> neg(B)` and `neg(U(A,B)) -> neg(A) | G(neg(U(A,B)))`. The first gives `neg(psi) in fam.mcs(t)`. But we need `neg(psi)` at an *intermediate* point to contradict the guard. Actually, `neg(U(A,B)) -> neg(B) & (neg(A) | G(neg(U(A,B))))`. If `neg(A) in fam.mcs(t)`, then since `phi in fam.mcs(u)` we need phi = A, and we need neg(A) to propagate... this gets complex.
- Simpler approach: Use `until_unfold` axiom directly. `U(phi,psi) <-> psi | (phi & F(U(phi,psi)))`. The backward direction says: if the witness pattern holds, then `U(phi,psi)` holds by induction on the gap `u - t`. For `u = t+1`: `phi in fam.mcs(t+1)` and the guard is vacuous (no integer strictly between t and t+1), so `U(phi,psi) in fam.mcs(t)` follows from... actually this needs `F(phi) in fam.mcs(t)` which needs `phi in fam.mcs(t+1)` which we have, plus the chain's g_content property gives `G(phi) in fam.mcs(t)` only for the reverse. Need `F(phi) in fam.mcs(t)`.
- Actually, the backward Until/Since coherence for the dense case uses `limit_satisfies_c4`/`c4'`. For the Henkin chain, the equivalent property must be established: if `neg(U(phi,psi)) in int_chain_fc N h_N n` and `phi in int_chain_fc N h_N m` (with `n < m`), then there exists `n < k < m` with `neg(psi) in int_chain_fc N h_N k`. This is the C4 condition for the Henkin chain.
- Prove the C4 condition for the Henkin chain from the Until axioms in the MCS. The key axiom: `neg(U(A,B)) -> neg(B) & (neg(A) | G(neg(U(A,B))))`. By induction on `m - n`: at each step, either `neg(A) in chain(n)` (and A = phi, contradicting phi in chain(m) via... no), or `G(neg(U(A,B))) in chain(n)`, which gives `neg(U(A,B)) in chain(n+1)`. Continue until we reach step m-1. At step m-1, `neg(U(A,B)) in chain(m-1)`, so `neg(B) in chain(m-1)`. But `psi = B` and `m-1` is strictly between `n` and `m` (if m > n+1). If `m = n+1`, the gap is empty and backward coherence is vacuously satisfied. So we set `k = n` and note `neg(psi) in chain(n)`. But k must be strictly between n and m. Actually for m = n+1 there is no such k, so the Until backward direction is vacuously true! For m > n+1, take k = n+1: `neg(U(phi,psi)) in chain(n+1)` (from propagation), so `neg(psi) in chain(n+1)`, and `n < n+1 < m`.

**1c. restricted_fuc (forward Until/Since coherence)**:

Goal: `U(phi,psi) in fam.mcs(t) -> exists u > t, phi in fam.mcs(u) & guard`.

Proof sketch:
- `U(phi,psi) in fam.mcs(t)`, i.e., `U(phi,psi) in int_chain_fc N h_N (t - s)`
- By `until_unfold`: `U(A,B) -> B | (A & F(U(A,B)))`. So either `psi in chain(t-s)` (immediate witness with degenerate gap) or `phi in chain(t-s) & F(U(phi,psi)) in chain(t-s)`.
- If `psi in chain(t-s)`: take `u = t+1`... no, we need `phi in fam.mcs(u)`, not psi. Wait, `U(phi,psi)` means "psi holds at some future point, and phi guards until then." So the witness has `psi in fam.mcs(u)` and `phi in fam.mcs(r)` for `t < r < u`. Let me re-read the definition.
- From the definition: `U(phi,psi) in fam.mcs(t) -> exists s > t, phi in fam.mcs(s) & forall r in (t,s), psi in fam.mcs(r)`. Wait, checking the restricted_fuc definition: `exists s > t, phi in fam.mcs(s) & forall r, t < r -> r < s -> psi in fam.mcs(r)`. So phi is at the endpoint s and psi guards the interval (t,s). This matches `U(psi, phi)` in some conventions... Let me re-read.
- From TemporalCoherence.lean line 536-545: `Formula.untl phi psi in fam.mcs t -> exists s > t, phi in fam.mcs s & forall r, t < r -> r < s -> psi in fam.mcs r`. So `untl phi psi` = "Until(phi, psi)" where phi is the *goal* (reached at s) and psi is the *guard* (holds between t and s).
- The `until_unfold` axiom gives: `U(phi,psi) <-> phi | (psi & F(U(phi,psi)))`. So either phi holds now (take s = t+1? no, s > t and phi at s)... Actually in our convention `U(phi,psi)` unfolds to `phi` (goal reached) or `psi & F(U(phi,psi))` (guard holds now, Until continues). So if phi in chain(t-s), we need s = t-s... that's the current point, not future.
- Better: use `schedule_surjective_above` to find a step where `U(phi,psi)` is targeted, then `fwd_succ_fc_resolves` resolves it. But `fwd_succ_fc` resolves F(chi), not U(chi1,chi2) directly.
- The forward Until coherence is the hardest part. The dense case uses `limit_satisfies_c5_strong` (chronicle C5 condition). For the Henkin chain, we need the analogous property.
- Key insight: by repeated application of `until_unfold`, `U(phi,psi) in chain(n)` gives either `phi in chain(n)` (immediate) or `psi in chain(n) & F(U(phi,psi)) in chain(n)`. In the latter case, `F(U(phi,psi))` gets resolved by `fwd_succ_fc_resolves` at some future step k (via `schedule_surjective_above`), giving `U(phi,psi) in chain(k)`. Recurse. By well-foundedness (or rather, by the fact that eventually we must hit the phi case because the MCS is consistent and U(phi,psi) can't loop forever without phi being reached -- this is the model existence argument)...
- Actually, we do NOT need well-foundedness here. We can use the constructive schedule: at each step where U(phi,psi) is in the chain, if phi is not there, then psi is (guard), and F(U(phi,psi)) is in the chain, which propagates U(phi,psi) forward. But we need phi to eventually appear. This follows from consistency: if U(phi,psi) is in every chain MCS but phi never appears, then neg(phi) would need to be consistent with U(phi,psi), but `U(phi,psi) -> F(phi)` is a theorem (Until implies the goal is eventually reached). So `F(phi) in chain(n)`, and by restricted_tc (already proved in 1a), `phi in chain(k)` for some k > n.
- So the proof strategy is: from `U(phi,psi) in chain(t-s)`, derive `F(phi) in chain(t-s)` via Until axioms, then use restricted_tc to get `phi in chain(k)` for some `k > t-s`. The guard `psi` at intermediate points follows from the Until propagation: at each step between `t-s` and `k`, either phi holds (and we found our witness earlier) or psi holds (guard maintained). This induction on `k - (t-s)` establishes the guard.

**BLOCKER** (Phase 1):
- **What failed**: The plan assumes `F(phi) -> G(F(phi))` (called `all_future_of_some_future`) is derivable, enabling F-formula propagation along the Henkin chain. This formula is NOT a theorem of our temporal logic (and is not semantically valid on integers under strict/irreflexive semantics).
- **What was tried**: (1) Attempted to derive `F(phi) -> G(F(phi))` from BX axioms -- impossible because `F(phi)` at time t means phi holds at some s > t, but at time r > t, the witness s might not satisfy s > r. (2) Attempted to use BX4 (`phi -> G(P(phi))`) to propagate F(phi) -- gives `G(P(F(phi)))` not `G(F(phi))`. (3) Attempted to use BX5 self-accumulation -- gives semantic enrichment of guard but no syntactic propagation to other chain elements. (4) Attempted contradiction argument assuming phi never appears -- `F(phi) in chain(n)` is syntactically consistent with `neg(phi) in chain(m)` for all m > n because `F(phi)` is just a formula in an MCS, not a semantic assertion about the chain.
- **Why it's stuck**: The Henkin chain preserves g_content (G-formulas) along the chain via `g_content(chain(n)) ⊆ chain(n+1)`. But F-formulas (`F(phi) = untl(phi, top)`) are NOT in g_content unless `G(F(phi)) in chain(n)`, which requires the unprovable `F(phi) -> G(F(phi))`. At each Lindenbaum extension step, `F(phi)` can be "lost" -- the extension might choose `G(neg(phi))` instead, permanently preventing phi from appearing in any future chain step. Once `G(neg(phi))` enters the chain, it propagates via temp_4 to all subsequent steps, making `neg(phi)` permanent. This means `restricted_tc` (F(phi) in chain(n) implies phi in chain(m) for some m > n) does NOT hold for the Henkin chain as constructed. The same issue blocks `restricted_fuc` since it depends on `restricted_tc` (plan Task 1.7 derives restricted_fuc from restricted_tc + BX10).
- **What is needed**: One of: (A) Modify the chain construction to preserve F-formulas -- e.g., include all F-witnesses from deferralClosure(root) in the Lindenbaum seed at each step. This requires proving `{chi | F(chi) in M, chi in deferralClosure(root)} ∪ g_content(M)` is consistent, which is non-trivial because conjunction of eventualities ≠ eventuality of conjunction. (B) Use a different BFMCS construction that satisfies all three coherence conditions on Z without succ_embed_surjective. (C) Close the Reynolds model surgery sorry (`gap_prior_UZ_contradiction` in GoodStructuresModelSurgery.lean) which would give sorry-free `no_gaps_discrete_model_surgery` and enable an alternative path to completeness_discrete. (D) Prove `IsSuccArchimedean` for the specific chronicle limit domain (not abstract discrete orders) by showing all limit domain points are in the succ/pred orbit of 0.
- **Key finding**: `cantor_bfmcs_discrete_restricted_buc` is ALREADY sorry-free (no sorryAx in axiom dependencies). Only `restricted_tc` and `restricted_fuc` carry sorryAx via `succ_embed_surjective`.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder

**Tasks**:
- [ ] **Task 1.1**: Prove `all_future_of_some_future` for the fc-parametric chain *(deviation: skipped -- F(phi) -> G(F(phi)) is not a theorem of the logic)* (if not already available): `F(phi) in MCS -> G(F(phi)) in MCS` (this is `SetMaximalConsistent.all_future_of_some_future` or derived from temp_4_future: `F(phi) -> G(F(phi))`). Verify this is available at the fc level (not just Base).
- [ ] **Task 1.2**: Prove `henkin_bfmcs_restricted_tc` in a new section of CanonicalModel.lean (or a new file). Use `schedule_surjective_above` + `fwd_succ_fc_resolves` for the forward direction, `schedule_surjective_above` + `bwd_pred_fc_resolves` for the backward direction. The key propagation step: `F(phi) in chain(n)` implies `G(F(phi)) in chain(n)` (from temp_4_future axiom), so `F(phi) in chain(k)` for all `k >= n` (by g_content propagation), enabling resolution at the scheduled step.
- [ ] **Task 1.3**: Prove `int_chain_fc_c4` (C4 condition for Henkin chain): `neg(U(phi,psi)) in chain(n)` and `phi in chain(m)` with `n < m` implies `exists k, n < k < m, neg(psi) in chain(k)`. Use the Until induction axiom (`neg(U(A,B)) -> neg(B) & (neg(A) | G(neg(U(A,B))))`) applied inductively along the chain.
- [ ] **Task 1.4**: Prove `int_chain_fc_c4'` (C4' for Since, symmetric): `neg(S(phi,psi)) in chain(n)` and `phi in chain(m)` with `m < n` implies `exists k, m < k < n, neg(psi) in chain(k)`.
- [ ] **Task 1.5**: Prove `henkin_bfmcs_restricted_buc` using `int_chain_fc_c4`/`c4'` (contrapositive argument, following the `cantor_bfmcs_dense_restricted_buc` template but without isomorphism translation).
- [ ] **Task 1.6**: Prove `until_implies_some_future_goal` (if not already available): `U(phi,psi) -> F(phi)` as a derivation tree. This follows from the Until axioms.
- [ ] **Task 1.7**: Prove `int_chain_fc_c5` (C5 condition for Henkin chain): `U(phi,psi) in chain(n)` implies `exists m > n, phi in chain(m) & forall k in (n,m), psi in chain(k)`. Use `until_implies_some_future_goal` to get `F(phi) in chain(n)`, then `restricted_tc` (from Task 1.2) to get `phi in chain(m)`. The guard follows from Until propagation along the chain: at each step between n and m, `U(phi,psi)` unfolds to give psi (or phi at that step, making it the witness instead).
- [ ] **Task 1.8**: Prove `int_chain_fc_c5'` (C5' for Since, symmetric).
- [ ] **Task 1.9**: Prove `henkin_bfmcs_restricted_fuc` using `int_chain_fc_c5`/`c5'`, following the `cantor_bfmcs_dense_restricted_fuc` template.
- [ ] **Task 1.10**: Verify `lake build Bimodal.Metalogic.BXCanonical.CanonicalModel` passes (or the new file if using a separate module).

**Timing**: 5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- add restricted coherence theorems after `henkin_bfmcs` (or create a new file `CanonicalModelCoherence.lean` if the file is too large)

**Verification**:
- All three restricted coherence theorems type-check without sorry
- `lake build` for the module passes

---

### Phase 2: Rewire countermodel_discrete_reynolds Through henkin_bfmcs [NOT STARTED]

**Goal**: Replace `cantor_bfmcs_discrete` with `henkin_bfmcs` in `countermodel_discrete_reynolds` (Transfer.lean), and update the `countermodel_discrete_enriched` proof in Completeness.lean to use the new BFMCS. This eliminates the `succ_embed_surjective` sorry from the discrete completeness path.

**Strategy**:

The current `countermodel_discrete_reynolds` (Transfer.lean:1203-1247) does:
```
let bfmcs := Chronicle.cantor_bfmcs_discrete fc A h_mcs h_box_discrete
let fam0 := Chronicle.rooted_succ_discrete_fmcs fc A h_mcs h_box_discrete 0
...
fully_restricted_parametric_completeness_from_neg_membership bfmcs phi
  (cantor_bfmcs_discrete_restricted_tc ...)
  (cantor_bfmcs_discrete_restricted_buc ...)
  (cantor_bfmcs_discrete_restricted_fuc ...)
```

Replace with:
```
let bfmcs := BXCanonical.henkin_bfmcs fc A h_mcs
let fam0 := BXCanonical.shifted_bx_fmcs_fc A h_mcs 0  -- the eval_family
...
fully_restricted_parametric_completeness_from_neg_membership bfmcs phi
  (henkin_bfmcs_restricted_tc ...)
  (henkin_bfmcs_restricted_buc ...)
  (henkin_bfmcs_restricted_fuc ...)
```

Key details:
- `henkin_bfmcs` does NOT require `h_box_discrete` -- it works for any fc-MCS. However, `countermodel_discrete_reynolds` is called in the discrete branch where `h_box_discrete` is available. The henkin_bfmcs construction does not use it (the chain is built from any MCS), which is fine.
- The eval_family of `henkin_bfmcs` is `shifted_bx_fmcs_fc A h_mcs 0`, and `shifted_bx_fmcs_fc_at_s` gives `(shifted_bx_fmcs_fc A h_mcs 0).mcs 0 = A`.
- The membership proof `fam0 in bfmcs.families` is `henkin_bfmcs.eval_family_mem`.
- `h_neg_fam : phi.neg in fam0.mcs 0` follows from `shifted_bx_fmcs_fc_at_s` + `h_neg_in`.
- The `countermodel_discrete_enriched` in Completeness.lean uses the same pattern and should be updated similarly.

**Tasks**:
- [ ] **Task 2.1**: Rewrite `countermodel_discrete_reynolds` in Transfer.lean to use `henkin_bfmcs` instead of `cantor_bfmcs_discrete`. Update the BFMCS, root family, membership proof, and coherence condition arguments.
- [ ] **Task 2.2**: Update `countermodel_discrete_enriched` in Completeness.lean similarly (or verify it already works via the updated `countermodel_discrete_reynolds`).
- [ ] **Task 2.3**: Verify the `h_neg_fam` proof works with `shifted_bx_fmcs_fc_at_s` (should be straightforward).
- [ ] **Task 2.4**: Verify `lake build Bimodal.Metalogic.WeakCanonical.Transfer` passes.
- [ ] **Task 2.5**: Verify `lake build Bimodal.Metalogic.BXCanonical.Completeness` passes.

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- rewrite `countermodel_discrete_reynolds`
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- update `countermodel_discrete_enriched` if needed

**Verification**:
- `countermodel_discrete_reynolds` uses `henkin_bfmcs` (grep confirms no reference to `cantor_bfmcs_discrete`)
- `lake build` for both modules passes
- No `sorry` in `countermodel_discrete_reynolds`

---

### Phase 3: Verification, Axiom Audit, and Documentation [NOT STARTED]

**Goal**: Full build verification, axiom audit confirming `sorryAx` is eliminated from the discrete completeness path, and documentation updates.

**Tasks**:
- [ ] **Task 3.1**: Run full `lake build` and verify zero errors.
- [ ] **Task 3.2**: Run `lake env lean --stdin <<< '#print axioms Bimodal.Metalogic.BXCanonical.completeness_discrete'` and verify no `sorryAx` in the output (or add temporary `#print axioms` in Completeness.lean).
- [ ] **Task 3.3**: Update docstrings on `countermodel_discrete_reynolds` to reflect that it now uses `henkin_bfmcs` (no chronicle, no succ_embed).
- [ ] **Task 3.4**: Update the Sorry Dependency Tree comments in Completeness.lean to reflect the eliminated sorry chain.
- [ ] **Task 3.5**: Update the module-level docstring in Transfer.lean to reference `henkin_bfmcs` instead of `cantor_bfmcs_discrete`.
- [ ] **Task 3.6**: If `completeness_discrete` still shows `sorryAx`, trace the dependency to identify remaining sorry sources (may be from other modules, not the discrete BFMCS path).

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- update docstrings
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- update axiom audit comments, sorry chain documentation
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- add docstrings for new coherence theorems

**Verification**:
- `#print axioms completeness_discrete` shows no `sorryAx`
- `lake build` passes with zero errors
- All docstrings accurately reflect current proof state

## Testing & Validation

- [ ] `henkin_bfmcs_restricted_tc` has no sorry after Phase 1
- [ ] `henkin_bfmcs_restricted_buc` has no sorry after Phase 1
- [ ] `henkin_bfmcs_restricted_fuc` has no sorry after Phase 1
- [ ] `lake build Bimodal.Metalogic.BXCanonical.CanonicalModel` passes after Phase 1
- [ ] `countermodel_discrete_reynolds` references `henkin_bfmcs` (not `cantor_bfmcs_discrete`) after Phase 2
- [ ] `lake build Bimodal.Metalogic.WeakCanonical.Transfer` passes after Phase 2
- [ ] `lake build Bimodal.Metalogic.BXCanonical.Completeness` passes after Phase 2
- [ ] `#print axioms completeness_discrete` shows no `sorryAx` after Phase 3
- [ ] Full `lake build` passes with zero errors after Phase 3

## Artifacts & Outputs

- plans/53_implementation-plan.md (this file)
- summaries/53_execution-summary.md (to be created at implementation completion)

## Rollback/Contingency

If the restricted coherence proofs for `henkin_bfmcs` prove intractable:

1. **Fallback A (restricted_fuc via full temporal coherence)**: If the Until forward coherence is hard to prove directly, first prove full `temporally_coherent` for `henkin_bfmcs` (which implies `restricted_temporally_coherent` and then use the existing `forward_implies_restricted_forward` and `backward_implies_restricted_backward` theorems). Full temporal coherence might be easier to prove in bulk than the restricted versions separately.

2. **Fallback B (hybrid BFMCS)**: Keep `cantor_bfmcs_discrete` for the Until/Since coherence proofs (which don't use `succ_embed_surjective`) and only replace the temporal coherence source. The restricted_tc is the one that depends on `succ_embed_surjective`; restricted_buc does not. Check if restricted_fuc depends on it.

3. **Fallback C (separate Until/Since resolution chain)**: If the schedule-based chain doesn't resolve Until formulas naturally, extend the chain construction to also schedule Until/Since formulas. Define a modified `fwd_succ_fc` that resolves both `F(phi)` and `U(phi,psi)` at each step when scheduled. This changes `CanonicalModel.lean` but preserves the Henkin approach.

4. **Fallback D (accept remaining sorry)**: If the coherence proofs are genuinely intractable in this plan cycle, document the blocker precisely and create a focused follow-up task. The current state (sorry in `succ_embed_surjective`) is preserved as the baseline.
