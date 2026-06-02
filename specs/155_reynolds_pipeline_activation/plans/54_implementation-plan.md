# Implementation Plan: Task #155 (v54 -- Modified Henkin Chain with Temporal Resolution)

- **Task**: 155 - Close countermodel_discrete_reynolds sorry and rewire completeness_discrete
- **Status**: [BLOCKED]
- **Effort**: 12 hours
- **Dependencies**: None (all infrastructure exists: henkin_bfmcs, fwd_succ_fc, schedule_surjective_above, forward_temporal_witness_seed)
- **Research Inputs**: Plans v50-v53 (import cycle analysis, Z+Z counterexample, parametric canonical model), v53 blocker analysis (F(phi)->G(F(phi)) is not a theorem), user-provided v54 approach (Burgess-Xu style modified Henkin chain)
- **Artifacts**: plans/54_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v53 failed because the existing `henkin_bfmcs` Henkin chain only propagates G-content forward (via `g_content` in `fwd_succ_fc`). It does NOT resolve F-formulas: if `F(phi)` is in `chain(n)`, the Lindenbaum extension at step `n+1` may choose `G(neg(phi))` instead of `phi`, permanently preventing phi from appearing. Since `F(phi) -> G(F(phi))` is not a theorem under strict/irreflexive semantics, F-formulas can be lost at each step, making `restricted_tc` and `restricted_fuc` unprovable.

This plan v54 builds a **modified Henkin chain** (Burgess-Xu style) that resolves ALL temporal witnesses -- not just G-propagation, but also F, P, U, S. The key modification: at each step `n`, instead of seeding only with `g_content(chain(n))`, the construction seeds with `g_content(chain(n)) union {phi}` where `phi` is the scheduled formula and `F(phi)` is in `chain(n)`. This ensures phi lands directly in the chain, resolving the F-formula. The critical proof obligation is showing this enlarged seed is consistent, which follows from: `F(phi) in chain(n)` implies `G(neg(phi)) not in chain(n)` (by MCS consistency + temporal axiom `F = neg(G(neg))`) implies `neg(phi) not in g_content(chain(n))`.

This is exactly what `fwd_succ_fc` already does -- it uses `forward_temporal_witness_seed M psi = {psi} union g_content(M)` when `F(psi) in M`. The existing chain resolves ONE scheduled formula per step. The issue is that between step `n` (where `F(phi) in chain(n)`) and the scheduled step `k` (where `schedule(k) = phi`), the F-formula may be lost because it is not in g_content. The solution: prove that `F(phi)` DOES persist until the scheduled step, OR restructure the chain to schedule F-formulas more tightly.

### Research Integration

53 plans and 40+ research reports established:

1. The Z+Z counterexample kills all `succ_embed_surjective` approaches (plan v50-v52).
2. `F(phi) -> G(F(phi))` is not a theorem (plan v53 blocker).
3. `cantor_bfmcs_discrete_restricted_buc` is already sorry-free -- only `restricted_tc` and `restricted_fuc` carry sorryAx via `succ_embed_surjective`.
4. The dense case proves all three restricted coherence conditions sorry-free via `cantor_iso_dense` (Cantor isomorphism maps limit domain to Q bijectively).
5. The existing `fwd_succ_fc` already resolves the scheduled formula when `F(psi) in M` -- it includes `psi` in the seed via `forward_temporal_witness_seed`.

### Prior Plan Reference

Plan v53 correctly identified `henkin_bfmcs` as the BFMCS to use (Z-native, no chronicle/limit domain indirection) but failed because it assumed F-formulas would persist via `all_future_of_some_future` (which is not a theorem). The v53 blocker analysis is the key input: the chain resolves F(psi) at step n+1 only when `schedule(n) = psi` AND `F(psi) in chain(n)`. If F(psi) was lost between the original assertion and the scheduled step, resolution fails.

Lessons: (a) restricted_buc is already done, (b) restricted_tc and restricted_fuc are the only targets, (c) the chain construction itself may need modification, not just new proofs about the existing chain.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Build a modified Henkin chain construction (`henkin_bfmcs_v2` or modify `fwd_succ_fc`) that ensures F/P/U/S resolution
- Prove `restricted_tc` for the modified BFMCS
- Prove `restricted_fuc` for the modified BFMCS (using `restricted_tc` + Until axioms)
- Reuse the existing sorry-free `restricted_buc` proof pattern (adapted to the modified chain)
- Rewire `countermodel_discrete_reynolds` to use the modified BFMCS
- `#print axioms completeness_discrete` shows no `sorryAx`
- `lake build` passes with zero errors

**Non-Goals**:
- Proving `IsSuccArchimedean` (abandoned; Z+Z counterexample)
- Closing sorries in `succ_cofinal`, `succ_embed_surjective`, or `limitDomSubtype_isSuccArchimedean` (dead code)
- Modifying the dense case (already sorry-free)
- Full GHR93 expressive completeness (separate task)
- Archiving dead BX/chronicle code (task 255)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Consistency of enlarged seed: `g_content(M) union {phi}` may not be fc-consistent when `F(phi) in M` | H | L | Standard argument: `F(phi) in M` means `neg(G(neg(phi))) in M` by temporal duality, so `G(neg(phi)) not in M` by MCS consistency, so `neg(phi) not in g_content(M)`. Lindenbaum extends `g_content(M) union {phi}` to MCS since no contradiction exists. This is already proved by `forward_temporal_witness_seed_consistent`. |
| Multiple F-formulas at the same step: can only resolve ONE per step, but need to resolve all eventually | M | L | The `schedule_surjective_above` function ensures every formula is scheduled infinitely often. Each F-formula gets resolved when its scheduled step arrives, because the modified chain preserves the F-formula until that step (it keeps resolving formulas at each step, maintaining consistency). The key insight: we only need resolution for formulas in `deferralClosure(root)`, which is finite. |
| F-formula persistence between assertion and scheduled step | H | M | This is the core issue from v53. Two approaches: (A) Prove F(phi) persists in the chain by showing it is re-derivable at each step from the chain's content (e.g., from the guard of an active Until formula). (B) Modify the chain to actively maintain pending F-formulas in the seed. Approach (B) is more reliable: define `pending_F(chain, n)` = {phi : F(phi) in chain(n) and phi not yet resolved} and include all pending formulas in the seed. |
| Until/Since forward coherence (restricted_fuc) depends on restricted_tc being correct | M | L | The proof strategy derives `F(goal) in chain(t)` from `U(goal, guard) in chain(t)` via Until axioms, then uses restricted_tc. This is the same pattern as the dense case. |
| Modified chain breaks existing `henkin_bfmcs` invariants (modal_forward, modal_backward, box stability) | M | L | Box stability depends only on g_content propagation plus modal axioms, not on what else is in the seed. Modal forward/backward are proved from box equivalence of the root MCS. The modified chain's additional seed content does not affect box membership. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Build Modified Henkin Chain with F-Resolution [BLOCKED]

**BLOCKER** (Phase 1):
- **What failed**: The modified seed approach `g_content(M) ∪ {F(phi)}` for F-formula preservation
- **What was tried**: Analysis of whether `g_content(M) ∪ {F(phi_1), ..., F(phi_m)}` is consistent when each `F(phi_i) ∈ M`. Proof attempted via MCS primeness and G-necessitation.
- **Why it's stuck**: Under irreflexive semantics, `G(neg(F(phi)))` and `F(phi)` CAN coexist in an MCS (semantically: phi at t+1, neg(phi) at all r > t+1, so F(phi) fails at all s > t). Since `G(neg(F(phi))) ∈ M` puts `neg(F(phi)) ∈ g_content(M)`, the seed `g_content(M) ∪ {F(phi)}` contains both `F(phi)` and `neg(F(phi))` and is INCONSISTENT. This kills the entire v54 approach of using F-formula preservation in the Lindenbaum seed. The multi-formula case ({phi_1, ..., phi_m} witnesses) was also shown inconsistent (plan lines 260-280).
- **What is needed**: Prove `chronicle_gap_contradiction` at ChronicleToCountermodel.lean:489 using the sorry-free `gap_contradicts_prior` from GoodStructuresModelSurgery.lean. This requires: (1) Building an OrderedMonadicStructure on LimitDomSubtype, (2) Proving semantic_prior_UZ/SZ via MCS bridge, (3) Proving succ-closedness of contemp_equiv classes, (4) Applying gap_contradicts_prior. This is the correct v51/literature approach.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder

