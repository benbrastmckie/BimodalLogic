# Implementation Plan: Task #107 (v21 -- Burgess Lemma 2.6 for BurgessR3Maximal, Correct g-Construction)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: [NOT STARTED]
- **Effort**: 55 hours
- **Dependencies**: None (irr_until branch)
- **Research Inputs**: [reports/34_team-research.md] (4 teammates, unanimous), [reports/28-33_prior-rounds.md]
- **Artifacts**: plans/34_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The Burgess 1982 chronicle construction for BX completeness has 9 remaining sorry sites: 7 in `CounterexampleElimination.lean` (c2' field for new adjacent pairs) and 2 in `ChronicleToCountermodel.lean` (forward Until/Since coherence at the limit). Team research (report 34, 4/4 unanimous) identified the root cause: all elimination functions pass `g = chi.g` unchanged, leaving new adjacent pairs with undefined (empty) g-values. The density elimination compounds this by setting `f(z) = f(x)` instead of constructing a fresh MCS, creating an unsatisfiable "self-pair" blocker.

The fix requires formalizing Burgess Lemma 2.6 for the content-based `BurgessR3Maximal` relation (the existing `lemma_2_6_full` for obligation-based `R3Maximal` trivially returns D=B and is useless for splitting), then using it to construct proper g-values within each elimination function. The plan is strictly sequential (shared files prevent parallelism) and preserves all completed phases from plan v20.

Definition of done: `dd_countermodel_chronicle` is sorry-free; `#print axioms` shows no `sorryAx`; `lake build` succeeds.

### Research Integration

- **Report 34 (team research, 4 teammates, unanimous)**: Primary input. Identified root cause (empty g-values), proved density `f(z)=f(x)` is unsatisfiable, confirmed `burgessR3_absorption` goes wrong direction, confirmed intersection-based `limit_g` is correct once g-values are non-empty, established BX axiom substitution path for Lemma 2.6 (BX5+BX6+BX7 for A4a, BX4+BX5 for A3a).
- **Reports 28-33 (prior rounds)**: Established BurgessR3Maximal, cruft purge, existence proof, guard algebra. All integrated in plans v17-v20.
- **Task 113 literature review**: Confirmed no alternative approach exists for S5+U/S+strict chronicle. These are engineering tasks following Burgess/Xu directly.

### Prior Plan Reference

Plan v20 (artifact 33): Phases 1, 1.5, 2, 4A [COMPLETED]. Phase 3 [PARTIAL] -- `rebuild_g` deleted, `burgessR3Maximal_exists_general` (FALSE) deleted, `c2'` field added to `EliminationResult`, but all 7 c2' sorry sites remain. The Phase 3 approach of using `burgessR3_absorption` for C4/density splitting was wrong (absorption goes parts-to-whole, not whole-to-parts). This plan replaces Phase 3-5 with a mathematically correct approach using Burgess Lemma 2.6 for the whole-to-parts splitting.

Key lessons from prior plan: (1) `burgessR3Maximal_exists_general` is FALSE -- never construct BurgessR3Maximal from arbitrary seeds; (2) `burgessR3_absorption` is Lemma 2.5 (composition), NOT Lemma 2.6 (splitting); (3) setting `f(z) = f(x)` creates provably unsatisfiable self-pairs; (4) the intersection-based `limit_g` definition IS correct for the dense limit, contra report 33's claim.

### Roadmap Alignment

- Advances: "TM is complete with respect to TaskFrames over totally ordered abelian groups" (representation theorem)
- Chronicle pathway is the primary completeness path (ROADMAP Section 2)
- Closing all 9 sorry sites achieves the chronicle sorry-free milestone

## Goals & Non-Goals

**Goals**:
- Formalize Burgess Lemma 2.6 for `BurgessR3Maximal(A, B, C)`: given `delta not in B`, construct `D, B', B''` with `BurgessR3Maximal(A, B', D)`, `BurgessR3Maximal(D, B'', C)`, and `neg(delta) in D`
- Modify C5/C5' elimination functions to construct g-values via `burgessR3Maximal_exists_from_seed` after `lemma_2_4` provides the endpoint
- Modify C4/C4' elimination functions to construct g-values via Lemma 2.6 splitting on the existing `BurgessR3Maximal(f(x), g(x,y), f(y))`
- Fix density elimination: replace `f(z) = f(x)` with `f(z) = D` from Lemma 2.6; construct g-values for new pairs from `B', B''`
- Close all 7 c2' sorry sites in CounterexampleElimination.lean
- Prove g-immutability across omega-chain stages (old pairs preserve g-values)
- Close 2 restricted_fuc sorry sites in ChronicleToCountermodel.lean using C5 seed + g-immutability + C3 interval containment
- Remove g_prop/h_prop elimination kinds if subsumed by C4 with proper g-values
- Achieve sorry-free `dd_countermodel_chronicle`
- Maintain `lake build` at each phase boundary

**Non-Goals**:
- Adding density axioms (GG->G, HH->H) -- wrong for BX
- Patching `burgessR3Maximal_exists_general` -- it is FALSE, not fixable
- Using `burgessR3_absorption` for splitting -- wrong direction (parts-to-whole)
- Changing `limit_g` from intersection-based to stage-based -- intersection IS correct for dense limit
- Keeping `rebuild_g` in any form -- deleted in prior phase
- Setting `f(z) = f(x)` in any elimination -- always construct fresh MCS via Lemma 2.6
- C5 n>0 case (insert between existing points) -- current construction avoids it
- BXCanonical sorry closure (task 109)
- Deleting rRelation or R3Maximal -- existing sorry-free code uses them

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Lemma 2.6 consistency proof for BurgessR3Maximal requires novel BX axiom chains | H | M | The existing `lemma_2_4` uses analogous BX techniques (BX4, BX5, seed consistency) and is sorry-free. Follow the same pattern. BX axiom substitutions for A3a/A4a are documented in PointInsertion.lean header. |
| The `B = B' inter D inter B''` splitting identity may be hard to prove for BurgessR3Maximal | H | M | Start with the weaker statement (existence of B', B'' without the equality), which suffices for c2'. The equality is a nice-to-have for C3 but may not be needed if we prove c2' directly. |
| Density elimination f(z) = D change cascades through c0, c2', c4 proofs | M | H | The density case currently uses `f(z) = f(x)` which is provably wrong. Any correct solution MUST change f(z). The replacement `f(z) = D` from Lemma 2.6 provides all needed properties (MCS, neg(delta) in D, BurgessR3Maximal for new pairs). |
| g_prop/h_prop removal may break g_agrees fields on EliminationResult | M | L | g_prop/h_prop already set g = chi.g (unchanged). Removing them only removes counterexample kinds from PotentialCounterexample, which is an inductive type change. Alternatively, keep them but give proper g-values. |
| FUC proof requires tracking which formulas enter g-values at C5 elimination | M | M | The C5 elimination constructs g(x,y) via `burgessR3Maximal_exists_from_seed`. The seed includes the Until guard (via Lemma 2.4's g_content(A) subset C). The guard enters B by the BurgessR3Maximal extension. Document the witness chain explicitly. |
| g-immutability across omega-chain stages is non-trivial | M | M | Each elimination function already has `g_agrees` on old domain pairs. g-immutability follows from composing these across stages, identical to the existing `omega_chain_f_agrees_le` proof pattern. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 0 | 1, 1.5, 2, 4A | -- (completed in plan v20) |
| 1 | 1 | -- (completed phases only) |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

All phases are strictly sequential (shared files: PointInsertion.lean, CounterexampleElimination.lean, ChronicleConstruction.lean, ChronicleToCountermodel.lean).

---

### Phase 1: Formalize Burgess Lemma 2.6 for BurgessR3Maximal [NOT STARTED]

**Goal**: Prove the BurgessR3Maximal splitting lemma: given `BurgessR3Maximal(A, B, C)` and `delta not in B`, construct a fresh MCS D with `neg(delta) in D`, plus DCS B' and B'' with `BurgessR3Maximal(A, B', D)` and `BurgessR3Maximal(D, B'', C)`. This is the single most important missing piece of infrastructure.

**Tasks**:
- [ ] **1.1** Prove seed consistency for Lemma 2.6: show that `S_left(A, B) union B union {neg(delta)} union S_right(C, B)` is consistent, where `S_left(A, B) = {S(alpha, beta) : alpha in A, beta in B}` captures "Until obligations from A resolved through B" and `S_right(C, B) = {U(gamma, beta) : gamma in C, beta in B}` captures "Since obligations from C resolved through B". The key argument: if this set is inconsistent, derive a contradiction using BX5+BX6+BX7 (subsuming A4a's role) and BX4+BX5 (subsuming A3a's role). Follow the pattern of `until_witness_seed_consistent` and `forward_temporal_witness_seed_consistent` in PointInsertion.lean.
  - Files: `Chronicle/PointInsertion.lean` (~100 lines)
  - Estimate: 10 hours

- [ ] **1.2** Construct MCS D via Lindenbaum extension of the consistent seed. Prove `neg(delta) in D`, `g_content(A) subset D`, and `h_content(C) subset D`.
  - Files: `Chronicle/PointInsertion.lean` (~40 lines)
  - Estimate: 2 hours

- [ ] **1.3** Construct B' (left interval): From the seed consistency and D, show `burgessR3(A, S_left(A,B) inter B inter D, D)` holds, then extend to `BurgessR3Maximal(A, B', D)` via `burgessR3Maximal_extension_exists`. Similarly construct B'' (right interval) with `BurgessR3Maximal(D, B'', C)`.
  - Files: `Chronicle/PointInsertion.lean` (~80 lines), `Chronicle/RRelation.lean` (helper lemmas)
  - Estimate: 8 hours

- [ ] **1.4** Assemble the full `burgess_lemma_2_6_content` theorem statement and proof:
  ```lean
  theorem burgess_lemma_2_6_content (A B C : Set Formula)
      (h_A : SetMaximalConsistent A) (h_C : SetMaximalConsistent C)
      (h_R : BurgessR3Maximal A B C) (delta : Formula) (h_notin : delta not_in B) :
      exists D B' B'', SetMaximalConsistent D ∧ delta.neg in D ∧
        BurgessR3Maximal A B' D ∧ BurgessR3Maximal D B'' C
  ```
  - Files: `Chronicle/PointInsertion.lean` (~30 lines)
  - Estimate: 2 hours

- [ ] **1.5** Run `lake build` and verify no regressions. The new lemma should be additive (no existing code modified).
  - Estimate: 1 hour

**Timing**: 23 hours

**Depends on**: none (completed phases only)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- new `burgess_lemma_2_6_content` theorem and helper lemmas (~250 lines added)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- possible helper lemmas for burgessR3/burgessRSet properties (~50 lines)

**Verification**:
- `burgess_lemma_2_6_content` compiles sorry-free
- All existing sorry-free lemmas remain sorry-free
- `lake build` succeeds

**Mathematical Detail**:

The consistency argument is the crux. Burgess's proof (Lemma 2.6) argues by contradiction: assume the seed set is inconsistent. Then there exist finite subsets of each component that together derive bot. By chaining BX axioms:

1. From `S_left(A, B)`: these are `untl(beta, alpha)` for `alpha in A`, `beta in B`. If finitely many enter the derivation, their conjunction is in A (MCS closure).
2. From B: finitely many elements, their conjunction is in B (DCS closure).
3. From `{neg(delta)}`: exactly `neg(delta)`.
4. From `S_right(C, B)`: these are `snce(beta, gamma)` for `gamma in C`, `beta in B`. If finitely many enter the derivation, their conjunction is in C (MCS closure).
5. Combine using BX5 (self_accum_until) to accumulate guards, BX6 (absorb_until) to absorb, BX7 (linear_until) for linearity, and BX4 (connect_future) for connection. The existing `lemma_2_4` seed consistency proof provides the template.
6. Reach a contradiction with `delta not_in B` (since B is DCS and `neg(delta) not_in B` by BurgessR3Maximal negation completeness, yet the derivation forces `delta in B`).

---

### Phase 2: Modify Elimination Functions to Construct g-Values [NOT STARTED]

**Goal**: Modify all 7 elimination functions (C5, C5', C4, C4', density, g_prop, h_prop) to construct proper g-values for new adjacent pairs. Close the 7 c2' sorry sites. Fix the density elimination to use `f(z) = D` from Lemma 2.6 instead of `f(z) = f(x)`.

**Tasks**:
- [ ] **2.1** Modify `eliminate_C5_counterexample` (lines ~170-205): After `lemma_2_4` produces endpoint C with `g_content(A) subset C`, construct B via `burgessR3Maximal_exists_from_seed(f(x_max), C, eta)` where eta comes from Lemma 2.4. Change the chronicle's g to set `g'(x_max, y) = B` for the new pair. Update the return type to include g-value modification proof. The `c2'` for the new pair `(x_max, y)` follows directly from BurgessR3Maximal.
  - Files: `Chronicle/CounterexampleElimination.lean` (~60 lines modified)
  - Estimate: 3 hours

- [ ] **2.2** Modify `eliminate_C5'_counterexample` (lines ~211-250): Mirror of 2.1 using Since direction. Construct B via `burgessR3Maximal_exists_from_seed` in the past direction. Set `g'(y, x_min) = B`.
  - Files: `Chronicle/CounterexampleElimination.lean` (~60 lines modified)
  - Estimate: 2 hours

- [ ] **2.3** Modify `eliminate_C4_counterexample` (C4 forward): Apply `burgess_lemma_2_6_content` to `BurgessR3Maximal(f(x), g(x,y), f(y))` with the delta from the C4 counterexample. Get D, B', B''. Set `f'(z) = D`, `g'(x, z) = B'`, `g'(z, y) = B''`. The `c2'` for new pairs `(x, z)` and `(z, y)` follows from BurgessR3Maximal output. Update the density case (lines 1000-1086) with the same pattern but using any `delta not_in g(x,y)` (which exists since g(x,y) is a proper DCS, not an MCS, by BurgessR3Maximal -- but note: BurgessR3Maximal B means B could be MCS; check if the density case needs a different approach).
  - Files: `Chronicle/CounterexampleElimination.lean` (~80 lines modified)
  - Estimate: 4 hours

- [ ] **2.4** Modify `eliminate_C4'_counterexample` (C4 backward): Mirror of 2.3 using Since direction.
  - Files: `Chronicle/CounterexampleElimination.lean` (~80 lines modified)
  - Estimate: 3 hours

- [ ] **2.5** Fix `density` elimination (lines 990-1086): This is the most architecturally wrong case. Currently sets `f(z) = f(x)` creating provably unsatisfiable self-pairs. Replace with: apply `burgess_lemma_2_6_content` to `BurgessR3Maximal(f(x), g(x,y), f(y))` with any formula `delta` such that `delta not_in g(x,y)`. If `g(x,y)` is already an MCS (possible under BurgessR3Maximal), then there is no such delta. In that case, set `f(z) = g(x,y)` (which is an MCS) and construct B', B'' by reflexivity of burgessR3 on MCS -- this is the `lemma_2_6_full` pattern. If `g(x,y)` is not MCS, pick any `delta not_in g(x,y)` (exists by non-maximality) and apply Lemma 2.6. Set `f'(z) = D`, `g'(x,z) = B'`, `g'(z,y) = B''`. The c2' for new pairs follows from BurgessR3Maximal.
  - Files: `Chronicle/CounterexampleElimination.lean` (~100 lines modified)
  - Estimate: 4 hours

- [ ] **2.6** Handle g_prop/h_prop elimination: Two options: (a) Remove g_prop/h_prop counterexample kinds entirely (they are subsumed by C4 with proper g-values, as proved by Teammate D: G(alpha) = neg(top U neg(alpha))). This requires modifying `PotentialCounterexampleKind` which cascades. (b) Keep them but give proper g-values using the same Lemma 2.6 pattern. Option (b) is safer: apply Lemma 2.6 to `g(x, x_next)` or `g(z_prev, y)`, set new g-values from the output. The c2' follows.
  - Files: `Chronicle/CounterexampleElimination.lean` (~60 lines modified)
  - Estimate: 2 hours

- [ ] **2.7** Update `eliminate_potential_counterexample` dispatch (lines 763-1154): Each match arm currently has `c2' := sorry`. After modifications in 2.1-2.6, replace sorry with the c2' proof produced by the modified elimination functions. Ensure `g_agrees` field is updated: old pairs still satisfy `val.g a b = chi.g a b` for `a in chi.dom` and `b in chi.dom`. New pairs have the constructed g-values. The `g_agrees` field currently says `forall a b, a in chi.dom -> b in chi.dom -> val.g a b = chi.g a b` which is correct (new points are NOT in chi.dom).
  - Files: `Chronicle/CounterexampleElimination.lean` (~40 lines modified)
  - Estimate: 2 hours

- [ ] **2.8** Run `lake build` and verify all 7 c2' sorry sites are closed.
  - Estimate: 1 hour

**Timing**: 21 hours

**Depends on**: Phase 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- all 7 elimination functions modified, 7 sorry sites closed (~400 lines changed)

**Verification**:
- 0 sorry sites in CounterexampleElimination.lean (grep -c "sorry" finds only comments)
- `lake build` succeeds
- `omega_chain` still returns `{chi // chi.c0 AND chi.c2'}` with no sorry in the recursion
- All `g_agrees` fields still proved (old pairs preserve g-values)
- f-agreement still proved (old points preserve f-values)

---

### Phase 3: g-Immutability and Limit g-Value Properties [NOT STARTED]

**Goal**: Prove g-immutability across omega-chain stages (for old pairs, g-values are preserved), then derive limit-level properties: limit_g contains the finite-stage g-values for the first stage where both points are in the domain, and BurgessR3Maximal holds at the limit for "limit-adjacent" pairs (vacuously true since limit domain is dense).

**Tasks**:
- [ ] **3.1** Prove `omega_chain_g_agrees` (single step): for `a in dom(n)` and `b in dom(n)`, `(omega_chain_val n+1).g a b = (omega_chain_val n).g a b`. This follows directly from `EliminationResult.g_agrees`.
  - Files: `Chronicle/ChronicleConstruction.lean` (~15 lines)
  - Estimate: 1 hour

- [ ] **3.2** Prove `omega_chain_g_agrees_le` (transitive): for `m <= n` and `a in dom(m)`, `b in dom(m)`, `(omega_chain_val n).g a b = (omega_chain_val m).g a b`. Proof by induction on `n - m`, same pattern as `omega_chain_f_agrees_le`.
  - Files: `Chronicle/ChronicleConstruction.lean` (~20 lines)
  - Estimate: 1 hour

- [ ] **3.3** Prove `limit_g_contains_finite_stage`: for `x < y` both in `limit_dom`, if both `x in dom(n)` and `y in dom(n)`, and `phi in (omega_chain_val n).g x y`, then `phi in limit_g x y`. Proof: for any `w in limit_dom` with `x < w < y`, `w` enters dom at some stage `m`. At stage `max(n, m)`, both `x, y, w` are in the domain. By C3 at stage `max(n,m)`: `g(x,y) subset f(w)`. By g-immutability: `g_{max(n,m)}(x,y) = g_n(x,y)`. So `phi in f_{max(n,m)}(w) = limit_f(w)`. Since w is arbitrary, `phi in limit_g(x,y)`.
  - Files: `Chronicle/ChronicleConstruction.lean` (~40 lines)
  - Estimate: 3 hours

- [ ] **3.4** Verify that `limit_c3`, `limit_c3_interval_subset_point`, `limit_forward_G`, `limit_backward_H` remain sorry-free (they should, since they use the intersection-based `limit_g` which has not changed).
  - Files: `Chronicle/ChronicleConstruction.lean` (no changes, verification only)
  - Estimate: 0.5 hours

- [ ] **3.5** Run `lake build` and verify no regressions.
  - Estimate: 0.5 hours

**Timing**: 6 hours

**Depends on**: Phase 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- g-immutability lemmas, limit_g containment (~75 lines added)

**Verification**:
- `omega_chain_g_agrees` and `omega_chain_g_agrees_le` sorry-free
- `limit_g_contains_finite_stage` sorry-free
- All existing sorry-free lemmas remain sorry-free
- `lake build` succeeds

---

### Phase 4: Close FUC Sorry Sites [NOT STARTED]

**Goal**: Close the 2 `restricted_fuc` sorry sites (ChronicleToCountermodel.lean lines 615, 619) using the C5 guard construction + g-immutability + C3 interval containment + Cantor isomorphism transfer.

**Tasks**:
- [ ] **4.1** Prove the guard-at-intermediate-points lemma for the limit chronicle: Given `U(xi, eta) in limit_f(t)`, the C5 elimination at some stage n produces endpoint `s > t` with `eta in f_n(s)` and a BurgessR3Maximal `g_n(t, s)` with `xi in g_n(t, s)` (the guard enters through the BurgessR3Maximal construction from the Until seed). By `limit_g_contains_finite_stage` (Phase 3.3), `xi in limit_g(t, s)`. By `limit_c3_interval_subset_point`, for any `r in limit_dom` with `t < r < s`, `limit_g(t, s) subset limit_f(r)`, so `xi in limit_f(r)`.

  The key sub-obligation is showing `xi in g_n(t, s)`. This follows from the C5 elimination construction:
  - `lemma_2_4` gives C with `g_content(f(t)) subset C` and `eta in C`
  - `burgessR3Maximal_exists_from_seed` constructs B with `BurgessR3Maximal(f(t), B, C)`
  - The seed for B includes `{eta} union g_content(f(t))`, which contains Until guard information
  - `U(xi, eta) in f(t)` implies `G(P(U(xi, eta))) in f(t)` (BX4), so `P(U(xi, eta)) in g_content(f(t)) subset C`
  - Need to show `xi in B`: from `U(xi, eta) in f(t)`, by BX9 (until_elim), `xi or eta in f(t)`. By BX5 (self_accum), `U(xi and U(xi,eta), eta) in f(t)`. The burgessR3 construction ensures the guard `xi` propagates to B through the Until r-relation: `burgessRSet(f(t), B, C)` means for `U(xi, eta) in f(t)`, either `eta in B` (then `xi in B` follows from `xi and U(xi,eta) in B` via BX5 accumulation) or `xi in B and U(xi,eta) in B`.

  - Files: `Chronicle/ChronicleConstruction.lean` (~60 lines)
  - Estimate: 5 hours

- [ ] **4.2** Close `restricted_fuc` Until case (line 615): Transfer the limit-level guard proof through the Cantor isomorphism. The `cantor_bfmcs` uses a Cantor bijection `cantor_iso` from `LimitDomSubtype` to `Rat`. The Until coherence requires: for all `t`, if `U(phi, psi) in mcs(t)`, then there exists `s > t` with `psi in mcs(s)` and for all `r` with `t < r < s`, `phi in mcs(r)`. The `mcs` here is `cantor_fmcs.mcs = limit_f composed with cantor_iso.symm`. Transfer from limit-level proof via the isomorphism.
  - Files: `Chronicle/ChronicleToCountermodel.lean` (~40 lines)
  - Estimate: 3 hours

- [ ] **4.3** Close `restricted_fuc` Since case (line 619): Mirror of 4.2 using Since direction and backward C5'.
  - Files: `Chronicle/ChronicleToCountermodel.lean` (~40 lines)
  - Estimate: 3 hours

- [ ] **4.4** Run `lake build` and verify both sorry sites are closed.
  - Estimate: 0.5 hours

**Timing**: 11.5 hours

**Depends on**: Phase 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- limit-level guard lemma (~60 lines added)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- `restricted_fuc` Until/Since proofs (~80 lines modified, 2 sorry sites closed)

**Verification**:
- `cantor_bfmcs_restricted_fuc` sorry-free
- `dd_countermodel_chronicle` sorry-free
- `#print axioms dd_countermodel_chronicle` shows NO `sorryAx`
- `lake build` succeeds

---

### Phase 5: Cleanup and Final Validation [NOT STARTED]

**Goal**: Remove dead code, validate the full sorry-free chronicle, clean up scaffolding from prior plan versions. Optional: remove g_prop/h_prop if clearly subsumed.

**Tasks**:
- [ ] **5.1** Delete `lemma_2_6_full` (trivial D=B version, PointInsertion.lean line 838) -- superseded by `burgess_lemma_2_6_content`.
  - Files: `Chronicle/PointInsertion.lean` (~35 lines deleted)
  - Estimate: 0.5 hours

- [ ] **5.2** Clean up dead comments from prior plan versions: remove "Phase 3:" annotations on sorry sites (they are now closed), update docstrings on elimination functions to reflect the new g-construction approach.
  - Files: `Chronicle/CounterexampleElimination.lean`, `Chronicle/ChronicleConstruction.lean`, `Chronicle/ChronicleToCountermodel.lean` (~20 lines)
  - Estimate: 0.5 hours

- [ ] **5.3** Verify zero sorry sites in Chronicle/ directory: `grep -rn "sorry" Chronicle/` finds only comments, string literals, and docstring references.
  - Estimate: 0.5 hours

- [ ] **5.4** Run `#print axioms dd_countermodel_chronicle` and verify only Lean axioms (`propfunext`, `Quot.sound`, `Classical.choice`) -- no `sorryAx`.
  - Estimate: 0.5 hours

- [ ] **5.5** Full `lake build` verification (clean build). Verify Soundness, FMP, ParametricTruthLemma remain sorry-free.
  - Estimate: 1 hour

- [ ] **5.6** (Optional) Evaluate removing g_prop/h_prop counterexample kinds. If G-propagation follows from C4 with proper g-values (Teammate D's proof: G(alpha) = neg(top U neg(alpha)), so if G(alpha) in f(x) and alpha not in f(y) with x < y, then (top U neg(alpha)).neg in f(x) and neg(alpha) in f(y) -- this is a C4 counterexample), then g_prop/h_prop are redundant. Removing them simplifies `PotentialCounterexampleKind` and the dispatch in `eliminate_potential_counterexample`. However, this is a larger refactor. Only do if time permits and if the proof that C4 subsumes g_prop is straightforward.
  - Files: `Chronicle/CounterexampleElimination.lean`, `Chronicle/ChronicleTypes.lean`
  - Estimate: 2 hours (if done)

**Timing**: 3-5 hours

**Depends on**: Phase 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- delete `lemma_2_6_full`
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- docstring cleanup
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- docstring cleanup
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- docstring cleanup

**Verification**:
- Zero sorry sites in Chronicle/ directory
- `#print axioms dd_countermodel_chronicle` clean (no `sorryAx`)
- `lake build` succeeds (full clean build)
- Soundness, FMP, ParametricTruthLemma remain sorry-free
- No dead code from prior plan versions

## Testing & Validation

- [ ] Phase 1: `burgess_lemma_2_6_content` compiles sorry-free; all existing sorry-free lemmas unaffected; `lake build` passes
- [ ] Phase 2: All 7 c2' sorry sites closed in CounterexampleElimination.lean; omega_chain recursion sorry-free; `lake build` passes
- [ ] Phase 3: g-immutability proved sorry-free; `limit_g_contains_finite_stage` sorry-free; `lake build` passes
- [ ] Phase 4: `cantor_bfmcs_restricted_fuc` sorry-free; `dd_countermodel_chronicle` sorry-free; `#print axioms` clean; `lake build` passes
- [ ] Phase 5: Zero sorry in Chronicle/; dead code removed; full `lake build` clean
- [ ] No regression in existing sorry-free modules (Soundness, FMP, ParametricTruthLemma)
- [ ] `lake build` succeeds at each phase boundary

## Artifacts & Outputs

- `specs/107_.../plans/34_implementation-plan.md` (this file)
- Modified: `Chronicle/PointInsertion.lean` -- `burgess_lemma_2_6_content` theorem (~250 lines added, ~35 lines deleted)
- Modified: `Chronicle/RRelation.lean` -- helper lemmas for burgessR3 properties (~50 lines added)
- Modified: `Chronicle/CounterexampleElimination.lean` -- all 7 elimination functions modified, 7 sorry sites closed (~400 lines changed)
- Modified: `Chronicle/ChronicleConstruction.lean` -- g-immutability, limit_g containment, guard lemma (~135 lines added)
- Modified: `Chronicle/ChronicleToCountermodel.lean` -- `restricted_fuc` proofs (~80 lines modified, 2 sorry sites closed)
- Summary: `summaries/34_implementation-summary.md` (post-implementation)

## Rollback/Contingency

- **Git safety**: The `irr_until` branch preserves the current state. All changes can be reverted to HEAD (`a47b913ae`).
- **Phase 1 contingency (seed consistency)**: If the full Lemma 2.6 consistency proof is too complex, start with the special case where `g(x,y)` is NOT an MCS (guaranteeing existence of `delta not_in g(x,y)`). The MCS case is handled by `lemma_2_6_full` (trivial splitting, D=B). This covers density elimination.
- **Phase 1 contingency (BX axiom chain)**: If BX5+BX6+BX7 do not directly subsume A4a's role in the consistency argument, identify the exact BX axiom chain needed by examining the `lemma_2_4` seed consistency proof (which uses BX4+BX5 and works sorry-free). Document the gap and seek targeted research.
- **Phase 2 contingency (C5 g-value)**: If `burgessR3Maximal_exists_from_seed` does not produce a B with the right Until guard content, strengthen the theorem to carry the witness explicitly. Alternatively, use `burgess_lemma_2_6_content` for C5 as well (with delta chosen to not be in the DCS).
- **Phase 2 contingency (density)**: If `g(x,y)` turns out to be an MCS for all adjacent pairs at the relevant stage (making `burgess_lemma_2_6_content` inapplicable since there is no `delta not_in g(x,y)`), use the `lemma_2_6_full` pattern: set `f(z) = g(x,y)` (which is MCS), B' = B'' = g(x,y), with reflexive BurgessR3Maximal.
- **Phase 4 contingency (guard tracking)**: If the guard `xi in g_n(t,s)` is hard to extract from the BurgessR3Maximal construction, strengthen EliminationResult to carry explicit witness that `xi in val.g t s` for the C5 case.
- **Budget overrun**: Phases are sequential so partial progress is always meaningful. Each phase reduces sorry count independently. Phase 1 is the highest-risk phase; if it takes longer than estimated, Phases 2-5 can proceed more quickly since they follow established patterns.