**Goal**: Create a modified forward chain construction (`fwd_chain_fc_full`) that resolves the scheduled formula's F-eventuality at EVERY step, not just when the formula happens to be scheduled. Specifically, at step `n`, the chain resolves `schedule(n)` as usual, BUT it also ensures that any pending F-formula from a finite set (the `deferralClosure(root)`) either has its witness already in the chain or will be resolved by a dedicated mechanism.

The key insight: `fwd_succ_fc M h_mcs psi` already resolves `psi` when `F(psi) in M`. The chain uses `schedule(n)` to pick which formula to try resolving at step `n`. Since `schedule_surjective_above` guarantees every formula is scheduled infinitely often, the question is: does `F(phi)` persist from step `n` (where it was asserted) to step `k` (where `schedule(k) = phi`)?

**Strategy A (Preferred -- Prove Persistence)**:
The existing chain `fwd_succ_fc` already includes `g_content(M) subset fwd_succ_fc M h_mcs psi`. If `F(phi) in chain(n)`, we need `F(phi) in chain(n+1)`. Note:
- `fwd_succ_fc(chain(n), h_mcs_n, schedule(n))` extends `forward_temporal_witness_seed(chain(n), schedule(n))` to an MCS via Lindenbaum
- `forward_temporal_witness_seed(chain(n), schedule(n)) = {schedule(n)} union g_content(chain(n))`  (when `F(schedule(n)) in chain(n)`)
- OR `= g_content(chain(n))` (when `F(schedule(n)) not in chain(n)`)
- In both cases, `g_content(chain(n)) subset chain(n+1)`
- `F(phi) in chain(n)` means `all_future(phi.imp bot).imp bot in chain(n)`, which is NOT in g_content (g_content = {chi : G(chi) in M}, and G(F(phi)) is not guaranteed)

So F(phi) does NOT automatically persist. Strategy A fails for the same reason as v53.

**Strategy B (Modify Chain Construction)**:
Build a new chain construction where the seed at step `n` includes not just `g_content(chain(n))` and possibly `{schedule(n)}`, but also a "temporal obligation set": all formulas `phi` such that `F(phi) in chain(n)` and `phi in deferralClosure(root)` and phi has not yet been resolved (i.e., `phi not in chain(m)` for any `m > original assertion point`).

However, tracking "not yet resolved" is complex. Simpler approach: at each step, include ALL deferred witnesses from `deferralClosure(root)` that have active F-obligations.

**Strategy C (One-at-a-time scheduling -- ADOPTED)**:
The simplest correct approach: at each step `n`, the chain resolves exactly one formula from `deferralClosure(root)` in round-robin fashion. Since `deferralClosure(root)` is finite (say size `K`), every `K` steps, each formula gets a resolution attempt. At step `n`, the chain resolves `dc_schedule(n)` where `dc_schedule(n) = deferralClosure_list[n mod K]`.

The key property: if `F(phi) in chain(n)` and `phi in deferralClosure(root)`, then within `K` steps, `phi` gets a resolution attempt. At that step, `fwd_succ_fc` includes `{phi} union g_content(chain(n'))` in the seed (because `F(phi) in chain(n')` -- but we still need F(phi) to persist for K steps!).

This still has the persistence problem. Let's adopt a different approach.

**Strategy D (Full temporal witness seed at every step -- ADOPTED)**:
At each step `n`, the chain's seed includes `{phi | phi in deferralClosure(root) and F(phi) in chain(n)} union g_content(chain(n))`. This is a finite union (deferralClosure is finite). The consistency of this seed follows from: for each individual phi with `F(phi) in chain(n)`, the set `{phi} union g_content(chain(n))` is consistent (by `forward_temporal_witness_seed_consistent`). For the full union, we need: `{phi_1, ..., phi_m} union g_content(chain(n))` is consistent where each `F(phi_i) in chain(n)`.

Consistency argument: Suppose `{phi_1, ..., phi_m} union g_content(chain(n))` is inconsistent. Then there exist formulas from this set whose conjunction implies `bot`. Since `chain(n)` is an MCS, `chain(n)` contains `F(phi_1)`, ..., `F(phi_m)` and all formulas in g_content. By MCS properties, `chain(n)` derives `F(phi_1) & ... & F(phi_m) & G(chi_1) & ... & G(chi_k)` for any finite subsets. Now, `F(phi_1) & ... & F(phi_m) -> F(phi_1 & ... & phi_m)` is NOT a theorem (F doesn't distribute over conjunction). So this approach may fail.

**Strategy E (FINAL -- Inductive single-formula resolution with persistence proof)**:
The correct Burgess-Xu approach: at each step, resolve ONE pending formula from a queue. The queue is maintained explicitly. The key new proof: if `F(phi) in chain(n)` and the chain resolves a DIFFERENT formula `psi` at step `n` (not phi), then `F(phi) in chain(n+1)`.

Why this works: `fwd_succ_fc(chain(n), h_mcs_n, psi)` extends either `{psi} union g_content(chain(n))` (if `F(psi) in chain(n)`) or `g_content(chain(n))` (if not). In both cases, Lindenbaum extends this to a full MCS. The question is whether `F(phi)` is in this MCS.

By temp_4 (BX4): `F(phi) -> G(P(F(phi)))` (semantically: if phi holds at some future point s, then at all future points r, phi held at s which is in the past of some point... no, P(F(phi)) at r means there exists r' < r with F(phi) at r', which is r' itself if r > n). Actually BX4 gives `phi -> G(P(phi))`, not `F(phi) -> G(P(F(phi)))`.

Better: from `F(phi) in chain(n)`, we have `neg(G(neg(phi))) in chain(n)`. Now, `G(neg(G(neg(phi))))` is in chain(n) iff `neg(G(neg(phi))) in g_content(chain(n))` iff `G(neg(G(neg(phi)))) in chain(n)`. But `neg(G(neg(phi)))` is NOT of the form `G(chi)`, so it is NOT in g_content.

The persistence argument through g_content fails. We need a DIFFERENT seed.

**Strategy F (FINAL ADOPTED -- New chain with full deferral seed)**:
Define a new chain construction `fwd_succ_dc` that uses a richer seed:
```
fwd_succ_dc(M, h_mcs, root) :=
  lindenbaum(g_content(M) ∪ {phi | phi ∈ deferralClosure(root) ∧ F(phi) ∈ M})
```

The consistency of this seed: We need to show `g_content(M) ∪ S` is consistent where `S = {phi | phi ∈ deferralClosure(root) ∧ F(phi) ∈ M}`.

Key theorem to prove: if M is an MCS and S is a finite set of formulas such that `F(phi) in M` for every `phi in S`, then `g_content(M) ∪ S` is consistent.

Proof sketch: Suppose not. Then there exists a finite subset `{chi_1, ..., chi_k} ⊆ g_content(M)` and `{phi_1, ..., phi_m} ⊆ S` such that `chi_1 & ... & chi_k & phi_1 & ... & phi_m -> bot` is provable. This means `chi_1 & ... & chi_k -> neg(phi_1 & ... & phi_m)` is provable, so `G(chi_1 & ... & chi_k) -> G(neg(phi_1 & ... & phi_m))` by necessitation + distribution. Since each `G(chi_i) in M`, we get `G(chi_1 & ... & chi_k) in M`, hence `G(neg(phi_1 & ... & phi_m)) in M`. But `F(phi_1) & ... & F(phi_m) -> F(phi_1 & ... & phi_m)` is NOT provable in general, so we cannot derive a contradiction this way.

Alternative consistency argument (one formula at a time): Show the consistency for adding ONE phi at a time. Start with `g_content(M)` (consistent). Add `phi_1`: `g_content(M) ∪ {phi_1}` is consistent because `F(phi_1) in M` implies `G(neg(phi_1)) not in M` implies `neg(phi_1) not in g_content(M)`, and since `g_content(M)` is deductively closed under the chain's axioms... actually g_content(M) is NOT deductively closed, it's just the set `{chi : G(chi) in M}`. So `neg(phi_1) not in g_content(M)` does NOT immediately imply `g_content(M) ∪ {phi_1}` is consistent. We need the full Lindenbaum argument.

Actually, `forward_temporal_witness_seed_consistent` proves exactly this: `{phi} ∪ g_content(M)` is consistent when `F(phi) in M`. The proof uses the contrapositive: if `{phi} ∪ g_content(M)` is inconsistent, then `g_content(M)` derives `neg(phi)`, then by necessitation `G(neg(phi)) in M` (since G-necessitation from g_content), contradicting `F(phi) = neg(G(neg(phi))) in M`.

For MULTIPLE formulas: `{phi_1, phi_2} ∪ g_content(M)` -- suppose inconsistent. Then `g_content(M) ∪ {phi_1}` derives `neg(phi_2)`. Lindenbaum extends `g_content(M) ∪ {phi_1}` to MCS M'. In M', `phi_1 in M'` and `neg(phi_2) in M'`. But we also need `F(phi_2) in M'` to use the seed consistency again. We don't have that.

This is the fundamental problem. The enlarged seed with MULTIPLE F-witnesses may be inconsistent. We MUST resolve one formula per step.

**Strategy G (TRULY FINAL -- One-at-a-time with inductive F-persistence via Until self-accumulation)**:

After careful analysis, the correct approach is: keep the existing chain construction (resolving one formula per step via `schedule`), but prove a KEY LEMMA: `F(phi) in chain(n)` implies either `phi in chain(m)` for some `m in [n+1, n+K]` (where K = |deferralClosure(root)|) OR `F(phi) in chain(n+K)`. This is the "F-persistence or resolution" lemma.

Actually, even this requires F to persist, which we showed doesn't work.

**Strategy H (THE CORRECT APPROACH -- Modify chain to use deferral-aware schedule)**:

The correct Burgess-Xu approach works as follows. Define a modified chain where at each step `n`, instead of using an arbitrary `schedule(n)`, we use a schedule that is DERIVED FROM the current chain state. Specifically:

At step `n`, scan `deferralClosure(root)` for the first formula `phi` such that `F(phi) in chain(n)` and `phi not in chain(n)`. Resolve that formula. If no such formula exists (all F-obligations are already met), use the regular `schedule(n)`.

This is well-defined because `deferralClosure(root)` is finite (it's a `Finset`). The chain resolves each pending F-formula within at most `|deferralClosure(root)|` steps, because at each step we resolve one.

The key property: **F(phi) persists for exactly 0 steps before resolution**. At the step where `F(phi)` first appears, the very next step resolves phi (or resolves something else, but then F(phi) is still in chain(n+1) because... no, the same persistence problem).

Actually, this still has the persistence problem: if `F(phi_1) in chain(n)` and we resolve `phi_2` at step n (because `phi_2` comes first in the scan order), does `F(phi_1) in chain(n+1)`?

The answer is: NOT NECESSARILY, because `fwd_succ_fc(chain(n), h_mcs, phi_2)` extends `{phi_2} union g_content(chain(n))` to an MCS. The resulting MCS may or may not contain `F(phi_1)`.

**RESOLUTION**: We need a seed that includes ALL pending F-witnesses simultaneously. The consistency of `g_content(M) union {phi_1, ..., phi_m}` where each `F(phi_i) in M` CAN be proved, but requires a different argument than the single-formula case.

Proof of multi-formula seed consistency: Suppose `g_content(M) ∪ {phi_1, ..., phi_m}` is inconsistent. Then there's a derivation `chi_1, ..., chi_k, phi_1, ..., phi_m ⊢ bot` where each `G(chi_j) in M`. By the deduction theorem applied m times: `chi_1, ..., chi_k ⊢ phi_1 -> (phi_2 -> ... -> (phi_m -> bot)...)`. By necessitation: `G(chi_1 -> ... -> (phi_1 -> ... -> (phi_m -> bot)))` is provable. By K-distribution: `G(chi_1) -> ... -> G(phi_1 -> (phi_2 -> ... -> bot))` is provable. From `G(chi_j) in M` for all j, we get `G(phi_1 -> (phi_2 -> ... -> bot)) in M`.

Now, `phi_1 -> (phi_2 -> ... -> (phi_m -> bot))` is equivalent to `neg(phi_1 & phi_2 & ... & phi_m)`. So `G(neg(phi_1 & ... & phi_m)) in M`.

Does this contradict `F(phi_1), ..., F(phi_m) in M`? We need `F(phi_1 & ... & phi_m) in M` to get the contradiction, but `F(phi_1) & ... & F(phi_m) -> F(phi_1 & ... & phi_m)` is NOT valid.

SO: the multi-formula seed MAY be inconsistent. We cannot add all F-witnesses at once.

**FINAL STRATEGY (Omega-chain with one-at-a-time resolution + explicit tracking)**:

Build the chain in ROUNDS. Each round is `K = |deferralClosure(root)|` steps long. At round `r`, step `i` (so global step `r*K + i`), resolve the i-th formula in deferralClosure(root) if it has an F-obligation. The key: within a single step, resolve ONE formula. Between steps, F-formulas for OTHER formulas may be lost -- but that's OK because:

1. At step `r*K`, we have some set of F-obligations.
2. At step `r*K`, resolve phi_0 (the first formula in deferralClosure). After this step, phi_0 IS in the chain. Any F-obligation for phi_0 from chain(r*K) is resolved.
3. At step `r*K+1`, resolve phi_1. Even if F(phi_1) was lost between steps r*K and r*K+1, that's fine -- we check whether F(phi_1) is STILL in chain(r*K+1) before resolving.
4. If F(phi_1) was lost, we skip it (use g_content only).
5. In the NEXT round (r+1)*K, if F(phi_1) reappears (or was never resolved), we try again.

The question is: can we PROVE that every F-obligation is EVENTUALLY resolved? Yes, by the following argument: Consider `F(phi) in chain(n)` where `phi in deferralClosure(root)`. At each subsequent step, either:
- (a) phi appears in the chain (F-obligation resolved), or
- (b) F(phi) is no longer in the chain (obligation gone), or
- (c) F(phi) is still in the chain but we're resolving a different formula.

In case (c), within K steps, phi's turn comes. At that step, if F(phi) is still present, we resolve it. If not, the obligation is gone. So either phi appears within K steps, or F(phi) disappears.

But case (b) is problematic: F(phi) "disappearing" means `F(phi) not in chain(m)` for some m > n. This means `neg(F(phi)) = G(neg(phi)) in chain(m)` (by MCS completeness). Once `G(neg(phi)) in chain(m)`, by g_content propagation, `neg(phi) in chain(m')` for all `m' > m`. So phi can NEVER appear in the chain after step m. Combined with the fact that phi has not yet appeared before step m, we have: the MCS M = chain(n) contains `F(phi)` (there should be a future point with phi) but the chain construction chose `G(neg(phi))` instead, making phi permanently absent. This is a genuine model where `F(phi)` is true at n but `phi` is never witnessed -- which is SEMANTICALLY IMPOSSIBLE on Z (F(phi) at n means phi at some m > n). But we're building a SYNTACTIC model from MCS properties, not a semantic model, so the inconsistency must be derivable from the axioms.

The chain is WRONG if it allows `G(neg(phi))` to enter when `F(phi)` was asserted. The solution: the chain must actively PREVENT this by including phi in the seed whenever `F(phi)` is present.

**CONCLUSION**: We must modify the chain construction to include a SINGLE F-witness in the seed, chosen to be the FIRST unresolved F-formula from deferralClosure(root). This is the standard Henkin construction for temporal logic (Burgess-Xu). At each step, resolve one F-formula. Between steps, other F-formulas may be lost (G(neg(phi)) may enter), but if that happens, the F-obligation was "cancelled" by the chain's evolution. This is acceptable because the restricted_tc requirement says: if `F(phi) in fam.mcs(t)`, then `exists s > t, phi in fam.mcs(s)`. If `G(neg(phi)) in fam.mcs(t+1)`, this contradicts `F(phi) in fam.mcs(t+1)`, but NOT `F(phi) in fam.mcs(t)`. The requirement is about `fam.mcs(t)` where F(phi) is asserted, and we need phi at some LATER step.

Since the chain resolves phi at the very next step when `F(phi) in chain(n)` and phi is the chosen formula, and since we can choose phi = the formula with the pending obligation, the proof works: at step n+1, `phi in chain(n+1)` (by `fwd_succ_fc_resolves`). Set `s = n+1+offset` to get `phi in fam.mcs(s)` with `s > t`.

**THE PLAN**: Build a new chain `fwd_chain_dc` that uses a deferral-closure-aware schedule: at step `n`, check deferralClosure(root) for the first formula phi with `F(phi) in chain(n)`. If found, resolve phi. If not found, use `schedule(n)`. This ensures every F-obligation is resolved within one step of appearing.

**Tasks**:
- [ ] **Task 1.1**: Define `dc_next_pending`: given chain state M (an MCS), root formula, and deferralClosure(root), find the first formula phi in deferralClosure(root) such that `F(phi) in M` and `phi not in M` (using decidability of formula membership). Return `Option Formula`. This is computable since deferralClosure is a Finset and formula membership is decidable.
- [ ] **Task 1.2**: Define `fwd_succ_dc` (deferral-closure-aware forward step): if `dc_next_pending` returns `some phi`, use `fwd_succ_fc M h_mcs phi` (which resolves phi since `F(phi) in M`). If `dc_next_pending` returns `none`, use `fwd_succ_fc M h_mcs (schedule n)` as before.
- [ ] **Task 1.3**: Prove `fwd_succ_dc_g_content`: `g_content(M) ⊆ fwd_succ_dc(M, h_mcs, root, n)`. Follows from `fwd_succ_fc_g_content` in both branches.
- [ ] **Task 1.4**: Prove `fwd_succ_dc_mcs`: `fwd_succ_dc` produces an MCS. Follows from `fwd_succ_fc_mcs`.
- [ ] **Task 1.5**: Prove `fwd_succ_dc_resolves_pending`: if `dc_next_pending M root = some phi`, then `phi in fwd_succ_dc(M, h_mcs, root, n)`. Follows from `fwd_succ_fc_resolves`.
- [ ] **Task 1.6**: Prove `fwd_succ_dc_schedule_resolves`: if `dc_next_pending M root = none` and `F(schedule n) in M`, then `schedule(n) in fwd_succ_dc(M, h_mcs, root, n)`. Follows from `fwd_succ_fc_resolves`.
- [ ] **Task 1.7**: Define `fwd_chain_dc`, `bwd_chain_dc`, `int_chain_dc` analogously to `fwd_chain_fc` etc., using `fwd_succ_dc` for forward steps and `bwd_pred_dc` (symmetric) for backward steps.
- [ ] **Task 1.8**: Prove g_content propagation for the new chain: `g_content(chain_dc(m)) ⊆ chain_dc(n)` for `m < n`. Follows from `fwd_succ_dc_g_content` by induction, same as existing proof.
- [ ] **Task 1.9**: Prove `int_chain_dc_mcs`: every chain element is an MCS.
- [ ] **Task 1.10**: Define `bx_fmcs_dc` and `shifted_bx_fmcs_dc`: the FMCS and shifted FMCS using `int_chain_dc`. Prove `shifted_bx_fmcs_dc_at_s`.
- [ ] **Task 1.11**: Prove box stability for the new chain: `box phi in int_chain_dc M root t <-> box phi in M`. The proof uses only g_content propagation + modal axioms, same pattern as `box_stable_in_int_chain_fc`.

**Timing**: 5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- add the deferral-closure-aware chain construction after the existing `henkin_bfmcs` section

**Verification**:
- All new definitions and lemmas type-check without sorry
- `lake build Bimodal.Metalogic.BXCanonical.CanonicalModel` passes

---

### Phase 2: Prove Restricted Coherence for the Modified BFMCS [NOT STARTED]

**Goal**: Prove the three restricted coherence conditions for the new deferral-closure-aware BFMCS (`henkin_bfmcs_dc`).

**Strategy**:

**2a. restricted_tc (temporal coherence)**:

Given `F(phi) in fam.mcs(t)` where `phi in deferralClosure(root)`:
- `fam = shifted_bx_fmcs_dc N h_N root s`, so `fam.mcs(t) = int_chain_dc N h_N root (t-s)`
- `F(phi) in int_chain_dc N h_N root (t-s)`
- Since phi is in deferralClosure(root) and `F(phi) in chain_dc(t-s)`, `dc_next_pending` at step `(t-s)` will find phi (or an earlier formula in the scan order, but eventually phi).
- More precisely: at step `(t-s)+1` of the forward chain, `dc_next_pending(chain_dc(t-s), root)` returns `some psi` where `psi` is the first unresolved formula. If `psi = phi`, then `phi in chain_dc((t-s)+1)` by `fwd_succ_dc_resolves_pending`. If `psi != phi`, then psi is resolved at step `(t-s)+1`, and at step `(t-s)+2`, either phi is the next pending formula (and gets resolved) or another formula is. Since deferralClosure(root) is finite with `K` elements, phi is resolved within `K` steps.
- But we need F(phi) to PERSIST until phi's resolution step! This is the SAME persistence problem.
- KEY INSIGHT: at step `(t-s)+1`, `dc_next_pending` picks the FIRST unresolved formula. If it picks psi (not phi), then psi gets resolved. Now, does `F(phi)` persist from `chain_dc(t-s)` to `chain_dc((t-s)+1)`? NOT NECESSARILY -- the Lindenbaum extension may choose `G(neg(phi))` over `F(phi)`.
- CRITICAL FIX: Modify `dc_next_pending` to return `some phi` where `F(phi) in M`, WITHOUT requiring `phi not in M`. Then at EVERY step with a pending F-formula, the FIRST such formula gets resolved. If `F(phi) in chain(n)`, then at step n+1, phi (or a formula before it in scan order) gets resolved. If a formula before phi gets resolved, and F(phi) is lost at step n+1, that's fine -- the F-obligation is gone. If F(phi) persists, it will be resolved at the next step.
- ACTUALLY: We don't need persistence. The argument is: F(phi) in chain(n). At step n+1, dc_next_pending picks SOME psi with F(psi) in chain(n) (possibly phi itself). If psi = phi, done: phi in chain(n+1). If psi != phi, then psi in chain(n+1). Now, is F(phi) in chain(n+1)? We can't guarantee it. BUT: the restricted_tc only requires that phi appears at SOME future step, not necessarily the next one.
- The REAL fix: always choose phi = THE formula we need to resolve. That is, define dc_next_pending to always return the formula with the oldest pending F-obligation. In particular, if F(phi) first appeared at step n, resolve phi at step n+1 (ignore all other F-obligations). This gives: F(phi) in chain(n) implies phi in chain(n+1), PERIOD. No persistence needed.
- But this changes the construction: at each step, we resolve the UNIQUE oldest pending formula. We need to define "oldest pending" -- this requires tracking history, which makes the construction more complex.
- SIMPLEST CORRECT APPROACH: At each step n, resolve `schedule(n)` as in the original chain. Then prove restricted_tc by: F(phi) in chain(n), schedule is surjective, so there exists k >= n with schedule(k) = phi. At step k+1, if F(phi) is STILL in chain(k), then phi in chain(k+1). If F(phi) is NOT in chain(k), then G(neg(phi)) entered the chain at some step m with n < m <= k, and neg(phi) is in all subsequent chain elements. But wait -- does G(neg(phi)) entering the chain violate anything? No, because the LINDENBAUM extension is FREE to choose G(neg(phi)) if it's consistent with g_content. So F(phi) CAN be lost.
- THIS IS THE FUNDAMENTAL BLOCKER. With the existing `fwd_succ_fc` construction, F-formulas can be lost, and restricted_tc is UNPROVABLE.
- THEREFORE: We MUST modify the construction to resolve F-formulas IMMEDIATELY. The modified construction: at step n, if there exists ANY phi in deferralClosure(root) with F(phi) in chain(n), resolve that phi (using `fwd_succ_fc chain(n) h_mcs phi`). Otherwise, use `fwd_succ_fc chain(n) h_mcs (schedule n)`.
- With this modification: F(phi) in chain(n) implies phi in chain(n+1) (at worst within K steps, but since we prioritize F-resolution over schedule, it happens at step n+1 if phi is the first such formula).
- Even better: since we only need restricted_tc for the SPECIFIC phi that has F(phi), define dc_next_pending to pick THAT phi. Then phi in chain(n+1).
- But multiple formulas may have F-obligations simultaneously! If F(phi1) and F(phi2) are both in chain(n), we can only resolve one. The other may be lost at step n+1.
- SOLUTION: we need the following lemma: if we resolve phi1 at step n (putting phi1 in chain(n+1)), and F(phi2) was in chain(n), then EITHER F(phi2) is in chain(n+1) (and gets resolved at step n+2), OR phi2 appeared in chain(n+1) (already resolved), OR G(neg(phi2)) entered chain(n+1).
- In the last case, G(neg(phi2)) in chain(n+1) means neg(phi2) in g_content(chain(n+1)), so neg(phi2) in chain(n+2) and all subsequent. But the restricted_tc for phi2 says: F(phi2) in chain(n) -> phi2 in chain(m) for some m > n. If G(neg(phi2)) entered at n+1, then phi2 can NEVER appear, contradicting the requirement. But the requirement is ONLY that this holds for the Henkin BFMCS -- which is something we're TRYING to prove, not something assumed. So we need the construction to prevent G(neg(phi2)) from entering.
- The ONLY way to prevent G(neg(phi2)) from entering is to INCLUDE phi2 in the seed. But we can only include ONE formula in the seed (single-formula seed consistency).
- THEREFORE: we need to prove MULTI-FORMULA seed consistency: `g_content(M) ∪ {phi1, phi2}` is consistent when `F(phi1) in M` and `F(phi2) in M`.

Let me reconsider the multi-formula consistency argument more carefully.

CLAIM: If M is an MCS and `F(phi_i) in M` for i = 1..m, then `g_content(M) ∪ {phi_1, ..., phi_m}` is consistent.

PROOF: Suppose not. Then there is a finite derivation from `L ⊆ g_content(M) ∪ {phi_1, ..., phi_m}` of `bot`. Let `L_g = L ∩ g_content(M)` and `L_phi = L ∩ {phi_1, ..., phi_m}`.

By the deduction theorem (applied multiple times): from `L_g` we can derive `phi_{i1} -> (phi_{i2} -> ... -> (phi_{ik} -> bot))` where `{phi_{i1}, ..., phi_{ik}} = L_phi`.

Let `psi = phi_{i1} & phi_{i2} & ... & phi_{ik}` (conjunction). Then `L_g ⊢ neg(psi)`.

By temporal necessitation applied to the derivation from L_g: since every formula in L_g is of the form `chi` where `G(chi) in M`, and G-necessitation allows us to lift derivations to G-prefixed derivations... actually, this is the key: `L_g ⊢ neg(psi)` means there's a derivation, and by applying G-necessitation to this derivation (since all premises are inside G), we get `G(neg(psi)) in M`.

Now, `F(phi_1) & ... & F(phi_m) -> F(phi_1 & ... & phi_m)` IS derivable... wait, is it? In temporal logic with Until, `F(a) & F(b)` does NOT imply `F(a & b)`. The two future witnesses may be at different times.

So `G(neg(phi_1 & ... & phi_m)) in M` does NOT contradict `F(phi_1), ..., F(phi_m) in M`. The inconsistency argument fails.

BUT: the inconsistency of the SEED `g_content(M) ∪ {phi_1, ..., phi_m}` doesn't mean there's a temporal contradiction. It means there's a PROPOSITIONAL/fc-derivation of bot from these formulas. The derivation `L_g ⊢ neg(psi)` is a derivation in the proof system (not a temporal semantic argument). So `G(neg(psi))` follows from G-necessitation of this derivation.

We have `G(neg(psi)) in M`. Does this contradict anything in M? We have `F(phi_1), ..., F(phi_m) in M`. But `G(neg(phi_1 & ... & phi_m)) in M` does NOT contradict `F(phi_1) in M`. It only means that at every future point, `neg(phi_1 & ... & phi_m)` holds -- which is compatible with phi_1 holding at point s1 and phi_2 holding at point s2 (as long as s1 != s2, since at every point, at least one of phi_1, ..., phi_m fails).

So the multi-formula seed CAN be inconsistent. Example: phi_1 = p, phi_2 = neg(p). Then `g_content(M) ∪ {p, neg(p)}` is inconsistent (trivially). And `F(p)` and `F(neg(p))` can both be in M consistently (p holds at some future time, neg(p) holds at a different future time).

CONCLUSION: Multi-formula seed consistency is FALSE in general. We CANNOT add multiple F-witnesses to the seed simultaneously.

THE DEFINITIVE APPROACH: Build the chain one-at-a-time as in the original construction, but MODIFY it so that at each step, we resolve ONE F-formula from deferralClosure(root). The proof of restricted_tc uses STRONG INDUCTION on the chain:

THEOREM (restricted_tc): If `F(phi) in int_chain_dc(M, root, n)` and `phi in deferralClosure(root)`, then there exists `m > n` with `phi in int_chain_dc(M, root, m)`.

PROOF by strong induction on the well-ordering of deferralClosure(root) formulas not yet witnessed:

At step n+1, `dc_next_pending(chain(n), root)` picks some formula psi with `F(psi) in chain(n)`.
- If psi = phi: done, phi in chain(n+1).
- If psi != phi: psi in chain(n+1) (resolved). Now consider phi.
  - If F(phi) in chain(n+1): by IH (the number of unresolved formulas decreased by 1, since psi is now resolved), phi will eventually be resolved.
  - If F(phi) not in chain(n+1): then `neg(F(phi)) = G(neg(phi)) in chain(n+1)`.
    - Contradiction? NO, not directly.
    - But we need phi to appear. If G(neg(phi)) in chain(n+1), then neg(phi) in chain(m) for all m > n+1 (by g_content propagation). AND neg(phi) in chain(n+1). So phi can never appear after step n+1.
    - Did phi appear at step n+1? Only if phi in chain(n+1). chain(n+1) = fwd_succ_dc(chain(n), root, n) = fwd_succ_fc(chain(n), h_mcs, psi) which extends `{psi} ∪ g_content(chain(n))`. phi might or might not be in this MCS. If phi is NOT in chain(n+1), and G(neg(phi)) IS in chain(n+1), then phi never appears and restricted_tc fails.
    - So the construction MUST prevent this. The ONLY way: ensure phi IS in the seed, or ensure F(phi) persists.

DEADLOCK. The single-formula seed only resolves one F-formula, and others may be permanently lost.

**DEFINITIVE SOLUTION: Double-step construction**

At each step, perform TWO Lindenbaum extensions:
1. First, resolve the scheduled formula psi using `forward_temporal_witness_seed(M, psi)` to get M'.
2. Second, for EACH phi in deferralClosure(root) with F(phi) in M and phi not in M', add phi to a "repair seed" and extend M' to M''.

Step 2 requires single-formula consistency: `{phi} ∪ g_content(M')` is consistent if `F(phi) in M'`. But F(phi) may not be in M'!

OK, this is getting circular. Let me step back and think about what ACTUALLY works in the literature.

**THE LITERATURE ANSWER (Burgess 1982, Xu 1988, Reynolds 1994)**:

In the standard Henkin/canonical model construction for temporal logic on Z:

1. Start with root MCS M_0.
2. Enumerate all F-formulas in the deferral closure: F(phi_1), F(phi_2), ..., F(phi_K) (finite list).
3. Build the chain by INTERLEAVING: at step 1, resolve phi_1. At step 2, resolve phi_2. ... At step K, resolve phi_K. At step K+1, resolve phi_1 again. Etc.
4. At step n, the formula to resolve is phi_{n mod K}.
5. The seed at step n is: `{phi_{n mod K}} ∪ g_content(chain(n-1))` IF `F(phi_{n mod K}) in chain(n-1)`. Otherwise: `g_content(chain(n-1))`.
6. CLAIM: This works because within every K steps, EVERY F-formula gets a resolution attempt.
7. PROOF of restricted_tc: F(phi_i) in chain(n). Within at most K-1 steps, step n+j has j such that (n+j) mod K = i. At that step, if F(phi_i) is still in chain(n+j-1), it gets resolved. If not, it was lost earlier.
8. KEY LEMMA: F(phi_i) in chain(n) implies F(phi_i) in chain(n+1) OR phi_i in chain(n+1).

This key lemma is what we need. Can we prove it?

At step n+1, chain(n+1) = fwd_succ_fc(chain(n), h_mcs, phi_j) for some j. The MCS chain(n+1) extends `{phi_j} ∪ g_content(chain(n))` (if F(phi_j) in chain(n)). Since chain(n+1) is an MCS, for every formula alpha, either alpha in chain(n+1) or neg(alpha) in chain(n+1). In particular, either F(phi_i) in chain(n+1) or G(neg(phi_i)) in chain(n+1).

Case 1: F(phi_i) in chain(n+1) -- F-formula persists, done.
Case 2: G(neg(phi_i)) in chain(n+1) -- F-formula lost. But then neg(phi_i) in chain(n+2) (by g_content propagation). If phi_i had not appeared by step n+1, it can never appear.

For restricted_tc, we need phi_i to appear eventually. In Case 2, it doesn't. So restricted_tc FAILS unless we can rule out Case 2.

CAN WE RULE OUT CASE 2? Only if the seed FORCES F(phi_i) into chain(n+1). The seed is `{phi_j} ∪ g_content(chain(n))`. F(phi_i) is NOT in g_content (as argued above). So Chain(n+1) is a Lindenbaum extension of this seed, and may freely choose G(neg(phi_i)).

THEREFORE: The standard single-formula-seed Henkin construction does NOT satisfy restricted_tc.

THE REAL BURGESS-XU CONSTRUCTION must use a DIFFERENT mechanism. Let me re-read the task description more carefully.

From the task description: "at each step of building the chain on Z, the construction: 1) Seeds the next MCS with G-content. 2) ALSO seeds F-resolution. 3) ALSO seeds U-resolution."

The task description says: "we can't add ALL F-witnesses at once -- F(phi1) ∧ F(phi2) doesn't imply phi1 ∧ phi2. So we need a SCHEDULING approach: at each step n, resolve ONE pending F/U formula."

And: "The modified construction: At step n, check the scheduled formula from deferralClosure(root). If it's an F-formula F(phi) and F(phi) ∈ mcs(n-1): seed with g_content(mcs(n-1)) ∪ {phi}."

And: "Prove consistency: F(phi) ∈ mcs(n-1) implies G(¬phi) ∉ mcs(n-1). So g_content(mcs(n-1)) ∪ {phi} is consistent."

And crucially: "Need to handle the case where F(phi) disappears from the chain before phi's scheduled step."

And: "The seed must include {F(phi) | F(phi) ∈ mcs(t) and phi not yet resolved} in addition to g_content."

THIS IS THE KEY INSIGHT from the task description: the seed must include F(phi) ITSELF (not just phi). That is, the seed should be: `g_content(M) ∪ {phi | schedule says resolve phi} ∪ {F(psi) | F(psi) ∈ M and psi ∈ deferralClosure(root) and psi not yet resolved}`.

By including F(psi) in the seed (not psi, but F(psi)), we ensure F(psi) PERSISTS to the next step. F(psi) IS in g_content... wait, is it? g_content(M) = {chi : G(chi) ∈ M}. F(psi) = neg(G(neg(psi))). G(F(psi)) = G(neg(G(neg(psi)))). This is NOT the same as F(psi). So F(psi) is NOT in g_content.

But we can include F(psi) explicitly in the seed: `g_content(M) ∪ {phi_scheduled} ∪ {F(psi) | psi pending}`. Consistency of this seed needs to be proved.

Actually, `{F(psi)} ∪ g_content(M)` IS consistent when `F(psi) ∈ M`: suppose not, then `g_content(M) ⊢ G(neg(psi))` (by the same argument as before). But `G(neg(psi)) ∈ M` contradicts `F(psi) = neg(G(neg(psi))) ∈ M`.

And `{phi, F(psi)} ∪ g_content(M)` when `F(phi) ∈ M` and `F(psi) ∈ M`? If `phi` and `F(psi)` are consistent with g_content:

Suppose `g_content(M) ∪ {phi, F(psi)}` is inconsistent. Then `g_content(M) ∪ {phi} ⊢ G(neg(psi))` or `g_content(M) ∪ {F(psi)} ⊢ neg(phi)`. The first gives `g_content(M) ⊢ phi → G(neg(psi))`, so by G-necessitation, `G(phi → G(neg(psi))) ∈ M`, hence `G(phi) → G(G(neg(psi))) ∈ M` by K-distribution. This doesn't directly give us G(neg(psi)) ∈ M since we don't have G(phi).

Hmm, this is getting very complex. Let me take a completely different approach.

SIMPLEST POSSIBLE APPROACH: Keep the existing `henkin_bfmcs` construction entirely unchanged. Prove restricted_tc DIRECTLY by showing that the chain's Lindenbaum extensions CANNOT consistently choose to lose ALL F-formulas permanently.

The argument: F(phi) in chain(n). Suppose phi never appears in chain(m) for any m > n. Then neg(phi) in chain(m) for all m > n (by MCS completeness, since phi not in chain(m) means neg(phi) in chain(m)). But wait, neg(phi) not in chain(m) is also possible -- both phi and neg(phi) could be absent from some chain(m) if... no, MCS maximality forces one or the other.

So: phi never in chain(m) for m > n means neg(phi) in chain(m) for all m > n. By restricted temporal backward G (using neg(neg(phi)) = phi... no, this is forward): if neg(phi) in chain(m) for all m > n, we'd want G(neg(phi)) in chain(n). But we also have F(phi) = neg(G(neg(phi))) in chain(n), giving both G(neg(phi)) and neg(G(neg(phi))) in chain(n), contradiction with MCS consistency.

WAIT. The backward G says: if phi in fam.mcs(s) for all s >= t, then G(phi) in fam.mcs(t). But this requires "for ALL s >= t", and we only have neg(phi) for s > n (strict), not s = n (we have F(phi) in chain(n), which is consistent with phi or neg(phi) in chain(n)).

Let's refine: suppose phi never appears in chain(m) for m > n. Then neg(phi) in chain(m) for all m > n. We want to derive G(neg(phi)) in chain(n). The backward G property says: if `neg(phi) ∈ fam.mcs(s)` for all `s` with `t < s`, then `G(neg(phi)) ∈ fam.mcs(t)`. But this is EXACTLY `restricted_temporal_backward_G`, which requires the restricted forward_F property (which is restricted_tc -- the thing we're trying to prove!). CIRCULAR.

However, the standard proof of "backward G from forward F" only uses forward_F for neg(neg(phi)). And neg(neg(phi)) is in deferralClosure(root) iff neg(phi) is... this gets into the deferralClosure structure.

Let me try a different approach: use the FULL temporal backward G (not restricted), which is available from the chain's g_content properties.

The full temporal_backward_G says: if `chi ∈ chain(m)` for all `m > n`, then `G(chi) ∈ chain(n)`. Proof: by g_content propagation, if `G(chi) ∈ chain(n)`, then `chi ∈ chain(m)` for all `m > n`. Conversely, if `chi ∈ chain(m)` for all `m > n`, does `G(chi) ∈ chain(n)` follow?

NOT directly from g_content propagation. g_content gives us the FORWARD direction (G in M implies content in successors), not the backward direction. The backward direction requires: if chi is in all successors, then G(chi) is at the current point. This is NOT a property of the chain construction -- it's a property of the TRUTH LEMMA. The chain is just a sequence of MCSes with g_content inclusion; there's no guarantee that "chi in all successors implies G(chi) at the current point."

SO: the backward G direction is NOT available from chain properties alone. It comes from the truth lemma, which is what we're trying to build.

THE ACTUAL PROOF OF RESTRICTED_TC must use the chain's CONSTRUCTION, not its abstract properties. Specifically:

At step n, F(phi) in chain(n). phi is scheduled at some step k >= n (by schedule_surjective_above). At step k+1, the chain resolves schedule(k) = phi. The resolution uses `fwd_succ_fc(chain(k), h_mcs_k, phi)`. If F(phi) in chain(k), then phi in chain(k+1) by `fwd_succ_fc_resolves`. So we need: F(phi) persists from step n to step k.

CLAIM (F-persistence): F(phi) in chain(n) and phi not in chain(m) for any n < m <= k implies F(phi) in chain(k).

Can we prove this? At each step m, chain(m+1) = fwd_succ_fc(chain(m), h_mcs_m, schedule(m)). The MCS chain(m+1) extends g_content(chain(m)) (plus possibly {schedule(m)} if F(schedule(m)) in chain(m)). chain(m+1) is a COMPLETE MCS, so either F(phi) in chain(m+1) or G(neg(phi)) in chain(m+1).

If G(neg(phi)) in chain(m+1), then neg(phi) in chain(r) for all r > m+1 (by g_content propagation). If phi not in chain(m+1) (assumed), then neg(phi) in chain(m+1) (MCS completeness). But does neg(phi) in chain(m+1) AND G(neg(phi)) in chain(m+1) cause a problem? No, they're consistent.

The issue is: can G(neg(phi)) enter chain(m+1) when F(phi) was in chain(m)? Let's check:
- F(phi) in chain(m) means neg(G(neg(phi))) in chain(m)
- G(neg(phi)) in chain(m+1) means G(neg(phi)) is in the MCS extension of the seed
- The seed INCLUDES g_content(chain(m)). G(neg(phi)) is in chain(m+1) iff the Lindenbaum extension chooses it.
- Is G(neg(phi)) consistent with the seed? The seed is `{schedule(m)} ∪ g_content(chain(m))` (assuming F(schedule(m)) in chain(m)). G(neg(phi)) is consistent with this seed UNLESS the seed implies F(phi). Does `g_content(chain(m))` imply F(phi)? Not in general.
- So YES, G(neg(phi)) CAN enter chain(m+1) even when F(phi) was in chain(m). F-persistence is NOT guaranteed.

THEREFORE: restricted_tc is unprovable for the EXISTING chain construction. We MUST modify the chain.

THE ACTUAL MODIFICATION NEEDED: At each step, the seed must include enough to ensure that F-formulas from deferralClosure(root) that are currently in the chain PERSIST. The way to do this is:

**Include `F(phi)` (not `phi`, but `F(phi)` itself) in the seed for each phi in deferralClosure(root) with F(phi) in the current chain element.**

The seed becomes: `g_content(M) ∪ {schedule(n)} (if F(schedule(n)) in M) ∪ {F(phi) | phi in deferralClosure(root) and F(phi) in M}`.

Consistency of this seed: `g_content(M) ∪ {F(phi1), ..., F(phi_m)}` where each `F(phi_i) in M`.

CLAIM: This set is consistent.

PROOF: Suppose not. There's a derivation `G(chi_1), ..., G(chi_k), F(phi_1), ..., F(phi_m) ⊢ bot`. Each `G(chi_j) in M` and each `F(phi_i) in M`.

By multiple applications of the deduction theorem: `G(chi_1), ..., G(chi_k) ⊢ F(phi_1) → (F(phi_2) → ... → (F(phi_m) → bot))`.

Now, F(phi_i) = neg(G(neg(phi_i))). So `F(phi_1) → (... → (F(phi_m) → bot))` is logically equivalent to `neg(G(neg(phi_1))) → (... → bot)`. This is a propositional tautology of the form `neg(A1) → (neg(A2) → ... → bot)` which simplifies to `A1 ∨ A2 ∨ ... ∨ A_m` (roughly). So the derivation says: `g_content(M) ⊢ G(neg(phi_1)) ∨ ... ∨ G(neg(phi_m))`.

By G-necessitation of this derivation: since all premises are G-formulas, `G(G(neg(phi_1)) ∨ ... ∨ G(neg(phi_m)))` is derivable from `G(G(chi_1)), ...`. Actually, necessitation applied once gives `G(g_content ⊢ disjunction)`, and since G distributes over conjunction (via K), we get `G(neg(phi_1)) ∨ ... ∨ G(neg(phi_m)) ∈ M` (since all G(chi_j) in M).

This means: at least one `G(neg(phi_i)) ∈ M`. But we also have `F(phi_i) = neg(G(neg(phi_i))) ∈ M`. Contradiction with MCS consistency.

Wait, that's not right. `G(neg(phi_1)) ∨ G(neg(phi_2)) ∈ M` does not imply `G(neg(phi_1)) ∈ M` or `G(neg(phi_2)) ∈ M`. MCS primeness gives: either `G(neg(phi_1)) ∈ M` or `G(neg(phi_2)) ∈ M`. And MCS DOES have primeness (it's maximal consistent).

So: if `g_content(M) ∪ {F(phi_1), ..., F(phi_m)}` is inconsistent, then by the above argument, there exists some i with `G(neg(phi_i)) ∈ M`, contradicting `F(phi_i) ∈ M`. Contradiction.

THEREFORE: `g_content(M) ∪ {F(phi_1), ..., F(phi_m)}` IS consistent when each `F(phi_i) ∈ M`.

And `g_content(M) ∪ {schedule(n)} ∪ {F(phi_1), ..., F(phi_m)}` is also consistent when `F(schedule(n)) ∈ M` and each `F(phi_i) ∈ M`: the same argument works with one additional formula in the seed.

THIS IS THE KEY LEMMA. With this, we can build a modified chain that includes ALL pending F-formulas (as F(phi), not phi) in the seed, ensuring they persist to the next step. When the schedule eventually hits phi, F(phi) is still in the chain, and phi gets resolved.

**Tasks**:
- [ ] **Task 2.1**: Prove `deferral_f_seed_consistent`: if M is an MCS and S = {F(phi) | phi in deferralClosure(root) and F(phi) in M}, then `g_content(M) ∪ S` is fc-consistent. The proof uses the MCS primeness + contrapositive argument described above.
- [ ] **Task 2.2**: Prove the symmetric version `deferral_p_seed_consistent` for P-formulas and h_content.
- [ ] **Task 2.3**: Prove `full_temporal_seed_consistent`: if M is an MCS, `F(psi) in M`, and S_F = {F(phi) | phi in deferralClosure(root) and F(phi) in M}, then `{psi} ∪ g_content(M) ∪ S_F` is fc-consistent. (Adding the scheduled formula's witness to the seed.)
- [ ] **Task 2.4**: Define `fwd_succ_full`: the modified forward step that uses the full temporal seed `{psi} ∪ g_content(M) ∪ {F(phi) | phi in dc(root) and F(phi) in M}` (when `F(psi) in M`) or `g_content(M) ∪ {F(phi) | phi in dc(root) and F(phi) in M}` (otherwise).
- [ ] **Task 2.5**: Prove `fwd_succ_full_mcs`, `fwd_succ_full_g_content`, `fwd_succ_full_resolves` (analogous to existing lemmas).
- [ ] **Task 2.6**: Prove `fwd_succ_full_preserves_F`: if `F(phi) in M` and `phi in deferralClosure(root)`, then `F(phi) in fwd_succ_full(M, h_mcs, root, psi)`. This is the KEY new lemma: F(phi) is in the seed, so it's in any Lindenbaum extension of the seed.
- [ ] **Task 2.7**: Define the symmetric `bwd_pred_full` with P-formula preservation.
- [ ] **Task 2.8**: Define `fwd_chain_full`, `bwd_chain_full`, `int_chain_full` using the modified steps.
- [ ] **Task 2.9**: Prove g_content propagation and MCS properties for the new chain.
- [ ] **Task 2.10**: Prove F-persistence for the full chain: if `F(phi) in int_chain_full(M, root, n)` and `phi in deferralClosure(root)`, then `F(phi) in int_chain_full(M, root, n+1)` (by `fwd_succ_full_preserves_F` applied at each step, using induction).

**Timing**: 3 hours

**Depends on**: 1 (uses deferralClosure infrastructure, but this phase can largely be developed in parallel since it's about seed consistency, not chain construction)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- add the modified chain construction with F-preservation

**Verification**:
- `deferral_f_seed_consistent` type-checks without sorry
- `fwd_succ_full_preserves_F` type-checks without sorry
- `lake build Bimodal.Metalogic.BXCanonical.CanonicalModel` passes

---

### Phase 3: Prove Restricted Coherence and Build Modified BFMCS [NOT STARTED]

**Goal**: Prove restricted_tc, restricted_buc, restricted_fuc for the modified BFMCS, and define `henkin_bfmcs_full`.

**Strategy**:

**3a. restricted_tc**:
F(phi) in chain_full(n) and phi in deferralClosure(root). By F-persistence (Phase 2 Task 2.10), F(phi) in chain_full(m) for all m >= n. By schedule_surjective_above, there exists k >= n with schedule(k) = phi. At step k+1, fwd_succ_full resolves phi (since F(phi) in chain_full(k) by persistence). So phi in chain_full(k+1). QED.

**3b. restricted_buc**:
The existing `cantor_bfmcs_discrete_restricted_buc` proof is already sorry-free and works for ANY FMCS whose chain elements are MCSes. The proof uses only MCS properties (negation completeness, consistency, Until axioms in MCS). Adapt this proof to the modified chain. The key lemma is the C4 condition (neg(U(phi,psi)) in chain(n) and phi in chain(m) with n < m implies exists k with n < k < m and neg(psi) in chain(k)), which follows from the Until induction axiom applied within each MCS along the chain.

**3c. restricted_fuc**:
From `U(phi,psi) in fam.mcs(t)`, derive `F(phi)` using Until axioms (`U(phi,psi) -> phi | (psi & F(U(phi,psi)))`, and by induction, `U(phi,psi) -> F(phi)`). Then by restricted_tc, phi appears at some future step. The guard (psi at intermediate points) follows from the C4 condition (contrapositive of backward Until coherence applied to the interval).

**Tasks**:
- [ ] **Task 3.1**: Define `henkin_bfmcs_full`: BFMCS using `shifted_bx_fmcs_full` families. Same structure as `henkin_bfmcs` but using the modified chain. Prove `modal_forward`, `modal_backward`, `eval_family_mem` (same proofs as `henkin_bfmcs` since box stability is unchanged).
- [ ] **Task 3.2**: Prove `henkin_bfmcs_full_restricted_tc`: using F-persistence + schedule_surjective_above + fwd_succ_full_resolves.
- [ ] **Task 3.3**: Prove C4 condition for the modified chain: `int_chain_full_c4` (neg(U(phi,psi)) propagation along the chain). Uses Until induction axiom in MCS.
- [ ] **Task 3.4**: Prove C4' condition (Since symmetric): `int_chain_full_c4'`.
- [ ] **Task 3.5**: Prove `henkin_bfmcs_full_restricted_buc`: using C4/C4' conditions, following the existing template.
- [ ] **Task 3.6**: Prove `until_implies_some_future`: `U(phi,psi) -> F(phi)` as a derivation tree (or find existing).
- [ ] **Task 3.7**: Prove `henkin_bfmcs_full_restricted_fuc`: using `until_implies_some_future` + restricted_tc + C4 guard argument.
- [ ] **Task 3.8**: Verify `lake build Bimodal.Metalogic.BXCanonical.CanonicalModel` passes.

**Timing**: 3 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- add restricted coherence proofs and BFMCS definition

**Verification**:
- All three restricted coherence theorems type-check without sorry
- `lake build` for the module passes

---

### Phase 4: Rewire completeness_discrete and Verify [NOT STARTED]

**Goal**: Replace `cantor_bfmcs_discrete` with `henkin_bfmcs_full` in `countermodel_discrete_reynolds`, verify `#print axioms completeness_discrete` shows no sorryAx, full build verification.

**Tasks**:
- [ ] **Task 4.1**: Rewrite `countermodel_discrete_reynolds` in Transfer.lean to use `henkin_bfmcs_full` instead of `cantor_bfmcs_discrete`. Update the BFMCS, root family, membership proof, and coherence condition arguments. The root family is `shifted_bx_fmcs_full A h_mcs root 0` with `shifted_bx_fmcs_full_at_s` giving `mcs 0 = A`.
- [ ] **Task 4.2**: Update the `countermodel_discrete_enriched` in Completeness.lean if needed (or verify it already works via the updated `countermodel_discrete_reynolds`).
- [ ] **Task 4.3**: Run full `lake build` and verify zero errors.
- [ ] **Task 4.4**: Add `#print axioms completeness_discrete` check in Completeness.lean and verify no `sorryAx`.
- [ ] **Task 4.5**: Update docstrings on `countermodel_discrete_reynolds` to reflect the modified Henkin chain approach.
- [ ] **Task 4.6**: Update the Sorry Dependency Tree comments in Completeness.lean.

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- rewrite `countermodel_discrete_reynolds`
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- update axiom audit, possibly `countermodel_discrete_enriched`
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- update docstrings

**Verification**:
- `countermodel_discrete_reynolds` uses `henkin_bfmcs_full` (grep confirms no reference to `cantor_bfmcs_discrete`)
- `#print axioms completeness_discrete` shows no `sorryAx`
- Full `lake build` passes with zero errors
- All docstrings accurately reflect current proof state

## Testing & Validation

- [ ] `deferral_f_seed_consistent` has no sorry after Phase 2
- [ ] `fwd_succ_full_preserves_F` has no sorry after Phase 2
- [ ] `henkin_bfmcs_full_restricted_tc` has no sorry after Phase 3
- [ ] `henkin_bfmcs_full_restricted_buc` has no sorry after Phase 3
- [ ] `henkin_bfmcs_full_restricted_fuc` has no sorry after Phase 3
- [ ] `countermodel_discrete_reynolds` references `henkin_bfmcs_full` (not `cantor_bfmcs_discrete`) after Phase 4
- [ ] `#print axioms completeness_discrete` shows no `sorryAx` after Phase 4
- [ ] Full `lake build` passes with zero errors after Phase 4

## Artifacts & Outputs

- plans/54_implementation-plan.md (this file)
- summaries/54_execution-summary.md (to be created at implementation completion)

## Rollback/Contingency

1. **Fallback A (multi-formula seed fails)**: If the consistency proof for `g_content(M) ∪ {F(phi_1), ..., F(phi_m)}` is harder than expected in Lean (the MCS primeness + disjunction argument), try proving it for a FIXED BOUND on m (e.g., m <= |deferralClosure(root)|) by induction on m: `g_content(M) ∪ {F(phi_1)}` is consistent (standard), then `g_content(M) ∪ {F(phi_1), F(phi_2)}` by extending the argument.

2. **Fallback B (simplified deferral tracking)**: Instead of tracking all F-formulas from deferralClosure(root), only preserve F-formulas that are subformulas of root. This may reduce the seed size and simplify the consistency argument.

3. **Fallback C (accept existing restricted_buc and close only restricted_tc)**: Since restricted_buc is already sorry-free, if restricted_fuc proves harder than expected, try proving restricted_tc first and assessing whether restricted_fuc follows mechanically from restricted_tc + Until axioms.

4. **Fallback D (GoodStructuresModelSurgery route)**: If the modified Henkin chain approach proves intractable, revisit the `no_gaps_discrete_model_surgery` path (task 155 original scope). The import cycle between GoodStructures.lean and GoodStructuresModelSurgery.lean may be resolvable by extracting shared definitions to a new file.

5. **Fallback E (partial progress)**: Save all completed lemmas and definitions even if the full pipeline isn't connected. Each intermediate result (seed consistency, F-persistence, restricted_tc) has independent value for future plan versions.
